//
//  Utils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/27.
//

import Foundation
import UIKit

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

let Documents = NSHomeDirectory() + "/Documents/"

func currentDateAndTime() -> String {
    let date = Date()
    let zone = NSTimeZone.system
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYYMMddHHmmssSSS"
    dateFormatter.timeZone = zone
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func formatTime(time: Int64) -> String {
    let t = time / 1_000_000
    let sec = t % 60
    let min = t / 60
    return "\(min):\(sec)"
}
