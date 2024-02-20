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
    var bultinName = ""
    var packagePath = ""
    var licPath = ""
    var imagePath = ""
    var name = ""
}

class DataSource: NSObject {
    var assetDir: String?
    override init() {
        fatalError("init method error!")
    }
    init(_ assetDir: String) {
        self.assetDir = assetDir;
        super.init()
    }
}

extension DataSource: AssetGetter {
    func didLoadAsset(_ block: ([DataSourceItem]) -> Void) {
        let fm = FileManager.default
        var array = [DataSourceItem]()
        var item = DataSourceItem()
        item.packagePath = ""
        item.imagePath = ""
        item.name = "无"
        array.append(item)
        guard let assetDir = assetDir else { return block([]) }
        fm.subpaths(atPath: assetDir)?.forEach({ name in
            if name.hasSuffix((assetDir as NSString).lastPathComponent) {
                var item = DataSourceItem()
                item.packagePath = assetDir + "/" + name
                item.imagePath = assetDir + "/" + name.split(separator: ".").first! as String + ".png"
                if !fm.fileExists(atPath: item.imagePath) {
                    item.imagePath = assetDir + "/" + name.split(separator: ".").first! as String + ".jpg"
                }
                if !fm.fileExists(atPath: item.imagePath) {
                    item.imagePath = assetDir + "/" + name.split(separator: ".").first! as String + ".webp"
                }
                if !fm.fileExists(atPath: item.imagePath) {
                    item.imagePath = assetDir + "/" + name.split(separator: ".").first! as String + ".png"
                    print("封面不存在")
                }
                array.append(item)
            }
        })
        block(array)
    }
}
