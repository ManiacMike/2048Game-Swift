//
//  Martrix.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/2.
//  Copyright © 2016年 张 帆. All rights reserved.
//

import Foundation
import SpriteKit

let gridInterval : Double = 0.15 //移动一个格子的时间
var resourceScale : CGFloat = 1.0

enum GridAction {
    case Move(Int)
    case Disapear(Int)
    case Duoble(Int,Int)
    case Still
}

class Matrix{
    var node : SKSpriteNode!
    private var parentNode: SKSpriteNode!
    var matrixByRow = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
    var grids = [Grid:[Int]]()
    var curDirection : SlideDirection = .Invalid
    var gameOn = true
    
    init(){
        let gameAreaWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - 50
        let gameArea = SKSpriteNode(imageNamed: "2048bg")
        let originalWidth = gameArea.size.width
        gameArea.zPosition = 1
        gameArea.size = CGSizeMake(gameAreaWidth, gameAreaWidth)
        node = gameArea
        resourceScale = gameAreaWidth / originalWidth
    }
    
    func addTo(parentNode: SKSpriteNode) -> Matrix {
        node.position = CGPoint(x:CGRectGetMidX(parentNode.frame), y:CGRectGetMidY(parentNode.frame))
        parentNode.addChild(node)
        return self
    }
    
    func startGame(){
        addNumberInSpace()
        addNumberInSpace()
    }
    
    func stepGame() -> Bool{
        let step =  SKAction.sequence(
            [
                SKAction.waitForDuration(gridInterval * 3),
                SKAction.runBlock {
                    self.gameOn = self.addNumberInSpace()
                }
            ]
        )
        self.node.runAction(step)
        return gameOn
    }
    
    func move(direction : SlideDirection){
        
        curDirection = direction
        
        var calMatrix : [[UInt]] = Matrix.getEmptyMatrix()
        switch direction {
        case .Up:
            calMatrix = Matrix.transferMatrix(matrixByRow)
        case .Down:
            calMatrix = Matrix.reverseMatrix(Matrix.transferMatrix(matrixByRow))
        case .Right:
            calMatrix = Matrix.reverseMatrix(matrixByRow);
        case .Left:
            calMatrix = matrixByRow
        default: break
        }
        
        var newMatrix = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
        var actionMatrix = [[GridAction]]()
        
        for i in  0...3{
            let orderLine = getOrderLine(calMatrix[i])
            newMatrix[i] = orderLine.newline
            actionMatrix.append(orderLine.returnActionCodes)
        }
        
        switch direction {
        case .Up:
            matrixByRow = Matrix.transferMatrix(newMatrix)
            actionMatrix = Matrix.transferMatrix(actionMatrix)
        case .Down:
            matrixByRow = Matrix.transferMatrix(Matrix.reverseMatrix(newMatrix))
            actionMatrix = Matrix.transferMatrix(Matrix.reverseMatrix(actionMatrix))
        case .Right:
            matrixByRow = Matrix.reverseMatrix(newMatrix)
            actionMatrix = Matrix.reverseMatrix(actionMatrix)
        case .Left:
            matrixByRow = newMatrix
        default: break
        }
        
        print("移动后的矩阵：",matrixByRow)
        print("action矩阵：",actionMatrix)
        do {
            try runActions(actionMatrix)
        } catch GameError.WrongNumGrid {
            print("Invalid NumGrid.")
        } catch {
            
        }
        
    }
    
}

extension Matrix{
    static func getEmptyMatrix<T>() -> [[T]]{
        let matrix = [[T]]()
        return matrix
    }
    
    static func reverseMatrix<T>(inputMatrix : [[T]]) -> [[T]]{
        var newMatrix : [[T]] = inputMatrix
        for i in 0...3{
            for j in 0...3{
                newMatrix[i][j] = inputMatrix[i][3-j];
            }
        }
        return newMatrix;
    }
    
    static func transferMatrix<T>(inputMatrix : [[T]]) -> [[T]]{
        var newMatrix : [[T]] = inputMatrix
        for i in 0...3{
            for j in 0...3{
                newMatrix[j][i] = inputMatrix[i][j];
            }
        }
        return newMatrix;
    }
}

private extension Matrix{
    
