cbuffer PixelShaderConstants : register( b0 )
{
    float4 g_vConst0     : packoffset( c0  );
    float4 g_vConst1     : packoffset( c1  );
    float4 g_vConst2     : packoffset( c2  );
    float4 g_vConst3     : packoffset( c3  );
    float4 g_vTexelSize0 : packoffset( c4  );
    float4 g_vTexelSize1 : packoffset( c5  );
    float4 g_vTexelSize2 : packoffset( c6  );
    float4 g_vTexelSize3 : packoffset( c7  );
    float4 g_vEyePos     : packoffset( c10 );
    row_major float4x4 g_mViewProj    : packoffset( c11 );
    row_major float4x4 g_mInvViewProj : packoffset( c15 );
};

// DX9 s0 ImageBuffer       -> t0/s0
// DX9 s1 MaskTexture       -> t1/s1
// DX9 s2 BackgroundTexture -> t2/s2
Texture2D<float4> g_BaseTexture : register( t0 );
Texture2D<float4> g_Texture1    : register( t1 );
Texture2D<float4> g_Texture2    : register( t2 );
Texture2D<float4> g_Texture3    : register( t3 );   // unused, kept for layout parity

SamplerState g_BaseTextureSampler : register( s0 );
SamplerState g_Texture1Sampler    : register( s1 );
SamplerState g_Texture2Sampler    : register( s2 );
SamplerState g_Texture3Sampler    : register( s3 ); // unused

//--------------------------------------------------------------------------------------
//   C0.x = max blur radius (px), C0.y = focus depth range
//   C1.xy = BUFFER_PIXEL_SIZE (1/w, 1/h)
//   C2.x = Bleed Weight, C2.y = Depth Threshold, C2.z = Falloff Curve, C2.w = Bleed Search Radius
//--------------------------------------------------------------------------------------
#define C0                g_vConst0
#define BUFFER_PIXEL_SIZE g_vConst1.xy      // or g_vTexelSize0.xy if the engine auto-fills it
#define C2                g_vConst2

// tex2Dlod( s, float4(uv,0,0) ) == SampleLevel( s, uv, 0 )
float4 SampleImage( float2 uv )
{
    return g_BaseTexture.SampleLevel( g_BaseTextureSampler, uv, 0.0 );
}
float SampleMask( float2 uv )
{
    return g_Texture1.SampleLevel( g_Texture1Sampler, uv, 0.0 ).r;
}
float3 SampleBackground( float2 uv )
{
    return g_Texture2.SampleLevel( g_Texture2Sampler, uv, 0.0 ).rgb;
}

struct PS_INPUT
{
    float4 vProjPos  : SV_Position;   // was VPOS (never read by the effect)
    float2 vTexCoord : TEXCOORD0;
};

// Poisson disk samples (pre-computed)
static const float2 poisson[12] =
{
    float2(-0.326, -0.406), float2(-0.840, -0.074), float2(-0.696,  0.457), float2(-0.203,  0.621),
    float2( 0.962, -0.195), float2( 0.473, -0.480), float2( 0.519,  0.767), float2( 0.185, -0.893),
    float2( 0.507,  0.064), float2( 0.896,  0.412), float2(-0.322, -0.933), float2(-0.792, -0.598)
};

float4 main( const PS_INPUT i ) : SV_Target0
{
    float2 uv = i.vTexCoord.xy;

    float  centerMask = SampleMask( uv );
    float4 centerSamp = SampleImage( uv );

    // early exit
    if ( centerMask >= 0.995 ) return float4( centerSamp.rgb, 1.0 );

    float2 off2x = float2( BUFFER_PIXEL_SIZE.x * 2.0, 0.0 );
    float2 off2y = float2( 0.0, BUFFER_PIXEL_SIZE.y * 2.0 );

    float trueDepth = min( centerSamp.a, min(
        min( SampleImage( uv + off2y ).a, SampleImage( uv - off2y ).a ),
        min( SampleImage( uv + off2x ).a, SampleImage( uv - off2x ).a ) ) );

    float t = saturate( trueDepth / max( C0.y, 1e-5 ) );
    float trueFocus = 1.0 - t * t;

    // early exit
    if ( trueFocus <= 0.001 ) return float4( centerSamp.rgb, 1.0 );

    float s, c;
    sincos( frac( sin( dot( uv, float2( 12.9898, 78.233 ) ) ) * 43758.5453 ), s, c );

    float2 bleedRad = BUFFER_PIXEL_SIZE * C2.w;
    float2 blurRad  = BUFFER_PIXEL_SIZE * ( C0.x * trueFocus );

    float2x2 bleedMat = float2x2( c * bleedRad.x, -s * bleedRad.x, s * bleedRad.y, c * bleedRad.y );
    float2x2 blurMat  = float2x2( c * blurRad.x,  -s * blurRad.x,  s * blurRad.y,  c * blurRad.y );

    float depthThresh = trueDepth + C2.y;

    float  bgHits      = 0.0;
    float3 col         = (float3)0.0;
    float  totalWeight = 0.0;

    [unroll]
    for ( int j = 0; j < 12; ++j )
    {
        float2 p = poisson[j];

        float2 bleedCoord = uv + mul( bleedMat, p );
        float  bleedDepth = SampleImage( bleedCoord ).a;
        float  bleedMask  = SampleMask( bleedCoord );
        bgHits += step( depthThresh, bleedDepth ) * step( bleedMask, 0.199 );

        float2 blurCoord    = uv + mul( blurMat, p );
        float  blurMask     = SampleMask( blurCoord );
        float  sampleWeight = step( blurMask, 0.199 );
        col         += SampleImage( blurCoord ).rgb * sampleWeight;
        totalWeight += sampleWeight;
    }

    col = ( totalWeight > 1e-4 ) ? ( col / totalWeight ) : centerSamp.rgb;

    float edgeFactor  = min( bgHits * 0.1666667, 1.0 );
    float bleedWeight = pow( saturate( edgeFactor * trueFocus * C2.x ), max( C2.z, 1e-4 ) );

    float3 bgColor = SampleBackground( uv );
    col = lerp( col, bgColor,        bleedWeight );
    col = lerp( col, centerSamp.rgb, centerMask  );

    return float4( col, 1.0 );
}