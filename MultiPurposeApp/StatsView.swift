import SwiftUI

struct StatsView: View {
    let lists: [ListItem]
    let totalItemsCount: Int
    let completedItemsCount: Int
    let overallCompletionRate: Double
    let listsWithItemsCount: Int
    let averageItemsPerList: Double
    let mostRecentList: ListItem?
    let listsCreatedThisWeek: Int
    let listsCreatedThisMonth: Int
    let deletedLists: [ListItem]
    
    private var zeroItemCount: Int {
        lists.filter { list in
            let key = "items_\(list.id.uuidString)"
            if let data = UserDefaults.standard.data(forKey: key),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                let purchasedCount = items.filter { $0.purchased }.count
                return items.count == 0 && purchasedCount == 0
            }
            return true // treat as zero if no data
        }.count
    }
    
    private var completedListCount: Int {
        lists.filter { list in
            let key = "items_\(list.id.uuidString)"
            if let data = UserDefaults.standard.data(forKey: key),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                let purchasedCount = items.filter { $0.purchased }.count
                return items.count >= 1 && items.count == purchasedCount
            }
            return false
        }.count
    }
    
    private var activeListCount: Int {
        lists.filter { list in
            let key = "items_\(list.id.uuidString)"
            if let data = UserDefaults.standard.data(forKey: key),
               let items = try? JSONDecoder().decode([ListElement].self, from: data) {
                let purchasedCount = items.filter { $0.purchased }.count
                return items.count >= 1 && items.count != purchasedCount
            }
            return false
        }.count
    }
    
    private var totalListCount: Int {
        activeListCount + zeroItemCount + completedListCount + deletedLists.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                        .font(.title)
                        .bold()
                    Text("Your list management insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                VStack(spacing: 16) {
                    StatCard(
                        title: "Total Lists",
                        value: "\(totalListCount)",
                        icon: "list.bullet.rectangle",
                        color: .blue
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 5)

                    HStack(spacing: 10) {
                        StatCard(
                            title: "Active",
                            value: "\(activeListCount)",
                            icon: "checklist",
                            color: .blue
                        )
                        StatCard(
                            title: "Zero Item",
                            value: "\(zeroItemCount)",
                            icon: "list.bullet.rectangle",
                            color: .gray
                        )
                        StatCard(
                            title: "Completed",
                            value: "\(completedListCount)",
                            icon: "checkmark.circle",
                            color: .green
                        )
                        StatCard(
                            title: "Deleted",
                            value: "\(deletedLists.count)",
                            icon: "trash",
                            color: .red
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Progress Overview")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ProgressStatCard(
                            title: "Overall Completion",
                            value: overallCompletionRate,
                            subtitle: "\(completedItemsCount) of \(totalItemsCount) items",
                            color: .blue
                        )
                        if lists.count > 0 {
                            ProgressStatCard(
                                title: "Lists with Items",
                                value: Double(listsWithItemsCount) / Double(lists.count),
                                subtitle: "\(listsWithItemsCount) of \(lists.count) lists",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activity")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ActivityStatCard(
                            title: "This Week",
                            value: "\(listsCreatedThisWeek)",
                            subtitle: "lists created",
                            icon: "calendar.badge.clock",
                            color: .orange
                        )
                        ActivityStatCard(
                            title: "This Month",
                            value: "\(listsCreatedThisMonth)",
                            subtitle: "lists created",
                            icon: "calendar",
                            color: .purple
                        )
                        if lists.count > 0 {
                            ActivityStatCard(
                                title: "Average Items",
                                value: String(format: "%.1f", averageItemsPerList),
                                subtitle: "per list",
                                icon: "chart.bar",
                                color: .blue
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                if let recentList = mostRecentList {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Most Recent List")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            RecentListCard(list: recentList)
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer(minLength: 100)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

