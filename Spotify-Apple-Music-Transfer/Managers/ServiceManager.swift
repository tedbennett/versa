//
//  ServiceManager.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import Foundation
import SpotifyAPI
import AppleMusicAPI

class ServiceManager {
    static var shared = ServiceManager()
    private init() {}
    
    func authoriseSpotify() {
        
    }
    
    func authoriseAppleMusic() {
        
    }
    
    func getSpotifyPlaylists(completion: @escaping ([SpotifyAPI.PlaylistSimplified]) -> Void) {
        SpotifyAPI.manager.getOwnPlaylists { playlists, error in
            if  let error = error {
                print(error.localizedDescription)
            }
            completion(playlists)
        }
    }
    
    func getSpotifyPlaylist(id: String, completion:  @escaping ([SpotifyAPI.PlaylistTrack]) -> Void) {
        SpotifyAPI.manager.getPlaylistsTracks(id: id, country: "GB") { songs, error in
            guard error == nil else {
                print(error.debugDescription)
                completion([])
                return
            }
            completion(songs.map { $0.track })
        }
    }
    
    func getAppleMusicPlaylists(completion: @escaping ([AppleMusicAPI.LibraryPlaylist]) -> Void) {
        AppleMusicAPI.manager.getAllLibraryPlaylists { playlists, error in
            guard let playlists = playlists else {
                print(error.debugDescription)
                completion([])
                return
            }
            completion(playlists)
        }
    }
    
    func getAppleMusicPlaylist(id: String, completion: @escaping ([AppleMusicAPI.LibrarySong]) -> Void) {
        AppleMusicAPI.manager.getLibraryPlaylistSongs(id: id) { songs, error in
            guard let songs = songs else {
                print(error.debugDescription)
                completion([])
                return
            }
            completion(songs)
        }
    }
    
    func findSongsOnSpotify(for songs: [AppleMusicAPI.LibrarySong], completion: @escaping ([String: String]) -> Void) {
        let group = DispatchGroup()
        var ids: [String: String] = [:]
        songs.forEach { song in
            group.enter()
            AppleMusicAPI.manager.getLibrarySongIsrcId(song: song) { id, error in
                guard let id = id else {
                    print(error.debugDescription)
                    group.leave()
                    return
                }
                SpotifyAPI.manager.getTrackFromIsrc(id) {tracks, _, error in
                    if !tracks.isEmpty {
                        ids[song.id] = tracks[0].uri
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion(ids)
        }
    }
    
    func findSongsOnSpotify(for songs: [AppleMusicAPI.Song], completion: @escaping ([String]) -> Void) {
        let group = DispatchGroup()
        let isrcIds = songs.compactMap { $0.attributes?.isrc }
        var uris: [String] = []
        isrcIds.forEach { isrc in
            group.enter()
            SpotifyAPI.manager.getTrackFromIsrc(isrc) {tracks, _, error in
                if !tracks.isEmpty {
                    uris.append(tracks[0].uri)
                }
                group.leave()
            }
            
        }
        group.notify(queue: .main) {
            completion(uris)
        }
    }
    
    func findSongsOnAppleMusic(tracks: [SpotifyAPI.PlaylistTrack], completion: @escaping ([String: AppleMusicAPI.Song]) -> Void) {
        let group = DispatchGroup()
        var ids: [String: AppleMusicAPI.Song] = [:]
        
        tracks.forEach { track in
            guard let isrc = track.externalIds?.isrc else {
                return
            }
            group.enter()
            AppleMusicAPI.manager.getCatalogSongByIsrcId(isrcId: isrc) { song, error in
                if let song = song {
                    ids[track.uri] = song
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(ids)
        }
    }
    
    func transferPlaylistToAppleMusic(songs: [AppleMusicAPI.Song], name: String, completion: @escaping (Bool) -> Void) {
        AppleMusicAPI.manager.createLibraryPlaylist(
            name: name,
            description: nil,
            songs: songs,
            librarySongs: []) { playlists, error in
            guard let playlists = playlists, !playlists.isEmpty else {
                print(error.debugDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func transferPlaylistToSpotify(uris: [String], name: String, description: String, completion: @escaping (Bool) -> Void) {
        SpotifyAPI.manager.createPlaylist(
            userId: nil,
            name: name,
            description: description,
            uris: uris,
            isPublic: false, collaborative: false) { success, error in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(success)
        }
    }
    
    func transferPlaylistToAppleMusic(fromId id: String, name: String, completion: @escaping (Bool) -> Void) {
        getSpotifyPlaylist(id: id) { [weak self] tracks in
            self?.findSongsOnAppleMusic(tracks: tracks) { map in
                let songs = map.values.compactMap { $0 }
                self?.transferPlaylistToAppleMusic(songs: songs, name: name) { success in
                    completion(success)
                }
            }
        }
    }
    
    func transferPlaylistToSpotify(fromId id: String, name: String, completion: @escaping (Bool) -> Void) {
        AppleMusicAPI.manager.getCatalogPlaylistSongs(id: id) { [weak self] songs, error in
            guard error == nil, let songs = songs, !songs.isEmpty else {
                print(error.debugDescription)
                completion(false)
                return
            }
            self?.findSongsOnSpotify(for: songs) { uris in
                guard !uris.isEmpty else {
                    completion(false)
                    return
                }
                self?.transferPlaylistToSpotify(uris: uris, name: name, description: "") { success in
                    completion(success)
                }
            }
        }
    }
}
