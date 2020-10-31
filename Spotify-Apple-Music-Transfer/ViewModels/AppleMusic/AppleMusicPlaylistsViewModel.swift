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
    static let shared = AppleMusicPlaylistsViewModel()
    
    private init() {}
    
    var playlists = [AppleMusicAPI.LibraryPlaylist]() {
        willSet {
            objectWillChange.send()
        }
    }
    
    func getLibraryPlaylists() {
        
        AppleMusicAPI.manager.getAllLibraryPlaylists { playlists, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            if let playlists = playlists {
                DispatchQueue.main.async {
                    self.playlists = playlists
                }
            }
        }
    }
    
    func getImageUrl(from urlString: String?, dimension: Int = 640) -> String? {
        return urlString != nil ? urlString!.replacingOccurrences(of: "{w}", with: String(640))
        .replacingOccurrences(of: "{h}", with: String(640)) : nil
        
    }
}

