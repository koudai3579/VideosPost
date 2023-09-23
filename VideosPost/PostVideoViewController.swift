//
//  PostVideoViewController.swift
//  VideosPost
//
//  Created by Koudai Okamura on 2023/09/23.
//

import UIKit
import AVFoundation
import Firebase

class PostVideoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tittleTextField: UITextField!
    @IBOutlet weak var videoContentView: UIView!
    var mediaURL:URL!
    var player:AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideo()
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailImageViewTapped)))

    }
    
    private func configureVideo(){

        player = AVPlayer(url: mediaURL)
        print(mediaURL)
        let playerView = AVPlayerLayer()
        playerView.player = player
        playerView.frame = videoContentView.bounds
        playerView.videoGravity = .resizeAspectFill
        videoContentView.layer.addSublayer(playerView)
        player?.volume = 0
        player?.play()
        
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        //画像をURLに変換してStorageに保存
        let thumbnailImage = thumbnailImageView.image!
        guard let uploadImage = thumbnailImage.jpegData(compressionQuality: 0.5) else {return}
        let ImageileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("thumbnail_image").child(ImageileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    return
                }
                guard let thumbnailImageUrl = url?.absoluteString else {return}
                
                //動画をURLに変換してStorageに保存
                
            }
        }
    }
    
    @objc func thumbnailImageViewTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            thumbnailImageView.image = editImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            thumbnailImageView.image = originalImage
        }
        dismiss(animated:true, completion: nil)
    }
    
}
