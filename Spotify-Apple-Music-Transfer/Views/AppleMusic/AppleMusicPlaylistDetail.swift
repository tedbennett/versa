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
    
    var playlist: AppleMusicAPI.LibraryPlaylist
    
    init(playlist: AppleMusicAPI.LibraryPlaylist) {
        self.playlist = playlist
        viewModel = AppleMusicPlaylistDetailViewModel(playlist: playlist)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                VStack(alignment: .leading) {
                    Text(song.attributes?.name ?? "Unknown Song")
                        .foregroundColor(viewModel.availableOnSpotify(song.id) ? .white : .gray)
                    Text(song.attributes?.artistName ?? "Unknown Artist")
                        .font(.footnote).foregroundColor(.gray)
                }
            }
        }.onAppear {
            viewModel.getPlaylistSongs()
        }.navigationTitle(playlist.attributes?.name ?? "Playlist")
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
