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
    
    
    
    @IBOutlet weak var FullScreenVideoButton: UIButton!
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var subContentTableView: UITableView!
    
    var player:AVPlayer?
    var video:VideoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideo()
        subContentTableView.delegate = self
        subContentTableView.dataSource = self
        
    }
    
    private func configureVideo(){
        guard let video = video else {
            print("video is none")
            return}
        guard let path = Bundle.main.path(forResource: video.videoFileName, ofType: video.videoFileFormat) else{
            print("failed to get path")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerView = AVPlayerLayer()
        playerView.player = player
        playerView.frame = videoContentView.bounds
        playerView.videoGravity = .resizeAspectFill
        videoContentView.layer.addSublayer(playerView)
        player?.volume = 0
        player?.play()
        videoContentView.bringSubviewToFront(FullScreenVideoButton)

        
    }
    
    
    @IBAction func showFullScreenVideo(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "FullScreenVideoViewController") as! FullScreenVideoViewController
        navigationController?.pushViewController(vc, animated: true)
        // 横向きに切り替える
        
    }
    
}
