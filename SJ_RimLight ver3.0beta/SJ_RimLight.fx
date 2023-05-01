////////////////////////////////////////////////////////////////////////////////////////////////

#define CONTROLLER "SJ_RimLight_Control.pmx"
// 控制器名称

float4 ClearColor = {1, 1, 1, 1};
float ClearDepth = 1;

float X_Size : CONTROLOBJECT < string name = CONTROLLER;
string item = "X_Size";
> ;
float Y_Size : CONTROLOBJECT < string name = CONTROLLER;
string item = "Y_Size";
> ;

float X_Direction : CONTROLOBJECT < string name = CONTROLLER;
string item = "X_Direction";
> ;
float Y_Direction : CONTROLOBJECT < string name = CONTROLLER;
string item = "Y_Direction";
> ;
float X_Intensity : CONTROLOBJECT < string name = CONTROLLER;
string item = "X_Intensity";
> ;
float Y_Intensity : CONTROLOBJECT < string name = CONTROLLER;
string item = "Y_Intensity";
> ;
float3 RGB_Color : CONTROLOBJECT < string name = CONTROLLER;
string item = "RGB_Color";
> ;
float Edge_Intensity : CONTROLOBJECT < string name = CONTROLLER;
string item = "Edge_Intensity";
> ;
float Block_Intensity : CONTROLOBJECT < string name = CONTROLLER;
string item = "Block_Intensity";
> ;
float RimLight_Debug : CONTROLOBJECT < string name = CONTROLLER;
string item = "RimLight_Debug";
> ;
float PhongMask_On : CONTROLOBJECT < string name = CONTROLLER;
string item = "PhongMask_On";
> ;
float Block_Cut : CONTROLOBJECT < string name = CONTROLLER;
string item = "Block_Cut";
> ;
float Block_Power : CONTROLOBJECT < string name = CONTROLLER;
string item = "Block_Power";
> ;

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
               string ScriptOutput = "color";
string ScriptClass = "scene";
string ScriptOrder = "postprocess";
> = 0.8;

// 边缘光信息图
texture SJ_RimDepth : OFFSCREENRENDERTARGET <
                      string Description = "the Depth information and normal information for SJ_RimLight.x";
float2 ViewPortRatio = {1.0f, 1.0f};
float4 ClearColor = {0.5, 0.5, 1, 1};
float ClearDepth = 1.0f;
string Format = "A16B16G16R16F";
int MipLevels = 1;
bool AntiAlias = true;
string DefaultEffect =
    "self = hide;"
    "* = hide;";
