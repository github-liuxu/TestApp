//
//  TimelineService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Combine
import Foundation
import NvStreamingSdkCore

func seek(timeline: NvsTimeline?, timestamp: Int64 = -1, flags: Int32 = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue | NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)) {
    guard let timeline = timeline else { return }
    let streamingContext = NvsStreamingContext.sharedInstance()
    var time = timestamp
    if timestamp == -1 {
        time = streamingContext?.getTimelineCurrentPosition(timeline) ?? 0
    }
    NvsStreamingContext.sharedInstance().seekTimeline(timeline, timestamp: time, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: flags)
}

protocol TimelineFxService {
    var captionService: CaptionServiceImp { get set }
    var stickerService: StickerServiceImp { get set }
    var comCaptionService: ComCaptionServiceImp { get set }
    var transitionService: TransitionServiceImp { get set }
    var timeline: NvsTimeline? { get set }
}

class TimelineService: NSObject, TimelineFxService {
    var livewindow: NvsLiveWindow
    var timeline: NvsTimeline?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var captionService: CaptionServiceImp = .init()
    var stickerService: StickerServiceImp = .init()
    var filterService = FilterServiceImp()
    var comCaptionService: ComCaptionServiceImp = .init()
    var transitionService: TransitionServiceImp = .init()

    var didPlaybackTimelinePosition: ((_ posotion: Int64, _ progress: Float) -> Void)? = nil
    var playStateChanged: ((_ isPlay: Bool) -> Void)? = nil
    var timeValueChanged: ((_ currentTime: String, _ duration: String) -> Void)? = nil
    var compileProgressChanged: ((_ progress: Int32) -> Void)? = nil
    private var compileProgress: PassthroughSubject<Int32, Error>?
    let seekFlag = Int32(NvsStreamingEngineSeekFlag_ShowCaptionPoster.rawValue | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster.rawValue | NvsStreamingEngineSeekFlag_BuddyHostVideoFrame.rawValue | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame.rawValue)
    init(livewindow: NvsLiveWindow) {
        self.livewindow = livewindow
        super.init()
//        streamingContext.setColorGainForSDRToHDR(2.0)
        timeline = createTimeline(width: 1920, height: 1080)
        captionService.timeline = timeline
        captionService.livewindow = livewindow
        filterService.timeline = timeline
        comCaptionService.timeline = timeline
        comCaptionService.livewindow = livewindow
        stickerService.livewindow = livewindow
        stickerService.timeline = timeline
        transitionService.timeline = timeline
        streamingContext.connect(timeline, with: livewindow)
        timeline?.appendVideoTrack()
        streamingContext.seekTimeline(timeline, timestamp: 0, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, flags: seekFlag)
        streamingContext.delegate = self
    }

    func clear() {
        if let timeline = timeline {
            streamingContext.remove(timeline)
        }
    }

    func addClips(localIds: [String]) {
        guard let timeline = timeline else { return }
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        let videoTrack = timeline.getVideoTrack(by: 0)
        for localId in localIds {
            videoTrack?.appendClip(localId)
        }
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))
        seek(time: currentTime)
    }

    func getClipService(index: UInt32, trackIndex: UInt32 = 0) -> VideoClipService? {
        guard let timeline = timeline else { return nil }
        let videoTrack = timeline.getVideoTrack(by: trackIndex)
        if let clip = videoTrack?.getClipWith(index) {
            let videoClipService = VideoClipServiceImp()
            videoClipService.videoClip = clip
            return videoClipService
        }
        return nil
    }

    func playClick(_: UIButton) {
        guard let timeline = timeline else { return }
        if streamingContext.getStreamingEngineState() != NvsStreamingEngineState_Playback {
            streamingContext.playbackTimeline(timeline, startTime: streamingContext.getTimelineCurrentPosition(timeline), endTime: timeline.duration, videoSizeMode: NvsVideoPreviewSizeModeLiveWindowSize, preload: true, flags: Int32(NvsStreamingEnginePlaybackFlag_BuddyHostVideoFrame.rawValue | NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame.rawValue))
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

    @discardableResult
    func saveAction(_ path: String, coverPath: String? = nil) -> PassthroughSubject<Int32, Error>? {
        guard let timeline = timeline else { return nil }
        compileProgress = PassthroughSubject<Int32, Error>()
        var finaltimeline: NvsTimeline = timeline
        if coverPath?.count ?? 0 > 0 {
            let timeline1 = createTimeline(width: UInt(timeline.videoRes.imageWidth), height: UInt(timeline.videoRes.imageHeight))
            let videotrack = timeline1?.appendVideoTrack()
            videotrack?.appendTimelineClip(timeline)
            let clip = videotrack?.insertClip(coverPath, trimIn: 0, trimOut: 100_000, clipIndex: 0)
            videotrack?.setBuiltinTransition(0, withName: "")
            clip?.imageMotionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn
            clip?.imageMotionAnimationEnabled = false
            clip?.disableAmbiguousCrop(true)
            finaltimeline = timeline1!
        }
        streamingContext.setCustomCompileVideoHeight(finaltimeline.videoRes.imageHeight)
        streamingContext.compileTimeline(finaltimeline, startTime: 0, endTime: finaltimeline.duration, outputFilePath: path, videoResolutionGrade: NvsCompileVideoResolutionGradeCustom, videoBitrateGrade: NvsCompileVideoBitrateGrade(rawValue: NvsCompileBitrateGradeMedium.rawValue), flags: Int32(NvsStreamingEngineCompileFlag_IgnoreTimelineVideoSize.rawValue | NvsStreamingEngineCompileFlag_BuddyHostVideoFrame.rawValue))
        return compileProgress
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

extension TimelineService: NvsStreamingContextDelegate {
    func didStreamingEngineStateChanged(_ state: NvsStreamingEngineState) {
        playStateChanged?(state == NvsStreamingEngineState_Playback)
    }

    func didCompileProgress(_: NvsTimeline!, progress: Int32) {
        compileProgressChanged?(progress)
        compileProgress?.send(progress)
    }

    func didCompileCompleted(_: NvsTimeline!, isHardwareEncoding _: Bool, errorType: Int32, errorString: String!, flags _: Int32) {
        if errorType == NvsStreamingEngineCompileErrorType_No_Error.rawValue {
            compileProgress?.send(completion: .finished)
        } else {
            let error = NSError(domain: errorString, code: Int(errorType)) as Error
            compileProgress?.send(completion: .failure(error))
        }
    }

    func didPlaybackTimelinePosition(_ timeline: NvsTimeline!, position: Int64) {
        let currentTime = streamingContext.getTimelineCurrentPosition(timeline)
        timeValueChanged?(formatTime(time: currentTime), formatTime(time: timeline.duration))

        didPlaybackTimelinePosition?(position, Float(position) / Float(timeline.duration))
    }

    func didPlaybackStopped(_: NvsTimeline!) {}

    func didPlaybackEOF(_: NvsTimeline!) {}

    func onPlaybackException(_: NvsTimeline!, exceptionType _: NvsStreamingEnginePlaybackExceptionType, exceptionString _: String!) {}
}
