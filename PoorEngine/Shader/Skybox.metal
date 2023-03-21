//
//  Skybox.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/26.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/CustomCore.h"

vertex SkyboxVertexOut vertex_skybox(const SkyboxVertexIn in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    SkyboxVertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.uvw = in.normal;
    return out;
}

fragment GBufferOut fragment_skybox(SkyboxVertexOut in [[stage_in]],
                                    constant Params &params [[buffer(ParamsBuffer)]],
                                    texturecube<float> skyboxTexture [[texture(SkyboxTexture)]] )
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

    float4 color = skyboxTexture.sample(linearSampler, in.uvw);
    
    GBufferOut out;
    out.MRT0 = float4(color.xyz, 1);
    out.MRT1 = float4(0, 1, 0, 0);
    out.MRT2 = float4(in.position.z, 0, 0, 0);
    out.MRT3 = float4(0, 0, 0, LIGHTING_MODE_SKYBOX);
    return out;
}

