//
//  CameraManager.swift
//  NC2-MagicFinger
//
//  Created by Chang Jonghyeon on 6/18/24.
//

import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    
    /// Input과 Output을 연결하는 Session
    var session = AVCaptureSession()
    
//    /// 실제 디바이스 연결을 통한 Input
//    private var videoDeviceInput: AVCaptureDeviceInput!
//    private let output = AVCapturePhotoOutput()
    
    private var videoCapture: VideoCapture?
    
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    // 카메라 셋업 과정을 담당하는 함수
    func setUpCamera() {
        guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        sessionQueue.async { [weak self] in
            
            guard let self = self else { return }
            do { // 카메라가 사용 가능하면 세션에 input과 output을 연결
                let videoDeviceInput = try AVCaptureDeviceInput(device: device)
                self.addInputToSession(input: videoDeviceInput)
//                addOutputToSession(output: output)
                
//                // 줌 배율 설정
//                do {
//                    try device.lockForConfiguration()
//                    device.videoZoomFactor = device.minAvailableVideoZoomFactor
//                    device.unlockForConfiguration()
//                } catch {
//                    print("Error locking configuration: \(error)")
//                }
                
                self.startSession()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    // 카메라 권한 요청 및 상태 확인
    func requestAndCheckPermissions() {
        // 상태 확인
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    self?.setUpCamera()
                }
            }
        case .restricted, .denied:
            print("권한 거부 / 제한")
        case .authorized:
            // 이미 권한 받은 경우
            setUpCamera()
        @unknown default:
            print("알수없는 권한 상태")
        }
    }

    
    // 세션 시작
    private func startSession() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    // 세션 정지
    private func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    // 세션에 입력 추가
    private func addInputToSession(input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Input이 추가되지 않음")
        }
    }
    
//    // 세션에 출력 추가
//    private func addOutputToSession(output: AVCapturePhotoOutput) {
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        } else {
//            print("Output이 추가되지 않음")
//        }
//    }
    
    func startVideoCapture() {
            videoCapture = VideoCapture()
            videoCapture?.delegate = self
            videoCapture?.isEnabled = true
        }

    func stopVideoCapture() {
        videoCapture?.isEnabled = false
    }
}

extension CameraManager: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        // Frame Publisher에서 프레임을 구독하여 필요한 작업 수행
    }
}


//// 사진 캡처 델리게이트
//extension CameraManager: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
//        
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
//        // AudioServicesDisposeSystemSoundID(1108)
//        
//    }
//    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
//        // AudioServicesDisposeSystemSoundID(1108)
//    }
//}
