//
//  Command.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import AccessAssociatedValue
import DiscordBM
import Collections

/// The basic command that is processed by the bot.
protocol Command : CustomStringConvertible, Sendable {
        /// The first word. This is always prepended with `[`.
        var message: String { get }
        
        /// Other valid messages to trigger this command.
        var aliases: [String] { get }
        
        /// The arguments that the command accepts. These are written in the following format:
        /// `[message argument: value argument: "some text" argument: 5]`
        /// The final argument is always has `]` appended to the value.
        // Yes, it's Objective-C-style message-passing. Shut up.
        var arguments: [Argument] { get }
        
        /// The actual function to run.
        var command: (ArgsDictionary, Gateway.MessageCreate, any DiscordClient) async -> Void { get }
}

extension Command {
        /// Default conformance to `CustomStringConvertible`.
        var description: String {
                return "\(message):\(arguments.map(\.argument).joined(separator: ":"))"
        }
        
        /// All valid messages to trigger this command.
        var allMessages: [String] {
                return [message] + aliases
        }
}

struct Argument : CustomStringConvertible {
        let argument: String
        let argType: ArgType
        let optional: Bool
        let defaultValue: ArgValue?
        let note: String?
        
        enum ArgType : String {
                case text
                case integer
                case double
                case boolean
        }
        
        var description: String {
                return "\(argument):(\(argType))"
        }
}

/// Values returned from parsing the tokens.
/// These are used in the `ArgsDictionary`, passed to `Commands`
/// to make it easier to deal with arguments.
@AccessAssociatedValue
enum ArgValue {
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
        case error(error: ArgValueError)
 
        case none
        
        /// Only used for the first token, which is the message to which the command responds.
        case message
}

/// Used in case of an argument whose supplied value is incorrect or missing.
enum ArgValueError: Error, CustomStringConvertible {
        case parameterMissing
        case argumentMissing
        case typeMismatch
        
        var description: String {
                switch self {
                case .parameterMissing: return "The command is missing a required parameter"
                case .argumentMissing: return "A parameter was specified but no argument supplied"
                case .typeMismatch: return "The argument type is incorrect"
                }
        }
}

typealias ArgsDictionary = OrderedDictionary<String, (Argument, ArgValue)>

extension ArgsDictionary {
        var firstError: ArgValueError? {
                let firstError = self.values.first {
                        if case .error(_) = $0.1 { true } else { false }
                }?.1
                switch firstError {
                case .error(let err): return err
                default: return nil
                }
        }
}
