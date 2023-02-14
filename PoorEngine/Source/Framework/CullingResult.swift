//
//  CullingResult.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

struct CullingResult{
    var models: [Model] = []
    var camera = ArcballCamera()
    var sceneLights = Lights()
    var isPaused = false
    
    mutating func cull(scene: GameScene){
        camera = scene.camera
        models = scene.models
        isPaused = scene.isPaused
        sceneLights = scene.sceneLights
    }
}
