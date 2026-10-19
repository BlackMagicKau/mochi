// Original Mochi artwork and theme, added for this fork.
import SwiftUI

enum MochiTheme {
    static let matcha = Color(red: 226 / 255, green: 235 / 255, blue: 206 / 255)
    static let cream = Color(red: 255 / 255, green: 251 / 255, blue: 238 / 255)
    static let tea = Color(red: 82 / 255, green: 109 / 255, blue: 57 / 255)
    static let ink = Color(red: 52 / 255, green: 69 / 255, blue: 42 / 255)
    static let muted = Color(red: 98 / 255, green: 107 / 255, blue: 86 / 255)
    static let warning = Color(red: 136 / 255, green: 81 / 255, blue: 38 / 255)
    static let blush = Color(red: 226 / 255, green: 159 / 255, blue: 139 / 255)
}

/// A1, the selected matcha dumpling. Decorative artwork adds no VoiceOver stop.
struct MochiMascot: View {
    // The local Mac package carries a PNG resource rather than an asset catalog.
    private static let artwork = Bundle.main.url(forResource: "MochiCharacter", withExtension: "png")
        .flatMap { NSImage(contentsOf: $0) }

    var body: some View {
        Group {
            if let artwork = Self.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

struct MochiHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 13) {
            MochiMascot().frame(width: 58, height: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 21, weight: .semibold, design: .rounded))
                Text(subtitle).font(.callout).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(MochiTheme.ink)
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MochiTheme.matcha)
    }
}

extension View {
    func mochiSurface() -> some View {
        self
            .tint(MochiTheme.tea)
            .foregroundStyle(MochiTheme.ink)
            .background(MochiTheme.cream)
            .environment(\.colorScheme, .light)
    }
}
