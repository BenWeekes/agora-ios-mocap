//
//  BlendShapeViewController.swift
//  AgoraBlendShapeDemo
//
//  Created by Deenan on 14/12/22.
//

import UIKit
import ARKit
import SceneKit
import AgoraRtcKit
import AgoraRtmKit


class BlendShapeViewController: UIViewController {
    
    var channelName: String = ""
    var agoraKit: AgoraRtcEngineKit!
    var rtmKit: AgoraRtmKit?
    var rtmChannel: AgoraRtmChannel?

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneView.delegate = self
        joinChannel()
        self.rtmLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      // 1
      let configuration = ARFaceTrackingConfiguration()
      // 2
      sceneView.session.run(configuration)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 1
        sceneView.session.pause()
        agoraKit.leaveChannel(nil)
        self.rtmChannel?.leave()
        self.rtmKit?.logout()
    }
    
    func joinChannel() {
        // set up agora instance when view loaded
        let config = AgoraRtcEngineConfig()
        config.appId = "20b7c51ff4c644ab80cf5a4e646b0537"
        config.areaCode = .global
        config.channelProfile = .liveBroadcasting
        // set audio scenario
        config.audioScenario = .default
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // make myself a broadcaster
        agoraKit.setClientRole(.broadcaster)
        
        // disable video module
        agoraKit.disableVideo()
        agoraKit.enableAudio()
        
        // set audio profile
        agoraKit.setAudioProfile(.default)
        
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        let result = agoraKit.joinChannel(byToken: "", channelId: channelName, userAccount: "DDD", mediaOptions: AgoraRtcChannelMediaOptions())
        if result != 0 {
            // Usually happens with invalid parameters
            // Error code description can be found at:
            // en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            // cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
        }
    }
    
    func rtmLogin() {
        self.rtmKit = AgoraRtmKit(appId: "20b7c51ff4c644ab80cf5a4e646b0537", delegate: self)
        self.rtmKit?.login(byToken: nil, user: "user", completion: { loginCode in
            if loginCode == .ok {
                self.rtmChannel = self.rtmKit?.createChannel(withId: self.channelName, delegate: self)
                self.rtmChannel?.join(completion: self.channelJoined(joinCode:))
            }
        })
    }
    
    func channelJoined(joinCode: AgoraRtmJoinChannelErrorCode) {
        if joinCode == .channelErrorOk {
            print("connected to channel")
        }
    }
    
    func showAlert(title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BlendShapeViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        // 3
        guard let device = sceneView.device else {
          return nil
        }
        
        // 4
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        // 5
        let node = SCNNode(geometry: faceGeometry)
        
        // 6
        node.geometry?.firstMaterial?.fillMode = .lines
        
        // 7
        return node
      }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // 2
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        // 3
        faceGeometry.update(from: faceAnchor.geometry)
        let blendShapes = faceAnchor.blendShapes
        
        let blendshapesLocation = "\(String(describing: blendShapes[.browDownLeft]!)),\(String(describing: blendShapes[.browDownRight]!)),\(String(describing: blendShapes[.browInnerUp]!)),\(String(describing: blendShapes[.browOuterUpLeft]!)),\(String(describing: blendShapes[.browOuterUpRight]!)),\(String(describing: blendShapes[.cheekPuff]!)),\(String(describing: blendShapes[.cheekSquintLeft]!)),\(String(describing: blendShapes[.cheekSquintRight]!)),\(String(describing: blendShapes[.eyeBlinkLeft]!)),\(String(describing: blendShapes[.eyeBlinkRight]!)),\(String(describing: blendShapes[.eyeLookDownLeft]!)),\(String(describing: blendShapes[.eyeLookDownRight]!)),\(String(describing: blendShapes[.eyeLookInLeft]!)),\(String(describing: blendShapes[.eyeLookInRight]!)),\(String(describing: blendShapes[.eyeLookOutLeft]!)),\(String(describing: blendShapes[.eyeLookOutRight]!)),\(String(describing: blendShapes[.eyeLookUpLeft]!)),\(String(describing: blendShapes[.eyeLookUpRight]!)),\(String(describing: blendShapes[.eyeSquintLeft]!)),\(String(describing: blendShapes[.eyeSquintRight]!)),\(String(describing: blendShapes[.eyeWideLeft]!)),\(String(describing: blendShapes[.eyeWideRight]!)),\(String(describing: blendShapes[.jawForward]!)),\(String(describing: blendShapes[.jawLeft]!)),\(String(describing: blendShapes[.jawOpen]!)),\(String(describing: blendShapes[.jawRight]!)),\(String(describing: blendShapes[.mouthClose]!)),\(String(describing: blendShapes[.mouthDimpleLeft]!)),\(String(describing: blendShapes[.mouthDimpleRight]!)),\(String(describing: blendShapes[.mouthFrownLeft]!)),\(String(describing: blendShapes[.mouthFrownRight]!)),\(String(describing: blendShapes[.mouthFunnel]!)),\(String(describing: blendShapes[.mouthLeft]!)),\(String(describing: blendShapes[.mouthLowerDownLeft]!)),\(String(describing: blendShapes[.mouthLowerDownRight]!)),\(String(describing: blendShapes[.mouthPressLeft]!)),\(String(describing: blendShapes[.mouthPressRight]!)),\(String(describing: blendShapes[.mouthPucker]!)),\(String(describing: blendShapes[.mouthRight]!)),\(String(describing: blendShapes[.mouthRollLower]!)),\(String(describing: blendShapes[.mouthRollUpper]!)),\(String(describing: blendShapes[.mouthShrugLower]!)),\(String(describing: blendShapes[.mouthShrugUpper]!)),\(String(describing: blendShapes[.mouthSmileLeft]!)),\(String(describing: blendShapes[.mouthSmileRight]!)),\(String(describing: blendShapes[.mouthStretchLeft]!)),\(String(describing: blendShapes[.mouthStretchRight]!)),\(String(describing: blendShapes[.mouthUpperUpLeft]!)),\(String(describing: blendShapes[.mouthUpperUpRight]!)),\(String(describing: blendShapes[.noseSneerLeft]!)),\(String(describing: blendShapes[.noseSneerRight]!)),\(String(describing: blendShapes[.tongueOut]!)))"
        
        
        self.rtmChannel?.send(AgoraRtmMessage(text: "\(blendshapesLocation)"), completion: { sentCode in
            if sentCode != .errorOk {
                print("could not send message")
            }
        })
    }
}

extension BlendShapeViewController: AgoraRtcEngineDelegate {
    
    /// callback when warning occured for agora sdk, warning can usually be ignored, still it's nice to check out
    /// what is happening
    /// Warning code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// @param warningCode warning code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning: \(warningCode)")
    }
    
    /// callback when error occured for agora sdk, you are recommended to display the error descriptions on demand
    /// to let user know something wrong is happening
    /// Error code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// @param errorCode error code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("error: \(errorCode)")
        self.showAlert(title: "Error", message: "Error \(errorCode) occur")
    }
    
}

extension BlendShapeViewController: AgoraRtmChannelDelegate, AgoraRtmDelegate {
    
}
