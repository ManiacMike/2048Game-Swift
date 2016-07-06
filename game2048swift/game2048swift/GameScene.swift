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
        print(direction)
        if direction != .Invalid{
            touchEnable = false
            matrix.move(direction)
            let gameOn = matrix.stepGame()
            if gameOn == false{
                askToPlayAgain()
            }
            let step =  SKAction.sequence(
                [
                    SKAction.waitForDuration(gridInterval * 3 + 0.5),
                    SKAction.runBlock {
                        self.touchEnable = true
                    }
                ]
            )
            screenNode.runAction(step)
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
        let alertView = SIAlertView(title: "Ouch!!", andMessage: "Congratulations! Your score is . Play again?")
        
        alertView.addButtonWithTitle("OK", type: .Default) { _ in self.onPlayAgainPressed() }
        alertView.addButtonWithTitle("Cancel", type: .Default) { _ in self.onCancelPressed() }
        alertView.show()
    }
}
