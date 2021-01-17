//
//  ObjectPicker.swift
//  Room Imagine
//
//  Created by Gerard on 21/10/2020.
//

import UIKit
import SceneKit

//MARK: Class & Init
class ObjectPicker: UIViewController {
    
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
        //let scene = SCNScene()
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        //MARK: Objects
        addObjects()
       
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
    
    func addObjects() {
        var i : Float = 0
        
        
        
        let objects = self.showFiles()
        let objectsNames = objects.map{ $0.lastPathComponent } //map [URL] to [String]
        let objectsWithoutExtensions = objects.map{ $0.deletingPathExtension().lastPathComponent }
       
        for j in 0...objects.count-1
        {
            guard let obj = SCNScene(named: "Objects.scnassets/\(objectsNames[j])")
            else { return }
            let node = obj.rootNode.childNode(withName: objectsWithoutExtensions[j], recursively: true)!
            
            let position = node.position.y

            let min = node.boundingBox.min
            let max = node.boundingBox.max
            let height = CGFloat((max.y - min.y))
            
            let scaleX = CGFloat(node.scale.x)
            let scaleY = CGFloat(node.scale.y)
            let scaleZ = CGFloat(node.scale.z)
    
            let minScale = min3(scaleX,scaleY,scaleZ)
            let scale = 0.3/height/minScale
            let scales = [scale*scaleX,scale*scaleY,scale*scaleZ]
            
            node.scale = SCNVector3(scales[0],scales[1],scales[2])
            
            node.eulerAngles =  SCNVector3(0, CGFloat(i * Float.pi)/10, 0)
            node.position = SCNVector3Make(1, (0.7 + position * 0.3 - i), -1)
            i+=0.4
            let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.01 * Double.pi), z: 0, duration: 0.1))
            node.runAction(rotate)
            self.sceneView.scene!.rootNode.addChildNode(node)
            
        }
        
    }
    func min3(_ a: CGFloat,_ b: CGFloat,_ c: CGFloat) -> CGFloat {
        return min(a, b, c)
    }
    
    func showFiles() -> [URL] {

        var daeFiles: [URL] = []
        do {
            let directory = Bundle.main.resourceURL!.appendingPathComponent("Objects.scnassets").absoluteURL
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
           
            daeFiles = directoryContents.filter{ $0.pathExtension == "dae" || $0.pathExtension == "scn"}
            
            } catch {
                print(error)
            }
        
        //daeFileNames = daeFiles.map{ $0.lastPathComponent }
            
        return daeFiles
            
    }
   
}
