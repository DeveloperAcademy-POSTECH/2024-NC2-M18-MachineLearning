import CoreML

extension ExerciseClassifier {
    func predictActionFromWindow(_ window: MLMultiArray) -> ActionPrediction {
        do {
            let output = try prediction(poses: window)
            let action = Label(output.label)
            let confidence = output.labelProbabilities[output.label]!
            return ActionPrediction(label: action.rawValue, confidence: confidence)
        } catch {
            fatalError("Exercise Classifier prediction error: \(error)")
        }
    }
}
