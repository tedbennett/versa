//
//  ImageView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 31/10/2020.
//

import SwiftUI

struct ImageView: View {
    static var defaultImage = UIImage(systemName: "camera")
    @ObservedObject var viewModel: ImageFromUrlViewModel
    
    init(urlString: String?) {
        viewModel = ImageFromUrlViewModel(urlString: urlString)
    }
    
    var body: some View {
        Image(uiImage: viewModel.image ?? ImageView.defaultImage!)
            .resizable()
            .scaledToFit()
    }
}

