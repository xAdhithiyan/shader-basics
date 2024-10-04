Shader "Unlit/SkyBoxShader"{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    } 
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #define TAU 6.283185307179586

            struct MeshData {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct Interpolators {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float2 DirtoRectilinear(float3 dir) { // converts vectors into 2D texture coordinates that correspond to points on the surface of a sphere
                float x = atan2(dir.z, dir.x) / TAU + 0.5; // range 0-1f
                float y = dir.y  * 0.5 + 0.5; // range 0-1
                return float2(x, y);
            }
            
            float4 frag (Interpolators i) : SV_Target {
                float4 col = tex2Dlod(_MainTex, float4(DirtoRectilinear(i.uv), 0, 0));
                return col;
            }
            ENDCG
        }
    }
}
