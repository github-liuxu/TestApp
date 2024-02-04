//
//  SequenceView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/4.
//

import UIKit
import NvStreamingSdkCore

class SequenceView: UIView {
    
    @IBOutlet weak var sequenceView: NvsMultiThumbnailSequenceView!
    var valueChangedAction: ((_ value: Int64)->())? = nil
    class func LoadView() -> SequenceView? {
        let nib = UINib.init(nibName: "SequenceView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as? SequenceView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = self.bounds.size.width
        sequenceView.delegate = self
        sequenceView.startPadding = width / 2.0
        sequenceView.endPadding = width / 2.0
        sequenceView.pointsPerMicrosecond = width / 20.0 / 1000000.0
        sequenceView.thumbnailImageFillMode = NvsThumbnailFillModeAspectCrop
        sequenceView.thumbnailAspectRatio = 1.0
        sequenceView.backgroundColor = .black
    }
    
    func sequenceInitLoad(videoTrack: NvsVideoTrack) {
        var descs = Array<NvsThumbnailSequenceDesc>()
        let clipCount = videoTrack.clipCount
        (0..<clipCount).forEach { index in
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
        }
        
        sequenceView.descArray = descs
    }
    
    func seekValue(_ value: Int64) {
        sequenceView.contentOffset = CGPoint.init(x: Double(value) * sequenceView.pointsPerMicrosecond, y: sequenceView.contentOffset.y)
    }

}

extension SequenceView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!scrollView.isDragging) {
            return
        }
        let value = scrollView.contentOffset.x/sequenceView.pointsPerMicrosecond
        valueChangedAction?(Int64(value))
    }
    
}
