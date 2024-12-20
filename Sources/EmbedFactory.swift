//
//  CustomEmbed.swift
//  0x4337
//
//  Created by Feets on 19/12/2024.
//

import DiscordBM

enum EmbedFactory {
        /// A blue embed for the result of running a command
        static func normalEmbed(for message: String, command: Command, payload: Gateway.MessageCreate) -> [Embed] {
                let username = payload.member?.nick ?? payload.author!.username
                
                return [Embed(color: .blue,
                              footer: .init(text: "Command called by \(username)"),
                              fields: [
                                .init(name: command.message, value: message),
                              ])]
        }
        
        /// A grey embed used to show a help page
        static func helpEmbed(for command: Command) -> [Embed] {
                let aliases = command.aliases.isEmpty ? "" : " (\(command.aliases.joined(separator: ", ")))"
                
                let fields = command.arguments.map { argument in
                        let optional = argument.optional ? "(optional) " : ""
                        let numericDescription = switch argument.argType {
                        case .integer(let min, let max): "(\(min) to \(max))"
                        case .double(let min, let max): "(\(min) to \(max))"
                        default: ""
                        }
                        
                        let description = "\(optional)\(argument.note ?? "") \(numericDescription)"
                        
                        return Embed.Field.init(name: argument.description, value: description)
                }
                
                return [Embed(title: "\(command.message)\(aliases)", color: .gray, fields: fields)]
        }
        
        /// A red embed for showing an error
        static func errorEmbed(for errors: [Error]) -> [Embed] {
                let fields = errors.map { error in
                        Embed.Field(name: "", value: "\(error)", inline: true)
                }
                
                return [Embed(color: .red, fields: fields)]
        }
}
