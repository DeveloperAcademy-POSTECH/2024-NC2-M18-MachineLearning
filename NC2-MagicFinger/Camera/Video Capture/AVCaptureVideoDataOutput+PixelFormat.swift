import AVFoundation

extension AVCaptureVideoDataOutput {
    static func withPixelFormatType(_ pixelFormatType: OSType) -> AVCaptureVideoDataOutput {
        let videoDataOutput = AVCaptureVideoDataOutput()
        let validPixelTypes = videoDataOutput.availableVideoPixelFormatTypes

        guard validPixelTypes.contains(pixelFormatType) else {
            var errorMessage = "`AVCaptureVideoDataOutput` doesn't support pixel format type: \(pixelFormatType)\n"
            errorMessage += "Please use one of these instead:\n"

            for (index, pixelType) in validPixelTypes.enumerated() {
                errorMessage += " availableVideoPixelFormatTypes[\(index)] (0x\(String(format: "%08x", pixelType))\n"
            }

            fatalError(errorMessage)
        }

        let pixelTypeKey = String(kCVPixelBufferPixelFormatTypeKey)
        videoDataOutput.videoSettings = [pixelTypeKey: pixelFormatType]
        return videoDataOutput
    }
}
