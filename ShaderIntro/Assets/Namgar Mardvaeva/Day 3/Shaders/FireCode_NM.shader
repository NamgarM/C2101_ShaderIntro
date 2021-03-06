﻿Shader "ShaderCourse/FireCode_NM"
{
    //UI of the Shader
    Properties
    {
        //
        _MaskTex("Mask", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _GradientTex("Gradient Noise", 2D) = "white" {}
        _ScrollSpeed("Scroll Speed", Float) = 1
        _Threshold("Threshold", Range(0,1)) = 0.5
        _Color("Color", Color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,0.2)) = 0.1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Transparent"}
            LOD 100
            ZWrite Off
            Blend One One // Blending 

            Pass
            {
                CGPROGRAM
                #pragma vertex VertexShader_
                #pragma fragment FragmentShader

                #include "UnityCG.cginc"

                struct VertexData
                {
                    float4 position : POSITION;
                    float3 normal   : NORMAL;
                    float2 uv       : TEXCOORD0;
                };

                struct VertexToFragment
                {
                    float4 position : SV_POSITION;
                    float normal : NORMAL;
                    float2 uv     : TEXCOORD0;
                };

                sampler2D _MaskTex;
                sampler2D _NoiseTex;
                sampler2D _GradientTex;
                float _ScrollSpeed;
                float _Threshold;
                float4 _Color;
                float _Smoothness;

                VertexToFragment VertexShader_(VertexData vertexData) /*object space*/
                {
                    /*//
                    float2 uv = vertexToFragment.uv;
                    float2 scrolledUv = vertexToFragment.uv;
                    // scrolling uv in y direction
                    scrolledUv.y += _Time.y * -1 * _ScrollSpeed; // confusing
                    
                    // Remapping
                    float4 maskCol = tex2D(_MaskTex, uv);
                    float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
                    float combined = maskCol.x * noiseCol.x;
                    float sharpenedResult = inverseLerp(combined, _Threshold - _Smoothness, _Smoothness + _Threshold);
                    sharpenedResult = saturate(sharpenedResult);
                    return sharpenedResult * _Color;*/

                    VertexToFragment output;
                    float3 worldNormal = mul(UNITY_MATRIX_M, vertexData.normal);
                    float4 worldPosition = mul(UNITY_MATRIX_M, vertexData.position);

                    float isFacingUp = dot(worldNormal, float3(0, 1, 0));
                    isFacingUp = clamp(isFacingUp, 0, 1);
                    float3 displacementDirection = worldNormal;

                    // Scrolling of tex
                    /*float scrollingSpeed = 1;
                    float2 scrollingLength = (0, 0);
                    scrollingLength.y = mul(scrollingSpeed, _Time.y);
                    _NoiseTex.uv = vertexData.uv += scrollingLength;*/
                    /*vertexData.uv += mul(1, _Time.y);
                    float4 noiseTex = tex2D(_NoiseTex, vertexData.uv);
                    output.uv = noiseTex.uv;*/

                    //
                    float4 displacementFactor = tex2Dlod(_NoiseTex, float4(vertexData.uv, 0, 0));
                    displacementDirection *= (displacementFactor * isFacingUp);

                    float4 displacedPosition = worldPosition;
                    displacedPosition.xyz += displacementDirection;
                    
                    output.position = mul(UNITY_MATRIX_VP, displacedPosition);
                    //output.uv = vertexData.uv;//totalUv;
                    return output;
                }

                // GPU IS DOING THINGS WITH THE DATA
                // Inverse lerp
                // v = 2
                // min = 1
                // max = 3
                // ret 0.5 

                float inverseLerp(float v, float min, float max) {
                    return (v - min) / (max - min);
                }

                float remap(float v, float min, float max, float outMin, float outMax) {
                    float t = inverseLerp(v, min, max);
                    return lerp(outMin, outMax, t);
                }

                float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
                {
                    // Displacement mapping
                    //float3 normal = normalize(vertexToFragment.normal);
                    // Multiply with gradient noise
                    //float multiplied = _GradientTex.x * normal.x;


                    //
                    float2 uv = vertexToFragment.uv;
                    float2 scrolledUv = vertexToFragment.uv;
                    // scrolling uv in y direction
                    scrolledUv.y += _Time.y * -1 * _ScrollSpeed; // confusing
                    
                    // Remapping
                    float4 maskCol = tex2D(_MaskTex, uv);
                    float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
                    float combined = maskCol.x * noiseCol.x;
                    float sharpenedResult = inverseLerp(combined, _Threshold - _Smoothness, _Smoothness + _Threshold);
                    sharpenedResult = saturate(sharpenedResult);
                    return sharpenedResult * _Color;
                    // Comparing
                    /*if (combined > _Threshold)
                    {
                        return _Color
                    }
                    else {
                        return float4(0, 0, 0, 0);
                    }
                    // Sample the tex
                    float4 maskCol = tex2D(_MaskTex, uv);
                    float4 noiuseCol = text2D(_NoiseTex, scrolledUv);
                    return maskCol * noiseCol;*/
                }
                ENDCG
            }
        }
}
