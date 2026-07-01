// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/CustomRenderTexture_NormalizedPreviewer"
{
    Properties
    {
        _MainTex ("Custom Render Texture (-1..1)", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 3.0

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    float4 rawData = tex2D(_MainTex, i.uv);
                    float rawValue = rawData.r; 
                    float normalizedColor = rawValue * 0.5 + 0.5;
                    float correctedColor = pow(max(0.0, normalizedColor), 2.2);
                    return float4(correctedColor, correctedColor, correctedColor, 1.0);
                }
            ENDCG
        }
    }
}