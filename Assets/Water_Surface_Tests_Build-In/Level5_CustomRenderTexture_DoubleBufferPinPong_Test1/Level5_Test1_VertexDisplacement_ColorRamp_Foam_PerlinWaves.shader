// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level5_Test1_VertexDisplacement_ColorRamp_Foam_PerlinWaves"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _Glossiness ("_Glossiness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", Range(0,1)) = 0.0

        [Header(Waves geometry)]
        _DispTex ("_DispTex (Grayscale)", 2D) = "gray" {}
        _Displacement ("_Displacement", Range(0, 10)) = 1.0
        _TexelSizeStep ("_TexelSizeStep", Range(0.0001, 0.1)) = 0.01
        
        [Header(Coloring By Wave height)]
        _RampTex ("Ramp Texture (RGB)", 2D) = "white" {}
        _ColorRange ("_ColorRange", Range(0.1, 10)) = 1.0
        _ColorOffset ("_ColorOffset", Range(-5, 5)) = 0.0

        [Header(Foam)]
        _FoamTex ("Foam Texture (RGB)", 2D) = "white" {}
        _FoamTextureScale ("Foam Scale", Float) = 5.0
        _FoamThreshold ("Foam Threshold", Range(-1, 1)) = 0.5
        _VelocityStrength ("Velocity Strength", Float) = 100.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
            #pragma surface surf Standard fullforwardshadows vertex:disp addshadow
            #pragma target 3.0

            sampler2D _MainTex;
            half _Glossiness;
            half _Metallic;

            sampler2D _DispTex;
            float _Displacement;
            float _TexelSizeStep;

            sampler2D _RampTex;        
            float _ColorRange;
            float _ColorOffset;

            sampler2D _FoamTex;
            float _FoamTextureScale;
            float _FoamThreshold;
            float _VelocityStrength;

            struct Input
            {
                float2 uv_MainTex;
                float customHeight;
                float waveSpeed;
            };

            float getHeight(float2 uv)
            {
                float rawColor = tex2Dlod(_DispTex, float4(uv, 0, 0)).r;
                return rawColor * _Displacement;
            }

            void disp(inout appdata_full v, out Input o)
            {
                UNITY_INITIALIZE_OUTPUT(Input, o);
                float2 uv = v.texcoord.xy;

                float4 rawData = tex2Dlod(_DispTex, float4(uv, 0, 0));
                float hCurrent = rawData.r * _Displacement;
    
                float hPrevious = rawData.g * _Displacement;
                float waveVelocity = abs(hCurrent - hPrevious);

                v.vertex.y += hCurrent;
    
                o.customHeight = hCurrent; 
                o.waveSpeed = waveVelocity; 

                float hL = getHeight(uv + float2(-_TexelSizeStep, 0));
                float hR = getHeight(uv + float2( _TexelSizeStep, 0));
                float hD = getHeight(uv + float2(0, -_TexelSizeStep));
                float hU = getHeight(uv + float2(0,  _TexelSizeStep));
                float3 correctedNormal = float3(hL - hR, 2.0 * _TexelSizeStep, hD - hU);
                v.normal = normalize(correctedNormal);
            }

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

                float heightMask = (IN.customHeight - _ColorOffset) * _ColorRange;
                float rampUV = saturate(heightMask * 0.5 + 0.5);
                fixed4 finalColor = tex2D(_RampTex, float2(rampUV, 0.5));

                float2 foamUV = IN.uv_MainTex * _FoamTextureScale + float2(_Time.x, _Time.x * 0.5);
                fixed4 foamColor = tex2D(_FoamTex, foamUV);

                float heightFoamMask = saturate((IN.customHeight - _FoamThreshold) * 5.0);
                float velocityMask = saturate(IN.waveSpeed * _VelocityStrength);
                float finalFoamMask = saturate(heightFoamMask + velocityMask);

                fixed3 waterWithFoam = lerp(finalColor.rgb, foamColor.rgb, finalFoamMask);
                o.Albedo = c.rgb * waterWithFoam;

                //o.Emission = foamColor.rgb * velocityMask * 1.5;

                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;
            }
        ENDCG
    }
    FallBack "Diffuse"
}