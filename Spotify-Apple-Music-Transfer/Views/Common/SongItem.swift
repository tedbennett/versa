//
//  SongItem.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 31/10/2020.
//

import SwiftUI

struct SongItem: View {
    var name: String?
    var artist: String?
    var imageUrl: String?
    
    var body: some View {
        HStack {
            ImageView(urlString: imageUrl).frame(width:80, height: 80).cornerRadius(8)
            VStack(alignment: .leading) {
                Text(name ?? "Unknown Song")
                Text(artist ?? "Unknown Artist")
                    .font(.footnote).foregroundColor(.gray)
            }
        }
    }
}
