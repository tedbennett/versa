//
//  WelcomeView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var display: Bool
    var body: some View {
        
        VStack(alignment: .center, spacing: 20) {
            Text("Welcome to").font(Font.system(size: 35, weight: .heavy, design: .rounded)).padding(.top, 20)
            Text("Versa").foregroundColor(.accentColor).font(Font.system(size: 40, weight: .heavy, design: .rounded))
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    ZStack {
                        Image(systemName: "circle").font(Font.system(size: 40)).foregroundColor(.accentColor)
                        Image(systemName: "music.note").font(Font.system(size: 25)).foregroundColor(.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Share Music").fontWeight(.medium)
                        Text("Convert song, album and artist links between Apple Music and Spotify").font(.callout).foregroundColor(.gray)
                    }
                }
                HStack(spacing: 10) {
                    Image(systemName: "paperclip.circle").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Just copy a link").fontWeight(.medium)
                        Text("Copy a link, and on opening Versa the link will be automatically converted").font(.callout).foregroundColor(.gray)
                    }
                }
                HStack(spacing: 10) {
                    Image(systemName: "text.badge.plus").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Add to your library").fontWeight(.medium)
                        Text("Log in with Apple Music and Spotify in Settings to add music to your libraries").font(.callout).foregroundColor(.gray)
                    }
                }
                HStack(spacing: 10) {
                    Image(systemName: "arrow.left.arrow.right.circle").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Transfer Playlists").fontWeight(.medium)
                        Text("Easily migrate playlists when logged in to both Apple Music and Spotify").font(.callout).foregroundColor(.gray)
                    }
                }
            }
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                display.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 60)
                    Text("Got it").font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }.padding()
        .onDisappear {
            UserDefaults.standard.setValue(AppData.version, forKey: "CurrentAppVersion")
        }
    }
}

struct HomeVIew_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(display: .constant(true))
        
    }
}
