//
//  PropView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import UIKit
import JXSegmentedView
import NvStreamingSdkCore

class PropView: UIView, BottomViewService {
    var arsceneService: CaptureARSceneService?
    var segmentedView: JXSegmentedView!
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var listContainerView: JXSegmentedListContainerView!
    var didViewClose: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: DispatchWorkItem(block: { [weak self] in
            self?.arsceneService?.readARSceneInfo()
        }))
        // 初始化并配置 JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        addSubview(segmentedView)

        // 配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titles = ["2D", "3D"]
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
    
    @IBAction func cancel(_ sender: Any) {
        didViewClose?()
        arsceneService?.cancelProps()
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { finish in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        didViewClose?()
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { finish in
            self.removeFromSuperview()
        }
    }
    
    static func newInstance() -> any BottomViewService {
        let nib = UINib(nibName: "PropView", bundle: Bundle(for: PropView.self))
        return nib.instantiate(withOwner: self).first as! BottomViewService
    }
    
    func show() {
        let height: CGFloat = 300
        let size = UIScreen.main.bounds.size
        self.frame = CGRectMake(0, size.height, size.width, height)
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, size.height - height, size.width, height)
        }
    }
}

// 实现 JXSegmentedListContainerViewDataSource 协议
extension PropView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list =  ListViewController()
        list.packageList.didSelectedPackage = { [weak self] packagePath, licPath, type in
            self?.arsceneService?.applyARScenePackage(packagePath: packagePath, licPath: licPath, type: type)
        }
        if index == 0 {
            let arsceneDir = Bundle.main.bundlePath + "/arscene/2D"
            list.assetGetter = DataSource(arsceneDir, typeString: "arscene")
        } else if index == 1 {
            let arsceneDir = Bundle.main.bundlePath + "/arscene/3D"
            list.assetGetter = DataSource(arsceneDir, typeString: "arscene")
        }
        return list
    }
}
