//
//  DataSource.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

protocol AssetGetter {
    func didLoadAsset(_ block: ([DataSourceItem]) -> Void)
}

struct DataSourceItem {
    var packagePath = ""
    var licPath = ""
    var imagePath = ""
    var name = ""
}

class DataSource: NSObject {
    
    override init() {
        super.init()
        loadAsset()
    }
    
    func loadAsset() {
        
    }
}

extension DataSource: AssetGetter {
    func didLoadAsset(_ block: ([DataSourceItem]) -> Void) {
        return block([DataSourceItem()])
    }
}
