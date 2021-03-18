//
//  SpotifyPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import UIKit
import SpotifyAPI
import AppleMusicAPI

class SpotifyPlaylistDetailViewModel: ObservableObject {
    var playlist: SpotifyAPI.PlaylistSimplified
    
    @Published var songs = [SpotifyAPI.PlaylistTrack]()
    @Published var searching = true
    @Published var transferring = false
    @Published var transferSuccess = false
    @Published var transferFail = false
    
    var appleMusicSongs = [String: AppleMusicAPI.Song]()
    
    init(playlist: SpotifyAPI.PlaylistSimplified) {
        self.playlist = playlist
        getPlaylistSongs()
    }
    
    func getPlaylistSongs() {
        ServiceManager.shared.getSpotifyPlaylist(id: playlist.id) { [weak self] songs in
            DispatchQueue.main.async {
                self?.songs = songs.map {
                    var song = $0
                    if song.id == nil {
                        song.id = UUID().uuidString
                    }
                    return song
                }
            }
        }
    }
    
    func findSongsOnAppleMusic() {
        ServiceManager.shared.findSongsOnAppleMusic(tracks: songs) { [weak self] map in
            self?.appleMusicSongs = map
            DispatchQueue.main.async {
                self?.searching = false
            }
        }
    }
    
    func transferToAppleMusic() {
        transferring = true
        let songs = appleMusicSongs.values.compactMap { $0 }
        ServiceManager.shared.transferPlaylistToAppleMusic(songs: songs, name: playlist.name) { [weak self] success in
            DispatchQueue.main.async {
                self?.transferring = false
                if success {
                    self?.transferSuccess = true
                } else {
                    self?.transferFail = true
                }
                
            }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
