//
//  TiledDeferredRenderPass.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

struct TiledDeferredRenderPass: RenderPass{
    var label = "Tiled Deferred Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var gBufferPassPSO: MTLRenderPipelineState
    var lightingPassPSO: MTLRenderPipelineState
    var terrainPassPSO: MTLRenderPipelineState
    var tessellationComputePass: TessellationComputePass
    
    let depthStencilState: MTLDepthStencilState?
    let lightingDepthStencilState: MTLDepthStencilState?
    
    weak var shadowTexture: MTLTexture?
    var albedoTexture: MTLTexture?
    var normalTexture: MTLTexture?
    var positionTexture: MTLTexture?
    var depthTexture: MTLTexture?

    var heightMap: MTLTexture?
    
    init(view: MTKView, options: Options) {
        gBufferPassPSO = PipelineStates.createGBufferPassPSO(
            colorPixelFormat: view.colorPixelFormat,
            options: options)
        lightingPassPSO = PipelineStates.createLightingPassPSO(
            colorPixelFormat: view.colorPixelFormat,
            options: options)
        terrainPassPSO = PipelineStates.createTerrainPSO(colorPixelFormat: view.colorPixelFormat)
        
        depthStencilState = Self.buildDepthStencilState()
        lightingDepthStencilState = Self.buildLightingDepthStencilState()
        
        tessellationComputePass = TessellationComputePass(view: view, options: options)
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        let frontFaceStencil = MTLStencilDescriptor()
        frontFaceStencil.stencilCompareFunction = .always
        frontFaceStencil.stencilFailureOperation = .keep
        frontFaceStencil.depthFailureOperation = .keep
        frontFaceStencil.depthStencilPassOperation = .incrementClamp
        descriptor.frontFaceStencil = frontFaceStencil
        return RHI.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    static func buildLightingDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = false
        let frontFaceStencil = MTLStencilDescriptor()
        frontFaceStencil.stencilCompareFunction = .notEqual
        frontFaceStencil.stencilFailureOperation = .keep
        frontFaceStencil.depthFailureOperation = .keep
        frontFaceStencil.depthStencilPassOperation = .keep
        descriptor.frontFaceStencil = frontFaceStencil
        return RHI.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
        //将贴图类型设为memoryless
        albedoTexture = Self.makeTexture(
            size: size,
            pixelFormat: .bgra8Unorm,
            label: "Albedo Texture",
            storageMode: .memoryless)
        normalTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Normal Texture",
            storageMode: .memoryless)
        positionTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Position Texture",
            storageMode: .memoryless)
        depthTexture = Self.makeTexture(
            size: size,
            pixelFormat: .depth32Float_stencil8,
            label: "Depth Texture",
            storageMode: .memoryless)
        
        do {
            heightMap = try TextureController.loadTexture(filename: "mountain")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func draw(commandBuffer: MTLCommandBuffer, cullingResult: CullingResult, uniforms: Uniforms, params: Params, options: Options) {
        guard let viewCurrentRenderPassDescriptor = descriptor else {
            return
        }
        // MARK: tesselation pass
        tessellationComputePass.tessellation(commandBuffer: commandBuffer, cullingResult: cullingResult)
        
        // MARK: G-buffer pass
        let descriptor = viewCurrentRenderPassDescriptor
        let textures = [
            albedoTexture,
            normalTexture,
            positionTexture
        ]
        //将贴图存储操作设为dontCare
        for (index, texture) in textures.enumerated() {
            let attachment =
            descriptor.colorAttachments[RenderTarget0.index + index]
            attachment?.texture = texture
            attachment?.loadAction = .clear
            attachment?.storeAction = .dontCare
            attachment?.clearColor =
            MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
        }
        descriptor.depthAttachment.texture = depthTexture
        descriptor.stencilAttachment.texture = depthTexture
        
        // TODO: 很离谱，显式指定Tile大小后，带宽、GPU时间大幅提高
        //        descriptor.tileWidth = 32
        //        descriptor.tileHeight = 32
        //        descriptor.threadgroupMemoryLength = MemoryLayout<Light>.size * 8
        
        guard let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor
                ) else { return }
        
        drawGBufferRenderPass(
            renderEncoder: renderEncoder,
            cullingResult: cullingResult,
            uniforms: uniforms,
            params: params,
            options: options)
        
        drawTerrainRenderPass(
            renderEncoder: renderEncoder,
            cullingResult: cullingResult,
            uniforms: uniforms,
            params: params,
            options: options)
        
        drawLightingRenderPass(
            renderEncoder: renderEncoder,
            cullingResult: cullingResult,
            uniforms: uniforms,
            params: params,
            options: options)
        renderEncoder.endEncoding()
    }
    
    func drawGBufferRenderPass(
        renderEncoder: MTLRenderCommandEncoder,
        cullingResult: CullingResult,
        uniforms: Uniforms,
        params: Params,
        options: Options
    ) {
        renderEncoder.label = "G-buffer render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(gBufferPassPSO)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        //        renderEncoder.setFrontFacing(.clockwise)
        //        renderEncoder.setCullMode(.back)
        
        for model in cullingResult.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params,
                options: options)
        }
    }
    
    func drawLightingRenderPass(
        renderEncoder: MTLRenderCommandEncoder,
        cullingResult: CullingResult,
        uniforms: Uniforms,
        params: Params,
        options: Options
    ) {
        renderEncoder.label = "Lighting render pass"
        renderEncoder.setDepthStencilState(lightingDepthStencilState)
        var uniforms = uniforms
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: UniformsBuffer.index)
        
        // MARK: DirLight support, Point Light un support
        renderEncoder.pushDebugGroup("Dir Light")
        renderEncoder.setRenderPipelineState(lightingPassPSO)
        var params = params
        params.lightCount = UInt32(cullingResult.sceneLights.dirLights.count)
        renderEncoder.setFragmentBytes(&params,
                                       length: MemoryLayout<Params>.stride,
                                       index: ParamsBuffer.index)
        renderEncoder.setFragmentBuffer(cullingResult.sceneLights.dirBuffer,
                                        offset: 0,
                                        index: LightBuffer.index)
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 6)
        renderEncoder.popDebugGroup()
    }
    
    func drawTerrainRenderPass(
        renderEncoder: MTLRenderCommandEncoder,
        cullingResult: CullingResult,
        uniforms: Uniforms,
        params: Params,
        options: Options
    ) {
        renderEncoder.label = "Terrain render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(terrainPassPSO)
        //        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        var uniforms = uniforms
        uniforms.modelMatrix = cullingResult.terrainQuad.transform.modelMatrix
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)
        
        var params = params
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)
        
        // draw
        renderEncoder.setTessellationFactorBuffer(tessellationComputePass.tessellationFactorsBuffer, offset: 0, instanceStride: 0)
        
        renderEncoder.setVertexBuffer(
            tessellationComputePass.controlPointsBuffer,
            offset: 0,
            index: 0)
        
        renderEncoder.setVertexTexture(heightMap, index: 0)
        var terrain = tessellationComputePass.terrain
        renderEncoder.setVertexBytes(&terrain, length: MemoryLayout<Terrain>.stride, index: TerrainBuffer.index)
        
        // MARK: 线框debug，由于我们使用TBDR，只有一个Encoder，因此执行CS后要恢复.fill
        renderEncoder.setTriangleFillMode(options.drawTriangle ? .fill : .lines)
        
        renderEncoder.drawPatches(
              numberOfPatchControlPoints: 4,
              patchStart: 0,
              patchCount: tessellationComputePass.patchCount,
              patchIndexBuffer: nil,
              patchIndexBufferOffset: 0,
              instanceCount: 1,
              baseInstance: 0)
        
        renderEncoder.setTriangleFillMode(.fill)
    }
}

