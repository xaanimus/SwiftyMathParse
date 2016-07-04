//
//  Parser.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/2/16.
//
//

import Foundation

enum BinOpTypes {
    case Plus, Minus, Times, Divide, Pow
}

indirect enum AST {
    case Number(Double), Var(Character)
    case BinOp(AST, BinOpTypes, AST)
    case Function(String, AST)
    case Equals(AST,AST)
}

infix operator ~== {precedence 130}
internal func ~==(a:Optional<Token>, b:Token) -> Bool {
    if let aUnwrapped = a {
        return aUnwrapped == b
    }
    return false
}

enum ParseError : ErrorType {
    case Error(String)
}

class Parser {
    
    func parse(tokens: TokenStream) throws -> AST {
        var remainingTokens = tokens
        return try parseEquals(&remainingTokens)
    }
    
    //equalsexpr ::= <addexpr> [ = <equalsexpr> ]
    func parseEquals(inout tokens: TokenStream) throws -> AST {
        let leftExpr = try parseAdd(&tokens)
        
        if tokens.peek() ~== Token.TOpEquals {
            tokens.consume()
            let rightExpr = try parseEquals(&tokens)
            return .Equals(leftExpr, rightExpr)
        } else {
            return leftExpr
        }
    }
    
    //addexpr ::= <mulexpr> [(*|/|\<empty>) <mulexpr>]
    func parseAdd(inout tokens: TokenStream) throws -> AST {
        let leftExpr = try parseMul(&tokens)
        
        if tokens.peek() ~== Token.TOpPlus ||
            tokens.peek() ~== Token.TOpMinus
        {
            let token = tokens.consume()!
            let rightExpr = try parseAdd(&tokens)
            
            var oper : BinOpTypes = .Plus
            if token == Token.TOpMinus {
                oper = .Minus
            }
            return .BinOp(leftExpr, oper, rightExpr)
        } else {
            return leftExpr
        }
    }
    
    func parseMul(inout tokens: TokenStream) throws -> AST {
        let leftExpr = try parsePow(&tokens)
        
        if tokens.peek() ~== Token.TOpTimes ||
            tokens.peek() ~== Token.TOpMinus
        {
            let token = tokens.consume()!
            let rightExpr = try parseMul(&tokens)
            
            var oper : BinOpTypes = .Times
            if token == Token.TOpDivide {
                oper = .Divide
            }
            return .BinOp(leftExpr, oper, rightExpr)
        } else {
            return leftExpr
        }
    }
    
    func parsePow(inout tokens: TokenStream) throws -> AST {
        let leftExpr = try parseFunNumParen(&tokens)
        
        if tokens.peek() ~== Token.TOpCaret {
            tokens.consume()
            let rightExpr = try parsePow(&tokens)
            return .BinOp(leftExpr, .Pow, rightExpr)
        } else {
            return leftExpr
        }
    }
    
    func parseFunNumParen(inout tokens: TokenStream) throws -> AST {
        if let token = tokens.peek() {
            if case Token.TString(let name) = token {
                tokens.consume()
                let funArgs = try parseNumParen(&tokens)
                return .Function(name, funArgs)
            } else {
                let numParen = try parseNumParen(&tokens)
                return numParen
            }
        } else {
            throw ParseError.Error("Expected a function or a numparen expression")
        }
    }
    
    //numparen ::= <number> | <var> | (<addexpr>)
    func parseNumParen(inout tokens: TokenStream) throws -> AST {
        if let t = tokens.consume() {
            switch t {
            case Token.TNumber(let num):
                return .Number(num)
            case Token.TVar(let c):
                return .Var(c)
            case Token.TParenLeft:
                let addExpr = try parseAdd(&tokens)
                if !(tokens.consume() ~== Token.TParenRight) {
                    throw ParseError.Error("Expected token right parenthesis")
                }
                return addExpr
            default:
                throw ParseError.Error("expected a number or a variable or a left parenthesis")
            }
        } else {
            throw ParseError.Error("expected a token")
        }
    }
    
}