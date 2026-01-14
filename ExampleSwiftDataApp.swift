//
//  ExampleSwiftDataApp.swift
//  ExampleSwiftData
//
//  Created by n.esmer on 14.01.2026.
//

import SwiftUI
import SwiftData

@main
struct ExampleSwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [MyBook.self], inMemory: false)
        }
    }
}
