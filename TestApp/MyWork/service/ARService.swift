//
//  ARService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/4/23.
//

import Foundation
import NvStreamingSdkCore

struct ARService {
    func initAR() {
        let licPath = Bundle.main.bundlePath + "/ms/meishesdk.lic"
        let humanSegModelPath = Bundle.main.bundlePath + "/ms/ms_humanseg_v1.0.15.model"
        let sss = NvsStreamingContext.initHumanDetection(humanSegModelPath, licenseFilePath: licPath, features: Int32(NvsEffectSdkHumanDetectionFeature_Background.rawValue))
        print("加载模型: \(sss)")
    }
}
