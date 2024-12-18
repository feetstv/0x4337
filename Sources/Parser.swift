//
//  Parser.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import Foundation

class Parser {
        static func parse(from selector: String, withArguments expectedArguments: [Argument]) -> ArgsDictionary? {
                // guard let inner = extractInnerContent(from: selector) else { return nil }
                let keyValuePairs = parseKeyValuePairs(from: selector)
                guard !keyValuePairs.isEmpty else { return nil }
                let validatedArguments = validateArguments(keyValuePairs: keyValuePairs, expectedArguments: expectedArguments)
                guard validatedArguments.count >= expectedArguments.filter({ !$0.optional }).count else { return nil }
                return validatedArguments
        }
        
        private static func parseKeyValuePairs(from selector: String) -> [String: String?] {
                let pairRegex = #/([A-Za-z]+)(?::\s*(-?\d+|"[^"]*"|'[^']*'|[^\s]+))?/#
                let matches = selector.trimmingCharacters(in: .whitespaces).matches(of: pairRegex)
                print("Matches: \(matches)")
                return matches.reduce(into: [:]) { result, match in
                        let key = String(match.output.1)
                        let value = match.output.2.map { val in
                                (val.hasPrefix("\"") && val.hasSuffix("\"")) || (val.hasPrefix("'") && val.hasSuffix("'"))
                                ? String(val.dropFirst().dropLast())
                                : String(val)
                        }
                        result[key] = value
                }
        }
        
        private static func validateArguments(keyValuePairs: [String: String?], expectedArguments: [Argument]) -> ArgsDictionary {
                return expectedArguments.reduce(into: ArgsDictionary()) { result, argument in
                        let rawValue = keyValuePairs[argument.argument] ?? nil
                        result[argument.argument] = (argument, transformArgumentValue(rawValue: rawValue, argument: argument))
                }
        }
        
        private static func transformArgumentValue(rawValue: String?, argument: Argument) -> ArgValue {
                switch (argument.argType, rawValue) {
                case (.text, let val?):
                        return .text(text: val)
                case (.integer, let val?):
                        if !val.contains("."), let number = Int(val) {
                                return .integer(integer: number)
                        } else {
                                return .error(error: .typeMismatch)
                        }
                case (.double, let val?):
                        if val.contains("."), let number = Double(val) {
                                return .double(double: number)
                        } else {
                                return .error(error: .typeMismatch)
                        }
                case (.boolean, let val?):
                        let val = val.lowercased()
                        if ["true", "false"].contains(val.lowercased()) {
                                return .boolean(boolean: val.lowercased() == "true")
                        } else {
                                return .error(error: .typeMismatch)
                        }
                case (_, nil) where !argument.optional:
                        return .error(error: .parameterMissing)
                case (_, nil) where argument.optional:
                        return .none
                case (_, nil):
                        return .error(error: .argumentMissing)
                }
        }
}
