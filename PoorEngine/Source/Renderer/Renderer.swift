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
        scene = GameScene()
        
        //TODO: 使用json管理场景，向scene中添加物体
        var ballGO = GameObject(name: "shaderBall", meshName: "shaderBall", exten: "obj")
        ballGO.position = [0,0,0]
        ballGO.scale = 0.01
        ballGO.rotation = [0,Float(90).degreesToRadians,0]
        ballGO.model.transform = ballGO.transform
        scene.goList.append(ballGO)
        scene.terrainQuad = Quad()
        scene.terrainQuad!.position = [0,0,0]
        scene.terrainQuad!.rotation = [0,Float(90).degreesToRadians,0]
        var largePlaneGO = GameObject(name: "large_plane", meshName: "large_plane", exten: "obj")
        largePlaneGO.tag = .ground
        scene.goList.append(largePlaneGO)
        
        var ballScene = SceneJson.loadScene(fileName: "BallScene")
        print(ballScene.name)
        
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

