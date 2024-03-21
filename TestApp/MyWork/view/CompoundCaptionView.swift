//
//  CompoundCaptionView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/20.
//

import UIKit

class CompoundCaptionView: UIView {
    
    var assetView: AssetView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nib = UINib.init(nibName: "AssetView", bundle: Bundle.main)
        assetView = nib.instantiate(withOwner: self).first as? AssetView
        assetView.slider.isHidden = true
        assetView.setCloseBlock = {
            self.removeFromSuperview()
        }
        addSubview(assetView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
