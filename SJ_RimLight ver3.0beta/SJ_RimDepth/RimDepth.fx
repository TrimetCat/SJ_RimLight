// 透明阈值
float alphaThr = 0.3;

float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldMatrix : WORLD;
float4x4 WorldViewMatrix : WORLDVIEW;
float4x4 ViewMatrix : VIEW;
float4x4 ProjMatrix : PROJECTION;

float4 Diffuse : DIFFUSE < string Object = "Geometry";
> ;

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
	float4 Dep = Pos;
	Pos = mul(Pos, ProjMatrix);

	float3 normal = normalize(mul(Normal, (float3x3)WorldViewMatrix));

	float3 normal2 = (normal + 1.0f) / 2.0f;

	VS_OUTPUT Out = {Pos, normal2, Dep, Tex};

	return Out;
}

float4 Basic_PS(VS_OUTPUT IN, float2 Tex
				: TEXCOORD0) : COLOR0
{
	float depth = IN.Dep.z / 1000.0f;

	float3 normal = IN.Normal.xyz;

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

	return float4(normal.x, normal.y, depth, 0);
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

technique EdgeDepthTec < string MMDPass = "edge";
> {}