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
                Text(song.attributes?.name ?? "Unknown Song")
            }
        }.onAppear {
            viewModel.getPlaylistSongs()
        }.navigationTitle(playlist.attributes?.name ?? "Playlist")
    }
}

//struct AppleMusicPlaylistDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleMusicPlaylistDetail()
//    }
//}
