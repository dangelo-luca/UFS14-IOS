import SwiftUI

struct ComponentePC: Identifiable {
    let id = UUID()
    let nome: String
    let immagine: String
    var colore: Color = .gray
    var fonti: [Fonte] = []
    var maxQuantita: Int = 1

    // Colore della modalità "colorata": lo stesso della pagina della categoria
    // (vedi ColoreCategoria in Components.swift)
    var coloreVivace: Color {
        fonti.count == 1 ? ColoreCategoria.colore(per: fonti[0].categoria) : .blue
    }
}

struct SelectedPart {
    let name: String
    let price: Double
}

struct BuildPcView: View {
    @Environment(BuildManager.self) private var buildManager
    var onSalvato: () -> Void = {}   // <- nuova
    @State private var mostraNomeBuild = false
    @State private var nomeBuild = ""
    @State private var apriDettaglio = false
    @State private var componenteSelezionato: ComponentePC?
    @State var testo: String = ""
    @State var risultati: [Risultato] = []
    @State private var scelti: [String: Selezione] = [:]
    @State private var colorato = false   // false = tutte blu (come prima), true = un colore per sezione

    private var total: Double {
        scelti.values.map(\.subtotale).reduce(0, +)
    }
    
    private var progress: Double {
        guard !componenti.isEmpty else { return 0 }
        return Double(scelti.count) / Double(componenti.count)
    }
    
    let componenti: [ComponentePC] = [
        ComponentePC(nome: "CPU", immagine: "cpu", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("cpu.json"),maxQuantita: 1),
        ComponentePC(nome: "CPU Cooler", immagine: "fan", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("cpu-cooler.json"),maxQuantita: 1),
        ComponentePC(nome: "Motherboard", immagine: "rectangle.3.group", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("motherboard.json"),maxQuantita: 1),
        ComponentePC(nome: "GPU", immagine: "display", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("video-card.json"),maxQuantita: 4),
        ComponentePC(nome: "RAM", immagine: "memorychip", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("memory.json"),maxQuantita: 4),
        ComponentePC(nome: "Power Supply", immagine: "powerplug.fill", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("power-supply.json"),maxQuantita: 1),
        ComponentePC(nome: "Storage", immagine: "internaldrive", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("internal-hard-drive.json"),maxQuantita: 10),
        ComponentePC(nome: "Case", immagine: "macpro.gen3", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("case.json"),maxQuantita: 1),
        ComponentePC(nome: "OS", immagine: "gearshape.2", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("os.json"),maxQuantita: 1),
        ComponentePC(nome: "Sound Card", immagine: "waveform", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("sound-card.json"),maxQuantita: 1),
        ComponentePC(nome: "Network Card", immagine: "wifi", colore: .blue.opacity(0.8), fonti: RicercaView.fonti("wireless-network-card.json"),maxQuantita: 1)
    ]
    
    var body: some View {
        // Rimosso NavigationStack da qui
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(componenti) { comp in
                    ComponentCardView(
                        componente: comp,
                        scelto: scelti[comp.nome],
                        colorato: colorato,
                        onQuantita: { scelti[comp.nome]?.quantita = $0 }
                    ) {
                        componenteSelezionato = comp
                        apriDettaglio = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            PriceHeader(
                count: scelti.count,
                total: componenti.count,
                price: total,
                progress: progress
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.bar)
        }
        .navigationTitle("Crea la tua build")
        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // In alto a sinistra: pulsante che accende/spegne i colori delle sezioni.
                // (Il "Indietro" non serve: questa è la radice dello stack.)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            colorato.toggle()
                        }
                    } label: {
                        Image(systemName: colorato ? "paintpalette.fill" : "paintpalette")
                            .foregroundStyle(colorato ? Color.pink : Color.primary)
                    }
                    .accessibilityLabel(colorato ? "Colori sezioni attivi" : "Colora le sezioni")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salva") {
                        nomeBuild = ""
                        mostraNomeBuild = true
                        
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.pink)
                    .controlSize(.small)
                    .disabled(scelti.isEmpty)
                    .alert("Nome della build", isPresented: $mostraNomeBuild) {
                        TextField("Build #\(buildManager.savedBuilds.count + 1)", text: $nomeBuild)
                            .textInputAutocapitalization(.words)

                        Button("Annulla", role: .cancel) { }

                        Button("Salva") {
                            let nome = nomeBuild.trimmingCharacters(in: .whitespacesAndNewlines)
                            buildManager.aggiungiBuild(scelti: scelti, nomeCustom: nome)
                            scelti = [:]
                            onSalvato()
                        }
                    } message: {
                        Text("Scegli un nome per riconoscerla tra le build salvate.")
                    }
                }
            }
        .navigationDestination(isPresented: $apriDettaglio) {
            if let comp = componenteSelezionato {
                Components(titolo: comp.nome, fonti: comp.fonti) { r in
                    let quantita = scelti[comp.nome]?.quantita ?? 1
                    scelti[comp.nome] = Selezione(risultato: r, quantita: quantita)
                }
            }
        }
    }
}

struct ComponentCardView: View {
    let componente: ComponentePC
    var scelto: Selezione? = nil
    var colorato: Bool = false          // false = blu come prima, true = colore della sezione
    var onQuantita: (Int) -> Void = { _ in }
    let action: () -> Void

    // Il giallo con testo bianco si legge male: in quel caso testo scuro
    private var coloreTesto: Color {
        colorato && componente.coloreVivace == .yellow ? Color.black.opacity(0.8) : .white
    }

    var body: some View {
        VStack(spacing: 12) {
            Button(action: action) {
                HStack(spacing: 26) {
                    Image(systemName: componente.immagine)
                        .font(.system(size: 32))
                        .foregroundColor(coloreTesto)
                        .frame(width: 70, height: 70)
                        .background(colorato ? coloreTesto.opacity(0.18) : Color.cyan.opacity(0.9))
                        .cornerRadius(100)

                    VStack(spacing: 6) {
                        Text(componente.nome)
                            .font(.title)
                            .bold()

                        Text(scelto?.risultato.nome ?? "Seleziona il componente")
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let scelto, componente.maxQuantita > 1 {
                Stepper(
                    value: Binding(get: { scelto.quantita }, set: onQuantita),
                    in: 1...componente.maxQuantita
                ) {
                    Text("Quantità: \(scelto.quantita)")
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundColor(coloreTesto)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorato ? componente.coloreVivace.opacity(0.85) : componente.colore)
        )
    }
}

struct PriceHeader: View {
    let count: Int
    let total: Int
    let price: Double
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Totale stimato")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(price, format: .currency(code: "EUR"))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                }
                Spacer()
                Text("\(count)/\(total)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.pink.opacity(0.12), in: Capsule())
                    .foregroundStyle(.pink)
            }

            ProgressView(value: progress)
                .tint(.pink)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
                .animation(.spring, value: progress)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}

#Preview {
    NavigationStack {
        BuildPcView()
    }
    .environment(BuildManager())
}
