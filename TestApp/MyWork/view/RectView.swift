//
//  RectView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/21.
//

import UIKit

protocol Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint)
    func scale(scale: Float)
    func rotate(rotate: Float)
    func tap(point: CGPoint)
    func drawRects()
}

protocol Rectable: NSObjectProtocol {
    func setPoints(_ points: [CGPoint])
    func setSubPoints(_ points: [[CGPoint]])
}

class RectView: UIView, Rectable {
    var panGesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    var rotateGesture: UIRotationGestureRecognizer!
    var pinchGesture: UIPinchGestureRecognizer!
    private var points: [CGPoint] = []
    private var subPoints: [[CGPoint]] = []
    var moveable: Moveable?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        addGestureRecognizer(panGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        addGestureRecognizer(tapGesture)
        rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(gesture:)))
        rotateGesture.delegate = self
        addGestureRecognizer(rotateGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        addGestureRecognizer(panGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        addGestureRecognizer(tapGesture)
        rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(gesture:)))
        rotateGesture.delegate = self
        addGestureRecognizer(rotateGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
    }

    @objc func pan(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view)
        let location = gesture.location(in: view)
        switch gesture.state {
        case .began:
            break
        case .changed:
            moveable?.translate(prePoint: CGPoint(x: location.x - translation.x, y: location.y - translation.y), curPoint: location)
        case .ended:
            // 获取移动前和移动后的点
            break
        default:
            break
        }
        gesture.setTranslation(.zero, in: view)
    }

    @objc func tap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let location = gesture.location(in: view)
        moveable?.tap(point: location)
    }

    @objc func rotate(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .changed:
            moveable?.rotate(rotate: Float(gesture.rotation))
        default:
            break
        }
        gesture.rotation = 0
    }

    @objc func pinch(gesture: UIPinchGestureRecognizer) {
        moveable?.scale(scale: Float(gesture.scale))
        gesture.scale = 1
    }

    // 设置点并触发重绘
    func setPoints(_ points: [CGPoint]) {
        subPoints = []
        self.points = points
        setNeedsDisplay() // 触发重绘
    }

    func setSubPoints(_ points: [[CGPoint]]) {
        subPoints = points
        setNeedsDisplay() // 触发重绘
    }

    func drawPoints(points: [CGPoint]) {
        guard points.count == 4 else { return } // 确保有4个点

        // 创建路径
        let path = UIBezierPath()
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.addLine(to: points[3])
        path.close()
        // 设置路径的属性
        path.lineWidth = 1.0
        let dashes: [CGFloat] = [6, 2] // 6个点的线，2个点的间隔
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        UIColor.white.setStroke()

        // 绘制路径
        path.stroke()
    }

    // 绘制方法
    override func draw(_: CGRect) {
        drawPoints(points: points)
        for points in subPoints {
            drawPoints(points: points)
        }
    }
}

extension RectView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
