Shader "Unlit/BetterHealthBar" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health Value", Range(0,1)) = 1
        _StartColor("Start Color", Color) = (1,1,1,1)
        _EndColor("End Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue" = "Transparent"    
        }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // alpha blending(depends on the alpha channel)

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;       
            float3 _StartColor;
            float3 _EndColor;

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverLerp(float a, float b, float v) {
                return (v-a)/(b-a);
            }

            float4 frag (Interpolators i) : SV_Target {
                // rounded corner -> we are making a uniform coordinate system based on the scale of the object -> values are hardcoded for now
                float2 coords = float2(i.uv.x * 8, i.uv.y); 
                float2 pointOnLineSegment = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLineSegment) * 2 - 1;
                clip(-sdf);

                float borderSdf = sdf + 0.2;
                float borderMask = step(0, -borderSdf);                  
                // fwidth() -> a funciton to get the partial derivate(rate of change) in screen space -> for smoothening out the pixels

                float3 col = tex2D(_MainTex, float2(_Health, i.uv.y)); //takes one horizontal strip
                float healthPlayerMask = _Health > i.uv.x;  

                // clip(healthPlayerMask - 0.5); -> doesnt render anything that is below zero
                if(_Health < 0.2) {
                    float cosWave = cos(_Time.y * 4) * 0.4 + 1;
                    col *= cosWave;
                }
                
                return float4(col * borderMask, healthPlayerMask); // alpha blending is used here

            }
            ENDCG
        }
    }
}
