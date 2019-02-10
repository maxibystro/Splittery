//
//  ViewController.swift
//  Splittery
//
//  Created by Maxim Bystrov on 02/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit
import Vision

class DebugViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstRotationIcon: UIImageView!
    @IBOutlet weak var secondRotationIcon: UIImageView!
    
    let recognizer = BillRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        recognizer.debug = true
        recognizer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if imageView.image == nil {
            presentImagePickerController()
        }
        super.viewDidAppear(animated)
    }
    
    @IBAction func onScanButton(_ sender: Any) {
        presentImagePickerController()
    }
    
    private func presentImagePickerController() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: false, completion: nil)
    }
    
    private func processImage(_ image: UIImage) {
        imageView.image = image
        firstRotationIcon.tintColor = .gray
        secondRotationIcon.isHidden = true
        recognizer.recognize(image: image, completion: { strings in
            print(strings)
        })
    }
}

extension DebugViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        processImage(image.fixOrientation())
        picker.dismiss(animated: true)
    }
}

extension DebugViewController: BillRecognizerDelegate {
    
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteFirstRotationWithSuccess success: Bool, rotatedImage: UIImage?) {
        firstRotationIcon.tintColor = success ? .green : .red
        if let rotatedImage = rotatedImage {
            imageView.image = rotatedImage
        }
    }
    
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteFirstTextRecognitionWithObservations observations: [VNTextObservation], debugImage: UIImage?) {
        if let debugImage = debugImage {
            imageView.image = debugImage
        }
    }
    
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteSecondRotationWithSuccess success: Bool, rotatedImage: UIImage?) {
        secondRotationIcon.isHidden = false
        secondRotationIcon.tintColor = success ? .green : .red
        if let rotatedImage = rotatedImage {
            imageView.image = rotatedImage
        }
    }
    
    func billRecognizer(_ recognizer: BillRecognizer, didCompleteSecondTextRecognitionWithObservations observations: [VNTextObservation], debugImage: UIImage?) {
        if let debugImage = debugImage {
            imageView.image = debugImage
        }
    }
}
