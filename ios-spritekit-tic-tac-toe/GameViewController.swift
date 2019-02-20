//
//  GameViewController.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isLandscape = UIDevice.current.userInterfaceIdiom == .phone
        debugPrint(#function + " is landscape orietnation : ", isLandscape)
        loadSceneForOrientation(isLandscape: !isLandscape)
        
         // Current implementation is commented because it cannot be fully supported yet. The reason is the app does not support game state persistence - it means that after the UI is rotated, the states of UI elements are reset. In order to bring full support for autorotation feature, game state persistence needs to be implemented first.
        /*
        // Registed notification observer to react on device rotation changes
        let defaultNotifCenter = NotificationCenter.default
        defaultNotifCenter.addObserver(self, selector: #selector(GameViewController.rotated),
                                       name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
         */
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .landscape
        }
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Rotation
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            print(#function + " landscape")
            loadSceneForOrientation(isLandscape: true)
        }

        if UIDevice.current.orientation.isPortrait {
            print(#function + " portrait")
            loadSceneForOrientation(isLandscape: false)
        }
    }
    
    // MARK: - Scene management
    
    private func loadSceneForOrientation(isLandscape: Bool) {
        var scene = GameScene(fileNamed: "GameScene-Portrait")
        scene?.scaleMode = .aspectFill
        
        if isLandscape {
            scene = GameScene(fileNamed: "GameScene-Landscape")
            scene?.scaleMode = .aspectFit
        }
        
        guard let unwrappedScene = scene else {
            fatalError(#function + " could not load game scene, the app will crash")
        }
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        skView.presentScene(unwrappedScene)
    }

}
