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
            .navigationBarItems(leading: Button {
                AuthViewModel.shared.logoutAppleMusic()
            } label: {
                Text("Logout")
            })
        }
    }
}

struct AppleMusicPlaylistList_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlaylistsView()
    }
}
