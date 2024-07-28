//
//  FilterSubviewDataFetch.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import UIKit
import JXSegmentedView

class FilterSubviewDataFetch: NSObject, SubViewDataFetchProtocol {
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?
    var packageService: PackageService?
    weak var subviewService: SubviewService?
    func fetchData() {
        subviewService?.willData()
        didFetchSuccess?()
        subviewService?.didDataSuccess(packageSubviewSource: self)
    }
    
    func titles() -> [String] {
        return ["filter"]
    }
    
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/videofx"
        var asset = DataSource(assetDir, typeString: "videofx")
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
