//
//  ViewController.swift
//  CTPanoramaView
//
//  Created by Cihan Tek on 12/10/2016.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
import CTPanoramaView

class ViewController: UIViewController {

    @IBOutlet weak var panoTypeButton: UIButton!
    @IBOutlet weak var motionTypeButton: UIButton!
    @IBOutlet weak var compassView: CTPieSliceView!
    @IBOutlet weak var pv: CTPanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCylindricalImage()
        pv.compass = compassView
        pv.controlMethod = .combo
        pv.panoramaType = .cylindrical

        panoTypeButton.setTitle(pv.panoramaType.description, for: .normal)
        motionTypeButton.setTitle(pv.controlMethod.description, for: .normal)
    }
    
    @IBAction func panoramaTypeTapped() {
        if pv.panoramaType == .spherical {
            loadCylindricalImage()
        }
        else {
            loadSphericalImage()
        }

        panoTypeButton.setTitle(pv.panoramaType.description, for: .normal)
    }
    
    @IBAction func motionTypeTapped() {
        if pv.controlMethod == .combo {
            pv.controlMethod = .touch
        }
        else if pv.controlMethod == .touch {
            pv.controlMethod = .motion
        }
        else {
            pv.controlMethod = .combo
        }

        motionTypeButton.setTitle(pv.controlMethod.description, for: .normal)
    }
    
    func loadSphericalImage() {
        pv.image = UIImage(named: "spherical")
    }
    
    func loadCylindricalImage() {
        pv.image = UIImage(named: "cylindrical")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
