const float4x4 cViewProj        : register(c8);

struct VS_INPUT
{
    float4 vPos         : POSITION;
    float2 uv           : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 projPos      : POSITION;
    float2 uv           : TEXCOORD0;
};

VS_OUTPUT main( const VS_INPUT v )
{
    VS_OUTPUT o = ( VS_OUTPUT )0;
    float4 vProjPos = mul(  v.vPos, cViewProj );
    o.projPos = vProjPos;
    o.uv = v.uv;
    return o;
}
