//
//  ViewController.swift
//  CTPanoramaController
//
//  Created by Cihan Tek on 12/10/2016.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var pc: CTPanoramaController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            pc = segue.destination as? CTPanoramaController
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let image = UIImage(named: "normal.jpg")
        pc?.image = image
        
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {[unowned self] in
            self.pc?.image = UIImage(named: "spherical.png")
        }
        
        /*
        let p = CTPanoramaController(image: image!)
        
        self.addChildViewController(p)
        view.addSubview(p.view)
        p.view.frame = view.bounds
        
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            p.image = UIImage(named: "spherical.png")
        }
 */
    }
    
    @IBAction func buttonTapped() {
        if pc!.controlMethod == .Touch {
            pc!.controlMethod = .Motion
        }
        else {
            pc!.controlMethod = .Touch
        }
    }
}
