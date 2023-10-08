import UIKit
import AVFoundation
import Firebase
import Nuke
import AVKit

private let cellId1 = "cellId1"
private let cellId2 = "cellId2"

class PlaybackVideoViewController: UIViewController {
    
    var player:AVPlayer?
    var video:Video!
    var relatedVideos = [Video]()
    
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var showFullscreenVideoButton: UIButton!
    @IBOutlet weak var subContentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showFullscreenVideoButton.layer.cornerRadius = 10
        configureVideo()
        subContentTableView.delegate = self
        subContentTableView.dataSource = self
        updatePlayedCount()
        fetchRelatedVideos()
    }
    
    private func configureVideo(){
        guard let url = URL(string: video.videoUrl) else {
            print("この動画URLは無効です。")
            return
        }
        // AVPlayer作成
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoContentView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoContentView.layer.addSublayer(playerLayer)
        player!.volume = 1.0
        player!.play()
        videoContentView.bringSubviewToFront(showFullscreenVideoButton)
    }
    
    @IBAction func showFullscreenVideoButtonTapped(_ sender: Any) {
        let player = AVPlayer(url: URL(string: video.videoUrl)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    private func fetchRelatedVideos(){
        self.relatedVideos.removeAll()
        self.relatedVideos = [Video]()
        
        Firestore.firestore().collection("videos").getDocuments { (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                
                let dic = snapshot.data()
                let thisVideo = Video.init(dic: dic)
                
                if thisVideo.videoUrl == self.video.videoUrl{return}
                
                self.relatedVideos.append(thisVideo)
                self.subContentTableView.reloadData()
            })
        }
    }
    
    private func updatePlayedCount(){
        Firestore.firestore().collection("videos").document(self.video.docID).updateData([
            "playedCount": (self.video.playedCount + 1)
        ]) { err in
            if let err = err {
                print("playedCountのアップデートに失敗しました。: \(err)")
            }
        }
    }
    
}

extension PlaybackVideoViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row{
        case 0:return 200
        default:return 300
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.relatedVideos.count + 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        //動画詳細(1番上のセル)
        case 0:
            let cell = subContentTableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath)
            cell.isUserInteractionEnabled = false
            let titleTextView = cell.viewWithTag(1) as! UITextView
            titleTextView.text = self.video.tittle
            let detailLabel = cell.viewWithTag(2) as! UILabel
            detailLabel.text = " 再生回数:\(self.video.playedCount + 1)・アップロード:\(dateFormatterForDateLabel(date:self.video.date.dateValue()))"
            let userImageView = cell.viewWithTag(3) as! UIImageView
            userImageView.layer.cornerRadius = 25
            let subscribeButton = cell.viewWithTag(5) as! UIButton
            subscribeButton.layer.cornerRadius = 5
            return cell
            
        //関連動画(2番目以降のセル)
        default:
            let cell = subContentTableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath)
            let thmnailImageView = cell.viewWithTag(1) as! UIImageView
            if let url = URL(string: self.relatedVideos[indexPath.row - 1].thumbnailImageUrl){
                Nuke.loadImage(with: url, into: thmnailImageView)
            }
            let userImageView = cell.viewWithTag(3) as! UIImageView
            userImageView.layer.cornerRadius = 25
            let titleTextView = cell.viewWithTag(4) as! UITextView
            titleTextView.text = self.relatedVideos[indexPath.row - 1].tittle
            let dateLabel = cell.viewWithTag(5) as! UILabel
            dateLabel.text = dateFormatterForDateLabel(date:self.relatedVideos[indexPath.row - 1].date.dateValue())
            
            let durationLabel = cell.viewWithTag(2) as! UILabel
            //動画の長さを取得(非同期タスク)
            Task {
                do {
                    let video = AVURLAsset(url: URL(string: self.relatedVideos[indexPath.row - 1].videoUrl)!)
                    let durationTime = try await TimeInterval(round(Float(video.load(.duration).value) / Float(video.load(.duration).timescale)))
                    durationLabel.text = generateDuration(timeInterval: durationTime)
                    
                } catch {
                    print("エラー: \(error)")
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlaybackVideoViewController")
        as! PlaybackVideoViewController
        vc.video = self.relatedVideos[indexPath.row - 1]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
