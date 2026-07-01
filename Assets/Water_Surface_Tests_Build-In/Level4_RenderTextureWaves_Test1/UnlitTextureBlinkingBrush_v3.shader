// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/UnlitTextureBlinkingBrush_v3"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _BlinkRamp ("_BlinkRamp", 2D) = "white" {}
        _BlinkSpeed ("_BlinkSpeed", Float) = 10.0
        _Slowing ("_Slowing", Range(0.1, 8.0)) = 0.5
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION; 
                float3 uv : TEXCOORD0; 
                float4 color : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;

            Texture2D _BlinkRamp;
            SamplerState sampler_BlinkRamp;

            float _BlinkSpeed;
            float _Slowing;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; 
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float brushAlpha = _MainTex.Sample(sampler_MainTex, i.uv.xy).a;
                float age = i.uv.z;
                float progressiveAge = pow(age, 1.0 / _Slowing);
                float rampUV = progressiveAge * _BlinkSpeed;
                float3 rampColor = _BlinkRamp.Sample(sampler_BlinkRamp, float2(rampUV, 0.5)).rgb;
                float finalAlpha = brushAlpha * i.color.a;
                return fixed4(rampColor, finalAlpha);
            }
            ENDCG
        }
    }
}
