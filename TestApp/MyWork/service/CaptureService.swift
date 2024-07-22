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
    let captionService = CaptureCaptionServiceImp()
    let filterService = CaptureFilterService()
    let arsceneService = CaptureARSceneServiceImp()
    var arsceneFx: NvsCaptureVideoFx?
    override init() {
        super.init()
        NvsStreamingContext.setSpecialCameraDeviceType("AVCaptureDeviceTypeBuiltInUltraWideCamera")
        initAR()
        arsceneFx = streamingContext.appendBuiltinCaptureVideoFx("AR Scene")
        arsceneFx?.setBooleanVal("Max Faces Respect Min", val: true)
        arsceneFx?.setBooleanVal("Use Face Extra Info", val: true)
        arsceneService.arsceneFx = arsceneFx
    }
    func initAR() {
        let licPath = Bundle.main.bundlePath + "/ms/meishesdk.lic"
        let ms_face240ModelPath = Bundle.main.bundlePath + "/ms/ms_face240_v2.0.8.model"
        let humanSegModelPath = Bundle.main.bundlePath + "/ms/ms_humanseg_v1.0.15.model"
        var sss = NvsStreamingContext.initHumanDetection(ms_face240ModelPath, licenseFilePath: licPath, features: Int32(NvsHumanDetectionFeature_FaceLandmark.rawValue|NvsHumanDetectionFeature_FaceAction.rawValue | NvsHumanDetectionFeature_SemiImageMode.rawValue))
        sss = NvsStreamingContext.initHumanDetectionExt(humanSegModelPath, licenseFilePath: licPath, features: Int32(NvsEffectSdkHumanDetectionFeature_Background.rawValue))
        print("加载模型: \(sss)")
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
        streamingContext.removeAllCaptureAudioFx()
    }
    
}

extension CaptureService: NvsStreamingContextDelegate {
    func didCaptureDeviceCapsReady(_ captureDeviceIndex: UInt32) {
        let cap = streamingContext.getCaptureDeviceCapability(captureDeviceIndex);
        print(cap?.maxZoomFactor)
    }
}
