import SwiftUI

struct BuildDetailView: View {
    let build: SavedBuild

    
    private static let ordine = [
        "CPU", "CPU Cooler", "Motherboard", "GPU", "RAM", "Power Supply",
        "Storage", "Case", "OS", "Sound Card", "Network Card"
    ]

    private var righe: [(categoria: String, selezione: Selezione)] {
        build.componenti
            .sorted { a, b in
                let ia = Self.ordine.firstIndex(of: a.key) ?? Int.max
                let ib = Self.ordine.firstIndex(of: b.key) ?? Int.max
                return ia < ib
            }
            .map { (categoria: $0.key, selezione: $0.value) }
    }

    private func dettagli(da dettagli: [String: Any]) -> [String] {
        dettagli.sorted { $0.key < $1.key }
            .map { "\(formattaValore($0.value))" }
            .filter { !$0.isEmpty && $0 != "N/D" && $0 != "N/A" }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        List {
            Section("Componenti") {
                ForEach(righe, id: \.categoria) { riga in
                    let chips = dettagli(da: riga.selezione.risultato.dettagli)
                    let accento = riga.selezione.risultato.modello.accento

                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(riga.categoria))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .firstTextBaseline) {
                            Text(riga.selezione.quantita > 1
                                ? "\(riga.selezione.quantita) × \(riga.selezione.risultato.nome)"
                                : riga.selezione.risultato.nome)
                                .font(.headline)

                            Spacer()

                            Text(riga.selezione.subtotale, format: .currency(code: "EUR"))
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                        }

                        if riga.selezione.quantita > 1, let unitario = riga.selezione.risultato.prezzo {
                            Text("\(unitario, format: .currency(code: "EUR")) cad.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        
                        if !chips.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(chips, id: \.self) { tag in
                                        Text(LocalizedStringKey(tag))
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(accento)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(accento.opacity(0.12), in: Capsule())
                                    }
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                HStack {
                    Text("Totale")
                        .font(.headline)
                    Spacer()
                    Text(build.totale, format: .currency(code: "EUR"))
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.pink)
                }
            }
        }
        .navigationTitle(build.nome)
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.bottom, 90, for: .scrollContent)
    }
}