    func addNumberInSpace() -> Bool{
        let spaceFlag = getSpaceFlag()
        if spaceFlag.count == 0{
            return false
        }
        let randNum = Int(UInt.random(min: 0, max: UInt(spaceFlag.count)))
        let y = spaceFlag[randNum]["y"]!
        let x = spaceFlag[randNum]["x"]!
        let showNum = UInt(UInt.random(min: 1, max: 3)*2);
        matrixByRow[y][x] = showNum
        let grid = Grid(row: x, column:y, showNum: showNum).addTo(self)
        grids[grid] = [y,x]
        return true
    }
    
    func getSpaceFlag() -> [[String : Int]]{
        var spaceFlag = [[String : Int]]()
        for (i, row) in matrixByRow.enumerate() {
            for (j,num) in row.enumerate(){
                if num == 0{
                    let flag = ["y":i , "x":j]
                    spaceFlag.append(flag)
                }
            }
        }
        return spaceFlag
    }
    
    //返回动作和组合后的顺序，"重力面"在前 [2,2,2,0]  ->   [4,2,0,0]
    func getOrderLine(line : [UInt]) -> (newline : [UInt],returnActionCodes : [GridAction]){
        var drop = 0,lastNotZeroIndex = -1
        var actions = [[Int]]()
        var newline = [UInt](count :4, repeatedValue: 0)
        for i in 0...3{
            var action = [Int](count :2, repeatedValue: 0)
            if(line[i]>0){
                if(lastNotZeroIndex != -1 && line[lastNotZeroIndex] == line[i]){//前面存在整数
                    action = [1, drop]
                    actions[lastNotZeroIndex][0] = 2//前面的数标记为double
                    drop += 1
                    lastNotZeroIndex = -1
                }else{
                    action = [0, drop]
                    lastNotZeroIndex = i
                }
            }else if (line[i] == 0){
                drop += 1
                action = [0,0]
            }
            actions.append(action);
        }
        var returnActionCodes = [GridAction](count : 4,repeatedValue : GridAction.Still)
        for i in 0...3 {
            var action = actions[i]
            if action[0] == 0 {
                if action[1] > 0{
                    returnActionCodes[i] = GridAction.Move(action[1])
                }
                newline[i-action[1]] = line[i];
            }else if (action[0] == 1){
                returnActionCodes[i] = GridAction.Disapear(action[1])
            }else{
                //get delay
                var delay :Int = 0;
                for j in i+1 ..< 4 {
                    if(actions[j][0] == 1){
                        delay = actions[j][1];
                        break;
                    }
                }
                returnActionCodes[i] = GridAction.Duoble(action[1], delay)
                newline[i-action[1]] = line[i]*2;
            }
        }
        
        return (newline, returnActionCodes)
    }
    
    func runActions(actionMatrix : [[GridAction]]) throws{
        var gridToDel:[Grid] = [Grid]()
        for (grid, position) in grids {
            let i = position[0]
            let j = position[1]
            let actionCode = actionMatrix[i][j]
            print("action code:",actionCode)
            switch actionCode {
            case .Move(let moveDistance):
                let moveAction = grid.moveByDirection(curDirection, distance: moveDistance)
                grid.node.runAction(moveAction)
                grids[grid] = [grid.column,grid.row]
                
            case .Disapear(let moveDistance):
                if moveDistance > 0{
                    let moveAction = grid.moveByDirection(curDirection, distance: moveDistance)
                    grid.node.runAction(SKAction.sequence([moveAction,SKAction.removeFromParent()]))
                }else{
                    grid.disappear()
                }
                gridToDel.append(grid)
                
            case .Duoble(let moveDistance, let delay):
                if moveDistance > 0{
                    let moveAction = grid.moveByDirection(curDirection, distance: moveDistance)
                    grid.node.runAction(moveAction)
                }
                print(moveDistance,"|",delay)
                grids[grid] = [grid.column,grid.row]
                let double =  SKAction.sequence(
                    [
                        SKAction.waitForDuration(Double(delay) * gridInterval),
                        SKAction.runBlock {
                            grid.doubled()
                        },
                    ]
                )
                grid.node.runAction(double)
            default : break
            }
            
        }
        
        for grid in gridToDel {
            grids.removeValueForKey(grid)
        }
        if grids.count + getSpaceFlag().count != 16 {
            throw GameError.WrongNumGrid
        }
        
        
    }
}