cbuffer PixelShaderConstants : register(b0)
{
    float4 g_vConst0      : packoffset(c0);  // vVig1: Center X (px), Center Y (px), Radius (px), Smooth Start Radius (px)
    float4 g_vConst1      : packoffset(c1);  // vVig2: Center X (px), Center Y (px), Radius (px), Smooth Start Radius (px)
    float4 g_vConst2      : packoffset(c2);  // vCAParams: xy = Red Offset Vector (UV), z = Lateral CA Base Strength, w = Lateral CA Angle Strength
    float4 g_vConst3      : packoffset(c3);  // vSceneParams: x = Lens K (Base), y = Unused, z = Res X, w = Res Y
    float4 g_vTexelSize0  : packoffset(c4);
    float4 g_vTexelSize1  : packoffset(c5);
    float4 g_vTexelSize2  : packoffset(c6);
    float4 g_vTexelSize3  : packoffset(c7);
    float4 g_vEyePos      : packoffset(c10);
    row_major float4x4 g_mViewProj    : packoffset(c11);
    row_major float4x4 g_mInvViewProj : packoffset(c15);
};

Texture2D<float4> g_BaseTexture       : register(t0);
SamplerState      g_BaseTextureSampler : register(s0);

struct PS_INPUT
{
    float4 vProjPos  : SV_Position;
    float2 vTexCoord : TEXCOORD0;
};

// -- Helper Functions --
float CircleMask(float2 p, float4 c)
{
    if (c.z <= 0.0) return 1.0;                      // radius 0 = circle disabled (DX9 behavior)
    float rIn = min(c.w, c.z - 1e-3);                // never let min == max
    return 1.0 - smoothstep(rIn, c.z, length(p - c.xy));
}

float GetVignetteFactor( float2 coords_px, float4 vig1, float4 vig2 )
{
    return CircleMask( coords_px, vig1 ) * CircleMask( coords_px, vig2 );
}


float2 lens_distort(float2 uv, float k1, float k2, float2 center)
{
    float2 d  = uv - center;
    float  r2 = dot(d, d);
    float  r4 = r2 * r2;
    float  f  = 1.0 + k1 * r2 + k2 * r4;
    return center + d * f;
}

// -- Main Pixel Shader --

float4 main(const PS_INPUT i) : SV_Target0
{
    float2 uv  = i.vTexCoord;
    float2 res = 1.0 / g_vTexelSize0.xy;
    float2 frag_p = uv * res;

    // 1. Primary Vignette (distortion weighting)
    float vig_factor = GetVignetteFactor(frag_p, g_vConst0, g_vConst1);

    // 2. Dynamic Distortion
    float factor     = 3.0 - pow(vig_factor, 1.25) * 1.75;
    float base_k     = g_vConst3.x;
    float dynamic_k1 = base_k * factor * 1.2;
    float dynamic_k2 = base_k * factor * 0.3;

    float2 d_uv = lens_distort(uv, dynamic_k1, dynamic_k2, float2(0.5, 0.5));

    // 3. Background Sampling with Lateral CA
    float2 center_uv  = float2(0.5, 0.5);
    float2 diff_uv    = uv - center_uv;
    float  r_dist     = length(diff_uv);
    float2 radial_dir = normalize(diff_uv);

    float ca_amount = g_vConst2.z * pow(abs(r_dist), 1.5) + g_vConst2.w * r_dist;

    float3 col;
    col.r = g_BaseTexture.Sample(g_BaseTextureSampler, d_uv + radial_dir * ca_amount * 2.5).r;
    col.g = g_BaseTexture.Sample(g_BaseTextureSampler, d_uv + radial_dir * ca_amount * 0.5).g;
    col.b = g_BaseTexture.Sample(g_BaseTextureSampler, d_uv - radial_dir * ca_amount * 1.8).b;

    // 4. Directional CA on Vignette Edges
    float2 off_r = g_vConst2.xy;
    float2 off_g = off_r *  0.25;
    float2 off_b = off_r * -0.75;

    col.r *= GetVignetteFactor(frag_p + (off_r * res), g_vConst0, g_vConst1);
    col.g *= GetVignetteFactor(frag_p + (off_g * res), g_vConst0, g_vConst1);
    col.b *= GetVignetteFactor(frag_p + (off_b * res), g_vConst0, g_vConst1);

    // 5. Final Tint
    col *= pow(vig_factor, 1.2);

    return float4(col, 1.0);
}