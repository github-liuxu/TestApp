//
//  CompoundCaption.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/20.
//

import Foundation


class CompoundCaptionGetter: DataSource {
    
    override init() {
        let filterDir = Bundle.main.bundlePath + "/compoundcaption"
        super.init(filterDir)
    }
    
}
