//
//  ClipboardViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 28/10/2020.
//

import SwiftUI
import SpotifyAPI
import AppleMusicAPI

class ClipboardViewModel: ObservableObject {
    
    static var shared = ClipboardViewModel()
    
    private init() {}
    
    @Published var name: String?
    @Published var artistName: String?
    @Published var albumName: String?
    @Published var imageUrl: String?
    @Published var numTracks: Int?
    @Published var url: URL?
    var id: String?
    
    @Published var presentShareSheet = false
    @Published var transferring = false
    @Published var transferSuccess = false
    @Published var addToLibrarySuccess = false
    @Published var transferFail = false
    
    @Published var state = ClipboardState.searching {
        didSet {
            DispatchQueue.main.async {
                switch self.state {
                    case .spotifySong, .spotifyAlbum, .spotifyArtist, .spotifyPlaylist,
                         .appleMusicSong, .appleMusicAlbum, .appleMusicArtist, .appleMusicPlaylist:
                        self.foundLink = true
                    default:
                        self.foundLink = false
                }
            }
        }
    }
    
    @Published var foundLink = false
    
    private var lastCheckedContents = ""
    
    private func clear() {
        state = .searching
        name = nil
        artistName = nil
        albumName = nil
        imageUrl = nil
        numTracks = nil
        url = nil
        id = nil
    }
    
    func parseClipboard(_ contents: String?) {
        guard let contents = contents, contents != "" else {
            state = .noUrl
            return
        }
        guard contents != lastCheckedContents else {
            return
        }
        clear()
        lastCheckedContents = contents
        guard let url = URL(string: contents), let host = url.host, url.pathComponents.count > 1 else {
            state = .invalidUrl
            return
        }
        
        if host == "music.apple.com" {
            // Some examples
            // Song: https://music.apple.com/gb/album/please-shut-up-feat-a%24ap-rocky-key-gucci-mane/1271967474?i=1271967482
            // Artist: https://music.apple.com/gb/artist/a%24ap-mob/560677601
            // Playlist: https://music.apple.com/gb/playlist/ghj/pl.u-qxylK6xt2M8M4v3
            // First component is always '/'
            // Second component is storefront
            // Third component is resource type
            // Fifth component is the resource or parent resource id
            // For songs, the song id is in the query
            if url.pathComponents.count > 4 {
                switch url.pathComponents[2] {
                    case "album":
                        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems, !queryItems.isEmpty {
                            if let id = queryItems.first(where: {item -> Bool in item.name == "i" })?.value {
                                getSpotifySong(id: id)
                            } else {
                                state = .invalidUrl
                                return
                            }
                        } else {
                            getSpotifyAlbum(id: url.pathComponents[4])
                        }
                    case "artist":
                        getSpotifyArtist(id: url.pathComponents[4])
                    case "playlist":
                        getSpotifyPlaylist(id: url.pathComponents[4])
                    default:
                        state = .invalidUrl
                        return
                }
            }
            
        } else if host == "open.spotify.com" {
            // Some examples
            // Song: https://open.spotify.com/track/421g9amcUikSqmfuG8EwON
            // Album: https://open.spotify.com/album/0zeAijecFGZOS4OaRdPVz5
            // Artist: https://open.spotify.com/artist/5BvJzeQpmsdsFp4HGUYUEx
            // Playlist: https://open.spotify.com/playlist/16NmMHcjIqtV5UZ54zIQGs?si=WchjaJbAQDao47Z9RH05fA
            // First component is always '/'
            // Second component is resource type
            // Third component is id - simple!
            if url.pathComponents.count > 2 {
                switch url.pathComponents[1] {
                    case "track":
                        getAppleMusicSong(id: url.pathComponents[2])
                    case "album":
                        getAppleMusicAlbum(id: url.pathComponents[2])
                    case "artist":
                        getAppleMusicArtist(id: url.pathComponents[2])
                    case "playlist":
                        getAppleMusicPlaylist(id: url.pathComponents[2])
                    default:
                        state = .invalidUrl
                        return
                }
            }
        } else {
            state = .invalidUrl
            return
        }
    }
    
