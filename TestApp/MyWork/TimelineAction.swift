//
//  TimelineAction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Foundation
import NvStreamingSdkCore

class TimelineAction: NSObject, NvsStreamingContextDelegate {
    var livewindow: NvsLiveWindow!
    var timeline: NvsTimeline!
    let streamingContext = NvsStreamingContext.sharedInstance()
    
    var playStateChanged:((_ isPlay: Bool)->())? = nil
    var timeValueChanged:((_ currentTime: String, _ duration: String)->())? = nil
    var compileProgressChanged:((_ progress: Int32) -> ())? = nil
    
    init(livewindow: NvsLiveWindow) {
        self.livewindow = livewindow
        livewindow.fillMode = NvsLiveWindowFillModePreserveAspectFit
        timeline = createTimeline(width: UInt(720), height: UInt(1280))
        streamingContext?.connect(timeline, with: livewindow)
        timeline?.appendVideoTrack()
        streamingContext?.seekTimeline(timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: 0)
        super.init()
        streamingContext?.delegate = self
    }
    
    func addClips(localIds: Array<String>) {
        let videoTrack = timeline.getVideoTrack(by: 0)
        localIds.forEach { localId in
            videoTrack?.appendClip(localId)
        }
        let currentTime = streamingContext!.getTimelineCurrentPosition(timeline)
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        seek(time: currentTime)
    }
    
    func playClick(_ sender: UIButton) {
        if streamingContext?.getStreamingEngineState() != NvsStreamingEngineState_Playback {
            streamingContext?.playbackTimeline(timeline, startTime: streamingContext?.getTimelineCurrentPosition(timeline) ?? 0, endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: 0)
        } else {
            streamingContext?.stop()
        }
    }
    
    func seek(time: Int64) {
        streamingContext?.seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: 0)
    }
    
    func saveAction(_ path: String?) {
        var compilePath = path
        if path == nil {
            compilePath = NSHomeDirectory() + "/Documents/" + currentDateAndTime() + ".mp4"
        }
        streamingContext?.setCustomCompileVideoHeight(timeline.videoRes.imageHeight)
        streamingContext?.compileTimeline(timeline, startTime: 0, endTime: timeline.duration, outputFilePath: compilePath, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileVideoBitrateGrade(rawValue: NvsCompileBitrateGradeMedium.rawValue), flags: 0)
    }
    
    func sliderValueChanged(_ sender: UISlider) {
        let ctime = Int64(sender.value * Float(timeline.duration))
        streamingContext?.seekTimeline(timeline, timestamp: ctime, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: 0)
        
        let currentTime = streamingContext!.getTimelineCurrentPosition(timeline)
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
    }
    
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        playStateChanged?(state == NvsStreamingEngineState_Playback)
    }
    
    func didCompileProgress(_ timeline: NvsTimeline!, progress: Int32) {
        compileProgressChanged?(progress)
    }
    
}
