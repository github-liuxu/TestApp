//
//  AlbumUtils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import Foundation
import LDXImagePicker
import Photos

protocol OpenAlbumEnable {
    func openAlbum(viewController: UIViewController, _ block: @escaping ([PHAsset]) -> Void)
}

class AlbumUtils: NSObject {
    var selectAssetBlock: (([PHAsset]) -> Void)? = nil
    var viewController: UIViewController?
    deinit {
        print("AlbumUtils deinit")
    }
}

extension AlbumUtils: OpenAlbumEnable {
    func openAlbum(viewController: UIViewController, _ block: @escaping ([PHAsset]) -> Void) {
        openAlbum(viewController: viewController, mediaType: .any, multiSelect: true, block)
    }

    func openAlbum(viewController: UIViewController, mediaType: LDXImagePickerMediaType = .any, multiSelect: Bool = true, _ block: @escaping ([PHAsset]) -> Void) {
        self.viewController = viewController
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
    func ldx_imagePickerController(_: LDXImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        viewController?.dismiss(animated: true)
        selectAssetBlock?(assets as! [PHAsset])
    }

    func ldx_imagePickerControllerDidCancel(_: LDXImagePickerController!) {
        viewController?.dismiss(animated: true)
    }
}
