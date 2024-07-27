//
//  SequenceView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/4.
//

import NvStreamingSdkCore
import UIKit

protocol TransitionCoverViewDelegate: NSObjectProtocol {
    func didSelectIndex(index: Int)
}

class SequenceView: UIView {
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var sequenceView: NvsMultiThumbnailSequenceView!
    weak var transitionCoverDelegate: TransitionCoverViewDelegate?
    let coverView = NvSequeceCoverView(frame: .zero)
    var valueChangedAction: ((_ value: Int64) -> Void)? = nil
    var addAlbmAction: (() -> Void)? = nil
    var didSelectClipIndex: ((_ index: UInt32) -> Void)? = nil
    class func LoadView() -> SequenceView? {
        let nib = UINib(nibName: "SequenceView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as? SequenceView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let width = bounds.size.width
        sequenceView.delegate = self
        sequenceView.startPadding = width / 2.0
        sequenceView.endPadding = width / 2.0
        sequenceView.pointsPerMicrosecond = width / 20.0 / 1_000_000.0
        sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop
        sequenceView.thumbnailAspectRatio = 1.0
        sequenceView.backgroundColor = .black
        addSubview(coverView)
        coverView.frame = sequenceView.bounds
        coverView.delegate = self
    }

    @IBAction func addAlbumClick(_: UIButton) {
        addAlbmAction?()
    }

    func sequenceInitLoad(videoTrack: NvsVideoTrack) {
        var array = [CGPoint]()
        var descs = [NvsThumbnailSequenceDesc]()
        let clipCount = videoTrack.clipCount
        for index in 0 ..< clipCount {
            let clip = videoTrack.getClipWith(index)
            let desc = NvsThumbnailSequenceDesc()
            desc.inPoint = clip!.inPoint
            desc.outPoint = clip!.outPoint
            desc.trimIn = clip!.trimIn
            desc.trimOut = clip!.trimOut
            desc.mediaFilePath = clip!.filePath
            if clip!.videoType == NvsVideoClipType_Image {
                desc.stillImageHint = true
            }

            descs.append(desc)

            let outpoint = clip!.outPoint
            let pointx = sequenceView.pointsPerMicrosecond * Double(outpoint)
            let point = CGPoint(x: pointx + sequenceView.startPadding, y: coverView.frame.size.height / 2.0)
            array.append(point)
        }

        sequenceView.descArray = descs
        coverView.reload(with: array.dropLast())
    }

    func seekValue(_ value: Int64) {
        sequenceView.contentOffset = CGPoint(x: Double(value) * sequenceView.pointsPerMicrosecond, y: sequenceView.contentOffset.y)
    }
}

extension SequenceView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        coverView.updateSubViews(contentOffsetx: scrollView.contentOffset.x)
        if !scrollView.isDragging {
            return
        }
        let value = scrollView.contentOffset.x / sequenceView.pointsPerMicrosecond
        valueChangedAction?(Int64(value))
    }
}

extension SequenceView: NvSequeceCoverViewDelegate {
    func didSelectIndex(index: Int) {
        transitionCoverDelegate?.didSelectIndex(index: index)
    }
}
