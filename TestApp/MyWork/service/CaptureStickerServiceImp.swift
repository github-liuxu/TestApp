//
//  CaptureStickerServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/25.
//

import UIKit
import NvStreamingSdkCore

class CaptureStickerServiceImp: NSObject {
    weak var rectable: Rectable?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var sticker: NvsAnimatedSticker?
    var livewindow: NvsLiveWindow?
    
    func getAnchorPoint(sticker: NvsAnimatedSticker?) -> CGPoint {
        guard let sticker = sticker else { return .zero }
        let vertices = sticker.getBoundingRectangleVertices() as NSArray
        let p1 = vertices[0] as! CGPoint
        let p2 = vertices[2] as! CGPoint
        let point = CGPoint(x: (p2.x + p1.x) / 2.0, y: (p2.y + p1.y) / 2.0)
        return point
    }
}

extension CaptureStickerServiceImp: StickerService {
    func deleteSticker() {
//        let count = streamingContext.getCaptureAnimatedStickerCount()
//        self.sticker = nil
//        (0..<count).forEach { element in
//            let sticker = streamingContext.getCaptureAnimatedSticker(by: element)
//            let vertices = sticker!.getBoundingRectangleVertices() as NSArray
//            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
//                self.sticker = sticker
//                return
//            }
//        }
//        streamingContext.removeCaptureAnimatedSticker(sticker.index)
        sticker = nil
    }

    func applyPackage(packagePath: String, licPath: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        streamingContext.appendCaptureAnimatedSticker(0, duration: 1000000000, animatedStickerPackageId: pid as String)
    }
    
    func applyCustomPackage(packagePath: String, licPath: String, imagePath: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        sticker = streamingContext.addCustomCaptureAnimatedSticker(0, duration: 1000000000, animatedStickerPackageId: pid as String, customImagePath: imagePath)
        drawRects()
    }
}

extension CaptureStickerServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let sticker = sticker else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        sticker.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
    }
    
    func scale(scale: Float) {
        guard let sticker = sticker else { return }
        sticker.scale(scale, anchor: getAnchorPoint(sticker: sticker))
        drawRects()
    }
    
    func rotate(rotate: Float) {
        guard let sticker = sticker else { return }
        let r = -rotate * Float(180.0/Double.pi)
        sticker.rotateAnimatedSticker(r)
        drawRects()
    }
    
    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        let count = streamingContext.getCaptureAnimatedStickerCount()
        self.sticker = nil
        (0..<count).forEach { element in
            let sticker = streamingContext.getCaptureAnimatedSticker(by: element)
            let vertices = sticker!.getBoundingRectangleVertices() as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                self.sticker = sticker
                return
            }
        }
        drawRects()
    }
    
    func drawRects() {
        if sticker == nil {
            rectable?.setPoints([])
            return
        }
        guard let livewindow = livewindow else { return }
        guard let sticker = sticker else { return }
        let vertices = sticker.getBoundingRectangleVertices() as NSArray
        var points = [CGPoint]()
        for point in vertices {
            let p = livewindow.mapCanonical(toView: point as! CGPoint)
            points.append(p)
        }
        rectable?.setPoints(points)
    }
}
