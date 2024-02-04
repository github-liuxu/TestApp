//
//  FilterInteraction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/4.
//

import UIKit

class FilterInteraction: NSObject {
    var filterView: AssetView
    var filterAction: FilterProtocal
    let filterAssetGetter = FilterAssetGetter()
    init(_ filterView: AssetView, filterAction: FilterProtocal) {
        self.filterView = filterView
        self.filterAction = filterAction
        super.init()
        bind()
    }
    
    func bind() {
        filterAssetGetter.didLoadAsset({ datas in
            filterView.dataSources.append(contentsOf: datas)
            filterView.reload()
        })
        
        filterView.didSelectItem {[weak self] index, item in
            guard let weakSelf = self else { return }
            weakSelf.filterAction.applyFilter(item: item)
            weakSelf.filterView.slider.value = weakSelf.filterAction.getFilterStrength()
        }
        
        filterView.didSliderValueChanged = {[weak self] value in
            guard let weakSelf = self else { return }
            weakSelf.filterAction.setFilterStrength(value: value)
        }
    }

}
