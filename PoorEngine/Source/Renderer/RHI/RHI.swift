//
//  RHI.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

class RHI: NSObject {
    public var device: MTLDevice!
    public var commandQueue: MTLCommandQueue!
    public var library: MTLLibrary!
    
    init(metalView: MTKView) {
        super.init()
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        self.device = device
        self.commandQueue = commandQueue
        
        let library = self.device.makeDefaultLibrary()
        self.library = library
    }
}
