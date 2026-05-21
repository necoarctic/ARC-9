sampler ImageBuffer : register(s0);
sampler MaskTexture : register(s1); 

float2 C0                : register(c0);
float2 BUFFER_PIXEL_SIZE : register(c1);

struct PS_INPUT
{
    float2 vTexCoord   : TEXCOORD0;
};

float getFocus(float2 coord)
{
    float depth = tex2D(ImageBuffer, coord).a;
    float t     = saturate(depth / max(C0.y, 0.00001));
    return 1.0 - t * t; 
}

float2 rot2D(float2 pos, float angle)
{
    float sinPhi, cosPhi;
    sincos(angle, sinPhi, cosPhi);
    float2 source = float2(sinPhi, cosPhi);
    return float2(dot(pos, float2(source.y, -source.x)), dot(pos, source));
}

static const float2 poisson[12] =
{
    float2(-0.326, -0.406), float2(-0.840, -0.074), float2(-0.696,  0.457), float2(-0.203,  0.621),
    float2( 0.962, -0.195), float2( 0.473, -0.480), float2( 0.519,  0.767), float2( 0.185, -0.893),
    float2( 0.507,  0.064), float2( 0.896,  0.412), float2(-0.322, -0.933), float2(-0.792, -0.598)
};

half4 main(PS_INPUT i) : COLOR
{
    float2 uv = i.vTexCoord.xy;
    half3 col = (half3) 0.0;
    
    // OPTIMIZATION 1: Calculate focus ONCE at the center pixel outside the loop.
    // This breaks the dependency chain and eliminates 12 depth texture fetches.
    float centerFocus = getFocus(uv);

    float random = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    half4 basis  = float4(rot2D(float2(1.0, 0.0), random), rot2D(float2(0.0, 1.0), random));

    float2 stepScale = BUFFER_PIXEL_SIZE * C0.x;

    [unroll]
    for (int j = 0; j < 12; ++j)
    {
        float2 offset = poisson[j];
        offset = float2(dot(offset, basis.xz), dot(offset, basis.yw));

        // Calculate the maximum extent of the blur radius
        float2 max_coord = uv + offset * stepScale;
        
        // Check the mask at the maximum extent
        half masked = tex2D(MaskTexture, max_coord).r;
        clip(0.5 - masked); // Discards if masked == 1

        // OPTIMIZATION 2: Calculate final coord using the center focus.
        // We no longer need *(1-masked) because clip() already guaranteed masked is 0.
        float2 final_coord = lerp(uv, max_coord, centerFocus);
        
        col += (half3) tex2D(ImageBuffer, final_coord).rgb;
    }

    return half4(col * 0.083h, 1.0h);
}