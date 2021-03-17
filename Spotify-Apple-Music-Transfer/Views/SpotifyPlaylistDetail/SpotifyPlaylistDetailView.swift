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
    
    init(playlist: SpotifyAPI.PlaylistSimplified) {
        viewModel = SpotifyPlaylistDetailViewModel(playlist: playlist)
    }
    
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                HStack {
                    SongItem(name: song.name, artist: song.artists?.first?.name, imageUrl: song.album?.images.first?.url)
                    Spacer()
                    if viewModel.searching {
                        ProgressView()
                    } else {
                        Image(systemName: viewModel.appleMusicSongs[song.uri] != nil ? "checkmark" : "xmark")
                    }
                }
            }
        }
        .onAppear {
            if viewModel.appleMusicSongs.isEmpty {
                viewModel.findSongsOnAppleMusic()
            }
        }.navigationTitle(viewModel.playlist.name)
        .navigationBarItems(trailing: Button(action: {
            viewModel.transferToAppleMusic()
        }, label: {
            HStack {
                if (viewModel.searching) {
                    ProgressView()
                }
                Text("Transfer").padding(.leading, 5).animation(.easeInOut)
            }
        }).disabled(viewModel.searching)
        )
        .blur(radius: viewModel.transferring ? 3.0 : 0.0)
        if (viewModel.transferring) {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous).frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                ProgressView()
            }
        }
    }
}

//struct SpotifyPlaylistDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyPlaylistDetailView()
//    }
//}
