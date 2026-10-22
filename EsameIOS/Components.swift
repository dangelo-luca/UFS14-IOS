//
//  Components.swift
//  EsameIOS
//

import SwiftUI

// MARK: - Pagina con la lista dei componenti di UNA categoria
//
// Uso (da BuildPcView, quando premi il bottone CPU):
//   Components(titolo: "CPU", fonti: [Fonte("cpu.json", CPU.self)]) { risultato in
//       // chiamata quando premi "Seleziona" su un prodotto
//   }
//
// Al caricamento legge tutti i dati dei json passati in `fonti`,
// poi la barra in basso filtra la lista mentre scrivi.

struct Components: View {
    var titolo: String = "Componenti"
    var fonti: [Fonte] = RicercaView.tutte
    var alSelezionare: ((Risultato) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var testo: String = ""
    @State private var tutti: [Risultato] = []
    @State private var caricato = false

    private let massimo = 100   // massimo prodotti mostrati, per tenere la lista leggera

    var body: some View {
        let query = testo.trimmingCharacters(in: .whitespaces)
        let filtrati = query.isEmpty ? tutti : tutti.filter { $0.nome.localizedCaseInsensitiveContains(query) }
        let lista = Array(filtrati.prefix(massimo))
        BarraRicerca(testo: $testo, placeholder: "Cerca in \(titolo)")
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
                    LazyVStack(spacing: 12) {
                        ForEach(lista) { r in
                            ProductView(
                                nome: r.nome,
                                prezzo: r.prezzo,
                                details: r.dettagli,
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
                }
            }
        }
        .navigationTitle(titolo)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
           
        }
        .task {
            guard !caricato else { return }
            await Task.yield()                 // lascia disegnare la pagina prima di leggere i file
            tutti = caricaRisultati(da: fonti) // <- qui si caricano i dati
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
    var onSelect: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nome)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.leading)

            if let prezzo = prezzo {
                Text(String(format: "Prezzo: %.2f €", prezzo))
            } else {
                Text("Prezzo: N/D")
                    .foregroundStyle(.secondary)
            }

            Divider()

            if isShowingDetails {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Text("\(key): \(formattaValore(value))")
                    }
                }
                Divider()
            }

            HStack {
                if let onSelect = onSelect {
                    Button("Seleziona", action: onSelect)
                        .buttonStyle(.borderedProminent)
                }
                Spacer()
                Button(action: { isShowingDetails.toggle() }) {
                    HStack {
                        Text(isShowingDetails ? "Nascondi dettagli" : "Mostra dettagli")
                        Image(systemName: isShowingDetails ? "chevron.up" : "chevron.down")
                    }
                }
            }
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        Components(titolo: "CPU", fonti: [Fonte("cpu.json", CPU.self)])
    }
}
