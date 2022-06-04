//
//  ListEditorView.swift
//  Shared
//
//  Created by uturnr on 2022-05-05.
//

import SwiftUI
import CoreData

struct ListEditorView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Name", text: $name)
        }
        
        Button("Add List") {
          self.addList(name: self.name)
        }
      }
      #if os(iOS)
        .navigationBarTitle("New List")
      #endif
    }
  }
  
  private func addList(name: String) {
    withAnimation {
      let _ = RoutineList(
        context: viewContext,
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

struct ListEditorView_Previews: PreviewProvider {
  static var previews: some View {
    ListEditorView().environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
