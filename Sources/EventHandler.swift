//
//  EventHandler.swift
//  0x4337
//
//  Created by Feets on 17/12/2024.
//

import DiscordBM
import Foundation
import RegexBuilder

extension Array where Element == Module {
        func firstResponder(for message: String) -> (any Module)? {
                return self.first { $0.commands.contains { $0.message == message } }
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
                
                let text = payload.content.lowercased()
                let components = text.components(separatedBy: " ")
                
                // Determine the message being sent to the bot.
                guard let firstWord = components.first, firstWord.first == "!"
                else { return }
                
                // Check for any responding modules.
                let message = String(firstWord.dropFirst())
                guard let firstResponder = modules.firstResponder(for: message),
                      let command = firstResponder.commands.firstResponse(for: message)
                else { return }
                
                // Show the command's help page.
                if components.count > 1, components[1] == "help" {
                        // Print error message if one is found.
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(embeds: EmbedFactory.helpEmbed(for: command)))
                        return
                }
                
                // Parse the command to ensure it was correctly provided by the user.
                guard let args = Parser.parse(from: payload.content, withArguments: command.arguments)
                else { return }
                print("Pairs: \(args)")
                
                // Make sure there were no errors detected.
                // This should be handled separately to avoid bothering calling the command.
                guard args.errors.isEmpty else {
                        // Print error message if one is found.
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(embeds: EmbedFactory.errorEmbed(for: args.errors)))
                        return
                }
                
                // If the command was found, run it.
                let outcome = await command.command(args, payload, client)
                
                // If the output is text, send it back.
                switch outcome {
                case .success(let text):
                        _ = try? await client.createMessage(channelId: payload.channel_id, payload: .init(embeds: EmbedFactory.normalEmbed(for: text, command: command, payload: payload)))
                case .failure(let error):
                        _ = try? await client.createMessage(
                                channelId: payload.channel_id,
                                payload: .init(embeds: EmbedFactory.errorEmbed(for: [error]))
                        )
                }
        }
}
