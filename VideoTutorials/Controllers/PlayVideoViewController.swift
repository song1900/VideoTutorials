//
//  PlayVideoViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/08.
//

import UIKit
import AVKit
import MobileCoreServices

class PlayVideoViewController: UIViewController {
    // MARK: - Properties
    lazy var selectAndPlayButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Select And Play Video", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionSelectAndPlay), for: .touchUpInside)
        return bt
    }()
    
    lazy var recordAndSaveButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Record And Save Video", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionRecrodAndSave), for: .touchUpInside)
        return bt
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [selectAndPlayButton, recordAndSaveButton])
        sv.axis = .vertical
        sv.spacing = 50
        return sv
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }
    
    // MARK: - Configure
    func configure() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
    }
    
    // MARK: - Actions
    @objc func actionSelectAndPlay() { // video 선택
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    @objc func actionRecrodAndSave() { // video 촬영
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    
    // video 저장, 저장 결과 alert
    @objc func video(_ videoPath: String,
                     didFinishSavingWithError error: Error?,
                     contextInfo info: AnyObject
    ) {
        print(videoPath)
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택한 비디오 처리
        switch picker.sourceType {
        case .photoLibrary: // video 선택
            guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                  mediaType == (kUTTypeMovie as String),
                  let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            
            dismiss(animated: true) {
                let player = AVPlayer(url: url)
                let vcPlayer = AVPlayerViewController()
                vcPlayer.player = player
                self.present(vcPlayer, animated: true, completion: nil)
            }
            
        case .camera: // video 촬영
            dismiss(animated: true, completion: nil)
            
            guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                  mediaType == (kUTTypeMovie as String),
                  let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                  UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) else { return }
            
            
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video), nil)
            
        default:
            break
        }
        
        
    }
    
    
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
    
}
