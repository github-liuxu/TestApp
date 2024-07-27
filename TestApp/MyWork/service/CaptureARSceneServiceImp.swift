//
//  CaptureARSceneServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import NvStreamingSdkCore
import UIKit

protocol CaptureARSceneService {
    func cancelProps()
    func readARSceneInfo()
    func applyARScenePackage(packagePath: String, licPath: String, type: String)
}

class CaptureARSceneServiceImp: NSObject, CaptureARSceneService {
    var assetGetter: DataSource?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var arsceneFx: NvsCaptureVideoFx?
    var oldPropsId = ""
    override init() {
        super.init()
        let propsDir = Bundle.main.bundlePath + "/arscene"
        assetGetter = DataSource(propsDir, typeString: "arscene")
        initAR()
    }

    func initAR() {
        let licPath = Bundle.main.bundlePath + "/ms/meishesdk.lic"
        let ms_face240ModelPath = Bundle.main.bundlePath + "/ms/ms_face240_v2.0.8.model"
        let humanSegModelPath = Bundle.main.bundlePath + "/ms/ms_humanseg_v1.0.15.model"
        var sss = NvsStreamingContext.initHumanDetection(ms_face240ModelPath, licenseFilePath: licPath, features: Int32(NvsHumanDetectionFeature_FaceLandmark.rawValue | NvsHumanDetectionFeature_FaceAction.rawValue | NvsHumanDetectionFeature_SemiImageMode.rawValue))
        sss = NvsStreamingContext.initHumanDetectionExt(humanSegModelPath, licenseFilePath: licPath, features: Int32(NvsEffectSdkHumanDetectionFeature_Background.rawValue))
        print("加载模型: \(sss)")
    }

    func readARSceneInfo() {
        oldPropsId = arsceneFx?.getStringVal("Scene Id") ?? ""
    }

    func cancelProps() {
        arsceneFx?.setStringVal("Scene Id", val: oldPropsId)
    }

    func applyARScenePackage(packagePath: String, licPath: String, type: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_ARScene, sync: true, assetPackageId: pid)
        arsceneFx?.setStringVal("Scene Id", val: pid as String)
    }
}
