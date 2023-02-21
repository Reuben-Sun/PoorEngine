//
//  ShaderType.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderType.h"



float3 getDebugColor(Material mat, Params params, float3 color){
    // Options.swift
    if(params.debugMode == 2){
        color = mat.baseColor;
    }
    else if(params.debugMode == 3){
        color = mat.metallic;
    }
    else if(params.debugMode == 4){
        color = mat.roughness;
    }
    else if(params.debugMode == 5){
        color = mat.ambientOcclusion;
    }
    else if(params.debugMode == 6){
        color = mat.shininess;
    }
    return color;
}