    private func getSpotifySong(id: String) {
        AppleMusicAPI.manager.getCatalogSong(id: id) { songs, error in
            guard let attributes = songs?.first?.attributes else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = attributes.name
                self.artistName = attributes.artistName
                self.albumName = attributes.albumName
                self.imageUrl = self.getAppleMusicImageUrl(from: attributes.artwork.url)
            }
            
            SpotifyAPI.manager.getTrackFromIsrc(attributes.isrc) { songs, url, error in
                guard let urlString = songs.first?.externalUrls.spotify else {
                    DispatchQueue.main.async {
                        self.state = .failedToFindOnSpotify
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.url = URL(string: urlString)
                    self.state = .spotifySong
                }
                self.id = songs.first?.id
            }
        }
    }
    
    private func getSpotifyAlbum(id: String) {
        AppleMusicAPI.manager.getCatalogAlbum(id: id) { albums, error in
            guard let attributes = albums?.first?.attributes else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = attributes.name
                self.artistName = attributes.artistName
                self.imageUrl = self.getAppleMusicImageUrl(from: attributes.artwork?.url)
            }
            
            // No ISRC for albums so we need to search...
            let search = "\(attributes.name) \(attributes.artistName)".replacingOccurrences(of: " ", with: "+")
            SpotifyAPI.manager.search(for: search) { (albums: [SpotifyAPI.AlbumSimplified], url, error) in
                guard let urlString = albums.first?.externalUrls.spotify else {
                    DispatchQueue.main.async {
                        self.state = .failedToFindOnSpotify
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.url = URL(string: urlString)
                    self.state = .spotifyAlbum
                }
                self.id = albums.first?.id
            }
        }
    }
    
    private func getSpotifyArtist(id: String) {
        AppleMusicAPI.manager.getCatalogArtist(id: id) { artists, error in
            guard let attributes = artists?.first?.attributes else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = attributes.name
            }
            
            // No ISRC for albums so we need to search...
            SpotifyAPI.manager.search(for: "\(attributes.name)".replacingOccurrences(of: " ", with: "+")) { (artists: [SpotifyAPI.Artist], url, error) in
                guard let urlString = artists.first?.externalUrls.spotify else {
                    DispatchQueue.main.async {
                        self.state = .failedToFindOnSpotify
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.url = URL(string: urlString)
                    self.imageUrl = artists.first?.images.first?.url
                    self.state = .spotifyArtist
                }
            }
        }
    }
    
