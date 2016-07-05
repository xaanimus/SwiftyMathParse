//
//  LexerTests.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/1/16.
//
//

import XCTest
@testable import SwiftyMathParse

let testItems : [(String, TokenStream )] = [
    ( "1+2", [.TNumber(1), .TOpPlus, .TNumber(2)] ),
    ( "1 + 2", [.TNumber(1), .TOpPlus, .TNumber(2)] ),
    ( "12.3 / 2.4", [.TNumber(12.3), .TOpDivide, .TNumber(2.4)] ),
    ( "36/5 * (5 + 4)", [.TNumber(36), .TOpDivide, .TNumber(5), .TOpTimes, .TParenLeft, .TNumber(5), .TOpPlus, .TNumber(4), .TParenRight]),
    ("y=5x^2+6x-2", [.TVar("y"), .TOpEquals, .TNumber(5), .TVar("x"), .TOpCaret, .TNumber(2), .TOpPlus, .TNumber(6), .TVar("x"), .TOpMinus, .TNumber(2)])
]

let testStrings = ["sin", "sinh"]
let stringTestItems : [(String, TokenStream)] = [
    ("xsinh(x) + 9000", [.TVar("x"), .TString("sinh"), .TParenLeft, .TVar("x"), .TParenRight, .TOpPlus, .TNumber(9000)])
]

func assertTokenStreamsEqual(a:TokenStream, _ b:TokenStream) {
    XCTAssertEqual(a.count, b.count)
    for i in 0..<a.count {
        XCTAssert(a[i] == b[i])
    }
}

class LexerTests: XCTestCase {
    
    var lexer : Lexer = Lexer()
    
    override func setUp() {
        super.setUp()
        lexer = Lexer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLex() {
        do {
            for (testStr, testTokens) in testItems {
                let result = try lexer.tokenize(testStr)
                assertTokenStreamsEqual(result, testTokens)
            }
        } catch let e {
            print(e)
            XCTAssertTrue(false, "could not tokenize string")
        }
    }
    
    func testScanStream() {
        do {
            for (s, results) in stringTestItems {
                let testPreResult = try lexer.tokenize(s)
                let testPreResultUnwrapped = testPreResult
                let testResult = lexer.scanStreamForStrings(testPreResultUnwrapped,
                                                            strings: testStrings)
                assertTokenStreamsEqual(results, testResult)
            }
        } catch let e {
            print(e)
            XCTAssertTrue(false, "could not tokenize string")
        }
    }
    
}
