import SwiftUI
import CoreData

struct ListsView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @State private var addListViewOpen: Bool = false
  
  // Initializing fetch request this way prevents preview crash
  static var getRoutineListsFetchRequest: NSFetchRequest<RoutineList> {
    let request: NSFetchRequest<RoutineList> = RoutineList.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineList.createdDate, ascending: true)
    ]
    
    return request
  }
    
  @FetchRequest private var lists: FetchedResults<RoutineList>
  
  init() {
    _lists = FetchRequest(
      fetchRequest: ListsView.getRoutineListsFetchRequest,
      animation: .default
    )
  }
  
  
  var body: some View {
    NavigationView {
      List {
        ForEach(lists) { list in
          ListItemView(list: list)
        }
        .onDelete(perform: deleteLists)
      }
      .navigationTitle("Lists")
      .environment(\.defaultMinListRowHeight, 80)
        .toolbar {
          // There are no non-beta settings yet
          #if BETA
            ToolbarItem(placement: .navigationBarLeading) {
              NavigationLink(destination: SettingsView()
                .environment(\.managedObjectContext, self.viewContext)) {
                Label("Settings", systemImage: "gearshape")
              }
            }
          #endif

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: showAddList) {
              Label("Add List", systemImage: "plus")
            }
            .sheet(isPresented: $addListViewOpen) {
              ListEditorView()
                .environment(\.managedObjectContext, self.viewContext)
            }
          }

          #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
              EditButton()
            }
          #endif
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

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext

    ListsView().environment(
      \.managedObjectContext,
       context
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
