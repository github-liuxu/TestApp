//
//  TimelineService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Foundation
import NvStreamingSdkCore

func seek(timeline: NvsTimeline?, timestamp: Int64 = -1, flags: Int32 = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)) {
    let streamingContext = NvsStreamingContext.sharedInstance()
    var time = timestamp
    if timestamp == -1 {
        time = streamingContext?.getTimelineCurrentPosition(timeline) ?? 0
    }
    NvsStreamingContext.sharedInstance().seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: flags)
}

protocol TimelineFxService {
    var captionService: CaptionServiceImp { get set }
    var stickerService: StickerServiceImp { get  set }
    var comCaptionService: ComCaptionServiceImp { get set }
    var timeline: NvsTimeline? { get set }
}

class TimelineService: NSObject, TimelineFxService {
    var livewindow: NvsLiveWindow
    var timeline: NvsTimeline?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var captionService: CaptionServiceImp = CaptionServiceImp()
    var stickerService: StickerServiceImp = StickerServiceImp()
    var filterService = FilterServiceImp()
    var comCaptionService: ComCaptionServiceImp = ComCaptionServiceImp()
    var videoTransitionFx: NvsVideoTransition?
    var caption: NvsTimelineCaption?
    
    var didPlaybackTimelinePosition:((_ posotion: Int64, _ progress: Float) -> ())? = nil
    var playStateChanged:((_ isPlay: Bool)->())? = nil
    var timeValueChanged:((_ currentTime: String, _ duration: String)->())? = nil
    var compileProgressChanged:((_ progress: Int32) -> ())? = nil
    let seekFlag = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue|NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue|NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)
    init(livewindow: NvsLiveWindow) {
        self.livewindow = livewindow
        super.init()
        ARService().initAR()
//        streamingContext.setColorGainForSDRToHDR(2.0)
        timeline = createTimeline(width: 1920, height: 1080)
        captionService.timeline = timeline
        filterService.timeline = timeline
        comCaptionService.timeline = timeline
        stickerService.livewindow = livewindow
        stickerService.timeline = timeline
        captionService.livewindow = livewindow
        streamingContext.connect(timeline, with: livewindow)
        timeline?.appendVideoTrack()
        streamingContext.seekTimeline(timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
        streamingContext.delegate = self
    }
    
    func addClips(localIds: Array<String>) {
        guard let timeline = timeline else { return }
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        let videoTrack = timeline.getVideoTrack(by: 0)
        localIds.forEach { localId in
            videoTrack?.appendClip(localId)
        }
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        seek(time: currentTime)
    }
    
    func playClick(_ sender: UIButton) {
        guard let timeline = timeline else { return }
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
    
    func addAnimationSticker() {
        guard let timeline = timeline else { return }
        let stickerPath = Bundle.main.path(forResource: "animationSticker/6FF9E1FC-3C2C-49B6-A3A7-BA51B1DA8AE0.1.animatedsticker", ofType: "")
        let path = Bundle.main.path(forResource: "9DD65EAD-DA38-4C19-AF17-621265A6B010.3", ofType: "captioninanimation")
        
        let pid = NSMutableString()
//        streamingContext.assetPackageManager.installAssetPackage(stickerPath, license: nil, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
//        
//        timeline.addAnimatedSticker(0, duration: timeline.duration, animatedStickerPackageId: pid as String)
        
        streamingContext.assetPackageManager.installAssetPackage(path, license: nil, type: NvsAssetPackageType_CaptionInAnimation, sync: true, assetPackageId: pid)
        let caption = timeline.addModularCaption("hjsdfhlaskdjfl;\naskjdfl;askdj", inPoint: 0, duration: timeline.duration)
        caption?.applyModularCaption(inAnimation: pid as String)
        caption?.setModularCaptionInAnimationDuration(Int32(timeline.duration))
    }
    
    
    func seek(time: Int64) {
        streamingContext.seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
    }
    
    func saveAction(_ path: String?) {
        guard let timeline = timeline else { return }
        var compilePath = path
        if path == nil {
            compilePath = NSHomeDirectory() + "/Documents/" + currentDateAndTime() + ".mp4"
        }
        streamingContext.setCustomCompileVideoHeight(timeline.videoRes.imageHeight)
        streamingContext.compileTimeline(timeline, startTime: 0, endTime: timeline.duration, outputFilePath: compilePath, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileVideoBitrateGrade(rawValue: NvsCompileBitrateGradeMedium.rawValue), flags: Int32(NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize.rawValue|NvsStreamingEngineCompileFlag_BuddyHostVideoFrame.rawValue))
    }
    
    func sliderValueChanged(_ value: Int64) {
        guard let timeline = timeline else { return }
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

extension TimelineService: CompoundCaptionProtocal {
    func applyCompoundCaption(item: DataSourceItem) {
        guard let timeline = timeline else { return }
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        let ccc = timeline.addCompoundCaption(0, duration: timeline.duration, compoundCaptionPackageId: pid as String)
        let text = ccc?.getText(0)
        print(text)
    }
    
    func applyCrop() {
        guard let timeline = timeline else { return }
        let clip = timeline.getVideoTrack(by: 0).getClipWith(0)
//        clip?.enableRawSourceMode(true)
        let transFx = clip?.appendRawBuiltinFx("Transform 2D")
        transFx?.setBooleanVal("Is Normalized Coord", val: true)
        transFx?.setBooleanVal("Force Identical Position", val: true)
        transFx?.setFloatVal("Trans X", val: 1)
        transFx?.setFloatVal("Trans Y", val: 0)
        let fx = clip?.appendRawBuiltinFx("Crop")
        fx?.setFilterMask(false)
        fx?.setFloatVal("Bounding Left", val: -2160)
        fx?.setFloatVal("Bounding Right", val: 0)
        fx?.setFloatVal("Bounding Top", val: 1152)
        fx?.setFloatVal("Bounding Bottom",val: -1152)
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

extension TimelineService: TransitionProtocal {
    func applyTransition(item: DataSourceItem, index: UInt32) {
        guard let timeline = timeline else { return }
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
