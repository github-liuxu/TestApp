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
    func startPreview(livewindow: NvsLiveWindow) {
        streamingContext?.connectCapturePreview(with: livewindow)
        streamingContext?.startCapturePreview(cameraIndex, videoResGrade: NvsVideoCaptureResolutionGradeHigh, flags: 0, aspectRatio: nil)
    }
    
    func startRecording() {
        let recordingPath = Documents + currentDateAndTime() + ".mov"
        streamingContext?.startRecording(recordingPath)
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
