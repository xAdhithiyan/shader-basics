Shader "Unlit/NewUnlitShader"
{
  Properties { // input data
    _Color("Color", Color) = (1,1,1,1)
  }

  SubShader    {
  Tags { "RenderType"="Opaque" }

  Pass { 
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag

    #include "UnityCG.cginc"

    float4 _Color;

    struct MeshData // per vertex mesh data
    {
      // float4 represents a 4-component vector which holds 4 floating numbers
      float4 vertex : POSITION; // vertex position
      float2 uv : TEXCOORD0; // uv cordinates (used for mapping 2d texture on 3d object)
      float3 normals: Normal; 
      float4 color: COLOR;
      float4 tangent: TANGENT;
    };

    struct Interpolators
    {
        //float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION; // clip space position
        float3 normal : TEXCOORD0; // TEXTCOORD0 refers to a specific channel
    };


    Interpolators vert (MeshData v)
    {
        Interpolators o;
        o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
        return o;
    }

    // float (32 bit float)
    // half (16 bit float)
    // fixed (lower presicion) -1 to 1
    // a float4 and Vector is kinda the same thing

    float4 frag (Interpolators i) : SV_Target
    {
      //float4 myValue;f
      //float2 otherValue = myValue.xy; -> swizzling (extracting component from a vector)
      return _Color; // color
    }
    ENDCG
    }
  }
}
