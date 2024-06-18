import SwiftUI

struct SummaryView: View {
    var actionFrameCounts: [String: Int]

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedActions, id: \.self) { action in
                    HStack {
                        Text(action)
                        Spacer()
                        if let frameCount = actionFrameCounts[action] {
                            Text(String(format: "%.1fs", Double(frameCount) / ExerciseClassifier.frameRate))
                        }
                    }
                }
            }
            .navigationTitle("Summary")
        }
    }

    private var sortedActions: [String] {
        actionFrameCounts.keys.sorted { (actionFrameCounts[$0] ?? 0) > (actionFrameCounts[$1] ?? 0) }
    }
}
