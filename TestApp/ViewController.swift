//
//  ViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/3.
//

import NvStreamingSdkCore
import PhotosUI
import UIKit
import WebKit

class ViewController: UIViewController {
    let albumUtils = AlbumUtils()
    var palyer: AVAudioPlayer?
    var avplayer: AVPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource: "meishesdk", ofType: "lic")
        let success = NvsStreamingContext.verifySdkLicenseFile(path)
        if success {
            print("success")
        } else {
            print("faild")
        }
//        NvsStreamingContext.sharedInstance(withFlags: NvsStreamingContextFlag_DisableHardwareAudioReader)
        
//        self.palyer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.bundlePath + "/IMG_0022.MOV"))
//        self.palyer?.play()
//        
//        self.avplayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.bundlePath + "/IMG_0022.MOV"))
//        self.avplayer?.play()
        
    }

    @IBAction func editClick(_: Any) {
//        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
//            if (status == .authorized || status == .limited) {
//                DispatchQueue.main.async {
//                    let filter = PHPickerFilter.any(of: [PHPickerFilter.videos, PHPickerFilter.images])
//                    self.presentPicker(filter: filter)
//                }
//            }
//        }
        albumUtils.openAlbum(viewController: self) { [weak self] assets in
            var array = [String]()
            for phasset in assets {
                array.append(phasset.localIdentifier)
            }
            let edit = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
            edit.localIdentifies = array
            edit.albumUtils = self?.albumUtils
            self?.navigationController?.pushViewController(edit, animated: true)
        }
    }

//    private func presentPicker(filter: PHPickerFilter) {
//        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
//        configuration.filter = filter
//        configuration.selectionLimit = 0
//
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        present(picker, animated: true)
//    }
}

// extension ViewController: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        var array = [String]()
//        results.forEach { result in
//            array.append(result.assetIdentifier!)
//        }
//        let edit = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
//        edit.localIdentifies = array
//        navigationController?.pushViewController(edit, animated: true)
//
//    }
// }
