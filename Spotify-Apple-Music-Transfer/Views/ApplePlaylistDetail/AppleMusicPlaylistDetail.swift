//
//  AppleMusicPlaylistDetail.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import AppleMusicAPI
import AlertToast

struct AppleMusicPlaylistDetail: View {
    @ObservedObject var viewModel: AppleMusicPlaylistDetailViewModel
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        viewModel = AppleMusicPlaylistDetailViewModel(playlist: playlist)
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.songs) { song in
                    HStack {
                        SongItem(name: song.attributes?.name, artist: song.attributes?.artistName, imageUrl: viewModel.getImageUrl(from: song.attributes?.artwork.url))
                        Spacer()
                        if viewModel.searching {
                            ProgressView()
                        } else {
                            Image(systemName: viewModel.spotifyTracks[song.id] != nil ? "checkmark" : "xmark")
                        }
                    
                    }
                }
            }.onAppear {
                if viewModel.spotifyTracks.isEmpty {
                    viewModel.findSongsOnSpotify()
                }
            }.navigationTitle(viewModel.playlistName())
            .navigationBarItems(trailing: Button(action: {
                viewModel.transferToSpotify()
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
}

//struct AppleMusicPlaylistDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleMusicPlaylistDetail()
//    }
//}
