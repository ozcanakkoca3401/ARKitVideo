//
//  ViewController.swift
//  HarryPotterAR
//
//  Created by Ozcan Akkoca on 28.05.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var videoNode: SKVideoNode!
    var videoPlayer: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneViewARImageTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentTouchLocation = touches.first?.location(in: self.sceneView) {
            selectedSceneView(location: currentTouchLocation)
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        let referenceImageSize = imageAnchor.referenceImage.physicalSize

        let planeVideo = SCNPlane(width: referenceImageSize.width, height: referenceImageSize.height)
        planeVideo.firstMaterial?.diffuse.contents = videoScene()
        let planeVideoNode = SCNNode(geometry: planeVideo)
        planeVideoNode.eulerAngles.x = -Float.pi / 2
        planeVideoNode.scale = SCNVector3(x: Float(imageAnchor.referenceImage.physicalSize.width), y: Float(imageAnchor.referenceImage.physicalSize.width * (9 / 16)), z: 1.0)
        node.addChildNode(planeVideoNode)
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let imageAnchor = (anchor as? ARImageAnchor) else { return }
        if imageAnchor.isTracked {
            videoNode.play()
        } else {
            videoNode.pause()
        }
    }
    
    func videoScene() -> SKScene {
        guard let videoURL = Bundle.main.url(forResource: "Ascendio", withExtension: ".mp4") else { return SKScene() }
        videoPlayer = AVPlayer(url: videoURL)
        videoNode = SKVideoNode(avPlayer: videoPlayer)
        
        let videoScene = SKScene(size: CGSize(width: 720, height: 1280))
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.yScale = -1.0
        videoNode.size = videoScene.size
        videoScene.backgroundColor = .clear
        videoScene.addChild(videoNode)
        
        return videoScene
    }
    
    
    func sceneViewARImageTrackingConfiguration() {
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ARImages", bundle: Bundle.main) {
            
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        sceneView.session.run(configuration)
    }
    
    func selectedSceneView(location: CGPoint) {
        let hitTestResults = self.sceneView.hitTest(location, options: nil)

        if hitTestResults.count > 0 {
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
}


