//
//  ComCaptionServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/17.
//

import UIKit
import NvStreamingSdkCore

protocol ComCaptionService {
    var dataSources: [DataSourceItem] { get set }
    func applyComCaptionIndex(index: Int)
    func applyComCaption(packageId: String)
}

class ComCaptionServiceImp: NSObject {
    var dataSources: [DataSourceItem] = []
    let comCaptionAssetGetter = DataSource()
    var comCaption: NvsCompoundCaption?
    var timeline: NvsTimeline!
    var livewindow: NvsLiveWindow?
    var streamingContext = NvsStreamingContext.sharedInstance()!
    weak var rectable: Rectable?
    override init() {
        super.init()
        let captionDir = Bundle.main.bundlePath + "/compoundcaption"
        dataSources = comCaptionAssetGetter.loadAsset(path: captionDir, typeString: "compoundcaption")
    }
}

extension ComCaptionServiceImp: ComCaptionService {
    func applyComCaptionIndex(index: Int) {
        let item = dataSources[index]
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_CompoundCaption, sync: true, assetPackageId: pid)
        applyComCaption(packageId: pid as String)
    }
    
    func applyComCaption(packageId: String) {
        let pid = packageId
        if let comCaptionFx = comCaption as? NvsTimelineCompoundCaption {
            timeline.remove(comCaptionFx)
            self.comCaption = nil
        }
        if pid.count > 0 {
            comCaption = timeline.addCompoundCaption(0, duration: timeline.duration, compoundCaptionPackageId: pid)
        }
        seek(timeline: timeline)
    }
}

extension ComCaptionServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let comCaption = comCaption else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        comCaption.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
        seek(timeline: timeline)
    }
    
    func scale(scale: Float) {
        guard let comCaption = comCaption else { return }
        comCaption.scale(scale, anchor: comCaption.getAnchorPoint())
        drawRects()
        seek(timeline: timeline)
    }
    
    func rotate(rotate: Float) {
        guard let comCaption = comCaption else { return }
        let r = -rotate * Float(180.0/Double.pi)
        comCaption.rotateCaption(r, anchor: comCaption.getAnchorPoint())
        drawRects()
        seek(timeline: timeline)
    }
    
    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        guard let timeline = timeline else { return }
        let position = streamingContext.getTimelineCurrentPosition(timeline)
        let comCaptions = timeline.getCaptionsByTimelinePosition(position)
        comCaption = nil
        comCaptions?.forEach({ comCaption in
            let comCap = comCaption as! NvsCompoundCaption
            let vertices = comCap.getCompoundBoundingVertices(NvsBoundingType_Frame) as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                self.comCaption = comCap
                return
            }
        })
        drawRects()
        seek(timeline: timeline)
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
    }
}
