//
//  CompoundCaptionInteraction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/20.
//

import UIKit

class CompoundCaptionInteraction: NSObject {
    var compoundCaptionView: CompoundCaptionView
    var compoundCaptionAction: CompoundCaptionProtocal
    let compoundCaptionAssetGetter = CompoundCaptionGetter()
    init(_ compoundCaptionView: CompoundCaptionView, compoundCaptionAction: CompoundCaptionProtocal) {
        self.compoundCaptionView = compoundCaptionView
        self.compoundCaptionAction = compoundCaptionAction
        super.init()
        bind()
    }
    
    func bind() {
        compoundCaptionAssetGetter.didLoadAsset({ datas in
            compoundCaptionView.assetView.dataSources.append(contentsOf: datas)
            compoundCaptionView.assetView.reload()
        })
        
        compoundCaptionView.assetView.didSelectItem {[weak self] index, item in
            guard let weakSelf = self else { return }
            weakSelf.compoundCaptionAction.applyCompoundCaption(item: item)
        }
    }
}
