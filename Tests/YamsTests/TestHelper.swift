//
//  TestHelper.swift
//  Yams
//
//  Created by Norio Nomura on 12/22/16.
//  Copyright (c) 2016 Yams. All rights reserved.
//

import XCTest

/// AssertEqual for Any
///
/// - Parameters:
///   - lhs: Any
///   - rhs: Any
///   - context: Closure generating String that used on generating assertion
///   - file: file path string
///   - line: line number
/// - Returns: true if lhs is equal to rhs
@discardableResult func YamsAssertEqual(_ lhs: Any?, _ rhs: Any?,
                                        _ context: @autoclosure @escaping () -> String = "",
                                        file: StaticString = #file, line: UInt = #line) -> Bool {
    // use inner function for capturing `file` and `line`
    @discardableResult func equal(_ lhs: Any?, _ rhs: Any?,
                                  _ context: @autoclosure @escaping () -> String = "") -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case let (lhs as [Any], rhs as [Any]):
            equal(lhs.count, rhs.count, joined("comparing count of \(dumped(lhs)) to \(dumped(rhs))", context()))
            for (index, (lhsElement, rhsElement)) in zip(lhs, rhs).enumerated() where !equal(
                lhsElement, rhsElement,
                joined("elements at \(index) from \(dumped(lhs)) and \(dumped(rhs))", context())) {
                    return false
            }
            return true
        case let (lhs as [String:Any], rhs as [String:Any]):
            let message1 = { "comparing count of \(dumped(lhs)) to \(dumped(rhs))" }
            equal(lhs.count, rhs.count, joined(message1(), context()))
            let keys = Set(lhs.keys).union(rhs.keys)
            for key in keys where !equal(
                lhs[key], rhs[key],
                joined("values for key(\"\(key)\") in \(dumped(lhs)) and \(dumped(rhs))", context())) {
                    return false
            }
            return true
        case let (lhs?, nil):
            let message = { "(\"\(type(of: lhs))(\(dumped(lhs)))\") is not equal to (\"nil\")" }
            XCTFail(joined(message(), context()), file: file, line: line)
            return false
        case let (nil, rhs?):
            let message = { "(\"nil\") is not equal to (\"\(type(of: rhs))(\(dumped(rhs)))\")" }
            XCTFail(joined(message(), context()), file: file, line: line)
            return false
        case let (lhs as Double, rhs as Double):
            if lhs.isNaN && rhs.isNaN { return true } // NaN is not equal to any value, including NaN
            XCTAssertEqual(lhs, rhs, context(), file: file, line: line)
            return lhs == rhs
        case let (lhs as AnyHashable, rhs as AnyHashable):
            XCTAssertEqual(lhs, rhs, context(), file: file, line: line)
            return lhs == rhs
        default:
            let message = { "Can't compare \(type(of: lhs))(\(dumped(lhs))) to \(type(of: rhs))(\(dumped(rhs)))" }
            XCTFail(joined(message(), context()), file: file, line: line)
            return false
        }
    }
    return equal(lhs, rhs, context)
}

private func dumped<T>(_ value: T) -> String {
    var output = ""
    dump(value, to: &output)
    var count = 0
    var firstLine = ""
    output.enumerateLines { line, stop in
        count += 1
        if count > 1 {
            stop = true
        } else {
            firstLine = line
        }
    }
    if count == 1 {
        // remove `- ` prefix if
        let index = firstLine.index(firstLine.startIndex, offsetBy: 2)
        return firstLine.substring(from: index)
    } else {
        return "[\n" + output + "]"
    }
}

private func joined(_ lhs: String, _ rhs: String) -> String {
    return lhs.isEmpty ? rhs : rhs.isEmpty ? lhs : lhs + " " + rhs
}
