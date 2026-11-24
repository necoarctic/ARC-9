cbuffer PixelShaderConstants : register(b0)
{
    //
    // C0.x = Vertical Grid Resolution
    // C0.y = Global opacity multiplier for overlay
    // C0.z = Aspect Ratio
    float4 C0 : packoffset(c0);
};

Texture2D<float4> sScene : register(t0);
Texture2D<float4> sOverlay : register(t1);

SamplerState sSceneSampler : register(s0);
SamplerState sOverlaySampler : register(s1);

struct PS_INPUT
{
    float4 Position : SV_Position;
    float2 UV       : TEXCOORD0;
};

float4 main(const PS_INPUT input) : SV_Target0
{
    // 1. Setup 2D Grid Resolution
    //
    // Multiply the vertical resolution by the aspect ratio to get horizontal resolution.
    // Example for 16:9:
    // float2(100.0 * 1.7777, 100.0) = float2(177.77, 100.0)
    float2 gridRes = float2(C0.x * C0.z, C0.x);

    // Prevent division by zero errors on both axes
    gridRes = max(gridRes, float2(1.0, 1.0));

    // 2. Calculate Pixelated UVs
    float2 blockUV = (floor(input.UV * gridRes) + 0.5) / gridRes;

    float4 sceneColor = sScene.Sample(sSceneSampler, blockUV);

    // 3. Calculate Local Macro-Pixel UVs
    // This tiles the overlay texture inside the blocks.
    float2 localUV = frac(input.UV * gridRes);

    float4 overlayColor = sOverlay.Sample(sOverlaySampler, localUV);

    // 4. Blend Scene and Overlay
    float overlayAlpha = overlayColor.a * C0.y;

    float4 finalColor;
    finalColor.rgb = lerp(sceneColor.rgb, overlayColor.rgb, overlayAlpha);
    finalColor.a   = sceneColor.a;

    return finalColor;
}