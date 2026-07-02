import SwiftUI

struct HomeworkView: View {
    @State private var selectedScope: HomeworkScope = .tomorrow

    var body: some View {
        List {
            Section {
                Picker("Период", selection: $selectedScope) {
                    ForEach(HomeworkScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Задания") {
                ForEach(SampleData.homework) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.subject)
                                .font(.headline)
                            Spacer()
                            StatusBadge(text: item.status.rawValue, color: badgeColor(for: item.status))
                        }
                        Text(item.title)
                            .font(.subheadline)
                        HStack {
                            Label(item.dueLabel, systemImage: "clock")
                            Label(item.source, systemImage: "person.crop.circle")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        if let bring = item.bring {
                            Label("Принести: \(bring)", systemImage: "shippingbox")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.warning)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "camera.viewfinder")
                }
                .accessibilityLabel("Сфотографировать ДЗ")

                Button {
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Добавить ДЗ")
            }
        }
    }

    private func badgeColor(for status: HomeworkItem.Status) -> Color {
        switch status {
        case .pending:
            SchoolTheme.warning
        case .done:
            SchoolTheme.success
        case .review:
            SchoolTheme.accent
        }
    }
}

private enum HomeworkScope: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    case week
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            "Сегодня"
        case .tomorrow:
            "Завтра"
        case .week:
            "Неделя"
        case .done:
            "Готово"
        }
    }
}

#Preview {
    NavigationStack {
        HomeworkView()
            .navigationTitle("ДЗ")
    }
}

