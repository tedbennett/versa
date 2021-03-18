//
//  HomeView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct HomeView: View {

    @ObservedObject var clipboardViewModel = ClipboardViewModel.shared
    
    var body: some View {
        TabView {
            AppleMusicPlaylistsView().tabItem {
                Text("Apple Music")
                Image(uiImage: UIImage(named: "apple")!)
            }.navigationBarHidden(true)

            SpotifyPlaylistsView().tabItem {
                Text("Spotify")
                Image(uiImage: UIImage(named: "spotify")!)
            }.navigationBarHidden(true)
            
            ClipboardView().tabItem {
                Text("Clipboard")
                Image(systemName: "arrow.left.arrow.right.circle")
            }.navigationBarHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
