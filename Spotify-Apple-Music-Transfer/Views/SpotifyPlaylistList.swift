//
//  SpotifyPlaylistList.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI

struct SpotifyPlaylistList: View {
    @ObservedObject var viewModel = SpotifyPlaylistsViewModel.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    Text(playlist.name)
                }
            }.navigationTitle("Your Playlists")
            .onAppear {
                viewModel.getLibraryPlaylists()
            }
        }
    }
}

struct SpotifyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistList()
    }
}
