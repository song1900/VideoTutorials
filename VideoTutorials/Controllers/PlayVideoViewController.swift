//
//  PlayVideoViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/08.
//

import UIKit
import AVKit
import MobileCoreServices
import MediaPlayer

class deleteVC: UIViewController {
    // MARK: - Properties
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    var mergingVideo = false
    
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
    
    lazy var mergeButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Merge Video", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionRecrodAndSave), for: .touchUpInside)
        return bt
    }()
    
    lazy var loadVideo01Button: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load video 01", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionLoadVideo), for: .touchUpInside)
        return bt
    }()
    
    lazy var loadVideo02Button: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load video 02", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionLoadVideo), for: .touchUpInside)
        return bt
    }()
    
    lazy var loadMusicButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load music", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionLoadMusic), for: .touchUpInside)
        return bt
    }()
    
    private lazy var mergeActionStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [loadVideo01Button, loadVideo02Button, loadMusicButton])
        sv.axis = .horizontal
        sv.spacing = 3
        return sv
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [selectAndPlayButton, recordAndSaveButton, mergeButton, mergeActionStackView])
        sv.axis = .vertical
        sv.spacing = 50
        return sv
    }()
    
    let indicatorView = UIActivityIndicatorView()
    
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
        
        view.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
    }
    
    // MARK: - Actions
    @objc func actionSelectAndPlay() { // video 선택
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    @objc func actionRecrodAndSave() { // video 촬영
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    
    
    @objc func actionLoadVideo() {
        mergingVideo = true
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    @objc func actionLoadMusic() {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        present(mediaPickerController, animated: true, completion: nil)
    }
    
    @objc func actionMerge() {
        guard let firstAsset = firstAsset, let secondAsset = secondAsset else { return }
        indicatorView.startAnimating()
        
        let mixComposition = AVMutableComposition() // video + audio 임시 저장
        
        // 01 first video 추가
        guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        // insertTimeRange를 통해 first video의 어떤 부분까지 넣을지 정한다. (* video .zero ~ video.duration 전체 삽입)
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: firstAsset.duration), of: firstAsset.tracks(withMediaType: .video)[0], at: .zero)
        } catch {
            print("Failed to load first track")
            return
        }
        
        // 02 second video 추가
        guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
        
        
        do { // insertTimeRange를 통해 first video의 어떤 부분까지 넣을지 정한다. (* video .zero ~ video.duration 전체 삽입)
            try secondTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: secondAsset.duration), of: secondAsset.tracks(withMediaType: .video)[0], at: .zero)
        } catch {
            print("Failed to load second track")
            return
        }
        
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration)) // video 01 + 02 재생시간 합
        
        let firstInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration) // second video가 재생될 때 보여지지 않게 설정
        
        let secondInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack)
        
        // first, second Instruction을 AVMutableVideoComposition의 프로퍼티에 추가
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30) // frame rate 30fps
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        // audio 불러오기.
        if let loadedAudioAsset = audioAsset {
            let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
            do {
                try audioTrack?.insertTimeRange(
                    CMTimeRangeMake(start: .zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration)), // 시간 범위 = first video duration + second video duration
                    of: loadedAudioAsset.tracks(withMediaType: .audio)[0],
                    at: .zero)
            } catch {
                print("Failed to load Audio track")
            }
        }
        
        // 완성된 비디오를 저장
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        // 현재 시간을 이용해서 unique 한 파일 이름 생성
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        // 합쳐진 비디오를 render 하고 export 해야 한다.
        // export 설정과 함께 content 을 transcode 한다. 이전에 AVMutableVideoComposition을 설정해뒀기 때문에 exporter에 asign만 하면 된다.
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        // export session을 초기화 한 뒤 exportAsynchrously()을 통해 export 작업을 시작할 수 있다
        
        
        
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
extension deleteVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택한 비디오 처리
        switch picker.sourceType {
        case .savedPhotosAlbum: // video 선택
            if mergingVideo {
                guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                      mediaType == (kUTTypeMovie as String),
                      let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
                
                let avAsset = AVAsset(url: url)
                var message: String
                if loadingAssetOne{
                    message = "Video one loaded"
                    firstAsset = avAsset
                } else {
                    message = "Video two loaded"
                    secondAsset = avAsset
                }
                let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                
                
            } else {
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
extension deleteVC: UINavigationControllerDelegate {
    
}

// MARK: - MPMediaPickerControllerDelegate
extension deleteVC: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true) {
            let selectedAudios = mediaItemCollection.items
            guard let audio = selectedAudios.first else { return }
            
            let title: String
            let message: String
            if let url = audio.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                self.audioAsset = AVAsset(url: url)
                title = "Asset Loaded"
                message = "Audio Loaded"
            } else {
                self.audioAsset = nil
                title = "Asset Not Available"
                message = "Audio Not Loaded"
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
