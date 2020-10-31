//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct ContentView: View {
    
    @ObservedObject var AppleMusicAuth = AppleMusicAuthViewModel.shared
    @ObservedObject var SpotifyAuth = SpotifyAuthViewModel.shared
    
    @ObservedObject var clipboardViewModel = OpenLinkViewModel.shared
    
    init() {
        SpotifyAuth.initialize()
    }
    
    var body: some View {
        TabView {
            if AppleMusicAuth.authenticated {
                AppleMusicPlaylistList().tabItem {
                    Text("Apple")
                    Image(uiImage: UIImage(named: "apple")!)
                }
            }
            if SpotifyAuth.authenticated {
                SpotifyPlaylistList().tabItem {
                    Text("Spotify")
                    Image(uiImage: UIImage(named: "spotify")!)
                }
            }
            if !(SpotifyAuth.authenticated && AppleMusicAuth.authenticated) {
                AddServiceView().tabItem {
                    Text("Add Service")
                    Image(systemName: "plus")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            clipboardViewModel.parseClipboard(UIPasteboard.general.string)
            }
        
        .sheet(isPresented: $clipboardViewModel.foundLink) {
            switch clipboardViewModel.state {
                case .spotifySong, .spotifyAlbum, .spotifyArtist, .spotifyPlaylist,
                .appleMusicSong, .appleMusicAlbum, .appleMusicArtist, .appleMusicPlaylist:
                    OpenLinkView()
                default:
                    Spacer()
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
