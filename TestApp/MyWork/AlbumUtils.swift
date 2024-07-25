//
//  AlbumUtils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import Foundation
import Photos
import LDXImagePicker

protocol OpenAlbumEnable {
    func openAlbum(viewController: UIViewController, _ block: @escaping ([PHAsset])->());
}

class AlbumUtils: NSObject {
    var selectAssetBlock: (([PHAsset]) -> ())? = nil
    var viewController: UIViewController?
    deinit {
        print("AlbumUtils deinit")
    }
}

extension AlbumUtils: OpenAlbumEnable {
    func openAlbum(viewController: UIViewController, _ block: @escaping ([PHAsset])->()) {
        openAlbum(viewController: viewController, mediaType: .any, multiSelect: true, block)
    }
    
    func openAlbum(viewController: UIViewController, mediaType: LDXImagePickerMediaType = .any, multiSelect: Bool = true, _ block: @escaping ([PHAsset])->()) {
        self.viewController = viewController;
        selectAssetBlock = block
        let picker = LDXImagePickerController()
        picker.delegate = self
        picker.mediaType = mediaType
        picker.allowsMultipleSelection = multiSelect
        picker.showsNumberOfSelectedAssets = true
        picker.numberOfColumnsInPortrait = 3
        picker.modalPresentationStyle = .fullScreen
        viewController.present(picker, animated: true)
    }
    
}

extension AlbumUtils: LDXImagePickerControllerDelegate {
    func ldx_imagePickerController(_ imagePickerController: LDXImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        self.viewController?.dismiss(animated: true)
        self.selectAssetBlock?(assets as! [PHAsset])
    }
    
    func ldx_imagePickerControllerDidCancel(_ imagePickerController: LDXImagePickerController!) {
        self.viewController?.dismiss(animated: true)
    }
}
