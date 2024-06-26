//
//  CameraPreviewView.swift
//  testFinger
//
//  Created by Chang Jonghyeon on 6/19/24.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    let session: AVCaptureSession

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()

        view.videoPreviewLayer.session = session
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoRotationAngle = 90

        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {

    }
}
