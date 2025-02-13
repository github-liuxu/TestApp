//
//  PackagePanel.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import JXSegmentedView
import UIKit

protocol DataSourceFetchService {
    var didFetchSuccess: (() -> Void)? { get set }
    var didFetchError: ((Error) -> Void)? { get set }
    func fetchData()
}

protocol PackageService: NSObjectProtocol {
    func cancelAction()
    func sureAction()
    func applyPackage(item: DataSourceItemProtocol)
}

protocol PackageSubviewSource: NSObjectProtocol {
    func titles() -> [String]
    func customView(index: Int) -> JXSegmentedListContainerViewListDelegate
}

class PackagePanel: UIView, BottomViewService {
    private var segmentedView: JXSegmentedView!
    private var segmentedDataSource: JXSegmentedTitleDataSource!
    private var listContainerView: JXSegmentedListContainerView!
    var didViewClose: ((Bool) -> Void)?
    var packageService: PackageService?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.layer.cornerRadius = 8.0
        closeBtn.titleLabel?.font = .systemFont(ofSize: 16)
        closeBtn.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            closeBtn.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            closeBtn.widthAnchor.constraint(equalToConstant: 35),
            closeBtn.heightAnchor.constraint(equalToConstant: 35),
        ])

        let sureBtn = UIButton(type: .custom)
        sureBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        sureBtn.layer.cornerRadius = 8.0
        sureBtn.titleLabel?.font = .systemFont(ofSize: 16)
        sureBtn.addTarget(self, action: #selector(sureTapped(_:)), for: .touchUpInside)
        sureBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sureBtn)
        NSLayoutConstraint.activate([
            sureBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sureBtn.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            sureBtn.widthAnchor.constraint(equalToConstant: 35),
            sureBtn.heightAnchor.constraint(equalToConstant: 35),
        ])

        // 初始化并配置 JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        segmentedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentedView)
        NSLayoutConstraint.activate([
            segmentedView.leadingAnchor.constraint(equalTo: closeBtn.trailingAnchor, constant: 8),
            segmentedView.trailingAnchor.constraint(equalTo: sureBtn.leadingAnchor, constant: -8),
            segmentedView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            segmentedView.heightAnchor.constraint(equalToConstant: 35),
        ])

        // 配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titles = []
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
        listContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(listContainerView)

        // 设置布局
        NSLayoutConstraint.activate([
            listContainerView.topAnchor.constraint(equalTo: segmentedView.bottomAnchor),
            listContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static func newInstance() -> BottomViewService {
        return PackagePanel()
    }

    func show() {
        let height: CGFloat = 300
        frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: CGSize(width: screenWidth, height: height))
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, screenHeight - height, screenWidth, height)
        }
    }

    weak var dataSource: PackageSubviewSource? {
        didSet {
            segmentedDataSource.titles = dataSource?.titles() ?? []
            segmentedView.reloadData()
        }
    }

    @objc func closeTapped(_: UIButton) {
        didViewClose?(true)
        packageService?.cancelAction()
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    @objc func sureTapped(_: UIButton) {
        didViewClose?(false)
        packageService?.sureAction()
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension PackagePanel: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in _: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }

    func listContainerView(_: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        var view: JXSegmentedListContainerViewListDelegate!
        if let subview = dataSource?.customView(index: index) {
            view = subview
        } else { // 正常逻辑不会走else
            let list = PackageList.newInstance()
            list.didSelectedPackage = { [weak self] item in
                self?.packageService?.applyPackage(item: item)
            }
            view = list
        }
        return view
    }
}
