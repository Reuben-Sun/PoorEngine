//
//  ShaderType.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderType.h"



float3 getDebugColor(Material mat, Params params, float3 normal){
    // Options.swift
    if(params.debugMode == DEBUG_NORMAL_WS){
        return normal;
    }
    else if(params.debugMode == DEBUG_ALBEDO){
        return mat.baseColor;
    }
    else if(params.debugMode == DEBUG_METALLIC){
        return mat.metallic;
    }
    else if(params.debugMode == DEBUG_ROUGHNESS){
        return mat.roughness;
    }
    else if(params.debugMode == DEBUG_AO){
        return mat.ambientOcclusion;
    }
    else if(params.debugMode == DEBUG_SHININESS){
        return mat.shininess;
    }
    return mat.baseColor;
}
