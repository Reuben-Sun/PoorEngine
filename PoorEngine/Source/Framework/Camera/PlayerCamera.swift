//
//  PlayerCamera.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import CoreGraphics

struct PlayerCamera: Camera {
    var transform = Transform()
    
    var aspect: CGFloat = 1.0
    var viewSize: CGFloat = 10
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 10
    var minDistance: Float = 0
    var maxDistance: Float = 20
    
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: Float(aspect))
    }
    
    mutating func update(size: CGSize) {
        aspect = CGFloat(Float(size.width / size.height))
    }
    
    var viewMatrix: float4x4 {
        let rotateMatrix = float4x4(
            rotationYXZ: [-rotation.x, rotation.y, 0])
        return (float4x4(translation: position) * rotateMatrix).inverse
    }
    
    mutating func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        rotation += transform.rotation
        position += transform.position
        let input = InputController.shared
        if input.leftMouseDown {
            let sensitivity = Settings.mousePanSensitivity
            rotation.x += input.mouseDelta.y * sensitivity
            rotation.y += input.mouseDelta.x * sensitivity
            rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
            input.mouseDelta = .zero
        }
    }
}

extension PlayerCamera: Movement { }


