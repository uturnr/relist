//
//  RelistApp.swift
//  Shared
//
//  Created by Cody Cody on 2022-05-05.
//

import SwiftUI

@main
struct RelistApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
