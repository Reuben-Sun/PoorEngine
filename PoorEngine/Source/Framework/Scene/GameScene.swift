//
//  GameScene.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

/// 创建场景
struct GameScene {
    var camera = ArcballCamera()
    var sceneLights: Lights
    var goList: [GameObject] = []
    var debugMainCamera: ArcballCamera?
    var debugShadowCamera: OrthographicCamera?
    var terrainQuad: Quad?
    var shouldDrawMainCamera = false
    var shouldDrawLightCamera = false
    var shouldDrawBoundingSphere = false
    var isPaused = false
    
    init() {
        sceneLights = Lights()
        camera.far = 10
        camera.transform = defaultView
        camera.target = [0, 1, 0]
        camera.distance = 4
        goList = []
    }
    
    init(sceneJsonName: String) {
        sceneLights = Lights()
        camera.far = 10
        camera.transform = defaultView
        camera.target = [0, 1, 0]
        camera.distance = 4
        goList = []
        let scene = SceneJson.loadScene(fileName: sceneJsonName)
        for go in scene.gameObject {
            var gameObject = GameObject(name: go.name, meshName: go.modelName, exten: go.exten)
            gameObject.position = [go.position[0], go.position[1], go.position[2]]
            gameObject.scale = go.scale
            gameObject.rotation = [go.rotation[0].degreesToRadians,
                                   go.rotation[1].degreesToRadians,
                                   go.rotation[2].degreesToRadians]
            gameObject.model.transform = gameObject.transform
            gameObject.tag = GameObjectTag(rawValue: go.tag) ?? .opaque
            goList.append(gameObject)
        }
        if scene.terrain.haveTerrain {
            terrainQuad = Quad()
            terrainQuad?.position = [scene.terrain.position[0],
                                     scene.terrain.position[1],
                                     scene.terrain.position[2]]
            terrainQuad?.scale = scene.terrain.scale
            terrainQuad?.rotation = [scene.terrain.rotation[0].degreesToRadians,
                                     scene.terrain.rotation[1].degreesToRadians,
                                     scene.terrain.rotation[2].degreesToRadians]
        }
        
    }
    
    
    /// 更新场景
    /// Swift知识：mutating是异变函数的关键词，使得不可变的结构体，通过创建新结构体赋值的方式可变
    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        if input.keysPressed.contains(.one) ||
            input.keysPressed.contains(.two) {
            camera.distance = 4
            if let mainCamera = debugMainCamera {
                camera = mainCamera
                debugMainCamera = nil
                debugShadowCamera = nil
            }
            shouldDrawMainCamera = false
            shouldDrawLightCamera = false
            shouldDrawBoundingSphere = false
            isPaused = false
        }
        if input.keysPressed.contains(.one) {
            camera.transform = Transform()
        }
        if input.keysPressed.contains(.two) {
            camera.transform = defaultView
        }
        if input.keysPressed.contains(.three) {
            shouldDrawMainCamera.toggle()
        }
        if input.keysPressed.contains(.four) {
            shouldDrawLightCamera.toggle()
        }
        if input.keysPressed.contains(.five) {
            shouldDrawBoundingSphere.toggle()
        }
        if !isPaused {
            if shouldDrawMainCamera || shouldDrawLightCamera || shouldDrawBoundingSphere {
                isPaused = true
                debugMainCamera = camera
                debugShadowCamera = OrthographicCamera()
                debugShadowCamera?.viewSize = 16
                debugShadowCamera?.far = 16
                let sun = sceneLights.dirLights[0]
                debugShadowCamera?.position = sun.position
                camera.distance = 40
                camera.far = 50
                camera.fov = 120
            }
        }
        input.keysPressed.removeAll()
        camera.update(deltaTime: deltaTime)
        //sun.position = sceneLights.lights[0].position
    }
    
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    var defaultView: Transform {
        Transform(
            position: [3.2, 3.1, 1.0],
            rotation: [-0.6, 10.7, 0.0])
    }
}
