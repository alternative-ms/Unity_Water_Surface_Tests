// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level2_PearlescentChameleon_PerlinWaves_TwoColors_SelfShadows"
{
    Properties
    {
        _Color ("Bottom Color (Blue)", Color) = (0.0, 0.0, 1.0, 1.0)      
        _WavePeakColor ("Top Color (High - Neon)", Color) = (0.0, 1.0, 0.0, 1.0)    

        _RimColor ("Edge Color (Fresnel)", Color) = (1.0, 1.0, 1.0, 1.0)
        _FresnelPower ("Fresnel Power", Range(0.001, 8.0)) = 1.0
        _FresnelMultipler ("Fresnel Multipler", Range(0, 4)) = 1.0

        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.5
        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.2
        _Cube ("Custom Cubemap", Cube) = "_Skybox" {}
        _ReflectionIntensity ("Reflection Intensity", Range(0.0, 5.0)) = 1.0

        _NoiseScale ("Waves Scale (Size)", Range(0.1, 10.0)) = 3.0          
        _NoiseSpeed ("Waves Speed", Range(0.0, 5.0)) = 1.0
        _NoiseAmplitude ("Waves Height", Range(0.0, 5.0)) = 1.2
        
        _CustomTime ("Custom Synced Time (Manual/Script)", Float) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Cull Back
        LOD 200

        CGPROGRAM
            #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.5

            struct Input
            {
                float3 worldNormal;
                float3 worldPos;
                float colorLerpFactor; 
                INTERNAL_DATA
            };

            fixed4 _Color;
            fixed4 _WavePeakColor;
            fixed4 _RimColor;
            half _FresnelPower;
            half _FresnelMultipler;
            half _Metallic;
            half _Roughness;
            UNITY_DECLARE_TEXCUBE(_Cube);
            half _ReflectionIntensity;

            half _NoiseScale;
            half _NoiseSpeed;
            half _NoiseAmplitude;
            float _CustomTime;

            float2 rgrad(float2 p)
            {
                float x = sin(dot(p, float2(127.1, 311.7))) * 43758.5453123;
                return normalize(float2(frac(x), frac(x * 0.7)) * 2.0 - 1.0);
            }

            float perlinNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                float a = dot(rgrad(i + float2(0.0, 0.0)), f - float2(0.0, 0.0));
                float b = dot(rgrad(i + float2(1.0, 0.0)), f - float2(1.0, 0.0));
                float c = dot(rgrad(i + float2(0.0, 1.0)), f - float2(0.0, 1.0));
                float d = dot(rgrad(i + float2(1.0, 1.0)), f - float2(1.0, 1.0));

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float getPureNoise(float2 uv)
            {
                float2 p = uv * _NoiseScale;
                float time = _CustomTime * _NoiseSpeed;

                float h1 = perlinNoise(p + float2(time * 0.2, time * 0.1));
                float2 p2 = float2(p.x * 0.707 - p.y * 0.707, p.x * 0.707 + p.y * 0.707) * 2.0;
                float h2 = perlinNoise(p2 - float2(time * 0.15, time * 0.2)) * 0.5;

                return ((h1 + h2) * 0.5 + 0.5);
            }

            void vert(inout appdata_full v, out Input o)
            {
                UNITY_INITIALIZE_OUTPUT(Input, o);

                float2 uv = v.texcoord.xy;
            
                float n01 = getPureNoise(uv);
                float currentHeight = (n01 - 0.5) * _NoiseAmplitude;
                v.vertex.y += currentHeight;

                o.colorLerpFactor = n01;

                float eps = 0.01; 
                float heightRight = (getPureNoise(uv + float2(eps, 0.0)) - 0.5) * _NoiseAmplitude;
                float heightUp    = (getPureNoise(uv + float2(0.0, eps)) - 0.5) * _NoiseAmplitude;

                float worldEps = eps * 10.0;
                float3 tangent   = float3(worldEps, heightRight - currentHeight, 0.0);
                float3 bitangent = float3(0.0, heightUp - currentHeight, worldEps);
            
                v.normal = normalize(cross(bitangent, tangent));
            }

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                float rawNoiseValue = (IN.colorLerpFactor - 0.5) * 2.0;
                float adjustedNoise = rawNoiseValue * saturate(_NoiseAmplitude * 4.0);
                float t = saturate(adjustedNoise * 0.5 + 0.5);
            
                fixed4 baseColor = lerp(_Color, _WavePeakColor, t);

                float3 customViewDir = normalize(_WorldSpaceCameraPos - IN.worldPos);
                float3 worldNormalDir = WorldNormalVector(IN, o.Normal);

                half fresnel = saturate(1.0 - saturate(dot(customViewDir, worldNormalDir)));
                half colorFresnel = pow(fresnel, _FresnelPower) * _FresnelMultipler;

                float chameleonMask = colorFresnel * _RimColor.a;
                fixed4 finalColor = lerp(baseColor, _RimColor, chameleonMask);
            
                o.Albedo = finalColor.rgb;
            
                float3 reflectedDir = reflect(-customViewDir, worldNormalDir);

                half mipLevel = _Roughness * 8.0; 
                fixed4 reflection = UNITY_SAMPLE_TEXCUBE_LOD(_Cube, reflectedDir, mipLevel);

                half reflectionFresnel = lerp(0.2, 1.0, fresnel); 
                o.Emission = reflection.rgb * _ReflectionIntensity * reflectionFresnel; 

                o.Metallic = _Metallic;
                o.Smoothness = 1.0 - _Roughness; 
                o.Alpha = finalColor.a;
            }
            ENDCG
        }
    FallBack "Diffuse"
}