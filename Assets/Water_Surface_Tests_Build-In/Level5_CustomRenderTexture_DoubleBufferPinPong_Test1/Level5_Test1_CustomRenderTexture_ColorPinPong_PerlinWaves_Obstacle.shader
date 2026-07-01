// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level5_Test1_CustomRenderTexture_ColorPinPong_PerlinWaves_Obstacle"
{
    Properties
    {
        _WavePropagation("Wave Propagation (Spread)", Range(0.0, 0.49)) = 0.25
        _DampingSpeed("Damping Speed (Friction)", Range(0.9, 1.0)) = 0.98

        _BrushPaintTex("Brush (R-Up,G-down,B-Obstacle) patch on Black background", 2D) = "black" {}
        _BrushForce("Brush Force", Range(0.1, 5.0)) = 1.0

        _NoiseTex ("Base Noise (R)", 2D) = "gray" {}
        _NoiseScale ("Noise Scale", Float) = 2.0
        _NoiseSpeed ("Noise Speed", Float) = 0.5
        _NoiseStrength ("Noise Strength", Float) = 0.01
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

                sampler2D _NoiseTex;
                float _NoiseScale;
                float _NoiseSpeed;
                float _NoiseStrength;

                float4 _SelfTexture2D_TexelSize;

                float4 frag(v2f_customrendertexture i) : SV_Target
                {
                    float2 uv = i.globalTexcoord;
                    float2 duv = 1.0 / _CustomRenderTextureWidth; 

                    float2 currentData = tex2D(_SelfTexture2D, uv).rg;
                    float current = currentData.r; 
                    float previous = currentData.g; 

                    float h_left  = tex2D(_SelfTexture2D, uv + float2(-duv.x, 0)).r;
                    float h_right = tex2D(_SelfTexture2D, uv + float2( duv.x, 0)).r;
                    float h_up = tex2D(_SelfTexture2D, uv + float2(0,  duv.y)).r;
                    float h_down = tex2D(_SelfTexture2D, uv + float2(0, -duv.y)).r;

                    if (tex2D(_BrushPaintTex, uv + float2(-duv.x, 0)).b > 0.01) h_left = current;
                    if (tex2D(_BrushPaintTex, uv + float2( duv.x, 0)).b > 0.01) h_right = current;
                    if (tex2D(_BrushPaintTex, uv + float2(0,  duv.y)).b > 0.01) h_up = current;
                    if (tex2D(_BrushPaintTex, uv + float2(0, -duv.y)).b > 0.01) h_down = current;

                    float laplacian = h_left + h_right + h_up + h_down - 4.0 * current;
                    float nextPosition = (2.0 * current - previous + _WavePropagation * laplacian);
    
                    float springReturn = current * 0.005; // old 0.02
                    nextPosition = (nextPosition - springReturn) * _DampingSpeed;

                    float2 noiseUV1 = uv * _NoiseScale + float2(_Time.x * _NoiseSpeed, _Time.x * _NoiseSpeed * 0.5);
                    float2 noiseUV2 = uv * (_NoiseScale * 1.5) - float2(_Time.x * _NoiseSpeed * 0.3, _Time.x * _NoiseSpeed);
    
                    float noise1 = tex2D(_NoiseTex, noiseUV1).r;
                    float noise2 = tex2D(_NoiseTex, noiseUV2).r;

                    float finalNoise = (noise1 + noise2) - 1.0; 
    
                    nextPosition += finalNoise * _NoiseStrength;

                    float4 brush = tex2D(_BrushPaintTex, uv);
                    float brushForce = (brush.r - brush.g) * _BrushForce;
                    if (brush.r > 0.01 || brush.g > 0.01) nextPosition = lerp(nextPosition, brushForce, 0.3); 
    
                    nextPosition = clamp(nextPosition, -1.0, 1.0);
                    
                    if (brush.b > 0.01)
                    {
                        nextPosition = 0.0;
                        current = 0.0;
                    }

                    return float4(nextPosition, current, 0.0, 0.0);
                }
            ENDCG
        }
    }
}