import SwiftUI

struct ImpostazioniView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("ignoreCompatibility") private var ignoreCompatibility = false
    @AppStorage("cameraSortingOption") private var cameraSortingOption = SortingOption.dateAdded.rawValue
    @AppStorage("filmPackSortingOption") private var filmPackSortingOption = SortingOption.dateAdded.rawValue
    @State private var showingDebugModal = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 1) {
                        // Sezione Compatibilità
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Ignore Camera-Film Compatibility")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $ignoreCompatibility)
                                    .labelsHidden()
                            }
                            
                            Text("When enabled, you can load any film type in any camera, bypassing compatibility checks.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Sezione Ordinamento Fotocamere
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Camera Sorting")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ForEach(SortingOption.allCases, id: \.self) { option in
                                HStack {
                                    Image(systemName: option.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text(option.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if cameraSortingOption == option.rawValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    cameraSortingOption = option.rawValue
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Sezione Ordinamento Film Pack
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Film Pack Sorting")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ForEach(SortingOption.allCases, id: \.self) { option in
                                HStack {
                                    Image(systemName: option.icon)
                                        .foregroundColor(.orange)
                                        .frame(width: 20)
                                    
                                    Text(option.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if filmPackSortingOption == option.rawValue {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.orange)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    filmPackSortingOption = option.rawValue
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Sezione Debug
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Debug")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            Text("Manage online data synchronization and local cache.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingDebugModal = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Sezione Versione
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Version")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("Alpha")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(Color(hex: "f4f4f4"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showingDebugModal) {
            DataSyncView()
        }
    }
}

#Preview {
    ImpostazioniView()
}
