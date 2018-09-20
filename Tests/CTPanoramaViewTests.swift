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
        var panoramaView = CTPanoramaView(frame: CGRect.zero, image: sphericalImage)
        XCTAssert(panoramaView.panoramaType == .spherical)

        panoramaView = CTPanoramaView(frame: CGRect.zero, image: cylindricalImage)
        XCTAssert(panoramaView.panoramaType == .cylindrical)

        panoramaView.image = sphericalImage
        XCTAssert(panoramaView.panoramaType == .spherical)

        panoramaView.image = cylindricalImage
        XCTAssert(panoramaView.panoramaType == .cylindrical)
    }

    func testThatSettingOverlayViewAddsTheViewOnTop() {
        let panoramaView = CTPanoramaView(frame: CGRect.zero, image: sphericalImage)
        let overlayView = UIView()

        panoramaView.overlayView = overlayView
        XCTAssert(overlayView.superview == panoramaView)

        let anotherOverlayView = UIView()

        panoramaView.overlayView = anotherOverlayView
        XCTAssert(overlayView.superview == nil)
        XCTAssert(anotherOverlayView.superview == panoramaView)

        panoramaView.overlayView = nil
        XCTAssert(overlayView.superview == nil)
    }

    func createImage(size: CGSize, scale: CGFloat = 1, orientation: UIImage.Orientation = .up) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        defer {UIGraphicsEndImageContext()}

        let image = UIGraphicsGetImageFromCurrentImageContext()
        return UIImage(cgImage: (image?.cgImage)!, scale: scale, orientation: orientation)
    }
}
