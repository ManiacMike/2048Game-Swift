//
//  GameScene.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/2.
//  Copyright (c) 2016年 张 帆. All rights reserved.
//

import SpriteKit
import SIAlertView

enum SlideDirection {
    case Left
    case Right
    case Up
    case Down
    case Invalid
}

enum GameError: ErrorType {
    case InvalidDirection
    case WrongNumGrid
    case OtherError
}

class GameScene: SKScene {
    private var screenNode : SKSpriteNode!
    private var touchBeginPoint : CGPoint = CGPointMake(0, 0)
    private var touchEnable : Bool = true
    lazy private var matrix = Matrix()
    
    var onPlayAgainPressed:(()->Void)!
    var onCancelPressed:(()->Void)!
    
    override func didMoveToView(view: SKView) {
        //        print(UIFont.familyNames())
        
        screenNode = SKSpriteNode(color: UIColor.whiteColor(), size: self.size)
        screenNode.anchorPoint = CGPoint(x: 0, y: 0)
        
        addTitle()
        
        matrix.addTo(screenNode)
        matrix.startGame()
//        matrix.initWithMatrix([[0, 2, 0, 0], [2, 4, 0, 0], [8, 2, 16, 0], [8, 32, 128, 32]])
        self.addChild(screenNode)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            touchBeginPoint = location
            break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchEndPoint : CGPoint = CGPoint(x: 0, y: 0)
        for touch in touches {
            let location = touch.locationInNode(self)
            touchEndPoint = location
        }
        let x : CGFloat = touchEndPoint.x - touchBeginPoint.x
        let y : CGFloat = touchEndPoint.y - touchBeginPoint.y
        let abx = x<0 ? -x : x
        let aby = y<0 ? -y : y
        var direction : SlideDirection = .Invalid
        if abx > aby && abx > 100{//right or left
            direction = x>0 ? .Right : .Left
        }else if abx<aby && aby>100{//up or down
            direction = y>0 ? .Up : .Down
        }
        if direction != .Invalid{
            let moveResult = matrix.move(direction)
            let gameOver = matrix.gameOver
            if gameOver == true{
                self.askToPlayAgain()
            }
            if moveResult.ifMoved == true {
                touchEnable = false
                let step =  SKAction.sequence(
                    [
                        SKAction.waitForDuration(moveResult.lastTime + 0.1), //等待move结束
                        SKAction.runBlock {
                            print("时间：",moveResult.lastTime)
                            do {
                                try self.matrix.checkIfRight()
                            } catch GameError.WrongNumGrid {
//                                print("====Invalid NumGrid Start====")
//                                var gridMatrix = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
//                                 var gridIdMatrix = [[Int]](count :4, repeatedValue: [Int](count :4, repeatedValue: 0))
//                                for (grid, position) in self.matrix.grids {
//                                    gridMatrix[position[0]][position[1]] = grid.number
//                                    gridIdMatrix[position[0]][position[1]] = grid.id
//                                }
//                                print(gridMatrix)
//                                print(gridIdMatrix)
//                                print("====Invalid NumGrid End====")
                                self.askToPlayAgain()
                            } catch {
                                
                            }

                            
                            self.touchEnable = true
                            self.matrix.stepGame()
                        }
                    ]
                )
                screenNode.runAction(step)
            }
        }
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

private extension GameScene{
    func addTitle(){
        let title = SKLabelNode(fontNamed: "Thonburi")
        title.text = "2048 By Mike"
        title.fontSize = 20
        title.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetHeight(self.frame) * 0.8 + 30)
        title.zPosition = 2
        title.fontColor = UIColor.blackColor()
        screenNode.addChild(title)
    }
}


// Private
private extension GameScene {
    func askToPlayAgain() {
        let alertView = SIAlertView(title: "Ouch!!", andMessage: "Congratulations! Your score is \(score). Play again?")
        
        alertView.addButtonWithTitle("OK", type: .Default) { _ in self.onPlayAgainPressed() }
        alertView.addButtonWithTitle("Cancel", type: .Default) { _ in self.onCancelPressed() }
        alertView.show()
    }
}
