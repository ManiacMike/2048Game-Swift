//
//  Utils.swift
//  game2048swift
//
//  Created by 张 帆 on 16/7/3.
//  Copyright © 2016年 张 帆. All rights reserved.
//

import Foundation

extension UInt {
    static func random(min lower: UInt = min, max upper: UInt = max) -> UInt {
        var m: UInt
        let u = upper - lower
        var r = UInt(arc4random())
        if u > UInt(Int.max) {
            m = 1 + ~u
        } else {
            m = ((max - (u * 2)) + 1) % u
        }
        while r < m {
            r = UInt(arc4random())
        }
        return (r % u) + lower
    }
}