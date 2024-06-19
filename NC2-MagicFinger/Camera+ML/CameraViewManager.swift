//
//  CameraViewManager.swift
//  testFinger
//
//  Created by Chang Jonghyeon on 6/19/24.
//

import SwiftUI
import AVFoundation
import Combine

class CameraViewManager: ObservableObject {
    let manager: CameraManager
    @Published var cameraPreview: AnyView
    @Published var handActionLabel: String = "Starting Up"

    private var cancellables = Set<AnyCancellable>()

    init() {
        manager = CameraManager()
        cameraPreview = AnyView(
            CameraPreviewView(session: manager.session)
        )

        manager.$handActionLabel
            .receive(on: RunLoop.main)
            .assign(to: \.handActionLabel, on: self)
            .store(in: &cancellables)

        configure()
    }

    private func configure() {
        manager.requestAndCheckPermissions()
    }
}
