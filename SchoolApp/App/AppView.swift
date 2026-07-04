import SwiftUI

struct AppView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingVersion") private var onboardingVersion = 0
    @AppStorage("currentUserRole") private var currentUserRoleRaw = AppUserRole.parent.rawValue
    @State private var selectedTab: AppTab
    @State private var completedForcedOnboarding = false

    init(initialTab: AppTab = AppView.launchTab()) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        Group {
            if showsOnboarding {
                OnboardingView(onFinish: completeOnboarding)
            } else {
                mainApp
            }
        }
        .onAppear(perform: resetOnboardingIfNeeded)
        .tint(SchoolTheme.success)
        .preferredColorScheme(.light)
    }

    private var mainApp: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                activeTab.content(userRole: currentUserRole)
            }

            SchoolTheme.page
                .frame(height: 96)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

            CustomTabBar(selectedTab: $selectedTab, tabs: visibleTabs)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear(perform: normalizeSelectedTab)
        .onChange(of: currentUserRole.rawValue) { _, _ in
            normalizeSelectedTab()
        }
    }

    private var showsOnboarding: Bool {
        if Self.forcesOnboarding {
            return !completedForcedOnboarding
        }

        return (!hasCompletedOnboarding || onboardingVersion < Self.requiredOnboardingVersion) && !Self.skipsOnboarding
    }

    private var currentUserRole: AppUserRole {
        if let launchRole = Self.launchRole {
            return launchRole
        }

        return AppUserRole(rawValue: currentUserRoleRaw) ?? .parent
    }

    private var visibleTabs: [AppTab] {
        AppTab.visibleTabs(for: currentUserRole)
    }

    private var activeTab: AppTab {
        visibleTabs.contains(selectedTab) ? selectedTab : visibleTabs[0]
    }

    private func completeOnboarding(role: AppUserRole) {
        hasCompletedOnboarding = true
        onboardingVersion = Self.requiredOnboardingVersion
        currentUserRoleRaw = role.rawValue
        completedForcedOnboarding = true
    }

    private func resetOnboardingIfNeeded() {
        guard Self.resetsOnboarding else {
            return
        }

        hasCompletedOnboarding = false
        onboardingVersion = 0
        currentUserRoleRaw = AppUserRole.parent.rawValue
        completedForcedOnboarding = false
    }

    private func normalizeSelectedTab() {
        guard !visibleTabs.contains(selectedTab) else {
            return
        }

        selectedTab = visibleTabs[0]
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

    private static var forcesOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding")
    }

    private static var skipsOnboarding: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("-qa-skip-onboarding") || arguments.contains("-qa-tab")
    }

    private static var resetsOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-reset-onboarding")
    }

    private static var launchRole: AppUserRole? {
        let arguments = ProcessInfo.processInfo.arguments

        guard
            let roleArgumentIndex = arguments.firstIndex(of: "-qa-role"),
            arguments.indices.contains(roleArgumentIndex + 1)
        else {
            return nil
        }

        return AppUserRole(rawValue: arguments[roleArgumentIndex + 1])
    }

    private static let requiredOnboardingVersion = 3
}

private struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    let tabs: [AppTab]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
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
                .accessibilityIdentifier("tab.\(tab.rawValue)")
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
