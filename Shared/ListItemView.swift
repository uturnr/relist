//
//  ListItemView.swift
//  Shared
//
//  Created by uturnr on 2022-06-29.
//

import SwiftUI
import CoreData

struct ListItemView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var list: RoutineList
  
  init(list: RoutineList) {
    self.list = list
  }
  
  
  var body: some View {
    NavigationLink {
      TasksView(list: list)
        .environment(\.managedObjectContext, self.viewContext)
    } label: {
      HStack {
        Text(list.name)
        
        Spacer()
        
        if (list.taskCompletion > 0) {
          CircularProgressView(progress: list.taskCompletion)
            .frame(width: 15, height: 15)
            .padding(4)
        }
      }
    }
  }
}

struct ListItemView_Previews: PreviewProvider {
  // TODO: use mock data from Persistence.swift
  static let list = RoutineList(
    context: PersistenceController.preview.container.viewContext,
    name: "Test List",
    orderIndex: 0
  )
  
  static var previews: some View {
    let _ = RoutineTask(
      context: PersistenceController.preview.container.viewContext,
      list: list,
      name: "Test Task",
      orderIndex: 0
    )
    
    TasksView(list: list).environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
