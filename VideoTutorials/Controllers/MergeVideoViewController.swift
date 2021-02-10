//
//  MergeVideoViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/10.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import Photos
import SnapKit
import AVKit

class MergeVideoViewController: UIViewController {
    // MARK: - Properties
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
    let indicatorView = UIActivityIndicatorView()
    
    lazy var loadVideoOneButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load video 01", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.addTarget(self, action: #selector(actionLoadAssetOne), for: .touchUpInside)
        return bt
    }()
    
    lazy var loadVideoTwoButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load video 02", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.addTarget(self, action: #selector(actionLoadAssetTwo), for: .touchUpInside)
        return bt
    }()
    
    lazy var loadMusicButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Load music", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.addTarget(self, action: #selector(actionLoadMusic), for: .touchUpInside)
        return bt
    }()
    
    lazy var mergeButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Merge and Save", for: .normal)
        bt.setTitleColor(.red, for: .normal)
        bt.addTarget(self, action: #selector(actionMerge), for: .touchUpInside)
        return bt
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [loadVideoOneButton, loadVideoTwoButton, loadMusicButton, mergeButton])
        sv.axis = .vertical
        sv.spacing = 15
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
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        
    }
    
    
    // MARK: - Actions
    @objc func actionLoadAssetOne() {
        if savedPhotosAvailable() {
            loadingAssetOne = true
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
    }
    
    @objc func actionLoadAssetTwo() {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
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

        let mixComposition = AVMutableComposition()

        guard let firstTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
          else { return }

        do {
          try firstTrack.insertTimeRange(
            CMTimeRangeMake(start: .zero, duration: firstAsset.duration),
            of: firstAsset.tracks(withMediaType: .video)[0],
            at: .zero)
        } catch {
          print("Failed to load first track")
          return
        }

        guard
          let secondTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
          else { return }

        do {
          try secondTrack.insertTimeRange(
            CMTimeRangeMake(start: .zero, duration: secondAsset.duration),
            of: secondAsset.tracks(withMediaType: .video)[0],
            at: firstAsset.duration)
        } catch {
          print("Failed to load second track")
          return
        }

        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(
          start: .zero,
          duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))

        
        let firstInstruction = VideoHelper.videoCompositionInstruction(
          firstTrack,
          asset: firstAsset)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = VideoHelper.videoCompositionInstruction(
          secondTrack,
          asset: secondAsset)

        
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height)

        
        if let loadedAudioAsset = audioAsset {
          let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: 0)
          do {
            try audioTrack?.insertTimeRange(
              CMTimeRangeMake(
                start: CMTime.zero,
                duration: CMTimeAdd(
                  firstAsset.duration,
                  secondAsset.duration)),
              of: loadedAudioAsset.tracks(withMediaType: .audio)[0],
              at: .zero)
          } catch {
            print("Failed to load Audio track")
          }
        }

        
        guard
          let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first
          else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")

        
        guard let exporter = AVAssetExportSession(
          asset: mixComposition,
          presetName: AVAssetExportPresetHighestQuality)
          else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition

        
        exporter.exportAsynchronously {
          DispatchQueue.main.async {
            self.exportDidFinish(exporter)
          }
        }
      
    }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
        // Cleanup assets
        indicatorView.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil

        guard session.status == AVAssetExportSession.Status.completed, let outputURL = session.outputURL else { return }

        let saveVideoToPhotos = {
            let changes: () -> Void = {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            }

            PHPhotoLibrary.shared().performChanges(changes) { saved, error in
                DispatchQueue.main.async {
                  let success = saved && (error == nil)
                  let title = success ? "Success" : "Error"
                  let message = success ? "Video saved" : "Failed to save video"

                  let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert)
                  alert.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                  self.present(alert, animated: true, completion: nil)
                }
            }
        }

        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            }
        } else {
            saveVideoToPhotos()
        }
        
    }
    
    
    func savedPhotosAvailable() -> Bool {
        guard !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return true }

        let alert = UIAlertController(title: "Not Available", message: "No Saved Album found",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return false
    }
    
    
}

// MARK: - UIImagePickerControllerDelegate
extension MergeVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
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
        
    }
}

// MARK: - UINavigationControllerDelegate
extension MergeVideoViewController: UINavigationControllerDelegate {
}

// MARK: - MPMediaPickerControllerDelegate
extension MergeVideoViewController: MPMediaPickerControllerDelegate {
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
