//
//  Movement.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import Foundation

/// 移动参数
enum Settings {
    static var rotationSpeed: Float {2.0}
    static var translationSpeed: Float {5.0}
    static var mouseScrollSensitivity: Float {0.1}
    static var mousePanSensitivity: Float {0.008}
    static var touchZoomSensitivity: Float {10}
}

protocol Movement where Self: Transformable {
}

extension Movement {
    /// 向前
    var forwardVector: float3 {
        //这个坐标系，y轴是垂直地面的，z轴向前，x轴向右
        normalize([sin(rotation.y), sin(rotation.x)*cos(rotation.z), cos(rotation.y)])
    }
    /// 水平向右
    var rightVector: float3 {
        [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
    
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let rotationAmount = deltaTime * Settings.rotationSpeed
        let input = InputController.shared
        
        //旋转
        if input.keysPressed.contains(.keyQ) {
            transform.rotation.y -= rotationAmount
        }
        if input.keysPressed.contains(.keyE) {
            transform.rotation.y += rotationAmount
        }
        //移动
        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {
            direction.z += 1
        }
        if input.keysPressed.contains(.keyS) {
            direction.z -= 1
        }
        if input.keysPressed.contains(.keyA) {
            direction.x -= 1
        }
        if input.keysPressed.contains(.keyD) {
            direction.x += 1
        }
        let translationAmount = deltaTime * Settings.translationSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += (direction.z * forwardVector + direction.x * rightVector) * translationAmount
        }
        return transform
    }
}

