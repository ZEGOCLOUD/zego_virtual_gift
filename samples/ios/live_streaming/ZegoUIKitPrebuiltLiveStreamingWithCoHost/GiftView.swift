//
//  GiftView.swift
//  virtual_gift_demo
//
//  Created by Kael Ding on 2023/11/6.
//

import UIKit

class GiftView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        Mp4PlayerManager.shared.delegate = self
        Mp4PlayerManager.shared.createMediaPlayer()
        Mp4PlayerManager.shared.setCanvas(self)
    }
    
    weak var container: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show(_ name: String) {
        show(name, container: nil)
    }
    
    func show(_ name: String, container: UIView?) {
        self.container = container
        Mp4PlayerManager.shared.loadResource("https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4")
        Mp4PlayerManager.shared.start()
    }
}

extension GiftView: Mp4PlayerDelegate {
    func didStartPlayMp4() {
        container?.addSubview(self)
    }
    func didFinishPlayMp4() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
}
