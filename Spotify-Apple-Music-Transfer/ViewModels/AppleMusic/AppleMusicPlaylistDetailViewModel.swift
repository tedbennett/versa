//
//  AppleMusicPlaylistDetailViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import AppleMusicAPI
import SpotifyAPI

class AppleMusicPlaylistDetailViewModel: ObservableObject {
    var playlist: AppleMusicAPI.LibraryPlaylist
    
    @Published var songs = [AppleMusicAPI.LibrarySong]()
    
    @Published var isrcIds = [String: String]()
    
    @Published var notFoundOnSpotify = [String]()
    
    private var spotifyTracks = [SpotifyAPI.Track]()
    
    @Published var isrcIdsFetched = false
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        self.playlist = playlist
    }
    
    func getPlaylistSongs() {
        AppleMusicAPI.manager.getLibraryPlaylistSongs(id: playlist.id) { [weak self] songs, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            if let songs = songs {
                DispatchQueue.main.async {
                    self?.songs = songs
                    self?.getIsrcIds()
                }
            }
        }
    }
    
    func getIsrcIds() {
        let group = DispatchGroup()
        songs.forEach { [weak self] song in
            group.enter()
            AppleMusicAPI.manager.getLibrarySongIsrcId(song: song) { isrcId, error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                DispatchQueue.main.async {
                    self?.isrcIds[song.id] = isrcId
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            DispatchQueue.main.async {
                self?.isrcIdsFetched = true
            }
        }
    }
    
    func transferToSpotify() {
        let group = DispatchGroup()
        isrcIds.values.forEach { [weak self] id in
            group.enter()
            SpotifyAPI.manager.getTrackFromIsrc(id) {tracks, _, error in
                if !tracks.isEmpty {
                    self?.spotifyTracks.append(tracks[0])
                } else {
                    // tell the user which tracks weren't added
                    self?.notFoundOnSpotify.append(id)
                }
                group.leave()
            }
        }
        
        // notify the main thread when all isrcs are found
        group.notify(queue: .main) {
            SpotifyAPI.manager.createPlaylist(
                userId: nil,
                name: self.playlist.attributes?.name ?? "",
                description: self.playlist.attributes?.description?.standard ?? "",
                uris: self.spotifyTracks.map { $0.uri },
                isPublic: false, collaborative: false) { success, error in
                    // notify the view that the process completed
                    print("Success \(success), Error: \(error.debugDescription)")
            }
            
        }
    }
    
    func availableOnSpotify(_ id: String) -> Bool {
        // Just because ISRC was found, may not be found on spotify...
        return isrcIds[id] != nil
    }
}