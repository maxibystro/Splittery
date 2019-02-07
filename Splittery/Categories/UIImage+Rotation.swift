//
//  UIImage+Orientation.swift
//  Splittery
//
//  Created by Maxim Bystrov on 08/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

extension UIImage {
    
    func rotate(radians: CGFloat) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func fixOrientation() -> UIImage {
        if (self.imageOrientation == .up) {
            return self;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (self.imageOrientation == .down || self.imageOrientation == .downMirrored) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        }
        
        if (self.imageOrientation == .left || self.imageOrientation == .leftMirrored) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        }
        
        if (self.imageOrientation == .right || self.imageOrientation == .rightMirrored) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: -.pi / 2);
        }
        
        if (self.imageOrientation == .upMirrored || self.imageOrientation == .downMirrored) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (self.imageOrientation == .leftMirrored || self.imageOrientation == .rightMirrored) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                      bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: self.cgImage!.colorSpace!,
                                      bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        
        if (self.imageOrientation == .left
            || self.imageOrientation == .leftMirrored
            || self.imageOrientation == .right
            || self.imageOrientation == .rightMirrored) {
            ctx.draw(self.cgImage!, in: CGRect(x:0,y:0,width:self.size.height,height:self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x:0,y:0,width:self.size.width,height:self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg: CGImage = ctx.makeImage()!
        return UIImage(cgImage: cgimg)
    }
}
