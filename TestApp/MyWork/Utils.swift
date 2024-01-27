//
//  Utils.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/27.
//

import Foundation

func currentDateAndTime() -> String {
    let date = Date()
    let zone = NSTimeZone.system
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYYMMddHHmmssSSS"
    dateFormatter.timeZone = zone
    let dateString = dateFormatter.string(from: date);
    return dateString
}

func formatTime(time: Int64) -> String {
    let t = time / 1000000
    let sec = t % 60
    let min = t / 60
    return "\(min):\(sec)"
}
