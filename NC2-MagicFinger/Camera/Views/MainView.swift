import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession)
                .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.actionLabel)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        Text(viewModel.confidenceLabel)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                HStack {
                    Spacer()
                    Button(action: viewModel.toggleCamera) {
                        Image(systemName: "camera.rotate")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        viewModel.showSummary = true
                    }) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.showSummary) {
            SummaryView(actionFrameCounts: viewModel.actionFrameCounts)
        }
        .onAppear {
            viewModel.startVideoCapture()
        }
        .onDisappear {
            viewModel.stopVideoCapture()
        }
    }
}
