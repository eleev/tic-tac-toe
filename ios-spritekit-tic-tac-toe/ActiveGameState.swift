//
//  ActiveGameState.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import GameplayKit
import SpriteKit

class ActiveGameState: GKState {
    
    // MARK: - Propertoes
    
    var scene: GameScene?
    var waitingOnPlayer: Bool
    
    // MARK: - Initializers
    
    init(scene: GameScene) {
        self.scene = scene
        waitingOnPlayer = false
        super.init()
    }
    
    // MARK: - Methods
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == EndGameState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        waitingOnPlayer = false
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        assert(scene != nil, "Scene must not be nil")
        assert(scene?.gameBoard != nil, "Gameboard must not be nil")
        
        if !waitingOnPlayer{
            waitingOnPlayer = true
            updateGameState()
        }
    }
    
    func updateGameState() {
        assert(scene != nil, "Scene must not be nil")
        assert(scene?.gameBoard != nil, "Gameboard must not be nil")
        
        let (state, winner) = self.scene!.gameBoard!.determineIfWinner()
        if state == .winner{
            let winningLabel = self.scene?.childNode(withName: "winningLabel")
            winningLabel?.isHidden = true
            let winningPlayer = self.scene!.gameBoard!.isPlayerOne(winner!) ? "1" : "2"
            
            if let winningLabel = winningLabel as? SKLabelNode,
                let player1_score = self.scene?.childNode(withName: "//player1_score") as? SKLabelNode,
                let player2_score = self.scene?.childNode(withName: "//player2_score") as? SKLabelNode {
                
                winningLabel.text = "Player \(winningPlayer) wins!"
                winningLabel.isHidden = false
                
                if winningPlayer == "1" {
                    player1_score.text = "\(Int(player1_score.text!)! + 1)"
                } else {
                    player2_score.text = "\(Int(player2_score.text!)! + 1)"
                }
                
                self.stateMachine?.enter(EndGameState.self)
                waitingOnPlayer = false
            }
        } else if state == .draw {
            let winningLabel = self.scene?.childNode(withName: "winningLabel")
            winningLabel?.isHidden = true
            
            if let winningLabel = winningLabel as? SKLabelNode {
                winningLabel.text = "It's a draw"
                winningLabel.isHidden = false
            }
            self.stateMachine?.enter(EndGameState.self)
            waitingOnPlayer = false
        } else if self.scene!.gameBoard!.isPlayerTwoTurn() {
            // Change the font type for AI agent
            let completion = highlightActivePlayer(.machine, with: .blue)
            
            //AI moves
            self.scene?.isUserInteractionEnabled = false
            
            assert(scene != nil, "Scene must not be nil")
            assert(scene?.gameBoard != nil, "Gameboard must not be nil")
            
            DispatchQueue.global(qos: .default).async {
                self.scene!.ai.gameModel = self.scene!.gameBoard!
                let move = self.scene!.ai.bestMoveForActivePlayer() as? Move
                
                assert(move != nil, "AI should be able to find a move")
                
                let strategistTime = CFAbsoluteTimeGetCurrent()
                let delta = CFAbsoluteTimeGetCurrent() - strategistTime
                let  aiTimeCeiling: TimeInterval = 1.0
                
                let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
                    
                    guard let cellNode: SKSpriteNode = self.scene?.childNode(withName: self.scene!.gameBoard!.getElementAtBoardLocation(move!.cell).node) as? SKSpriteNode else{
                        return
                    }
                    
                    let circle = SKSpriteNode(imageNamed: Constants.ouCell)
                    circle.size = CGSize(width: Constants.cellSize, height: Constants.cellSize)
                    cellNode.alpha = 0.0
                    cellNode.addChild(circle)
                    
                    let reveal = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                    cellNode.run(reveal)
                    
                    self.scene!.gameBoard!.addPlayerValueAtBoardLocation(move!.cell, value: .o)
                    self.scene!.gameBoard!.togglePlayer()
                    self.waitingOnPlayer = false
                    self.scene?.isUserInteractionEnabled = true
                    
                    // Completes the visual feedback to the human-player
                    completion()
                }
            }
        } else {
            self.waitingOnPlayer = false
            self.scene?.isUserInteractionEnabled = true
        }
    }
}

/*
 Extension that adds helper methods for visual feedback for human-player
 */
extension ActiveGameState {
    
    /*
     Highlights player's label indicating which turn is which
     */
    fileprivate func highlightActivePlayer(_ player: CurrentPlayer, with color: UIColor = .blue) -> () -> ()? {
        let labelNodeName = player == .human ? "player1_label_node" : "player2_label_node"
        
        var font: UIColor?
        var label: SKLabelNode?
        
        if let playerNode = self.scene?.childNode(withName: labelNodeName) as? SKLabelNode {
            label = playerNode
            font = playerNode.fontColor
            playerNode.fontColor = color
        }
        
        let completion = {
            label?.fontColor = font
        }
        
        return completion
    }
}

struct Constants {
    static let cellSize = 115
    static let ouCell = "O"
    static let exCell = "X"
    static let reset = "Reset"
    static let resetLabel = "reset_label"
    static let gridSearchRequest = "//grid*"
    static let difficuly = "Difficulty:"
}
