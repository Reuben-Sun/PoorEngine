//
//  Renderer.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

class RHI: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var shadowRenderPass: ShadowRenderPass
    var tiledDeferredRenderPass: TiledDeferredRenderPass
    
    var options: Options
    
    var shadowCamera = OrthographicCamera()
    var uniforms = Uniforms()
    var params = Params()
    
    init(metalView: MTKView, options: Options) {
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        RHI.device = device
        RHI.commandQueue = commandQueue
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        self.options = options
        
        // tile-base，仅支持苹果芯片
        if !device.supportsFamily(.apple3){
            print("WARNING: TBDR features not supported. Reverting to Forward Rendering")
        }
        shadowRenderPass = ShadowRenderPass()
        tiledDeferredRenderPass = TiledDeferredRenderPass(view: metalView, options: options)
        
        super.init()
        
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.9,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
}

extension RHI {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        shadowRenderPass.resize(view: view, size: size)
        tiledDeferredRenderPass.resize(view: view, size: size)
    }

    /// update
    func draw(cullingResult: CullingResult, in view: MTKView) {
        guard let commandBuffer = RHI.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        updateUniforms(cullingResult: cullingResult)
        updateParams(cullingResult: cullingResult, options: options)
        
        
        //阴影投射
        shadowRenderPass.draw(commandBuffer: commandBuffer,
                              cullingResult: cullingResult,
                              uniforms: uniforms,
                              params: params,
                              options: options)
        //TBDR
        tiledDeferredRenderPass.finalTexture = view.currentDrawable?.texture
        tiledDeferredRenderPass.shadowTexture = shadowRenderPass.shadowTexture
        tiledDeferredRenderPass.descriptor = descriptor
        tiledDeferredRenderPass.draw(commandBuffer: commandBuffer,
                                     cullingResult: cullingResult,
                                     uniforms: uniforms,
                                     params: params,
                                     options: options)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateUniforms(cullingResult: CullingResult) {
        uniforms.viewMatrix = cullingResult.camera.viewMatrix
        uniforms.projectionMatrix = cullingResult.camera.projectionMatrix
        
        shadowCamera.viewSize = 16
        shadowCamera.far = 16
        let sun = cullingResult.sceneLights!.dirLights[0]
        shadowCamera = OrthographicCamera.createShadowCamera(using: cullingResult.camera, lightPosition: sun.position)
        uniforms.shadowProjectionMatrix = shadowCamera.projectionMatrix
        uniforms.shadowViewMatrix = float4x4(eye: shadowCamera.position, center: shadowCamera.center, up: [0, 1, 0])
    }
    
    func updateParams(cullingResult: CullingResult, options: Options) {
        params.lightCount = UInt32(cullingResult.sceneLights!.pointLights.count)
        params.cameraPosition = cullingResult.camera.position
        params.inverseVPMatrix = (cullingResult.camera.viewMatrix.inverse * cullingResult.camera.projectionMatrix.inverse)
        //TODO: 通过Param传入Debug信息，未来会修改
        params.debugMode = uint(options.renderChoice.rawValue)
        params.tonemappingMode = uint(options.tonemappingMode.rawValue)
    }
}

