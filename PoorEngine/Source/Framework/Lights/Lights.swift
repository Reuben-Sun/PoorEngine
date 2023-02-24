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
    
    mutating func compileLightBuffer(){
        if !dirLights.isEmpty{
            dirBuffer = Self.createBuffer(lights: dirLights)
        }
        if !pointLights.isEmpty{
            pointBuffer = Self.createBuffer(lights: pointLights)
        }
        
    }
    
    static func createBuffer(lights: [Light]) -> MTLBuffer {
        var lights = lights
        return RHI.device.makeBuffer(
            bytes: &lights,
            length: MemoryLayout<Light>.stride * lights.count,
            options: [])!
    }
    
    init() {
        dirLights = []
        pointLights = []
    }
}

