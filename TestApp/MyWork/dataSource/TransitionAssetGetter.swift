//
//  TransitionAssetGetter.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/20.
//

import Foundation

class TransitionAssetGetter: DataSource {
    
    override init() {
        let videotransitionDir = Bundle.main.bundlePath + "/videotransition"
        super.init(videotransitionDir)
    }
    
}
