//
//  EndGameState.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import GameplayKit

class EndGameState: GKState{
    var scene: GameScene?
    
    init(scene: GameScene){
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == StartGameState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        updateGameState()
    }
    
    func updateGameState(){
        let resetNode = self.scene?.childNode(withName: "Reset")
        resetNode?.isHidden = false
    }
}

