import SwiftUI

struct CustomAppIconsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var iconManager = CustomAppIconManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Custom App Icons")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose the icon you prefer for your app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(AppColors.backgroundSecondary)
                
                // Grid delle icone
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        // Icona Default
                        CustomAppIconCard(
                            icon: CustomAppIcon(
                                name: "Default", 
                                displayIconName: "", 
                                alternateIconName: "", 
                                isPremium: false, 
                                isUnlocked: true
                            ),
                            isSelected: iconManager.selectedIconName == nil,
                            onTap: {
                                iconManager.resetToDefaultIcon()
                            }
                        )
                        
                        // Icone custom
                        ForEach(iconManager.customIcons) { icon in
                            CustomAppIconCard(
                                icon: icon,
                                isSelected: iconManager.selectedIconName == icon.alternateIconName,
                                onTap: {
                                    print("🎯 [CustomAppIconsView] Icona selezionata: \(icon.name) (\(icon.alternateIconName))")
                                    iconManager.changeAppIcon(to: icon.alternateIconName)
                                }
                            )
                            .onAppear {
                                print("🔍 [CustomAppIconsView] Icona caricata: \(icon.name)")
                                print("   - displayIconName: \(icon.displayIconName)")
                                print("   - alternateIconName: \(icon.alternateIconName)")
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CustomAppIconCard: View {
    let icon: CustomAppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon preview
                if icon.displayIconName.isEmpty {
                    // Default icon
                    Image(systemName: "app.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.primary)
                } else {
                    // Custom icon
                    Image(icon.displayIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .onAppear {
                            print("🖼️ [CustomAppIconCard] Caricamento icona: \(icon.displayIconName)")
                        }
                }
                
                Text(icon.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.accentPrimary)
                        .font(.title3)
                }
            }
            .padding()
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.accentPrimary.opacity(0.1) : AppColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? AppColors.accentPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CustomAppIconsView()
}

