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
    @objc func actionSelectAndPlay() {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택한 비디오 처리
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
        
        dismiss(animated: true) {
            let player = AVPlayer(url: url)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        }
        
    }
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
    
}
