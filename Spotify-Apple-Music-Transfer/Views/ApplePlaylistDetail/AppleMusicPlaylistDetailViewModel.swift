//
//  AppleMusicPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import UIKit
import AppleMusicAPI
import SpotifyAPI

class AppleMusicPlaylistDetailViewModel: ObservableObject {
    var playlist: AppleMusicAPI.LibraryPlaylist
    
    @Published var songs = [AppleMusicAPI.LibrarySong]()
    @Published var searching = true
    @Published var transferring = false
    @Published var transferSuccess = false
    @Published var transferFail = false
    
    var spotifyTracks = [String: String]()
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        self.playlist = playlist
        getPlaylistSongs()
    }
    
    func playlistName() -> String {
        return playlist.attributes?.name ?? "Playlist"
    }
    
    func getPlaylistSongs() {
        ServiceManager.shared.getAppleMusicPlaylist(id: playlist.id) { [weak self] songs in
            DispatchQueue.main.async {
                self?.songs = songs
            }
        }
    }
    
    func findSongsOnSpotify() {
        ServiceManager.shared.findSongsOnSpotify(for: songs) { [weak self] ids in
            self?.spotifyTracks = ids
            DispatchQueue.main.async {
                self?.searching = false
            }
        }
    }
    
    func transferToSpotify() {
        transferring = true
        let uris = spotifyTracks.values.compactMap { $0 }
        ServiceManager.shared.transferPlaylistToSpotify(uris: uris, name: playlistName(), description: "") { [weak self] success in
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
    
    func getImageUrl(from urlString: String?, dimension: Int = 640) -> String? {
        return urlString?.replacingOccurrences(of: "{w}", with: String(dimension))
            .replacingOccurrences(of: "{h}", with: String(dimension))
    }
}
