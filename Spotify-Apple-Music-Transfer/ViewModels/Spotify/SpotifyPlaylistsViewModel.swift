//
//  SpotifyPlaylistsViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import Combine
import SpotifyAPI

class SpotifyPlaylistsViewModel: ObservableObject {
    static let shared = SpotifyPlaylistsViewModel()
    
    private init() {}
    
    @Published var playlists = [SpotifyAPI.PlaylistSimplified]()
    
    //var objectWillChange = ObservableObjectPublisher()
    
    func getLibraryPlaylists() {
        
        SpotifyAPI.manager.getOwnPlaylists { playlists, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            DispatchQueue.main.async {
                self.playlists = playlists
            }
        }
    }
}
