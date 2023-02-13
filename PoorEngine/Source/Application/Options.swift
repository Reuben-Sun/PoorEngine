//
//  Options.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import Foundation

enum RenderChoice {
    case shadered, debugLight, selectItem
}

enum RenderPath {
    case forward, deferred, tiled
}

class Options: ObservableObject {
    @Published var renderChoice = RenderChoice.shadered
    @Published var renderPath = RenderPath.deferred
    @Published var tiledSupported = false
}
