//
//  Mp4PlayerManager.swift
//  ZegoUIKitPrebuiltLiveStreamingWithCoHost
//
//  Created by Kael Ding on 2024/1/10.
//

import Foundation
import ZegoExpressEngine

protocol Mp4PlayerDelegate: AnyObject {
    func didFinishPlayMp4()
    func didStartPlayMp4()
}

class Mp4PlayerManager: NSObject {
    static let shared = Mp4PlayerManager()
    
    var player: ZegoMediaPlayer?
    
    weak var delegate: Mp4PlayerDelegate?
    
    private var resourceMap = [String: String]()
    
    func createMediaPlayer() {
        if (player == nil) {
            player = ZegoExpressEngine.shared().createMediaPlayer()
            player?.setEventHandler(self)
            player?.enableLocalCache(true, cacheDir: "")
        }
    }
    
    func destroyMediaPlayer() {
        if (player != nil) {
            ZegoExpressEngine.shared().destroy(player!)
            player = nil
        }
    }
    
    func start() {
        player?.start()
    }
    
    func loadResource(_ url: String) {
        let resource = ZegoMediaPlayerResource()
        resource.loadType = .filePath
        resource.filePath = resourceMap[url] ?? url
        resource.alphaLayout = .left
        player?.loadResource(withConfig: resource, callback: { errorCode in
            if errorCode == 0 {
                
            }
        })
    }
    
    func setCanvas(_ view: UIView) {
        view.backgroundColor = .clear
        let canvas = ZegoCanvas(view: view)
        canvas.alphaBlend = true
        player?.setPlayerCanvas(canvas)
    }
}

extension Mp4PlayerManager: ZegoMediaPlayerEventHandler {
    func mediaPlayer(_ mediaPlayer: ZegoMediaPlayer, stateUpdate state: ZegoMediaPlayerState, errorCode: Int32) {
        if state == .playing {
            delegate?.didStartPlayMp4()
        }
        if state == .playEnded {
            delegate?.didFinishPlayMp4()
            player?.clearView()
        }
    }
    
    func mediaPlayer(_ mediaPlayer: ZegoMediaPlayer, firstFrameEvent event: ZegoMediaPlayerFirstFrameEvent) {
        if event == .videoRendered {
            
        }
    }
    
    func mediaPlayer(_ mediaPlayer: ZegoMediaPlayer, localCacheError errorCode: Int32, resource: String, cachedFile: String) {
        print("mediaPlayer, errorCode: \(errorCode), resource: \(resource), cachedFile: \(cachedFile)")
        if errorCode == 0 {
            resourceMap[resource] = cachedFile
        }
    }
}
