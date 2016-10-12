//
//  CTPanoramaController
//  CTPanoramaController
//
//  Created by Cihan Tek on 11/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import ImageIO

@objc public enum CTPanaromaControlMethod: Int {
    case Motion
    case Touch
}

@objc public enum CTPanaromaType: Int {
    case Cylindirical
    case Spherical
}

@objc public class CTPanoramaController: UIViewController {
    
    public var image: UIImage?
    public var panaromaType = CTPanaromaType.Spherical
    public var speed = CGPoint(x: 0.005, y: 0.005)
    
    public var controlMethod: CTPanaromaControlMethod? {
        didSet {
            switchControlMethod(to: controlMethod!)
        }
    }
    
    private var sceneView: SCNView!
    private let cameraNode = SCNNode()
    private var prevLocation = CGPoint.zero
    private var motionManger = CMMotionManager()
    
    private var panoramaTypeForCurrentImage: CTPanaromaType {
        if let image = image {
            if (image.size.width / image.size.height == 2) {
                return .Spherical
            }
        }
        return .Cylindirical
    }
    
    // MARK: Class lifecycle methods
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot be initialized from a storyboard or nib")
    }
    
    deinit {
        if (motionManger.isDeviceMotionActive) {
            motionManger.stopDeviceMotionUpdates()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        panaromaType = panoramaTypeForCurrentImage

        prepareUI()
        createScene()

        controlMethod = .Touch
    }
    
    // MARK: Configuration helper methods
    
    private func createScene() {
        let camera = SCNCamera()
        camera.zFar = 100
        camera.xFov = 70
        camera.yFov = 70
        cameraNode.camera = camera
        
        let material = SCNMaterial()
        material.diffuse.contents = image!
        material.diffuse.mipFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
        material.diffuse.wrapS = .repeat
        material.cullMode = .front
        
        var geometryNode: SCNNode
        
        if (panaromaType == .Spherical) {
            let sphere = SCNSphere(radius: 50)
            sphere.segmentCount = 300
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode()
            sphereNode.geometry = sphere
            sphereNode.position = SCNVector3Make(0, 0, 0)
            geometryNode = sphereNode
        }
        else {
            let tube = SCNTube(innerRadius: 40, outerRadius: 40, height: 100)
            tube.heightSegmentCount = 50
            tube.radialSegmentCount = 300
            tube.firstMaterial = material
            
            let tubeNode = SCNNode()
            tubeNode.geometry = tube
            tubeNode.position = SCNVector3Make(0, 0, 0)
            geometryNode = tubeNode
            
            speed.y = 0 // Don't allow vertical movement in a cylindrical panorama
        }
        
        cameraNode.position = geometryNode.position
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(geometryNode)
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
    }
    
    private func prepareUI() {
        sceneView = SCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Touch/Motion", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        let views = ["sceneView" : sceneView, "button": button]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[sceneView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sceneView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[button]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    private func switchControlMethod(to method: CTPanaromaControlMethod) {
        if (method == .Touch) {
            let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panRec:)))
            sceneView.addGestureRecognizer(panGestureRec)
            
            if (motionManger.isDeviceMotionActive) {
                motionManger.stopDeviceMotionUpdates()
            }
        }
        else {
            guard motionManger.isDeviceMotionAvailable else {return}
            motionManger.deviceMotionUpdateInterval = 0.015
            motionManger.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {[unowned self] (motionData, error) in
                if let motionData = motionData {
                    self.cameraNode.orientation = motionData.look(at: UIApplication.shared.statusBarOrientation)
                }
                else {
                    print("\(error?.localizedDescription)")
                    self.motionManger.stopDeviceMotionUpdates()
                }
            })
            sceneView.gestureRecognizers?.removeAll()
        }
        cameraNode.eulerAngles = SCNVector3Make(0, 0, 0)
    }
    
    // MARK: Event handling methods
    
    @objc private func buttonTapped() {
        if controlMethod == .Touch {
            controlMethod = .Motion
        }
        else {
            controlMethod = .Touch
        }
    }
    
    @objc private func handlePan(panRec: UIPanGestureRecognizer) {
        if (panRec.state == .began) {
            prevLocation = CGPoint.zero
        }
        else if (panRec.state == .changed) {
            let location = panRec.translation(in: sceneView)
            let orientation = cameraNode.eulerAngles
            var newOrientation = SCNVector3Make(orientation.x + Float(location.y - prevLocation.y) * Float(speed.y),
                                                orientation.y + Float(location.x - prevLocation.x) * Float(speed.x),
                                                orientation.z)
            
            if (controlMethod == .Touch) {
                newOrientation.x = max(min(newOrientation.x, 1.01),-1.01)
            }

            cameraNode.eulerAngles = newOrientation
            prevLocation = location
        }
    }
}


extension CMDeviceMotion {
    
    func look(at orientation: UIInterfaceOrientation) -> SCNVector4 {
        
        let attitude = self.attitude.quaternion
        let aq = GLKQuaternionMake(Float(attitude.x), Float(attitude.y), Float(attitude.z), Float(attitude.w))
        
        var result: SCNVector4
        
        switch UIApplication.shared.statusBarOrientation {
            
        case .landscapeRight:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(M_PI_2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            result = SCNVector4(x: -q.y, y: q.x, z: q.z, w: q.w)
            
        case .landscapeLeft:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-M_PI_2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            result = SCNVector4(x: q.y, y: -q.x, z: q.z, w: q.w)
            
        case .portraitUpsideDown:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(M_PI_2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            result = SCNVector4(x: -q.x, y: -q.y, z: q.z, w: q.w)
            
        case .unknown:
            fallthrough
        case .portrait:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-M_PI_2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            result = SCNVector4(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        return result
    }
}
