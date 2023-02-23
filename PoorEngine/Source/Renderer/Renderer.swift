//
//  GameController.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

class Renderer: NSObject {
    var scene: GameScene
    var rhi: RHI
    var cullingResult: CullingResult
    var options = Options()
    var fps: Double = 0
    var deltaTime: Double = 0
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    
    init(metalView: MTKView, options: Options) {
        rhi = RHI(metalView: metalView, options: options)
        scene = GameScene(sceneJsonName: "BallScene")
        
        cullingResult = CullingResult()
        super.init()
        self.options = options
        metalView.delegate = self
        fps = Double(metalView.preferredFramesPerSecond)
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
        rhi.mtkView(view, drawableSizeWillChange: size)
    }
    
    func draw(in view: MTKView) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = (currentTime - lastTime)
        lastTime = currentTime
        scene.update(deltaTime: Float(deltaTime))
        cullingResult.cull(scene: scene, options: options)
        rhi.draw(cullingResult: cullingResult, in: view)
    }
}

