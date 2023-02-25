//
//  CustomCore.h
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

#ifndef CustomCore_h
#define CustomCore_h

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
    float3 color [[attribute(Color)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float3 color;
    float3 positionWS;
    float3 normalWS;
    float3 tangentWS;
    float3 bitangentWS;
    float4 shadowPosition;
    float4 custom;  //为特殊用途预留的结构
};

struct GBufferOut {
    // RGB: albedo, A: shadowAtten
    float4 MRT0 [[color(RenderTarget0)]];
    // RGB: normal
    float4 MRT1 [[color(RenderTarget1)]];
    // R: depth
    float4 MRT2 [[color(RenderTarget2)]];
};

struct LightingOut
{
    float4 Color [[color(0)]];
};

#endif /* CustomCore_h */
