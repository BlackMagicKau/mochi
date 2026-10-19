// Modified for Mochi: original mascot and matcha status card.
import SwiftUI

/// The block at the top of the status menu: the header and its explanation, what streams, and
/// one row per device. 300 pt wide, hosted in an NSMenuItem's view (StatusItemController).
struct StatusCard: View {
    let presentation: StatusPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                MochiMascot().frame(width: 47, height: 47)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mochi").font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text(presentation.header)
                        .font(.callout.weight(.medium))
                }
            }
            if let subtitle = presentation.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(MochiTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let source = presentation.source {
                StatusRow(row: source)
            }
            ForEach(presentation.devices) { StatusRow(row: $0) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 300, alignment: .leading)
        .background(MochiTheme.matcha, in: RoundedRectangle(cornerRadius: 13))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .mochiSurface()
    }
}

/// The card in the live menu. It re-renders as the model's presentation changes, including while
/// the menu is open (the menu's tracking loop still runs main-actor hops).
struct LiveStatusCard: View {
    let model: AppModel

    var body: some View {
        StatusCard(presentation: model.presentation)
    }
}

private struct StatusRow: View {
    let row: StatusPresentation.Row

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: row.symbol)
                .foregroundStyle(MochiTheme.muted)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(row.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let detail = row.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(MochiTheme.muted)
                        .monospacedDigit()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
