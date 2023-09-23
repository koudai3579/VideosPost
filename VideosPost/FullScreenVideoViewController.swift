//
//  FullScreenVideoViewController.swift
//  VideosPost
//
//  Created by Koudai Okamura on 2023/09/23.
//

import UIKit
import AVFoundation


class FullScreenVideoViewController: UIViewController {
    
    var mediaURL:URL!
    var player:AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        rotate(orientation: .landscapeRight)
       

    }
    
    private func configureVideo(){

        player = AVPlayer(url: mediaURL)
        let playerView = AVPlayerLayer()
        playerView.player = player
        playerView.frame = self.view.bounds
        playerView.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(playerView)
        player?.volume = 0
        player?.play()
        
    }
    
    private func rotate(orientation: UIInterfaceOrientation) {
            if #available(iOS 16.0, *) {
                guard let windowScene = view.window?.windowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation == .portrait ? .portrait : .landscapeRight)) { error in
                    // 画面回転の要求が拒否された場合の処理
                }
            } else {
                UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            }
        }
    
    

   

}
