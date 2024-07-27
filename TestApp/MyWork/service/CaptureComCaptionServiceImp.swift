//
//  CaptureComCaptionServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/25.
//

import UIKit
import NvStreamingSdkCore

class CaptureComCaptionServiceImp: NSObject {
    var comCaption: NvsCompoundCaption?
    var timeline: NvsTimeline!
    var livewindow: NvsLiveWindow?
    var streamingContext = NvsStreamingContext.sharedInstance()!
    weak var rectable: Rectable?
    var selectIndex: UInt32 = 0

}

extension CaptureComCaptionServiceImp: ComCaptionService {
    func applyComCaptionPackage(item: any DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        applyComCaption(packageId: pid as String)
    }
    
    func applyComCaption(packageId: String) {
        let pid = packageId
        if let comCaptionFx = comCaption as? NvsCaptureCompoundCaption {
            streamingContext.removeCaptureCompoundCaption(selectIndex)
            self.comCaption = nil
        }
        if pid.count > 0 {
            selectIndex = streamingContext.getCaptureCompoundCaptionCount() + 1
            comCaption = streamingContext.appendCaptureCompoundCaption(0, duration: 1000000000, compoundCaptionPackageId: pid)
        }
        drawRects()
    }
}

extension CaptureComCaptionServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let comCaption = comCaption else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        comCaption.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
    }
    
    func scale(scale: Float) {
        guard let comCaption = comCaption else { return }
        comCaption.scale(scale, anchor: comCaption.getAnchorPoint())
        drawRects()
    }
    
    func rotate(rotate: Float) {
        guard let comCaption = comCaption else { return }
        let r = -rotate * Float(180.0/Double.pi)
        comCaption.rotateCaption(r, anchor: comCaption.getAnchorPoint())
        drawRects()
    }
    
    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        let count = streamingContext.getCaptureCompoundCaptionCount()
        comCaption = nil
        selectIndex = 0
        for (index, element) in (0..<count).enumerated() {
            if let compoundCaption = streamingContext.getCaptureCompoundCaption(by: UInt32(index)) {
                let vertices = compoundCaption.getCompoundBoundingVertices(NvsBoundingType_Frame) as NSArray
                if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                    self.comCaption = compoundCaption
                    selectIndex = UInt32(index)
                    return
                }
            }
        }
        drawRects()
    }
    
    func drawRects() {
        if comCaption == nil {
            rectable?.setPoints([])
            return
        }
        guard let livewindow = livewindow else { return }
        guard let comCaption = comCaption else { return }
        let vertices = comCaption.getCompoundBoundingVertices(NvsBoundingType_Frame) as NSArray
        var points = [CGPoint]()
        for point in vertices {
            let p = livewindow.mapCanonical(toView: point as! CGPoint)
            points.append(p)
        }
        rectable?.setPoints(points)
        if comCaption.captionCount == 1 {
            return
        }
        var subPoints: [[CGPoint]] = []
        if let _comCaption = comCaption as? NvsTimelineCompoundCaption {
            (0..<_comCaption.captionCount).forEach { index in
                let vertices = _comCaption.getBoundingVertices(index, boundingType: NvsBoundingType_Text) as NSArray
                var points = [CGPoint]()
                for point in vertices {
                    let p = livewindow.mapCanonical(toView: point as! CGPoint)
                    points.append(p)
                }
                subPoints.append(points)
            }
            rectable?.setSubPoints(subPoints)
        }
    }
}