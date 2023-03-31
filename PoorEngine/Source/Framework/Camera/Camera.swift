//
//  Camera.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import CoreGraphics

/// 相机
/// Swift知识：protocol是协议的关键词
protocol Camera: Transformable {
    var aspect: CGFloat {get}
    var viewSize: CGFloat {get}
    var near: Float {get}
    var far: Float {get}
    var minDistance: Float {get}
    var maxDistance: Float  {get}
    var fov: Float {get}
    var projectionMatrix: float4x4 {get}
    var viewMatrix: float4x4 {get}
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}

/// 透视相机
struct OrthographicCamera: Camera, Movement {
    var transform = Transform()
    var aspect: CGFloat = 1
    var viewSize: CGFloat = 10
    var near: Float = 0.1
    var far: Float = 100
    var center = float3.zero
    var fov: Float = Float(70).degreesToRadians
    
    var minDistance: Float = 0.0
    var maxDistance: Float = 20
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
    }
    
    var projectionMatrix: float4x4 {
      let rect = CGRect(
        x: -viewSize * aspect * 0.5,
        y: viewSize * 0.5,
        width: viewSize * aspect,
        height: viewSize)
      return float4x4(orthographic: rect, near: near, far: far)
    }

    mutating func update(size: CGSize) {
      aspect = size.width / size.height
    }

    mutating func update(deltaTime: Float) {
      let transform = updateInput(deltaTime: deltaTime)
      position += transform.position
      let input = InputController.shared
      let zoom = input.mouseScroll.x + input.mouseScroll.y
      viewSize -= CGFloat(zoom)
      input.mouseScroll = .zero
    }
}

