Shader "Unlit/Textures"
{
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

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldCords : TEXCOORD1;
            };

            sampler2D _MainTex; // sampling texture
            float4 _MainTex_ST; // optional

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.worldCords = mul( UNITY_MATRIX_M, float4 ( v.vertex.xyz , 1)); // converting local coordinates to world coordinates
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 topDownView = i.worldCords.xz;
                //float4 col = tex2D(_MainTex, i.uv); // appling the texture color to the object based on corresponding uv coordinates

                // VERY IMPORTANT
                float4 col = tex2D(_MainTex, topDownView); // appling the texture color to the object based on corresponding world view x and z coordinates
                return col;
            }
            ENDCG
        }
    }
}
