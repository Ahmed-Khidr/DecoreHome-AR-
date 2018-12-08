//
//  ViewController.swift
//  FurnitureApp
//
//  Created by GreenTech on 12/8/18.
//  Copyright © 2018 AhmedKhidr. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var sceneView: ARSCNView?
    @IBOutlet weak var collectionView: UICollectionView?
    
    var furnitureArray = ["SofaIcon","chairIcon","tableIcon"]
    var ScnArray = ["Sofa","Chair","Table"]
    var scenename = "Chair"
    var furnitureModel = FurnitureModel()
    var floorNodeName = "currentFloor"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScene()
        addGestures()
        setupConfiguration()
        addSurface()
        
    }
    
    func setupScene() {
        let scene = SCNScene()
        sceneView?.scene = scene
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView?.session.run(configuration)
    }
    
    func addSurface() {
        furnitureModel.loadModel(name: scenename)
        sceneView?.scene.rootNode.addChildNode(furnitureModel)
    }
    
    //MARK :- add furnitureSCN
    func addGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
        tap.numberOfTapsRequired = 1
        sceneView?.addGestureRecognizer(tap)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        sceneView?.addGestureRecognizer(pinchGesture)

        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotated(sender:)))
        sceneView?.addGestureRecognizer(rotateGesture)
        
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(move(sender:)))
        sceneView?.addGestureRecognizer(moveGesture)
        
        let deleteGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteNode(sender:)))
        sceneView?.addGestureRecognizer(deleteGesture)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
            print("Touch detected surface")
            addFurniture(hitTestResult: hitTest.first!)
        }
        else{
            print("Not a surface")
        }
    }
    @objc func zoom(sender: UIPinchGestureRecognizer){
        let scnVw = sender.view as! ARSCNView
        let tapLoc = sender.location(in: scnVw)
        
        let hitTest = scnVw.hitTest(tapLoc)
        if !hitTest.isEmpty{
            let node = hitTest.filter({$0.node.name != floorNodeName}).first?.node
            let zoomAction = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(zoomAction)
            sender.scale = 1.0
        }
    }
    @objc func rotated(sender: UIRotationGestureRecognizer){
        let scnVw = sender.view as! ARSCNView
        let tapLoc = sender.location(in: scnVw)
        
        let hitTest = scnVw.hitTest(tapLoc)
        if !hitTest.isEmpty{
            let node = hitTest.filter({$0.node.name != floorNodeName}).first?.node
            if sender.state == .began || sender.state == .changed {
                node?.eulerAngles = SCNVector3(CGFloat((node?.eulerAngles.x)!),sender.rotation,CGFloat((node?.eulerAngles.z)!))
            }
        }
    }
    @objc func move(sender: UIPanGestureRecognizer){
        let scnVw = sender.view as! ARSCNView
        let tapLoc = sender.location(in: scnVw)
        
        let hitTest = scnVw.hitTest(tapLoc)
        if !hitTest.isEmpty{
            let node = hitTest.filter({$0.node.name != floorNodeName}).first?.node
            if sender.state == .changed {
                let location = sender.location(in: sceneView)
                guard let result = sceneView?.hitTest(tapLoc, types: .existingPlane).first else { return }
                
                let transform = result.worldTransform
                let newPosition = float3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                node?.simdPosition = newPosition
            }
        }
    }
    @objc func deleteNode(sender: UILongPressGestureRecognizer) {
        let scnVw = sender.view as! ARSCNView
        let tapLoc = sender.location(in: scnVw)
        
        let hitTest = scnVw.hitTest(tapLoc)
        if !hitTest.isEmpty{
            let node = hitTest.filter({$0.node.name != floorNodeName}).first?.node
            node?.removeFromParentNode()
    }
    }
    func addFurniture(hitTestResult:ARHitTestResult){
        
        guard let scene = SCNScene(named: "scnFurniture.scnassets/\(scenename).scn") else{return}
        
        let node = (scene.rootNode.childNode(withName: scenename, recursively: false))!
        
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        self.sceneView?.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ScnArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FurnitureCollectionViewCell
        cell.furnitureImg?.image = UIImage(named: furnitureArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scenename = ScnArray[indexPath.row]
        collectionView.reloadData()
    }
    
}

extension ViewController : ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
            plane.materials.first?.diffuse.contents = UIColor.yellow.withAlphaComponent(0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            planeNode.position = SCNVector3(CGFloat(anchor.center.x), CGFloat(anchor.center.y), CGFloat(anchor.center.z))
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.name = floorNodeName
            node.addChildNode(planeNode)
        }
    }
}

class FurnitureCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var furnitureImg: UIImageView?
}
    

