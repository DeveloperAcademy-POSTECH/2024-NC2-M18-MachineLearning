import UIKit
import Vision

typealias Observation = VNHumanBodyPoseObservation
struct Pose {
    private let landmarks: [Landmark]
    private var connections: [Connection]!
    let multiArray: MLMultiArray?
    let area: CGFloat

    static func fromObservations(_ observations: [Observation]?) -> [Pose]? {
        observations?.compactMap { observation in Pose(observation) }
    }

    init?(_ observation: Observation) {
        landmarks = observation.availableJointNames.compactMap { jointName in
            guard jointName != JointName.root else {
                return nil
            }
            guard let point = try? observation.recognizedPoint(jointName) else {
                return nil
            }
            return Landmark(point)
        }
        guard !landmarks.isEmpty else { return nil }
        area = Pose.areaEstimateOfLandmarks(landmarks)
        multiArray = try? observation.keypointsMultiArray()
        buildConnections()
    }

    func drawWireframeToContext(_ context: CGContext, applying transform: CGAffineTransform? = nil) {
        let scale = drawingScale
        connections.forEach {
            line in line.drawToContext(context, applying: transform, at: scale)
        }
        landmarks.forEach { landmark in
            landmark.drawToContext(context, applying: transform, at: scale)
        }
    }

    private var drawingScale: CGFloat {
        let typicalLargePoseArea: CGFloat = 0.35
        let max: CGFloat = 1.0
        let min: CGFloat = 0.6
        let ratio = area / typicalLargePoseArea
        let scale = ratio >= max ? max : (ratio * (max - min)) + min
        return scale
    }
}

extension Pose {
    mutating func buildConnections() {
        guard connections == nil else {
            return
        }
        connections = [Connection]()
        let joints = landmarks.map { $0.name }
        let locations = landmarks.map { $0.location }
        let zippedPairs = zip(joints, locations)
        let jointLocations = Dictionary(uniqueKeysWithValues: zippedPairs)
        for jointPair in Pose.jointPairs {
            guard let one = jointLocations[jointPair.joint1] else { continue }
            guard let two = jointLocations[jointPair.joint2] else { continue }
            connections.append(Connection(one, two))
        }
    }

    static func areaEstimateOfLandmarks(_ landmarks: [Landmark]) -> CGFloat {
        let xCoordinates = landmarks.map { $0.location.x }
        let yCoordinates = landmarks.map { $0.location.y }
        guard let minX = xCoordinates.min() else { return 0.0 }
        guard let maxX = xCoordinates.max() else { return 0.0 }
        guard let minY = yCoordinates.min() else { return 0.0 }
        guard let maxY = yCoordinates.max() else { return 0.0 }
        let deltaX = maxX - minX
        let deltaY = maxY - minY
        return deltaX * deltaY
    }
}
