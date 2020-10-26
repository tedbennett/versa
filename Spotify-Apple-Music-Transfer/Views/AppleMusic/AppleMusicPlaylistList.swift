//
//  AppleMusicPlaylistList.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI

struct AppleMusicPlaylistList: View {
    
    @ObservedObject var viewModel = AppleMusicPlaylistsViewModel.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    NavigationLink(
                        destination: AppleMusicPlaylistDetail(playlist: playlist),
                        label: {
                            Text(playlist.attributes?.name ?? "Unknown Name")
                        })
                }
            }.navigationTitle("Your Playlists")
            .onAppear {
                viewModel.getLibraryPlaylists()
            }
        }
    }
}

struct AppleMusicPlaylistList_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlaylistList()
    }
}
