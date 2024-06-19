//
//  CameraView.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/20/24.
//

import SwiftUI

struct CameraView: View {
    @StateObject var viewManager = CameraViewManager()

    var body: some View {
        VStack {
            viewManager.cameraPreview
                .ignoresSafeArea()

            Text(viewManager.handActionLabel)
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(.top, 20)
        }
    }
}
