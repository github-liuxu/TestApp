//
//  AnimationStickerGetter.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/5/21.
//

import UIKit

class AnimationStickerGetter: DataSource {
    override init() {
        let filterDir = Bundle.main.bundlePath + "/animationSticker"
        super.init(filterDir)
    }
}
