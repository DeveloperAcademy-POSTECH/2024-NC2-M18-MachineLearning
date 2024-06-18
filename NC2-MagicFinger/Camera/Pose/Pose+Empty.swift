import CoreML

extension Pose {
    static let emptyPoseMultiArray = zeroedMultiArrayWithShape([1, 3, 18])

    private static func zeroedMultiArrayWithShape(_ shape: [Int]) -> MLMultiArray {
        guard let array = try? MLMultiArray(shape: shape as [NSNumber], dataType: .double) else {
            fatalError("Creating a multiarray with \(shape) shouldn't fail.")
        }
        guard let pointer = try? UnsafeMutableBufferPointer<Double>(array) else {
            fatalError("Unable to initialize multiarray with zeros.")
        }
        pointer.initialize(repeating: 0.0)
        return array
    }
}
