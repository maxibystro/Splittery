//
//  BillRecognizer.swift
//  Splittery
//
//  Created by Maxim Bystrov on 03/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import Foundation
import UIKit
import Vision

class BillRecognizer {
    
    static func recognize(image: UIImage) -> [String] {
        return []
    }
    
    static func fixHorizon(image: UIImage, completion: @escaping ((UIImage?) -> Void)) {
        let request = VNDetectHorizonRequest { (request, error) in
            guard let observations = request.results as? [VNHorizonObservation], let observation = observations.first else {
                completion(nil)
                return
            }
            let result = image.rotate(radians: -observation.angle)
            completion(result)
        }
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? requestHandler.perform([request])
    }
    
    static func findText(image: UIImage, completion: @escaping ((UIImage?) -> Void)) {
        let request = VNDetectTextRectanglesRequest { (request, error) in
            guard let observations = request.results as? [VNTextObservation] else {
                completion(nil)
                return
            }
            
            completion(nil)
        }
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? requestHandler.perform([request])
    }
    
}

private extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
