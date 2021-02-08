//
//  Coordinator.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/08.
//

import UIKit

class Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window.rootViewController = PlayVideoViewController()
        window.makeKeyAndVisible()
    }
}
