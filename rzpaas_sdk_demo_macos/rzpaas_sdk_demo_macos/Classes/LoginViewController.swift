//
//  LoginViewController.swift
//  rzpaas_sdk_demo_macos
//
//  Created by yxibng on 2021/1/6.
//

import Cocoa
import RZPaas_macOS
import AVFoundation

class LoginViewController: NSViewController {

    @IBOutlet weak var channelIdInput: NSTextField!
    @IBOutlet weak var uidInput: NSTextField!
    
    @IBOutlet weak var channelIdTipLabel: NSTextField!
    @IBOutlet weak var uidTipLabel: NSTextField!
    @IBOutlet weak var channelIdLine: RZMView!
    @IBOutlet weak var uidLine: RZMView!
    
    var inJoinState = false
    
    deinit {
        print(#function)
    }
    
    let keyForUid = "com.paas.demo.key.uid"
    let keyForChannelId = "com.paas.demo.key.channelId"
    
    func loadOldInput() {
    
        let uid = UserDefaults.standard.string(forKey: keyForUid) ?? ""
        let channelId = UserDefaults.standard.string(forKey: keyForChannelId) ?? ""
        self.uidInput.stringValue = uid
        self.channelIdInput.stringValue = channelId
    }
    
    func saveNewInput()  {

        let uid = self.uidInput.stringValue
        let channelId = self.channelIdInput.stringValue
        
        UserDefaults.standard.setValue(uid, forKey: keyForUid)
        UserDefaults.standard.setValue(channelId, forKey: keyForChannelId)
        UserDefaults.standard.synchronize()

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.init(hex: "1e6ceb")?.cgColor
        
        self.loadOldInput()

        if #available(macOS 10.14, *) {
            //要求启动获取权限
            AVCaptureDevice.requestAccess(for: .audio) { (ret) in
                if ret {
                    print("获取了麦克风录制权限")
                } else {
                    print("获取麦克风录制权限失败")
                }
            }
            
            AVCaptureDevice.requestAccess(for: .video) { (ret) in
                if ret {
                    print("获取了摄像头使用权限")
                } else {
                    print("获取摄像头使用权限失败")
                }
            }
        }
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Login"
        if let closeButton = self.view.window?.standardWindowButton(.closeButton) {
            closeButton.target = self
            closeButton.action = #selector(onClickClose(sender:))
        }
    }
    

    
    @objc func onClickClose(sender: Any)  {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func onClickJoin(_ sender: Any) {
        
        
        if self.inJoinState {
            return
        }

        self.validateInput()
    
        let uid = self.uidInput.stringValue
        let channelId = self.channelIdInput.stringValue
        
        if uid.isEmpty || channelId.isEmpty {
            return
        }
        
        self.saveNewInput()

        EngineManager.sharedEngineManager.delegate = self
        
        var ret = EngineManager.sharedEngineManager.createChannel(channelId: channelId)
        if !ret {
            return
        }

        
        ret = EngineManager.sharedEngineManager.joinChannel(by: uid)
        if !ret {
            return
        }
        self.inJoinState = true
    }
}



extension LoginViewController {
    
    func validateInput() {
        let normalColor = NSColor.white
        let emptyColor = NSColor.init(hex: "ffa62f")!
        
        if self.uidInput.stringValue.isEmpty {
            self.uidTipLabel.isHidden = false
            self.uidLine.backgroundColor = emptyColor
        } else {
            self.uidTipLabel.isHidden = true
            self.uidLine.backgroundColor = normalColor
        }
        
        if self.channelIdInput.stringValue.isEmpty {
            self.channelIdTipLabel.isHidden = false
            self.channelIdLine.backgroundColor = emptyColor
        } else {
            self.channelIdTipLabel.isHidden = true
            self.channelIdLine.backgroundColor = normalColor
        }
    }
}


extension LoginViewController: EngineManagerDelegate {
    
    func shouldHandleInvalidChannelId() {
        
        let alert = NSAlert.init()
        alert.alertStyle = .warning
        alert.informativeText = "当前频道ID不合法"
        alert.messageText = "进入频道失败"
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func shouldHandleInvalidUid() {
        let alert = NSAlert.init()
        alert.alertStyle = .warning
        alert.informativeText = "当前用户ID不合法"
        alert.messageText = "进入频道失败"
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func shouldHandleJoinSuccess() {
        
        //reset state
        self.inJoinState = false
        //save channel id
        EngineManager.sharedEngineManager.channelId = channelIdInput.stringValue
        
        //switch page
        let vc = VideoChatViewController.init()
        if let closeButton = self.view.window?.standardWindowButton(.closeButton) {
            closeButton.target = vc
            closeButton.action = #selector(VideoChatViewController.onClickLeaveChannel(sender:))
        }
        self.view.window?.contentViewController = vc
    }
    
    func shouldHandleJoinError(code: Int, message: String?) {
        self.inJoinState = false
        EngineManager.sharedEngineManager.leaveChannel()
        
        let alert = NSAlert.init()
        alert.alertStyle = .warning
        alert.informativeText = "\(message ?? "") \n错误码\(code)"
        alert.messageText = "进入频道失败"
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func shouldHandleOnLeaveChannleSuccess() {
        EngineManager.sharedEngineManager.destroyChannel()
    }
}
