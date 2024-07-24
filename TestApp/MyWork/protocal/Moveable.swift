//
//  Moveable.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/1.
//

import Foundation
import NvStreamingSdkCore

protocol Moveable {
    func translate(prePoint: CGPoint, curPoint: CGPoint)
    func scale(scale: Float)
    func rotate(rotate: Float)
    func tap(point: CGPoint)
    func drawRects()
}
