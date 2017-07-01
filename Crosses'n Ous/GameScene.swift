//
//  GameScene.swift
//  Crosses'n Ous
//
//  Created by Astemir Eleev on 01/07/2017.
//  Copyright © 2017 Astemir Eleev. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var gameBoard: Board!
    var stateMachine: GKStateMachine!
    var ai: GKMinmaxStrategist!
    
    
    override func didMove(to view: SKView) {
        sceneSetup()
        boardSetup()
        gameplaySetup()
        stateMachinesSetup()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {   
        for touch in touches {
            let location = touch.location(in: self)
            let selectedNode = self.atPoint(location)
            var node: SKSpriteNode
            
            if let name = selectedNode.name {
                if name == "Reset" || name == "reset_label"{
                    self.stateMachine.enter(StartGameState.self)
                    return
                }
            }
            
            if gameBoard.isPlayerOne(){
                let cross = SKSpriteNode(imageNamed: "X_symbol")
                cross.size = CGSize(width: 75, height: 75)
                cross.zRotation = CGFloat.pi / 4.0
                node = cross
            }
            else{
                let circle = SKSpriteNode(imageNamed: "O_symbol")
                circle.size = CGSize(width: 75, height: 75)
                node = circle
            }
            
            for i in 0...8{
                guard let cellNode: SKSpriteNode = self.childNode(withName: gameBoard.getElementAtBoardLocation(i).node) as? SKSpriteNode else{
                    return
                }
                if selectedNode.name == cellNode.name{
                    cellNode.addChild(node)
                    gameBoard.addPlayerValueAtBoardLocation(i, value: gameBoard.isPlayerOne() ? .x : .o)
                    gameBoard.togglePlayer()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        stateMachine.update(deltaTime: currentTime)
    }
}

extension GameScene {
    /* 
     Sets up the scene. Do all additional initialization logic here related to the scene.
     */
    func sceneSetup() {
        self.enumerateChildNodes(withName: "//grid*") { (node, stop) in
            if let node = node as? SKSpriteNode{
                node.color = UIColor.clear
            }
        }
    }
    
    /*
     Sets up the game board. Do all additional initialization logic here related to the game board.
     */
    func boardSetup() {
        let top_left: BoardCell  = BoardCell(value: .none, node: "//*top_left")
        let top_middle: BoardCell = BoardCell(value: .none, node: "//*top_middle")
        let top_right: BoardCell = BoardCell(value: .none, node: "//*top_right")
        let middle_left: BoardCell = BoardCell(value: .none, node: "//*middle_left")
        let center: BoardCell = BoardCell(value: .none, node: "//*center")
        let middle_right: BoardCell = BoardCell(value: .none, node: "//*middle_right")
        let bottom_left: BoardCell = BoardCell(value: .none, node: "//*bottom_left")
        let bottom_middle: BoardCell = BoardCell(value: .none, node: "//*bottom_middle")
        let bottom_right: BoardCell = BoardCell(value: .none, node: "//*bottom_right")
        
        let board = [top_left, top_middle, top_right, middle_left, center, middle_right, bottom_left, bottom_middle, bottom_right]
        
        gameBoard = Board(gameboard: board)

    }
    
    /*
     Sets up gameplay for the game. For this particular case it is minmax strategy. Do all additional initialization logic here related to the gameplay phase.
     */
    func gameplaySetup() {
        ai = GKMinmaxStrategist()
        ai.maxLookAheadDepth = 9
        ai.randomSource = GKARC4RandomSource()
    }
    
    /*
     Sets up state machines for the game. For this particular case there are three states such as:
     - Start game state
     - Active game state
     - End game state
     Do any additional initialization logic here related to the state machines.
     */
    func stateMachinesSetup() {
        let beginGameState = StartGameState(scene: self)
        let activeGameState = ActiveGameState(scene: self)
        let endGameState = EndGameState(scene: self)
        
        stateMachine = GKStateMachine(states: [beginGameState, activeGameState, endGameState])
        stateMachine.enter(StartGameState.self)
    }
    
}
