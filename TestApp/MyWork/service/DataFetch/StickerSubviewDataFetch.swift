//
//  StickerSubviewDataFetch.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import UIKit
import JXSegmentedView

class StickerSubviewDataFetch: NSObject, SubViewDataFetchProtocol {
    var packageService: (PackageService & StickerService)?
    weak var subviewService: SubviewService?
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?
    
    func fetchData() {
        subviewService?.willData()
        didFetchSuccess?()
        subviewService?.didDataSuccess(packageSubviewSource: self)
    }

    func titles() -> [String] {
        return ["sticker", "custom"]
    }
    
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/sticker"
        if index == 0 {
            var asset = DataSource(assetDir + "/animationsticker", typeString: "animatedsticker")
            asset.didFetchSuccess = { dataSource in
                list.dataSource = dataSource
            }
            asset.didFetchError = { error in
                
            }
            asset.fetchData()
            list.didSelectedPackage = { [weak self] item in
                self?.packageService?.applyPackage(item: item)
            }
        } else if index == 1 {
            var asset = DataSource(assetDir + "/custom", typeString: "animatedsticker")
            asset.didFetchSuccess = { dataSource in
                list.dataSource = dataSource
            }
            asset.didFetchError = { error in
                
            }
            asset.fetchData()
            list.didSelectedPackage = { [weak self] item in
                // album
                let viewController = list.findViewController()!
                let albumUtils = AlbumUtils()
                albumUtils.openAlbum(viewController: viewController, mediaType: .image, multiSelect: false) { [weak self] assets in
                    viewController.dismiss(animated: true)
                    if assets.count > 0 {
                        let phasset = assets.first!
                        saveAssetToSandbox(asset: phasset) { url in
                            if let path = url?.absoluteString.replacingOccurrences(of: "file://", with: "") {
                                self?.packageService?.applyCustomPackage(item: item, imagePath: path)
                            }
                        }
                    }
                }
            }
        }
        return list
    }
}
