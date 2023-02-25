//
//  PostProcess.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/25.
//

#include <metal_stdlib>
using namespace metal;

#import "Include/Lighting.h"
#import "Include/CustomCore.h"
#import "Include/Sample.h"
#import "Include/ShaderType.h"

float3 linearToneMapping(float3 color)
{
    float exposure = 1.;
    color = clamp(exposure * color, 0., 1.);
    color = pow(color, float3(1. / GAMMA));
    return color;
}

float3 filmicToneMapping(float3 color)
{
    color = max(float3(0.0), color - float3(0.004));
    color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);
    return color;
}

float3 lumaBasedReinhardToneMapping(float3 color)
{
    float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
    float toneMappedLuma = luma / (1. + luma);
    color *= toneMappedLuma / luma;
    color = pow(color, float3(1. / GAMMA));
    return color;
}

float3 whitePreservingLumaBasedReinhardToneMapping(float3 color)
{
    float white = 2.;
    float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
    float toneMappedLuma = luma * (1. + luma / (white*white)) / (1. + luma);
    color *= toneMappedLuma / luma;
    color = pow(color, float3(1. / GAMMA));
    return color;
}

fragment float4 fragment_postprocess(VertexOut in [[stage_in]],
                                     constant Params &params [[buffer(ParamsBuffer)]],
                                     texture2d<float> preTexture [[texture(1)]])
{
    constexpr sampler sample(filter::linear, address::repeat);
    in.uv.y = -in.uv.y;
    float4 color = preTexture.sample(sample, in.uv);
    float3 HDRColor = color.xyz;
    if(params.tonemappingMode == TONEMAPPING_LINEAR){
        HDRColor = linearToneMapping(color.xyz);
    }
    if(params.tonemappingMode == TONEMAPPING_FILMIC){
        HDRColor = filmicToneMapping(color.xyz);
    }
    if(params.tonemappingMode == TONEMAPPING_LUMA){
        HDRColor = lumaBasedReinhardToneMapping(HDRColor);
    }
    if(params.tonemappingMode == TONEMAPPING_WHITE){
        HDRColor = whitePreservingLumaBasedReinhardToneMapping(HDRColor);
    }

    return float4(HDRColor, 1);
}

// MARK: 放弃实现MSAA，后续会改为TAA
kernel void msaa_main(imageblock<LightingOut> img_blk_colors,
                      uint pid [[thread_position_in_grid]])
{
    const ushort sampleCount = img_blk_colors.get_num_colors(pid);
    float4 resolved_color = float4(0.0);
    for(int i = 0; i < sampleCount; ++i){
        const float4 color = img_blk_colors.read(pid, i, imageblock_data_rate::color).Color;
        const ushort sampleColorCount = popcount(img_blk_colors.get_color_coverage_mask(pid, i));
        resolved_color += color * sampleColorCount;
    }
    resolved_color /= img_blk_colors.get_num_samples();
    
    const ushort output_sample_mask = 0xF;
    img_blk_colors.write(LightingOut{resolved_color}, pid, output_sample_mask);
}
