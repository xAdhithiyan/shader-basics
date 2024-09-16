Shader "Unlit/NewUnlitShader"
{
  Properties { // input data
    _ColorA("Color A", Color) = (1,1,1,1)
    _ColorB("Color B", Color) = (1,1,1,1)
    _ColorStart("Color Start", Range(0,1)) = 0
    _ColorEnd("Color End", Range(0,1)) = 1
   
    _Scale("UV Scale", Float) = 1
    _Offset("UV Offset", Float) = 0
    _WaveAmplitute("Wave Amplitute", Range(0,3)) = 0.1
  }

  SubShader {
    Tags { 
      "RenderType" = "Opaque"    
    }

    Pass {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

      #define TAU 6.283185307179586

      float4 _ColorA;
      float4 _ColorB;
      float _ColorStart;
      float _ColorEnd;

      float _Scale;
      float _Offset;
      float _WaveAmplitute;
      

      struct MeshData 
      {
        float4 vertex : POSITION;
        float2 uv0 : TEXCOORD0; 
        float3 normal: NORMAL; 
        float4 color: COLOR;
        float4 tangent: TANGENT;
      };

      struct Interpolators
      {
        float4 vertex : SV_POSITION; 
        float3 normal : TEXCOORD0 ; 
        float2 uv : TEXCOORD1;
      };


      // RIPPLING EFFECT
      float GetWave(float2 uv) {
        //changing the range from 0,1 to -1,1
        float2 uvCentered = uv * 2 - 1;

        // length just caluclates the magnitute (root of a^2 + b^2)
        float radialDistance = length(uvCentered);

        float wave = cos((radialDistance - _Time.y * 0.2) * TAU * 2) * 0.5 + 0.5;
        wave *= 1 - radialDistance; // 0 means black
        return wave;
       }

      Interpolators vert (MeshData v)
      {
        Interpolators o;
       
        // float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5);
        // float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5
        // v.vertex.y = wave * _WaveAmplitute;
       
        v.vertex.y = GetWave(v.uv0);

        o.vertex = UnityObjectToClipPos(v.vertex); 
        o.normal = UnityObjectToWorldNormal( v.normal );
        o.uv = v.uv0;
        return o;
      }

      // if v = a then 0 is returned and v = b then 1 is returned
      float InverseLerp(float a, float b, float v) {
        return (v-a)/(b-a);
      }

      float4 frag (Interpolators i) : SV_Target
      {
        return GetWave(i.uv);
       }
      ENDCG
     }
  }
}
