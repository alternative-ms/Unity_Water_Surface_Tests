Shader "Custom/Level0_Simple_Lambert"
{
    Properties
    {
        _Color ("_Color", Color) = (0.5, 0.0, 0.5, 1.0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Back
        LOD 200

        CGPROGRAM
            #pragma surface surf Lambert keepalpha addshadow fullforwardshadows 
            #pragma target 3.0

            struct Input
            {
                half dummy;
            };

            fixed4 _Color;

            void surf( Input i , inout SurfaceOutput o )
            {
                o.Albedo = _Color.rgb;
                o.Alpha = _Color.a;
            }
        ENDCG
    }
    FallBack "Diffuse"
}