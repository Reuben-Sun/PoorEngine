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
                                    constant Params &params [[buffer(ParamsBuffer)]])
{
    GBufferOut out;
    out.MRT0 = float4(0.73, 0.92, 1, 1);
    out.MRT1 = float4(0,1,0,0);
    out.MRT2 = float4(in.position.z, 0, 0, 0);
    return out;
}

