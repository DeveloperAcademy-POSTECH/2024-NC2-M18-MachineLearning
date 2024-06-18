//
//  CameraTestView.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/18/24.
//


import SwiftUI

struct CameraTestView: View {
    
    @StateObject var viewManager = CameraViewManager()
    
    var body: some View {
        VStack{
            viewManager.cameraPreview
                .ignoresSafeArea()
            
        }
    }
}
