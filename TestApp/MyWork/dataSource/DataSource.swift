//
//  DataSource.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

protocol DataSourceService {
    var assetGetter: AssetGetter? { get set }
}

protocol DataSourceItemProtocol {
    var bultinName: String { get set }
    var packagePath: String { get set }
    var licPath: String { get set }
    var imagePath: String { get set }
    var name: String { get set }
    var type: String { get set }
}

protocol AssetGetter {
    init(_ assetDir: String, typeString: String)
    var dataSource: [DataSourceItemProtocol] { get set }
    mutating func fetchData()
    var didFetchSuccess: ((_ dataSource: [DataSourceItemProtocol]) -> Void)? { get set }
    var didFetchError: ((Error) -> Void)? { get set }
}

struct DataSourceItem: DataSourceItemProtocol {
    var bultinName = ""
    var packagePath = ""
    var licPath = ""
    var imagePath = ""
    var name = ""
    var type = ""
}

struct DataSource: AssetGetter {
    var didFetchError: ((any Error) -> Void)?
    var didFetchSuccess: ((_ dataSource: [DataSourceItemProtocol]) -> Void)?
    var dataSource: [DataSourceItemProtocol]
    var assetDir: String!
    var typeString: String!
    init() {
        assetDir = ""
        typeString = ""
        dataSource = [DataSourceItemProtocol]()
    }
    init(_ assetDir: String, typeString: String) {
        self.assetDir = assetDir
        self.typeString = typeString
        dataSource = [DataSourceItemProtocol]()
    }
    
    mutating func fetchData() {
        dataSource = loadAsset()
        didFetchSuccess?(dataSource)
    }
    
    func loadAsset() -> [DataSourceItemProtocol] {
        return loadAsset(path: assetDir, typeString: typeString)
    }
    
    func loadAsset(path: String, typeString: String) -> [DataSourceItemProtocol] {
        let fm = FileManager.default
        var array = [DataSourceItem]()
        var item = DataSourceItem()
        item.packagePath = ""
        item.imagePath = ""
        item.name = "无"
        item.type = typeString
        array.append(item)
        fm.subpaths(atPath: path)?.forEach({ name in
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
