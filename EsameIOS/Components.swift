import SwiftUI

// MARK: - Sfondo sfumato (stesso stile della Home e di Crea la tua build)
struct SfondoSfumato: View {
    var colore: Color = .blue

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [colore.opacity(0.45), colore.opacity(0.0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 420)

            Circle()
                .fill(colore.opacity(0.45))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -100, y: -80)

            Circle()
                .fill(colore.opacity(0.35))
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
            SfondoSfumato()

            VStack(spacing: 12) {
                // Barra di ricerca e Filtro separati e affiancati
                HStack(spacing: 12) {
                    BarraRicerca(testo: $testo, placeholder: "Cerca in \(titolo)")
                    PulsanteFiltro(ordine: $ordine)
                }
                .padding(.horizontal)

                Group {
                    if !caricato {
                        ProgressView("Caricamento...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if lista.isEmpty {
                        Text("Nessun risultato")
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
                            .padding(.bottom, 20)
                        }
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

// MARK: - Scheda di un prodotto (card blu, testo bianco, angoli arrotondati)
struct ProductView: View {
    @State private var isShowingDetails: Bool = false

    var nome: String
    var prezzo: Double?
    var details: [String: Any]
    var categoria: String? = nil
    var modello: (any Model)? = nil
    var titoloBottone: String = "Aggiungi"
    var onSelect: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Immagine + nome + prezzo affiancati
            HStack(alignment: .center, spacing: 14) {
                if let categoria, let modello {
                    ComponenteImmagine(categoria: categoria, nome: nome, modello: modello, dimensione: 76)
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(nome)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.leading)

                    if let prezzo = prezzo {
                        Text(prezzo, format: .currency(code: "EUR"))
                            .font(.title3)
                            .bold()
                    } else {
                        Text("Prezzo: N/D")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer(minLength: 0)
            }

            if isShowingDetails {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .foregroundStyle(.white.opacity(0.75))
                            Spacer()
                            Text(formattaValore(value))
                        }
                        .font(.caption)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            HStack {
                if let onSelect = onSelect {
                    Button(action: onSelect) {
                        Text(titoloBottone)
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(Color.white, in: Capsule())
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
                        Text(isShowingDetails ? "Nascondi dettagli" : "Mostra dettagli")
                        Image(systemName: isShowingDetails ? "chevron.up" : "chevron.down")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
    }
}

#Preview {
    NavigationStack {
        Components(titolo: "CPU", fonti: [Fonte("cpu.json", CPU.self)])
    }
}
