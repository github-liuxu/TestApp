//
//  CaptureStickerServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/25.
//

import JXSegmentedView
import NvStreamingSdkCore
import UIKit

class CaptureStickerServiceImp: NSObject {
    weak var rectable: Rectable?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var sticker: NvsAnimatedSticker?
    var livewindow: NvsLiveWindow?
    var didFetchSuccess: (() -> Void)?
    var didFetchError: ((Error) -> Void)?

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
    func fetchData() {
        didFetchSuccess?()
    }

    func applyCustomPackage(item: DataSourceItemProtocol, imagePath: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        sticker = streamingContext.addCustomCaptureAnimatedSticker(0, duration: 1_000_000_000, animatedStickerPackageId: pid as String, customImagePath: imagePath)
        drawRects()
    }
}

extension CaptureStickerServiceImp: PackageService {
    func cancelAction() {}

    func sureAction() {}

    func applyPackage(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_AnimatedSticker, sync: true, assetPackageId: pid)
        sticker = streamingContext.appendCaptureAnimatedSticker(0, duration: 1_000_000_000, animatedStickerPackageId: pid as String)
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
        let r = -rotate * Float(180.0 / Double.pi)
        sticker.rotateAnimatedSticker(r)
        drawRects()
    }

    func tap(point: CGPoint) {
        guard let livewindow = livewindow else { return }
        let p1 = livewindow.mapView(toCanonical: point)
        let count = streamingContext.getCaptureAnimatedStickerCount()
        sticker = nil
        for element in 0 ..< count {
            let sticker = streamingContext.getCaptureAnimatedSticker(by: element)
            let vertices = sticker!.getBoundingRectangleVertices() as NSArray
            if isPointInPolygon(point: p1, polygon: vertices as! [CGPoint]) {
                self.sticker = sticker
                continue
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

extension CaptureStickerServiceImp: PackageSubviewSource {
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
