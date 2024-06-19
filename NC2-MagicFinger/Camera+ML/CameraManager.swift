import SwiftUI
import AVFoundation
import Vision
import CoreML

class CameraManager: NSObject, ObservableObject {
    
    var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let output = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let model = try! HandActionClassifier(configuration: MLModelConfiguration())
    
    @Published var handActionLabel: String = "Starting Up"
    
    private var poseWindow = [VNHumanHandPoseObservation?](repeating: nil, count: 60)
    private var currentIndex = 0
    
//    private var previousLabel: String?
//    private var sameLabelCount = 0
//    private let sameLabelThreshold = 5 // 동일한 예측 결과가 연속으로 나타나는 횟수 임계값
//    private var isProcessing = false
    
//    private var queue = [MLMultiArray]()
//    private let queueSize = 60 // 학습 데이터 기반으로 결정
//    private var frameCounter = 0
//    private var queueSamplingCounter = 0
//    private let queueSamplingCount = 1 // 모든 프레임을 사용
//    private let handActionConfidenceThreshold: Double = 0.98 // 신뢰도 임계값
    
    
    func setUpCamera() {
        guard let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                self.videoDeviceInput = try AVCaptureDeviceInput(device: device)
                self.addInputToSession(input: self.videoDeviceInput)
                self.addOutputToSession(output: self.output)
                
                self.output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                
                try device.lockForConfiguration()
                device.videoZoomFactor = device.minAvailableVideoZoomFactor
                device.unlockForConfiguration()
                
                self.startSession()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    self?.setUpCamera()
                }
            }
        case .restricted, .denied:
            print("권한 거부 / 제한")
        case .authorized:
            setUpCamera()
        @unknown default:
            print("알수없는 권한 상태")
        }
    }
    
    private func startSession() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    private func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    private func addInputToSession(input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Input이 추가되지 않음")
        }
    }
    
    private func addOutputToSession(output: AVCaptureVideoDataOutput) {
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        } else {
            print("Output이 추가되지 않음")
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
//        if isProcessing {
//            return
//        }
        handPoseRequest.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]) //😀
        do {
            try handler.perform([handPoseRequest]) //😀
            if let results = handPoseRequest.results?.first {
                processHandPoseObservation(results)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func processHandPoseObservation(_ observation: VNHumanHandPoseObservation) {
        
//        frameCounter += 1
//
//        do {
//            let multiArray = try createMLMultiArray(from: observation)
////            let multiArray = try observation.keypointsMultiArray()
//            queue.append(multiArray)
//            queue = Array(queue.suffix(queueSize)) // 최신 60개의 자세 유지
//
//            queueSamplingCounter += 1
//            if queue.count == queueSize && queueSamplingCounter % queueSamplingCount == 0 {
//                let poses = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
//                let input = HandActionClassifierInput(poses: poses)
//                let prediction = try? model.prediction(input: input)
//
//                guard let label = prediction?.label,
//                      let confidence = prediction?.labelProbabilities[label] else { return }
//
//                if confidence > handActionConfidenceThreshold {
//                    DispatchQueue.main.async {
//                        self.handActionLabel = label
//                        print("Detected hand action: \(label) & confidence: \(confidence)")
//                    }
//                }
//            }
        
        
        
        poseWindow[currentIndex] = observation
        currentIndex = (currentIndex + 1) % poseWindow.count
        
        if poseWindow.contains(where: { $0 == nil }) {
            return
        }
        
        do {
            let multiArray = try createMLMultiArray(from: poseWindow)
//            let multiArray = try observation.keypointsMultiArray()
            let input = HandActionClassifierInput(poses: multiArray)
            let prediction = try? model.prediction(input: input)
            
            guard let label = prediction?.label,
                  let confidence = prediction?.labelProbabilities[label] else { return }
            
//            if label == previousLabel {
//                sameLabelCount += 1
//            } else {
//                sameLabelCount = 0
//            }
//
//            if sameLabelCount >= sameLabelThreshold {
//                isProcessing = true
//                DispatchQueue.main.async {
//                    self.handActionLabel = label
//                    print("Detected hand action: \(label) & confidence: \(confidence)")
//
//                    // 일정 시간 후에 isProcessing을 false로 설정하여 다시 감지할 수 있도록 함
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
//                        self.isProcessing = false
//                    }
//                }
//                sameLabelCount = 0
//            }
//
//            previousLabel = label
            
            
            DispatchQueue.main.async {
                self.handActionLabel = label //😀
                print("Detected hand action: \(label) & confidence: \(confidence)") // 콘솔에 출력
            }
            
            
//            if confidence >= 1.0 {
//                DispatchQueue.main.async {
//                    self.handActionLabel = label //😀
//                    print("Detected hand action: \(label) & confidence: \(confidence)") // 콘솔에 출력
//                }
//            }
            
            
        } catch {
            print("Error: \(error)")
        }
    }
    
//    private func createMLMultiArray(from observation: VNHumanHandPoseObservation) throws -> MLMultiArray {
//        let array = try MLMultiArray(shape: [1, 3, 21], dataType: .double)
//        let pointKeys: [VNHumanHandPoseObservation.JointName] = [
//            .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
//            .indexMCP, .indexPIP, .indexDIP, .indexTip,
//            .middleMCP, .middlePIP, .middleDIP, .middleTip,
//            .ringMCP, .ringPIP, .ringDIP, .ringTip,
//            .littleMCP, .littlePIP, .littleDIP, .littleTip
//        ]
//        let recognizedPoints = try observation.recognizedPoints(.all)
//        for (pointIndex, pointKey) in pointKeys.enumerated() {
//            if let recognizedPoint = recognizedPoints[pointKey] {
//                array[[0, 0, pointIndex] as [NSNumber]] = NSNumber(value: recognizedPoint.location.x)
//                array[[0, 1, pointIndex] as [NSNumber]] = NSNumber(value: recognizedPoint.location.y)
//                array[[0, 2, pointIndex] as [NSNumber]] = NSNumber(value: recognizedPoint.confidence)
//            }
//        }
//        return array
//    }
    
    
    
    private func createMLMultiArray(from observations: [VNHumanHandPoseObservation?]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [60, 3, 21], dataType: .double)
        let pointKeys: [VNHumanHandPoseObservation.JointName] = [
            .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        for (frameIndex, observation) in observations.enumerated() {
            guard let observation = observation else { continue }
            let recognizedPoints = try observation.recognizedPoints(.all)
            for (pointIndex, pointKey) in pointKeys.enumerated() {
                if let recognizedPoint = recognizedPoints[pointKey] {
                    array[[frameIndex as NSNumber, 0, pointIndex as NSNumber]] = NSNumber(value: recognizedPoint.location.x)
                    array[[frameIndex as NSNumber, 1, pointIndex as NSNumber]] = NSNumber(value: recognizedPoint.location.y)
                    array[[frameIndex as NSNumber, 2, pointIndex as NSNumber]] = NSNumber(value: recognizedPoint.confidence)
                }
            }
        }
        return array
    }
}
