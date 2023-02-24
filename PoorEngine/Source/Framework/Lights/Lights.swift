//
//  Lights.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

struct Lights {
    var dirLights: [Light]
    var pointLights: [Light]
    
    var dirBuffer: MTLBuffer?
    var pointBuffer: MTLBuffer?
    
    let sunlight: Light = {
        var light = Self.buildDefaultLight()
        light.direction = [3, 3, -2]
        light.color = [1, 1, 1]
        return light
    }()
    
    let ambientLight: Light = {
        var light = Self.buildDefaultLight()
        light.color = [0.0, 0.1, 0.05]
        light.type = Ambient
        return light
    }()
    
    //Spot光
    lazy var spotlight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Spot
        light.position = [-0.64, 0.64, -1.07]
        light.color = [1, 0, 1]
        light.attenuation = [1, 0.5, 0]
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [0.5, -0.7, 1]
        light.coneAttenuation = 8
        return light
    }()
    
    mutating func addPointLight(count: Int, min: float3, max: float3){
        let colors: [float3] = [
            float3(1, 0, 0),
            float3(1, 1, 0),
            float3(1, 1, 1),
            float3(0, 1, 0),
            float3(0, 1, 1),
            float3(0, 0, 1),
            float3(0, 1, 1),
            float3(1, 0, 1)
        ]
        for _ in 0..<count {
            var light = Self.buildDefaultLight()
            light.type = Point
            let x = Float.random(in: min.x...max.x)
            let y = Float.random(in: min.y...max.y)
            let z = Float.random(in: min.z...max.z)
            light.position = [x, y, z]
            light.color = colors[Int.random(in: 0..<colors.count)]
            light.attenuation = [0.2, 10, 50]
            pointLights.append(light)
        }
    }
    
    mutating func compileLightBuffer(){
        if !dirLights.isEmpty{
            dirBuffer = Self.createBuffer(lights: dirLights)
        }
        if !pointLights.isEmpty{
            pointBuffer = Self.createBuffer(lights: pointLights)
        }
        
    }
    
    static func buildDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.direction = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Dirtctional
        return light
    }
    static func createBuffer(lights: [Light]) -> MTLBuffer {
        var lights = lights
        return RHI.device.makeBuffer(
            bytes: &lights,
            length: MemoryLayout<Light>.stride * lights.count,
            options: [])!
    }
    
    
    /// 灯光初始化
    init() {
        dirLights = []
        // TODO: 目前至少有一盏方向光，不然无法进行Light Pass，需要修复
//        dirLights = [sunlight, ambientLight]
//        dirBuffer = Self.createBuffer(lights: dirLights)
        pointLights = []
        //        pointBuffer = Self.createBuffer(lights: pointLights)
    }
}

