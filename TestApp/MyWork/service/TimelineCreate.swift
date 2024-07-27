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
    NvsStreamingContext.getSdkVersion(withUnsafeMutablePointer(to: &major) { $0 }, minorVersion: withUnsafeMutablePointer(to: &minor) { $0 }, revisionNumber: withUnsafeMutablePointer(to: &revision) { $0 })
    return "\(major).\(minor).\(revision)"
}

func createTimeline(width: UInt, height: UInt) -> NvsTimeline? {
    guard let streamingContext = NvsStreamingContext.sharedInstance() else {
        return nil
    }
    var videoEditRes = NvsVideoResolution()
    videoEditRes.imageWidth = UInt32(width)
    videoEditRes.imageHeight = UInt32(height)
    videoEditRes.imagePAR = NvsRational(num: 1, den: 1)
    var videoFps = NvsRational(num: 30, den: 1)
    var audioEditRes = NvsAudioResolution()
    audioEditRes.sampleRate = 48000
    audioEditRes.channelCount = 2
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16
    let timeline: NvsTimeline = streamingContext.createTimeline(&videoEditRes, videoFps: &videoFps, audioEditRes: &audioEditRes)
//    let timeline:NvsTimeline = streamingContext.createTimeline(&videoEditRes, videoFps:  &videoFps, audioEditRes: &audioEditRes, bitDepth: NvsVideoResolutionBitDepth_16Bit_Float, flags: 0)
    let res = timeline.videoRes
    print("timeline width \(res.imageWidth) height \(res.imageHeight)")
    return timeline
}
