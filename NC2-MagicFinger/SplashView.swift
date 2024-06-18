import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView() // 스플래시 화면이 끝난 후 메인 화면으로 전환
        } else {
            ZStack{
                Color(red: 252/255, green: 91/255, blue: 63/255)
                .ignoresSafeArea()
            VStack {
                VStack{
                    Text("Magic")
                    Text("Finger")
                    }
                .font(.system(size: 70, weight: .bold, design: .default)) // 텍스트 크기 줄이기
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                .padding(.top,30)
                VStack{
                    Text("Control media")
                    Text("with gestures!")
                    }
                .font(.system(size: 35, weight: .bold, design: .default)) // 텍스트 크기 줄이기
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .foregroundColor(.white)

                Image("pichung")
                    .resizable()
                    .frame(width: 350, height: 400)
                    .padding(.top)
                    .padding(.leading, 60)
                            }  
            }

            .onAppear {
                // 2초 후에 메인 화면으로 전환
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
