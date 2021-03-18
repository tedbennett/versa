//
//  AppleMusicPlaylistsView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI

struct AppleMusicPlaylistsView: View {
    
    @ObservedObject var viewModel = AppleMusicPlaylistsViewModel()
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(
                        destination: AppleMusicPlaylistDetail(playlist: playlist),
                        label: {
                            PlaylistItem(
                                name: playlist.attributes?.name,
                                imageUrl: viewModel.getImageUrl(from: playlist.attributes?.artwork?.url, dimension: 240))
                        })
                }
            }.navigationTitle("Apple Music Playlists")
//            .onAppear {
//                if viewModel.playlists.isEmpty {
//                    viewModel.getLibraryPlaylists()
//                }
//            }
        }
    }
}

struct AppleMusicPlaylistList_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlaylistsView()
    }
}
