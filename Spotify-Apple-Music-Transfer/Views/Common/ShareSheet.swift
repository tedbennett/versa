//
//  ShareSheet.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    
    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
    
}
