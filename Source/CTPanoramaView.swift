//
//  CTPanoramaView
//  CTPanoramaView
//
//  Created by Cihan Tek on 11/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import ImageIO

/**
 * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
fileprivate func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

@objc public protocol CTPanoramaCompass {
    func updateUI(rotationAngle: CGFloat, fieldOfViewAngle: CGFloat)
}

@objc public enum CTPanoramaControlMethod: Int {
    case motion
    case touch
    case combo // FIXME: Currently combo type is only supported for Cylindrical Panoramas

    public var description : String {
        switch self {
        case .motion: return "motion"
        case .touch: return "touch"
        case .combo: return "combo"
        }
    }
}

@objc public enum CTPanoramaType: Int {
    case cylindrical
    case spherical

    public var description : String {
        switch self {
        case .cylindrical: return "cylindrical"
        case .spherical: return "spherical"
        }
    }
}

@objc public class CTPanoramaView: UIView {
    
    // MARK: Public properties
    
    public var panSpeed = CGPoint(x: 0.005, y: 0.005)
    
    public var image: UIImage? {
        didSet {
            panoramaType = panoramaTypeForCurrentImage
        }
    }
    
    public var overlayView: UIView? {
        didSet {
            replace(overlayView: oldValue, with: overlayView)
        }
    }
    
    public var panoramaType: CTPanoramaType = .cylindrical {
        didSet {
            createGeometryNode()
            resetCameraAngles()
        }
    }
    
    public var controlMethod: CTPanoramaControlMethod! {
        didSet {
            switchControlMethod(to: controlMethod!)
            resetCameraAngles()
        }
    }
    
    public var compass: CTPanoramaCompass?
    public var movementHandler: ((_ rotationAngle: CGFloat, _ fieldOfViewAngle: CGFloat) -> ())?
    
    // MARK: Private properties
    
    private let radius: CGFloat = 10
    private let sceneView = SCNView()
    private let scene = SCNScene()
    private let motionManager = CMMotionManager()
    private var geometryNode: SCNNode?
    private var prevLocation = CGPoint.zero
    private var prevBounds = CGRect.zero

    var panningVector = SCNVector3Make(0,100,0)
    var headingVector = SCNVector3Make(0,Float(-1.0 * .pi / 2.0),0)

    private lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        let camera = SCNCamera()
        camera.yFov = 70
        node.camera = camera
        return node
    }()
    
    private lazy var fovHeight: CGFloat = {
        return CGFloat(tan(self.cameraNode.camera!.yFov/2 * .pi / 180.0)) * 2 * self.radius
    }()
    
    private var xFov: CGFloat {
        return CGFloat(self.cameraNode.camera!.yFov) * self.bounds.width / self.bounds.height
    }
    
    private var panoramaTypeForCurrentImage: CTPanoramaType {
        if let image = image {
            if image.size.width / image.size.height == 2 {
                return .spherical
            }
        }
        return .cylindrical
    }
    
    // MARK: Class lifecycle methods
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        ({self.image = image})() // Force Swift to call the property observer by calling the setter from a non-init context
    }
    
    deinit {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func commonInit() {
        add(view: sceneView)
    
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        
        if controlMethod == nil {
            controlMethod = .touch
        }
     }
    
    // MARK: Configuration helper methods

    private func createGeometryNode() {
        guard let image = image else {return}
        
        geometryNode?.removeFromParentNode()
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.diffuse.mipFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
        material.diffuse.wrapS = .repeat
        material.cullMode = .front
        
        if panoramaType == .spherical {
            let sphere = SCNSphere(radius: radius)
            sphere.segmentCount = 300
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode()
            sphereNode.geometry = sphere
            geometryNode = sphereNode
        }
        else {
            let tube = SCNTube(innerRadius: radius, outerRadius: radius, height: fovHeight)
            tube.heightSegmentCount = 50
            tube.radialSegmentCount = 300
            tube.firstMaterial = material
            
            let tubeNode = SCNNode()
            tubeNode.geometry = tube
            geometryNode = tubeNode
        }
        scene.rootNode.addChildNode(geometryNode!)
    }
    
    private func replace(overlayView: UIView?, with newOverlayView: UIView?) {
        overlayView?.removeFromSuperview()
        guard let newOverlayView = newOverlayView else {return}
        add(view: newOverlayView)
    }
    
    private func switchControlMethod(to method: CTPanoramaControlMethod) {
        sceneView.gestureRecognizers?.removeAll()

        if method == .touch || method == .combo {
                let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panRec:)))
                sceneView.addGestureRecognizer(panGestureRec)
 
            if motionManager.isDeviceMotionActive && method != .combo {
                motionManager.stopDeviceMotionUpdates()
            }
        }
        if method == .motion || method == .combo {
            guard motionManager.isDeviceMotionAvailable else {return}
            motionManager.deviceMotionUpdateInterval = 0.015
            motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue.main, withHandler: {[weak self] (motionData, error) in
                guard let panoramaView = self else {return}
                guard panoramaView.controlMethod == .motion || panoramaView.controlMethod == .combo else {return}
                
                guard let motionData = motionData else {
                    print("\(error?.localizedDescription)")
                    panoramaView.motionManager.stopDeviceMotionUpdates()
                    return
                }
                
                let rm = motionData.attitude.rotationMatrix
                var userHeading = .pi - atan2(rm.m32, rm.m31)
                userHeading += .pi/2

                panoramaView.headingVector = SCNVector3Make(
                    0 ,
                    Float(-userHeading) ,
                    0)

                if panoramaView.panoramaType == .cylindrical {
                    panoramaView.cameraNode.eulerAngles = panoramaView.headingVector
                        + panoramaView.panningVector
                }
                else {
                    // Use quaternions when in spherical mode to prevent gimbal lock
                    panoramaView.cameraNode.orientation = motionData.orientation()
                }
                panoramaView.reportMovement(CGFloat(userHeading), panoramaView.xFov.toRadians())
            })
        }
    }
    
    private func resetCameraAngles() {
        cameraNode.eulerAngles = SCNVector3Make(0, 0, 0)
        panningVector = SCNVector3Make(0,100,0)
        headingVector = SCNVector3Make(0,Float(-1.0 * .pi / 2.0),0)

        self.reportMovement(0, xFov.toRadians(), callHandler: false)
    }
    
    private func reportMovement(_ rotationAngle: CGFloat, _ fieldOfViewAngle: CGFloat, callHandler: Bool = true) {
        compass?.updateUI(rotationAngle: rotationAngle, fieldOfViewAngle: fieldOfViewAngle)
        if callHandler {
            movementHandler?(rotationAngle, fieldOfViewAngle)
        }
    }
    
    // MARK: Gesture handling
    
    @objc private func handlePan(panRec: UIPanGestureRecognizer) {
        if controlMethod == .combo && panoramaType == .spherical {
            // FIXME combo control method not supported in spherical panoramas at this time
            return
        }

        if panRec.state == .began {
            prevLocation = CGPoint.zero
        }
        else if panRec.state == .changed {
            var modifiedPanSpeed = panSpeed
            
            if panoramaType == .cylindrical {
                modifiedPanSpeed.y = 0 // Prevent vertical movement in a cylindrical panorama
            }
            
            let location = panRec.translation(in: sceneView)
            // let orientation = cameraNode.eulerAngles

            panningVector = panningVector + SCNVector3Make(
                Float(location.y - prevLocation.y) * Float(modifiedPanSpeed.y),
                Float(location.x - prevLocation.x) * Float(modifiedPanSpeed.x),
                0)

            var newOrientation = panningVector + headingVector
            if controlMethod == .touch {
                newOrientation.x = max(min(newOrientation.x, 1.1),-1.1)
            }

            cameraNode.eulerAngles = newOrientation
            prevLocation = location
            
            reportMovement(CGFloat(-cameraNode.eulerAngles.y), xFov.toRadians())
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size.width != prevBounds.size.width || bounds.size.height != prevBounds.size.height {
            sceneView.setNeedsDisplay()
            reportMovement(CGFloat(-cameraNode.eulerAngles.y), xFov.toRadians(), callHandler: false)
        }
    }
}

fileprivate extension CMDeviceMotion {
    
        func orientation() -> SCNVector4 {
        
        let attitude = self.attitude.quaternion
        let aq = GLKQuaternionMake(Float(attitude.x), Float(attitude.y), Float(attitude.z), Float(attitude.w))
        
        var result: SCNVector4
        
        switch UIApplication.shared.statusBarOrientation {
            
        case .landscapeRight:
            let cq1 = GLKQuaternionMakeWithAngleAndAxis(.pi/2, 0, 1, 0)
            let cq2 = GLKQuaternionMakeWithAngleAndAxis(-(.pi/2), 1, 0, 0)
            var q = GLKQuaternionMultiply(cq1, aq)
            q = GLKQuaternionMultiply(cq2, q)
            
            result = SCNVector4(x: -q.y, y: q.x, z: q.z, w: q.w)
            
        case .landscapeLeft:
            let cq1 = GLKQuaternionMakeWithAngleAndAxis(-(.pi/2), 0, 1, 0)
            let cq2 = GLKQuaternionMakeWithAngleAndAxis(-(.pi/2), 1, 0, 0)
            var q = GLKQuaternionMultiply(cq1, aq)
            q = GLKQuaternionMultiply(cq2, q)
            
            result = SCNVector4(x: q.y, y: -q.x, z: q.z, w: q.w)
            
        case .portraitUpsideDown:
            let cq1 = GLKQuaternionMakeWithAngleAndAxis(-(.pi/2), 1, 0, 0)
            let cq2 = GLKQuaternionMakeWithAngleAndAxis(.pi, 0, 0, 1)
            var q = GLKQuaternionMultiply(cq1, aq)
            q = GLKQuaternionMultiply(cq2, q)
            
            result = SCNVector4(x: -q.x, y: -q.y, z: q.z, w: q.w)
            
        case .unknown:
            fallthrough
        case .portrait:
            let cq = GLKQuaternionMakeWithAngleAndAxis(-(.pi/2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            result = SCNVector4(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        return result
    }
}

fileprivate extension UIView {
    func add(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
}

fileprivate extension FloatingPoint {
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
    
    func toRadians() -> Self {
        return self * .pi / 180
    }
}
