import SwiftUI

struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(_ title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal)
    }
}

struct DashboardCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(SchoolTheme.card, in: RoundedRectangle(cornerRadius: SchoolTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: SchoolTheme.cardRadius, style: .continuous)
                    .stroke(SchoolTheme.line, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

struct IconBadge: View {
    let systemName: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color)
            Image(systemName: systemName)
                .font(.system(size: size * 0.44, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

struct HeaderIconButton: View {
    let systemName: String
    var badgeColor: Color?
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .frame(width: 46, height: 46)
                    .background(SchoolTheme.card, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(SchoolTheme.line, lineWidth: 1)
                    }

                if let badgeColor {
                    Circle()
                        .fill(badgeColor)
                        .frame(width: 9, height: 9)
                        .offset(x: -6, y: 6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct InfoPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(color.opacity(0.10), in: Capsule())
    }
}

struct InitialAvatar: View {
    let text: String
    var color: Color = SchoolTheme.success
    var size: CGFloat = 58

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.88), color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 2)
            }
    }
}