    private func getSpotifyPlaylist(id: String) {
        AppleMusicAPI.manager.getCatalogPlaylist(id: id) { playlists, error in
            guard let attributes = playlists?.first?.attributes else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = attributes.name
                self.artistName = "Apple Music Playlist"
                self.imageUrl = self.getAppleMusicImageUrl(from: attributes.artwork?.url)
                self.state = .spotifyPlaylist
            }
            self.id = playlists?.first?.id
        }
    }
    
    private func getAppleMusicSong(id: String) {
        SpotifyAPI.manager.getTrack(id: id) { song, error in
            guard let song = song else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = song.name
                self.artistName = song.artists.first?.name ?? "Unknown Artist"
                self.albumName = song.album.name
                self.imageUrl = song.album.images.first?.url
            }
            if let isrc = song.externalIds.isrc {
                AppleMusicAPI.manager.getCatalogSongByIsrcId(isrcId: isrc) { song, error in
                    guard let url = song?.attributes?.url else {
                        DispatchQueue.main.async {
                            self.state = .failedToFindOnAppleMusic
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.url = url
                        self.state = .appleMusicSong
                    }
                    self.id = song?.id
                }
            }
        }
    }
    
    private func getAppleMusicAlbum(id: String) {
        SpotifyAPI.manager.getAlbum(id: id) { album, error in
            guard let album = album else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            let artistName = album.artists.first?.name ?? "Unknown Artist"
            DispatchQueue.main.async {
                self.artistName = artistName
                self.name = album.name
                self.imageUrl = album.images.first?.url
            }
            
            AppleMusicAPI.manager.searchCatalogAlbums(term: "\(artistName) \(album.name)") { albums, error in
                guard let url = albums?.first?.attributes?.url else {
                    DispatchQueue.main.async {
                        self.state = .failedToFindOnAppleMusic
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.url = url
                    self.state = .appleMusicAlbum
                }
                self.id = albums?.first?.id
            }
        }
    }
    
    private func getAppleMusicArtist(id: String) {
        SpotifyAPI.manager.getArtist(id: id) { artist, error in
            guard let artist = artist else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = artist.name
                self.imageUrl = artist.images.first?.url
            }
            AppleMusicAPI.manager.searchCatalogArtists(term: artist.name) { artists, error in
                guard let url = artists?.first?.attributes?.url else {
                    DispatchQueue.main.async {
                        self.state = .failedToFindOnAppleMusic
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.url = url
                    self.state = .appleMusicArtist
                }
            }
        }
    }
    
    private func getAppleMusicPlaylist(id: String) {
        SpotifyAPI.manager.getPlaylist(id: id) { playlist, error in
            guard let playlist = playlist else {
                print(error.debugDescription)
                self.state = .failedToGetResources
                return
            }
            DispatchQueue.main.async {
                self.name = playlist.name
                self.artistName = "Spotify Playlist"
                self.imageUrl = playlist.images.first?.url
                self.state = .appleMusicPlaylist
            }
            self.id = playlist.id
        }
    }
    
    private func transferDidComplete(success: Bool) {
        self.transferring = false
        if success {
            self.transferSuccess = true
        } else {
            self.transferFail = true
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    private func processDidComplete(success: Bool) {
        self.transferring = false
        if success {
            self.addToLibrarySuccess = true
        } else {
            self.transferFail = true
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    func addToLibrary() {
        guard let id = id else {
            transferFail = true
            return
        }
        transferring = true
        switch state {
            case .spotifySong:
                ServiceManager.shared.addSongToSpotify(id: id) { [weak self] success in
                    DispatchQueue.main.async {
                        self?.processDidComplete(success: success)
                    }
                }
            case .spotifyAlbum:
                ServiceManager.shared.addAlbumToSpotify(id: id) { [weak self] success in
                    DispatchQueue.main.async {
                        self?.processDidComplete(success: success)
                    }
                }
            case .appleMusicSong:
                ServiceManager.shared.addSongToAppleMusic(id: id) { [weak self] success in
                    DispatchQueue.main.async {
                        self?.processDidComplete(success: success)
                    }
                }
            case .appleMusicAlbum:
                ServiceManager.shared.addAlbumToAppleMusic(id: id) { [weak self] success in
                    DispatchQueue.main.async {
                        self?.processDidComplete(success: success)
                    }
                }
            default: break
        }
    }
    
    func transferToSpotify() {
        guard let id = id else {
            return
        }
        transferring = true
        ServiceManager.shared.transferPlaylistToSpotify(fromId: id, name: name ?? "New Playlist") { [weak self] success in
            DispatchQueue.main.async {
                self?.transferDidComplete(success: success)
            }
        }
    }
    
    func transferToAppleMusic() {
        guard let id = id else {
            return
        }
        transferring = true
        ServiceManager.shared.transferPlaylistToAppleMusic(fromId: id, name: name ?? "New Playlist") { [weak self] success in
            DispatchQueue.main.async {
                self?.transferDidComplete(success: success)
            }
        }
    }
    
    
    private func getImageURL(from string: String?) -> URL? {
        guard let string = string else {
            return nil
        }
        return URL(string: string)
    }
    
    private func getAppleMusicImageUrl(from string: String?) -> String? {
        return string?.replacingOccurrences(of: "{w}", with: String(640))
            .replacingOccurrences(of: "{h}", with: String(640))
    }
    
    
}

enum ClipboardState {
    case searching
    case noUrl
    case invalidUrl
    case failedToGetResources
    case failedToFindOnSpotify
    case failedToFindOnAppleMusic
    case spotifySong
    case spotifyAlbum
    case spotifyArtist
    case spotifyPlaylist
    case appleMusicSong
    case appleMusicAlbum
    case appleMusicArtist
    case appleMusicPlaylist
}
