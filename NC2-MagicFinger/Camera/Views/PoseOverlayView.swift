import SwiftUI

struct PoseOverlayView: UIViewRepresentable {
    var poses: [Pose]?

    func makeUIView(context: Context) -> PoseOverlayUIView {
        let view = PoseOverlayUIView()
        view.poses = poses
        return view
    }

    func updateUIView(_ uiView: PoseOverlayUIView, context: Context) {
        uiView.poses = poses
        uiView.setNeedsDisplay()
    }
}

class PoseOverlayUIView: UIView {
    var poses: [Pose]?

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let poses = poses else {
            return
        }
        
        for pose in poses {
            pose.drawWireframeToContext(context, applying: nil)
        }
    }
}
