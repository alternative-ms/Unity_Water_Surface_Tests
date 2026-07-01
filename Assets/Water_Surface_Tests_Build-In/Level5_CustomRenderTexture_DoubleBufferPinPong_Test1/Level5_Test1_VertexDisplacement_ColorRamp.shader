// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level5_Test1_VertexDisplacement_ColorRamp"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _DispTex ("_DispTex (Grayscale)", 2D) = "gray" {}
        _Displacement ("_Displacement", Range(0, 10)) = 1.0
        _TexelSizeStep ("_TexelSizeStep", Range(0.0001, 0.1)) = 0.01
        
        [Header(Coloring By Wave height)]
        _RampTex ("Ramp Texture (RGB)", 2D) = "white" {}
        _ColorRange ("_ColorRange", Range(0.1, 10)) = 1.0
        _ColorOffset ("_ColorOffset", Range(-5, 5)) = 0.0

        _Glossiness ("_Glossiness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:disp addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _DispTex;
        sampler2D _RampTex;
        float _Displacement;
        float _TexelSizeStep;
        
        fixed4 _LowColor;
        fixed4 _ZeroColor;
        fixed4 _HeightColor;
        float _ColorRange;
        float _ColorOffset;

        half _Glossiness;
        half _Metallic;

        struct Input
        {
            float2 uv_MainTex;
            float customHeight; 
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

            float hCurrent = getHeight(uv);
            v.vertex.y += hCurrent;
            o.customHeight = hCurrent;

            float hL = getHeight(uv + float2(-_TexelSizeStep, 0));
            float hR = getHeight(uv + float2( _TexelSizeStep, 0));
            float hD = getHeight(uv + float2(0, -_TexelSizeStep));
            float hU = getHeight(uv + float2(0,  _TexelSizeStep));

            float3 tangent = float3(2.0 * _TexelSizeStep, hR - hL, 0.0);
            float3 bitangent = float3(0.0, hU - hD, 2.0 * _TexelSizeStep);

            float3 correctedNormal = float3(hL - hR, 2.0 * _TexelSizeStep, hD - hU);
            v.normal = normalize(correctedNormal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            float heightMask = (IN.customHeight - _ColorOffset) * _ColorRange;

            float rampUV = saturate(heightMask * 0.5 + 0.5);

            fixed4 finalColor = tex2D(_RampTex, float2(rampUV, 0.5));

            o.Albedo = c.rgb * finalColor.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}