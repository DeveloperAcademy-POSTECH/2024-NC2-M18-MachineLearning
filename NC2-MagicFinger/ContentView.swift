//
//  ContentView.swift
//  Magicfinger
//
//  Created by 김도현 on 6/14/24.
//

import SwiftUI
import MediaPlayer
import AVFoundation

struct ContentView: View {
    @State private var isPlaying = false
    @State private var currentIndex: Int = 1
    @StateObject private var viewManager = CameraViewManager()
    
    var body: some View {
        VStack {
            HStack {
                Text("Magics")
                    .font(.system(size: 55, weight: .bold, design: .default))// 텍스트 크기 설정
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 왼쪽 정렬
                    .padding(.horizontal , 25)
                    .padding(.top, 10)
                
                CameraView(viewManager: viewManager)
                    .hidden()
            }

            Spacer()
            
            CarrocelView(currentIndex: $currentIndex)
            Button(action: {
                togglePlayPause()
                        }){
                            Text(isPlaying ? "PAUSE" : "START")
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color(red:252/255, green:91/255, blue:63/255))
                                .foregroundColor(.white)
                                .font(.system(size: 40, weight: .bold, design: .default))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                        Color.black
                        .edgesIgnoringSafeArea(.all)


                VStack{
                    Text("Notice: This video will never")
                    Text("be saved and is solely for")
                    Text("capturing hand motions.")
                }
                .font(.system(size: 20, weight: .bold, design: .default)) // 텍스트 크기 줄이기
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.gray)
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)



        }
        .background(Color.black)
        .onReceive(viewManager.$handActionLabel) { label in
            updateCurrentIndex(for: label)
        }
    }
    
    func togglePlayPause() {
        let player = MPMusicPlayerController.systemMusicPlayer
        
        if player.playbackState == .playing {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func updateCurrentIndex(for label: String) {
        switch label {
        case "VolumeUp":
            currentIndex = 0
        case "Pause":
            currentIndex = 1
        case "Next":
            currentIndex = 2
        default:
            currentIndex = 1
        }
    }
    
}


#Preview {
    ContentView()
}

