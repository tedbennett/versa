//
//  ImageView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 31/10/2020.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var viewModel: ImageFromUrlViewModel
    
    init(urlString: String?) {
        viewModel = ImageFromUrlViewModel(urlString: urlString)
    }
    
    var body: some View {
        if viewModel.image != nil {
            Image(uiImage: viewModel.image!)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "camera")
                .scaledToFit()
        }
    }
}

