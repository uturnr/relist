import SwiftUI
import CoreData

struct ListItemView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @ObservedObject var list: RoutineList

  var editList: () -> Void

  init(
    list: RoutineList,
    editList: @escaping () -> Void
  ) {
    self.list = list
    self.editList = editList
  }


  var body: some View {
    NavigationLink {
      TasksView(list: list)
        .environment(\.managedObjectContext, self.viewContext)
    } label: {
      HStack {
        Text(list.name)
          .accessibilityIdentifier(list.name)

        Spacer()

        if (list.taskCompletion > 0) {
          CircularProgressView(progress: list.taskCompletion)
            .frame(width: 15, height: 15)
            .padding(4)
        }
      }
    }
    .contextMenu {
      Button(action: editList) {
        Label("Edit", systemImage: "pencil")
      }
      .accessibilityIdentifier("editList")

      Button(role: .destructive, action: {
        ListsService.deleteLists([list])
      }) {
        Label("Delete", systemImage: "trash")
      }
    }
  }
}

/// Entire list previewed for a more accurate preview.
struct ListItemView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewContainer {
      ListsView()
    }
  }
}
