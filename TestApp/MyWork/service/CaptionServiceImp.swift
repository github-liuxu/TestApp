//
//  CaptionServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/4/30.
//

import Foundation
import NvStreamingSdkCore

class CaptionServiceImp: NSObject {
    weak var rectable: Rectable?
    var didCaptionTextChanged: ((String?) -> Void)?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var timeline: NvsTimeline?
    var caption: NvsCaption?
    var livewindow: NvsLiveWindow?
    var assetGetter: DataSource?
    override init() {
        super.init()
        let captionDir = Bundle.main.bundlePath + "/captionrenderer"
        assetGetter = DataSource(captionDir, typeString: "captionrenderer")
    }
    
}

extension CaptionServiceImp: CaptionService {
    func addCaption(text: String) -> NvsCaption {
        caption = (timeline?.addModularCaption(text, inPoint: 0, duration: timeline!.duration))!
        didCaptionTextChanged?(caption?.getText())
        drawRects()
        seek(timeline: timeline)
        return caption!
    }
    
    func deleteCaption() {
        timeline?.remove(caption as! NvsTimelineCaption?)
        caption = nil
        drawRects()
        seek(timeline: timeline)
    }
    
    func getAllCaption() -> [NvsCaption] {
        var captios = [NvsCaption]()
        if let cap = timeline?.getFirstCaption() {
            captios.append(cap)
            while let caption = timeline?.getNextCaption(cap) {
                captios.append(caption)
            }}
        return captios
    }
    
    func setCaptionText(text: String) {
        caption?.setText(text)
        drawRects()
        seek(timeline: timeline)
    }
    
    func setCaptionTextColor(text: String) {
        
    }
    
    func applyCaptionPackage(packagePath: String, licPath: String, type: String) {
        let pid = NSMutableString()
        if type == "captioncontext" {
            streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_CaptionContext, sync: true, assetPackageId: pid)
            caption?.applyModularCaptionContext(pid as String)
        } else if type == "captionrenderer" {
            streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_CaptionRenderer, sync: true, assetPackageId: pid)
            caption?.applyModularCaptionRenderer(pid as String)
        } else if type == "captionanimation" {
            streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_CaptionAnimation, sync: true, assetPackageId: pid)
            caption?.applyModularCaptionAnimation(pid as String)
        } else if type == "captioninanimation" {
            streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_CaptionInAnimation, sync: true, assetPackageId: pid)
            caption?.applyModularCaption(inAnimation: pid as String)
        } else if type == "captionoutanimation" {
            streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_CaptionOutAnimation, sync: true, assetPackageId: pid)
            caption?.applyModularCaptionOutAnimation(pid as String)
        }
        drawRects()
        seek(timeline: timeline)
    }
}

extension CaptionServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let caption = caption else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        caption.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
        seek(timeline: timeline)
    }
    
    func scale(scale: Float) {
        guard let caption = caption else { return }
        caption.scale(scale, anchor: caption.getAnchorPoint())
        drawRects()
        seek(timeline: timeline)
    }
    
    func rotate(rotate: Float) {
        guard let caption = caption else { return }
        let r = -rotate * Float(180.0/Double.pi)
        caption.rotateCaption(r, anchor: caption.getAnchorPoint())
        drawRects()
        seek(timeline: timeline)
    }
    
    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        guard let timeline = timeline else { return }
        let position = streamingContext.getTimelineCurrentPosition(timeline)
        let captions = timeline.getCaptionsByTimelinePosition(position)
        self.caption = nil
        captions?.forEach({ caption in
            let cap = caption as! NvsCaption
            let vertices = cap.getBoundingVertices(NvsBoundingType_Frame) as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                self.caption = cap
                return
            }
        })
        drawRects()
        seek(timeline: timeline)
    }
    
    func drawRects() {
        if caption == nil {
            rectable?.setPoints([])
            return
        }
        guard let livewindow = livewindow else { return }
        guard let caption = caption else { return }
        let vertices = caption.getBoundingVertices(NvsBoundingType_Frame) as NSArray
        var points = [CGPoint]()
        for point in vertices {
            let p = livewindow.mapCanonical(toView: point as! CGPoint)
            points.append(p)
        }
        rectable?.setPoints(points)
    }
}
