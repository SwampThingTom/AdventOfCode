#!/usr/bin/swift

// Operation Order
// https://adventofcode.com/2020/day/18

import Foundation

func readFile(named name: String) -> [String] {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: name + ".txt", relativeTo: currentDirectoryURL)
    guard let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8) else {
        print("Unable to read input file \(name)")
        print("Current directory: \(currentDirectoryURL)")
        return []
    }
    return content.components(separatedBy: .newlines)
}

enum Token: CustomStringConvertible {
    case oper(value: Character)
    case separator(value: Character)
    case literal(value: Int)

    var description: String {
        switch self {
        case .oper(let value):
            return "\(value)"
        case .separator(let value):
            return "\(value)"
        case .literal(let value):
            return "\(value)"
        }
    }

    var operValue: Character {
        switch self {
        case .oper(let value):
            return value
        default:
            assert(false)
        }
    }

    var literalValue: Int {
        switch self {
        case .literal(let value):
            return value
        default:
            assert(false)
        }
    }

    var isGroupStart: Bool {
        switch self {
        case .separator(let value):
            return value == "("
        default:
            return false
        }
    }
}

func parse(_ expression: String) -> [Token] {
    var tokens = [Token]()
    let tokenStrings = expression.components(separatedBy: " ")
    for token in tokenStrings {
        if token.first! == "(" || token.last == ")" {
            tokens.append(contentsOf: parse(group: token))
        } else if token.first!.isNumber {
            tokens.append(.literal(value: Int(String(token))!))
        } else if token.first! == "*" || token.first! == "+" {
            tokens.append(.oper(value: token.first!))
        } else {
            assert(false)
        }
    }
    return tokens
}

func parse(group: String) -> [Token] {
    var tokens = [Token]()
    var number = group
    while number.first == "(" {
        tokens.append(.separator(value: "("))
        number.removeFirst()
    }
    var endSeparators = [Token]()
    while number.last == ")" {
        endSeparators.append(.separator(value: ")"))
        number.removeLast()
    }
    tokens.append(.literal(value: Int(String(number))!))
    tokens.append(contentsOf: endSeparators)
    return tokens
}

class ExpressionEvaluator {
    var stack = [Token]()

    // Returns the result of evaluating the given expression from left-to-right.
    // If no `lowPrecedenceOperator` is provided, all operators have the same precedence.
    // If a `lowPrecedenceOperator` is provided, those operations are left until the end.
    // This solution is not easily extensible to multiple levels of operator precedence
    // so thankfully today's problem has only two opeators. :-)
    func evaluate(expression: [Token], lowPrecedenceOperator: Character? = nil) -> Int {
        for token in expression {
            switch token {
            case .oper:
                stack.append(token)
            case .separator:
                if token.isGroupStart {
                    stack.append(token)
                } else {
                    evaluateGroup(except: lowPrecedenceOperator)
                }
            case .literal:
                evaluateOperation(operand: token, except: lowPrecedenceOperator)
            }
        }
        // Evaluate all low precedence operations at the end.
        while stack.count > 1 {
            let operand = stack.removeLast()
            evaluateOperation(operand: operand)
        }
        assert(stack.count == 1)
        return stack[0].literalValue
    }

    private func evaluateGroup(except lowPrecedenceOperator: Character? = nil) {
        while true {
            let result = stack.removeLast()
            if stack.last!.isGroupStart {
                _ = stack.removeLast()  // "(""
                evaluateOperation(operand: result, except: lowPrecedenceOperator)
                return
            }
            evaluateOperation(operand: result)
        }
    }

    // Evaluates an operation for the given operand.
    // If there is no operation on the stack, this simply pushes the operand on the stack.
    // If `lowPrecedenceOperator` is provided, those operations are also left on the stack.
    // Otherwise, it calculates the value of the operation and pushes that on the stack.
    // NOTE: `operand` must be a `.literal`.
    private func evaluateOperation(operand: Token, except lowPrecedenceOperator: Character? = nil) {
        guard !stack.isEmpty && !stack.last!.isGroupStart else {
            stack.append(operand)
            return
        }
        // Leave low precedence operations on the stack.
        if let lowPrecedenceOperator = lowPrecedenceOperator, stack.last!.operValue == lowPrecedenceOperator {
            stack.append(operand)
            return
        }
        let oper = stack.removeLast()
        let operand2 = stack.removeLast()
        let result = evaluate(oper: oper.operValue,
                              operand1: operand.literalValue,
                              operand2: operand2.literalValue)
        let resultLiteral: Token = .literal(value: result)
        stack.append(resultLiteral)
    }

    private func evaluate(oper: Character, operand1: Int, operand2: Int) -> Int {
        switch oper {
        case "+":
            return operand1 + operand2
        case "*":
            return operand1 * operand2
        default:
            assert(false)
        }
    }
}

let input = readFile(named: "18-input").filter { !$0.isEmpty }
let sumOfResults = input.reduce(0) { sum, expressionString in
    let evaluator = ExpressionEvaluator()
    let expression = parse(expressionString)
    let result = evaluator.evaluate(expression: expression)
    return sum + result
}
print("The sum of the results of every expression is \(sumOfResults)")

let sumOfAdvancedReults = input.reduce(0) { sum, expressionString in
    let evaluator = ExpressionEvaluator()
    let expression = parse(expressionString)
    let result = evaluator.evaluate(expression: expression, lowPrecedenceOperator: "*")
    return sum + result
}
print("The sum of the results of every expression using advanced math is \(sumOfAdvancedReults)")
