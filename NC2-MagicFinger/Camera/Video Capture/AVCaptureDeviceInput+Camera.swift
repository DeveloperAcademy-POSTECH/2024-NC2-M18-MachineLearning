//
//  AVCaptureDeviceInput+Camera.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/18/24.
//

import AVFoundation

extension AVCaptureDeviceInput {
    static func createCameraInput(position: AVCaptureDevice.Position, frameRate: Double) -> AVCaptureDeviceInput? {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return nil
        }
        guard camera.configureFrameRate(frameRate) else { return nil }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            return cameraInput
        } catch {
            print("Unable to create an input from the camera: \(error)")
            return nil
        }
    }
}
