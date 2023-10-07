//
//  PlaybackVideoViewController.swift
//  Videos
//
//  Created by Koudai Okamura on 2023/09/21.
//

import UIKit
import AVFoundation

private let cellId1 = "cellId1"
private let cellId2 = "cellId2"

class PlaybackVideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row{
        case 0:return 200
        default:return 300
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = subContentTableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath)
            return cell
            
        default:
            let cell = subContentTableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath)
            return cell
            
        }
    }
    
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var subContentTableView: UITableView!
    
    var player:AVPlayer?
    var video:Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideo()
        subContentTableView.delegate = self
        subContentTableView.dataSource = self
        
    }
    
    private func configureVideo(){
        //        guard let path = Bundle.main.path(forResource: video.videoFileName, ofType: video.videoFileFormat) else{
        //            print("failed to get path")
        //            return
        //        }
        //        guard let url = URL(string: video.videoUrl) else {
        //            print("url is none")
        //            return}
        //        player = AVPlayer(url: url)
        //        let playerView = AVPlayerLayer()
        //        playerView.player = player
        //        playerView.frame = videoContentView.bounds
        //        playerView.videoGravity = .resizeAspectFill
        //        videoContentView.layer.addSublayer(playerView)
        //        player?.volume = 0
        //        player?.play()
        // Firebaseから取得した動画のURL
        guard let url = URL(string: video.videoUrl) else {
            print("この動画URLは無効です。")
            return
        }
        print("有効なURL:",url)
        // AVPlayerを作成
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoContentView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoContentView.layer.addSublayer(playerLayer)
        player!.volume = 1.0
        player!.play()
        
    }
    
    
}
