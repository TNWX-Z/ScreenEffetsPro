Shader "TNWX/ScreenEffects/RianOnTheScreen"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
		_EnvironmentMap("环境纹理", Cube) = "grey"{}
		smoothv ("平滑值",float) = 0.1
		ballradius ("雨滴半径",float) = 0.0
		metaPow ("雨滴效果强度",float) = 1.0
		densityMin ("密度 最小值",float) = 4.0
		densityMax ("密度 最大值",float) = 7.0
		densityEvolution ("雨点扩散 速度",float) = 0.4
		rotationSpeed ("雨点运动 速度",float) = 0.005
		moveSpeed ("漂移方向", vector) = (0.1,0.0,0.0,0.0)
		distortion ("消散 值", float) = 0.05
		nstrenght ("雨滴 强度", float) = 1.0
		nsize ("雨滴融合 强度",float) = 1.0
		//lightColor ("灯光颜色", vector) = (7.0,8.0,10.0,0.0)
	}
	CGINCLUDE
		sampler2D _MainTex;
		uniform float smoothv = 0.1;
		uniform float ballradius = 0.0;
		uniform float metaPow = 1.0;
		uniform float densityMin = 4.0;
		uniform float densityMax= 7.0;
		uniform float densityEvolution = 0.4;
		uniform float rotationSpeed = 0.005;
		uniform float2 moveSpeed = float2(0.1,0.0);
		uniform float distortion = 0.05;
		uniform float nstrenght = 1.0;
		uniform float nsize = 1.0;
		//uniform float3 lightColor = float3(7.0,8.0,10.0);

		float2 rotuv(float2 uv, float angle, float2 center)
		{    
		    return mul(float2x2( cos(angle), -sin(angle), sin(angle), cos(angle)), (uv - center)) + center;
		}
		float hash(float n)
		{
		    return frac(sin(dot(n.xx ,float2(12.9898,78.233))) * 43758.5453);  
		}  
		float metaBall(float2 uv)
		{
		    return length(frac(uv) - 0.5);
		}
		float rand(float co){
		    return frac(sin(dot(co.xx ,float2(12.9898,78.233))) * 43758.5453);
		}
		float metaNoiseRaw(float2 uv, float density)
		{
		    float v =10.5, metaball0=3.;
		    for(int i = 0; i < 23; i++)
		    {
		        float inc = float(rand(float(i))) + 1.0;
		        float r1 = hash(15.3548*inc);
		        float s1 = -_Time.y*rotationSpeed*r1;
		        float2 f1 = moveSpeed*r1;
		        float2 c1 = float2(hash(11.2*inc)*20., hash(33.2*inc))*70.0*rand(float(i)) - s1;   
		        float2 uv1 = -rotuv(uv*(1.0+r1*v), r1*60.0 + s1, c1) ;    
		        float metaball1 = saturate(metaBall(uv1)*density);
		        metaball0 *= metaball1;
		    }
		    return pow(metaball0, metaPow);
		}
		float metaNoise(float2 uv)
		{ 
		    float density = lerp(densityMin,densityMax,sin(densityEvolution)*0.5+0.5);
		    return 1.0 - smoothstep(ballradius, ballradius+smoothv, metaNoiseRaw(uv, density));
		}
		float4 calculateNormals(float2 uv, float s)
		{
			float2 offsetXY = nsize * s / _ScreenParams.xy;
		    float2 ovX = float2(0.0, offsetXY.x);
		    float2 ovY = float2(0.0, offsetXY.y);
		    
		    float X = (metaNoise(uv - ovX.yx) - metaNoise(uv + ovX.yx)) * nstrenght;
		    float Y = (metaNoise(uv - ovY.xy) - metaNoise(uv + ovY.xy)) * nstrenght;
		    float Z = sqrt(1.0 - saturate(length(float2(X,Y))));
		    
		    float c = abs(X+Y);
		    return normalize(float4(X,Y,Z,c));
		}
		float3 GetNormal(float2 uv/*float2 fragCoord*/ )
		{
		    float2 sphereUvs = uv - 0.5;
		    float vign = length(sphereUvs);
		    float noise = metaNoise(uv);
		    float4 n = calculateNormals(uv, smoothstep(0.0, 0.8, 1.0));
		    return n.xyz+0.5;
		}		
	ENDCG
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend Off Lighting Off AlphaTest Off
		Pass{
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#include "UnityCG.cginc"
				samplerCUBE _EnvironmentMap;
				struct V2F{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					//float3 vDir : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
				};
				V2F vert(float4 vertex:POSITION,float2 coord:TEXCOORD0){
					V2F o;
						o.pos = UnityObjectToClipPos(vertex);
						o.uv = coord;
						float3 worldPos = mul(unity_ObjectToWorld,vertex).xyz;
						//o.vDir = normalize( _WorldSpaceCameraPos.xyz - worldPos);
						o.worldPos = worldPos;
					return o;
				}
				fixed4 frag(V2F i):SV_Target{
					//i.uv.y = 1.-i.uv.y;
					float3 viewDirection = GetNormal(i.uv);
					float3 rain = texCUBE(_EnvironmentMap,-reflect(viewDirection,-float3(i.uv,1.))).xyz;
					//return viewDirection.xyzx;
					//return fixed4(rain,1.);
					//return fixed4(GetNormal(i.uv).xy,1.,0);
					//return GetNormal(i.uv).xyzz;
					//return fixed4(viewDirection.xy-0.5,0.,0.);
					return tex2D(_MainTex,i.uv + viewDirection.xy - 0.5);
				}
			ENDCG
		}
	}
}
