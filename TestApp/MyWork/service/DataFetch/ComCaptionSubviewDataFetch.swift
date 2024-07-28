//
//  ComCaptionSubviewDataFetch.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import UIKit
import JXSegmentedView

class ComCaptionSubviewDataFetch: NSObject, SubViewDataFetchProtocol {
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
        ["CompoundCaption"]
    }
    
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/compoundcaption"
        var asset = DataSource(assetDir, typeString: "compoundcaption")
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
