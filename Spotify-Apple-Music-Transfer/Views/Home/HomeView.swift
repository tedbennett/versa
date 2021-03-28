//
//  HomeView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct HomeView: View {
    @ObservedObject var auth = AuthManager.shared
    @State var currentTab = 0
    @Binding var presentInfo: Bool
    
    var body: some View {
        TabView(selection: $currentTab) {
            ClipboardView(currentTab: $currentTab).tabItem {
                Text("Clipboard")
                Image(systemName: "arrow.left.arrow.right.circle")
            }.navigationBarHidden(true)
            .tag(0)
            
            if auth.authorisedApple && auth.authorisedSpotify {
                AppleMusicPlaylistsView().tabItem {
                    Text("Apple Music")
                    Image(uiImage: UIImage(named: "apple")!)
                }.navigationBarHidden(true)
                .tag(1)
            
                SpotifyPlaylistsView().tabItem {
                    Text("Spotify")
                    Image(uiImage: UIImage(named: "spotify")!)
                }.navigationBarHidden(true)
                .tag(2)
            }
            SettingsView(presentInfo: $presentInfo).tabItem {
                Text("Settings")
                Image(systemName: "gear")
            }.navigationBarHidden(true)
            .tag(3)
        }.onChange(of: currentTab) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(presentInfo: .constant(false))
    }
}
