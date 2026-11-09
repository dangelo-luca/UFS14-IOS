import SwiftUI
import UIKit

// MARK: - Formati

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

// File pronto da condividere (Identifiable per usarlo con .sheet(item:))
struct FileCondivisibile: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Foglio di condivisione di sistema

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Export

@MainActor
enum BuildExporter {
    // Stesso ordine usato in HomeView e BuildDetailView
    private static let ordineComponenti = [
        "CPU", "CPU Cooler", "Motherboard", "GPU", "RAM", "Power Supply",
        "Storage", "Case", "OS", "Sound Card", "Network Card"
    ]

    /// Coppie (categoria, descrizione) ordinate come nel resto dell'app.
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

    /// Crea il file nella cartella temporanea e ne restituisce l'URL.
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

    // MARK: Testo

    private static func testo(_ build: SavedBuild) -> String {
        var righeTesto = [build.nome, String(repeating: "-", count: max(build.nome.count, 8)), ""]
        for r in righe(build) {
            righeTesto.append("\(r.categoria): \(r.descrizione)")
        }
        righeTesto.append("")
        righeTesto.append("Totale: \(totaleFormattato(build))")
        return righeTesto.joined(separator: "\n")
    }

    // MARK: PDF

    private static func creaPDF(_ build: SavedBuild, in url: URL) -> URL? {
        let larghezza: CGFloat = 595 // A4 a 72 dpi

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

    // MARK: Nome file

    private static func nomeFile(_ build: SavedBuild, estensione: String) -> String {
        let vietati = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let pulito = build.nome
            .components(separatedBy: vietati)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespaces)
        return (pulito.isEmpty ? "Build" : pulito) + "." + estensione
    }
}

// MARK: - Pagina del PDF

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
                        Text(riga.categoria)
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
