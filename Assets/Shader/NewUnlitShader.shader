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

  SubShader    {
  Tags { "RenderType"="Opaque" }

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
    
     // tau makes sure that it starts and ends properly 
     float t = cos(i.uv.x * TAU * 2);
      return t;

      //  float4 outColor = lerp(_ColorA, _ColorB, t);
      //return outColor;
     }
    ENDCG
    }
  }
}
