//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct ContentView: View {

    @ObservedObject var clipboardViewModel = OpenLinkViewModel.shared
    
    var body: some View {
        TabView {
            AppleMusicView().tabItem {
                Text("Apple")
                Image(uiImage: UIImage(named: "apple")!)
            }

            SpotifyView().tabItem {
                Text("Spotify")
                Image(uiImage: UIImage(named: "spotify")!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            clipboardViewModel.parseClipboard(UIPasteboard.general.string)
        }
        
        .sheet(isPresented: $clipboardViewModel.foundLink) {
            OpenLinkView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
