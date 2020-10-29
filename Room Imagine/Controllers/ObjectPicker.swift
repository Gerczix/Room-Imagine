//
//  ObjectPicker.swift
//  Room Imagine
//
//  Created by Gerard on 21/10/2020.
//

import UIKit
import SceneKit

//MARK: Class & Init
class ObjectPicker: UIViewController, UIScrollViewDelegate {
    
    var sceneView: SCNView!
    
    var size: CGSize!
    weak var viewController: ViewController!
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Frame
        
        view.frame = CGRect(origin: CGPoint.zero, size: size)
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.insertSubview(sceneView, at: 0)
        
        sceneView.allowsCameraControl = true
        
        preferredContentSize = size
        let scene = SCNScene(named: "art.scnassets/objects.scn")!
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        //MARK: Objects
        
        //PIPE
        var obj = SCNScene(named: "art.scnassets/pipe.dae")
        var node = obj?.rootNode.childNode(withName: "pipe", recursively: true)!
        node?.scale = SCNVector3Make(0.0022, 0.0022, 0.0022)
        node?.position = SCNVector3Make(1, 0.7, -1)
        let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.01 * Double.pi), z: 0, duration: 0.1))
        node!.runAction(rotate)
        scene.rootNode.addChildNode(node!)
        
        //BURGER
        obj = SCNScene(named: "art.scnassets/burger.dae")
        node = obj?.rootNode.childNode(withName: "burger", recursively: true)!
        
        node?.scale = SCNVector3Make(0.14, 0.14, 0.14)
        node?.position = SCNVector3Make(1, -0.4, -1)
        node!.runAction(rotate)
        scene.rootNode.addChildNode(node!)
        
    }
    
    //MARK: Tap Recognizer
    @objc func tapped(sender: UITapGestureRecognizer) {
        let tapLocation: CGPoint = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, options: [:])
        
        if hitTest.count > 0 {
            let node = hitTest[0].node
            viewController.selectedItem = node.name!
            dismiss(animated: true, completion: nil)
        }
    }
   
}
