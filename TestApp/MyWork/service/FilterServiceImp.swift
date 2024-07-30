//
//  FilterServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/16.
//

import NvStreamingSdkCore
import JXSegmentedView

protocol FilterService {
    func applyFilter(item: DataSourceItemProtocol)
    func setFilterStrength(value: Float)
    func getFilterStrength() -> Float
}

class FilterServiceImp: NSObject, FilterService {
    var filterFx: NvsTimelineVideoFx?
    var timeline: NvsTimeline!
    var streamingContext = NvsStreamingContext.sharedInstance()!
    override init() {
        super.init()
    }
    
    func setFilterStrength(value: Float) {
        guard let filterFx = filterFx else { return }
        filterFx.setFilterIntensity(value)
        seek(timeline: timeline)
    }

    func getFilterStrength() -> Float {
        return filterFx?.getFilterIntensity() ?? 0
    }

    func applyFilter(packageId: String) {
        let pid = packageId
        if filterFx?.timelineVideoFxType == NvsTimelineVideoFxType_Builtin {
            if filterFx?.bultinTimelineVideoFxName == packageId {
                return
            }
        } else {
            if filterFx?.timelineVideoFxPackageId == pid as String {
                return
            }
        }

        if let filterFx = filterFx {
            timeline.remove(filterFx)
            self.filterFx = nil
        }
        if pid.count > 0 {
            filterFx = timeline.addPackagedTimelineVideoFx(0, duration: timeline.duration, videoFxPackageId: pid as String)
        }
        seek(timeline: timeline)
    }
    func applyFilter(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
}

extension FilterServiceImp: PackageService {
    func cancelAction() {
        
    }
    
    func sureAction() {
        
    }
    
    func applyPackage(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
}

extension FilterServiceImp: PackageSubviewSource {
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
            self?.applyPackage(item: item)
        }
        return list
    }
}
