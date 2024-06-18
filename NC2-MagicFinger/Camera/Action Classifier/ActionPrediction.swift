struct ActionPrediction {
    let label: String
    let confidence: Double!

    var confidenceString: String? {
        guard let confidence = confidence else {
            return nil
        }
        let percent = confidence * 100
        let formatString = percent >= 99.5 ? "%2.0f %%" : "%2.1f %%"
        return String(format: formatString, percent)
    }

    init(label: String, confidence: Double) {
        self.label = label
        self.confidence = confidence
    }
}

extension ActionPrediction {
    private enum AppLabel: String {
        case starting = "Starting Up"
        case noPerson = "No Person"
        case lowConfidence = "Low Confidence"
    }

    static let startingPrediction = ActionPrediction(.starting)
    static let noPersonPrediction = ActionPrediction(.noPerson)
    static let lowConfidencePrediction = ActionPrediction(.lowConfidence)

    private init(_ otherLabel: AppLabel) {
        label = otherLabel.rawValue
        confidence = nil
    }

    var isModelLabel: Bool { !isAppLabel }
    var isAppLabel: Bool { confidence == nil }
}
