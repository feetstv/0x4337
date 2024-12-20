//
//  PingCommand.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import DiscordBM

/// A module that sends Pong whenever you Ping!
struct PingModule : Module {
        let name: String = "Ping"
        let commands: [any Command] = [
                PingCommand()
        ]
        let description: String = "Sends Pong whenever you Ping!"
}

/// A command to send Pong whenever you Ping!
/// Accepts 1 argument `count` (number), specifying how many times to print "pong!" (up to 10).
struct PingCommand : Command {
        let message: String = "ping"
        let aliases: [String] = []
        let arguments: [Parameter] = [
                .init(parameter: "count", argType: .integer(1,10), optional: true, defaultValue: .integer(integer: 1), note: "1 to 10")
        ]
        
        var command: (ArgsDictionary, Gateway.MessageCreate, any DiscordClient) async -> Result<String, Error> {
                return { pairs, payload, client in
                        let count = if case .integer(let number) = pairs["count"]?.1, 1 <= number, number <= 10 { number } else { 1 }
                        let output = String(String(repeating: "pong!", count: count))
                        
                        return .success(output)
                }
        }
}
