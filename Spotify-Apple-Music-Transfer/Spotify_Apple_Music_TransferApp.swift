//
//  Spotify_Apple_Music_TransferApp.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

@main
struct Spotify_Apple_Music_TransferApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                SpotifyAPI.manager.handleRedirect(redirectUrl: url, completion: { _ in })
            }
        }
    }
}


