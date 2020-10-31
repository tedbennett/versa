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
    }
}

//struct AppleMusicPlaylistDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleMusicPlaylistDetail()
//    }
//}
