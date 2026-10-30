import SwiftUI

// MARK: - Colore di ogni categoria (usato per sfondo, prezzo, pulsanti e chip)
enum ColoreCategoria {
    static func colore(per categoria: String) -> Color {
        switch categoria {
        case "cpu":                                   return .indigo
        case "cpu-cooler", "case-fan", "fan-controller": return .cyan
        case "motherboard":                           return .teal
        case "video-card":                            return .green
        case "memory":                                return .orange
        case "internal-hard-drive", "external-hard-drive", "optical-drive": return .purple
        case "power-supply", "ups":                   return .yellow
        case "case", "case-accessory":                return .gray
        case "monitor":                               return .pink
        case "keyboard", "mouse", "headphones", "speakers", "webcam", "sound-card": return .red
        case "wired-network-card", "wireless-network-card": return .mint
        default:                                      return .blue
        }
    }
}

// MARK: - Sfondo sfumato (stesso stile della Home e di Crea la tua build)
struct SfondoSfumato: View {
    var colore: Color = .blue

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [colore.opacity(0.25), colore.opacity(0.0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 420)

            Circle()
                .fill(colore.opacity(0.30))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -100, y: -80)

            Circle()
                .fill(colore.opacity(0.20))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 130, y: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
    }
}

// MARK: - Pagina con la lista dei componenti di UNA categoria
struct Components: View {
    var titolo: String = "Componenti"
    var fonti: [Fonte] = RicercaView.tutte
    var alSelezionare: ((Risultato) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var testo: String = ""
    @State private var tutti: [Risultato] = []
    @State private var caricato = false
    @State private var ordine: OrdineRicerca = .nomeAZ
    private let massimo = 100

    // Se la pagina mostra una sola categoria, lo sfondo prende il suo colore
    private var colorePagina: Color {
        fonti.count == 1 ? ColoreCategoria.colore(per: fonti[0].categoria) : .blue
    }

    private func ordinaRisultati(_ dati: [Risultato]) -> [Risultato] {
        dati.sorted { r1, r2 in
            switch ordine {
            case .nomeAZ:
                return r1.nome.localizedCaseInsensitiveCompare(r2.nome) == .orderedAscending
            case .nomeZA:
                return r1.nome.localizedCaseInsensitiveCompare(r2.nome) == .orderedDescending
            case .prezzoCrescente:
                return (r1.prezzo ?? 0) < (r2.prezzo ?? 0)
            case .prezzoDecrescente:
                return (r1.prezzo ?? 0) > (r2.prezzo ?? 0)
            }
        }
    }

    var body: some View {
        let query = testo.trimmingCharacters(in: .whitespaces)
        let filtrati = query.isEmpty ? tutti : tutti.filter { $0.nome.localizedCaseInsensitiveContains(query) }
        let ordinati = ordinaRisultati(filtrati)
        let lista = Array(ordinati.prefix(massimo))

        ZStack {
            SfondoSfumato(colore: colorePagina)

            VStack(spacing: 10) {
                // Barra di ricerca e Filtro separati e affiancati
                HStack(spacing: 12) {
                    BarraRicerca(testo: $testo, placeholder: "Cerca in \(titolo)")
                    PulsanteFiltro(ordine: $ordine)
                }
                .padding(.horizontal)

                if caricato {
                    Text("\(filtrati.count) componenti")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                }

                Group {
                    if !caricato {
                        ProgressView("Caricamento...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if lista.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                            Text("Nessun risultato")
                                .font(.headline)
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(lista) { r in
                                    ProductView(
                                        nome: r.nome,
                                        prezzo: r.prezzo,
                                        details: r.dettagli,
                                        categoria: r.categoria,
                                        modello: r.modello,
                                        titoloBottone: "Aggiungi",
                                        onSelect: alSelezionare == nil ? nil : {
                                            alSelezionare?(r)
                                            dismiss()
                                        }
                                    )
                                }

                                if filtrati.count > massimo {
                                    Text("Mostrati i primi \(massimo) di \(filtrati.count): scrivi per restringere")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 8)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
        }
        .navigationTitle(titolo)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !caricato else { return }
            await Task.yield()
            tutti = caricaRisultati(da: fonti)
            caricato = true
        }
    }
}

// MARK: - Scheda di un prodotto
struct ProductView: View {
    @State private var isShowingDetails: Bool = false

    var nome: String
    var prezzo: Double?
    var details: [String: Any]
    var categoria: String? = nil
    var modello: (any Model)? = nil
    var titoloBottone: String = "Aggiungi"
    var onSelect: (() -> Void)? = nil

    private var accento: Color { ColoreCategoria.colore(per: categoria ?? "") }

    // Le prime caratteristiche utili, mostrate come "chip" sotto il nome
    private var chip: [String] {
        details.sorted { $0.key < $1.key }
            .map { "\(formattaValore($0.value))" }
            .filter { !$0.isEmpty && $0 != "N/D" && $0 != "N/A" }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Logo + nome + prezzo
            HStack(alignment: .center, spacing: 14) {
                if let categoria, let modello {
                    ComponenteImmagine(categoria: categoria, nome: nome, modello: modello, dimensione: 72)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(accento.opacity(0.25), lineWidth: 1.5)
                        )
                        .shadow(color: accento.opacity(0.15), radius: 6, y: 3)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(nome)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)

                    if let prezzo = prezzo {
                        Text(prezzo, format: .currency(code: "EUR"))
                            .font(.title3.bold())
                            .foregroundStyle(accento)
                    } else {
                        Text("Prezzo non disponibile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }

            // Caratteristiche principali
            if !chip.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chip, id: \.self) { testo in
                            Text(testo)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(accento)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(accento.opacity(0.12), in: Capsule())
                        }
                    }
                }
            }

            // Dettagli completi
            if isShowingDetails {
                VStack(spacing: 0) {
                    let righe = details.sorted(by: { $0.key < $1.key })
                    ForEach(Array(righe.enumerated()), id: \.element.key) { indice, riga in
                        HStack {
                            Text(riga.key)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(formattaValore(riga.value))
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        .padding(.vertical, 8)

                        if indice < righe.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Azioni
            HStack {
                if let onSelect = onSelect {
                    Button(action: onSelect) {
                        Label(titoloBottone, systemImage: "plus")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(accento.gradient, in: Capsule())
                            .shadow(color: accento.opacity(0.35), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        isShowingDetails.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isShowingDetails ? "Nascondi" : "Dettagli")
                        Image(systemName: isShowingDetails ? "chevron.up" : "chevron.down")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accento)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color.gray.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 12, y: 5)
    }
}

#Preview {
    NavigationStack {
        Components(titolo: "CPU", fonti: [Fonte("cpu.json", CPU.self)])
    }
}
