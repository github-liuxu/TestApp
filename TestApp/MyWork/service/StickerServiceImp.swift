//
//  StickerServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/18.
//

import JXSegmentedView
import NvStreamingSdkCore
import UIKit

protocol StickerService: NSObjectProtocol, DataSourceFetchService {
    func applyCustomPackage(item: DataSourceItemProtocol, imagePath: String)
}

class StickerServiceImp: NSObject {
    weak var rectable: Rectable?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var timeline: NvsTimeline?
    var sticker: NvsAnimatedSticker?
    var livewindow: NvsLiveWindow?
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?

    override init() {
        super.init()
    }

    func getAnchorPoint(sticker: NvsAnimatedSticker?) -> CGPoint {
        guard let sticker = sticker else { return .zero }
        let vertices = sticker.getBoundingRectangleVertices() as NSArray
        let p1 = vertices[0] as! CGPoint
        let p2 = vertices[2] as! CGPoint
        let point = CGPoint(x: (p2.x + p1.x) / 2.0, y: (p2.y + p1.y) / 2.0)
        return point
    }
}

extension StickerServiceImp: Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint) {
        guard let sticker = sticker else { return }
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: prePoint)
        let p2 = livewindow.mapView(toCanonical: curPoint)
        sticker.translate(CGPoint(x: p2.x - p1.x, y: p2.y - p1.y))
        drawRects()
        seek(timeline: timeline)
    }

    func scale(scale: Float) {
        guard let sticker = sticker else { return }
        sticker.scale(scale, anchor: getAnchorPoint(sticker: sticker))
        drawRects()
        seek(timeline: timeline)
    }

    func rotate(rotate: Float) {
        guard let sticker = sticker else { return }
        let r = -rotate * Float(180.0 / Double.pi)
        sticker.rotateAnimatedSticker(r)
        drawRects()
        seek(timeline: timeline)
    }

    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        guard let timeline = timeline else { return }
        let position = streamingContext.getTimelineCurrentPosition(timeline)
        let stickers = timeline.getAnimatedStickers(byTimelinePosition: position)
        sticker = nil
        stickers?.forEach { sticker in
            let sticker = sticker as! NvsAnimatedSticker
            let vertices = sticker.getBoundingRectangleVertices() as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                self.sticker = sticker
                return
            }
        }
        drawRects()
        seek(timeline: timeline)
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

extension StickerServiceImp: StickerService {
    func fetchData() {
        didFetchSuccess?()
    }

    func applyCustomPackage(item: DataSourceItemProtocol, imagePath: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        if let sticker = sticker as? NvsTimelineAnimatedSticker {
            timeline?.remove(sticker)
        }
        sticker = timeline?.addCustomAnimatedSticker(0, duration: timeline?.duration ?? 1_000_000, animatedStickerPackageId: pid as String, customImagePath: imagePath)
        drawRects()
        seek(timeline: timeline)
    }
}

extension StickerServiceImp: PackageService {
    func cancelAction() {
        if let sticker = sticker as? NvsTimelineAnimatedSticker {
            timeline?.remove(sticker)
        }
        sticker = nil
    }

    func sureAction() {}

    func applyPackage(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        if let sticker = sticker as? NvsTimelineAnimatedSticker {
            timeline?.remove(sticker)
        }
        sticker = timeline?.addAnimatedSticker(0, duration: timeline?.duration ?? 0, animatedStickerPackageId: pid as String)
        drawRects()
        seek(timeline: timeline)
    }
}

extension StickerServiceImp: PackageSubviewSource {
    func titles() -> [String] {
        return ["sticker", "custom"]
    }

    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        let assetDir = Bundle.main.bundlePath + "/sticker"
        if index == 0 {
            var asset = DataSource(assetDir + "/animationsticker", typeString: "animatedsticker")
            asset.didFetchSuccess = { dataSource in
                list.dataSource = dataSource
            }
            asset.didFetchError = { _ in
            }
            asset.fetchData()
            list.didSelectedPackage = { [weak self] item in
                self?.applyPackage(item: item)
            }
        } else if index == 1 {
            var asset = DataSource(assetDir + "/custom", typeString: "animatedsticker")
            asset.didFetchSuccess = { dataSource in
                list.dataSource = dataSource
            }
            asset.didFetchError = { _ in
            }
            asset.fetchData()
            list.didSelectedPackage = { [weak self] item in
                // album
                let viewController = list.findViewController()!
                let albumUtils = AlbumUtils()
                albumUtils.openAlbum(viewController: viewController, mediaType: .image, multiSelect: false) { [weak self] assets in
                    viewController.dismiss(animated: true)
                    if assets.count > 0 {
                        let phasset = assets.first!
                        saveAssetToSandbox(asset: phasset) { url in
                            if let path = url?.absoluteString.replacingOccurrences(of: "file://", with: "") {
                                self?.applyCustomPackage(item: item, imagePath: path)
                            }
                        }
                    }
                }
            }
        }
        return list
    }
}
