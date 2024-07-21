//
//  CaptureService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import UIKit
import NvStreamingSdkCore

class CaptureService: NSObject {
    var streamingContext = NvsStreamingContext.sharedInstance()!
    var cameraIndex: UInt32 = 0
    var filterFx: NvsCaptureVideoFx?
    let captionService: CaptureCaptionServiceImp = CaptureCaptionServiceImp()
    override init() {
        super.init()
        NvsStreamingContext.setSpecialCameraDeviceType("AVCaptureDeviceTypeBuiltInUltraWideCamera")
        ARService().initAR()
    }
    func startPreview(livewindow: NvsLiveWindow) {
        captionService.livewindow = livewindow
        streamingContext.connectCapturePreview(with: livewindow)
        streamingContext.delegate = self
        let aspectRatio = NvsRational(num: 9, den: 16)
        let ratio = withUnsafePointer(to: aspectRatio, { $0 })
        streamingContext.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: Int32(NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize.rawValue|NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame.rawValue), aspectRatio: ratio)
    }
    
    func startRecording() {
        let recordingPath = Documents + currentDateAndTime() + ".mov"
        let result = streamingContext.startRecording(withFx: recordingPath, withFlags: 0, withRecordConfigurations: nil)
        print(result ? "record success" : "record error")
    }
    
    func stopRecording() {
        streamingContext.stopRecording()
    }
    
    func switchCamera() {
        if (cameraIndex == 0) {
            cameraIndex = 1
        } else if (cameraIndex == 1) {
            cameraIndex = 2
        } else {
            cameraIndex = 0
        }
        streamingContext.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: Int32(NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize.rawValue|NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame.rawValue), aspectRatio: nil)
    }
    
    func zoomFactor(zoom: Float) {
        streamingContext.setZoomFactor(zoom)
    }
    
    func clear() {
        captionService.clear()
        streamingContext.removeAllCaptureVideoFx()
    }
    
}

extension CaptureService: NvsStreamingContextDelegate {
    func didCaptureDeviceCapsReady(_ captureDeviceIndex: UInt32) {
        let cap = streamingContext.getCaptureDeviceCapability(captureDeviceIndex);
        print(cap?.maxZoomFactor)
    }
}

extension CaptureService: FilterProtocal {
    func applyFilter(item: DataSourceItem) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
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
            streamingContext.removeCaptureVideoFx(filterFx.index)
        }
        if pid.length > 0 {
            filterFx = streamingContext.appendPackagedCaptureVideoFx(pid as String)
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
