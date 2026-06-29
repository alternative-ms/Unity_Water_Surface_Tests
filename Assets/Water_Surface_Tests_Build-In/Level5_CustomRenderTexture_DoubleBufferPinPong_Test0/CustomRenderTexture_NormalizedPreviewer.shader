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

                fixed4 frag (v2f i) : SV_Target
                {
                    float4 crtData = tex2D(_MainTex, i.uv);
                
                    float rawValue = crtData.r; // color in [-1..1]

                    float normalizedColor = rawValue * 0.5 + 0.5; // now color [0..1]

                    return fixed4(normalizedColor, normalizedColor, normalizedColor, 1.0);
                }
            ENDCG
        }
    }
}