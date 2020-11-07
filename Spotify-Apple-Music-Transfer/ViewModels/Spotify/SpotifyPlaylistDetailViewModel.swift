//
//  SpotifyPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import SpotifyAPI
import AppleMusicAPI

class SpotifyPlaylistDetailViewModel: ObservableObject {
    var playlist: SpotifyAPI.PlaylistSimplified
    
    @Published var songs = [SpotifyAPI.PlaylistTrack]()
    
    private var appleMusicSongs = [AppleMusicAPI.Song]()
    
    init(playlist: SpotifyAPI.PlaylistSimplified) {
        self.playlist = playlist
    }
    
    func getPlaylistName() -> String {
        return playlist.name
    }
    
    func getPlaylistSongs() {
        SpotifyAPI.manager.getPlaylistsTracks(id: playlist.id, country: "GB") { [weak self] songs, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            DispatchQueue.main.async {
                self?.songs = songs.map { $0.track }
            }
        }
    }
    
    func transferToAppleMusic() {
        let group = DispatchGroup()
        songs.forEach { song in
            group.enter()
            if let isrc = song.externalIds?.isrc {
                AppleMusicAPI.manager.getCatalogSongByIsrcId(isrcId: isrc) { [weak self] song, error in
                    if let song = song {
                        self?.appleMusicSongs.append(song)
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            AppleMusicAPI.manager.createLibraryPlaylist(
                name: self?.playlist.name ?? "",
                description: nil,
                songs: self?.appleMusicSongs ?? [],
                librarySongs: []) { playlists, error in
                    guard let playlists = playlists, !playlists.isEmpty else {
                        print(error.debugDescription)
                        return
                    }
            }
        }
        
    }
}
