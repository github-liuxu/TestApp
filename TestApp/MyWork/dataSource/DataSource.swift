//
//  DataSource.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

protocol AssetGetter {
    init(_ assetDir: String, typeString: String)
    func loadAsset() -> [DataSourceItem]
    func loadAsset(path: String, typeString: String) -> [DataSourceItem]
}

struct DataSourceItem {
    var bultinName = ""
    var packagePath = ""
    var licPath = ""
    var imagePath = ""
    var name = ""
    var type = ""
}

struct DataSource: AssetGetter {
    var assetDir: String!
    var typeString: String!
    init() {
        assetDir = ""
        typeString = ""
    }
    init(_ assetDir: String, typeString: String) {
        self.assetDir = assetDir
        self.typeString = typeString
    }
    
    func loadAsset() -> [DataSourceItem] {
        return loadAsset(path: assetDir, typeString: typeString)
    }
    
    func loadAsset(path: String, typeString: String) -> [DataSourceItem] {
        let fm = FileManager.default
        var array = [DataSourceItem]()
        var item = DataSourceItem()
        item.packagePath = ""
        item.imagePath = ""
        item.name = "无"
        item.type = typeString
        array.append(item)
        guard let assetDir = assetDir else { return [] }
        fm.subpaths(atPath: assetDir)?.forEach({ name in
            if name.hasSuffix(typeString) {
                var item = DataSourceItem()
                item.type = typeString
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
        return array
    }
}
