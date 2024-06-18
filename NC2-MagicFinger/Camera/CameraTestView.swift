//
//  CameraTestView.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/18/24.
//


import SwiftUI
import SwiftData

struct CameraTestView: View {
    
    @StateObject var viewManager = CameraViewManager()
    
    var body: some View {
        VStack{
            viewManager.cameraPreview
                .ignoresSafeArea()
//                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//                .aspectRatio(1, contentMode: .fit)
            
        }
    }
}
