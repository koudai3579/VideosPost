import UIKit
import Firebase
import Nuke
import AVFoundation

private let cellId = "cellId"

//Date型をString型に変換するpublic関数
public func dateFormatterForDateLabel(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: date)
}

//時間を「00:00」表示に変換するpublic関数
public func generateDuration(timeInterval: TimeInterval) -> String {
    
    let min = Int(timeInterval / 60)
    let sec = Int(round(timeInterval.truncatingRemainder(dividingBy: 60)))
    let duration = String(format: "%02d:%02d", min, sec)
    return duration
}

class VideosViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var videos = [Video]()
    @IBOutlet weak var videosTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "VideosPost"
        videosTableView.dataSource = self
        videosTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchVideoDatas()
    }
    
    private func fetchVideoDatas(){
        
        self.videos.removeAll()
        self.videos = [Video]()
        
        Firestore.firestore().collection("videos").getDocuments { (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                self.videosTableView.reloadData()
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let video = Video.init(dic: dic)
                self.videos.append(video)
                self.videosTableView.reloadData()
            })
        }
    }
    
    @IBAction func postVideo(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.mediaTypes = ["public.movie"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //動画URLを渡しながら画面遷移
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaURL = info[.mediaURL] as? URL
        picker.dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostVideoViewController") as! PostVideoViewController
        vc.mediaURL = mediaURL
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension VideosViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videosTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let thmnailImageView = cell.viewWithTag(1) as! UIImageView
        if let url = URL(string: self.videos[indexPath.row].thumbnailImageUrl){
            Nuke.loadImage(with: url, into: thmnailImageView)
        }
        let userImageView = cell.viewWithTag(3) as! UIImageView
        userImageView.layer.cornerRadius = 25
        let titleTextView = cell.viewWithTag(4) as! UITextView
        titleTextView.text = self.videos[indexPath.row].tittle
        
        let dateLabel = cell.viewWithTag(5) as! UILabel
        dateLabel.text = dateFormatterForDateLabel(date:self.videos[indexPath.row].date.dateValue())
        
        let durationLabel = cell.viewWithTag(2) as! UILabel
        //動画の長さを取得(非同期タスク)
        Task {
            do {
                let video = AVURLAsset(url: URL(string: self.videos[indexPath.row].videoUrl)!)
                let durationTime = try await TimeInterval(round(Float(video.load(.duration).value) / Float(video.load(.duration).timescale)))
                durationLabel.text = generateDuration(timeInterval: durationTime)
                
            } catch {
                print("エラー: \(error)")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlaybackVideoViewController")
        as! PlaybackVideoViewController
        vc.video = videos[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
