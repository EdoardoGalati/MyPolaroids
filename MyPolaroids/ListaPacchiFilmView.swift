import SwiftUI
import Combine

struct ListaPacchiFilmView: View {
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var mostraAggiungiPacco = false
    @State private var mostraModificaPacco = false
    @State private var paccoDaModificare: FilmPack?
    @State private var animationTrigger = false
    @State private var nuovoPackId: UUID?
    @State private var mostraImpostazioni = false
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.pacchiFilm.isEmpty {
                    VStack(spacing: 16) {
                        Image("polaroid.film.symbols")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No film packs")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Add your first film pack to start.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { mostraAggiungiPacco = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Film Pack")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 50)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                } else {
                    // Pacchi in scadenza
                    if !viewModel.pacchiInScadenza.isEmpty {
                        Section("⚠️ In Scadenza") {
                            ForEach(viewModel.pacchiInScadenza) { pacco in
                                PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
                                    .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                    )
                            }
                        }
                    }
                    
                    // Pacchi disponibili
                    if !viewModel.pacchiDisponibili.isEmpty {
                        Section("📦 Disponibili") {
                            ForEach(viewModel.pacchiDisponibili) { pacco in
                                PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
                                    .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                    )
                            }
                        }
                    }
                    
                    // Pacchi associati
                    let pacchiAssociati = viewModel.pacchiFilmOrdinate.filter { pacco in
                        pacco.fotocameraAssociata != nil && !pacco.isFinito
                    }
                    if !pacchiAssociati.isEmpty {
                        Section("📷 In Uso") {
                            ForEach(pacchiAssociati) { pacco in
                                PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
                                    .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                    )
                            }
                        }
                    }
                    
                    // Pacchi finiti
                    if !viewModel.pacchiFiniti.isEmpty {
                        Section("✅ Completati") {
                            ForEach(viewModel.pacchiFiniti) { pacco in
                                PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
                                    .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                    )
                            }
                        }
                    }
                    
                    // Pacchi scaduti
                    if !viewModel.pacchiScaduti.isEmpty {
                        Section("❌ Scaduti") {
                            ForEach(viewModel.pacchiScaduti) { pacco in
                                PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
                                    .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 80)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationTrigger)
            .navigationTitle("Inventario Film")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { mostraImpostazioni = true }) {
                            Image(systemName: "gearshape")
                        }
                        
                        Button(action: {
                            mostraAggiungiPacco = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $mostraAggiungiPacco) {
                AggiungiPaccoFilmView(viewModel: viewModel, fotocamera: nil)
            }
            .sheet(isPresented: $mostraModificaPacco) {
                if let pacco = paccoDaModificare {
                    ModificaPaccoFilmView(
                        pacco: Binding(
                            get: { pacco },
                            set: { newValue in
                                viewModel.aggiornaPaccoFilm(newValue)
                            }
                        ),
                        viewModel: viewModel
                    )
                }
            }
            .sheet(isPresented: $mostraImpostazioni) {
                ImpostazioniView()
            }
            .onReceive(viewModel.$pacchiFilm) { pacchi in
                // Controlla se è stato aggiunto un nuovo pacco film
                if let ultimoPacco = pacchi.last, pacchi.count > 0 {
                    // Se è il primo pacco o se è una nuova aggiunta
                    if pacchi.count == 1 || !viewModel.pacchiFilm.contains(where: { $0.id == ultimoPacco.id }) {
                        nuovoPackId = ultimoPacco.id
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animationTrigger.toggle()
                        }
                        
                        // Reset dell'animazione dopo un delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                animationTrigger.toggle()
                            }
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // Forza l'aggiornamento quando cambiano le impostazioni di ordinamento
                DispatchQueue.main.async {
                    viewModel.objectWillChange.send()
                }
            }
        }
    }
}

struct PaccoFilmRowView: View {
    let pacco: FilmPack
    let viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var mostraModifica = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Informazioni principali
            VStack(alignment: .leading, spacing: 6) {
                Text("\(pacco.tipo) • \(pacco.modello)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let giorni = pacco.giorniAllaScadenza {
                    if pacco.isScaduto {
                        Text("Expired")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    } else if pacco.isScadenzaOggi {
                        Text("Expiring today")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else if giorni == 1 {
                        Text("Expires tomorrow")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else if pacco.isInScadenza {
                        Text("Expires in \(giorni) days")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else {
                        Text("Expires in \(giorni) days")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Label "In use" o numero di scatti rimanenti
            if pacco.fotocameraAssociata != nil {
                Text("In use (\(pacco.scattiRimanenti)/8)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.buttonText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                    )
                    
            } else {
                Text("\(pacco.scattiRimanenti)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            // Chevron per indicare che è modificabile
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            mostraModifica = true
        }
        .contextMenu {
            Button("View details") {
                // Azione per visualizzare dettagli
            }
        }
        .sheet(isPresented: $mostraModifica) {
            ModificaRapidaPaccoView(
                pacco: Binding(
                    get: { pacco },
                    set: { newValue in
                        // Aggiorna il pacco nel viewModel
                        viewModel.aggiornaPaccoFilm(newValue)
                    }
                ),
                viewModel: viewModel,
                selectedTab: $selectedTab
            )
        }
    }
}

#Preview {
    ListaPacchiFilmView(viewModel: FilmPackViewModel(), selectedTab: .constant(0))
}
