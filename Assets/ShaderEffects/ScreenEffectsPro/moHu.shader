Shader "TNWX/Hash Blur"
{
	Properties
	{
		_Tex ("纹理", 2D) = "grey" {}
		_Kernel ("哈希模糊次数", range(1,64)) = 20.0
		_BlurRadius ("哈希模糊半径", range(-0.2,0.2)) = 0.0
		_minBlur ("Min Blur",range(0.0,1.0)) = 0.0
		_maxBlur ("Max Blur",range(0.0,1.0)) = 0.7
		_GlassColor ("Glass Color", color) = (0.2,0.4,0.3,0.0)
	}
	CGINCLUDE
		sampler2D _Tex;
		float _Kernel;
		half _BlurRadius;
		half _minBlur;
		half _maxBlur;
		fixed4 _GlassColor;

		#define _2PI 6.283185306

		float3 read(float2 uv) {
			return tex2Dlod(_Tex,float4(uv.x,uv.y,0.,0.)).rgb;
		}
		float rand(float2 co){
		    return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
		}
		float3 hashBlur(float2 uv)
		{
		    float3 blurred_image = float3(0.,0.,0.);
			float i = 0.0;
			while(i++ < _Kernel /*- (0.5-abs(uv.y-0.5))*20.*/){
				float2 q = float2(cos((i/_Kernel)*_2PI),sin((i/_Kernel)*_2PI)) * (rand(float2(i,uv.x+uv.y))+_BlurRadius); 
		        float2 uv2 = uv+(q*_BlurRadius);
		        blurred_image += read(uv2)/2;
					   q = float2(cos((i/_Kernel)*_2PI),sin((i/_Kernel)*_2PI)) * (rand(float2(i+2.,uv.x+uv.y+24.))+_BlurRadius); 
					   uv2 = uv+(q*_BlurRadius);
		        blurred_image += read(uv2)/2.;
			}
		    blurred_image /= _Kernel;
		    return blurred_image;
		}
	ENDCG
	SubShader
	{
		Pass{
			Cull Back ZWrite Off ZTest Off
			AlphaTest Off 
			Blend Off
			Lighting Off
			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert 
				#pragma fragment frag 
				#include "UnityCG.cginc"
				struct V2F{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};
				V2F vert(float4 vertex : POSITION,float2 coord : TEXCOORD0){
					V2F o;
						o.pos = UnityObjectToClipPos(vertex);
						o.uv = coord;
					return o;
				}
				fixed4 frag(V2F i):SV_Target{
					fixed3 blurCol = hashBlur(i.uv) * _GlassColor.rgb;
					fixed3 texCol = read(i.uv);
					float range = 0.5-abs(i.uv.y-0.5);
						  range = smoothstep(_minBlur,_minBlur+_maxBlur,range);
					blurCol = lerp(blurCol,texCol,range);
					return blurCol.rgbr;
				}
			ENDCG
		}
	}
}
