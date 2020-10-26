//
//  SpotifyPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import SpotifyAPI

class SpotifyPlaylistDetailViewModel: ObservableObject {
    var playlist: SpotifyAPI.PlaylistSimplified
    
    @Published var songs = [SpotifyAPI.PlaylistTrack]()
    
    init(playlist: SpotifyAPI.PlaylistSimplified) {
        self.playlist = playlist
    }
    
    func getPlaylistSongs() {
        SpotifyAPI.manager.getPlaylistsTracks(id: playlist.id, country: "GB") { songs, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            DispatchQueue.main.async {
                self.songs = songs.map { $0.track }
            }
        }
    }
}
