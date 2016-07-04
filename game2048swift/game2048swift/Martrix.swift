//
//  Martrix.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/2.
//  Copyright © 2016年 张 帆. All rights reserved.
//

import Foundation
import SpriteKit


class Matrix{
    var node : SKSpriteNode!
    private var parentNode: SKSpriteNode!
    var matrixByRow = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
    var grids = [Grid:[Int]]()
    var curDirection : SlideDirection = .Invalid
    
    init(){
        let gameArea = SKSpriteNode(imageNamed: "2048bg")
        gameArea.zPosition = 1
        node = gameArea
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
    
    func move(direction : SlideDirection) -> [[Int]]{
        
        //        guard direction != .Invalid else {
        //            throw GameError.InvalidDirection
        //        }
        curDirection = direction
        
        var calMatrix : [[UInt]] = getEmptyMatrix()
        switch direction {
        case .Up:
            calMatrix = transferMatrix(matrixByRow)
        case .Down:
            calMatrix = reverseMatrix(transferMatrix(matrixByRow))
        case .Right:
            calMatrix = reverseMatrix(matrixByRow);
        case .Left:
            calMatrix = matrixByRow
        default:
            calMatrix = matrixByRow
        }
        
        var newMatrix = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
        var actionMatrix = [[Int]](count :4, repeatedValue: [Int](count :4, repeatedValue: 0))
        
        for i in  0...3{
            let orderLine = getOrderLine(calMatrix[i])
            newMatrix[i] = orderLine.newline
            actionMatrix[i] = orderLine.returnActionCodes
        }
        
        switch direction {
        case .Up:
            matrixByRow = transferMatrix(newMatrix)
            actionMatrix = transferMatrix(actionMatrix)
        case .Down:
            matrixByRow = transferMatrix(reverseMatrix(newMatrix))
            actionMatrix = transferMatrix(reverseMatrix(actionMatrix))
        case .Right:
            matrixByRow = reverseMatrix(reverseMatrix(newMatrix))
            actionMatrix = reverseMatrix(reverseMatrix(actionMatrix))
        case .Left:
            matrixByRow = newMatrix
        default:
            matrixByRow = newMatrix
        }
        
        self.runActions(actionMatrix)
        return actionMatrix
    }
}

private extension Matrix{
    func addNumberInSpace(){
        var spaceFlag = [[String : Int]]()
        for (i, row) in matrixByRow.enumerate() {
            for (j,num) in row.enumerate(){
                if num == 0{
                    let flag = ["y":i , "x":j]
                    spaceFlag.append(flag)
                }
            }
        }
        let randNum = Int(UInt.random(min: 0, max: UInt(spaceFlag.count)))
        let y = spaceFlag[randNum]["y"]!
        let x = spaceFlag[randNum]["x"]!
        let showNum = UInt(UInt.random(min: 1, max: 2)*2);
        matrixByRow[y][x] = showNum
        let grid = Grid(row: xmap(x), column: ymap(y), showNum: showNum).addTo(self)
        grids[grid] = [y,x]
    }
    
    func ymap(key : Int) -> Int{
        let dic = [0 : 2, 1 : 1, 2 : -1, 3 : -2]
        return dic[key]!
    }
    
    func xmap(key : Int) -> Int{
        let dic = [0 : -2, 1 : -1, 2 : 1, 3 : 2]
        return dic[key]!
    }
    
    func getEmptyMatrix() -> [[UInt]]{
        let matrix = [[UInt]](count :4, repeatedValue: [UInt](count :4, repeatedValue: 0))
        return matrix
    }
    
    func reverseMatrix(inputMatrix : [[UInt]]) -> [[UInt]]{
        var newMatrix : [[UInt]] = getEmptyMatrix()
        for i in 0...3{
            for j in 0...3{
                newMatrix[i][j] = inputMatrix[i][3-j];
            }
        }
        return newMatrix;
    }
    
    func transferMatrix(inputMatrix : [[UInt]]) -> [[UInt]]{
        var newMatrix : [[UInt]] = getEmptyMatrix()
        for i in 0...3{
            for j in 0...3{
                newMatrix[j][i] = inputMatrix[i][j];
            }
        }
        return newMatrix;
    }
    
    //TODO 使用范型解决
    func getEmptyMatrix() -> [[Int]]{
        let matrix = [[Int]](count :4, repeatedValue: [Int](count :4, repeatedValue: 0))
        return matrix
    }
    
    func reverseMatrix(inputMatrix : [[Int]]) -> [[Int]]{
        var newMatrix  : [[Int]] = getEmptyMatrix()
        for i in 0...3{
            for j in 0...3{
                newMatrix[i][j] = inputMatrix[i][3-j];
            }
        }
        return newMatrix;
    }
    
    func transferMatrix(inputMatrix : [[Int]]) -> [[Int]]{
        var newMatrix : [[Int]] = getEmptyMatrix()
        for i in 0...3{
            for j in 0...3{
                newMatrix[j][i] = inputMatrix[i][j];
            }
        }
        return newMatrix;
    }
    
    //返回动作和组合后的顺序，"重力面"在前
    func getOrderLine(line : [UInt]) -> (newline : [UInt],returnActionCodes : [Int]){
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
                }else{
                    action = [0, drop]
                }
                lastNotZeroIndex = i
            }else if (line[i] == 0){
                drop += 1
                action = [0,0]
            }
            actions.append(action);
        }
        var returnActionCodes = [Int](count : 4,repeatedValue : 0)
        print(actions)
        for i in 0...3 {
            var action = actions[i]
            if action[0] == 0 {
                returnActionCodes[i] = action[1]
                newline[i-action[1]] = line[i];
            }else if (action[0] == 1){
                returnActionCodes[i] = -1 - action[1];
            }else{
                //get delay
                var delay :Int = 0;
                for j in i+1 ..< 4 {
                    if(actions[j][0] == 1){
                        delay = actions[j][1];
                        break;
                    }
                }
                returnActionCodes[i] = 10 + action[1] + delay*10;
                newline[i-action[1]] = line[i]*2;
            }
        }
        
        return (newline, returnActionCodes)
    }
    
    func runActions(actionMatrix : [[Int]]){
        for (grid, position) in grids {
            let i = position[0]
            let j = position[1]
            let actionCode = actionMatrix[i][j]
            if actionCode < 0{//move and disappear
                let moveDistance = -1 - actionCode
                //TODO
                grid.moveByDirection(curDirection, distance: moveDistance)
            }else if actionCode > 0 && actionCode<5 { // just move
                
            }else if actionCode > 9{//move and duoble
                
            }
        }
    }
}