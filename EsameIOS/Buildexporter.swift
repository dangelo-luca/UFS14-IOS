import SwiftUI
import UIKit

enum FormatoExport {
    case pdf
    case testo

    var estensione: String {
        switch self {
        case .pdf: return "pdf"
        case .testo: return "txt"
        }
    }
}

struct FileCondivisibile: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

@MainActor
enum BuildExporter {

    private static let ordineComponenti = [
        "CPU", "CPU Cooler", "Motherboard", "GPU", "RAM", "Power Supply",
        "Storage", "Case", "OS", "Sound Card", "Network Card"
    ]

    static func righe(_ build: SavedBuild) -> [(categoria: String, descrizione: String)] {
        build.componenti
            .sorted { a, b in
                let ia = ordineComponenti.firstIndex(of: a.key) ?? Int.max
                let ib = ordineComponenti.firstIndex(of: b.key) ?? Int.max
                return ia < ib
            }
            .map { voce in
                let nome = voce.value.risultato.nome
                let quantita = voce.value.quantita
                return (voce.key, quantita > 1 ? "\(quantita) × \(nome)" : nome)
            }
    }

    static func totaleFormattato(_ build: SavedBuild) -> String {
        build.totale.formatted(.currency(code: "EUR"))
    }

    static func esporta(_ build: SavedBuild, formato: FormatoExport) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(nomeFile(build, estensione: formato.estensione))
        try? FileManager.default.removeItem(at: url)

        switch formato {
        case .testo:
            do {
                try testo(build).write(to: url, atomically: true, encoding: .utf8)
                return url
            } catch {
                return nil
            }
        case .pdf:
            return creaPDF(build, in: url)
        }
    }

    private static func testo(_ build: SavedBuild) -> String {
        let isEn = UserDefaults.standard.string(forKey: "language") == "en"
        let totalLabel = isEn ? "Total" : "Totale"
        var righeTesto = [build.nome, String(repeating: "-", count: max(build.nome.count, 8)), ""]
        for r in righe(build) {
            let cat = isEn ? categoriaInglese(r.categoria) : r.categoria
            righeTesto.append("\(cat): \(r.descrizione)")
        }
        righeTesto.append("")
        righeTesto.append("\(totalLabel): \(totaleFormattato(build))")
        return righeTesto.joined(separator: "\n")
    }

    private static func categoriaInglese(_ categoria: String) -> String {
        switch categoria {
        case "Dissipatore CPU": return "CPU Cooler"
        case "Scheda madre": return "Motherboard"
        case "Scheda video": return "GPU"
        case "Alimentatore": return "Power Supply"
        case "Archiviazione": return "Storage"
        case "Sistema Operativo": return "Operating System"
        case "Scheda audio": return "Sound Card"
        case "Scheda di rete": return "Network Card"
        default: return categoria
        }
    }

    private static func creaPDF(_ build: SavedBuild, in url: URL) -> URL? {
        let larghezza: CGFloat = 595

        let renderer = ImageRenderer(content: PaginaBuildPDF(build: build, larghezza: larghezza))
        renderer.proposedSize = ProposedViewSize(width: larghezza, height: nil)

        var riuscito = false
        renderer.render { size, disegna in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let contesto = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else { return }
            contesto.beginPDFPage(nil)
            disegna(contesto)
            contesto.endPDFPage()
            contesto.closePDF()
            riuscito = true
        }
        return riuscito ? url : nil
    }

    private static func nomeFile(_ build: SavedBuild, estensione: String) -> String {
        let vietati = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let pulito = build.nome
            .components(separatedBy: vietati)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespaces)
        return (pulito.isEmpty ? "Build" : pulito) + "." + estensione
    }
}

private struct PaginaBuildPDF: View {
    let build: SavedBuild
    let larghezza: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(build.nome)
                    .font(.system(size: 28, weight: .bold))
                Text(Date.now.formatted(date: .long, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }

            Divider()

            VStack(spacing: 0) {
                ForEach(Array(BuildExporter.righe(build).enumerated()), id: \.offset) { indice, riga in
                    HStack(alignment: .firstTextBaseline) {
                        Text(LocalizedStringKey(riga.categoria))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.gray)
                            .frame(width: 120, alignment: .leading)
                        Text(riga.descrizione)
                            .font(.system(size: 14))
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 9)

                    if indice < build.componenti.count - 1 {
                        Divider()
                    }
                }
            }

            Divider()

            HStack {
                Text("Totale")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(BuildExporter.totaleFormattato(build))
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .foregroundStyle(.black)
        .padding(40)
        .frame(width: larghezza, alignment: .topLeading)
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }
}
