// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/RainDropScreen"
{
	Properties
	{
		_MainTex ("Back Ground", 2D) = "white" {}
		_NoiseTex ("Noise Tex", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
			#define LOD 3.5
			#define _ShadeDir float2(-1.0,1.0)
			sampler2D _MainTex;
			sampler2D _NoiseTex;

			float shading(float2 dir){
				float s = dot(normalize(dir), normalize(_ShadeDir));
				return max(s,0.0);
			}
			float2 myRound(float2 xy){
				return floor(xy+0.5);
			}
			float4 layerEliemichel(float2 uv, float2 p, float4 curr, float time){
				float2 x = float2(30.0,30.0); // controls the size vs density
			    float2 xuv = x * p;
			    float4 n = tex2D(_NoiseTex, myRound(xuv - .3) / x);
			    
			    float2 offset = (tex2D(_NoiseTex, p * .1).rg - .5) * 2.; // expands to [-1, 1]
			    float2 z = xuv * 6.3 + offset; // 6.3 is a magic number
			    x = sin(z) - frac(time * (n.b + .1) + n.g) * .5;
			    
				if ((x.x + x.y - n.r * 3.) > .5)
			    {
			        float2 dir = cos(z);
			        curr = tex2Dlod(_MainTex, float4(uv + dir * .2, 0.0, 0.0));
			        curr += shading(dir) * curr;
			    }
    			return curr;
			}
			float3 n31(float p){
				float3 p3 = frac(float3(p.xxx)*float3(0.1031,0.11369,0.13787));
				p3 += dot(p3,p3.yzx + 19.19);
				return frac(float3((p3.x+p3.y)*p3.z,(p3.x+p3.z)*p3.z,(p3.y+p3.z)*p3.x));
			}
			float sawTooth(float t){
				return cos(t+cos(t)) + sin(2.*t)*0.2 + sin(4.0*t)*0.02;
			}
			float deltaSawTooth(float t){
				return 0.4*cos(2.*t)+0.08*cos(4.*t) - (1.-sin(t))*sin(t+cos(t));
			}
			float3 getDrops(float2 uv,float seed, float t){
				//float2 o = float2(0.,0.);
				uv.y += t * 0.05;
				uv *= float2(20.0, 2.5) * 2.0;
				float2 id = floor(uv);
				float3 n = n31(id.x + (id.y+seed) * 546.3524);
				float2 bd = frac(uv);
				float2 uv2 = bd;
				bd -= 0.5;
				bd.y *= 4.0;
				bd.x += (n.x-0.5)*0.6;
				t += n.z * 6.28;
				float slide = sawTooth(t);
				float ts = 1.5;
				float2 trailPos = float2(bd.x*ts,(frac(bd.y*ts*2.-t*2.)-0.5)*0.5);
				bd.y += slide*2.;
				float dropShape = bd.x * bd.x;
				dropShape *= deltaSawTooth(t);
				bd.y += dropShape;

				float d = length(bd);
				float trailMask = smoothstep(-0.2,0.2,bd.y);
				
				trailMask *= bd.y;								// fade dropsize
			    float td = length(trailPos*max(0.5, trailMask));	// distance to trail drops
			    
			    float mainDrop = smoothstep(0.2, 0.1, d);
			    float dropTrail = smoothstep(0.1, 0.02, td);
			    
			    dropTrail *= trailMask;
			    return float3(lerp(bd*mainDrop, trailPos, dropTrail), d);
			}
			float4 layerBigWIngs(float2 uv,float2 p,float4 curr,float time){
				float3 drop = getDrops(p,1.,time);
				if(length(drop.xy) > 0.0){
					float2 offset = -drop.xy * (1.0 - drop.z);
					curr = tex2D(_MainTex, uv + offset);
					curr += shading(offset) * curr * 0.5;
				}
				return curr;
			}
			#define time _Time.y
			float4 RainEffect(float2 uv){
				float4 col = tex2Dlod(_MainTex,float4(uv,LOD,LOD));
				col = layerBigWIngs(uv, uv, col, time * 0.5);
				const float2x2 m = float2x2(0.8,0.6,-0.6,0.8);
				float2 p = uv;
				col = layerEliemichel(uv, p, col, time * 0.25);
    			p = mul(m,p) * 2.02;
    			col = layerEliemichel(uv, p, col, time * 0.125);
    			p = mul(m,p) * 1.253;
    			return layerEliemichel(uv, p, col, time * 0.125);
			}
		ENDCG

		Pass{
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
				#define R _ScreenParams.xy
				fixed4 frag(V2F i):SV_Target{
					return RainEffect(i.uv);
				}
			ENDCG
		}
	}
}
