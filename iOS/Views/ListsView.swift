import SwiftUI
import CoreData

struct ListsView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State var editMode: EditMode = .inactive
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
          ListItemView(
            list: list,
            editList: { showEditList(list) }
          )
        }
        .onDelete { indexSet in
          let listsToDelete = indexSet.map { lists[$0] }
          ListsService.deleteLists(listsToDelete)
        }
      }
      .accessibilityIdentifier("Sidebar")
      .animation(.default, value: isEditing)
      .navigationTitle(isEditing ? "Editing Lists" : "Lists")
      .environment(\.defaultMinListRowHeight, 80)
      #if os(iOS)
      .environment(\.editMode, $editMode)
      #endif
      .onChange(of: isEditing) { isEditing in
        withAnimation {
          editMode = isEditing ? .active : .inactive
        }
      }
      .toolbar {
        // There are no non-beta settings yet
        #if BETA
          ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink(destination: SettingsView()) {
              Label("Settings", systemImage: "gearshape")
            }
          }
        #endif

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: showAddList) {
            Label("Add List", systemImage: "plus")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          VStack {
            if isEditing {
              Button(action: { isEditing.toggle() }) {
                Text("Done")
              }
              .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
              Menu {
                #if os(iOS)
                  Button(action: { isEditing.toggle() }) {
                    Label("Edit Lists", systemImage: "pencil")
                  }
                #endif

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
              .transition(.move(edge: .leading).combined(with: .opacity))
            }
          }
          .animation(.snappy, value: isEditing)
        }
      }

      Text("Select a list")
    }
    .sheet(item: $editedList) { editedList in
      if editedList.isNew {
        ListEditorView(list: nil)
      } else {
        ListEditorView(list: lists.first(where: { $0.id == editedList.listId }))
      }
    }
    .onAppear {
      print("Environment undo manager: \(String(describing: undoManager))")
      print("ViewContext undo manager: \(String(describing: viewContext.undoManager))")
      print("Are they the same? \(undoManager === viewContext.undoManager)")
    }
  }

  private func showAddList() {
    editedList = EditedList(isNew: true)
  }

  private func showEditList(_ list: RoutineList) {
    editedList = EditedList(listId: list.id)
  }
}

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewContainer {
      ListsView()
    }
  }
}
