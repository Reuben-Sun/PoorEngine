//
//  Skybox.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/26.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/CustomCore.h"

struct SkyboxVertexIn {
    float4 position [[attribute(0)]];
};

vertex VertexOut vertex_skybox(const SkyboxVertexIn in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    VertexOut out;
    float4x4 vp = uniforms.projectionMatrix * uniforms.viewMatrix;
    out.position = (vp * in.position).xyww;
    return out;
}

fragment GBufferOut fragment_skybox(VertexOut in [[stage_in]],
                                    constant Params &params [[buffer(ParamsBuffer)]])
{
    GBufferOut out;
    out.MRT0 = float4(1, 1, 1, 1);
    out.MRT1 = float4(0,1,0,0);
    out.MRT2 = float4(in.position.z, 0, 0, 0);
    return out;
}

