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
    var sceneLights = Lights()
    var goList: [GameObject] = []
    var debugMainCamera: ArcballCamera?
    var debugShadowCamera: OrthographicCamera?
    
    var shouldDrawMainCamera = false
    var shouldDrawLightCamera = false
    var shouldDrawBoundingSphere = false
    var isPaused = false
    
    init() {
        camera.far = 10
        camera.transform = defaultView
        camera.target = [0, 1, 0]
        camera.distance = 4
        
        //TODO: scene加载逻辑，用usd做场景管理
        var trainGO = GameObject(name: "train", meshName: "train.obj")
        var treefir1GO = GameObject(name: "treefir1", meshName: "treefir.obj")
        treefir1GO.position = [-1, 0, 2.5]
        var treefir2GO = GameObject(name: "treefir2", meshName: "treefir.obj")
        treefir2GO.position = [-3, 0, -2]
        var treefir3GO = GameObject(name: "treefir3", meshName: "treefir.obj")
        treefir3GO.position = [1.5, 0, -0.5]
        var largePlaneGO = GameObject(name: "large_plane", meshName: "large_plane.obj")
        goList = [trainGO, treefir1GO, treefir2GO, treefir3GO, largePlaneGO]
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
                let sun = sceneLights.lights[0]
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