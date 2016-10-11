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

@objc public enum CTPanaromaControlMethod: Int {
    case Accelerometer
    case Touch
}

@objc public class CTPanoramaController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    public var controlMethod = CTPanaromaControlMethod.Accelerometer
    private let cameraNode = SCNNode()
    private var prevLocation = CGPoint.zero
    private var motionManger = CMMotionManager()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
  
        let camera = SCNCamera()
        camera.zFar = 100
        camera.xFov = 70
        camera.yFov = 70
        cameraNode.camera = camera
        
        let material = SCNMaterial()
        let texture = UIImage(named: "test.png")
        material.diffuse.contents = texture
        material.diffuse.mipFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
        material.diffuse.wrapS = .repeat
        material.cullMode = .front

        let sphere = SCNSphere(radius: 50)
        sphere.segmentCount = 300
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        
        sphereNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.position = sphereNode.position
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)

        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        
        if (controlMethod == .Touch) {
            let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panRec:)))
            sceneView.addGestureRecognizer(panGestureRec)
        }
        else {
            guard motionManger.isAccelerometerAvailable else {return}
            motionManger.deviceMotionUpdateInterval = 0.01
            motionManger.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {[unowned self] (motionData, error) in
                if let motionData = motionData {
                    self.cameraNode.orientation = motionData.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
                }
                else {
                    print("\(error?.localizedDescription)")
                    self.motionManger.stopGyroUpdates()
                }
            })
            
        }
    }
    
    @objc private func handlePan(panRec: UIPanGestureRecognizer) {
        if (panRec.state == .began) {
            prevLocation = CGPoint.zero
        }
        else if (panRec.state == .changed) {
            let location = panRec.translation(in: sceneView)
            let orientation = cameraNode.eulerAngles
            let newOrientation = SCNVector3Make(orientation.x + Float(location.y - prevLocation.y) * 0.005,
                                                orientation.y + Float(location.x - prevLocation.x) * 0.005,
                                                orientation.z)
            
            cameraNode.eulerAngles = newOrientation
            prevLocation = location
        }
    }
    
    deinit {
        if (motionManger.isGyroActive) {
            motionManger.stopGyroUpdates()
        }
    }
    
}

extension CMDeviceMotion {
    
    func gaze(atOrientation orientation: UIInterfaceOrientation) -> SCNVector4 {
        
        let attitude = self.attitude.quaternion
        let aq = GLKQuaternionMake(Float(attitude.x), Float(attitude.y), Float(attitude.z), Float(attitude.w))
        
        var final: SCNVector4
        
        switch UIApplication.shared.statusBarOrientation {
            
        case .landscapeRight:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(M_PI_2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: -q.y, y: q.x, z: q.z, w: q.w)
            
        case .landscapeLeft:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-M_PI_2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: q.y, y: -q.x, z: q.z, w: q.w)
            
        case .portraitUpsideDown:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(M_PI_2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: -q.x, y: -q.y, z: q.z, w: q.w)
            
        case .unknown:
            
            fallthrough
            
        case .portrait:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-M_PI_2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        
        return final
    }
}
