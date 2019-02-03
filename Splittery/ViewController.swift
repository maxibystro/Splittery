//
//  ViewController.swift
//  Splittery
//
//  Created by Maxim Bystrov on 02/02/2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var captured = false
    
    override func viewDidAppear(_ animated: Bool) {
        if captured == false {
            presentImagePickerController()
        }
        super.viewDidAppear(animated)
    }
    
    private func presentImagePickerController() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: false, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        captured = true
        picker.dismiss(animated: true) {
            BillRecognizer.fixHorizon(image: image, completion: { (fixedImage) in
                self.imageView.image = fixedImage
            })
            let strings = BillRecognizer.recognize(image: image)
            let message = strings.reduce("", { return $0 + $1 + "\n" })
            let alert = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
            self.present(alert, animated: false, completion: nil)
        }
    }
    
}

