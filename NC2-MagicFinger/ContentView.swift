//
//  ContentView.swift
//  Magicfinger
//
//  Created by 김도현 on 6/14/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("INFO")
                .font(.system(size: 45, weight: .bold, design: .default))// 텍스트 크기 설정
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 왼쪽 정렬
                .padding(15)
            Spacer()
            CarrocelView()
            Button(action: {
                            print("Button tapped!")
                        }){
                            Text("START")
                                .padding(30)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 15) // 선택 사항: 좌우 여백 추가
            Color.black // 배경색 설정
                            .edgesIgnoringSafeArea(.all)
                        .padding()

        }
        .background(Color.black)
    }

}

#Preview {
    ContentView()
}

