//
//  Utils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/18.
//

import Foundation

public func isPointInPolygon(point: CGPoint, polygon: [CGPoint]) -> Bool {
    guard polygon.count >= 4 else { return false }
    var isInside = false
    var j = polygon.count - 1
    
    for i in 0..<polygon.count {
        if (polygon[i].y < point.y && polygon[j].y >= point.y) || (polygon[j].y < point.y && polygon[i].y >= point.y) {
            if polygon[i].x + (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x {
                isInside.toggle()
            }
        }
        j = i
    }
    return isInside
}
