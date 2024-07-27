//
//  CaptureService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import Combine
import NvStreamingSdkCore
import UIKit

class CaptureService: NSObject {
    var streamingContext = NvsStreamingContext.sharedInstance()!
    var cameraIndex: UInt32 = 0
    let captionService = CaptureCaptionServiceImp()
    let filterService = CaptureFilterService()
    let arsceneService = CaptureARSceneServiceImp()
    let stickerService = CaptureStickerServiceImp()
    let comCaptionService = CaptureComCaptionServiceImp()
    var arsceneFx: NvsCaptureVideoFx?
    var seconds: Int64 = 0
    @Published var isRecording = false
    override init() {
        super.init()
        NvsStreamingContext.setSpecialCameraDeviceType("AVCaptureDeviceTypeBuiltInUltraWideCamera")
        arsceneFx = streamingContext.appendBuiltinCaptureVideoFx("AR Scene")
        arsceneFx?.setBooleanVal("Max Faces Respect Min", val: true)
        arsceneFx?.setBooleanVal("Use Face Extra Info", val: true)
        arsceneService.arsceneFx = arsceneFx
    }

    func startPreview(livewindow: NvsLiveWindow) {
        captionService.livewindow = livewindow
        streamingContext.connectCapturePreview(with: livewindow)
        streamingContext.delegate = self
        let aspectRatio = NvsRational(num: 9, den: 16)
        let ratio = withUnsafePointer(to: aspectRatio) { $0 }
        streamingContext.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: Int32(NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize.rawValue | NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame.rawValue), aspectRatio: ratio)
    }

    func startRecording(seconds: Int64 = 0) {
        self.seconds = seconds
        let recordingPath = Documents + currentDateAndTime() + ".mov"
        streamingContext.stopRecording()
        let result = streamingContext.startRecording(withFx: recordingPath, withFlags: 0, withRecordConfigurations: nil)
        print(result ? "record success" : "record error")
    }

    func stopRecording() {
        streamingContext.stopRecording()
    }

    func pauseRecording() {
        streamingContext.pauseRecording()
        isRecording = false
    }

    func resumeRecording() {
        streamingContext.resumeRecording()
        isRecording = true
    }

    func streamingIsRecording() -> Bool {
        return streamingContext.getStreamingEngineState() == NvsStreamingEngineState_CaptureRecording
    }

    func switchCamera() {
        if cameraIndex == 0 {
            cameraIndex = 1
        } else if cameraIndex == 1 {
            cameraIndex = 2
        } else {
            cameraIndex = 0
        }
        streamingContext.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: Int32(NvsStreamingEngineCaptureFlag_StrictPreviewVideoSize.rawValue | NvsStreamingEngineCaptureFlag_CaptureBuddyHostVideoFrame.rawValue), aspectRatio: nil)
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
        let cap = streamingContext.getCaptureDeviceCapability(captureDeviceIndex)
        print(cap?.maxZoomFactor)
    }

    func didCaptureRecordingDurationUpdated(_: Int32, duration: Int64) {
        if seconds > 0 && duration >= (seconds * 1_000_000) {
            DispatchQueue.main.async { [weak self] in
                self?.streamingContext.stopRecording()
            }
        }
    }

    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        print("state:\(state)")
        if state == NvsStreamingEngineState_CaptureRecording {
            isRecording = true
        } else {
            isRecording = false
        }
    }
}
