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
    var camera: Camera
    var sceneLights: Lights?
    var isPaused = false
    var terrainQuad: Quad?
    var skybox: Skybox?
    
    init(camera: Camera){
        self.camera = camera
    }
    
    mutating func cull(scene: GameScene, options: Options){
        models = []
        if options.drawGameObject {
            for gameObject in scene.goList{
                if gameObject.tag == .opaque {
                    models.append(gameObject.model)
                    Self.objectId += 1
                }
                else if gameObject.tag == .ground {
                    if !options.terrainReplacePlane {
                        models.append(gameObject.model)
                        Self.objectId += 1
                    }
                }
            }
            models.append(scene.pawn.model)
            
        }     
        camera = scene.camera
        isPaused = scene.isPaused
        sceneLights = scene.sceneLights
        if options.terrainReplacePlane {
            terrainQuad = scene.terrainQuad
        } else {
            terrainQuad = nil
        }
        skybox = scene.skybox
        
    }
}
