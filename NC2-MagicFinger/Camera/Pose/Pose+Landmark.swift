import UIKit
import Vision

extension Pose {
    typealias JointName = VNHumanBodyPoseObservation.JointName

    struct Landmark {
        private static let threshold: Float = 0.2
        private static let radius: CGFloat = 14.0
        let name: JointName
        let location: CGPoint

        init?(_ point: VNRecognizedPoint) {
            guard point.confidence >= Pose.Landmark.threshold else {
                return nil
            }
            name = JointName(rawValue: point.identifier)
            location = point.location
        }

        func drawToContext(_ context: CGContext, applying transform: CGAffineTransform? = nil, at scale: CGFloat = 1.0) {
            context.setFillColor(UIColor.white.cgColor)
            context.setStrokeColor(UIColor.darkGray.cgColor)
            let origin = location.applying(transform ?? .identity)
            let radius = Landmark.radius * scale
            let diameter = radius * 2
            let rectangle = CGRect(x: origin.x - radius, y: origin.y - radius, width: diameter, height: diameter)
            context.addEllipse(in: rectangle)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    }
}
