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

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(11)]])
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
    
    GBufferOut out;
    out.MRT0 = float4(_material.baseColor, getShadowAttenuation(in.shadowPosition, shadowTexture));
    out.MRT1 = float4(normalize(in.normalWS), 1.0);
    out.MRT2 = float4(in.position.z, 0.0, 0.0, 1.0);
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
    VertexOut out {
        .position = float4(vertices[vertexID], 1)
    };
    return out;
}


fragment float4 fragment_tiled_deferredSun(VertexOut in [[stage_in]],
                                           constant Params &params [[buffer(ParamsBuffer)]],
                                           constant Light *lights [[buffer(LightBuffer)]],
                                           GBufferOut gBuffer)
{
    float3 albedo = gBuffer.MRT0.xyz;
    float3 normal = gBuffer.MRT1.xyz;
    float4 pos = float4(in.uv.x, in.uv.y, 1, gBuffer.MRT2.x);
    float3 position = (params.inverseVPMatrix * pos).xyz;
    Material material {
        .baseColor = albedo,
        .specularColor = float3(0),
        .shininess = 500
    };
    float3 color = phongLighting(normal, position, params, lights, material);
    color *= gBuffer.MRT0.a;
    return float4(color, 1);
}
