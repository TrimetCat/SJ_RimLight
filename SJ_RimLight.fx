////////////////////////////////////////////////////////////////////////////////////////////////

#define CONTROLLER "SJ_RimLight_Control.pmx"
//控制器名称

float4 ClearColor = {0, 0, 0, 1};
float ClearDepth = 1;

#define QUALITY 2

float MulRUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul R+";
> ;
float MulGUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul G+";
> ;
float MulBUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul B+";
> ;
float MulRDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul R-";
> ;
float MulGDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul G-";
> ;
float MulBDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Mul B-";
> ;
//强度乘算

float AddRUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add R+";
> ;
float AddGUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add G+";
> ;
float AddBUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add B+";
> ;
float AddRDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add R-";
> ;
float AddGDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add G-";
> ;
float AddBDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Add B-";
> ;
//强度加算

float RimLightDemo : CONTROLOBJECT < string name = CONTROLLER;
string item = "RimLight_Demo";
> ;
//边缘光测试

float IntensityUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Intensity+";
> ;
float IntensityDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Intensity-";
> ;
//整体强度

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
               string ScriptOutput = "color";
string ScriptClass = "scene";
string ScriptOrder = "postprocess";
> = 0.8;

//边缘光信息图
texture SJ_Depth : OFFSCREENRENDERTARGET <
                   string Description = "the Depth information and model Cutting for SJ_RimLight.x, please open the SJ_RimLight_Depth.x in this part and hide it in the Main part.";
float2 ViewPortRatio = {QUALITY, QUALITY};
float4 ClearColor = {0, 0, 0, 1};
float ClearDepth = 1.0f;
string Format = "D3DFMT_A8R8G8B8";
int MipLevels = 0;
bool AntiAlias = false;
string DefaultEffect =
    "self = hide;"
    "* = hide;";
> ;
sampler DepMapSmp = sampler_state
{
    texture = <SJ_Depth>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

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
                      float2 ViewPortRatio = {QUALITY, QUALITY};
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

float4 PS_DrawBuffer(float2 Tex
                     : TEXCOORD0) : COLOR
{
    float4 DepthColor = tex2D(DepMapSmp, Tex);

    if (RimLightDemo >= 0.5)
    {
        return DepthColor;
    }

    float4 ScreenColor = tex2D(ScnSamp, Tex);

    /*
    MulRUp *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    MulGUp *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    MulBUp *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    MulRDown *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    MulGDown *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    MulBDown *= ((1 + IntensityUp) * saturate(1 - IntensityDown));
    */
    if (RimLightDemo >= 0.25)
    {
        ScreenColor.r = ScreenColor.r * (0 - (saturate(MulRDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.r * (MulRUp) + (AddRUp - AddRDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));
        ScreenColor.g = ScreenColor.g * (0 - (saturate(MulGDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.g * (MulGUp) + (AddGUp - AddGDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));
        ScreenColor.b = ScreenColor.b * (0 - (saturate(MulBDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.b * (MulBUp) + (AddBUp - AddBDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));
    }

    ScreenColor.r = ScreenColor.r * (1 - (saturate(MulRDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.r * (MulRUp) + (AddRUp - AddRDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));
    ScreenColor.g = ScreenColor.g * (1 - (saturate(MulGDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.g * (MulGUp) + (AddGUp - AddGDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));
    ScreenColor.b = ScreenColor.b * (1 - (saturate(MulBDown) * DepthColor.b * ((1 + IntensityUp) * saturate(1 - IntensityDown)))) + (ScreenColor.b * (MulBUp) + (AddBUp - AddBDown)) * DepthColor.r * ((1 + IntensityUp) * saturate(1 - IntensityDown));

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