> ;
sampler DepMapSmp = sampler_state
{
    texture = <SJ_RimDepth>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
// 遮罩
texture SJ_RimMask : OFFSCREENRENDERTARGET <
                     string Description = "the Mask information for SJ_RimLight.x";
float2 ViewPortRatio = {1.0f, 1.0f};
float4 ClearColor = {0, 0, 0, 1};
float ClearDepth = 1.0f;
string Format = "D3DFMT_A8R8G8B8";
int MipLevels = 1;
bool AntiAlias = true;
string DefaultEffect =
    "self = hide;"
    "* = hide;";
> ;
sampler MaskMapSmp = sampler_state
{
    texture = <SJ_RimMask>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// 当前画面的描画读取
texture ScnMap : RENDERCOLORTARGET <
                 bool AntiAlias = false;
float2 ViewportRatio = {1.0, 1.0};
int MipLevels = 1;
string Format = "A8R8G8B8";
> ;
sampler ScnSamp = sampler_state
{
    texture = <ScnMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
texture RimLightMap : RENDERCOLORTARGET;
sampler RimLightSamp = sampler_state
{
    texture = <RimLightMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// 深度缓存
texture DepthBuffer : RENDERDEPTHSTENCILTARGET <
                      float2 ViewPortRatio = {1.0, 1.0};
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

VS_OUTPUT VS_RimLightBuffer(float4 Pos
                            : POSITION, float2 Tex
                            : TEXCOORD0)
{
    VS_OUTPUT Out;
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

float4 PS_RimLightBuffer(float2 Tex
                         : TEXCOORD0) : COLOR
{
    float4 DepthColor = tex2D(DepMapSmp, Tex);
    float4 MaskColor = tex2D(MaskMapSmp, Tex);

    if (0.0 < RimLight_Debug && RimLight_Debug <= 0.1)
    {
        return float4(DepthColor.r, DepthColor.r, DepthColor.r, 1);
    }
    else if (0.1 < RimLight_Debug && RimLight_Debug <= 0.2)
    {
        return float4(DepthColor.g, DepthColor.g, DepthColor.g, 1);
    }
    else if (0.2 < RimLight_Debug && RimLight_Debug <= 0.3)
    {
        return float4(DepthColor.b, DepthColor.b, DepthColor.b, 1);
    }
    else if (0.3 < RimLight_Debug && RimLight_Debug <= 0.4)
    {
        return float4(DepthColor.a, DepthColor.a, DepthColor.a, 1);
    }
    else if (0.4 < RimLight_Debug && RimLight_Debug <= 0.5)
    {
        return float4(MaskColor.r, MaskColor.r, MaskColor.r, 1);
    }
    else if (0.5 < RimLight_Debug && RimLight_Debug <= 0.6)
    {
        return float4(MaskColor.g, MaskColor.g, MaskColor.g, 1);
    }
    else if (0.6 < RimLight_Debug && RimLight_Debug <= 0.7)
    {
        return float4(MaskColor.b, MaskColor.b, MaskColor.b, 1);
    }
    else if (1.0 < RimLight_Debug && RimLight_Debug <= 1.11)
    {
        return float4(MaskColor.a, MaskColor.a, MaskColor.a, 1);
    }

    float2 normal = normalize(float3(DepthColor.r * 2.0f - 1.0f, DepthColor.g * 2.0f - 1.0f, 0));
    X_Direction = saturate(X_Direction) * 2.0f;
    Y_Direction = saturate(Y_Direction) * 2.0f;
    X_Intensity = saturate(X_Intensity) * 2.0f;
    Y_Intensity = saturate(Y_Intensity) * 2.0f;
    if (normal.x < 0)
    {
        X_Intensity = -normal.x * (X_Intensity);
        normal.x = normal.x * (X_Direction);
    }
    else
    {
        X_Intensity = normal.x * (2 - X_Intensity);
        normal.x = normal.x * (2 - X_Direction);
    }
    if (normal.y < 0)
    {
        Y_Intensity = -normal.y * (Y_Intensity);
        normal.y = normal.y * (Y_Direction);
    }
    else
    {
        Y_Intensity = normal.y * (2 - Y_Intensity);
        normal.y = normal.y * (2 - Y_Direction);
    }

    float2 coord = Tex;
    coord.x = coord.x + normal.x * (0.005) / (pow(DepthColor.b * 2.0f, 0.75)) * X_Size * MaskColor.a;
    coord.y = coord.y - normal.y * (0.005) / (pow(DepthColor.b * 2.0f, 0.75)) * Y_Size * MaskColor.a;
    float4 OffsetColor_X = tex2D(DepMapSmp, float2(coord.x, Tex.y));
    float4 OffsetColor_Y = tex2D(DepMapSmp, float2(Tex.x, coord.y));

    RGB_Color = saturate((RGB_Color)*0.1);

    float3 RimLight_X = (OffsetColor_X.a - DepthColor.a);
    float3 RimLight_Y = (OffsetColor_Y.a - DepthColor.a);
    float3 BlockLight_X = saturate(pow(saturate(DepthColor.r - OffsetColor_X.r - Block_Cut) + saturate(OffsetColor_X.r - DepthColor.r - Block_Cut), 1.0f - Block_Power)) * (1 - RimLight_X);
    float3 BlockLight_Y = saturate(pow(saturate(DepthColor.g - OffsetColor_Y.g - Block_Cut) + saturate(OffsetColor_Y.g - DepthColor.g - Block_Cut), 1.0f - Block_Power)) * (1 - RimLight_Y);
    if (OffsetColor_X.b - DepthColor.b <= 0)
    {
        BlockLight_X = 0;
    }
    if (OffsetColor_Y.b - DepthColor.b <= 0)
    {
        BlockLight_Y = 0;
    }
    if (PhongMask_On > 0.5)
    {
        RimLight_X = RimLight_X * MaskColor.b;
        RimLight_Y = RimLight_Y * MaskColor.b;
        BlockLight_X = BlockLight_X * MaskColor.b;
        BlockLight_Y = BlockLight_Y * MaskColor.b;
    }
    if (0.7 < RimLight_Debug && RimLight_Debug <= 0.8)
    {
        return float4(RimLight_X + RimLight_Y, 1);
    }
    if (0.8 < RimLight_Debug && RimLight_Debug <= 0.9)
    {
        return float4(BlockLight_X + BlockLight_Y, 1);
    }
    RimLight_X = RimLight_X * MaskColor.r * (X_Intensity + Y_Intensity) * RGB_Color * Edge_Intensity;
    RimLight_Y = RimLight_Y * MaskColor.r * (X_Intensity + Y_Intensity) * RGB_Color * Edge_Intensity;
    BlockLight_X = BlockLight_X * MaskColor.g * (X_Intensity + Y_Intensity) * RGB_Color * Block_Intensity;
    BlockLight_Y = BlockLight_Y * MaskColor.g * (X_Intensity + Y_Intensity) * RGB_Color * Block_Intensity;
    if (0.9 < RimLight_Debug && RimLight_Debug <= 1.0)
    {
        return float4(RimLight_X + RimLight_Y + BlockLight_X + BlockLight_Y, 1);
    }

    float4 ScreenColor = tex2D(ScnSamp, Tex);
    ScreenColor.rgb = ScreenColor.rgb + RimLight_X.rgb + RimLight_Y.rgb + BlockLight_X.rgb + BlockLight_Y.rgb;
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
    "Pass=RimLightBuffer;";
>
{
    pass RimLightBuffer < string Script = "Draw=Buffer;";
    >
    {
        AlphaBlendEnable = FALSE;
        //AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_RimLightBuffer();
        PixelShader = compile ps_3_0 PS_RimLightBuffer();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
