//
//  EventHandler.swift
//  0x4337
//
//  Created by Feets on 17/12/2024.
//

import DiscordBM
import RegexBuilder

extension Array where Element == Module {
        func firstResponder(for message: String) -> (any Module)? {
                return self.first { $0.commands.contains { $0.message == message } }
        }
}

extension Array where Element == Command {
        func firstResponse(for message: String) -> (any Command)? {
                return self.first { $0.allMessages.contains(message) }
        }
}

struct EventHandler: GatewayEventHandler {
        let event: Gateway.Event
        let client: any DiscordClient
        
        let modules: [any Module] = [
                PingModule(),
                RandomModule()
        ]
        
        func onMessageCreate(_ payload: Gateway.MessageCreate) async throws {
                // Ignore the bot's own messages.
                guard let ownId = try? await client.getOwnUser().decode().id, payload.author?.id != ownId else { return }
                
                // Determine the message being sent to the bot.
                guard let message = payload.content.split(separator: " ").first?.lowercased().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                else { return }
                        
                // Check for any responding modules.
                guard let firstResponder = modules.firstResponder(for: message),
                      let command = firstResponder.commands.firstResponse(for: message)
                else { return }
                
                // Parse the command to ensure it was correctly provided by the user.
                guard let args = Parser.parse(from: payload.content, withArguments: command.arguments)
                else { return }
                print("Pairs: \(args)")
                
                // Make sure there were no errors detected.
                guard args.firstError == nil else {
                        // Print error message if one is found.
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(content: "Error: \(args.firstError!)"))
                        return
                }
                
                // If the command was found, run it.
                await command.command(args, payload, client)
        }
}
