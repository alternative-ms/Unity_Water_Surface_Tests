// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level5_Test1_CustomRenderTexture_ColorPinPong"
{
    Properties
    {
        _WavePropagation("Wave Propagation (Spread)", Range(0.0, 0.49)) = 0.25
        _DampingSpeed("Damping Speed (Friction)", Range(0.9, 1.0)) = 0.98

        _BrushPaintTex("Brush (R/G) patch on Black background", 2D) = "black" {}
        _BrushForce("Brush Force", Range(0.1, 5.0)) = 1.0
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
                #pragma vertex CustomRenderTextureVertexShader
                #pragma fragment frag
                #include "UnityCustomRenderTexture.cginc"

                half _WavePropagation;
                half _DampingSpeed;

                sampler2D _BrushPaintTex;
                half _BrushForce;

                float4 _SelfTexture2D_TexelSize;

                float4 frag(v2f_customrendertexture i) : SV_Target
                {
                    float2 uv = i.globalTexcoord;
                    float2 duv = 1.0 / _CustomRenderTextureWidth; 

                    float2 currentData = tex2D(_SelfTexture2D, uv).rg;
                    float current  = currentData.r;
                    float previous = currentData.g;

                    float h_left  = tex2D(_SelfTexture2D, uv + float2(-duv.x, 0)).r;
                    float h_right = tex2D(_SelfTexture2D, uv + float2( duv.x, 0)).r;
                    float h_up    = tex2D(_SelfTexture2D, uv + float2(0,  duv.y)).r;
                    float h_down  = tex2D(_SelfTexture2D, uv + float2(0, -duv.y)).r;

                    float laplacian = h_left + h_right + h_up + h_down - 4.0 * current;

                    float nextPosition = (2.0 * current - previous + _WavePropagation * laplacian) * _DampingSpeed;
                    
                    float4 brush = tex2D(_BrushPaintTex, uv);
                    float brushForce = (brush.r - brush.g) * _BrushForce; 
    
                    nextPosition += brushForce;
                    nextPosition = clamp(nextPosition, -2.0, 2.0);

                    return float4(nextPosition, current, 0.0, 0.0);
                }
            ENDCG
        }
    }
}