//
//  SpotifyViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import SpotifyAPI

class SpotifyAuthViewModel: ObservableObject {
    static let shared = SpotifyAuthViewModel()
    
    private init() {}
    
    @Published var authenticated = false
    
    func initialize() {
        SpotifyAPI.manager.initialize(clientId: "e164f018712e4c6ba906a595591ff010", redirectUris: ["apple-music-spotify-transfer://oauth-callback/"] , scopes: [.playlistModifyPrivate, .playlistModifyPublic])
    }
    
    func authorize() {
        SpotifyAPI.manager.authorize { success in
            self.authenticated = success
        }
    }
}
