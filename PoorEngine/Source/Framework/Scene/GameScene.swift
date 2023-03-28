//
//  GameScene.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

/// 创建场景
struct GameScene {
    var camera: Camera
    var sceneLights: Lights
    var goList: [GameObject] = []
    var terrainQuad: Quad?
    var skybox: Skybox?
    var isPaused = false
    var pawn: Pawn
    
    init(sceneJsonName: String) {
        // load json
        let scene = SceneJson.loadScene(fileName: sceneJsonName)
        // load pawn
        pawn = Pawn(name: "pawn", meshName: "luoluo")
        pawn.model.position = [3,0,3]
        // load camera
        camera = PlayerCamera()
        camera.transform = GameScene.defaultView
        // load gameobject
        goList = []
        for go in scene.gameObject {
            let gameObject = GameObject(name: go.name, meshName: go.modelName, exten: go.exten)
            gameObject.model.position = [go.position[0], go.position[1], go.position[2]]
            gameObject.model.scale = go.scale
            gameObject.model.rotation = [go.rotation[0].degreesToRadians,
                                   go.rotation[1].degreesToRadians,
                                   go.rotation[2].degreesToRadians]
            gameObject.tag = GameObjectTag(rawValue: go.tag) ?? .opaque
            goList.append(gameObject)
        }
        // load terrain
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
        // load lights
        sceneLights = Lights()
        for light in scene.lights {
            var lightObject = Light()
            lightObject.type = LightType(rawValue: UInt32(light.lightType))
            lightObject.position = [light.position[0], light.position[1], light.position[2]]
            lightObject.direction = [light.direction[0], light.direction[1], light.direction[2]]
            lightObject.color = [light.color[0], light.color[1], light.color[2]]
            lightObject.specularColor = [light.specularColor[0], light.specularColor[1], light.specularColor[2]]
            lightObject.radius = light.radius
            lightObject.attenuation = [light.attenuation[0], light.attenuation[1], light.attenuation[2]]
            lightObject.coneAngle = light.coneAngle.degreesToRadians
            lightObject.coneDirection = [light.coneDirection[0], light.coneDirection[1], light.coneDirection[2]]
            lightObject.coneAttenuation = light.coneAttenuation
            if lightObject.type == Dirtctional {
                sceneLights.dirLights.append(lightObject)
            } else {
                sceneLights.pointLights.append(lightObject)
            }
        }
        sceneLights.compileLightBuffer()
        // load skybox
        skybox = Skybox(textureName: scene.skybox.textureName, shape: SkyboxShape(rawValue: scene.skybox.shape) ?? .sphere)
    }
    
    
    /// 更新场景
    /// Swift知识：mutating是异变函数的关键词，使得不可变的结构体，通过创建新结构体赋值的方式可变
    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        // 相机位置
        if input.keysPressed.contains(.one) {
            camera.transform = GameScene.defaultView
        }
        if input.keysPressed.contains(.two) {
            camera.transform = frontView
        }
        if input.keysPressed.contains(.three) {
            camera.transform = sideView
        }
        if input.keysPressed.contains(.four) {
            camera.transform = topView
        }
        if input.keysPressed.contains(.five) {
            camera.transform = farView
        }
        // 输出相机信息
        if input.keysPressed.contains(.keyP){
            print(camera.transform)
        }
       
        camera.update(deltaTime: deltaTime)
        //sun.position = sceneLights.lights[0].position
    }
    
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    static var defaultView: Transform {
        Transform(
            position: [1.4, 3.4, 3.2],
            rotation: [-0.5645003, 3.593275, 0.0])
    }
    
    var frontView: Transform {
        Transform(
            position: [0, 1, 3],
            rotation: [0, Float(180).degreesToRadians, 0])
    }
    
    var sideView: Transform {
        Transform(
            position: [3, 1, 0],
            rotation: [0, Float(-90).degreesToRadians, 0])
    }
    
    var topView: Transform {
        Transform(
            position: [0, 5, 0],
            rotation: [Float(-90).degreesToRadians, 0, 0.0])
    }
    
    var farView: Transform {
        Transform(
            position: [2.8, 5.1, 6.2],
            rotation: [-0.5645003, 3.593275, 0.0])
    }
}
