import UIKit
import AVFoundation
import Firebase

class PostVideoViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate,UINavigationControllerDelegate {
    
    var mediaURL:URL!
    var player:AVPlayer?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tittleTextField: UITextField!
    @IBOutlet weak var videoContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideo()
        postButton.isEnabled = false
        postButton.layer.cornerRadius = 10
        tittleTextField.delegate = self
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailImageViewTapped)))
    }
    
    private func configureVideo(){
        player = AVPlayer(url: mediaURL)
        let playerView = AVPlayerLayer()
        playerView.player = player
        playerView.frame = videoContentView.bounds
        playerView.videoGravity = .resizeAspectFill
        videoContentView.layer.addSublayer(playerView)
        player?.volume = 0
        player?.play()
        
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        self.postButton.isEnabled = false
        uploadVideoToDB(url: self.mediaURL)
    }
    
    func uploadVideoToDB(url: URL){
        //①画像をURLに変換してStorageに保存
        let thumbnailImage = thumbnailImageView.image!
        guard let uploadImage = thumbnailImage.jpegData(compressionQuality: 0.5) else {return}
        let ImageFileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("thumbnail_image").child(ImageFileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                return
            }
            storageRef.downloadURL { (imageURL, err) in
                if let err = err{
                    print("Firebaseから画像のダウンロードに失敗しました。\(err)")
                    return
                }
                guard let uploadedThumbnailImageUrl = imageURL?.absoluteString else {return}
                
                //②動画をURLに変換してStorageに保存
                let filename = UUID().uuidString
                let videoRef = Storage.storage().reference().child("videos").child("\(filename).mp4")
                do {
                    let videoData = try Data(contentsOf: url)
                    videoRef.putData(videoData) { (metadata, error) in
                        if let error = error {
                            print("Firebase_Storageへの動画の保存に失敗しました。エラー: \(error)")
                            return
                        }
                        
                        videoRef.downloadURL { (videoURL, error) in
                            if let error = error {
                                print("Firebaseからの動画のダウンロードに失敗しました。エラー: \(error)")
                                return
                            }
                            
                            guard let uploadedVideoUrl = videoURL?.absoluteString else {return}
                            
                            //③FireStoreにデータをテキストベースで保存
                            let videoUUID = NSUUID().uuidString
                            let docData = [
                                "docID": videoUUID,
                                "tittle": self.tittleTextField.text ?? "タイトルなし",
                                "videoUrl": uploadedVideoUrl,
                                "thumbnailImageUrl": uploadedThumbnailImageUrl,
                                "date":Timestamp(),
                                "playedCount":0,
                            ] as [String : Any]
                            
                            Firestore.firestore().collection("videos").document(videoUUID).setData(docData) { (err) in
                                if let err = err {
                                    print("err:",err)
                                }
                                
                                let alert = UIAlertController(title: "投稿が完了しました。", message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } catch {
                    print("動画の読み込みに失敗しました。エラー: \(error)")
                }
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if tittleTextField.text?.isEmpty == true{
            postButton.isEnabled = false
        }else{
            postButton.isEnabled = true
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
