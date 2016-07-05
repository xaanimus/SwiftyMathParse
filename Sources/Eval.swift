//
//  Eval.swift
//  SwiftyMathParse
//
//  Created by Serge-Olivier Amega on 7/5/16.
//
//

import Foundation

public enum EvalError : ErrorType {
    case UndefinedVarError, UndefinedFunctionError, EqualsEvalError
}

public func eval(ast: AST,
                 varEnv: [Character:Double],
                 funEnv: [String:(Double->Double)]) throws -> Double
{
    switch ast {
    case .Number(let n): return n
    case .Var(let c):
        if let num = varEnv[c] {
            return num
        } else {
            throw EvalError.UndefinedVarError
        }
    case .BinOp(let l, let op, let r):
        let left = try eval(l, varEnv: varEnv, funEnv: funEnv)
        let right = try eval(r, varEnv: varEnv, funEnv: funEnv)
        switch op {
        case .Plus:
            return left + right
        case .Minus:
            return left - right
        case .Times:
            return left * right
        case .Divide:
            return left / right
        case .Pow:
            return pow(left, right)
        }
    case .Function(let name, let a):
        if let fun = funEnv[name] {
            let args = try eval(a, varEnv: varEnv, funEnv: funEnv)
            return fun(args)
        } else {
            throw EvalError.UndefinedFunctionError
        }
    case .Equals(_,_):
        throw EvalError.EqualsEvalError
    }
}