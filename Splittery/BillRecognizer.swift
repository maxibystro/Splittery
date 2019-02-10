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

protocol BillRecognizerDelegate: class {
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteFirstRotationWithSuccess success: Bool, rotatedImage: UIImage?)
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteFirstTextRecognitionWithObservations observations: [VNTextObservation], debugImage: UIImage?)
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteSecondRotationWithSuccess success: Bool, rotatedImage: UIImage?)
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteSecondTextRecognitionWithObservations observations: [VNTextObservation], debugImage: UIImage?)
}

class BillRecognizer {
    
    weak var delegate: BillRecognizerDelegate?
    var debug = false
    
    var isRecognizing: Bool {
        return completion != nil
    }
    
    private var completion: (([String]) -> Void)?
    
    func recognize(image: UIImage, completion: @escaping ([String]) -> Void) {
        guard !isRecognizing else { fatalError("BillRecognizer is busy") }
        self.completion = completion
        DispatchQueue.global().async {
            self.makeFirstRotation(image: image)
        }
    }
    
    private func makeFirstRotation(image: UIImage) {
        let fixedImage = BillRecognizer.fixHorizon(image: image)
        let success = fixedImage != nil
        DispatchQueue.main.async {
            self.delegate?.billRecognizer(self, didCompleteFirstRotationWithSuccess: success, rotatedImage: fixedImage)
        }
        makeFirstTextRecognition(image: fixedImage ?? image, rotationSucceeded: success)
    }
    
    private func makeFirstTextRecognition(image: UIImage, rotationSucceeded: Bool) {
        let observations = BillRecognizer.findText(image: image)
        DispatchQueue.main.async {
            let debugImage = self.debug ? image.draw(textObservations: observations) : nil
            self.delegate?.billRecognizer(self, didCompleteFirstTextRecognitionWithObservations: observations, debugImage: debugImage)
        }
        if rotationSucceeded {
            recognizeTextObservations(image: image, observations: observations)
        } else {
            makeSecongRotation(image: image, observations: observations)
        }
    }
    
    private func makeSecongRotation(image: UIImage, observations: [VNTextObservation]) {
        let fixedImage = BillRecognizer.fixHorizon(image: image, basedOnTextObservations: observations)
        let success = fixedImage != nil
        DispatchQueue.main.async {
            self.delegate?.billRecognizer(self, didCompleteSecondRotationWithSuccess: success, rotatedImage: fixedImage)
        }
        makeSecondTextRecognition(image: fixedImage ?? image)
    }
    
    private func makeSecondTextRecognition(image: UIImage) {
        let observations = BillRecognizer.findText(image: image)
        DispatchQueue.main.async {
            let debugImage = self.debug ? image.draw(textObservations: observations) : nil
            self.delegate?.billRecognizer(self, didCompleteSecondTextRecognitionWithObservations: observations, debugImage: debugImage)
        }
        recognizeTextObservations(image: image, observations: observations)
    }
    
    private func recognizeTextObservations(image: UIImage, observations: [VNTextObservation]) {
        DispatchQueue.main.async {
            let result = [String]()
            self.completion?(result)
            self.completion = nil
        }
    }
    
    // MARK: - Pure functions
    
    static func fixHorizon(image: UIImage) -> UIImage? {
        var result: UIImage?
        let request = VNDetectHorizonRequest { (request, error) in
            guard let observations = request.results as? [VNHorizonObservation], let observation = observations.first else {
                return
            }
            result = image.rotate(radians: -observation.angle)
        }
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? requestHandler.perform([request])
        return result
    }
    
    static func fixHorizon(image: UIImage, basedOnTextObservations observations: [VNTextObservation]) -> UIImage? {
        var sumLength: CGFloat = 0
        var sumAngle: CGFloat = 0
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        observations.forEach({ (observation) in
            let bottomLeft = observation.bottomLeft.toAbsoluteCoordinates(width: imageWidth, height: imageHeight)
            let bottomRight = observation.bottomRight.toAbsoluteCoordinates(width: imageWidth, height: imageHeight)
            let length = hypot(bottomLeft.x - bottomRight.x, bottomLeft.y - bottomRight.y)
            sumLength += CGFloat(length)
            let angle = atan2(bottomRight.y - bottomLeft.y, bottomRight.x - bottomLeft.x)
            sumAngle += angle * length
        })
        guard sumLength > 0 else { return nil }
        return image.rotate(radians: sumAngle / sumLength)
    }
    
    static func findText(image: UIImage) -> [VNTextObservation] {
        var result = [VNTextObservation]()
        let request = VNDetectTextRectanglesRequest { (request, error) in
            guard let observations = request.results as? [VNTextObservation] else {
                return
            }
            result = observations
        }
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? requestHandler.perform([request])
        return result
    }
    
}

private extension CGPoint {
    
    func toAbsoluteCoordinates(width: CGFloat, height: CGFloat) -> CGPoint {
        return CGPoint(x: x * width, y: y * height)
    }
}
