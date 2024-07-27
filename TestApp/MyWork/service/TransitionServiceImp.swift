//
//  TransitionServiceImp.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import UIKit
import JXSegmentedView
import NvStreamingSdkCore

protocol TransitionService {
    var didFetchSuccess: (() -> Void)? { get set }
    var didFetchError: ((Error) -> Void)? { get set }
    func fetchData()
    var selectedIndex: UInt32 { get set }
}

class TransitionServiceImp: NSObject, TransitionService {
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?
    var timeline: NvsTimeline!
    var streamingContext = NvsStreamingContext.sharedInstance()!
    var videoTransitionFx: NvsVideoTransition?
    var selectedIndex: UInt32 = 0
    func fetchData() {
        didFetchSuccess?()
    }
}

extension TransitionServiceImp: PackageService {
    func cancelAction() {
        
    }
    
    func sureAction() {
        
    }
    
    func applyPackage(item: DataSourceItemProtocol) {
        guard let timeline = timeline else { return }
        let videoTrack = timeline.getVideoTrack(by: 0)
        videoTransitionFx = videoTrack?.getTransitionWithSourceClipIndex(selectedIndex)
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoTransition, sync: true, assetPackageId: pid)
        if videoTransitionFx?.videoTransitionType == NvsVideoTransitionType_Builtin {
            if videoTransitionFx?.bultinVideoTransitionName == item.bultinName {
                return
            }
        } else {
            if videoTransitionFx?.videoTransitionPackageId == pid as String {
                return
            }
        }
        if pid.length > 0 {
            videoTransitionFx = videoTrack?.setPackagedTransition(selectedIndex, withPackageId: pid as String)
        } else {
            videoTransitionFx = videoTrack?.setBuiltinTransition(selectedIndex, withName: item.bultinName)
        }
        let clip = videoTrack?.getClipWith(selectedIndex)
        streamingContext.playbackTimeline(timeline, startTime: clip!.outPoint - 500_000, endTime: clip!.outPoint + 500_000, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: 0)
    }
}

extension TransitionServiceImp: PackageSubviewSource {
    func titles() -> [String] {
        return ["2D", "3D"]
    }
    
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/videotransition"
        var asset = DataSource(assetDir, typeString: "videotransition")
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
