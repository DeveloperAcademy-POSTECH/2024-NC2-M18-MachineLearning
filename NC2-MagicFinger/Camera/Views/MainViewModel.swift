import SwiftUI
import AVFoundation
import Combine

class MainViewModel: NSObject, ObservableObject {
    @Published var actionLabel: String = "Starting Up"
    @Published var confidenceLabel: String = "Observing..."
    @Published var showSummary: Bool = false
    
//    @Published var poses: [Pose]? = nil  // 포즈 정보를 저장하는 프로퍼티

    private var videoCapture: VideoCapture!
    private var videoProcessingChain: VideoProcessingChain!
    private var cancellables = Set<AnyCancellable>()

    var captureSession: AVCaptureSession {
        videoCapture.captureSession
    }

    var actionFrameCounts = [String: Int]()

    override init() {
        super.init()
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        videoCapture = VideoCapture()
        videoCapture.delegate = self
    }

    func startVideoCapture() {
        videoCapture.isEnabled = true
    }

    func stopVideoCapture() {
        videoCapture.isEnabled = false
    }

    func toggleCamera() {
        videoCapture.toggleCameraSelection()
    }
}

extension MainViewModel: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

extension MainViewModel: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain, didPredict actionPrediction: ActionPrediction, for frameCount: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frameCount, to: actionPrediction.label)
        }
        DispatchQueue.main.async {
            self.actionLabel = actionPrediction.label
            self.confidenceLabel = actionPrediction.confidenceString ?? "Observing..."
        }
    }

    func videoProcessingChain(_ chain: VideoProcessingChain, didDetect poses: [Pose]?, in frame: CGImage) {
        // Process and display the poses if needed
        
//        DispatchQueue.main.async {
//                    self.poses = poses  // 포즈 정보를 업데이트
//        }
        
    }

    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount
        actionFrameCounts[actionLabel] = totalFrames
    }
}
