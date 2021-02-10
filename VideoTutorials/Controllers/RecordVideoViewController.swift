//
//  RecordVideoViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/10.
//

import UIKit
import SnapKit
import MobileCoreServices

class RecordVideoViewController: UIViewController {
    // MARK: - Properties
    lazy var recordAndSaveButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Record Video", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.addTarget(self, action: #selector(actionRecrodAndSave), for: .touchUpInside)
        return bt
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
        
        view.addSubview(recordAndSaveButton)
        recordAndSaveButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
    
    // MARK: - Actions
    @objc func actionRecrodAndSave() {
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
extension RecordVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) else { return }
        
        
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video), nil)
    }
}

// MARK: - UINavigationControllerDelegate
extension RecordVideoViewController: UINavigationControllerDelegate {
}
