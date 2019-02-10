//
//  UIImage+Drawing.swift
//  Splittery
//
//  Created by Maxim Bystrov on 09/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit
import Vision

extension UIImage {
    
    func draw(textObservations: [VNTextObservation]) -> UIImage {
        let boundingRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        return draw(boundingRect:boundingRect, textObservations:textObservations)
    }
    
    func draw(boundingRect: CGRect, textObservations: [VNTextObservation]) -> UIImage {
        guard textObservations.count > 0 else { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = self.size.width * boundingRect.size.width
        let rectHeight = self.size.height * boundingRect.size.height
        
        //draw image
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)
        
        //draw bound rect
        var fillColor = UIColor.green
        fillColor.setFill()
        context.addRect(CGRect(x: boundingRect.origin.x * self.size.width, y:boundingRect.origin.y * self.size.height, width: rectWidth, height: rectHeight))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        //draw overlay
        fillColor = UIColor.green
        fillColor.setStroke()
        context.setLineWidth(4.0)
        for textObservation in textObservations {
            var points: [CGPoint] = []
            points.append(textObservation.topLeft)
            points.append(textObservation.topRight)
            points.append(textObservation.bottomRight)
            points.append(textObservation.bottomLeft)
            points.append(textObservation.topLeft)
            let mappedPoints = points.map { CGPoint(x: boundingRect.origin.x * self.size.width + $0.x * rectWidth, y: boundingRect.origin.y * self.size.height + $0.y * rectHeight) }
            context.addLines(between: mappedPoints)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
    }
}
