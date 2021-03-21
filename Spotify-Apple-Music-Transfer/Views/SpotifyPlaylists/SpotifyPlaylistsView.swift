//
//  SpotifyPlaylistsView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI

struct SpotifyPlaylistsView: View {
    @ObservedObject var viewModel = SpotifyPlaylistsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(
                        destination: SpotifyPlaylistDetailView(playlist: playlist),
                        label: {
                            PlaylistItem(name: playlist.name, imageUrl: playlist.images.first?.url)
                        })
                }
            }.navigationTitle("Spotify Playlists")
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: Button {
                viewModel.refresh()
            } label: {
                if viewModel.loading {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            })
        }
    }
}

struct SpotifyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlaylistsView()
    }
}
