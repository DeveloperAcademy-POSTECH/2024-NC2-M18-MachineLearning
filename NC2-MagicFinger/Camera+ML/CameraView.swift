//
//  CameraView.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/20/24.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var viewManager: CameraViewManager
    
    var body: some View {
        VStack {
            viewManager.cameraPreview
                .ignoresSafeArea()

        }
    }
}
