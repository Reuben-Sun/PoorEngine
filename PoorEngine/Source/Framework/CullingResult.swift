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
    
    mutating func cull(scene: GameScene){
        models = []
        for gameObject in scene.goList{
            var goModel = Model(name: gameObject.meshName, exten: gameObject.meshExten)
            goModel.transform = gameObject.transform
            models.append(goModel)
        }
        
        camera = scene.camera
        isPaused = scene.isPaused
        
        sceneLights = scene.sceneLights
        //sun.position = sceneLights.lights[0].position
        //models = [treefir1, treefir2, treefir3, train, ground, sun]
    }
    
    func createModel(name: String, exten: String) -> Model {
        let model = Model(name: name, exten: exten, objectId: Self.objectId)
        Self.objectId += 1
        return model
    }
}
