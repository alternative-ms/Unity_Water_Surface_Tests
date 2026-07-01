// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
Shader "Custom/Level5_Test1_CustomRenderTexture_SlowMo"
{
    Properties
    {
        _WavePropagation("Wave Propagation (Spread)", Range(0.0001, 0.01)) = 0.01 // 0.01 ok
        _DampingSpeed("Damping Speed (Friction)", Range(0.9, 1.0)) = 0.999999 // 0.999999 ok
        
        _LerpSpeed("_LerpSpeed", Range(0.0000001, 0.1)) = 0.01 // 0.01 ok
        _LerpSpeed2("_LerpSpeed2", Range(0.01, 1)) = 0.4 // 0.4 ok
        
        _BrushVelocityMinMax("_BrushVelocityMinMax", Range(0.005, 0.1)) = 0.015 // 0.015 ok
        
        _SpringReturn("_SpringReturn", Range(0.0000001, 0.001)) = 0.0001 // 0.0001 ok
        
        _BrushPaintTex("Brush (R-Up,G-down,B-Obstacle) patch on Black background", 2D) = "black" {}
        _BrushForce("Brush Force", Range(0.1, 5.0)) = 1.0
        
        _NoiseTex ("Base Noise (R)", 2D) = "gray" {}
        _NoiseScale ("Noise Scale", Float) = 0.5 // 0.5 ok
        _NoiseSpeed ("Noise Speed", Float) = 1 // 1 ok
        _NoiseStrength ("Noise Strength", Float) = 0.00001 // ok 
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "ALTERNATIVE_WAVE_SIMULATION_LEVEL5"

            CGPROGRAM
                #pragma vertex CustomRenderTextureVertexShader
                #pragma fragment frag
                
                #include "UnityCustomRenderTexture.cginc"
                
                half _WavePropagation;
                half _DampingSpeed;
                
                half _LerpSpeed;
                half _LerpSpeed2;
                
                half _BrushVelocityMinMax;
                
                half _SpringReturn;
                
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
                    float current  = currentData.r; 
                    float previous = currentData.g; 

                    float h_left  = tex2D(_SelfTexture2D, uv + float2(-duv.x, 0)).r;
                    float h_right = tex2D(_SelfTexture2D, uv + float2( duv.x, 0)).r;
                    float h_up    = tex2D(_SelfTexture2D, uv + float2(0,  duv.y)).r;
                    float h_down  = tex2D(_SelfTexture2D, uv + float2(0, -duv.y)).r;

                    if (tex2D(_BrushPaintTex, uv + float2(-duv.x, 0)).b > 0.01) h_left = current;
                    if (tex2D(_BrushPaintTex, uv + float2( duv.x, 0)).b > 0.01) h_right = current;
                    if (tex2D(_BrushPaintTex, uv + float2(0,  duv.y)).b > 0.01) h_up = current;
                    if (tex2D(_BrushPaintTex, uv + float2(0, -duv.y)).b > 0.01) h_down = current;

                    float laplacian = h_left + h_right + h_up + h_down - 4.0 * current;
                    float nextPosition = 2.0 * current - previous + _WavePropagation * laplacian;

                    nextPosition = (nextPosition - current * _SpringReturn) * _DampingSpeed;

                    float blurNeighbors = (h_left + h_right + h_up + h_down) * 0.25;
                    nextPosition = lerp(nextPosition, blurNeighbors, _LerpSpeed);

                    float2 noiseUV1 = uv * _NoiseScale + float2(_Time.x * _NoiseSpeed, _Time.x * _NoiseSpeed * 0.5);
                    float2 noiseUV2 = uv * (_NoiseScale * 1.5) - float2(_Time.x * _NoiseSpeed * 0.3, _Time.x * _NoiseSpeed);
                    float noise1 = tex2D(_NoiseTex, noiseUV1).r;
                    float noise2 = tex2D(_NoiseTex, noiseUV2).r;
                    float finalNoise = (noise1 + noise2) - 1.0; 
                    nextPosition += finalNoise * _NoiseStrength;

                    float4 brush = tex2D(_BrushPaintTex, uv);
                    float brushForce = (brush.r - brush.g) * _BrushForce;
    
                    if (brush.r > 0.01 || brush.g > 0.01) nextPosition = lerp(nextPosition, brushForce, _LerpSpeed2); 

                    float CLAMP_VELOCITY = nextPosition - current;
                    CLAMP_VELOCITY = clamp(CLAMP_VELOCITY, -_BrushVelocityMinMax, _BrushVelocityMinMax);
                    
                    nextPosition = current + CLAMP_VELOCITY;
                    nextPosition = clamp(nextPosition, -2.0, 2.0);
                    
                    if (brush.b > 0.01) { nextPosition = 0.0; current = 0.0; }

                    return float4(nextPosition, current, 0.0, 0.0);
                }
            ENDCG
        }
    }
}