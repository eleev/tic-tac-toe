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
    
    // MARK: - Properties
    
    var gameBoard: Board!
    var stateMachine: GKStateMachine!
    var ai: GKMinmaxStrategist!

    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        sceneSetup()
        gameplaySetup()
        maxLookAheadDepth()
        stateMachinesSetup()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {   
        for touch in touches {
            let location = touch.location(in: self)
            let selectedNode = self.atPoint(location)
            var node: SKSpriteNode
            
            if let name = selectedNode.name {
                if name == Constants.reset || name == Constants.resetLabel {
                    self.stateMachine.enter(StartGameState.self)
                    return
                }
            }
            
            if gameBoard.isPlayerOne() {
                let cross = SKSpriteNode(imageNamed: Constants.exCell)
                cross.size = CGSize(width: Constants.cellSize, height: Constants.cellSize)
//                cross.zRotation = CGFloat.pi / 4.0
                node = cross
            } else {
                let circle = SKSpriteNode(imageNamed: Constants.ouCell)
                circle.size = CGSize(width: Constants.cellSize, height: Constants.cellSize)
                node = circle
            }
            
            node.alpha = 0.0
            let reveal = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            node.run(reveal)
            
            for i in 0...8 {
                guard let cellNode: SKSpriteNode = self.childNode(withName: gameBoard.getElementAtBoardLocation(i).node) as? SKSpriteNode else { return }
                if selectedNode.name == cellNode.name {
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
    
    // MARK: - Setup
    
    /* 
     Sets up the scene. Do all additional initialization logic here related to the scene.
     */
    func sceneSetup() {
        self.enumerateChildNodes(withName: Constants.gridSearchRequest) { (node, stop) in
            if let node = node as? SKSpriteNode {
                node.color = UIColor.clear
            }
        }
    }
    
    /*
     Sets up gameplay for the game. For this particular case it is minmax strategy. Do all additional initialization logic here related to the gameplay phase.
     */
    func gameplaySetup() {
        ai = GKMinmaxStrategist()
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
    
    // MARK: - Utilities
    
    
    /*
     Generates a difficulty level for the AI based on the max number of levels that to look ahead to the decision making tree.
     */
    func maxLookAheadDepth() {
        func difficultyLevel() -> Int {
            return Int(1 + arc4random_uniform(9)) // 9 is the max level for decision making tree since there are only 9 cells in the play grid
        }
        
        func toDifficultyLevel(_ level: Int) -> DifficultyLevel {
            switch level {
            case 1: return .one
            case 2: return .two
            case 3: return .three
            case 4: return .four
            case 5: return .five
            case 6: return .six
            case 7: return .seven
            case 8: return .eight
            case 9: return .nine
            default: return .ufo
            }
        }
        
        
        let diffLevel = difficultyLevel()
        ai.maxLookAheadDepth = diffLevel
        
        guard let difficultyLabelNode = self.childNode(withName: "Difficulty_level") as? SKLabelNode else {
            fatalError("Could not find Dicculty label of type SKLabelNode")
        }
        difficultyLabelNode.text = "\(Constants.difficuly) \(toDifficultyLevel(diffLevel).rawValue)"
    }
    
    /*
     Randomly returns current player type - human or machine
     */
    func flipCoin() -> CurrentPlayer {
        return drand48() >= 0.5 ? .human : .machine
    }
    
}

/*
 Describes all possible diffibulty levels for the minimax strategy
 */
enum DifficultyLevel: String {
    case one = "Newborn"
    case two = "Toddler"
    case three = "Dummy"
    case four = "Pupil"
    case five = "Student"
    case six = "B.S."
    case seven = "M.S."
    case eight = "PhD"
    case nine = "Nikola Tesla"
    case ufo = "UFO"
}
