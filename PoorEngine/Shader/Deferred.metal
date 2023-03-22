//
//  Deferred.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"




vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.normal = in.normal;
    out.uv = in.uv;
    out.color = in.color;
    out.positionWS = (uniforms.modelMatrix * in.position).xyz;
    out.normalWS = uniforms.normalMatrix * in.normal;
    out.tangentWS = uniforms.normalMatrix * in.tangent;
    out.bitangentWS = uniforms.normalMatrix * in.bitangent;
    out.shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * in.position;
    return out;
}


fragment GBufferOut fragment_gBuffer(VertexOut in [[stage_in]],
                                     constant Params &params [[buffer(ParamsBuffer)]],
                                     constant Material &material [[buffer(MaterialBuffer)]],
                                     texture2d<float> baseColorTexture [[texture(BaseColor)]],
                                     texture2d<float> normalTexture [[texture(NormalTexture)]],
                                     texture2d<float> roughnessTexture [[texture(RoughnessTexture)]],
                                     texture2d<float> metallicTexture [[texture(MetallicTexture)]],
                                     texture2d<float> aoTexture [[texture(AOTexture)]],
                                     texture2d<uint> idTexture [[texture(IdBuffer)]],
                                     depth2d<float> shadowTexture [[texture(ShadowTexture)]])
{
    Material _material = sampleTexture(material, baseColorTexture, roughnessTexture, metallicTexture, aoTexture, idTexture, in.uv, params);
    float3 normal = getNormal(normalTexture, in.uv, in.normalWS, in.tangentWS, in.bitangentWS, params);
    
    GBufferOut out;
    out.MRT0 = float4(_material.baseColor, getShadowAttenuation(in.shadowPosition, shadowTexture));
    out.MRT1 = float4(normalize(normal), 1.0);
    out.MRT2 = float4(in.position.z, _material.metallic, _material.roughness, _material.ambientOcclusion);
    out.MRT3 = float4(_material.shininess, LIGHTING_MODE_OPAQUE);
    return out;
}

constant float3 vertices[6] = {
    float3(-1,  1,  0),    // triangle 1
    float3( 1, -1,  0),
    float3(-1, -1,  0),
    float3(-1,  1,  0),    // triangle 2
    float3( 1,  1,  0),
    float3( 1, -1,  0)
};

vertex VertexOut vertex_quad(uint vertexID [[vertex_id]])
{
    float4 pos = float4(vertices[vertexID], 1);
    // MARK: 左下角UV为(0,0), 右上角UV为(1,1)
    VertexOut out {
        .position = pos,
        .uv = (pos.xy + float2(1, 1))/2
    };
    return out;
}


fragment LightingOut fragment_tiled_deferredLighting(VertexOut in [[stage_in]],
                                                     constant Params &params [[buffer(ParamsBuffer)]],
                                                     constant Light *lights [[buffer(LightBuffer)]],
                                                     texturecube<float> skyboxTexture [[texture(SkyboxTexture)]],
                                                     GBufferOut gBuffer)
{
    //device float3* debugColor = 0;
    
    float3 normal = gBuffer.MRT1.xyz;
    float4 pos = float4(2 * in.uv -1, 1, gBuffer.MRT2.x);
    float3 position = (params.inverseVPMatrix * pos).xyz;
    Material material = decodeGBuffer(gBuffer);
    Illumination indirect = getIndirect(position, normal, params, skyboxTexture);

    // debug
    if(params.debugMode > DISABLE_DEBUG && params.debugMode <= DEBUG_SHININESS ){
        float3 debugColor = getDebugColor(material, params, normal);
        return LightingOut{float4(debugColor, 1)};
    }
    
    float3 color = 0;
    float lightMode = gBuffer.MRT3.a;
    // direct lighting
    if(lightMode == LIGHTING_MODE_OPAQUE){
        color = directLighting(normal, position, params, lights, material);
    }
    else if(lightMode == LIGHTING_MODE_SKYBOX){
        color = material.baseColor;
    }
    else{
        color = material.baseColor;
    }
    
    // shadow
    color *= gBuffer.MRT0.a;
    
    return LightingOut{float4(color, 1)};
}
