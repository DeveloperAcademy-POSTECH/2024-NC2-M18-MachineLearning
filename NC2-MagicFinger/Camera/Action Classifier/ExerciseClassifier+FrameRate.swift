import CoreML

extension ExerciseClassifier {
    static let frameRate = 30.0

    func calculatePredictionWindowSize() -> Int {
        let modelDescription = model.modelDescription
        let modelInputs = modelDescription.inputDescriptionsByName
        assert(modelInputs.count == 1, "The model should have exactly 1 input")
        guard let input = modelInputs.first?.value else {
            fatalError("The model must have at least 1 input.")
        }
        guard input.type == .multiArray else {
            fatalError("The model's input must be an `MLMultiArray`.")
        }
        guard let multiArrayConstraint = input.multiArrayConstraint else {
            fatalError("The multiarray input must have a constraint.")
        }
        let dimensions = multiArrayConstraint.shape
        guard dimensions.count == 3 else {
            fatalError("The model's input multiarray must be 3 dimensions.")
        }
        let windowSize = Int(truncating: dimensions.first!)
        let frameRate = ExerciseClassifier.frameRate
        let timeSpan = Double(windowSize) / frameRate
        let timeString = String(format: "%0.2f second(s)", timeSpan)
        let fpsString = String(format: "%.0f fps", frameRate)
        print("Window is \(windowSize) frames wide, or \(timeString) at \(fpsString).")
        return windowSize
    }
}
