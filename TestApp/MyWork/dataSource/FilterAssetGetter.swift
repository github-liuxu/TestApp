//
//  FilterAssetGetter.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/2.
//

import Foundation

class FilterAssetGetter: DataSource {
    
    override init() {
        let filterDir = Bundle.main.bundlePath + "/videofx"
        super.init(filterDir)
    }
    
}

