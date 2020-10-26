//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct ContentView: View {
    
    @ObservedObject var AMViewModel = AppleMusicAuthViewModel.shared
    
    init() {
        SpotifyAPI.manager.initialize(clientId: "e164f018712e4c6ba906a595591ff010", redirectUris: ["test://oauth-callback/"] , scopes: [.playlistModifyPrivate, .playlistModifyPublic])
    }
    
    var body: some View {
        TabView {
            if AMViewModel.authenticated {
                AppleMusicPlaylistList().tabItem {
                    Text("Apple")
                    Image(uiImage: UIImage(named: "apple")!)
                }
            }
            SpotifyPlaylistList().tabItem {
                Text("Spotify")
                Image(uiImage: UIImage(named: "spotify")!)
            }
            AddServiceView().tabItem {
                Text("Add Service")
                Image(systemName: "plus")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
