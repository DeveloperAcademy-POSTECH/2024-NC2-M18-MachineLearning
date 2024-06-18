import SwiftUI

struct CarouselView<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    
    @State private var currentIndex: Int

    init(items: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.items = items
        self.content = content
        _currentIndex = State(initialValue: items.count / 2)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<items.count, id: \.self) { index in
                        content(items[index])
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height)
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .rotation3DEffect(
                                .degrees(Double(index - currentIndex) * -20),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(index == currentIndex ? 1.0 : 0.5)
                            .scaleEffect(index == currentIndex ? 1.0 : 0.5)
                            .offset(x: CGFloat(index - currentIndex) * geometry.size.width * 0.5)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                            .onTapGesture {
                                withAnimation {
                                    currentIndex = index
                                }
                            }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width < -threshold {
                                currentIndex = min(currentIndex + 1, items.count - 1)
                            } else if value.translation.width > threshold {
                                currentIndex = max(currentIndex - 1, 0)
                            }
                        }
                )
            }
            .frame(height: 400)
            
            HStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.white : Color.gray)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 10)
        }
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarrocelView()
    }
}

struct CarrocelView: View {
    let images = ["volume", "play", "next"]
    
    var body: some View {
        
        CarouselView(items: images) { imageName in
            Image(imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding()
    }
}

