import SwiftUI
import CoreData

struct ListsViewMac: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State var isEditing = false

  private var undoManager: UndoManager? {
    viewContext.undoManager
  }
    
  @FetchRequest private var lists: FetchedResults<RoutineList>
  
  init() {
    _lists = FetchRequest(
      fetchRequest: ListsService.routineListsFetchRequest,
      animation: .default
    )
  }
  
  struct EditedList: Identifiable {
    var id: String { listId ?? "new" }
    var isNew: Bool = false
    var listId: String? = nil
  }
  
  @State private var editedList: EditedList? = nil
  
  var body: some View {
    NavigationView {
      List {
        ForEach(lists) { list in
          Text(list.name)
        }
        .onDelete { indexSet in
          let listsToDelete = indexSet.map { lists[$0] }
          ListsService.deleteLists(listsToDelete)
        }
      }
      .animation(.default, value: isEditing)
      .navigationTitle(isEditing ? "Editing Lists" : "Lists")
      .environment(\.defaultMinListRowHeight, 80)
      .toolbar {
        // There are no non-beta settings yet
        #if BETA
          ToolbarItem() {
            NavigationLink(destination: SettingsView()) {
              Label("Settings", systemImage: "gearshape")
            }
          }
        #endif

        ToolbarItem() {
          Button(action: { }) {
            Label("Add List", systemImage: "plus")
          }
        }

        ToolbarItem() {
          Menu {
            Button(action: { undoManager?.undo() }) {
              Label(
                "Undo \(undoManager?.undoActionName ?? "")",
                systemImage: "arrow.uturn.backward"
              )
            }
            .disabled(!(undoManager?.canUndo ?? false))
            
            Button(action: { undoManager?.redo() }) {
              Label(
                "Redo \(undoManager?.redoActionName ?? "")",
                systemImage: "arrow.uturn.forward"
              )
            }
            .disabled(!(undoManager?.canRedo ?? false))
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      
      VStack {
        Spacer()
        Text("Select a list")
        Spacer()
        Text("""
          Native macOS is not supported. Use the 'Designed for iPad' \
          version on Mac. This is a placeholder view for if a Native macOS \
          experience is built in the future.
          """)
        Spacer()
      }
      .frame(maxWidth: 300)
      .padding()
    }
  }
}

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewContainer {
      ListsViewMac()
    }
  }
}
