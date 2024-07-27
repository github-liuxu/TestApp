//
//  RectMoveableImp.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/20.
//

import Foundation
import NvStreamingSdkCore

class RectMoveableImp: Moveable {
    var timelineService: TimelineFxService?
    var moveable: Moveable?
    var livewindow: NvsLiveWindow?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        moveable?.translate(prePoint: prePoint, curPoint: curPoint)
    }

    func scale(scale: Float) {
        moveable?.scale(scale: scale)
    }

    func rotate(rotate: Float) {
        moveable?.rotate(rotate: rotate)
    }

    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        guard let timeline = timelineService?.timeline else { return }
        let position = streamingContext.getTimelineCurrentPosition(timeline)

        let stickers = timeline.getAnimatedStickers(byTimelinePosition: position)
        stickers?.forEach { sticker in
            let sticker = sticker as! NvsAnimatedSticker
            let vertices = sticker.getBoundingRectangleVertices() as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                if let stickerService = timelineService?.stickerService {
                    stickerService.timeline = timeline
                    stickerService.livewindow = livewindow
                    stickerService.sticker = sticker
                    moveable = stickerService
                    moveable?.drawRects()
                }
                return
            }
        }

        let captions = timeline.getCaptionsByTimelinePosition(position)
        captions?.forEach { caption in
            let cap = caption as! NvsCaption
            let vertices = cap.getBoundingVertices(NvsBoundingType_Frame) as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                if let captionService = timelineService?.captionService {
                    captionService.timeline = timeline
                    captionService.livewindow = livewindow
                    captionService.caption = cap
                    moveable = captionService
                    moveable?.drawRects()
                }
                return
            }
        }

        let comCaptions = timeline.getCompoundCaptions(byTimelinePosition: position)
        comCaptions?.forEach { comCaption in
            let comCap = comCaption as NvsCompoundCaption
            let vertices = comCap.getCompoundBoundingVertices(NvsBoundingType_Frame) as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                if let comCaptionService = timelineService?.comCaptionService {
                    comCaptionService.timeline = timeline
                    comCaptionService.livewindow = livewindow
                    comCaptionService.comCaption = comCap
                    moveable = comCaptionService
                    moveable?.drawRects()
                }
                return
            }
        }
    }

    func drawRects() {
        moveable?.drawRects()
    }
}
