//
//  main.swift
//  0x4337
//
//  Created by Feets on 17/12/2024.
//

import DiscordBM
import Foundation

guard let token = ProcessInfo.processInfo.environment["DISCORD_TOKEN"] else {
    print("No token found.")
    exit(EXIT_FAILURE)
}

let bot = await BotGatewayManager(
    token: token,
    presence: .init(
        activities: [.init(name: "up", type: .game)],
        status: .online,
        afk: false
    ),
    intents: [.guildMessages, .messageContent]
)

await withTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await bot.connect()
    }

    taskGroup.addTask {
        /// Handle each event in the `bot.events` async stream
        /// This stream will never end, therefore preventing your executable from exiting
        for await event in await bot.events {
            EventHandler(event: event, client: bot.client).handle()
        }
    }
}
