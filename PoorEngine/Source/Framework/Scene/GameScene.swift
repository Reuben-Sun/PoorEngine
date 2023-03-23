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
    var debugMainCamera: ArcballCamera?
    var debugShadowCamera: OrthographicCamera?
    var terrainQuad: Quad?
    var skybox: Skybox?
    var shouldDrawMainCamera = false
    var shouldDrawLightCamera = false
    var shouldDrawBoundingSphere = false
    var isPaused = false
    
    init(sceneJsonName: String) {
        sceneLights = Lights()
        camera = ArcballCamera()
        goList = []
        let scene = SceneJson.loadScene(fileName: sceneJsonName)
        // load gameobject
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
        if input.keysPressed.contains(.one) ||
            input.keysPressed.contains(.two) {
            //camera.distance = 4
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
                //debugMainCamera = camera
                debugShadowCamera = OrthographicCamera()
                debugShadowCamera?.viewSize = 16
                debugShadowCamera?.far = 16
                let sun = sceneLights.dirLights[0]
                debugShadowCamera?.position = sun.position
                //camera.distance = 40
                //camera.far = 50
                //camera.fov = 120
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
