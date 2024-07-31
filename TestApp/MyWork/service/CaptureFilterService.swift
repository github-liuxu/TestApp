//
//  CaptureFilterService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import JXSegmentedView
import NvStreamingSdkCore

class CaptureFilterService: NSObject, FilterService {
    var filterFx: NvsCaptureVideoFx?
    var streamingContext = NvsStreamingContext.sharedInstance()!
    override init() {
        super.init()
    }

    func setFilterStrength(value: Float) {
        guard let filterFx = filterFx else { return }
        filterFx.setFilterIntensity(value)
    }

    func getFilterStrength() -> Float {
        return filterFx?.getFilterIntensity() ?? 0
    }

    func applyFilter(packageId: String) {
        let pid = packageId
        if filterFx?.captureVideoFxType == NvsCaptureVideoFxType_Builtin {
            if filterFx?.bultinCaptureVideoFxName == packageId {
                return
            }
        } else {
            if filterFx?.captureVideoFxPackageId == pid as String {
                return
            }
        }

        if let filterFx = filterFx {
            streamingContext.removeCaptureVideoFx(filterFx.index)
            self.filterFx = nil
        }
        if pid.count > 0 {
            filterFx = streamingContext.appendPackagedCaptureVideoFx(pid)
        }
    }

    func applyFilter(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
}

extension CaptureFilterService: PackageService {
    func cancelAction() {}

    func sureAction() {}

    func applyPackage(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
}

extension CaptureFilterService: PackageSubviewSource {
    func titles() -> [String] {
        return ["filter"]
    }

    func customView(index _: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/videofx"
        var asset = DataSource(assetDir, typeString: "videofx")
        asset.didFetchSuccess = { dataSource in
            list.dataSource = dataSource
        }
        asset.didFetchError = { _ in
        }
        asset.fetchData()
        list.didSelectedPackage = { [weak self] item in
            self?.applyPackage(item: item)
        }
        return list
    }
}
