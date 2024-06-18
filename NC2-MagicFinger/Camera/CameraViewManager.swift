//
//  CameraViewManager.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/18/24.
//

import SwiftUI
import AVFoundation
import Combine

class CameraViewManager: ObservableObject {
    let manager: CameraManager
    @Published var cameraPreview: AnyView
    
    init() {
        manager = CameraManager()
        cameraPreview = AnyView(
            CameraPreviewView(session: manager.session)
        )
        
        configure()
    }
    
    // 초기 설정
    private func configure() {
        manager.requestAndCheckPermissions()
    }
    
    
}
