//
//  CaptureFilterService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import UIKit
import NvStreamingSdkCore

class CaptureFilterService: NSObject, FilterService {
    var dataSources = [DataSourceItem]()
    let filterAssetGetter = DataSource(Bundle.main.bundlePath + "/videofx", typeString: "videofx")
    var filterFx: NvsCaptureVideoFx?
    var streamingContext = NvsStreamingContext.sharedInstance()!
    override init() {
        super.init()
        dataSources = filterAssetGetter.loadAsset()
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

    func applyFilterIndex(index: Int) {
        let item = dataSources[index]
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
    
}
