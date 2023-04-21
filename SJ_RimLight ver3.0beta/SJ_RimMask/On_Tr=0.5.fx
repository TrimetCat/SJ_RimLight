// 外侧边缘光强度 [0.0 - 1.0]
float Rim = 0.5;

// 内侧边缘光强度 [0.0 - 1.0]
float Block = 0.5;

// 边缘光宽度 [0.0 - 1.0]
float RimSize = 1.0;

// 透明阈值 [0.0 - 1.0]
float alphaThr = 0.65;

// 定义后使用轮廓线做黑遮罩（不显示边缘光）
#define Use_EdgeBlackMask

// 定义后使用Phong做遮罩（需要打开控制器右下角PhongMask_On，然后旋转Light_Pos）
#define Use_PhongMask

// 控制器名称
#define CONTROLLER "SJ_RimLight_Control.pmx"

float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldMatrix : WORLD;
float4x4 WorldViewMatrix : WORLDVIEW;
float4x4 ViewMatrix : VIEW;
float4x4 ProjMatrix : PROJECTION;

float4 Diffuse : DIFFUSE < string Object = "Geometry";
> ;
float4 EdgeColor : EDGECOLOR;

texture matTexture : MATERIALTEXTURE;
sampler matTextureSamp = sampler_state
{
	texture = <matTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
	ADDRESSU = WRAP;
	ADDRESSV = WRAP;
};

#ifdef Use_PhongMask
float3 Light_Pos : CONTROLOBJECT < string name = CONTROLLER;
string item = "Light_Pos";
> ;
float3 Light_Dir : CONTROLOBJECT < string name = CONTROLLER;
string item = "Light_Dir";
> ;
#endif

struct VS_OUTPUT
{
	float4 Pos : POSITION;
	float3 Normal : TEXCOORD0;
	float4 Dep : TEXCOORD1;
	float2 TexCoord : TEXCOORD2;
};

VS_OUTPUT Basic_VS(float4 Pos
				   : POSITION, float3 Normal
				   : NORMAL, float2 Tex
				   : TEXCOORD0)
{
	Pos = mul(Pos, WorldViewMatrix);
	Pos = mul(Pos, ProjMatrix);

	float3 normal = (normalize(Normal) + 1.0f) / 2.0f;

	float4 Dep = Pos;

	VS_OUTPUT Out = {Pos, normal, Dep, Tex};

	return Out;
}

float4 Basic_PS(VS_OUTPUT IN, float2 Tex
				: TEXCOORD0) : COLOR0
{
	float alpha = Diffuse.a;

	alpha = alpha * tex2D(matTextureSamp, IN.TexCoord).a;

	if (alpha > alphaThr)
	{
		alpha = 1;
	}
	else
	{
		alpha = 0;
	}
	clip(alpha - alphaThr);

#ifdef Use_PhongMask
	float3 LightDirection = normalize(Light_Dir - Light_Pos);
	float3 normal = IN.Normal * 2.0f - 1.0f;
	float LdotN = 1.0f - (dot(normal, LightDirection) + 1.0f) / 2.0f;
	float4 Color = float4(Rim, Block, LdotN, RimSize);
#else
	float4 Color = float4(Rim, Block, 1, alpha);
#endif

	return Color;
}

technique MainTexTec < string MMDPass = "object";
>
{
	pass DrawObject
	{
		AlphaTestEnable = FALSE;
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 Basic_VS();
		PixelShader = compile ps_2_0 Basic_PS();
	}
}

technique MainTexTec_ss < string MMDPass = "object_ss";
>
{
	pass DrawObject
	{
		AlphaTestEnable = FALSE;
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 Basic_VS();
		PixelShader = compile ps_2_0 Basic_PS();
	}
}

technique ShadowTec < string MMDPass = "shadow";
> {}

#ifndef Use_EdgeBlackMask
technique EdgeDepthTec < string MMDPass = "edge";
> {}
#else
float4 EdgeRender_VS(float4 Pos
					 : POSITION) : POSITION
{
	return mul(Pos, WorldViewProjMatrix);
}

float4 EdgeRender_PS() : COLOR
{
	return float4(0, 0, 0, EdgeColor.a);
}

technique EdgeDepthTec < string MMDPass = "edge";
>
{
	pass DrawEdge
	{
		AlphaTestEnable = FALSE;
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 EdgeRender_VS();
		PixelShader = compile ps_2_0 EdgeRender_PS();
	}
}
#endif