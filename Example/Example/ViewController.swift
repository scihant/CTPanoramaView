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

    @IBOutlet weak var compassView: CTPieSliceView!
    @IBOutlet weak var pv: CTPanoramaView!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSphericalImage()
        pv.compass = compassView
    }

    @IBAction func panoramaTypeTapped() {
        if pv.panoramaType == .spherical {
            loadCylindricalImage()
        } else {
            loadSphericalImage()
        }
    }

    @IBAction func motionTypeTapped() {
        if pv.controlMethod == .touch {
            pv.controlMethod = .motion
        } else {
            pv.controlMethod = .touch
        }
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
