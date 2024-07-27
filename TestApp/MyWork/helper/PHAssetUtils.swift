//
//  PHAssetUtils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/25.
//

import Foundation
import Photos

// 获取PHAsset并保存到沙盒
func saveAssetToSandbox(asset: PHAsset, completion: @escaping (URL?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true

    if asset.mediaType == .image {
        // 请求图像数据
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            // 保存图像数据到沙盒
            if let url = saveToSandbox(data: data, fileExtension: "jpg") {
                completion(url)
            } else {
                completion(nil)
            }
        }
    } else if asset.mediaType == .video {
        // 请求视频数据
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let urlAsset = avAsset as? AVURLAsset else {
                completion(nil)
                return
            }
            // 读取视频数据
            do {
                let data = try Data(contentsOf: urlAsset.url)
                // 保存视频数据到沙盒
                if let url = saveToSandbox(data: data, fileExtension: "mp4") {
                    completion(url)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }
}

// 将数据保存到沙盒
func saveToSandbox(data: Data, fileExtension: String) -> URL? {
    let fileName = "\(CFAbsoluteTime())" + "." + fileExtension
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving file to sandbox: \(error)")
        return nil
    }
}
