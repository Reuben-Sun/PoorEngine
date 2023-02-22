//
//  CullingResult.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

struct CullingResult{
    static var objectId: UInt32 = 1
    var models: [Model] = []
    var camera = ArcballCamera()
    var sceneLights = Lights()
    var isPaused = false
    var terrainQuad = Quad()
    
    mutating func cull(scene: GameScene){
        models = []
        for gameObject in scene.goList{
            models.append(gameObject.model)
            Self.objectId += 1
        }
        camera = scene.camera
        isPaused = scene.isPaused
        sceneLights = scene.sceneLights
        terrainQuad = scene.terrainQuad
    }
}
