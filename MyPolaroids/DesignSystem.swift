import SwiftUI

// Shared visual language for Instant Box.
//
// Direction (matches Flit and Stories for Letterboxd):
// - System navigation: native TabView + NavigationStack, system large titles.
// - Monochrome chrome: `.tint(.primary)` everywhere. Color appears only on
//   camera tiles and film swatches, never on buttons or text.
// - Liquid Glass on custom controls: `.glassEffect(.regular.interactive(), in: Capsule())`.
// - Rounded bold display text for empty states and hero titles.
// - Continuous corners. Side margin 20. Control heights 44 / 48 / 56.

enum DS {
    static let margin: CGFloat = 20
    static let cardRadius: CGFloat = 22
    static let tileRadius: CGFloat = 14
    static let settingsTileRadius: CGFloat = 8
}

// MARK: - Camera tile

/// Rounded square filled with the camera colour gradient and the camera glyph
/// (a custom symbol from the asset catalog or an SF Symbol).
struct CameraTile: View {
    let symbol: String
    let colorHex: String
    var size: CGFloat = 56

    @Environment(\.colorScheme) private var scheme

    private var isNeutral: Bool { colorHex == "000" || colorHex.isEmpty }

    private var fill: AnyShapeStyle {
        isNeutral
            ? AnyShapeStyle(Color.primary.gradient)
            : AnyShapeStyle(Camera.coloreDaNome(colorHex).gradient)
    }

    private var glyph: Color {
        isNeutral ? Color(.systemBackground) : .white
    }

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
            .fill(fill)
            .frame(width: size, height: size)
            .overlay {
                symbolImage
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(glyph)
            }
    }

    @ViewBuilder
    private var symbolImage: some View {
        if UIImage(named: symbol) != nil {
            Image(symbol)
        } else {
            Image(systemName: symbol.isEmpty ? "camera.fill" : symbol)
        }
    }
}

// MARK: - Shots

/// Eight (or N) little frames that show how many shots remain in a pack.
struct ShotFrames: View {
    let remaining: Int
    let total: Int
    var frameSize: CGFloat = 12

    var body: some View {
        HStack(spacing: frameSize * 0.35) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                RoundedRectangle(cornerRadius: frameSize * 0.22, style: .continuous)
                    .fill(index < remaining ? Color.primary : Color.primary.opacity(0.18))
                    .frame(width: frameSize, height: frameSize * 1.15)
            }
        }
        .accessibilityLabel("\(remaining) of \(total) shots left")
    }
}

/// Compact "5/8" capsule used in list rows.
struct ShotsBadge: View {
    let remaining: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Image("polaroid.film.symbols")
                .font(.system(size: 11, weight: .semibold))
            Text("\(remaining)/\(total)")
                .font(.footnote.weight(.semibold).monospacedDigit())
                .contentTransition(.numericText())
        }
        .foregroundStyle(remaining == 0 ? .secondary : .primary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.primary.opacity(0.08), in: Capsule(style: .continuous))
    }
}

// MARK: - Chips and labels

/// Small capsule label, e.g. a film format ("i-Type") or a status ("Expired").
struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var prominent = false

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(prominent ? Color(.systemBackground) : .primary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            prominent ? AnyShapeStyle(Color.primary) : AnyShapeStyle(Color.primary.opacity(0.08)),
            in: Capsule(style: .continuous)
        )
    }
}

/// Settings row label with a gradient tile, as in Stories and iOS Settings.
struct SettingsLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            RoundedRectangle(cornerRadius: DS.settingsTileRadius, style: .continuous)
                .fill(color.gradient)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: systemImage)
                        .symbolVariant(.fill)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
        }
    }
}

// MARK: - Empty state

/// ContentUnavailableView in the Flit style: rounded type and a glass CTA.
struct EmptyState: View {
    let title: String
    let message: String
    let image: String
    var isAsset = false
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                if isAsset {
                    Image(image)
                } else {
                    Image(systemName: image)
                }
            }
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.glassProminent)
                    .tint(.primary)
                    .controlSize(.large)
            }
        }
        .fontDesign(.rounded)
    }
}

// MARK: - Cards

/// Grouped content card used on detail screens.
struct Card<Content: View>: View {
    var title: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DS.cardRadius, style: .continuous))
    }
}

/// Key/value row inside a Card.
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

// MARK: - Buttons

extension View {
    /// 44pt round glass button for custom headers (same as Flit's headerButtonStyle).
    func glassCircleButton() -> some View {
        self
            .font(.system(size: 19, weight: .medium))
            .frame(width: 44, height: 44)
            .glassEffect(.regular.interactive(), in: Circle())
    }
}

/// Full-width primary action, 52pt capsule, glass tinted with the primary color.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color(.systemBackground))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .glassEffect(.regular.tint(.primary).interactive(), in: Capsule(style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// Full-width secondary action, 52pt plain glass capsule.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .glassEffect(.regular.interactive(), in: Capsule(style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primaryBox: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondaryBox: SecondaryButtonStyle { SecondaryButtonStyle() }
}

// MARK: - Backgrounds

extension View {
    /// Grouped background for detail screens built with ScrollView + Cards.
    func groupedScreenBackground() -> some View {
        self.background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Formatting

extension Date {
    var shortDisplay: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview("Components") {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            CameraTile(symbol: "polaroid.600.fill.symbols", colorHex: "D60027")
            CameraTile(symbol: "polaroid.sx70.fill.symbols", colorHex: "000")
            CameraTile(symbol: "polaroid.go.fill.symbols", colorHex: "198CD9", size: 44)
        }
        ShotFrames(remaining: 5, total: 8)
        ShotsBadge(remaining: 5, total: 8)
        HStack { Chip(text: "i-Type"); Chip(text: "Expired", systemImage: "clock", prominent: true) }
        Card(title: "Film") {
            InfoRow(label: "Format", value: "600")
            InfoRow(label: "Bought", value: Date().shortDisplay)
        }
        Button("Take a shot") {}.buttonStyle(.primaryBox)
        Button("Unload film") {}.buttonStyle(.secondaryBox)
    }
    .padding(DS.margin)
    .groupedScreenBackground()
}
