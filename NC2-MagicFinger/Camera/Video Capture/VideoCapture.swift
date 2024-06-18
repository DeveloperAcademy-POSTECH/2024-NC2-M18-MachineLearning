import UIKit
import Combine
import AVFoundation

typealias Frame = CMSampleBuffer
typealias FramePublisher = AnyPublisher<Frame, Never>

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher)
}

class VideoCapture: NSObject {
    weak var delegate: VideoCaptureDelegate! {
        didSet { createVideoFramePublisher() }
    }

    var isEnabled = true {
        didSet { isEnabled ? enableCaptureSession() : disableCaptureSession() }
    }

    var captureSession: AVCaptureSession {
        return self.session
    }

    private var cameraPosition = AVCaptureDevice.Position.front {
        didSet { createVideoFramePublisher() }
    }

    private var orientation = AVCaptureVideoOrientation.portrait {
        didSet { createVideoFramePublisher() }
    }

    private let session = AVCaptureSession()
    private var framePublisher: PassthroughSubject<Frame, Never>?
    private let videoCaptureQueue = DispatchQueue(label: "Video Capture Queue", qos: .userInitiated)
    private var videoStabilizationEnabled = false

    func toggleCameraSelection() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }

    func updateDeviceOrientation() {
        let currentPhysicalOrientation = UIDevice.current.orientation
        switch currentPhysicalOrientation {
        case .portrait, .faceUp, .faceDown, .unknown:
            orientation = .portrait
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        @unknown default:
            orientation = .portrait
        }
    }

    private func enableCaptureSession() {
        videoCaptureQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func disableCaptureSession() {
        videoCaptureQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

//😀
extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput frame: Frame,
                       from connection: AVCaptureConnection) {
        // Forward the frame through the publisher.
        framePublisher?.send(frame)
    }
}

extension VideoCapture {
    private func createVideoFramePublisher() {
        guard let videoDataOutput = configureCaptureSession() else { return }
        //😀
        // Create a new passthrough subject that publishes frames to subscribers.
        let passthroughSubject = PassthroughSubject<Frame, Never>()
        
        // Keep a reference to the publisher.
        framePublisher = passthroughSubject
        
        // Set the video capture as the video output's delegate.
        videoDataOutput.setSampleBufferDelegate(self, queue: videoCaptureQueue)
        //😀
        let genericFramePublisher = passthroughSubject.eraseToAnyPublisher()
        delegate.videoCapture(self, didCreate: genericFramePublisher)
    }

    private func configureCaptureSession() -> AVCaptureVideoDataOutput? {
        disableCaptureSession()
        guard isEnabled else { return nil }
        defer { enableCaptureSession() }
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        //😀
        // Set the video camera to run at the action classifier's frame rate.
        let modelFrameRate = 30.0
        let input = AVCaptureDeviceInput.createCameraInput(position: cameraPosition, frameRate: modelFrameRate)
        let output = AVCaptureVideoDataOutput.withPixelFormatType(kCVPixelFormatType_32BGRA)

        let success = configureCaptureConnection(input, output)
        return success ? output : nil
        //😀
    }

    private func configureCaptureConnection(_ input: AVCaptureDeviceInput?, _ output: AVCaptureVideoDataOutput?) -> Bool {
        guard let input = input, let output = output else { return false }
        session.inputs.forEach(session.removeInput)
        session.outputs.forEach(session.removeOutput)
        guard session.canAddInput(input), session.canAddOutput(output) else { return false }
        session.addInput(input)
        session.addOutput(output)
        guard let connection = session.connections.first else { return false }
        
        //😀
        if connection.isVideoOrientationSupported {
            // Set the video capture's orientation to match that of the device.
            connection.videoOrientation = orientation
        }

        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = cameraPosition == .front
        }

        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = videoStabilizationEnabled ? .standard : .off
        }
        
        // Discard newer frames if the app is busy with an earlier frame.
        output.alwaysDiscardsLateVideoFrames = true
        return true
        //😀
    }
}
