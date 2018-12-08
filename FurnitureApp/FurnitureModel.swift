//
//  FurnitureModel.swift
//  FurnitureApp
//
//  Created by GreenTech on 12/8/18.
//  Copyright © 2018 AhmedKhidr. All rights reserved.
//

import UIKit
import ARKit

class FurnitureModel: SCNNode {
    
    func loadModel(name: String) {
        guard let virtualObjectScene = SCNScene(named: name) else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
    }
}
