//
//  FilterAssetGetter.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/2.
//

import Foundation

class FilterAssetGetter: NSObject, AssetGetter {
    let filterDir = Bundle.main.bundlePath + "/videofx"
    func didLoadAsset(_ block: ([DataSourceItem]) -> Void) {
        let fm = FileManager.default
        var array = [DataSourceItem]()
        fm.subpaths(atPath: filterDir)?.forEach({ name in
            if name.hasSuffix("videofx") {
                var item = DataSourceItem()
                item.packagePath = filterDir + "/" + name                
                item.imagePath = filterDir + "/" + name.split(separator: ".").first! as String + ".png"
                array.append(item)
            }
        })
        block(array)
    }
    
    
}

