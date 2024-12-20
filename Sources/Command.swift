//
//  Command.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import DiscordBM

extension Array where Element == Command {
        func firstResponse(for message: String) -> (any Command)? {
                return self.first { $0.allMessages.contains(message) }
        }
}

/// The basic command that is processed by the bot.
protocol Command : CustomStringConvertible, Sendable {
        /// The first word.
        var message: String { get }
        
        /// Other valid messages to trigger this command.
        var aliases: [String] { get }
        
        /// The arguments that the command accepts. These are written in the following format:
        /// `[message argument: value argument: "some text" argument: 5]`
        var arguments: [Parameter] { get }
        
        /// The actual function to run.
        var command: (ArgsDictionary, Gateway.MessageCreate, any DiscordClient) async -> Result<String, Error> { get }
}

extension Command {
        /// Default conformance to `CustomStringConvertible`.
        var description: String {
                return "\(message):\(arguments.map(\.parameter).joined(separator: ":"))"
        }
        
        /// All valid messages to trigger this command.
        var allMessages: [String] {
                return [message] + aliases
        }
}
