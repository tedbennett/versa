//
//  AppleMusicPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import AppleMusicAPI

class AppleMusicPlaylistDetailViewModel: ObservableObject {
    
    var playlist: AppleMusicAPI.LibraryPlaylist
    
    @Published var songs = [AppleMusicAPI.LibrarySong]()
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        self.playlist = playlist
    }
    
    func getPlaylistSongs() {
        AppleMusicAPI.manager.getLibraryPlaylistSongs(id: playlist.id) { songs, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            if let songs = songs {
                DispatchQueue.main.async {
                    self.songs = songs
                }
            }
        }
    }
}
