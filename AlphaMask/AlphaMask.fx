////////////////////////////////////////////////////////////////////////////////////////////////


float4 ClearColor = {0, 0, 0, 1};
float ClearDepth = 1;

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
               string ScriptOutput = "color";
string ScriptClass = "scene";
string ScriptOrder = "postprocess";
> = 0.8;


// 当前画面的描画读取
texture ScnMap : RENDERCOLORTARGET <
                 float2 ViewPortRatio = {1.0f, 1.0f};
> ;
sampler ScnSamp = sampler_state
{
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
};

// 深度缓存
texture DepthBuffer : RENDERDEPTHSTENCILTARGET <
                      float2 ViewPortRatio = {1.0f, 1.0f};
> ;

// 视角空间的尺寸
float2 ViewportSize : VIEWPORTPIXELSIZE;

// 视角空间偏移
static float2 ViewportOffset = (float2(0.5, 0.5) / ViewportSize);

struct VS_OUTPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// 着色器部分

VS_OUTPUT VS_DrawBuffer(float4 Pos
                        : POSITION, float2 Tex
                        : TEXCOORD0)
{
    VS_OUTPUT Out;

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}


float3 TonemapNaughtyDog(float3 x)
{
	float A = -2586.3655;
	float B = 0.6900;
	float C = -767.6706;
	float D = -8.5706;
	float E = 2.8784;
	float F = 107.4683;
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

float3 ReTonemapNaughtyDog(float3 y)
{
	float A = -2586.3655;
	float B = 0.6900;
	float C = -767.6706;
	float D = -8.5706;
	float E = 2.8784;
	float F = 107.4683;
	return (sqrt((B*B*F*F-4*A*D*F*F*F)*y*y+(4*A*D*F*F*F+((-4*A*D*E)-2*B*B*C)*F*F+2*B*B*E*F)*y+B*B*C*C*F*F-2*B*B*C*E*F+B*B*E*E)-B*F*y+B*C*F-B*E)/(2*A*F*y-2*A*F+2*A*E);
}

float3 srgb2linear(float3 rgb)
{
	rgb = max(6.10352e-5, rgb);
	return rgb < 0.04045f ? rgb * (1.0 / 12.92) : pow(rgb * (1.0 / 1.055) + 0.0521327, 2.4);
}

float3 linear2srgb(float3 srgb)
{
	srgb = max(6.10352e-5, srgb);
	return min(srgb * 12.92, pow(max(srgb, 0.00313067), 1.0/2.4) * 1.055 - 0.055);
}


float4 PS_DrawBuffer(float2 Tex
                     : TEXCOORD0) : COLOR
{


    float4 ScreenColor = tex2D(ScnSamp, Tex);
    //ScreenColor.rgb = srgb2linear(ScreenColor.rgb);
   // ScreenColor.rgb = saturate(TonemapNaughtyDog(ScreenColor.rgb));
    //ScreenColor.rgb = saturate(ReTonemapNaughtyDog(ScreenColor.rgb));
    //ScreenColor.rgb = srgb2linear(ScreenColor.rgb);
   // ScreenColor.rgb = linear2srgb(ScreenColor.rgb);
    ScreenColor.a = 1.0f;
    //ScreenColor.rgb = ScreenColor.rgb * 0.8;
    return ScreenColor;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique PostEffect <
    string Script =
    "RenderColorTarget0=ScnMap;"
    "RenderDepthStencilTarget=DepthBuffer;"
    "ClearSetColor=ClearColor;"
    "ClearSetDepth=ClearDepth;"
    "Clear=Color;"
    "Clear=Depth;"
    "ScriptExternal=Color;"
    "RenderColorTarget0=;"
    "RenderDepthStencilTarget=;"
    "Pass=DrawBuffer;";
>
{
    pass DrawBuffer < string Script = "Draw=Buffer;";
    >
    {
        AlphaBlendEnable = FALSE;
        // AlphaBlendEnable = true;
        // SRCBLEND = SRCALPHA;
        // DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_DrawBuffer();
        PixelShader = compile ps_2_0 PS_DrawBuffer();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
