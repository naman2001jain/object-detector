//
//  ViewController.swift
//  hotdog detector
//
//  Created by Naman Jain on 27/05/21.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    //outlets
    
    @IBOutlet weak var imageSelectorView: UIView!
    @IBOutlet weak var userSelectedImageView: UIImageView!
    @IBOutlet weak var imageDiscriptionLabel: UILabel!
    @IBOutlet weak var aboutTheImage: UILabel!
    
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageView()
        self.setupCameraView()
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage{
            userSelectedImageView.image = userPickedImage

            guard let ciImage = CIImage(image: userPickedImage) else{
                fatalError("couldn't convert UIImage to CIImage.")
            }
            detect(image: ciImage)

        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    //setup Functions
    @IBAction func selectImageButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true,completion: nil)
    }
    
    func detect(image: CIImage){

        //setup vision with a coreml model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("couldn't load core ml model.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("couldn't request to the model.")
            }
            if let firstResult = results.first{
                self.imageDiscriptionLabel.text = firstResult.identifier
                self.imageDiscriptionLabel.backgroundColor = .green
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    
}

extension ViewController{
    func setupImageView(){
        userSelectedImageView.clipsToBounds = true
        userSelectedImageView.layer.cornerRadius = 10
    }
    func setupCameraView(){
        imageSelectorView.layer.cornerRadius = imageSelectorView.bounds.height/2
    }
    
}
