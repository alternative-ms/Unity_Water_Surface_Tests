Shader "Custom/Level3_VertexDisplacement_ColorRamp"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _DispTex ("_DispTex (Grayscale)", 2D) = "gray" {}
        _Displacement ("_Displacement", Range(0, 10)) = 1.0
        _TexelSizeStep ("_TexelSizeStep", Range(0.0001, 0.1)) = 0.01
        
        [Header(Coloring By Height)]
        _RampTex ("Ramp Texture (RGB)", 2D) = "white" {}
        _ColorRange ("_ColorRange", Range(0.1, 10)) = 1.0
        _ColorOffset ("_ColorOffset", Range(-5, 5)) = 0.0

        _Glossiness ("_Glossiness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:disp addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _DispTex;
        sampler2D _RampTex;
        float _Displacement;
        float _TexelSizeStep;
        
        fixed4 _LowColor;
        fixed4 _ZeroColor;
        fixed4 _HeightColor;
        float _ColorRange;
        float _ColorOffset;

        half _Glossiness;
        half _Metallic;

        struct Input
        {
            float2 uv_MainTex;
            float customHeight; 
        };

        float getHeight(float2 uv)
        {
            float2 clampedUV = clamp(uv, 0.0005, 0.9995); 
            float rawColor = tex2Dlod(_DispTex, float4(clampedUV, 0, 0)).r;

            float biDirectional = 0.0;
    
            if (rawColor >= 0.21406)
            {
                // upper range: from 0.21406 to 1.0 (total lenght 0.78594)
                biDirectional = (rawColor - 0.21406) / 0.78594; // convert to 0...+1
            }
            else
            {
                // lower range: from 0.0 to 0.21406 (total lenght 0.21406)
                biDirectional = -((0.21406 - rawColor) / 0.21406); // convert to -1...0
            }

            // normalize total displacement amplitude
            return biDirectional * 0.5 * _Displacement;
        }

        void disp(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float2 uv = v.texcoord.xy;

            float hCurrent = getHeight(uv);
            v.vertex.y += hCurrent;
            o.customHeight = v.vertex.y; 

            float hL = getHeight(uv - float2(_TexelSizeStep, 0));
            float hR = getHeight(uv + float2(_TexelSizeStep, 0));
            float hD = getHeight(uv - float2(0, _TexelSizeStep));
            float hU = getHeight(uv + float2(0, _TexelSizeStep));

            float3 normal = float3(hL - hR, _TexelSizeStep * 2.0, hD - hU);
            v.normal = normalize(normal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            float heightMask = (IN.customHeight - _ColorOffset) * _ColorRange;

            float rampUV = saturate(heightMask * 0.5 + 0.5);

            fixed4 finalColor = tex2D(_RampTex, float2(rampUV, 0.5));

            o.Albedo = c.rgb * finalColor.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}