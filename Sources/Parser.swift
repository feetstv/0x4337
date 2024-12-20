//
//  Parser.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import Foundation

class Parser {
        static func parse(from selector: String, withArguments expectedArguments: [Parameter]) -> ArgsDictionary? {
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
        
        private static func validateArguments(keyValuePairs: [String: String?], expectedArguments: [Parameter]) -> ArgsDictionary {
                return expectedArguments.reduce(into: ArgsDictionary()) { result, parameter in
                        let rawValue = keyValuePairs[parameter.parameter] ?? nil
                        result[parameter.parameter] = (parameter, transformArgumentValue(rawValue: rawValue, argument: parameter))
                }
        }
        
        private static func transformArgumentValue(rawValue: String?, argument: Parameter) -> Argument {
                switch (argument.argType, rawValue) {
                case (.text, let val?):
                        return .text(text: val)
                case (.integer(let min, let max), let val?):
                        // Ensure integers don't contain decimal places.
                        guard !val.contains(".") else {
                            return .error(error: .typeMismatch)
                        }

                        guard let number = Int(val) else {
                            return .error(error: .typeMismatch)
                        }

                        // Ensure the integer is in range.
                        guard number >= min, number <= max else {
                                return .error(error: .numberOutOfRange(Double(min), Double(max)))
                        }

                        return .integer(integer: number)
                case (.double(let min, let max), let val?):
                        guard let number = Double(val) else {
                            return .error(error: .typeMismatch)
                        }

                        // Ensure the double is in range.
                        guard number >= min, number <= max else {
                                return .error(error: .numberOutOfRange(min, max))
                        }

                        return .double(double: number)
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
