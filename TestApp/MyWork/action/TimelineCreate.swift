//
//  TimelineCreate.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import Foundation
import NvStreamingSdkCore

func getVertionString() -> String {
    var major: Int32 = 0
    var minor: Int32 = 0
    var revision: Int32 = 0
    NvsStreamingContext.getSdkVersion(withUnsafeMutablePointer(to: &major) {$0}, minorVersion: withUnsafeMutablePointer(to: &minor) {$0}, revisionNumber: withUnsafeMutablePointer(to: &revision) {$0})
    return "\(major).\(minor).\(revision)"
}

func createTimeline(width: UInt, height: UInt) -> NvsTimeline? {
    guard let streamingContext = NvsStreamingContext.sharedInstance() else {
        return nil
    }
    var videoEditRes : NvsVideoResolution = NvsVideoResolution ()
    let size = CGSize(width: Int((width + 3) & ~3), height: Int((height + 1) & ~1))
    videoEditRes.imageWidth = UInt32(size.width)
    videoEditRes.imageHeight = UInt32(size.height)
    videoEditRes.imagePAR = NvsRational.init(num: 1, den: 1)
    var videoFps : NvsRational = NvsRational.init(num: 30, den: 1)
    var audioEditRes : NvsAudioResolution = NvsAudioResolution()
    audioEditRes.sampleRate = 48000
    audioEditRes.channelCount = 2
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16
//    let timeline:NvsTimeline = streamingContext.createTimeline(&videoEditRes, videoFps: &videoFps, audioEditRes: &audioEditRes)
    let timeline:NvsTimeline = streamingContext.createTimeline(&videoEditRes, videoFps:  &videoFps, audioEditRes: &audioEditRes, bitDepth: NvsVideoResolutionBitDepth_Auto, flags: 0)
    return timeline
}
