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
        debugPrint("GameScene -> didMove")
        
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
    
    // MARK: - Setup
    
    /* 
     Sets up the scene. Do all additional initialization logic here related to the scene.
     */
    func sceneSetup() {
        self.enumerateChildNodes(withName: "//grid*") { (node, stop) in
            debugPrint("child node is : ", node)
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
        difficultyLabelNode.text = "Difficulty: \(toDifficultyLevel(diffLevel).rawValue)"
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
