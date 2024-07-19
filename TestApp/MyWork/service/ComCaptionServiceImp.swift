//
//  ComCaptionServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/17.
//

import UIKit
import NvStreamingSdkCore

protocol ComCaptionService {
    var dataSources: [DataSourceItem] { get set }
    func applyComCaptionIndex(index: Int)
    func applyComCaption(packageId: String)
}

class ComCaptionServiceImp: NSObject, ComCaptionService {
    var dataSources: [DataSourceItem] = []
    let comCaptionAssetGetter = DataSource()
    var comCaptionFx: NvsTimelineCompoundCaption?
    var timeline: NvsTimeline!
    var streamingContext = NvsStreamingContext.sharedInstance()!
    
    override init() {
        super.init()
        let captionDir = Bundle.main.bundlePath + "/compoundcaption"
        dataSources = comCaptionAssetGetter.loadAsset(path: captionDir, typeString: "compoundcaption")
    }
    func applyComCaptionIndex(index: Int) {
        let item = dataSources[index]
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        applyComCaption(packageId: pid as String)
    }
    
    func applyComCaption(packageId: String) {
        let pid = packageId
        if let comCaptionFx = comCaptionFx {
            timeline.remove(comCaptionFx)
            self.comCaptionFx = nil
        }
        if pid.count > 0 {
            comCaptionFx = timeline.addCompoundCaption(0, duration: timeline.duration, compoundCaptionPackageId: pid)
        }
        seek(timeline: timeline)
    }
}
