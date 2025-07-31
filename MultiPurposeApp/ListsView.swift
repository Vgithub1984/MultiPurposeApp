import SwiftUI

struct ListsView: View {
    @Binding var lists: [ListItem]
    let sortedLists: [ListItem]
    var listsNeedRefresh: Bool
    var onListTap: (ListItem) -> Void
    var onDelete: (ListItem) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if lists.isEmpty {
                Spacer()
                VStack(spacing: 5) {
                    Label("Lists", systemImage: "list.bullet.rectangle")
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                    Text("List is empty !")
                        .foregroundColor(.secondary)
                    Text("Add a new list using + button !")
                        .foregroundColor(.secondary)
                    Text("")
                    Text("")
                    Text("Gestures:")
                        .font(.title)
                        .bold()
                    Label("Swipe Left to Delete List", systemImage: "arrow.backward.square")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                VStack {
                    List(sortedLists) { list in
                        ListCardView(list: list, refreshKey: listsNeedRefresh)
                            .onTapGesture {
                                onListTap(list)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    onDelete(list)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .environment(\.defaultMinListRowHeight, 60)
                    .environment(\.defaultMinListHeaderHeight, 0)
                    .id(listsNeedRefresh)
                }
            }
        }
    }
}
