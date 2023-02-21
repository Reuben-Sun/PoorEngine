//
//  ShaderType.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderType.h"



void getDebugColor(Material mat, Params params, device float3& debugColor, float3 color, float3 normal){
    // Options.swift
    float3 c = debugColor;
    if(params.debugMode == DEBUG_NORMAL_WS){
        c = normal;
    }
    else if(params.debugMode == DEBUG_ALBEDO){
        c = mat.baseColor;
    }
    else if(params.debugMode == DEBUG_METALLIC){
        c = mat.metallic;
    }
    else if(params.debugMode == DEBUG_ROUGHNESS){
        c = mat.roughness;
    }
    else if(params.debugMode == DEBUG_AO){
        c = mat.ambientOcclusion;
    }
    else if(params.debugMode == DEBUG_SHININESS){
        c = mat.shininess;
    }
    debugColor = c;
}
