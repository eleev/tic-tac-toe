//
//  StartGameState.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class StartGameState: GKState{
    var scene: GameScene?
    var winningLabel: SKNode!
    var resetNode: SKNode!
    var boardNode: SKNode!
    
    init(scene: GameScene){
        self.scene = scene
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == StartGameState.self
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        resetGame()
        self.stateMachine?.enter(ActiveGameState.self)
    }
    
    func resetGame(){
        let top_left: BoardCell  = BoardCell(value: .none, node: "//*top_left")
        let top_middle: BoardCell = BoardCell(value: .none, node: "//*top_middle")
        let top_right: BoardCell = BoardCell(value: .none, node: "//*top_right")
        let middle_left: BoardCell = BoardCell(value: .none, node: "//*middle_left")
        let center: BoardCell = BoardCell(value: .none, node: "//*center")
        let middle_right: BoardCell = BoardCell(value: .none, node: "//*middle_right")
        let bottom_left: BoardCell = BoardCell(value: .none, node: "//*bottom_left")
        let bottom_middle: BoardCell = BoardCell(value: .none, node: "//*bottom_middle")
        let bottom_right: BoardCell = BoardCell(value: .none, node: "//*bottom_right")
        
        boardNode = self.scene?.childNode(withName: "//Grid") as? SKSpriteNode
        
        winningLabel = self.scene?.childNode(withName: "winningLabel")
        winningLabel.isHidden = true
        
        resetNode = self.scene?.childNode(withName: "Reset")
        resetNode.isHidden = true
        
        
        let board = [top_left, top_middle, top_right, middle_left, center, middle_right, bottom_left, bottom_middle, bottom_right]
        
        self.scene?.gameBoard = Board(gameboard: board)
        
        self.scene?.enumerateChildNodes(withName: "//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.removeAllChildren()
            }
        }
    }
}

