Shader "Unlit/MultipleLightSource"
{
    Properties {
        _RockAlbedo ("Rock Albedo", 2D) = "white" {}
        [NoScaleOffset] _RockNormal ("Rock Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _RockHeight ("Rock Height", 2D) = "grey" {}
        _DiffuseIBL ("Diffuse IBL", 2D) = "black" {}
        _SpecularIBL ("Specular IBL", 2D) = "black" {}
        
        _NormalIntensity ("Normal Intensity", Range(0, 1)) = 1
        _Gloss ("Gloss", Range(0,1)) = 1
        _Color ("Color", Color) = (0,0,0,0)
        _AmbientLight ("Ambient Light", Color) = (1,1,1,1)
        _DispStrength ("Displacement Strength", Range(0,1)) = 1
        _SpecularIBLIntensity ("Specular IBL Intensity", Range(0,1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
       
        // Base Pass
        Pass {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM 
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "normalMapExample.cginc"
            ENDCG
        }

        // Add Pass 
        Pass {
            Blend One One // additive blending src*1 + dist*1  
            Tags { "LightMode" = "ForwardAdd"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "normalMapExample.cginc"
            ENDCG
        }
    }
}
