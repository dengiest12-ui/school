import SwiftUI

struct AppView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.content
                        .navigationTitle(tab.title)
                        .toolbarTitleDisplayMode(.inline)
                }
                .tabItem { tab.label }
                .tag(tab)
            }
        }
        .tint(SchoolTheme.accent)
    }
}

#Preview {
    AppView()
}

