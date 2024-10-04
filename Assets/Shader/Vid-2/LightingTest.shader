Shader "Unlit/SpecularLighting" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0,1)) = 1
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {

            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1; 
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex); // coverting object position to world position;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                // remapping Gloss
                float specularComponent = exp2(_Gloss * 11) + 2;

                // DIFFUSE (lambertian lighting)
                float3 N = normalize(i.normal); // we are normalizing normal becuase when interpolation between vertex the magnitude might go just below one on the face
                float3 L = _WorldSpaceLightPos0.xyz; // a vector pointing to the directional light
                float3 diffuseLight = max(0, dot(L, N));
                diffuseLight *= _LightColor0.xyz;
                // return float4(diffuseLight, 1);

                // SPECULAR (phong lighting)
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 R = reflect(-_WorldSpaceLightPos0.xyz, N); 

                float3 phongLighting = max(0, dot(viewDir, R));
                phongLighting = pow(phongLighting, specularComponent); // specular exponent -> to apply gloss effect
                phongLighting *= _LightColor0.xyz;
                // return float4(phongLighting, 1);

                // SPECULAR (blinn phong lighting)
                float3 H = normalize(viewDir + _WorldSpaceLightPos0.xyz); // half vector
                
                float3 binnPhongLighting = max(0, dot(H, N));
                binnPhongLighting = pow(binnPhongLighting, specularComponent);
                binnPhongLighting *= _LightColor0.xyz;
                //return float4(binnPhongLighting, 1);
                
                // Fernal Effect -> add this to the return float4
                // float fernal = 1 - dot(viewDir, N);
                // fernal = step(0.9, fernal);

                // Compositing
                return float4(diffuseLight * _Color + binnPhongLighting, 1); // the color is multiplied by Spectural Lighting only for metallic surfaces

            }
            ENDCG
        }
    }
}
