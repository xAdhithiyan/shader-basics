Shader "Unlit/HeatlhBar"
{
    Properties
    {
        _MainTex("Main Text", 2D) = "white" {}
        _StartColor("Start Color", Color) = (1,1,1,1)
        _EndColor("End Color", Color) = (1,1,1,1)
        _CurrentHealthRange("Current Health", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _StartColor;
            float4 _EndColor;
            float _CurrentHealthRange;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float inverserLerp(float a, float b, float v) {
                return (v-a)/(b-a);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                
                //return tex2D(_MainTex, i.uv);
                float checkAboveRange = saturate(inverserLerp(0, _CurrentHealthRange, i.uv.x));
                _CurrentHealthRange = saturate(inverserLerp(0.2, 0.8, _CurrentHealthRange));
                float4 outputColor = lerp(_StartColor, _EndColor, _CurrentHealthRange); 
                if(_CurrentHealthRange == 0){
                    float t = cos(_Time.y * 10) * 0.5 + 0.5;
                    outputColor = lerp(outputColor, float4(0,0,0,0), t);
                 }
                outputColor *= checkAboveRange < 1;
                return outputColor;
            }
            ENDCG
        }
    }
}
