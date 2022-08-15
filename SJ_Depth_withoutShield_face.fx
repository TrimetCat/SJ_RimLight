

//透明阈值
float alphaThr = 0.65;

//边缘光的粗细,
float Thickness = 1.2;

float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 WorldViewMatrix          : WORLDVIEW;
float4x4 ViewMatrix               : VIEW;
float4x4 ProjMatrix               : PROJECTION;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;


float3 CameraDrection			  : DIRECTION < string Object = "Camera"; >;
float4 Diffuse 			  		  : DIFFUSE < string Object = "Geometry"; >;

float2 ScreenSize 				  : VIEWPORTPIXELSIZE;


texture matTexture: MATERIALTEXTURE;

sampler matTextureSamp = sampler_state
{
    texture = <matTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

struct VS_OUTPUT
{
	float4 Pos : POSITION;
	float3 Normal : TEXCOORD0;
	float4 Dep : TEXCOORD1;
	float2 TexCoord : TEXCOORD2;
};


VS_OUTPUT Basic_VS( float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0) 
{
	//float4 Pos0 = Pos; 
	
	Pos = mul( Pos, WorldViewMatrix );
	float4 Dep = Pos;
	Pos = mul( Pos, ProjMatrix );
	
	float3 normal = normalize( mul( Normal, (float3x3)WorldViewMatrix ) );
	//float3 normal = normalize( mul( Normal, (float3x3)WorldViewMatrix ) );
	//float3 Eye = CameraPosition - mul( Pos0, WorldMatrix );
	
	float3 normal2 = ( normal + 1.0f ) / 2.0f;
	//Pos.x = Pos.x + normal.x / 3;
	//Pos.y = Pos.y - normal.y / 3;
	

	
	
	//Pos.x = Pos.x - normal.x * 0.05; Pos.y = Pos.y - normal.y * 0.05; //Pos.z = Pos.z - normal.z * 0.06;
	//float4 Dep2 = Pos;
	VS_OUTPUT Out = { Pos, normal2, Dep, Tex};
	
	return Out;
}


float4 Basic_PS(VS_OUTPUT IN, float2 Tex: TEXCOORD0, uniform bool useTex) : COLOR0
{
	
	//对应屏幕0-1的坐标
	//IN.Pos.x *= 1;
	
	//Tex.x *= 2;
	
	float depth = IN.Dep.z / 1000.0f / Thickness;
	
	float3 normal = IN.Normal.xyz ;
	
	//float4 Color = tex2D( DepSamp, Tex );
	
	float alpha = Diffuse.a;
    
    if(useTex)
	{
		alpha = alpha * tex2D(matTextureSamp, IN.TexCoord).a;
	}
    
    if(alpha > alphaThr)
	{
		alpha = 1;
	}
	else
	{
		alpha = 0;
	}
	
	//float4 Color = float4(0,0,0,a);
	
	//return Color;
    //return float4(depth , depth, depth, 1 );
	return float4(normal.x, depth, 0.9, alpha);
}


technique MainTec < string MMDPass = "object"; bool UseTexture = false;> {
    pass DrawObject {
		AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false);
    }
}

technique MainTec_ss < string MMDPass = "object_ss"; bool UseTexture = false;> {
    pass DrawObject {
		AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false);
    }
}

technique MainTexTec < string MMDPass = "object"; bool UseTexture = true;> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true);
    }
}

technique MainTexTec_ss < string MMDPass = "object_ss"; bool UseTexture = true;> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true);
    }
}

technique ShadowTec < string MMDPass = "shadow"; > { }

technique EdgeDepthTec < string MMDPass = "edge"; > { }