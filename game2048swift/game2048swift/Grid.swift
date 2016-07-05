//
//  Grid.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/2.
//  Copyright © 2016年 张 帆. All rights reserved.
//

import Foundation

import SpriteKit

func ==(lhs: Grid, rhs: Grid) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Grid {
    var row : Int
    var column : Int
    var number : UInt
    var node : SKSpriteNode!
    private var parentNode: SKSpriteNode!
    let gridWidth :CGFloat = 107
    
    init(row : Int, column: Int, showNum: UInt){
        self.row = row
        self.column = column
        self.number = showNum
        self.node = createNode()
    }
    
    func addTo(parentNode: Matrix) -> Grid {
        self.parentNode = parentNode.node
        parentNode.node.addChild(node)
        node.zPosition = 2
        node.position = getPosition(self.row, column: self.column)
        
        let title = getTextNode(self.number)
        node.addChild(title)
        return self
    }
    
    func moveByDirection(direction : SlideDirection, distance : Int) -> SKAction{
        
        switch direction {
        case .Up:
            let y = Matrix.ymapReverse(column) - distance
            column = Matrix.ymap(y)
        case .Down:
            let y = Matrix.ymapReverse(column) + distance
            column = Matrix.ymap(y)
        case .Left:
            let x = Matrix.xmapReverse(row) - distance
            row = Matrix.xmap(x)
        case .Right:
            let x = Matrix.xmapReverse(row) + distance
            row = Matrix.xmap(x)
        default: break
        }
        let targetPosition = getPosition(row, column: column)
        return SKAction.moveTo(targetPosition, duration: 0.5)
    }
    
    func moveTo(targetRow : Int, targetColomn: Int){
        let targetPosition = getPosition(targetRow, column: targetColomn)
        self.node.runAction(SKAction.moveTo(targetPosition, duration: 0.5))
    }
    
    func doubled(){
        self.number *= 2
        self.node.childNodeWithName("text")?.removeFromParent()
        let title = getTextNode(self.number)
        node.addChild(title)
        self.node.color = getBlockColor()
    }
    
    func disappear(){
        self.node.removeFromParent()
    }
}

// Creators
private extension Grid {
    func createNode() -> SKSpriteNode {
        print(self.getBlockColor())
        let grid = SKSpriteNode(color: self.getBlockColor(), size: CGSize.init(width: gridWidth, height: gridWidth))
        node = grid
        return grid
    }
    
    
    func getBlockColor() -> UIColor{
        let color : UIColor
        switch (self.number) {
        case 2:
            color = UIColor.init(red: 238/255, green: 228/255, blue: 215/255, alpha: 1)
        case 4:
            color = UIColor.init(red: 237/255, green: 224/255, blue: 200/255, alpha: 1)
        case 8:
            color = UIColor.init(red: 242/255, green: 177/255, blue: 121/255, alpha: 1)
        case 16:
            color = UIColor.init(red: 245/255, green: 149/255, blue: 99/255, alpha: 1)
        case 32:
            color = UIColor.init(red: 246/255, green: 124/255, blue: 95/255, alpha: 1)
        case 64:
            color = UIColor.init(red: 246/255, green: 94/255, blue: 59/255, alpha: 1)
        case 128:
            color = UIColor.init(red: 237/255, green: 207/255, blue: 114/255, alpha: 1)
        case 256:
            color = UIColor.init(red: 237/255, green: 207/255, blue: 114/255, alpha: 1)
        default:
            color = UIColor.init(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        }
        return color
    }
    
    func getFontColor(showNum : UInt) -> UIColor{
        if(showNum == 2 || showNum == 4){
            return UIColor.init(red: 119/255, green: 110/255, blue: 101/255, alpha: 1)
        }else{
            return UIColor.whiteColor()
        }
    }
    
    func getPosition(row : Int, column: Int) -> CGPoint{
        let x = (gridWidth + 14) * CGFloat(((row > 0) ?(Float(row) - 0.5): (Float(row) + 0.5)))
        let y = (gridWidth + 14) * CGFloat(((column > 0) ?(Float(column) - 0.5): (Float(column) + 0.5)))
        return CGPointMake(x,y)
    }
    
    func getTextNode(showNum : UInt) -> SKLabelNode{
        let title = SKLabelNode(fontNamed: "Clear Sans")
        title.text = String(showNum)
        title.fontSize = 40
        title.position = CGPointMake(0,-10)
        title.zPosition = 3
        title.fontColor = getFontColor(showNum)
        title.name = "text"
        return title
    }
}

extension Grid : Hashable{
    var hashValue : Int {
        get{
            return self.row * 10 + self.column
        }
    }
}
