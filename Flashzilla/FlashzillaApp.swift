//
//  FlashzillaApp.swift
//  Flashzilla
//
//  Created by  He on 2026/1/29.
//

import SwiftUI
import SwiftData

@main
struct FlashzillaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Card.self)
    }
}
