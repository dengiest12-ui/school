import SwiftUI

struct AppView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingVersion") private var onboardingVersion = 0
    @AppStorage("currentUserRole") private var currentUserRoleRaw = AppUserRole.parent.rawValue
    @State private var selectedTab: AppTab
    @State private var completedForcedOnboarding = false
    @State private var completedChildrenReset = false
    @State private var completedSupabaseBridgeSeed = false
    @State private var completedSupabaseChildBridgeSeed = false
    @State private var completedSupabaseAnnouncementBridgeSeed = false
    @State private var completedSupabaseHomeworkBridgeSeed = false
    @State private var completedSupabaseCalendarEventBridgeSeed = false
    @State private var completedSupabaseCollectionBridgeSeed = false
    @State private var completedSupabasePhotoBridgeSeed = false

    init(initialTab: AppTab = AppView.launchTab()) {
        if Self.resetsChildren {
            AppChildStore.clear()
        }
        if Self.seedsSupabaseBridge {
            AppSupabaseClassContextBridge.seedSmokeContext()
        }
        if Self.seedsSupabaseChildBridge {
            AppSupabaseChildContextBridge.seedSmokeContext()
        }
        if Self.seedsSupabaseAnnouncementBridge {
            AppSupabaseAnnouncementBridge.seedSmokeAnnouncements()
        }
        if Self.seedsSupabaseHomeworkBridge {
            AppSupabaseHomeworkBridge.seedSmokeHomework()
        }
        if Self.seedsSupabaseCalendarEventBridge {
            AppSupabaseCalendarEventBridge.seedSmokeEvents()
        }
        if Self.seedsSupabaseCollectionBridge {
            AppSupabaseCollectionBridge.seedSmokeCollections()
        }
        if Self.seedsSupabasePhotoBridge {
            AppSupabasePhotoBridge.seedSmokePhotos()
        }
        if Self.usesSupabaseChildSourcePreview {
            AppChildStore.usesSupabaseChildSourcePreview = true
        }
        _selectedTab = State(initialValue: initialTab)
        _completedChildrenReset = State(initialValue: Self.resetsChildren)
        _completedSupabaseBridgeSeed = State(initialValue: Self.seedsSupabaseBridge)
        _completedSupabaseChildBridgeSeed = State(initialValue: Self.seedsSupabaseChildBridge)
        _completedSupabaseAnnouncementBridgeSeed = State(initialValue: Self.seedsSupabaseAnnouncementBridge)
        _completedSupabaseHomeworkBridgeSeed = State(initialValue: Self.seedsSupabaseHomeworkBridge)
        _completedSupabaseCalendarEventBridgeSeed = State(initialValue: Self.seedsSupabaseCalendarEventBridge)
        _completedSupabaseCollectionBridgeSeed = State(initialValue: Self.seedsSupabaseCollectionBridge)
        _completedSupabasePhotoBridgeSeed = State(initialValue: Self.seedsSupabasePhotoBridge)
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
        .onAppear(perform: resetChildrenIfNeeded)
        .onAppear(perform: seedSupabaseBridgeIfNeeded)
        .onAppear(perform: seedSupabaseChildBridgeIfNeeded)
        .onAppear(perform: seedSupabaseAnnouncementBridgeIfNeeded)
        .onAppear(perform: seedSupabaseHomeworkBridgeIfNeeded)
        .onAppear(perform: seedSupabaseCalendarEventBridgeIfNeeded)
        .onAppear(perform: seedSupabaseCollectionBridgeIfNeeded)
        .onAppear(perform: seedSupabasePhotoBridgeIfNeeded)
        .onAppear(perform: enableSupabaseChildSourcePreviewIfNeeded)
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

    private func resetChildrenIfNeeded() {
        guard Self.resetsChildren, !completedChildrenReset else {
            return
        }

        AppChildStore.clear()
        completedChildrenReset = true
    }

    private func seedSupabaseBridgeIfNeeded() {
        guard Self.seedsSupabaseBridge, !completedSupabaseBridgeSeed else {
            return
        }

        AppSupabaseClassContextBridge.seedSmokeContext()
        completedSupabaseBridgeSeed = true
    }

    private func seedSupabaseChildBridgeIfNeeded() {
        guard Self.seedsSupabaseChildBridge, !completedSupabaseChildBridgeSeed else {
            return
        }

        AppSupabaseChildContextBridge.seedSmokeContext()
        completedSupabaseChildBridgeSeed = true
    }

    private func seedSupabaseAnnouncementBridgeIfNeeded() {
        guard Self.seedsSupabaseAnnouncementBridge, !completedSupabaseAnnouncementBridgeSeed else {
            return
        }

        AppSupabaseAnnouncementBridge.seedSmokeAnnouncements()
        completedSupabaseAnnouncementBridgeSeed = true
    }

    private func seedSupabaseHomeworkBridgeIfNeeded() {
        guard Self.seedsSupabaseHomeworkBridge, !completedSupabaseHomeworkBridgeSeed else {
            return
        }

        AppSupabaseHomeworkBridge.seedSmokeHomework()
        completedSupabaseHomeworkBridgeSeed = true
    }

    private func seedSupabaseCalendarEventBridgeIfNeeded() {
        guard Self.seedsSupabaseCalendarEventBridge, !completedSupabaseCalendarEventBridgeSeed else {
            return
        }

        AppSupabaseCalendarEventBridge.seedSmokeEvents()
        completedSupabaseCalendarEventBridgeSeed = true
    }

    private func seedSupabaseCollectionBridgeIfNeeded() {
        guard Self.seedsSupabaseCollectionBridge, !completedSupabaseCollectionBridgeSeed else {
            return
        }

        AppSupabaseCollectionBridge.seedSmokeCollections()
        completedSupabaseCollectionBridgeSeed = true
    }

    private func seedSupabasePhotoBridgeIfNeeded() {
        guard Self.seedsSupabasePhotoBridge, !completedSupabasePhotoBridgeSeed else {
            return
        }

        AppSupabasePhotoBridge.seedSmokePhotos()
        completedSupabasePhotoBridgeSeed = true
    }

    private func enableSupabaseChildSourcePreviewIfNeeded() {
        guard Self.usesSupabaseChildSourcePreview else {
            return
        }

        AppChildStore.usesSupabaseChildSourcePreview = true
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

    private static var resetsChildren: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-reset-children-store")
    }

    private static var seedsSupabaseBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-class-bridge")
    }

    private static var seedsSupabaseChildBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-child-bridge")
    }

    private static var seedsSupabaseAnnouncementBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-announcement-bridge")
    }

    private static var seedsSupabaseHomeworkBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-homework-bridge")
    }

    private static var seedsSupabaseCalendarEventBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-calendar-event-bridge")
    }

    private static var seedsSupabaseCollectionBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-collection-bridge")
    }

    private static var seedsSupabasePhotoBridge: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-seed-supabase-photo-bridge")
    }

    private static var usesSupabaseChildSourcePreview: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-use-supabase-child-source")
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
