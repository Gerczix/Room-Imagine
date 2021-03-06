//
//  ViewController.swift
//  Room Imagine
//
//  Created by Gerard on 10/10/2020.
//

import UIKit
import SceneKit
import ARKit


//MARK: DECLARATIONS

class ViewController: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var item1: UIButton!
    @IBOutlet var item2: UIButton!
    @IBOutlet var item3: UIButton!
    @IBOutlet var item4: UIButton!
    @IBOutlet var buttonForward: UIButton!
    @IBOutlet var buttonLeft: UIButton!
    @IBOutlet var buttonBackward: UIButton!
    @IBOutlet var buttonDown: UIButton!
    @IBOutlet var buttonUp: UIButton!
    
    var currentNode : SCNNode?
    var selectedItem : String?
    
    //MARK: VIEW FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        sceneView.automaticallyUpdatesLighting = true
        //sceneView.autoenablesDefaultLighting = true -to test
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = ARWorldTrackingConfiguration.EnvironmentTexturing.automatic
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        
        registerGestureRecognizers()
        //addLight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }    
    
    //MARK: GESTURE RECOGNIZERS
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.sceneView.addGestureRecognizer(pressGestureRecognizer)
    }

    @objc func tapped(sender: UITapGestureRecognizer) {
        hideButtons(true)
        let sceneView = sender.view as! ARSCNView
        let tapLocation: CGPoint = sender.location(in: sceneView)
        
        guard let hitTest = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        guard let raycastResult = sceneView.session.raycast(hitTest).first else { return }
        addItem(raycastResult)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pressLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pressLocation)
        
        if !hitTest.isEmpty {
            
            let results = hitTest.first!
            let node = results.node
            if(node.name != nil)
            {
                print(node.name as Any)
                self.currentNode = node
                hideButtons(false)
            }
        }
        else {
            hideButtons(true)
        }
    }
    //MARK: HIDE BUTTONS
    func hideButtons(_ bool: Bool) {
        let items : Array<UIButton> = [self.item1, self.item2, self.item3, self.item4, self.buttonUp, self.buttonBackward, self.buttonDown, self.buttonForward, self.buttonLeft]
        for item in items {
            if(bool == true) {
                item.isHidden = true
            }
            else {
                item.isHidden = false
            }
        }
    }
    
    //MARK: ADD AND REMOVE OBJECTS
    
    func addItem(_ result: ARRaycastResult) {
        
        if(self.selectedItem != nil) {
            print("selectedItem ", self.selectedItem!)
            var scene = SCNScene(named: "Objects.scnassets/\(self.selectedItem!).scn")
            
            if(scene == nil) {
                scene = SCNScene(named: "Objects.scnassets/\(self.selectedItem!).dae")
            }
            
            if(scene == nil) {
                scene = SCNScene(named: "Objects.scnassets/\(self.selectedItem!).abc")
            }
            
            if(scene != nil) {
                let node = (scene!.rootNode.childNode(withName: self.selectedItem!, recursively: false))!
                let position = result.worldTransform.columns.3
                print("position = ", position)
                node.position = SCNVector3(position.x, position.y, position.z)
                node.eulerAngles.y = sceneView.session.currentFrame!.camera.eulerAngles.y
                print(sceneView.session.currentFrame!.camera.eulerAngles.y)
                
                
                
                self.sceneView.scene.rootNode.addChildNode(node)
                self.currentNode = node
                hideButtons(false)
                self.selectedItem = nil
            }
        }
    }
    /*
    func addLight() {
        // 1
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        // 2
        directionalLight.intensity = 1000
        // 3
        directionalLight.castsShadow = true
        directionalLight.shadowMode = .deferred
        // 4
        directionalLight.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // 5
        directionalLight.shadowSampleCount = 10
        // 6
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 3)
        self.sceneView.scene.rootNode.addChildNode(directionalLightNode)
    }
    */
    @IBAction func removeObject(_ sender: UIButton) {
        self.currentNode?.removeFromParentNode()
        hideButtons(true)
    }
    
    //MARK: Move
    func move(x: CGFloat, y: CGFloat, z: CGFloat, duration: Double) {
            
        let move = SCNAction.moveBy(x: x, y: y, z: z, duration: duration)
        let forever = SCNAction.repeatForever(move)
        self.currentNode!.runAction(forever)
    }
    
    @IBAction func moveRight(_ sender: UIButton) {
        
        let y = sceneView.session.currentFrame!.camera.eulerAngles.y
        move(x: CGFloat(cos(y)), y: 0, z: CGFloat(-sin(y)), duration: 1)
    }
    
    @IBAction func moveBackward(_ sender: UIButton) {
        
        let y = sceneView.session.currentFrame!.camera.eulerAngles.y
        move(x: CGFloat(sin(y)), y: 0, z: CGFloat(cos(y)), duration: 1)
    }
    
    @IBAction func moveLeft(_ sender: UIButton) {
        let y = sceneView.session.currentFrame!.camera.eulerAngles.y
        
        move(x: CGFloat(-cos(y)), y: 0, z: CGFloat(sin(y)), duration: 1)
    }
    
    @IBAction func moveForward(_ sender: UIButton) {
        let y = sceneView.session.currentFrame!.camera.eulerAngles.y
        
        move(x: CGFloat(-sin(y)), y: 0, z: CGFloat(-cos(y)), duration: 1)
    }
    
    @IBAction func moveDown(_ sender: UIButton) {
        move(x: 0, y: -1, z: 0, duration: 1)
    }
    
    @IBAction func moveUp(_ sender: UIButton) {
        move(x: 0, y: 1, z: 0, duration: 1)
    }
    
    //MARK: Rotate
    
    func rotate(x: CGFloat, y: CGFloat, z: CGFloat, duration: Double) {
        
        let move = SCNAction.rotateBy(x: x, y: y, z: z, duration: duration)
        let forever = SCNAction.repeatForever(move)
        self.currentNode!.runAction(forever)
    }
    
    @IBAction func rotateLeft(_ sender: UIButton) {
        rotate(x: 0, y: CGFloat(2*Double.pi), z: 0, duration: 3)
     }
    
    @IBAction func rotateRight(_ sender: UIButton) {
        rotate(x: 0, y: CGFloat(-2*Double.pi), z: 0, duration: 3)
    }
    
    @IBAction func stopAction(_ sender: UIButton) {
        self.currentNode!.removeAllActions()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK: Press object
    @IBAction func objectsPressed(_ sender: UIButton) {
        hideButtons(true)
        let objectPicker = ObjectPicker(size: CGSize(width: 250, height: 500))
        objectPicker.viewController = self
        objectPicker.modalPresentationStyle = .popover
        objectPicker.popoverPresentationController?.delegate = self
        present(objectPicker, animated: true, completion: nil)
        objectPicker.popoverPresentationController?.sourceView = sender
        objectPicker.popoverPresentationController?.sourceRect = sender.bounds
        
    }
    
}
