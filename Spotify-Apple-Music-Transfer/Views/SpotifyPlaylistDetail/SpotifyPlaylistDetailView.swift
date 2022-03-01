//
//  SpotifyPlaylistDetailView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI
import AlertToast

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
        .toast(isPresenting: $viewModel.transferring) {
            AlertToast(type: .loading, title: "Transferring...", subTitle: nil)
        }
        .toast(isPresenting: $viewModel.transferSuccess, duration: 2.0, tapToDismiss: false, alert: {
            AlertToast(type: .complete(.primary), title: "Transfer complete!", subTitle: nil)
        }, completion: {})
        .toast(isPresenting: $viewModel.transferFail, duration: 2.0, tapToDismiss: false, alert: {
            AlertToast(type: .error(.primary), title: "Transfer failed", subTitle: "An error occured")
        }, completion: {})
    }
}

//struct SpotifyPlaylistDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyPlaylistDetailView()
//    }
//}
