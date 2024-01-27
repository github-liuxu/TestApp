//
//  ViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/3.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func editClick(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if (status == .authorized || status == .limited) {
                DispatchQueue.main.async {
                    let filter = PHPickerFilter.any(of: [PHPickerFilter.videos, PHPickerFilter.images])
                    self.presentPicker(filter: filter)                    
                }
            }
        }
    }
    
    private func presentPicker(filter: PHPickerFilter) {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = filter
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var array = [String]()
        results.forEach { result in
            array.append(result.assetIdentifier!)
        }
        let edit = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        edit.localIdentifies = array
        navigationController?.pushViewController(edit, animated: true)
        
    }
}
