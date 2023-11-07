//
//  ViewController.swift
//  ZegoUIKitPrebuiltLiveStreamingWithCoHost
//
//  Created by zego on 2022/11/22.
//

import UIKit
import ZegoUIKit
import ZegoUIKitPrebuiltLiveStreaming
import ZegoUIKitSignalingPlugin

class ViewController: UIViewController {
    
    let appID: UInt32 = <#YourAppID#>
    let appSign: String = <#YourAppSign#>
    let serverSecret: String = <#YourServerSecret#>
    
    let userID: String = String(format: "%d", arc4random() % 999999)
    var userName: String?
    
    var liveVC: ZegoUIKitPrebuiltLiveStreamingVC!
    
    @IBOutlet weak var liveIDTextField: UITextField! {
        didSet {
            let liveID: UInt32 = arc4random() % 999
            liveIDTextField.text = String(format: "%d", liveID)
        }
    }
    
    @IBOutlet weak var useVideoAspectFillLabel: UILabel! {
        didSet {
            if useVideoAspectFill {
                useVideoAspectFillLabel.text = "true"
            } else {
                useVideoAspectFillLabel.text = "false"
            }
        }
    }
    
    var useVideoAspectFill: Bool = true {
        didSet {
            if useVideoAspectFill {
                useVideoAspectFillLabel.text = "true"
            } else {
                useVideoAspectFillLabel.text = "false"
            }
        }
    }
    
    lazy var giftView: GiftView = {
        let giftView = GiftView(frame: view.bounds)
        return giftView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userName = String(format: "n_%@", self.userID)
    }

    @IBAction func startLiveButtonClick(_ sender: Any) {
        let config: ZegoUIKitPrebuiltLiveStreamingConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(enableCoHosting: true)
        let audioVideoConfig = ZegoPrebuiltAudioVideoViewConfig()
        audioVideoConfig.useVideoViewAspectFill = useVideoAspectFill
        config.audioVideoViewConfig = audioVideoConfig
        liveVC = ZegoUIKitPrebuiltLiveStreamingVC(self.appID, appSign: self.appSign, userID: self.userID, userName: self.userName ?? "", liveID: self.liveIDTextField.text ?? "", config: config)
        
        liveVC.modalPresentationStyle = .fullScreen
        self.present(liveVC, animated: true, completion: nil)
        ZegoUIKit.shared.addEventHandler(self)
    }
    
    @IBAction func watchLiveButtonClick(_ sender: Any) {
        let config: ZegoUIKitPrebuiltLiveStreamingConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience(enableCoHosting: true)
        let audioVideoConfig = ZegoPrebuiltAudioVideoViewConfig()
        audioVideoConfig.useVideoViewAspectFill = useVideoAspectFill
        config.audioVideoViewConfig = audioVideoConfig
        liveVC = ZegoUIKitPrebuiltLiveStreamingVC(self.appID, appSign: self.appSign, userID: self.userID, userName: self.userName ?? "", liveID: self.liveIDTextField.text ?? "", config: config)
        
        let giftButton = UIButton(type: .system)
        giftButton.backgroundColor = .red
        giftButton.setTitle("Gift", for: .normal)
        giftButton.setTitleColor(.white, for: .normal)
        giftButton.addTarget(self, action: #selector(sendGift), for: .touchUpInside)
        liveVC.addButtonToBottomMenuBar(giftButton, role: .audience)
        liveVC.addButtonToBottomMenuBar(giftButton, role: .coHost)
        
        liveVC.modalPresentationStyle = .fullScreen
        self.present(liveVC, animated: true, completion: nil)
        ZegoUIKit.shared.addEventHandler(self)
    }
    
    @IBAction func useVideoAspectFillClick(_ sender: Any) {
        useVideoAspectFill = !useVideoAspectFill
    }
    
    @objc func sendGift() {
        let parameters: [String: Any] = [
            "app_id": appID,
            "server_secret": serverSecret,
            "room_id": liveIDTextField.text!,
            "user_id": userID,
            "user_name": userName!,
            "gift_type": 1001,
            "gift_count": 1,
            "timestamp": "123"
        ]
        
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://zego-virtual-gift.vercel.app/api/send_gift")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            
        }

        print("Start sending gift...")
        let task = session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                print("Send Gift success.")
                //show gift animation
                DispatchQueue.main.async {
                    self.giftView.show("vap.mp4", container: self.liveVC.view)
                }
            } else {
                print("Send Gift fail.")
            }
        }
        task.resume()
    }
}

extension ViewController: ZegoUIKitEventHandle {
    func onInRoomCommandMessageReceived(_ messages: [ZegoSignalingInRoomCommandMessage], roomID: String) {
        if let message = messages.first {
            if message.senderUserID != userID {
                //show gift animation
                DispatchQueue.main.async {
                    self.giftView.show("vap.mp4", container: self.liveVC.view)
                }
            }
        }
    }
}

