//
//  FilterServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/16.
//

import UIKit
import NvStreamingSdkCore

protocol FilterService {
    func applyFilterIndex(index: Int)
    func applyFilter(packageId: String)
    func setFilterStrength(value: Float)
    func getFilterStrength() -> Float
    var dataSources: [DataSourceItem] { get set }
}

class FilterServiceImp: NSObject, FilterService {
    var dataSources = [DataSourceItem]()
    let filterAssetGetter = DataSource()
    var filterFx: NvsTimelineVideoFx?
    var timeline: NvsTimeline!
    var streamingContext = NvsStreamingContext.sharedInstance()!
    override init() {
        super.init()
        let filterDir = Bundle.main.bundlePath + "/videofx"
        dataSources = filterAssetGetter.loadAsset(path: filterDir, typeString: "videofx")
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

    func applyFilterIndex(index: Int) {
        let item = dataSources[index]
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        applyFilter(packageId: pid as String)
    }
    
}
