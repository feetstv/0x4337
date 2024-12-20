//
//  Parameter.swift
//  0x4337
//
//  Created by Feets on 19/12/2024.
//

import AccessAssociatedValue
import Collections
import Foundation

struct Parameter : CustomStringConvertible {
        let parameter: String
        let argType: ArgType
        let optional: Bool
        let defaultValue: Argument?
        let note: String?
        
        var description: String {
                return "\(parameter):(\(argType))"
        }
}

enum ArgType : CustomStringConvertible {
        case text
        case integer(Int, Int)
        case double(Double, Double)
        case boolean
        
        var description: String {
                return switch self {
                case .text: "text"
                case .integer(_, _): "integer"
                case .double(_, _): "double"
                case .boolean: "bool"
                }
        }
}

/// Values returned from parsing the tokens.
/// These are used in the `ArgsDictionary`, passed to `Commands`
/// to make it easier to deal with arguments.
@AccessAssociatedValue
enum Argument {
        /// Normal text. These must be wrapped with quotation marks.
        case text(text: String)
        
        /// Whole numbers.
        case integer(integer: Int)
        
        /// Floating-point numbers with double precision, the Swift default.
        case double(double: Double)
        
        /// Boolean (`true` or `false`)
        case boolean(boolean: Bool)
        
        /// Errors. The `EventHandler` always prints out the first one in
        /// the `ArgsDictionary` if one is found.
        case error(error: ArgumentError)
 
        case none
        
        /// Only used for the first token, which is the message to which the command responds.
        case message
}

/// Used in case of an argument whose supplied value is incorrect or missing.
enum ArgumentError: Error, CustomStringConvertible {
        case parameterMissing
        case argumentMissing
        case numberOutOfRange(Double, Double)
        case typeMismatch
        
        var description: String {
                switch self {
                case .parameterMissing: return "The command is missing a required parameter"
                case .argumentMissing: return "A parameter was specified but no argument supplied"
                case .numberOutOfRange(let min, let max):
                        let min = min == floor(min) ? String(format: "%.0f", min) : "\(min)"
                        let max = max == floor(max) ? String(format: "%.0f", max) : "\(max)"
                        return "The argument value is out of range (\(min) to \(max))"
                case .typeMismatch: return "The argument type is incorrect"
                }
        }
}

typealias ArgsDictionary = OrderedDictionary<String, (Parameter, Argument)>

extension ArgsDictionary {
        var errors: [ArgumentError] {
                return self.values.reduce(into: [ArgumentError]()) { result, value in
                        if case .error(let error) = value.1 { result.append(error) }
                }
        }
}
