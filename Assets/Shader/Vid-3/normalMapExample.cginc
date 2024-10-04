#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
#define TAU 6.283185307179586

struct MeshData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT; // xyz = tangent direction, w = tangent sign
    float3 normal : NORMAL;
};

struct Interpolators
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 wPos : TEXCOORD4;
    LIGHTING_COORDS(5,6)
};

sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;
sampler2D _RockNormal;
sampler2D _RockHeight;
sampler2D _DiffuseIBL;
sampler2D _SpecularIBL;
float4 _Color;
float4 _AmbientLight;
float _Gloss;
float _NormalIntensity;
float _DispStrength;
float _SpecularIBLIntensity;

Interpolators vert(MeshData v)
{
    Interpolators o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    // for height map
    float height = tex2Dlod( _RockHeight, float4(o.uv, 0, 0)).x * 2 -1;
    v.vertex.xyz += v.normal * (height * _DispStrength);
    // v.vertex.xyz += v.normal *  cos(v.uv.x * 10 + _Time.y ) * 0.1; -> a wave
    o.vertex = UnityObjectToClipPos(v.vertex);

    // for normal map
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent = UnityObjectToWorldDir( v.tangent.xyz ); // tangent in world space ig
    o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
 
    o.wPos = mul(unity_ObjectToWorld, v.vertex); // converting object position to world position
    TRANSFER_VERTEX_TO_FRAGMENT(o) 
    return o;
}

float2 DirtoRectilinear(float3 dir) { // converts vectors into 2D texture coordinates that correspond to points on the surface of a sphere
    float x = atan2(dir.z, dir.x) / TAU + 0.5; // range 0-1f
    float y = dir.y  * 0.5 + 0.5; // range 0-1
    return float2(x, y);
}

float4 frag(Interpolators i) : SV_Target{
    float3 rockTex = tex2D(_RockAlbedo, i.uv);
    float3 surfaceColor = rockTex * _Color.xyz; // colorizing a texture

    float4 rockNormalTex = tex2D(_RockNormal, i.uv );
    float3 tangentSpaceNormal = UnpackNormal( rockNormalTex ) ; // unpacking the normal map -> range is from -1 to 1
    tangentSpaceNormal = lerp(float3(0,0,1), tangentSpaceNormal, _NormalIntensity); 
    float3x3 mtxTangentToWorld = { // used to convert a vector from tangent space to normal space
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,  
        i.tangent.z, i.bitangent.z, i.normal.z,  
    };
    
    float3 N = mul(mtxTangentToWorld, tangentSpaceNormal);
    
    // check is done at compile time
    #ifdef USE_LIGHTING 
        
    // remapping Gloss
    float specularComponent = exp2(_Gloss * 11) + 2;

    // DIFFUSE (lambertian lighting)
    // float3 N = normalize(i.normal); // we are normalizing normal because when interpolation between vertex the magnitude might go just below one on the face
    float3 L = normalize( UnityWorldSpaceLightDir(i.wPos) );
    float attenuation = LIGHT_ATTENUATION(i); // attenuation is the reduction of an effect/value
    float3 lambert = max(0, dot(L, N));
    float3 diffuseLight = lambert * attenuation * _LightColor0.xyz;
    // return float4(diffuseLight, 1);

    // ambient lighting (DIFFUSE)
    #ifdef IS_IN_BASE_PASS
        float3 diffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirtoRectilinear(N), 0, 0));
        // diffuseLight += _AmbientLight;
        diffuseLight += diffuseIBL;
    #endif
    
    // SPECULAR (phong lighting)
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 R = reflect(-L, N);

    float3 phongLighting = max(0, dot(viewDir, R));
    phongLighting = pow(phongLighting, specularComponent); // specular exponent -> to apply gloss effect
    phongLighting *= _LightColor0.xyz;
    // return float4(phongLighting, 1);

    // SPECULAR (blinn phong lighting)
    float3 H = normalize(viewDir + L); // half vector
                     
    float3 binnPhongLighting = max(0, dot(H, N));
    binnPhongLighting = pow(binnPhongLighting, specularComponent) * attenuation;
    binnPhongLighting *= _LightColor0.xyz;
    //return float4(binnPhongLighting, 1);
        
    // Fernal Effect -> add this to the return float4
    // float fernal = 1 - dot(viewDir, N);
    // fernal = step(0.9, fernal);

    // ambient lighting (SPECULAR)
    #ifdef IS_IN_BASE_PASS
        float3 fernal = pow(1 - saturate(dot(viewDir, N)), 5); // reflection at only the edges
    
        float3 viewRef = reflect(-viewDir, N);
        float mip = (1 - _Gloss) * 6;
        float3 specularIBL = tex2Dlod(_SpecularIBL, float4(DirtoRectilinear(viewRef), mip, mip));
        binnPhongLighting += specularIBL * _SpecularIBLIntensity * fernal;
    #endif

    // Compositing
    return float4(diffuseLight * surfaceColor + binnPhongLighting, 1); // the color is multiplied by specular Lighting only for metallic surfaces

    #else
        #ifdef IS_IN_BASE_PASS
                return float4(surfaceColor , 1);
        #else
                return 0;
        #endif
    #endif
}
