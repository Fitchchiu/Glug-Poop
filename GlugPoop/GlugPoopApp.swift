//
//  GlugPoopApp.swift
//  GlugPoop
//
//  Created by feng on 2026/4/29.
//

import SwiftUI

@main
struct GlugPoopApp: App {
    @StateObject private var viewModel = AppViewModel(persistenceController: PersistenceController.shared)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
