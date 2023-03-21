//
//  Lighting.h
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float getAttenuation(Light light, float3 positionWS);

float3 BRDF(float3  L,
            float3  V,
            float3  N,
            float3  F0,
            Material material);


float3 directLighting(float3 normalWS,
                      float3 positionWS,
                      constant Params &params,
                      constant Light *lights,
                      Material material,
                      Illumination indirect,
                      device float3& debugColor);

float3 computeDiffuse(Material material,
                      float3 normalWS,
                      float3 lightDir);

// functions
float3 computeSpecular(float3 normal,
                       float3 viewDirection,
                       float3 lightDirection,
                       float roughness,
                       float3 F0);

float3 calculatePoint(Light light,
                      float3 position,
                      float3 normal,
                      Material material);

#endif /* Lighting_h */
