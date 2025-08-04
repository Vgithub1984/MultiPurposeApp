import SwiftUI

struct DeletedView: View {
    @Binding var deletedLists: [ListItem]
    let sortedDeletedLists: [ListItem]
    var listsNeedRefresh: Bool
    var onRestore: (ListItem) -> Void
    var onDeleteForever: (ListItem) -> Void

    var body: some View {
        VStack(spacing: 20) {
            if deletedLists.isEmpty {
                Spacer()
                VStack(spacing: 5) {
                    Label("Deleted Lists", systemImage: "trash")
                        .font(.title)
                        .bold()
                        .foregroundColor(.red)
                    Text("No deleted lists!")
                        .foregroundColor(.secondary)
                    Text("Deleted lists will appear here")
                        .foregroundColor(.secondary)
                    Text("")
                    Text("")
                    Text("Gestures:")
                        .font(.title)
                        .bold()
                    Label("Swipe Left to Delete List", systemImage: "arrow.backward.square")
                        .foregroundColor(.secondary)
                    Label("Swipe Right to Restore List", systemImage: "arrow.forward.square")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                VStack {
                    List(sortedDeletedLists) { list in
                        ListCardView(list: list, refreshKey: listsNeedRefresh)
                            .swipeActions(edge: .leading) {
                                Button {
                                    onRestore(list)
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.left")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    onDeleteForever(list)
                                } label: {
                                    Label("Delete Forever", systemImage: "trash.fill")
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
