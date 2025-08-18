import SwiftUI

struct DettagliTipologiaView: View {
    let tipologia: TipologiaPaccoFilm
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var mostraModifica = false
    @State private var paccoDaModificare: FilmPack?
    @State private var mostraDeleteAlert = false
    @State private var paccoDaEliminare: FilmPack?
    @State private var animationTrigger = false
    @State private var nuovoPackId: UUID?
    @State private var mostraModificaRapida = false
    @State private var paccoDaModificareRapido: FilmPack?

    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenuto scrollabile (header incluso)
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    // Header con nome pack e cerchio del colore
                    headerSection
                    
                    // Lista dei pacchi
                    pacchiSection
                    
                    // Singoli film pack
                    if tipologia.conteggioTotale > 0 {
                        filmPacksListSection
                    }
                    
                    // Spazio per il bottone floating
                    Spacer(minLength: 120)
                }
            }
            
            // Bottone floating fisso in basso
            VStack {
                addPackSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96)) // #f4f4f4
        .navigationTitle("Film Pack Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostraModifica) {
            if let pacco = paccoDaModificare {
                ModificaPaccoFilmView(pacco: Binding(
                    get: { pacco },
                    set: { newValue in
                        viewModel.aggiornaPaccoFilm(newValue)
                    }
                ), viewModel: viewModel)
            }
        }
        .sheet(isPresented: $mostraModificaRapida) {
            if let pacco = paccoDaModificareRapido {
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

        .alert("Delete Film Pack", isPresented: $mostraDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let pacco = paccoDaEliminare {
                    // Salva le informazioni del tipo prima di eliminarlo
                    let tipoPacco = pacco.tipo
                    let modelliPacco = pacco.modello
                    
                    // Elimina il pacco
                    viewModel.rimuoviPaccoFilm(pacco)
                    
                    // Controlla se ci sono ancora pacchi dello stesso tipo e modello
                    let pacchiRimanenti = viewModel.pacchiFilm.filter { 
                        $0.tipo == tipoPacco && $0.modello == modelliPacco 
                    }
                    
                    // Se non ci sono più pacchi di questo tipo, torna alla home
                    if pacchiRimanenti.isEmpty {
                        selectedTab = 0
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this film pack? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Cerchio del colore del film
            FilmPackColorIndicator(
                tipo: tipologia.tipo,
                modello: tipologia.modello,
                modelliDisponibili: viewModel.modelliFilm,
                size: 80
            )
            
            // Nome del tipo
            Text("\(tipologia.tipo) • \(tipologia.modello)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 50)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.top, 20)
    }
    

    
    // MARK: - Pacchi Section
    private var pacchiSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Film Packs")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(tipologia.conteggioTotale)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            if tipologia.conteggioTotale == 0 {
                VStack(spacing: 12) {
                    Image(systemName: "film")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No film packs yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Film Packs List Section
    private var filmPacksListSection: some View {
        VStack(spacing: 1) {
            ForEach(pacchiOrdinati, id: \.id) { pacco in
                paccoRowView(for: pacco)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationTrigger)
        .onChange(of: animationTrigger) { newValue in
            print("🎨 [DettagliTipologiaView] animationTrigger cambiato: \(newValue)")
        }
    }
    
    private func paccoRowView(for pacco: FilmPack) -> some View {
        PaccoFilmRowView(pacco: pacco, viewModel: viewModel, selectedTab: $selectedTab)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .scaleEffect(pacco.id == nuovoPackId && animationTrigger ? 1.02 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(pacco.id == nuovoPackId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
            )
            .contextMenu {
                Button("Quick Edit") {
                    paccoDaModificareRapido = pacco
                    mostraModificaRapida = true
                }
                
                Button("Delete", role: .destructive) {
                    paccoDaEliminare = pacco
                    mostraDeleteAlert = true
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive) {
                    paccoDaEliminare = pacco
                    mostraDeleteAlert = true
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                paccoDaModificareRapido = pacco
                mostraModificaRapida = true
            }
    }
    
    // MARK: - Add Pack Section
    private var addPackSection: some View {
        VStack(spacing: 16) {
            Button(action: { aggiungiPaccoIdentico() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add Film Pack of This Type")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(16)
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Helper Properties
    private var pacchiOrdinati: [FilmPack] {
        let pacchi = viewModel.pacchiFilm.filter { pacco in
            pacco.tipo == tipologia.tipo && pacco.modello == tipologia.modello
        }
        
        return ordinaPacchi(pacchi)
    }
    
    private func ordinaPacchi(_ pacchi: [FilmPack]) -> [FilmPack] {
        return pacchi.sorted { first, second in
            let firstPriority = prioritaPacco(first)
            let secondPriority = prioritaPacco(second)
            
            if firstPriority != secondPriority {
                return firstPriority < secondPriority
            }
            
            return ordinaPerDataScadenza(first, second)
        }
    }
    
    private func ordinaPerDataScadenza(_ first: FilmPack, _ second: FilmPack) -> Bool {
        if let firstDate = first.dataScadenza, let secondDate = second.dataScadenza {
            return firstDate < secondDate
        }
        
        return first.id.uuidString < second.id.uuidString
    }
    
    private func prioritaPacco(_ pacco: FilmPack) -> Int {
        if pacco.scattiRimanenti == 0 { return 4 } // Completati
        if pacco.isScaduto { return 3 } // Scaduti
        if pacco.isInScadenza { return 2 } // In scadenza
        return 1 // Disponibili
    }
    
    // MARK: - Add Pack Function
    private func aggiungiPaccoIdentico() {
        print("🎬 [DettagliTipologiaView] Inizio aggiunta pack identico...")
        
        // Crea un nuovo pack con lo stesso tipo e modello
        let nuovoPacco = FilmPack(
            tipo: tipologia.tipo,
            modello: tipologia.modello,
            scattiTotali: 8, // Default per la maggior parte dei tipi
            dataAcquisto: Date(),
            dataScadenza: nil, // Nessuna data di scadenza automatica
            note: "Added from film pack details"
        )
        
        print("📦 [DettagliTipologiaView] Nuovo pack creato: \(nuovoPacco.tipo) • \(nuovoPacco.modello)")
        
        // Aggiungi il nuovo pack in cima alla lista con animazione
        print("🎭 [DettagliTipologiaView] Avvio animazione spring...")
        nuovoPackId = nuovoPacco.id
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            viewModel.aggiungiPaccoFilmInCima(nuovoPacco)
            animationTrigger.toggle()
            print("🔄 [DettagliTipologiaView] animationTrigger toggled: \(animationTrigger)")
        }
        
        // Scroll automatico verso il nuovo pack dopo un breve delay
        print("⏰ [DettagliTipologiaView] Pianificazione scroll automatico...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("🎯 [DettagliTipologiaView] Esecuzione scroll automatico...")
            withAnimation(.easeInOut(duration: 0.5)) {
                // Trigger per scroll automatico
                animationTrigger.toggle()
                print("🔄 [DettagliTipologiaView] animationTrigger toggled di nuovo: \(animationTrigger)")
            }
        }
        
        print("✅ [DettagliTipologiaView] Aggiunta pack completata!")
    }
}



#Preview {
    NavigationView {
        DettagliTipologiaView(
            tipologia: TipologiaPaccoFilm(
                tipo: "600",
                modello: "Color",
                pacchi: []
            ),
            viewModel: FilmPackViewModel(),
            selectedTab: .constant(0)
        )
    }
}
