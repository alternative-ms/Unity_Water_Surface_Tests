Shader "Custom/Level1_Pearlescent_Chameleon"
{
    Properties
    {
        _Color ("Base Color (Center)", Color) = (0.5, 0.0, 0.5, 1.0)
        _RimColor ("Chameleon Color (Fresnel)", Color) = (0.0, 1.0, 1.0, 1.0)
        _FresnelPower ("Fresnel Power", Range(0.001, 8.0)) = 1.0
        _FresnelMultipler ("Fresnel Multipler", Range(0, 4)) = 1.0
        _Cube ("Custom Cubemap", Cube) = "_Skybox" {}
        _ReflectionIntensity ("Reflection Intensity", Range(0.0, 2.0)) = 1.0
        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Back
        LOD 200

        CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma fragmentoption ARB_precision_hint_fastest
        
            #pragma target 3.5

            struct Input
            {
                float3 viewDir;
                float3 worldRefl;
            };

            fixed4 _Color;
            fixed4 _RimColor;
            half _FresnelPower;
            half _FresnelMultipler;

            UNITY_DECLARE_TEXCUBE(_Cube);
        
            half _ReflectionIntensity;
            half _Roughness;

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                half fresnel = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
                half colorFresnel = pow(fresnel, _FresnelPower) * _FresnelMultipler;
                fixed4 finalColor = lerp(_Color, _RimColor, colorFresnel);
                o.Albedo = finalColor.rgb;
                half mipLevel = _Roughness * 8.0; 
                fixed4 reflection = UNITY_SAMPLE_TEXCUBE_LOD(_Cube, IN.worldRefl, mipLevel);
                half reflectionFresnel = lerp(0.2, 1.0, fresnel); 
                o.Emission = reflection.rgb * _ReflectionIntensity * reflectionFresnel; 
                o.Metallic = 0.0;
                o.Smoothness = 1.0 - _Roughness; 
                o.Alpha = finalColor.a;
            }
        ENDCG
    }
    FallBack "Diffuse"
}