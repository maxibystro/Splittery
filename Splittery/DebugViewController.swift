//
//  ViewController.swift
//  Splittery
//
//  Created by Maxim Bystrov on 02/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rotationIconView: UIImageView!
    
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
        rotationIconView.tintColor = .gray
        BillRecognizer.fixHorizon(image: image, completion: { (fixedImage) in
            if let fixedImage = fixedImage {
                self.rotationIconView.tintColor = .green
                self.imageView.image = fixedImage
            } else {
                self.rotationIconView.tintColor = .red
            }
            self.recognizeTextRects(image: fixedImage ?? image)
        })
    }
    
    private func recognizeTextRects(image: UIImage) {
        BillRecognizer.findText(image: image) { textObservations in
            if let textObservations = textObservations {
                self.imageView.image = image.draw(textObservations: textObservations)
            }
        }
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
