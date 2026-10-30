//
//  ComponenteImmagine.swift
//  EsameIOS
//
//  Immagine di un componente:
//   1. cerca una foto del PRODOTTO su Wikimedia Commons (gratis, senza chiave)
//   2. se non trova nulla (o nel frattempo) mostra l'icona SF Symbol della categoria
//

import SwiftUI

// MARK: - Icona per categoria (chiave = nome del file json senza ".json")
enum IconeCategoria {
    static func simbolo(per categoria: String) -> String {
        switch categoria {
        case "case":                    return "desktopcomputer"
        case "case-accessory":          return "puzzlepiece"
        case "case-fan", "cpu-cooler":  return "fan"
        case "cpu":                     return "cpu"
        case "external-hard-drive":     return "externaldrive"
        case "internal-hard-drive":     return "internaldrive"
        case "fan-controller":          return "slider.horizontal.3"
        case "headphones":              return "headphones"
        case "keyboard":                return "keyboard"
        case "memory":                  return "memorychip"
        case "monitor":                 return "display"
        case "motherboard":             return "rectangle.split.3x3"
        case "mouse":                   return "computermouse"
        case "optical-drive":           return "opticaldisc"
        case "os":                      return "macwindow"
        case "power-supply":            return "bolt.fill"
        case "sound-card":              return "waveform"
        case "speakers":                return "hifispeaker"
        case "thermal-paste":           return "drop.fill"
        case "ups":                     return "battery.100.bolt"
        case "video-card":              return "square.stack.3d.up.fill"
        case "webcam":                  return "web.camera"
        case "wired-network-card":      return "cable.connector"
        case "wireless-network-card":   return "wifi"
        default:                        return "shippingbox"
        }
    }
}

// MARK: - Risposta delle API MediaWiki (Commons e Wikipedia)
private struct RispostaWiki: Decodable {
    struct Query: Decodable { let pages: [String: Pagina] }
    struct Pagina: Decodable {
        let index: Int?
        let title: String?
        let thumbnail: Thumb?           // Wikipedia
        let imageinfo: [InfoImmagine]?  // Commons
    }
    struct Thumb: Decodable { let source: String }
    struct InfoImmagine: Decodable {
        let thumburl: String?
        let mime: String?
    }
    let query: Query?
}

// MARK: - Servizio di ricerca (con cache su disco)
actor ServizioImmagini {
    static let shared = ServizioImmagini()

    // Chiave nuova: scarta la vecchia cache che aveva salvato solo "non trovato"
    private let chiaveSalvataggio = "cacheImmaginiV3"
    // nome prodotto -> url ("" = cercato ma non trovato)
    private var cache: [String: String]

    init() {
        cache = UserDefaults.standard.dictionary(forKey: "cacheImmaginiV3") as? [String: String] ?? [:]
    }

    func url(nome: String) async -> URL? {
        if let salvato = cache[nome] {
            return salvato.isEmpty ? nil : URL(string: salvato)
        }
        do {
            let trovato = try await cercaSuCommons(nome)
            cache[nome] = trovato ?? ""
            UserDefaults.standard.set(cache, forKey: chiaveSalvataggio)
            print("IMMAGINI: \(nome) -> \(trovato ?? "nessuna immagine")")
            return trovato.flatMap { URL(string: $0) }
        } catch {
            // errore di rete o riga uscita dallo schermo: non salvo, riproverà
            if !(error is CancellationError), (error as? URLError)?.code != .cancelled {
                print("IMMAGINI: errore per \(nome): \(error)")
            }
            return nil
        }
    }

    // Foto del prodotto vero. Un file è accettato solo se il suo titolo contiene
    // TUTTE le sigle del modello (es. "a10" e "7800", oppure "5600x") e non parla
    // di loghi, edifici, schemi ecc. Meglio un'icona che una foto sbagliata.
    private func cercaSuCommons(_ nome: String) async throws -> String? {
        let sigle = sigleModello(nome)
        guard !sigle.isEmpty else { return nil }
        let r = try await chiama(host: "commons.wikimedia.org", [
            "action": "query", "format": "json",
            "generator": "search", "gsrnamespace": "6",
            "gsrsearch": nome, "gsrlimit": "10",
            "prop": "imageinfo", "iiprop": "url|mime", "iiurlwidth": "400"
        ])
        let vietate = ["logo", "icon", "wordmark", "building", "headquarters", "campus",
                       "diagram", "chart", "screenshot", "schematic", "map", "die shot", "benchmark"]
        let pagine = (r.query?.pages.values.sorted { ($0.index ?? 99) < ($1.index ?? 99) }) ?? []
        for p in pagine {
            guard let titolo = p.title?.lowercased(),
                  sigle.allSatisfy({ titolo.contains($0) }),
                  !vietate.contains(where: { titolo.contains($0) }),
                  let info = p.imageinfo?.first,
                  let mime = info.mime, ["image/jpeg", "image/png"].contains(mime),
                  let url = info.thumburl else { continue }
            return url
        }
        return nil
    }

    // Sigle del modello: le parole con un numero (almeno 3 caratteri) tra le prime
    // tre dopo la marca. "AMD A10-7800" -> ["a10","7800"]; "AMD Ryzen 5 5600X" -> ["5600x"]
    private func sigleModello(_ nome: String) -> [String] {
        let parti = nome.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        return Array(parti.dropFirst().prefix(3))
            .filter { $0.count >= 3 && $0.contains(where: \.isNumber) }
    }

    private func chiama(host: String, _ parametri: [String: String]) async throws -> RispostaWiki {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host = host
        comp.path = "/w/api.php"
        comp.queryItems = parametri.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = comp.url else { throw URLError(.badURL) }

        var richiesta = URLRequest(url: url)
        // Wikimedia chiede uno User-Agent descrittivo
        richiesta.setValue("EsameIOS/1.0 (progetto universitario)", forHTTPHeaderField: "User-Agent")
        let (dati, _) = try await URLSession.shared.data(for: richiesta)
        return try JSONDecoder().decode(RispostaWiki.self, from: dati)
    }
}

// MARK: - Vista da usare nelle liste e nei dettagli
struct ComponenteImmagine: View {
    let categoria: String
    let nome: String
    let modello: any Model
    var dimensione: CGFloat = 60

    @State private var url: URL?

    // Categorie dove i nomi hanno una sigla di modello riconoscibile.
    // Per memory, hard disk, ecc. i nomi sono troppo generici: restano icone.
    private let categorieOnline: Set<String> = [
        "cpu", "video-card", "motherboard", "monitor", "keyboard", "mouse",
        "headphones", "webcam", "speakers", "case", "cpu-cooler", "power-supply"
    ]

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { fase in
                    switch fase {
                    case .success(let immagine):
                        immagine.resizable().scaledToFit()
                    default:
                        icona
                    }
                }
            } else {
                icona
            }
        }
        .frame(width: dimensione, height: dimensione)
        .task(id: nome) {
            url = nil
            guard categorieOnline.contains(categoria) else { return }
            url = await ServizioImmagini.shared.url(nome: nome)
        }
    }

    private var icona: some View {
        Image(systemName: IconeCategoria.simbolo(per: categoria))
            .resizable()
            .scaledToFit()
            .padding(dimensione * 0.2)
            .foregroundStyle(.secondary)
    }
}
