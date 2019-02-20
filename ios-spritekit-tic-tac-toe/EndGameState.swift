//
//  EndGameState.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import GameplayKit

class EndGameState: GKState {
    
    // MARK: - Properties
    
    weak var scene: GameScene?
    
    // MARK: - Initializers
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    // MARK: - Methods
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == StartGameState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        updateGameState()
    }
    
    func updateGameState() {
        let resetNode = self.scene?.childNode(withName: Constants.reset)
        resetNode?.isHidden = false
        resetNode?.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
    }
}
