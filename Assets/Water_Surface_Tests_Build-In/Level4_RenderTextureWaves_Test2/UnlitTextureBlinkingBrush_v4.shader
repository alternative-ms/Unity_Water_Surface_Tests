Shader "Custom/UnlitTextureBlinkingBrush_v4"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _BlinkRamp ("_BlinkRamp", 2D) = "white" {}
        _BlinkSpeed ("_BlinkSpeed", Float) = 10.0
        _Slowing ("_Slowing", Range(0.1, 8.0)) = 0.5

        _FadeRamp ("_FadeRamp", 2D) = "white" {}
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

            Texture2D _FadeRamp;
            SamplerState sampler_FadeRamp;

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
                float4 brushColor = _MainTex.Sample(sampler_MainTex, i.uv.xy);

                float age = i.uv.z;

                float rampFade = _FadeRamp.Sample(sampler_FadeRamp, float2(age, 0.5)).r;
                float progressiveBlingSpeed = (_BlinkSpeed * rampFade + _BlinkSpeed) * 0.5;

                float rampUV = age * progressiveBlingSpeed; // age * _BlinkSpeed;
                
                float3 rampColor = _BlinkRamp.Sample(sampler_BlinkRamp, float2(rampUV, 0.5)).rgb * i.color.rgb;

                float finalAlpha = brushColor.a * i.color.a * rampFade;

                return fixed4(brushColor.rgb * rampColor, finalAlpha);
            }
            ENDCG
        }
    }
}
