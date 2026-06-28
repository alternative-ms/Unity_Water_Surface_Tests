Shader "Mobile/Particles/Additive_Color" {
    Properties {
        _MainTex ("Particle Texture", 2D) = "white" {}
        _Color ("_Color (Alpha for Opacity)", Color) = (1,1,1,1)
    }

    SubShader {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend SrcAlpha One
        Cull Off 
        Lighting Off 
        ZWrite Off

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;

                struct appdata_t {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                };

                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = v.color;
                    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target {
                    fixed4 tex = tex2D(_MainTex, i.texcoord);
                    fixed4 col = tex * i.color * _Color;
            
                    col.rgb *= col.a; 
                    return col;
                }
            ENDCG
        }
    }
}
