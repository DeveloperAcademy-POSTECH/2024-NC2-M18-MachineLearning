import Vision
import Combine
import CoreImage

protocol VideoProcessingChainDelegate: AnyObject {
    func videoProcessingChain(_ chain: VideoProcessingChain, didDetect poses: [Pose]?, in frame: CGImage)
    func videoProcessingChain(_ chain: VideoProcessingChain, didPredict actionPrediction: ActionPrediction, for frames: Int)
}

struct VideoProcessingChain {
    weak var delegate: VideoProcessingChainDelegate?
    var upstreamFramePublisher: AnyPublisher<Frame, Never>! {
        didSet { buildProcessingChain() }
    }

    private var frameProcessingChain: AnyCancellable?
    private let humanBodyPoseRequest = VNDetectHumanBodyPoseRequest() //😀 extract poses
    private let actionClassifier = ExerciseClassifier.shared
    private let predictionWindowSize: Int
    private let windowStride = 10
    private var performanceReporter = PerformanceReporter()

    init() {
        predictionWindowSize = actionClassifier.calculatePredictionWindowSize()
    }
}

extension VideoProcessingChain {
    private mutating func buildProcessingChain() {
        guard upstreamFramePublisher != nil else { return }

        frameProcessingChain = upstreamFramePublisher
            .compactMap(imageFromFrame)
            .map(findPosesInFrame)
            .map(isolateLargestPose)
            .map(multiArrayFromPose)
            .scan([MLMultiArray?](), gatherWindow)
            .filter(gateWindow)
            // Make an activity prediction from the window.
            .map(predictActionWithWindow)
            // Send the action prediction to the delegate.
            .sink(receiveValue: sendPrediction)
    }
}

extension VideoProcessingChain {
    private func imageFromFrame(_ buffer: Frame) -> CGImage? {
        performanceReporter?.incrementFrameCount()
        guard let imageBuffer = buffer.imageBuffer else {
            print("The frame doesn't have an underlying image buffer.")
            return nil
        }
        let ciContext = CIContext(options: nil)
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            print("Unable to create an image from a frame.")
            return nil
        }
        return cgImage
    }

    private func findPosesInFrame(_ frame: CGImage) -> [Pose]? {
        //😀
        // Create a request handler for the image.
        let visionRequestHandler = VNImageRequestHandler(cgImage: frame)
        
        //😀
        // Use Vision to find human body poses in the frame.
        do { try visionRequestHandler.perform([humanBodyPoseRequest]) } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }
        
        //😀
        let poses = Pose.fromObservations(humanBodyPoseRequest.results)
//        let poses = humanBodyPoseRequest.results! as [VNRecognizedPointsObservation]
        
        // Send the frame and poses, if any, to the delegate on the main queue.
        DispatchQueue.main.async {
            self.delegate?.videoProcessingChain(self, didDetect: poses, in: frame)
        }
        return poses
    }

    private func isolateLargestPose(_ poses: [Pose]?) -> Pose? {
        return poses?.max(by:) { pose1, pose2 in pose1.area < pose2.area }
    }

    private func multiArrayFromPose(_ item: Pose?) -> MLMultiArray? {
        return item?.multiArray
    }

    private func gatherWindow(previousWindow: [MLMultiArray?], multiArray: MLMultiArray?) -> [MLMultiArray?] {
        var currentWindow = previousWindow
        if previousWindow.count == predictionWindowSize {
            currentWindow.removeFirst(windowStride)
        }
        currentWindow.append(multiArray)
        return currentWindow
    }

    private func gateWindow(_ currentWindow: [MLMultiArray?]) -> Bool {
        return currentWindow.count == predictionWindowSize
    }

    private func predictActionWithWindow(_ currentWindow: [MLMultiArray?]) -> ActionPrediction {
        var poseCount = 0
        // Fill the nil elements with an empty pose array.
        let filledWindow: [MLMultiArray] = currentWindow.map { multiArray in
            if let multiArray = multiArray {
                poseCount += 1
                return multiArray
            } else {
                return Pose.emptyPoseMultiArray
            }
        }
        // Only use windows with at least 60% real data to make a prediction
        // with the action classifier.
        let minimum = predictionWindowSize * 60 / 100
        guard poseCount >= minimum else {
            return ActionPrediction.noPersonPrediction
        }
        // Merge the array window of multiarrays into one multiarray.
        let mergedWindow = MLMultiArray(concatenating: filledWindow, axis: 0, dataType: .float)
        // Make a genuine prediction with the action classifier.
        let prediction = actionClassifier.predictActionFromWindow(mergedWindow)
        // Return the model's prediction if the confidence is high enough.
        // Otherwise, return a "Low Confidence" prediction.
        return checkConfidence(prediction)
    }

    private func checkConfidence(_ actionPrediction: ActionPrediction) -> ActionPrediction {
        let minimumConfidence = 0.6
        let lowConfidence = actionPrediction.confidence < minimumConfidence
        return lowConfidence ? .lowConfidencePrediction : actionPrediction
    }

    private func sendPrediction(_ actionPrediction: ActionPrediction) {
        // Send the prediction to the delegate on the main queue.
        DispatchQueue.main.async {
            self.delegate?.videoProcessingChain(self, didPredict: actionPrediction, for: windowStride)
        }
        performanceReporter?.incrementPrediction()
    }
}
