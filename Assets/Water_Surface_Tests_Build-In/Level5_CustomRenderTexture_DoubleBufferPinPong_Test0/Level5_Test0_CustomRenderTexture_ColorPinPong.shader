Shader "Custom/Level5_Test0_CustomRenderTexture_ColorPinPong"
{
    Properties
    {
        _OscillationSpeed("Oscillation Speed", Range(0.1, 50.0)) = 15.0
        _DampingSpeed("Damping Speed (Friction)", Range(0.0, 5.0)) = 1.0
        _MicroNoiseFilter("_MicroNoiseFilter", Range(0.0, 0.002)) = 0.001
    }

    CGINCLUDE
        #include "UnityCustomRenderTexture.cginc"

        half _OscillationSpeed;
        half _DampingSpeed;
        half _MicroNoiseFilter;

        float4 frag(v2f_customrendertexture i) : SV_Target
        {
            float2 uv = i.globalTexcoord;
            
            float4 current = tex2D(_SelfTexture2D, uv);
            
            float position = current.r; 
            float velocity = current.g; 

            float deltaTime = clamp(unity_DeltaTime.x, 0.0, 0.03);

            //float acceleration = -position * _OscillationSpeed; // old, all pixels moving same time, wrong
            float acceleration = -sign(position) * sqrt(abs(position)) * _OscillationSpeed; // new, not linear moving time

            velocity += acceleration * deltaTime;

            velocity *= exp(-_DampingSpeed * deltaTime);

            position += velocity * deltaTime;

            if (abs(position) < _MicroNoiseFilter && abs(velocity) < _MicroNoiseFilter)
            {
                position = 0.0;
                velocity = 0.0;
            }

            return float4(position, velocity, 0, 0);
        }
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "Update"
            CGPROGRAM
                #pragma vertex CustomRenderTextureVertexShader
                #pragma fragment frag
            ENDCG
        }
    }
}