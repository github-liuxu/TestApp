//
//  CaptureCaptionServiceImp.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/21.
//

import UIKit
import NvStreamingSdkCore

class CaptureCaptionServiceImp: NSObject {
    weak var rectable: Rectable?
    var didCaptionTextChanged: ((String?) -> Void)?
    var caption: NvsCaption?
    var livewindow: NvsLiveWindow?
    var assetGetter: DataSource?
    override init() {
        super.init()
        let captionDir = Bundle.main.bundlePath + "/captionrenderer"
        assetGetter = DataSource(captionDir, typeString: "captionrenderer")
    }
    
    func clear() {
        let streamingContext = NvsStreamingContext.sharedInstance()!
        streamingContext.removeAllCaptureCaption()
        caption = nil
    }
    
}
extension CaptureCaptionServiceImp: CaptionService {
    func addCaption(text: String) -> NvsCaption {
        let streamingContext = NvsStreamingContext.sharedInstance()!
        caption = streamingContext.appendCaptureModularCaption(text, offsetTime: 0, duration: 1000000000)
        didCaptionTextChanged?(caption?.getText())
        drawRects()
        return caption!
    }
    
    func deleteCaption() {
        let streamingContext = NvsStreamingContext.sharedInstance()!
        let count = streamingContext.getCaptureCaptionCount()
        streamingContext.removeCaptureCaption(count - 1)
        caption = nil
        drawRects()
    }
    
    func getAllCaption() -> [NvsCaption] {
        var captios = [NvsCaption]()
//        if let cap = timeline?.getFirstCaption() {
//            captios.append(cap)
//            while let caption = timeline?.getNextCaption(cap) {
//                captios.append(caption)
//            }}
        return captios
    }
    
    func setCaptionText(text: String) {
        caption?.setText(text)
        drawRects()
    }
    
    func setCaptionTextColor(text: String) {
        
    }
    
    func applyCaptionPackage(packagePath: String, licPath: String, type: String) {
        let streamingContext = NvsStreamingContext.sharedInstance()!
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
    }
}

extension CaptureCaptionServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let caption = caption else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        caption.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
    }
    
    func scale(scale: Float) {
        guard let caption = caption else { return }
        caption.scale(scale, anchor: caption.getAnchorPoint())
        drawRects()
    }
    
    func rotate(rotate: Float) {
        guard let caption = caption else { return }
        let r = -rotate * Float(180.0/Double.pi)
        caption.rotateCaption(r, anchor: caption.getAnchorPoint())
        drawRects()
    }
    
    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        let streamingContext = NvsStreamingContext.sharedInstance()!
        let count = streamingContext.getCaptureCaptionCount()
        self.caption = nil
        (0..<count).forEach { index in
            if let caption = streamingContext.getCaptureCaption(by: index) {
                let vertices = caption.getBoundingVertices(NvsBoundingType_Frame) as NSArray
                if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                    self.caption = caption
                    return
                }
            }
        }
        drawRects()
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
