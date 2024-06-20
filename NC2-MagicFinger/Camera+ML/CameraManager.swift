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
        
        handPoseRequest.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
            if let results = handPoseRequest.results?.first {
                processHandPoseObservation(results)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func processHandPoseObservation(_ observation: VNHumanHandPoseObservation) {
        poseWindow[currentIndex] = observation
        currentIndex = (currentIndex + 1) % poseWindow.count
        
        if poseWindow.contains(where: { $0 == nil }) {
            return
        }
        
        do {
            let multiArray = try createMLMultiArray(from: poseWindow)
            let input = HandActionClassifierInput(poses: multiArray)
            let prediction = try? model.prediction(input: input)
            
            guard let label = prediction?.label,
                  let confidence = prediction?.labelProbabilities[label] else { return }
            
            DispatchQueue.main.async {
                self.handActionLabel = label
                print("Detected hand action: \(label) & confidence: \(confidence)")
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
    
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
