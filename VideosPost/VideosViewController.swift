//
//  VideosViewController.swift
//  Videos
//
//  Created by Koudai Okamura on 2023/09/21.
//

import UIKit
import Firebase
import Nuke
private let cellId = "cellId"

//struct VideoModel{
//    let caption:String
//    let username:String
//    let audioTrackName:String
//    let videoFileName:String
//    let videoFileFormat:String
//}


class VideosViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        titleTextView.text = self.self.videos[indexPath.row].tittle
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
    
    var videos = [Video]()
    @IBOutlet weak var videosTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videosTableView.dataSource = self
        videosTableView.delegate = self
        fetchVideoDatas()
        
    }
    
    private func fetchVideoDatas(){
        
        
        self.videos.removeAll()
        self.videos = [Video]()
        
//        guard let uid = Auth.auth().currentUser?.uid else {return}
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
        //動画だけを抽出。
        imagePickerController.mediaTypes = ["public.movie"]
        //編集不可にする。
        //imagePickerController.allowsEditing = false
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
