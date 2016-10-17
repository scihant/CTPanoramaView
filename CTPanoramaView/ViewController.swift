//
//  ViewController.swift
//  CTPanoramaView
//
//  Created by Cihan Tek on 12/10/2016.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var compassView: CTPieSliceView!
    @IBOutlet weak var pv: CTPanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "spherical.png")
        pv.image = image
        pv.controlMethod = .Motion
        
        /*
        let deadlineTime = DispatchTime.now() + .seconds(0)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {[unowned self] in
            self.pv.image = UIImage(named: "spherical.png")
        }
        */
        pv.radar = compassView
    }
    
    @IBAction func panoramaTypeTapped() {
        if pv.panaromaType == .Spherical {
            pv.image = UIImage(named: "cylindrical.jpg")
        }
        else {
            pv.image = UIImage(named: "spherical.png")
        }
    }
    
    @IBAction func motionTypeTapped() {
        if pv.controlMethod == .Touch {
            pv.controlMethod = .Motion
        }
        else {
            pv.controlMethod = .Touch
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
