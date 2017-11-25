// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ScreenEffects/WaterColor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tex ("Lena Texture", 2D) = "white"{}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
			sampler2D _MainTex;
			sampler2D _Tex;

			float3 read(float2 coord,float lod_x,float lod_y){
				return tex2Dlod(_Tex, float4(coord,lod_x,lod_y)).rgb;
			}
			float rand(float2 co){
		    	return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
			}
			float3 waterColor(float2 coord){
				return float3(1,1,1);
			}
		ENDCG
		Pass
		{
			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert 
				#pragma fragment frag 
				#include "UnityCG.cginc"

				struct V2F{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};
				V2F vert(float4 vertex:POSITION,float2 coord:TEXCOORD0){
					V2F o;
						o.pos = UnityObjectToClipPos(vertex);
						o.uv = coord;
					return o;
				}
				fixed4 frag(V2F i):SV_Target{
					float2 uv = i.uv;
					float3 col = float3(0,0,0);
					const int iter = 20;
					for(int i = 0; i< iter; i++){
						float random = rand(uv.x*uv.y);
						float2 dir = 0.008*float2(sin(random),sin(random));
						uv += dir;
						uv = floor(uv*500.)/500.;
						float g = uv.x + uv.y;
						
						col += read(uv, 0., 4);
					}
					col /= iter;
					return fixed4(col.rgb,1.);
				}
			ENDCG
		}
	}
}
