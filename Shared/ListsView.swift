//
//  ListsView.swift
//  Shared
//
//  Created by uturnr on 2022-05-05.
//

import SwiftUI
import CoreData

struct ListsView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @State private var addListViewOpen: Bool = false
  
  // Initializing fetch request this way prevents preview crash
  static var getRoutineListFetchRequest: NSFetchRequest<RoutineList> {
    let request: NSFetchRequest<RoutineList> = RoutineList.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineList.createdDate, ascending: true)
    ]
    
    return request
  }
  
  @FetchRequest(fetchRequest: getRoutineListFetchRequest, animation: .default)

  private var lists: FetchedResults<RoutineList>
  
  
  var body: some View {
    NavigationView {
      List {
        ForEach(lists) { list in
          NavigationLink {
            TasksView(list: list)
              .environment(\.managedObjectContext, self.viewContext)
          } label: {
            Text("\(list.createdDate, formatter: itemFormatter) - \(list.name)")
          }
        }
        .onDelete(perform: deleteLists)
      }.environment(\.defaultMinListRowHeight, 80)
        .toolbar {
          #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
              EditButton()
            }
          #endif
          ToolbarItem {
            Button(action: showAddList) {
              Label("Add List", systemImage: "plus")
            }
            .sheet(isPresented: $addListViewOpen) {
              ListEditorView()
                .environment(\.managedObjectContext, self.viewContext)
            }
          }
        }
      
      Text("Select a list")
    }
  }
  
  private func showAddList() {
    addListViewOpen = true
  }
  
  private func deleteLists(offsets: IndexSet) {
    withAnimation {
      offsets.map { lists[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .none
  formatter.timeStyle = .medium
  return formatter
}()

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext

    ListsView().environment(
      \.managedObjectContext,
       context
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
