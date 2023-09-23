//
//  VideosViewController.swift
//  Videos
//
//  Created by Koudai Okamura on 2023/09/21.
//

import UIKit
private let cellId = "cellId"

struct VideoModel{
    let caption:String
    let username:String
    let audioTrackName:String
    let videoFileName:String
    let videoFileFormat:String
}


class VideosViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videosTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
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

    var videos = [VideoModel]()
    @IBOutlet weak var videosTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<10{
            let model = VideoModel(caption: "caption", username: "username", audioTrackName: "audioTrackName", videoFileName: "video1", videoFileFormat: "mp4")
            videos.append(model)
        }
        videosTableView.dataSource = self
        videosTableView.delegate = self

    }
    
    
    @IBAction func postVideo(_ sender: Any) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                //タイプはアルバム。
                imagePickerController.sourceType = .savedPhotosAlbum
                //動画だけを抽出。
                imagePickerController.mediaTypes = ["public.movie"]
                //編集不可にする。
//                imagePickerController.allowsEditing = false
                self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaURL = info[.mediaURL] as? URL
        picker.dismiss(animated: true, completion: nil)
        
        //動画URLを渡しながら画面遷移。
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostVideoViewController") as! PostVideoViewController
        vc.mediaURL = mediaURL
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    


}
