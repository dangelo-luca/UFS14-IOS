import SwiftUI

struct BuildDetailView: View {
    let build: SavedBuild

    // Stesso ordine della schermata di creazione
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

    var body: some View {
        List {
            Section("Componenti") {
                ForEach(righe, id: \.categoria) { riga in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(riga.categoria)
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
