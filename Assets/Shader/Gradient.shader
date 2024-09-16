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

    float4 _ColorA;
    float4 _ColorB;
    float _ColorStart;
    float _ColorEnd;

    float _Scale;
    float _Offset;

    struct MeshData // per vertex mesh data
    {
      float4 vertex : POSITION; 
      float2 uv0 : TEXCOORD0; // uv cordinates have a min of (0,0) and a max of (1,1)
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
      // by defualt the normal is in local space. We can convert them to world space by 
      // o.normal = UnityObjectToWorldNormal( v.normal ); 
      // o.uv = ((v.uv0 + _Offset) * _Scale);


      o.uv = v.uv0;
      return o;
    }

    // if v = a then 0 is returned and v = b then 1 is returned
    float InverseLerp(float a, float b, float v) {
      return (v-a)/(b-a);
    }

    float4 frag (Interpolators i) : SV_Target
    {

      // here the normal is interpreted as color
      // return float4(i.normal, 1);
      // return float4(i.uv, 0,  1); 
       
      // gradient across x uv coordinate
      // saturate -> used for clamping between 0, 1;
      float t = saturate (InverseLerp(_ColorStart, _ColorEnd, i.uv.x));

      // frac = v - floor(v) -> frac(t) -> to check if it is clamped or not

      float4 outColor = lerp(_ColorA, _ColorB, t);
      return outColor;
     }
    ENDCG
    }
  }
}
