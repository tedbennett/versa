//
//  AppleMusicPlaylistDetail.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import AppleMusicAPI

struct AppleMusicPlaylistDetail: View {
    @ObservedObject var viewModel: AppleMusicPlaylistDetailViewModel
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        viewModel = AppleMusicPlaylistDetailViewModel(playlist: playlist)
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.songs) { song in
                    SongItem(name: song.attributes?.name, artist: song.attributes?.artistName, imageUrl: viewModel.getImageUrl(from: song.attributes?.artwork.url))
                }
            }.onAppear {
                viewModel.getPlaylistSongs()
            }.navigationTitle(viewModel.getPlaylistName())
            .navigationBarItems(trailing: Button(action: {
                viewModel.transferToSpotify()
            }, label: {
                Text("Transfer")
            }).disabled(!viewModel.isrcIdsFetched)
            )
            .blur(radius: viewModel.transferring ? 3.0 : 0.0)
            if (viewModel.transferring) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous).frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                        .scaleEffect(2.0, anchor: .center)
                }
            }
        }
    }
}

//struct AppleMusicPlaylistDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleMusicPlaylistDetail()
//    }
//}
