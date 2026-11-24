cbuffer PixelShaderConstants : register(b0)
{
    float4 C0 : packoffset(c0);
    float4 BUFFER_PIXEL_SIZE : packoffset(c1);
};

Texture2D<float4> ImageBuffer : register(t0);
Texture2D<float4> MaskTexture : register(t1);

SamplerState ImageBufferSampler : register(s0);
SamplerState MaskTextureSampler : register(s1);

struct PS_INPUT
{
    float4 pPos      : SV_Position;
    float2 vTexCoord : TEXCOORD0;
};

float getFocus(float2 coord)
{
    float depth = ImageBuffer.SampleLevel(ImageBufferSampler, coord, 0.0).a;
    float t     = saturate(depth / max(C0.y, 0.00001));
    return 1.0 - t * t; // quadratic
}

// Helper for Poisson-disk rotation
float2 rot2D(float2 pos, float angle)
{
    float sinPhi, cosPhi;
    sincos(angle, sinPhi, cosPhi);

    float2 source = float2(sinPhi, cosPhi);

    return float2(
        dot(pos, float2(source.y, -source.x)),
        dot(pos, source)
    );
}

// Poisson disk samples
static const float2 poisson[12] =
{
    float2(-0.326, -0.406), float2(-0.840, -0.074), float2(-0.696,  0.457), float2(-0.203,  0.621),
    float2( 0.962, -0.195), float2( 0.473, -0.480), float2( 0.519,  0.767), float2( 0.185, -0.893),
    float2( 0.507,  0.064), float2( 0.896,  0.412), float2(-0.322, -0.933), float2(-0.792, -0.598)
};

float4 main(const PS_INPUT i) : SV_Target0
{
    float2 uv = i.vTexCoord;

    float3 col = 0.0;

    float random = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);

    float4 basis = float4(
        rot2D(float2(1.0, 0.0), random),
        rot2D(float2(0.0, 1.0), random)
    );

    float2 stepScale = BUFFER_PIXEL_SIZE.xy * C0.x;

    [unroll]
    for (int j = 0; j < 12; ++j)
    {
        float2 offset = poisson[j];

        offset = float2(
            dot(offset, basis.xz),
            dot(offset, basis.yw)
        );

        float2 coord = uv + offset * stepScale;

        float masked = MaskTexture.SampleLevel(MaskTextureSampler, coord, 0.0).r;

        if (masked == 1.0)
        {
            discard;
        }

        // Focus from alpha channel
        coord = lerp(uv, coord, getFocus(coord) * (1.0 - masked));

        col += ImageBuffer.SampleLevel(ImageBufferSampler, coord, 0.0).rgb;
    }

    return float4(col * 0.083, 1.0);
}