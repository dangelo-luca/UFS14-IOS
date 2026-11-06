import SwiftUI

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

struct Components: View {
    var titolo: String = "Componenti"
    var fonti: [Fonte] = RicercaView.tutte
    var colore: Color = .blue
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
            SfondoSfumato(colore: colore)

            VStack(spacing: 10) {
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


struct ProductView: View {
    @State private var isShowingDetails: Bool = false

    var nome: String
    var prezzo: Double?
    var details: [String: Any]
    var modello: Component? = nil
    var titoloBottone: String = "Aggiungi"
    var onSelect: (() -> Void)? = nil

    private var accento: Color { modello?.accento ?? TipoComponente.generico.accento }
    private var riempimento: Color { modello?.colore ?? TipoComponente.generico.colore }

    private var dettagli: [String] {
        details.sorted { $0.key < $1.key }
            .map { "\(formattaValore($0.value))" }
            .filter { !$0.isEmpty && $0 != "N/D" && $0 != "N/A" }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                if modello != nil {
                    ComponenteImmagine(colore: riempimento, nome: nome, dimensione: 72)
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
            if !dettagli.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dettagli, id: \.self) { testo in
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

            HStack {
                if let onSelect = onSelect {
                    Button(action: onSelect) {
                        Label(titoloBottone, systemImage: "plus")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(riempimento.gradient, in: Capsule())
                            .shadow(color: riempimento.opacity(0.35), radius: 6, y: 3)
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
        Components(titolo: "CPU", fonti: [Fonte("cpu.json", CPU.self)], colore: CPU.colore)
    }
}
