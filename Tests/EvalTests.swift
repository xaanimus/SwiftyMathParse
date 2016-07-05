//
//  EvalTests.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/5/16.
//
//

import XCTest
@testable import SwiftyMathParse

class EvalTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEval() {
        let str = "2 + 3 / 5 - 6 * 4"
        let result = -21.4
        do {
            let ast = try AST.fromString(str)
            let testResult = try eval(ast, varEnv:[:], funEnv:[:])
            XCTAssertEqual(result, testResult)
        } catch _ {
            XCTAssert(false)
        }
    }
    
    func testEvalVar() {
        let str = "100 + x * y - 6"
        let varEnv : [Character:Double] = ["x":34, "y":9]
        let result = 400.0
        do {
            let ast = try AST.fromString(str)
            let testResult = try eval(ast, varEnv:varEnv, funEnv:[:])
            XCTAssertEqual(result, testResult)
        } catch _ {
            XCTAssert(false)
        }
    }
    
    func testEvalFun() {
        let str = "y * sin(x)"
        let varEnv : [Character:Double] = ["x":5, "y":2]
        let funEnv : [String:(Double->Double)] = ["sin":sin]
        let result = -1.917848549
        do {
            let ast = try AST.fromString(str, withFunctions:funEnv.map{$0.0})
            let testResult = try eval(ast, varEnv:varEnv, funEnv:funEnv)
            XCTAssertEqualWithAccuracy(testResult, result, accuracy: 0.01)
        } catch _ {
            XCTAssert(false)
        }
    }
}