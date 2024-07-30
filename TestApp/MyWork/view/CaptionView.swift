//
//  CaptionView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/4/16.
//

import JXSegmentedView
import NvStreamingSdkCore
import UIKit

class CaptionView: UIView, BottomViewService {
    var captionService: CaptionService?
    var segmentedView: JXSegmentedView!
    var segmentedDataSource: JXSegmentedTitleDataSource!
    var listContainerView: JXSegmentedListContainerView!
    @IBOutlet var textField: UITextField!
    var didViewClose: ((Bool) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        // 添加监听器，当文本发生变化时调用textFieldDidChange方法
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // 初始化并配置 JXSegmentedView
        segmentedView = JXSegmentedView()
        segmentedView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        addSubview(segmentedView)

        // 配置数据源
        segmentedDataSource = JXSegmentedTitleDataSource()
        segmentedDataSource.titles = ["renderer", "context", "animation", "inAni", "outAni"]
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
        // 监听键盘事件
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        // 移除观察者
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        // 在这里处理文本发生变化后的逻辑
        if let text = textField.text {
            captionService?.setCaptionText(text: text)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // 调整视图布局，避免被键盘遮挡
        let keyboardHeight = keyboardFrame.height
        let p = convert(CGPoint(x: 0, y: textField.frame.maxY), to: superview)
        let size = UIScreen.main.bounds.size
        let offset = keyboardHeight - (size.height - p.y)
        frame.origin.y = frame.origin.y - offset
    }

    @objc func keyboardWillHide(notification _: NSNotification) {
        // 恢复视图布局
        let size = UIScreen.main.bounds.size
        frame.origin.y = size.height - 300
    }

    func show() {
        let height: CGFloat = 300
        let size = UIScreen.main.bounds.size
        frame = CGRectMake(0, size.height, size.width, height)
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, size.height - height, size.width, height)
        }
    }

    // 处理 “Done” 按钮点击事件的方法
    func handleDoneButtonTap() {
        guard let text = textField.text else { return }
        print("User entered: \(text)")
        // 在这里添加你的处理逻辑，例如验证输入或提交数据
    }

    @IBAction func close(_: Any) {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { _ in
            self.removeFromSuperview()
        }
        didViewClose?(false)
    }

    @IBAction func closeDelete(_: Any) {
        captionService?.deleteCaption()
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { _ in
            self.removeFromSuperview()
        }
        didViewClose?(true)
    }

    static func newInstance() -> BottomViewService {
        let nib = UINib(nibName: "CaptionView", bundle: Bundle(for: CaptionView.self))
        return nib.instantiate(withOwner: self).first as! BottomViewService
    }
}

// 实现 JXSegmentedListContainerViewDataSource 协议
extension CaptionView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in _: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }

    func listContainerView(_: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let list = PackageList.newInstance()
        list.didSelectedPackage = { [weak self] item in
            self?.captionService?.applyCaptionPackage(packagePath: item.packagePath, licPath: item.licPath, type: item.type)
        }
        var asset: DataSource!
        if index == 0 {
            let captionDir = Bundle.main.bundlePath + "/captions/captionrenderer"
            asset = DataSource(captionDir, typeString: "captionrenderer")
        } else if index == 1 {
            let captionDir = Bundle.main.bundlePath + "/captions/captioncontext"
            asset = DataSource(captionDir, typeString: "captioncontext")
        } else if index == 2 {
            let captionDir = Bundle.main.bundlePath + "/captions/captionanimation"
            asset = DataSource(captionDir, typeString: "captionanimation")
        } else if index == 3 {
            let captionDir = Bundle.main.bundlePath + "/captions/captioninanimation"
            asset = DataSource(captionDir, typeString: "captioninanimation")
        } else if index == 4 {
            let captionDir = Bundle.main.bundlePath + "/captions/captionoutanimation"
            asset = DataSource(captionDir, typeString: "captionoutanimation")
        }
        asset.didFetchSuccess = { dataSource in
            list.dataSource = dataSource
        }
        asset.didFetchError = { error in
            
        }
        asset.fetchData()
        return list
    }
}

extension CaptionView: UITextFieldDelegate {
    // 实现 UITextFieldDelegate 方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 隐藏键盘
        handleDoneButtonTap() // 调用处理方法
        return true
    }
}
