//
//  CTPieSliceView.swift
//  CTPanoramaView
//
//  Created by Cihan Tek on 15/10/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

@IBDesignable @objcMembers public class CTPieSliceView: UIView {
    
    @IBInspectable var sliceAngle: CGFloat = .pi/2 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var sliceColor: UIColor = .red {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var outerRingColor: UIColor = .green {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var bgColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    #if !TARGET_INTERFACE_BUILDER
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    #endif
    
    func commonInit() {
        backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // Draw the background
        ctx.addEllipse(in: bounds)
        ctx.setFillColor(bgColor.cgColor)
        ctx.fillPath()
        
        // Draw the outer ring
        ctx.addEllipse(in: bounds.insetBy(dx: 2, dy: 2))
        ctx.setStrokeColor(outerRingColor.cgColor)
        ctx.setLineWidth(2)
        ctx.strokePath()
        
        let radius = (bounds.width/2)-6
        let localCenter = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        let startAngle = -(.pi/2 + sliceAngle/2)
        let endAngle = startAngle + sliceAngle
        let arcStartPoint = CGPoint(x: localCenter.x + radius*cos(startAngle), y: localCenter.y + radius*sin(startAngle))
        
        // Draw the inner slice
        ctx.beginPath()
        ctx.move(to: localCenter)
        ctx.addLine(to: arcStartPoint)
        ctx.addArc(center: localCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        ctx.closePath()
        ctx.setFillColor(sliceColor.cgColor)
        ctx.fillPath()
    }
}

extension CTPieSliceView: CTPanoramaCompass {
    public func updateUI(rotationAngle: CGFloat, fieldOfViewAngle: CGFloat) {
        sliceAngle = fieldOfViewAngle
        transform = CGAffineTransform.identity.rotated(by: rotationAngle)
    }
}
