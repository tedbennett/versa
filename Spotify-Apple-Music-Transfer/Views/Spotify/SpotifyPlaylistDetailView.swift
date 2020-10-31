//
//  SpotifyPlaylistDetailView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI

struct SpotifyPlaylistDetailView: View {
    @ObservedObject var viewModel: SpotifyPlaylistDetailViewModel
    
    var playlist: SpotifyAPI.PlaylistSimplified
    
    init(playlist: SpotifyAPI.PlaylistSimplified) {
        self.playlist = playlist
        viewModel = SpotifyPlaylistDetailViewModel(playlist: playlist)
    }
    
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                SongItem(name: song.name, artist: song.artists?.first?.name, imageUrl: song.album?.images.first?.url)
            }
        }.onAppear {
            viewModel.getPlaylistSongs()
        }.navigationTitle(playlist.name)
        .navigationBarItems(trailing: Button(action: {
            viewModel.transferToAppleMusic()
        }, label: {
            HStack {
                Text("Transfer")
                Image(systemName: "chevron.right")
            }
        }))
    }
}

//struct SpotifyPlaylistDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyPlaylistDetailView()
//    }
//}
