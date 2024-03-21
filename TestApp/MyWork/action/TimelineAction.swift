//
//  TimelineAction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Foundation
import NvStreamingSdkCore

class TimelineAction: NSObject {
    var livewindow: NvsLiveWindow!
    var timeline: NvsTimeline!
    let streamingContext = NvsStreamingContext.sharedInstance()!
    
    var filterFx: NvsTimelineVideoFx?
    var videoTransitionFx: NvsVideoTransition?
    
    var caption: NvsTimelineCaption?
    
    var didPlaybackTimelinePosition:((_ posotion: Int64, _ progress: Float) -> ())? = nil
    var playStateChanged:((_ isPlay: Bool)->())? = nil
    var timeValueChanged:((_ currentTime: String, _ duration: String)->())? = nil
    var compileProgressChanged:((_ progress: Int32) -> ())? = nil
    let seekFlag = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue)
    init(connect: ConnectEnable) {
        streamingContext.setColorGainForSDRToHDR(2.0)
        timeline = createTimeline(width: UInt(720), height: UInt(1280))
        connect.connect(streamingContext: streamingContext, timeline: timeline)
        timeline?.appendVideoTrack()
        streamingContext.seekTimeline(timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
        super.init()
        streamingContext.delegate = self
    }
    
    func addClips(localIds: Array<String>) {
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        let videoTrack = timeline.getVideoTrack(by: 0)
        localIds.forEach { localId in
            videoTrack?.appendClip(localId)
        }
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        seek(time: currentTime)
    }
    
    func playClick(_ sender: UIButton) {
        if streamingContext.getStreamingEngineState() != NvsStreamingEngineState_Playback {
            streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: 0)
        } else {
            streamingContext.stop()
        }
    }
    
    func seek(time: Int64) {
        streamingContext.seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
    }
    
    func saveAction(_ path: String?) {
        var compilePath = path
        if path == nil {
            compilePath = NSHomeDirectory() + "/Documents/" + currentDateAndTime() + ".mp4"
        }
        streamingContext.setCustomCompileVideoHeight(timeline.videoRes.imageHeight)
        streamingContext.compileTimeline(timeline, startTime: 0, endTime: timeline.duration, outputFilePath: compilePath, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileVideoBitrateGrade(rawValue: NvsCompileBitrateGradeMedium.rawValue), flags: 0)
    }
    
    func sliderValueChanged(_ value: Int64) {
        var time = value
        if value < 0 {
            time = 0
        }
        if value > timeline.duration {
            time = timeline.duration
        }
        streamingContext.seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
        timeValueChanged?(formatTime(time: time), formatTime(time: timeline.duration))
    }
    
}

extension TimelineAction: CaptionProtocal {
    func addCaption(text: String) -> NvsCaption {
        return NvsCaption()
    }
    
    func deleteCaption(caption: NvsCaption) {
        
    }
    
    func getAllCaption() -> [NvsCaption] {
        return []
    }
    
    func addCaption() {
//        caption = timeline.addModularCaption("helloworld\n123", inPoint: 0, duration: timeline.duration)
//        seek(time: 0)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 0) + 3, execute: DispatchWorkItem(block: {
//            self.caption?.setTextAlignment(NvsTextAlignmentRight)
//        }))
    }
}

extension TimelineAction: CompoundCaptionProtocal {
    func applyCompoundCaption(item: DataSourceItem) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        let ccc = timeline.addCompoundCaption(0, duration: timeline.duration, compoundCaptionPackageId: pid as String)
        let text = ccc?.getText(0)
        print(text)
    }
}

extension TimelineAction: NvsStreamingContextDelegate {
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        playStateChanged?(state == NvsStreamingEngineState_Playback)
    }
    
    func didCompileProgress(_ timeline: NvsTimeline!, progress: Int32) {
        compileProgressChanged?(progress)
    }
    
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        
        didPlaybackTimelinePosition?(position, Float(position) / Float(timeline.duration))
    }
}

extension TimelineAction: FilterProtocal {
    func applyFilter(item: DataSourceItem) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_VideoFx, sync: true, assetPackageId: pid)
        if filterFx?.timelineVideoFxType == NvsTimelineVideoFxType_Builtin {
            if filterFx?.bultinTimelineVideoFxName == item.bultinName {
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
        if pid.length > 0 {
            filterFx = timeline.addPackagedTimelineVideoFx(0, duration: timeline.duration, videoFxPackageId: pid as String)
        }
        seek(time: streamingContext.getTimelineCurrentPosition(timeline) )
    }
    
    func setFilterStrength(value: Float) {
        guard let filterFx = filterFx else { return }
        filterFx.setFilterIntensity(value)
        seek(time: streamingContext.getTimelineCurrentPosition(timeline) )
    }
    
    func getFilterStrength() -> Float {
        return filterFx?.getFilterIntensity() ?? 0
    }
}

extension TimelineAction: TransitionProtocal {
    func applyTransition(item: DataSourceItem, index: UInt32) {
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
        let videoTrack = timeline.getVideoTrack(by: 0)
        if pid.length > 0 {
            videoTransitionFx = videoTrack?.setPackagedTransition(index, withPackageId: pid as String)
        } else {
            videoTransitionFx = videoTrack?.setBuiltinTransition(index, withName: item.bultinName)
        }
        let clip = videoTrack?.getClipWith(index)
        streamingContext.playbackTimeline(timeline, startTime: clip!.outPoint - 500000, endTime: clip!.outPoint + 500000, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: 0)
    }
    
}
