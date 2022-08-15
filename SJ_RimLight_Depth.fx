////////////////////////////////////////////////////////////////////////////////////////////////

#define CONTROLLER "SJ_RimLight_Control.pmx"
//控制器名称

float4 ClearColor = {0.5, 0, 0, 1};
float ClearDepth = 1;

float NormalOffsetThr : CONTROLOBJECT < string name = CONTROLLER;
string item = "CoverThr";
> ;
//遮挡光线屏蔽阈值

float Offset : CONTROLOBJECT < string name = CONTROLLER;
string item = "Offset";
> ;
//边缘光内缩

float SizeUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Size+";
> ;
float SizeDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Size-";
> ;
//整体粗细

float IntensityUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "Intensity+";
> ;
float IntensityDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "Intensity-";
> ;
//整体强度

float SheildLightUp : CONTROLOBJECT < string name = CONTROLLER;
string item = "SheildLight+";
> ;
float SheildLightDown : CONTROLOBJECT < string name = CONTROLLER;
string item = "SheildLight-";
> ;
//被遮挡光强度

float RimLightDemo : CONTROLOBJECT < string name = CONTROLLER;
string item = "RimLight_Demo";
> ;
//边缘光测试

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

// 这个是预定义的，不用改！
static float2 ViewportOffset = (float2(0.5, 0.5) / ViewportSize);

struct VS_OUTPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// 着色器部分

VS_OUTPUT VS_DrawBuffer(float4 Pos
                        : POSITION, float4 Tex
                        : TEXCOORD0)
{
    VS_OUTPUT Out;

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    // Out.Tex = Tex;
    // float4 dep = tex2D( DepMapSmp, Out.Tex );
    // float4 nml = tex2D( NmlMapSmp, Tex ) * 2.0f / 1.0f;

    // if(dep.g > 0.999)
    //{
    //	//Tex.x = Tex.x - nml.x * 0.05 ;
    //	//Out.Tex.x = Out.Tex.x - nml.x * 0.05 ;
    // }

    return Out;
}

float4 PS_DrawBuffer(float2 Tex
                     : TEXCOORD0) : COLOR
{
    float4 scnmap = tex2D(ScnSamp, Tex);
    float normal = (scnmap.r * 2.0f) - 1.0f;
    float2 coord = Tex;
    coord.x = coord.x + normal * ((0.00045) + (0.00050) * Offset) / sqrt(scnmap.g) * (1 + SizeUp * 2.0f) * saturate(1 - SizeDown);
    float2 coord2 = Tex;
    coord2.x = coord2.x + normal * (0.00050) * Offset / sqrt(scnmap.g);

    float4 Color = tex2D(ScnSamp, coord);
    float4 depmap = tex2D(ScnSamp, coord2);
    if (Color.r < 0.5)
    {
        // depmap.r = 0.5 - depmap.r;
        Color.r = 1 - Color.r;
    }
    // return float4(Color.r, Color.r, Color.r, 1.0);
    // return float4(depmap.r, depmap.r, depmap.r, 1.0);
    if (depmap.r < 0.5)
    {
        depmap.r = 1 - depmap.r;
        // Color.r =  1.5 - Color.r;
    }
    // Color = float4(Color.g, Color.g, Color.g, Color.a);
    // Color = float4(normal.g, normal.g, normal.g, normal.a);
    /*     if ((sqrt(Color.g) * 1000.0f - sqrt(normal.g) * 1000.0f) < -30)
        {
            Color.rgb = 1;
        }
        else
        {
            Color.rgb = 0;
        } */
    float WithoutShield = 0;
    if (Color.b > 0)
    {
        Color.b = Color.b * 3.0f;
        // WithoutShield = 1;
    }
    if (depmap.b < 0.93 && depmap.b > 0.88)
    {
        depmap.b = depmap.b * 1.5f;
        WithoutShield = 1;
    }
    Color.rgb = depmap.rgb - Color.rgb;

    if (WithoutShield == 1)
    {
        Color.r = 0.0f;
        Color.b = Color.b * 3.0f;
    }
    /*     if (depmap.b < 0.45)
        {
            Color.r = 0.0f;
            Color.b = Color.b * 2.5f + Color.b * 2.5f * (1 + SheildLightUp * 5.0f) * saturate(1 - SheildLightDown);
        } */
    Color.r = Color.r * (1 - saturate(Color.b)) * 1.0 * (1 + SheildLightUp * 5.0f) * saturate(1 - SheildLightDown);
    Color.r = saturate(Color.r - NormalOffsetThr);
    Color.g = -Color.g;

    if (RimLightDemo >= 0.75)
    {
        return Color;
    }

    float inten = saturate(Color.r) + Color.g + saturate(Color.b * 1.0);
    inten = inten * 0.5 * (1 + IntensityUp) * saturate(1 - IntensityDown);
    inten = inten * depmap.b;
    Color.rgb = float3(inten, inten, inten);
    // Color.rgb = float3(1-Color.g, 1-Color.g, 1-Color.g);
    return Color;
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
