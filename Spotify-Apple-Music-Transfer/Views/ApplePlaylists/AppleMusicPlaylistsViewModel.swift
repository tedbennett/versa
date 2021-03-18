//
//  AppleMusicPlaylistsViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import Combine
import AppleMusicAPI

class AppleMusicPlaylistsViewModel: ObservableObject {
    @Published var playlists = [AppleMusicAPI.LibraryPlaylist]()
    
    init() {
        getLibraryPlaylists()
    }
    
    func getLibraryPlaylists() {
        ServiceManager.shared.getAppleMusicPlaylists() { [weak self] playlists in
            DispatchQueue.main.async {
                self?.playlists = playlists
            }
        }
    }
    
    func getImageUrl(from urlString: String?, dimension: Int = 640) -> String? {
        return urlString != nil ? urlString!.replacingOccurrences(of: "{w}", with: String(dimension))
        .replacingOccurrences(of: "{h}", with: String(dimension)) : nil
    }
}

