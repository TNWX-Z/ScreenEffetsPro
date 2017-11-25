// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/BackGround"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass{
			CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert 
				#pragma fragment frag 
				#include "UnityCG.cginc"
				sampler2D _MainTex;
				#define time _Time.y
				#define R _ScreenParams.xy
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

				float2 myMod(float2 p,float coef){
					return p - floor(p/coef)*coef;
				}

				float map(float3 p){
					float a = p.z*0.1001;
					//p.xy = abs(p.xy);
					p.xy = mul(p.xy,float2x2(cos(a), sin(a), -sin(a), cos(a)));
					float t = length(myMod(p.xy, 2.0) - 1.0) - 0.07 - sin(p.z)*sin(time)/4.;
					t = min(t,length(myMod(p.yz, 2.0) - 1.0) - 0.07 - sin(p.x)*cos(time)/4.);
					t = min(t,length(myMod(p.zx, 2.0) - 1.0) - 0.07 - sin(p.y)*sin(time)/4.);
					return t;
				}
				#define DEPTH_STEP 64
				float4 BackGround(float2 U){
					float3 campos = float3(0.,0.,time);

					float2 uv = (U-0.5)*2.;
						   uv.x *= _ScreenParams.x/_ScreenParams.y;
					float3 dir = normalize(float3( uv, 2.));
					float j = 0.;
					float depth = 1.;
					float d = 0.;
					for(int i=0;i< 64;i++){
						d = map(campos + dir * depth);
						depth += d;
						j = float(i);
						if(d<0.015)
							break;
					}
					float3 surface = campos + dir * depth;
				    float3 col = pow(float3(1.,1.,1.)*(1.-j/float(64.)), float3(1, 3, 10));	
					if(depth < 18.){
						col.b += sin(surface.z);
					}				    
					return float4(col,0.);				
				}
				fixed4 frag(V2F i):SV_Target{
					//i.uv.y = 1. - i.uv.y;
					return BackGround(i.uv);
				}
			ENDCG
		}
		
	}
}
