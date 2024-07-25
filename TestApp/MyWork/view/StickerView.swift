//
//  StickerView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/18.
//

import UIKit
import JXSegmentedView
import PhotosUI

class StickerView: UIView, BottomViewService {
    weak var stickerService: StickerService?
    var segmentedView: JXSegmentedView!
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var listContainerView: JXSegmentedListContainerView!
    var didViewClose: (() -> Void)?
    var albumUtils = AlbumUtils()
    override func awakeFromNib() {
        super.awakeFromNib()
        // 初始化并配置 JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.frame = CGRect(x: 35, y: 0, width: bounds.width - 70, height: 50)
        addSubview(segmentedView)

        // 配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titles = ["sticker", "custom"]
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalColor = .black
        segmentedDataSource.titleSelectedColor = .red
        segmentedView.dataSource = segmentedDataSource

        // 配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor = .red
        segmentedView.indicators = [indicator]

        // 配置列表容器
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        segmentedView.listContainer = listContainerView
        addSubview(listContainerView)
        
        // 设置布局
        segmentedView.translatesAutoresizingMaskIntoConstraints = false
        listContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 25),
            segmentedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedView.heightAnchor.constraint(equalToConstant: 50),
            
            listContainerView.topAnchor.constraint(equalTo: segmentedView.bottomAnchor),
            listContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func show() {
        let height: CGFloat = 300
        let size = UIScreen.main.bounds.size
        self.frame = CGRectMake(0, size.height, size.width, height)
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, size.height - height, size.width, height)
        }
    }
    
    @IBAction func okClick(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { finish in
            self.removeFromSuperview()
        }
        didViewClose?()
    }
    
    @IBAction func closeClick(_ sender: Any) {
        stickerService?.deleteSticker()
        okClick(sender)
    }
    
    static func newInstance() -> BottomViewService {
        let nib = UINib(nibName: "StickerView", bundle: Bundle(for: StickerView.self))
        return nib.instantiate(withOwner: self).first as! BottomViewService
    }

}
// 实现 JXSegmentedListContainerViewDataSource 协议
extension StickerView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list =  ListViewController()
        if index == 0 {
            let path = Bundle.main.bundlePath + "/sticker/animationsticker"
            list.assetGetter = DataSource(path, typeString: "animatedsticker")
            list.packageList.didSelectedPackage = { [weak self] packagePath, licPath, index in
                self?.stickerService?.applyPackage(packagePath: packagePath, licPath: licPath)
            }
        } else if index == 1 {
            let path = Bundle.main.bundlePath + "/sticker/custom"
            list.assetGetter = DataSource(path, typeString: "animatedsticker")
            list.packageList.didSelectedPackage = { [weak self] packagePath, licPath, index in
                // album
                let viewController = self!.findViewController()!
                self?.albumUtils.openAlbum(viewController: viewController, mediaType: .image, multiSelect: false) { [weak self] assets in
                    viewController.dismiss(animated: true)
                    if assets.count > 0 {
                        let phasset = assets.first!
                        saveAssetToSandbox(asset: phasset) { url in
                            if let path = url?.absoluteString.replacingOccurrences(of: "file://", with: "") {
                                self?.stickerService?.applyCustomPackage(packagePath: packagePath, licPath: licPath, imagePath: path)
                            }
                        }
                        
                    }
                }
            }

        }
        return list
    }
}
