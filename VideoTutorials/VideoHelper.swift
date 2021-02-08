//
//  VideoHelper.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/08.
//

import MobileCoreServices
import UIKit

enum VideoHelper {
    static func startMediaBrowser(
        delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
        sourceType: UIImagePickerController.SourceType
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true // 수정 가능 여부
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
        
    }
}
