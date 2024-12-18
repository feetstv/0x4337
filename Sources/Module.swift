//
//  Module.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

/// Modules contain a number of commands that are logically related in a single object.
protocol Module : Sendable {
        /// The name of the module.
        var name: String { get }
        
        /// The commands contained in the module.
        var commands: [any Command] { get }
}

extension Module {
        /// Returns the module(s) that respond(s) to a given message.
        func responses(for message: String) -> [Command] {
                return self.commands.filter { $0.message == message }
        }
}
