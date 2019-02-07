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
        let globalQueqeCompletion: ((UIImage?) -> Void) = { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
        DispatchQueue.global().async {
            let request = VNDetectHorizonRequest { (request, error) in
                guard let observations = request.results as? [VNHorizonObservation], let observation = observations.first else {
                    globalQueqeCompletion(nil)
                    return
                }
                let result = image.rotate(radians: -observation.angle)
                globalQueqeCompletion(result)
            }
            let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            try? requestHandler.perform([request])
        }
    }
    
    static func findText(image: UIImage, completion: @escaping (([VNTextObservation]?) -> Void)) {
        let globalQueqeCompletion: (([VNTextObservation]?) -> Void) = { observations in
            DispatchQueue.main.async {
                completion(observations)
            }
        }
        DispatchQueue.global().async {
            let request = VNDetectTextRectanglesRequest { (request, error) in
                guard let observations = request.results as? [VNTextObservation] else {
                    globalQueqeCompletion(nil)
                    return
                }
                globalQueqeCompletion(observations)
            }
            let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            try? requestHandler.perform([request])
        }
    }
    
}
