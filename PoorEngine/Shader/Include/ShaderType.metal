//
//  ShaderType.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/20.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderType.h"



void getDebugColor(Material mat, Params params, device float3& color){
    // Options.swift
    float3 c = 0;
    if(params.debugMode == 2){
        c = mat.baseColor;
    }
    else if(params.debugMode == 3){
        c = mat.metallic;
    }
    else if(params.debugMode == 4){
        c = mat.roughness;
    }
    else if(params.debugMode == 5){
        c = mat.ambientOcclusion;
    }
    else if(params.debugMode == 6){
        c = mat.shininess;
    }
    color = c;
}
