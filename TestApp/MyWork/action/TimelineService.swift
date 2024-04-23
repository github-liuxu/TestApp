//
//  TimelineService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Foundation
import NvStreamingSdkCore

class TimelineService: NSObject {
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
    let seekFlag = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)
    init(connect: ConnectEnable) {
        super.init()
        ARService().initAR()
//        streamingContext.setColorGainForSDRToHDR(2.0)
        timeline = createTimeline(width: 1920, height: 1080)
        connect.connect(streamingContext: streamingContext, timeline: timeline)
        timeline?.appendVideoTrack()
        streamingContext.seekTimeline(timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
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
            streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
        } else {
            streamingContext.stop()
        }
    }
    
    func matting() {
        /// 添加轨道
        /// 添加背景分割特效
        let segfx = timeline!.addBuiltinTimelineVideoFx(0, duration: timeline!.duration, videoFxName: "Segmentation")
        segfx?.setBooleanVal("Inverse Segment", val: true)
        segfx?.setBooleanVal("Output Mask", val: true)
//        let image = streamingContext.grabImage(from: timeline, timestamp: 100, proxyScale: nil)
//        print(image)
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
        streamingContext.compileTimeline(timeline, startTime: 0, endTime: timeline.duration, outputFilePath: compilePath, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileVideoBitrateGrade(rawValue: NvsCompileBitrateGradeMedium.rawValue), flags: Int32(NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize.rawValue|NvsStreamingEngineCompileFlag_BuddyHostVideoFrame.rawValue))
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

extension TimelineService: CaptionProtocal {
    func addCaption(text: String) -> NvsCaption {
        return NvsCaption()
    }
    
    func deleteCaption(caption: NvsCaption) {
        
    }
    
    func getAllCaption() -> [NvsCaption] {
        return []
    }
    
    func addCaption() {
        let pid = NSMutableString()
        let packagePath = Bundle.main.bundlePath + "/caption/F226A086-A071-4948-9C82-81D555322FE1.1.captionrenderer"
        streamingContext.assetPackageManager.installAssetPackage(packagePath, license: nil, type: NvsAssetPackageType_CaptionRenderer, sync: true, assetPackageId: pid)
        caption = timeline.addModularCaption("同样500公里油费300块电费30块", inPoint: 0, duration: timeline.duration)
        caption?.applyModularCaptionRenderer(pid as String)
        caption?.setScaleX(0.6573522)
        caption?.setScaleY(0.6573522)
        let fontPath = Bundle.main.bundlePath + "/font/ZKWYJW.TTF"
        caption?.setFontWithFilePath(fontPath)
        seek(time: 0)
//        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 0) + 3, execute: DispatchWorkItem(block: {
//            self.caption?.setTextAlignment(NvsTextAlignmentRight)
//        }))
    }
    
    func setCaptionText(caption: NvsCaption, text: String) {
        
    }
    
    func setCaptionTextColor(caption: NvsCaption, text: String) {
        
    }
    
    func applyCaptionRenderer(caption: NvsCaption, rendererid: String) {
        
    }
    
    func applyCaptionContext(caption: NvsCaption, contextid: String) {
        
    }
    
    func applyCaptionAnimation(caption: NvsCaption, animationid: String) {
        
    }
    
    func selectCaption(point: CGPoint) -> NvsCaption {
        return NvsCaption()
    }
}

extension TimelineService: CompoundCaptionProtocal {
    func applyCompoundCaption(item: DataSourceItem) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        let ccc = timeline.addCompoundCaption(0, duration: timeline.duration, compoundCaptionPackageId: pid as String)
        let text = ccc?.getText(0)
        print(text)
    }
}

extension TimelineService: NvsStreamingContextDelegate {
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        playStateChanged?(state == NvsStreamingEngineState_Playback)
    }
    
    func didCompileProgress(_ timeline: NvsTimeline!, progress: Int32) {
        compileProgressChanged?(progress)
    }
    
    func didCompileCompleted(_ timeline: NvsTimeline!, isHardwareEncoding: Bool, errorType: Int32, errorString: String!, flags: Int32) {
        if errorType == NvsStreamingEngineCompileErrorType_No_Error.rawValue {
            
        }
    }
    
    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        
        didPlaybackTimelinePosition?(position, Float(position) / Float(timeline.duration))
    }
    
    func didPlaybackStopped(_ timeline: NvsTimeline!) {
        
    }
    
    func didPlaybackEOF(_ timeline: NvsTimeline!) {
        
    }
    
    func onPlaybackException(_ timeline: NvsTimeline!, exceptionType: NvsStreamingEnginePlaybackExceptionType, exceptionString: String!) {
        
    }


}

extension TimelineService: FilterProtocal {
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

extension TimelineService: TransitionProtocal {
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
