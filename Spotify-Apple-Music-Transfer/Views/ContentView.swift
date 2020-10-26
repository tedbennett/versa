//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppleMusicPlaylistList().tabItem {
                Text("Apple")
                Image(uiImage: UIImage(named: "apple")!)
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
