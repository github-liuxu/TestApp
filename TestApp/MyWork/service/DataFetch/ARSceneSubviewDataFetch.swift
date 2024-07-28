//
//  ARSceneSubviewDataFetch.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import UIKit
import JXSegmentedView

class ARSceneSubviewDataFetch: NSObject, SubViewDataFetchProtocol {
    var packageService: PackageService?
    weak var subviewService: SubviewService?
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?
    
    func fetchData() {
        subviewService?.willData()
        didFetchSuccess?()
        subviewService?.didDataSuccess(packageSubviewSource: self)
    }
    
    func titles() -> [String] {
        return ["2D", "3D"]
    }
    
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/arscene"
        var asset: DataSource!
        if index == 0 {
            asset = DataSource(assetDir + "/2D", typeString: "arscene")
        } else if index == 1 {
            asset = DataSource(assetDir + "/3D", typeString: "arscene")
        }
        asset.didFetchSuccess = { dataSource in
            list.dataSource = dataSource
        }
        asset.didFetchError = { error in
            
        }
        asset.fetchData()
        list.didSelectedPackage = { [weak self] item in
            self?.packageService?.applyPackage(item: item)
        }
        return list
    }
}
