import SwiftUI

struct ListItemsView: View {
    let list: ListItem
    @Environment(\.dismiss) private var dismiss

    @State private var items: [ListElement] = []
    @State private var newItem: String = ""
    @FocusState private var isInputFocused: Bool

    // Sorted items alphabetically by name
    private var sortedItems: [ListElement] {
        items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var purchasedCount: Int {
        sortedItems.filter { $0.purchased }.count
    }

    private var purchasedPercentage: Double {
        let totalCount = sortedItems.count
        return totalCount == 0 ? 0 : Double(purchasedCount) / Double(totalCount)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 10) {
                    
                    VStack(alignment: .leading) {
                        Text(list.name)
                            .font(.largeTitle)
                            .bold()
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(list.createdAt, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(list.createdAt, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    // Progress Bar
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Total Item: \(sortedItems.count)")
                                .font(.caption)
                                .padding(.bottom, -4)
                            Spacer()
                            Text("Purchased: \(purchasedCount)")
                                .font(.caption)
                                .padding(.bottom, -4)
                        }
                        .padding(.trailing, 5)
                        
                        HStack {
                            ProgressView(value: purchasedPercentage)
                                .progressViewStyle(.linear)
                            Text("\(Int(purchasedPercentage * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    
                    }
                    .padding(.top, 2)

                    // Input field
                    HStack {
                        TextField("Add an item", text: $newItem)
                            .onSubmit { addItem() }
                            .focused($isInputFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.sentences)
                            .disableAutocorrection(false)
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.vertical, 4)
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isInputFocused = true } }

                    // Items list
                    ScrollViewWithBlur(blurRadius: 6, blurThreshold: 40) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                                HStack(alignment: .center, spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .stroke(item.purchased ? Color.appSuccess : Color.appSecondaryText, lineWidth: 2)
                                            .frame(width: 28, height: 28)
                                        Text("\(index+1)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.leading, 8)
                                    Text(item.name)
                                        .strikethrough(item.purchased)
                                        .foregroundColor(item.purchased ? Color.appSecondaryText : Color.appPrimaryText)
                                    Spacer()
                                    Button(action: { deleteItem(with: item.id) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(Color.appError)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    togglePurchased(for: item)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                        }
                    }
                }
            }
        }
        .onAppear {
            loadItems()
            DispatchQueue.main.async {
                isInputFocused = true
            }
        }
    }

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(ListElement(name: trimmed), at: 0)
        newItem = ""
        DispatchQueue.main.async {
            isInputFocused = true
        }
        saveItems()
    }

    private func togglePurchased(for item: ListElement) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].purchased.toggle()
            saveItems()
        }
    }
    
    private func deleteItem(with id: UUID) {
        items.removeAll { $0.id == id }
        saveItems()
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "items_\(list.id.uuidString)") else {
            items = []
            return
        }
        if let decoded = try? JSONDecoder().decode([ListElement].self, from: data) {
            items = decoded
        } else {
            items = []
        }
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items_\(list.id.uuidString)")
        }
    }
}

#Preview {
    ListItemsView(list: ListItem(name: "Groceries"))
}
