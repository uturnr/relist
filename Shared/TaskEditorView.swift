//
//  TaskEditorView.swift
//  Shared
//
//  Created by uturnr on 2022-05-05.
//

import SwiftUI
import CoreData

struct TaskEditorView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  
  var list: RoutineList
  
  @State private var name = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Name", text: $name)
        }
        
        Button("Add Task") {
          self.addTask(name: self.name)
        }
      }
      #if os(iOS)
        .navigationBarTitle("New Task")
      #endif
    }
  }
  
  private func addTask(name: String) {
    withAnimation {
      let _ = RoutineTask(
        context: viewContext,
        list: list,
        name: name,
        orderIndex: 0
      )
      
      do {
        try viewContext.save()
        presentationMode.wrappedValue.dismiss()
      } catch {
        // TODO: Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

struct TaskEditorView_Previews: PreviewProvider {
  static let list = RoutineList(
    context: PersistenceController.preview.container.viewContext,
    name: "Test",
    orderIndex: 0
  )

  static var previews: some View {
    TaskEditorView(list: list).environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
