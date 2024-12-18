//
//  RandomModule.swift
//  0x4337
//
//  Created by Feets on 18/12/2024.
//

import DiscordBM

/// A module that sends Pong whenever you Ping!
struct RandomModule : Module {
        let name: String = "Random"
        let commands: [any Command] = [
                CoinTossCommand(),
                DiceThrowCommand()
        ]
        let description: String = "Generate random outcomes."
}

/// Tosses a coin: heads or tails!
struct CoinTossCommand : Command {
        let message: String = "cointoss"
        let aliases: [String] = ["tosscoin", "coin", "toss"]
        let arguments: [Argument] = []
        
        var command: (ArgsDictionary, Gateway.MessageCreate, any DiscordClient) async -> Void {
                return { message, payload, client in
                        let outcome = ["🪙 Heads", "🪙 Tails"].randomElement()!
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(content: outcome))
                }
        }
}

/// Throws a dice of a specified size (D6 by default).
struct DiceThrowCommand : Command {
        let message: String = "dice"
        let aliases: [String] = ["roll"]
        let arguments: [Argument] = [
                .init(argument: "size", argType: .integer, optional: true, defaultValue: .integer(integer: 6), note: "The max number to roll (i.e. 6, 10, 12, 20)"),
                .init(argument: "count", argType: .integer, optional: true, defaultValue: .integer(integer: 1), note: "The number of dice to roll (up to 5)")
        ]
        
        var command: (ArgsDictionary, Gateway.MessageCreate, any DiscordClient) async -> Void {
                return { pairs, payload, client in
                        let size = switch pairs["size"]!.1 {
                        case .integer(let number): number
                        default: pairs["size"]!.0.defaultValue!.integer
                        }
                        
                        let count = switch pairs["count"]?.1 {
                        case .integer(let number) where 1 <= number && number <= 5: number
                        default: 1
                        }
                        
                        let output = (0..<count).reduce([String]()) { result, _ in
                                return result + ["\(Int.random(in: 1...size!))"]
                        }
                
                        let outcome = "🎲 \(output.joined(separator: ", "))"
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(content: outcome))
                }
        }
}
