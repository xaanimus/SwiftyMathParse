# SwiftyMathParse
A math parser for Swift

![alt text](https://https://raw.githubusercontent.com/xaanimus/SwiftyMathParse/master/assets/IconMain.png)

## Usage
To parse a string into an AST:
```swift
do {
    let ast = try AST.fromString("x = 3 + 4")
} catch _ {
}
```

To parse a string with functions into an AST:
```swift
do {
    let functions = ["sin", "cos", "tan"]
    let ast = try AST.fromString("x = 3 + 4", withFunctions:functions)
} catch _ {
}
```

To parse and evaluate a string with variables:
```swift
do {
    let functions = ["sin":sin]
    let vars : [Character:Double] = ["x":M_PI]
    let ast = try AST.fromString("sin(x)", withFunctions:functions.map{$0.0})
    let result = try eval(ast, varEnv:vars, funEnv:functions)
    print("sin(x) = \(result)")
} catch _ {
}
```
