//
//  Lexer.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/1/16.
//
//

import Foundation

// ====================================================
// MARK - Helper functions

private extension String {
    func rangesOfString (str: String) -> [Range<Index>] {
        var ranges : [Range<Index>] = []
        var scratchString = self
        while let range = scratchString.rangeOfString(str) {
            ranges.append(range)
            scratchString = scratchString.substringFromIndex(range.endIndex)
        }
        return ranges
    }
}

private extension Character {
    func charCode() -> UInt8 {
        return String(self).utf8.map {$0}[0]
    }
    
    func isLetter() -> Bool {
        let code = self.charCode()
        let isUpperCase = (65 <= code && code <= 90)
        let isLowerCase = (97 <= code && code <= 122)
        return isLowerCase || isUpperCase
    }
    
    func isNumericDigit() -> Bool {
        let code = self.charCode()
        return 48 <= code && code <= 57 || code == 46
    }
}

internal extension Array {
    func peek() -> Element? {
        if self.count > 0 {
            return self[0]
        } else {
            return nil
        }
    }
    
    mutating func consume() -> Element? {
        if count > 0 {
            return self.removeFirst()
        } else {
            return nil
        }
    }
}

// ====================================================

public enum Token {
    case TVar(Character)
    case TOpCaret, TOpPlus, TOpMinus, TOpTimes, TOpDivide, TOpEquals
    case TNumber(Double)
    case TParenLeft, TParenRight
    case TBang
    case TComma
    case TString(String)
}

public func ==(a:Token, b:Token) -> Bool {
    switch (a,b) {
    case (.TVar(let x), .TVar(let y)) where x == y: return true
    case (.TNumber(let x), .TNumber(let y)) where x == y: return true
    case (.TString(let x), .TString(let y)) where x == y: return true
    case (.TOpCaret, .TOpCaret): return true
    case (.TOpPlus, .TOpPlus): return true
    case (.TOpMinus, .TOpMinus): return true
    case (.TOpTimes, .TOpTimes): return true
    case (.TOpDivide, .TOpDivide): return true
    case (.TParenLeft, .TParenLeft): return true
    case (.TParenRight, .TParenRight): return true
    case (.TOpEquals, .TOpEquals): return true
    case (.TBang, .TBang): return true
    case (.TComma, .TComma): return true
    default: return false
    }
}

public func !=(a:Token, b:Token) -> Bool {
    return !(a == b)
}

public func ==(a:TokenStream, b:TokenStream) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i] != b[i] {
            return false
        }
    }
    return true
}

func tokensFromLetters(str: String, strings: [String]) -> TokenStream {
    let sortedStrings = strings.sort({$0.characters.count > $1.characters.count})
    var locations : [Int:String] = [:]
    
    //scan for locations
    for tString in sortedStrings {
        let ranges = str.rangesOfString(tString)
        for range in ranges {
            let i = str.startIndex.distanceTo(range.startIndex)
            if locations[i] == nil {
                locations[i] = tString
            }
        }
    }
    //==================
    
    var resTokens : TokenStream = []
    let chars = str.characters.map {$0}
    var i = 0
    while i < chars.count {
        if let tokenString = locations[i] {
            resTokens.append(.TString(tokenString))
            i += tokenString.characters.count
        } else {
            resTokens.append(.TVar(chars[i]))
            i += 1
        }
    }
    
    return resTokens
}

public typealias TokenStream = [Token]

class Lexer {
    
    enum LexerError : ErrorType {
        case NextTokenUnparsable
    }
    
    func scanStreamForStrings(tokens: TokenStream, strings: [String]) -> TokenStream {
        var resultStream : TokenStream = []
        var scanString = ""
        
        for token in tokens {
            switch token {
            case .TVar(let c): scanString += String(c)
            case let t where scanString.characters.count > 0:
                let stringTokens = tokensFromLetters(scanString, strings: strings)
                resultStream.appendContentsOf(stringTokens)
                scanString = ""
                resultStream.append(t)
            case let t : resultStream.append(t)
            }
            print()
        }
        
        return resultStream
        
    }
    
    func lex(str: String) throws -> TokenStream? {
        return try lex(str.characters.map{$0})
    }
    
    func lex(chars: [Character]) throws -> TokenStream {
        var tokens : TokenStream = []
        
        var remainingChars : [Character] = chars
        
        while remainingChars.count > 0 {
            if let token = try lexNextToken(&remainingChars) {
                tokens.append(token)
            }
        }
        
        return tokens
    }
    
    //parses next token and returns (remainingChars, parsedToken)
    private func lexNextToken(inout characters: [Character]) throws -> Token? {
        guard let nextChar = characters.peek() else {
            return nil
        }
        
        switch nextChar {
        case let c where c.isNumericDigit():
            return lexNumber(&characters)!
        case let c where c.isLetter():
            return .TVar(characters.consume()!)
        case "^": characters.consume()
                  return .TOpCaret
        case "+": characters.consume()
                  return .TOpPlus
        case "-": characters.consume()
                  return .TOpMinus
        case "*": characters.consume()
                  return .TOpTimes
        case "/": characters.consume()
                  return .TOpDivide
        case "(": characters.consume()
                  return .TParenLeft
        case ")": characters.consume()
                  return .TParenRight
        case "!": characters.consume()
                  return .TBang
        case "=": characters.consume()
                  return .TOpEquals
        case " ", "\t", "\n", "\r": characters.consume()
                                    return nil
        default : throw LexerError.NextTokenUnparsable
        }
    }
    
    private func lexNumber(inout characters: [Character]) -> Token? {
        var str = String("")
        
        while (characters.peek() != nil &&
               characters.peek()!.isNumericDigit())
        {
                let c = characters.consume()!
                str += String(c)
        }
        
        let number = Double(str)!
        return .TNumber(number)
    }
}
