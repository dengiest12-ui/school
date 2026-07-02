import SwiftUI

struct AppView: View {
    @State private var selectedTab: AppTab

    init(initialTab: AppTab = AppView.launchTab()) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                selectedTab.content
            }

            SchoolTheme.page
                .frame(height: 96)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .tint(SchoolTheme.success)
        .preferredColorScheme(.light)
    }

    private static func launchTab() -> AppTab {
        let arguments = ProcessInfo.processInfo.arguments

        guard
            let tabArgumentIndex = arguments.firstIndex(of: "-qa-tab"),
            arguments.indices.contains(tabArgumentIndex + 1),
            let tab = AppTab(rawValue: arguments[tabArgumentIndex + 1])
        else {
            return .today
        }

        return tab
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 24, weight: .semibold))
                            .frame(height: 26)
                        Text(tab.title)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .foregroundStyle(selectedTab == tab ? SchoolTheme.success : SchoolTheme.graphite)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(SchoolTheme.tabBar, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 8)
    }
}

#Preview {
    AppView()
}
