//
//  Lighting.metal
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"
#import "CustomCore.h"
#import "ShaderType.h"

//着色函数库
constant float pi = 3.1415926535897932384626433832795;

//获得灯光衰减信息
// TODO: 修改灯光逻辑后，衰减要进行迭代
float getAttenuation(Light light, float3 positionWS){
    float attenuation = 0;
    
    switch (light.type) {
        case Dirtctional: {
            attenuation = 1;
            break;
        }
        case Point: {
            float d = distance(light.position, positionWS);
            attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            break;
        }
        case Spot: {
            float d = distance(light.position, positionWS);
            float3 lightDir = normalize(light.position - positionWS);
            float3 coneDir = normalize(light.coneDirection);
            float spotResult = dot(lightDir, -coneDir);
            if(spotResult > cos(light.coneAngle)){
                attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
            }
            break;
        }
        case Ambient: {
            attenuation = 1;
            break;
        }
        case unused: {
            break;
        }
    }
    return attenuation;
}

float D_GGX(float NoH, float roughness)
{
    float alpha  = roughness * roughness;
    float alpha2 = alpha * alpha;
    float denom  = NoH * NoH * (alpha2 - 1.0) + 1.0;
    return (alpha2) / (pi * denom * denom);
}

float G_SchlicksmithGGX(float NoL, float NoV, float roughness)
{
    float r  = (roughness + 1.0);
    float k  = (r * r) / 8.0;
    float GL = NoL / (NoL * (1.0 - k) + k);
    float GV = NoV / (NoV * (1.0 - k) + k);
    return GL * GV;
}

float Pow5(float x)
{
    return x*x*x*x*x;
}

float3 F_Schlick(float cosTheta, float3 F0)
{
    return F0 + (1.0 - F0) * Pow5(1.0 - cosTheta);
}

float3 F_SchlickR(float cosTheta, float3 F0, float roughness)
{
    return F0 + (max(float3(1.0 - roughness, 1.0 - roughness, 1.0 - roughness), F0) - F0) * Pow5(1.0 - cosTheta);
}

float3 BRDF(float3  L,
            float3  V,
            float3  N,
            float3  F0,
            Material material)
{
    float3  H     = normalize(V + L);
    float NoV = clamp(dot(N, V), 0.0, 1.0);
    float NoL = clamp(dot(N, L), 0.0, 1.0);
    //float LoH = clamp(dot(L, H), 0.0, 1.0);
    float NoH = clamp(dot(N, H), 0.0, 1.0);
    
    float rroughness = max(0.05, material.roughness);
    
    float D = D_GGX(NoH, rroughness);
    float G = G_SchlicksmithGGX(NoL, NoV, rroughness);
    float3 F = F_Schlick(NoV, F0);
    
    float3 spec = D * F * G / (4.0 * NoL * NoV + 0.001);
    //float3 Kd   = (float3(1.0) - F) * (1.0 - material.metallic);
    //color += (Kd * material.baseColor / pi + (1.0 - Kd) * spec);
    
    return spec;
}

float3 directLighting(float3 normalWS,
                     float3 positionWS,
                     constant Params &params,
                     constant Light *lights,
                     Material material)
{
    float3 color(0,0,0);
    float3 diffuse = float3(0.0);
    float3 specular = float3(0.0);
    
    for (uint i = 0; i < params.lightCount; i++){
        Light light = lights[i];
        float attenuation = getAttenuation(light, positionWS);
        float3 lightDir = normalize(light.direction);
        //float3 reflectionDir = reflect(lightDir, normalWS);
        float3 viewDir = normalize(params.cameraPosition);
        
        float NoL = clamp(dot(normalWS, lightDir), 0.0, 1.0);
        float3 intensity = light.color * attenuation * NoL;
        color += intensity; //MARK: 这里是用于debug记录light only，后面会被覆盖为真正的着色结果
        diffuse += material.baseColor * intensity;
        specular += BRDF(lightDir, viewDir, normalWS, material.specularColor, material) * intensity;
    }
    //debug
    if(params.debugMode == DEBUG_DIFFUSE){
        return diffuse;
    }
    else if(params.debugMode == DEBUG_SPECULAR){
         return specular;
    }
    else if(params.debugMode == DEBUG_LIGHTONLY){
        return color;
    }
    
    color = diffuse + specular;
    
    return color;
}


// diffuse
float3 computeDiffuse(Material material,
                      float3 normalWS,
                      float3 lightDir)
{
    float nDotL = saturate(dot(normalWS, lightDir));
    float3 diffuse = float3(((1.0/pi) * material.baseColor) * (1.0 - material.metallic));
    diffuse = float3(material.baseColor) * (1.0 - material.metallic);
    return diffuse * nDotL * material.ambientOcclusion;
}

float G1V(float nDotV, float k)
{
    return 1.0f / (nDotV * (1.0f - k) + k);
}

// specular optimized-ggx
float3 computeSpecular(float3 normal,
                       float3 viewDirection,
                       float3 lightDirection,
                       float roughness,
                       float3 F0)
{
    float alpha = roughness * roughness;
    float3 halfVector = normalize(viewDirection + lightDirection);
    float nDotL = saturate(dot(normal, lightDirection));
    float nDotV = saturate(dot(normal, viewDirection));
    float nDotH = saturate(dot(normal, halfVector));
    float lDotH = saturate(dot(lightDirection, halfVector));
    
    float3 F;
    float D, G;
    
    // D
    float alphaSqr = alpha * alpha;
    float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
    D = alphaSqr / (pi * denom * denom);
    
    // F
    float lDotH5 = pow(1.0 - lDotH, 5);
    F = F0 + (1.0 - F0) * lDotH5;
    
    // G
    float k = alpha / 2.0f;
    G = G1V(nDotL, k) * G1V(nDotV, k);
    
    float3 specular = nDotL * D * F * G;
    return specular;
}

float3 calculatePoint(Light light,
                      float3 position,
                      float3 normal,
                      Material material)
{
    float d = distance(light.position, position);
    float3 lightDirection = normalize(light.position - position);
    float attenuation = 1.0 / (light.attenuation.x +
                               light.attenuation.y * d + light.attenuation.z * d * d);
    
    float diffuseIntensity =
    saturate(dot(lightDirection, normal));
    float3 color = light.color * material.baseColor * diffuseIntensity;
    color *= attenuation;
    return color;
}




