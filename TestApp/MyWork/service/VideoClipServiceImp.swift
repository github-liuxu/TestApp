//
//  VideoClipServiceImp.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/26.
//

import NvStreamingSdkCore
import UIKit

protocol VideoClipService {}

class VideoClipServiceImp: NSObject {
    var videoClip: NvsVideoClip?
}

extension VideoClipServiceImp: VideoClipService {}
