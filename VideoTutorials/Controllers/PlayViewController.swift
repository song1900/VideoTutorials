//
//  PlayViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/10.
//

import UIKit
import SnapKit
import AVKit
import MobileCoreServices

class PlayViewController: UIViewController {
    // MARK: - Properties
    var videoPlayer = AVPlayer()
    var playerLayer = AVPlayerLayer()
    let videoView = UIView()
    
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }
    
    // MARK: - Configure
    func configure() {
        view.backgroundColor = .systemBackground
        self.title = "Select and Play Video"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionPlayVideo))
        
        
        view.addSubview(videoView)
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        

    }
    
    // MARK: - Action
    @objc func actionPlayVideo() {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension PlayViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        
        if playerLayer.isReadyForDisplay { playerLayer.removeFromSuperlayer() }

        dismiss(animated: true) {
            self.videoPlayer = AVPlayer(url: url)
            self.playerLayer = AVPlayerLayer(player: self.videoPlayer)
            self.playerLayer.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(self.playerLayer)
            self.videoPlayer.play()
        }
        
    }
    
    
}

// MARK: - UINavigationControllerDelegate
extension PlayViewController: UINavigationControllerDelegate {
}
