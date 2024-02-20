//
//  NvSequeceView.swift
//  TestDemo
//
//  Created by meicam on 2021/10/18.
//  Copyright © 2021 刘东旭. All rights reserved.
//

import UIKit

protocol NvSequeceCoverViewDelegate : NSObjectProtocol {
    func didSelectIndex(index: Int)
}

class TransitionView: UIView {
    var originCenter: CGPoint = .zero
}

class NvSequeceCoverView: UIView {
    weak var delegate: NvSequeceCoverViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(with points:Array<CGPoint>) {
        subviews.forEach { subView in
            if subView.classForCoder == TransitionView.self {
                subView.removeFromSuperview()
            }
        }
        var tag: Int = 0
        for point in points {
            let transitionView = TransitionView()
            transitionView.backgroundColor = .orange
            addSubview(transitionView)
            transitionView.originCenter = point
            transitionView.frame.size = CGSize(width: 20, height: 20)
            transitionView.center = point
            transitionView.tag = tag
            tag = tag+1
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
            transitionView.addGestureRecognizer(tap)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews {
            if view.frame.contains(point) {
                return view
            }
        }
        return nil
    }
    
    func updateSubViews(contentOffsetx:CGFloat) {
        subviews.forEach { subView in
            if subView.classForCoder == TransitionView.self {
                subView.center = CGPoint(x: (subView as! TransitionView).originCenter.x - contentOffsetx, y: subView.center.y)
            }
        }
    }
    
    @objc func tapGesture(_ gesture: UIGestureRecognizer) {
        if let view = gesture.view {
            delegate?.didSelectIndex(index: view.tag)
        }
    }
}
