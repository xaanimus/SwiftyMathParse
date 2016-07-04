//
//  ParserTests.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/4/16.
//
//

import XCTest
@testable import SwiftyMathParse

class ParserTest: XCTestCase {
    
    var parser : Parser = Parser()
    
    override func setUp() {
        super.setUp()
        parser = Parser()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseOpsOne() {
        let tokens : TokenStream = [.TNumber(3), .TOpPlus, .TNumber(2), .TOpTimes, .TNumber(10)]
        let ast : AST = .BinOp(.Number(3), .Plus, .BinOp(.Number(2), .Times, .Number(10)))
        if let testAst = try? parser.parse(tokens) {
            XCTAssert(ast == testAst)
        } else {
            XCTAssert(false, "threw error while parsing")
        }
    }
    
    func testParseOpsTwo() {
        let tokens : TokenStream = [.TNumber(3), .TOpCaret, .TNumber(2), .TOpCaret, .TNumber(10)]
        let ast : AST = .BinOp(.Number(3), .Pow, .BinOp(.Number(2), .Pow, .Number(10)))
        if let testAst = try? parser.parse(tokens) {
            XCTAssert(ast == testAst)
        } else {
            XCTAssert(false, "threw error while parsing")
        }
    }
    
    func testParseFunctionOne() {
        let tokens : TokenStream = [.TString("sin"), .TParenLeft, .TVar("x"), .TParenRight]
        let ast : AST = .Function("sin", .Var("x"))
        if let testAst = try? parser.parse(tokens) {
            XCTAssert(ast == testAst)
        } else {
            XCTAssert(false, "threw error while parsing")
        }
    }
    
}