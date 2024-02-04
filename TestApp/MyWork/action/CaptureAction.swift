//
//  CaptureAction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import UIKit
import NvStreamingSdkCore

class CaptureAction: NSObject {
    var streamingContext = NvsStreamingContext.sharedInstance()
    var cameraIndex: UInt32 = 0
    var filterFx: NvsCaptureVideoFx?
    func startPreview(livewindow: NvsLiveWindow) {
        streamingContext?.connectCapturePreview(with: livewindow)
        streamingContext?.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: 0, aspectRatio: nil)
    }
    
    func startRecording() {
        let recordingPath = Documents + currentDateAndTime() + ".mov"
        streamingContext?.startRecording(withFx: recordingPath, withFlags: 0, withRecordConfigurations: nil)
    }
    
    func stopRecording() {
        streamingContext?.stopRecording()
    }
    
    func switchCamera() {
        if (cameraIndex == 0) {
            cameraIndex = 1
        } else {
            cameraIndex = 0
        }
        streamingContext?.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: 0, aspectRatio: nil)
    }
    
}

extension CaptureAction: FilterProtocal {
    func applyFilter(item: DataSourceItem) {
        let pid = NSMutableString()
        streamingContext?.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        if filterFx?.captureVideoFxType == NvsCaptureVideoFxType_Builtin {
            if filterFx?.bultinCaptureVideoFxName == item.bultinName {
                return
            }
        } else {
            if filterFx?.captureVideoFxPackageId == pid as String {
                return
            }
        }
        
        if let filterFx = filterFx {
            streamingContext?.removeCaptureVideoFx(filterFx.index)
        }
        if pid.length > 0 {
            filterFx = streamingContext?.appendPackagedCaptureVideoFx(pid as String)
        }
    }
    
    func setFilterStrength(value: Float) {
        guard let filterFx = filterFx else { return }
        filterFx.setFilterIntensity(value)
    }
    
    func getFilterStrength() -> Float {
        return filterFx?.getFilterIntensity() ?? 0
    }
}
