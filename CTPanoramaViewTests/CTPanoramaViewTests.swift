//
//  CTPanoramaViewTests.swift
//  CTPanoramaViewTests
//
//  Created by Cihan Tek on 16/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

import XCTest
@testable import CTPanoramaView

class CTPanoramaViewTests: XCTestCase {
    
     private let sphericalImageName = "spherical"
     private let cylindricalImageName = "cylindrical"
     
     private var sphericalImage: UIImage!
     private var cylindricalImage: UIImage!
    
    override func setUp() {
        super.setUp()
        sphericalImage = UIImage(named: sphericalImageName)
        cylindricalImage = UIImage(named: cylindricalImageName)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatPanoramaTypeChangesAccordingToImage() {
        var pv = CTPanoramaView(frame: CGRect.zero, image: sphericalImage)
        XCTAssert(pv.panoramaType == .Spherical)
        
        pv = CTPanoramaView(frame: CGRect.zero, image: cylindricalImage)
        XCTAssert(pv.panoramaType == .Cylindrical)
        
        pv.image = sphericalImage
        XCTAssert(pv.panoramaType == .Spherical)
        
        pv.image = cylindricalImage
        XCTAssert(pv.panoramaType == .Cylindrical)
    }
    
    func testThatSettingOverlayViewAddsTheViewOnTop() {
        let pv = CTPanoramaView(frame: CGRect.zero, image: sphericalImage)
        let overlayView = UIView()
        
        pv.overlayView = overlayView
        XCTAssert(overlayView.superview == pv)
        
        let anotherOverlayView = UIView()
        
        pv.overlayView = anotherOverlayView
        XCTAssert(overlayView.superview == nil)
        XCTAssert(anotherOverlayView.superview == pv)
        
        pv.overlayView = nil;
        XCTAssert(overlayView.superview == nil)
    }
    
}
