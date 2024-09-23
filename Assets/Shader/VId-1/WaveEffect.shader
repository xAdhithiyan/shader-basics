Shader "Unlit/NewUnlitShader"
{
  Properties { // input data
    _ColorA("Color A", Color) = (1,1,1,1)
    _ColorB("Color B", Color) = (1,1,1,1)
    _ColorStart("Color Start", Range(0,1)) = 0
    _ColorEnd("Color End", Range(0,1)) = 1

    _Scale("UV Scale", Float) = 1
    _Offset("UV Offset", Float) = 0

  }

  SubShader {
    Tags { 
      "RenderType" = "Transparent"    
      "Queue" = "Transparent"  
    }

    Pass {
      
      Cull Off // (Off, Front, Back) renders everything/frontside/backside
      ZWrite Off // (Off, On) disable writing to z-buffer
      ZTest LEqual // (Always) disables reading from z-buffer (GEqual) -> renders only when something is present in front of it
      Blend One One // additive blending
      // Blend DstColor Zero // multiply blending

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


      Interpolators vert (MeshData v)
      {
        Interpolators o;
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
        // triangle wave
        // float t = abs(frac((i.uv.x) * 5) * 2 - 1);

        // TAU scales the output to the range (-1, 1) when the input is (0,1)
        // float t = cos((i.uv.x + i.uv.y) * TAU) * 0.5 + 0.5; // gives slanting lines

        float xOffset = cos(i.uv.x * TAU * 8) * 0.01;
        float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
        t *= 1 - i.uv.y; 

        float topButtonRemover = t * (abs(i.normal.y) < 0.999);
        float waves = t * topButtonRemover;


        float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

        return gradient * waves;


        // float4 outColor = lerp(_ColorA, _ColorB, t);
        // return outColor;
       }
      ENDCG
     }
  }
}
