//
//  TransitionInteraction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/20.
//

import UIKit

class TransitionInteraction: NSObject {
    var view: AssetView
    var transitionAction: TransitionProtocal
    var transitionIndex: Int
    let transitionAssetGetter = DataSource()
    init(_ transitionView: AssetView, transitionAction: TransitionProtocal) {
        view = transitionView
        self.transitionAction = transitionAction
        transitionIndex = 0
        super.init()
        bind()
    }

    func bind() {
//        transitionAssetGetter.didLoadAsset({ datas in
//            view.dataSources.append(contentsOf: datas)
//            view.reload()
//        })
//
//        view.didSelectItem {[weak self] index, item in
//            guard let weakSelf = self else { return }
//            weakSelf.transitionAction.applyTransition(item: item, index: UInt32(weakSelf.transitionIndex))
//        }

//        view.didSliderValueChanged = {[weak self] value in
//            guard let weakSelf = self else { return }
//            weakSelf.filterAction.setFilterStrength(value: value)
//        }
    }
}
