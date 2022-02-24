//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Zubair Khalid on 23/02/2022.
//

import Vision
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // UI elements
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var button: UIButton!
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .red
        label.textAlignment = .center
        return label
    }()
    
    //Variables
    var imageToProcess: UIImage!
    
    //Loads in the UI Elements
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        
        imageView.backgroundColor = .secondarySystemBackground
        
        button.backgroundColor = .systemBlue
        button.setTitle("Take Picture", for: .normal)
        button.setTitleColor((.white), for: .normal)
    }
    
    //Adds label to main storyboard
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.frame = CGRect(x: 20, y: view.frame.size.width+100, width: view.frame.size.width-40, height: 200)
    }

    //Code for when button is pressed
    // calls function, and sets the source to camera. 'allowsEditing' lets you crop in.
    @IBAction func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }

    // if you cancel taking a photo, the camera closes.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Handles the actual image taking functionality. Just sets the image taken to the imageView, and calls recognizeText function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = image
        
        imageToProcess = image
    
        recognizeText(image: imageToProcess)
    }
  
    
    
    private func recognizeText(image: UIImage?){
        guard let cgImage = imageView.image?.cgImage else {
            fatalError("Could not get CGImage")
        }
        
        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        
        // Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                      return
                  }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            
            DispatchQueue.main.async {
                self?.label.text = text
            }
        }
        
        
        //Process Request
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        
    }

    
}
