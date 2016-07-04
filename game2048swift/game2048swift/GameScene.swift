//
//  GameScene.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/2.
//  Copyright (c) 2016年 张 帆. All rights reserved.
//

import SpriteKit

enum SlideDirection {
    case Left
    case Right
    case Up
    case Down
    case Invalid
}

enum GameError: ErrorType {
    case InvalidDirection
}

class GameScene: SKScene {
    private var screenNode : SKSpriteNode!
    private var touchBeginPoint : CGPoint = CGPointMake(0, 0)
    lazy private var matrix = Matrix()
    
    override func didMoveToView(view: SKView) {
        //        print(UIFont.familyNames())
        
        screenNode = SKSpriteNode(color: UIColor.whiteColor(), size: self.size)
        screenNode.anchorPoint = CGPoint(x: 0, y: 0)
        
        addTitle()
        
        matrix.addTo(screenNode)
        matrix.startGame()
//        let a = Grid(row: 1, column: 1 , showNum: 2).addTo(matrix)
//        a.disappear()
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
            print(matrix.move(direction))
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
