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
    @IBOutlet weak var panoramaView: CTPanoramaView!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSphericalImage()
        panoramaView.compass = compassView
    }

    @IBAction func panoramaTypeTapped() {
        if panoramaView.panoramaType == .spherical {
            loadCylindricalImage()
        } else {
            loadSphericalImage()
        }
    }

    @IBAction func motionTypeTapped() {
        if panoramaView.controlMethod == .touch {
            panoramaView.controlMethod = .motion
        } else {
            panoramaView.controlMethod = .touch
        }
    }

    func loadSphericalImage() {
        panoramaView.image = UIImage(named: "spherical")
    }

    func loadCylindricalImage() {
        panoramaView.image = UIImage(named: "cylindrical")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
