import CoreML

extension ExerciseClassifier {
    static let shared: ExerciseClassifier = {
        let defaultConfig = MLModelConfiguration()
        guard let exerciseClassifier = try? ExerciseClassifier(configuration: defaultConfig) else {
            fatalError("Exercise Classifier failed to initialize.")
        }
        exerciseClassifier.checkLabels()
        return exerciseClassifier
    }()
}
