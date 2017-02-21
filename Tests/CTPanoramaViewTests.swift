//
//  CTPanoramaViewTests.swift
//  CTPanoramaViewTests
//
//  Created by Cihan Tek on 15/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

import XCTest
@testable import CTPanoramaView

class CTPanoramaViewTests: XCTestCase {

    private var sphericalImage: UIImage!
    private var cylindricalImage: UIImage!
    
    override func setUp() {
        super.setUp()
        sphericalImage = createImage(size: CGSize(width: 100, height: 50))
        cylindricalImage = createImage(size: CGSize(width: 200, height: 50))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatPanoramaTypeChangesAccordingToImage() {
        var pv = CTPanoramaView(frame: CGRect.zero, image: sphericalImage)
        XCTAssert(pv.panoramaType == .spherical)
        
        pv = CTPanoramaView(frame: CGRect.zero, image: cylindricalImage)
        XCTAssert(pv.panoramaType == .cylindrical)
        
        pv.image = sphericalImage
        XCTAssert(pv.panoramaType == .spherical)
        
        pv.image = cylindricalImage
        XCTAssert(pv.panoramaType == .cylindrical)
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
    
    func createImage(size: CGSize, scale: CGFloat = 1, orientation: UIImageOrientation = .up) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        defer {UIGraphicsEndImageContext()}
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return UIImage(cgImage: (image?.cgImage)!, scale: scale, orientation: orientation)
    }
}
