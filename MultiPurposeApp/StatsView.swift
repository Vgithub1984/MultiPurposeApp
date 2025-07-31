import SwiftUI

struct StatsView: View {
    let lists: [ListItem]
    let activeListCount: Int
    let totalItemsCount: Int
    let completedItemsCount: Int
    let overallCompletionRate: Double
    let listsWithItemsCount: Int
    let averageItemsPerList: Double
    let mostRecentList: ListItem?
    let listsCreatedThisWeek: Int
    let listsCreatedThisMonth: Int
    let deletedLists: [ListItem]

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

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Lists",
                        value: "\(lists.count)",
                        icon: "list.bullet.rectangle",
                        color: .blue
                    )

                    StatCard(
                        title: "Active Lists",
                        value: "\(activeListCount)",
                        icon: "checklist",
                        color: .green
                    )

                    StatCard(
                        title: "Total Items",
                        value: "\(totalItemsCount)",
                        icon: "square.and.pencil",
                        color: .orange
                    )

                    StatCard(
                        title: "Completed",
                        value: "\(completedItemsCount)",
                        icon: "checkmark.circle",
                        color: .purple
                    )
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

                if deletedLists.count > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Deleted Lists")
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            DeletedSummaryCard(count: deletedLists.count)
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
