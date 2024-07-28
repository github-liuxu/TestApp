//
//  CaptureARSceneServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import NvStreamingSdkCore
import UIKit
import JXSegmentedView

protocol CaptureARSceneService {
    func readARSceneInfo()
}

class CaptureARSceneServiceImp: NSObject, CaptureARSceneService {
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var arsceneFx: NvsCaptureVideoFx?
    var oldPropsId = ""
    override init() {
        super.init()
        initAR()
        arsceneFx = streamingContext.appendBuiltinCaptureVideoFx("AR Scene")
        arsceneFx?.setBooleanVal("Max Faces Respect Min", val: true)
        arsceneFx?.setBooleanVal("Use Face Extra Info", val: true)
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
}

extension CaptureARSceneServiceImp: PackageService {
    func cancelAction() {
        arsceneFx?.setStringVal("Scene Id", val: oldPropsId)
    }
    
    func sureAction() {
        
    }
    
    func applyPackage(item: DataSourceItemProtocol) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(item.packagePath, license: item.licPath, type: NvsAssetPackageType_ARScene, sync: true, assetPackageId: pid)
        arsceneFx?.setStringVal("Scene Id", val: pid as String)
    }
}
