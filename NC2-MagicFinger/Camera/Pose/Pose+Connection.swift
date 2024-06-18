import UIKit

extension Pose {
    struct Connection: Equatable {
        static let width: CGFloat = 12.0
        static let colors = [UIColor.systemGreen.cgColor,
                             UIColor.systemYellow.cgColor,
                             UIColor.systemOrange.cgColor,
                             UIColor.systemRed.cgColor,
                             UIColor.systemPurple.cgColor,
                             UIColor.systemBlue.cgColor
        ] as CFArray
        static let gradientColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        static let gradient = CGGradient(colorsSpace: gradientColorSpace,
                                         colors: colors,
                                         locations: [0, 0.2, 0.33, 0.5, 0.66, 0.8])!
        private let point1: CGPoint
        private let point2: CGPoint

        init(_ one: CGPoint, _ two: CGPoint) { point1 = one; point2 = two }

        func drawToContext(_ context: CGContext, applying transform: CGAffineTransform? = nil, at scale: CGFloat = 1.0) {
            let start = point1.applying(transform ?? .identity)
            let end = point2.applying(transform ?? .identity)
            context.saveGState()
            defer { context.restoreGState() }
            context.setLineWidth(Connection.width * scale)
            context.move(to: start)
            context.addLine(to: end)
            context.replacePathWithStrokedPath()
            context.clip()
            context.drawLinearGradient(Connection.gradient, start: start, end: end, options: .drawsAfterEndLocation)
        }
    }
}

extension Pose {
    static let jointPairs: [(joint1: JointName, joint2: JointName)] = [
        (.leftShoulder, .leftElbow),
        (.leftElbow, .leftWrist),
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),
        (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist),
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle),
        (.leftShoulder, .neck),
        (.rightShoulder, .neck),
        (.leftShoulder, .leftHip),
        (.rightShoulder, .rightHip),
        (.leftHip, .rightHip)
    ]
}
