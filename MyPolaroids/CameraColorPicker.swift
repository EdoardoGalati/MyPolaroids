import SwiftUI

/// Horizontal row of the six camera colours from `Camera.coloriDisponibili`.
/// The selected one shows a checkmark and a 2pt primary ring. Each swatch is 44pt.
struct CameraColorPicker: View {
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Camera.coloriDisponibili, id: \.self) { colore in
                Button {
                    selection = colore
                } label: {
                    swatch(colore)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(accessibilityName(colore))
                .accessibilityAddTraits(selection == colore ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func swatch(_ colore: String) -> some View {
        let isSelected = selection == colore
        return ZStack {
            Circle()
                .fill(fill(colore))
                .frame(width: 34, height: 34)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(glyph(colore))
                    }
                }
            Circle()
                .stroke(Color.primary, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .animation(.snappy(duration: 0.2), value: selection)
    }

    private func isNeutral(_ colore: String) -> Bool {
        colore == "000" || colore.isEmpty
    }

    private func fill(_ colore: String) -> AnyShapeStyle {
        isNeutral(colore)
            ? AnyShapeStyle(Color.primary.gradient)
            : AnyShapeStyle(Camera.coloreDaNome(colore).gradient)
    }

    private func glyph(_ colore: String) -> Color {
        isNeutral(colore) ? Color(.systemBackground) : .white
    }

    private func accessibilityName(_ colore: String) -> String {
        switch colore {
        case "000": return "Black"
        case "D60027": return "Red"
        case "FF8200": return "Orange"
        case "FFB503": return "Yellow"
        case "78BE1F": return "Green"
        case "198CD9": return "Blue"
        default: return colore
        }
    }
}

#Preview {
    @Previewable @State var selection = "D60027"
    Form {
        Section("Color") {
            CameraColorPicker(selection: $selection)
        }
    }
}
