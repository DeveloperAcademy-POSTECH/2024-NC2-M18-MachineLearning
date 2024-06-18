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
        //😀
        // Build a new video-processing chain by assigning the new frame publisher.
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

extension MainViewModel: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain, didPredict actionPrediction: ActionPrediction, for frameCount: Int) {
        if actionPrediction.isModelLabel {
            // Update the total number of frames for this action.
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
        
//        // Render the poses on a different queue than pose publisher.
//        DispatchQueue.global(qos: .userInteractive).async {
//            // Draw the poses onto the frame.
//            self.drawPoses(poses, onto: frame)
//        }
        
    }

    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount
        actionFrameCounts[actionLabel] = totalFrames
    }
    
//    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
//        // Update the UI's prediction label on the main thread.
//        DispatchQueue.main.async { self.actionLabel = prediction.label }
//
//        // Update the UI's confidence label on the main thread.
//        let confidenceString = prediction.confidenceString ?? "Observing..."
//        DispatchQueue.main.async { self.confidenceLabel = confidenceString }
//    }
    
//    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
//        // Create a default render format at a scale of 1:1.
//        let renderFormat = UIGraphicsImageRendererFormat()
//        renderFormat.scale = 1.0
//
//        // Create a renderer with the same size as the frame.
//        let frameSize = CGSize(width: frame.width, height: frame.height)
//        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
//                                                   format: renderFormat)
//
//        // Draw the frame first and then draw pose wireframes on top of it.
//        let frameWithPosesRendering = poseRenderer.image { rendererContext in
//            // The`UIGraphicsImageRenderer` instance flips the Y-Axis presuming
//            // we're drawing with UIKit's coordinate system and orientation.
//            let cgContext = rendererContext.cgContext
//
//            // Get the inverse of the current transform matrix (CTM).
//            let inverse = cgContext.ctm.inverted()
//
//            // Restore the Y-Axis by multiplying the CTM by its inverse to reset
//            // the context's transform matrix to the identity.
//            cgContext.concatenate(inverse)
//
//            // Draw the camera image first as the background.
//            let imageRectangle = CGRect(origin: .zero, size: frameSize)
//            cgContext.draw(frame, in: imageRectangle)
//
//            // Create a transform that converts the poses' normalized point
//            // coordinates `[0.0, 1.0]` to properly fit the frame's size.
//            let pointTransform = CGAffineTransform(scaleX: frameSize.width,
//                                                   y: frameSize.height)
//
//            guard let poses = poses else { return }
//
//            // Draw all the poses Vision found in the frame.
//            for pose in poses {
//                // Draw each pose as a wireframe at the scale of the image.
//                pose.drawWireframeToContext(cgContext, applying: pointTransform)
//            }
//        }
//
//        // Update the UI's full-screen image view on the main thread.
////        DispatchQueue.main.async { self.imageView.image = frameWithPosesRendering }
//    }
    
}
