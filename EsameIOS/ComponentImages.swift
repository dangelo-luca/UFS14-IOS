//
//  ComponenteImmagine.swift
//  EsameIOS
//
//  Mostra il LOGO DELLA MARCA del componente, sempre nitido.
//  Fonti (tutte gratuite e senza chiave), provate in ordine:
//   1. Simple Icons  -> logo vettoriale convertito in PNG da wsrv.nl (marche principali)
//   2. Icon Horse    -> icona del sito della marca
//  Un'immagine viene accettata SOLO se è abbastanza grande (>= 120 px sul lato corto).
//  Se nessuna lo è, al posto di un logo sgranato si mostra un monogramma colorato
//  con le iniziali della marca (sempre nitido).
//

import SwiftUI
import UIKit

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

// MARK: - Marca: ricava sito e indirizzi del logo dal primo nome del prodotto
enum Marca {
    // marche scritte con più parole (controllate per prime)
    private static let composte: [(String, String)] = [
        ("western digital", "wdc.com"), ("cooler master", "coolermaster.com"),
        ("be quiet", "bequiet.com"), ("lian li", "lian-li.com"),
        ("silicon power", "silicon-power.com"), ("team group", "teamgroupinc.com"),
        ("turtle beach", "turtlebeach.com"), ("in win", "inwin-style.com"),
        ("fractal design", "fractal-design.com"), ("g.skill", "gskill.com"),
        ("g skill", "gskill.com"), ("tp-link", "tp-link.com"),
        ("audio-technica", "audio-technica.com"), ("hyper x", "hyperx.com"),
        ("steel series", "steelseries.com")
    ]

    // marche il cui sito non è "nome.com"
    private static let speciali: [String: String] = [
        "wd": "wdc.com", "hp": "hp.com", "lg": "lg.com", "xfx": "xfxforce.com",
        "sapphire": "sapphiretech.com", "teamgroup": "teamgroupinc.com",
        "a-data": "adata.com", "cougar": "cougargaming.com",
        "glorious": "gloriousgaming.com", "noctua": "noctua.at",
        "arctic": "arctic.de", "creative": "creative.com", "gskill": "gskill.com"
    ]

    // Marche con logo vettoriale su Simple Icons (nomi verificati uno per uno).
    // chiave = prima parola del nome in minuscolo, valore = nome del logo su Simple Icons
    private static let simpleIcons: [String: String] = [
        "asus": "asus", "corsair": "corsair", "msi": "msi", "kingston": "kingstontechnology",
        "intel": "intel", "cooler": "coolermaster", "samsung": "samsung", "acer": "acer",
        "seagate": "seagate", "hp": "hp", "lg": "lg", "amd": "amd", "nzxt": "nzxt",
        "deepcool": "deepcool", "razer": "razer", "toshiba": "toshiba", "dell": "dell",
        "sony": "sony", "steelseries": "steelseries", "hitachi": "hitachi",
        "sennheiser": "sennheiser", "lenovo": "lenovo", "audio-technica": "audiotechnica",
        "panasonic": "panasonic", "nec": "nec", "supermicro": "supermicro",
        "tp-link": "tplink", "redragon": "redragon", "nvidia": "nvidia", "bose": "bose",
        "apple": "apple", "denon": "denon", "netgear": "netgear", "jbl": "jbl",
        "linksys": "linksys", "cisco": "cisco", "synology": "synology", "qnap": "qnap",
        "fujitsu": "fujitsu", "huawei": "huawei", "elgato": "elgato", "sharp": "sharp",
        "wacom": "wacom", "alienware": "alienware", "xiaomi": "xiaomi",
        "motorola": "motorola", "hyperx": "hyperx"
    ]

    static func dominio(da nome: String) -> String? {
        let minuscolo = nome.lowercased()
        for (prefisso, dominio) in composte where minuscolo.hasPrefix(prefisso) {
            return dominio
        }
        guard let prima = minuscolo.split(separator: " ").first else { return nil }
        let chiave = String(prima)
        if let d = speciali[chiave] { return d }
        let pulita = chiave.filter { $0.isLetter || $0.isNumber || $0 == "-" }
        guard pulita.count >= 2, pulita.first?.isLetter == true else { return nil }
        return pulita + ".com"
    }

    // Iniziali per il monogramma: "ASRock" -> "AS", "G.Skill" -> "GS"
    static func iniziali(da nome: String) -> String {
        let prima = nome.split(separator: " ").first.map(String.init) ?? ""
        let lettere = prima.filter { $0.isLetter }
        return lettere.isEmpty ? "?" : String(lettere.prefix(2)).uppercased()
    }

    // Gli indirizzi da provare, in ordine di qualità
    static func urlLogo(da nome: String) -> [URL] {
        var indirizzi: [String] = []

        // 1. logo vettoriale nitido (se la marca è nella tabella)
        let prima = nome.lowercased().split(separator: " ").first.map(String.init) ?? ""
        if let slug = simpleIcons[prima] {
            indirizzi.append("https://wsrv.nl/?url=cdn.simpleicons.org/\(slug)&output=png&w=256&h=256&fit=contain")
        }

        // 2. icona del sito della marca (di solito 180 px o più)
        if let dominio = dominio(da: nome) {
            indirizzi.append("https://icon.horse/icon/\(dominio)")
        }
        return indirizzi.compactMap { URL(string: $0) }
    }
}

// MARK: - Scarica i loghi, li controlla e li tiene in memoria (uno per marca)
actor ServizioLoghi {
    static let shared = ServizioLoghi()

    private let latoMinimo: CGFloat = 120          // sotto questa soglia il logo risulta sgranato
    private var cache: [String: UIImage] = [:]
    private var assenti: Set<String> = []
    private var inCorso: [String: Task<(UIImage?, Bool), Never>] = [:]

    func logo(per nome: String) async -> UIImage? {
        guard let chiave = Marca.dominio(da: nome) else { return nil }
        if let immagine = cache[chiave] { return immagine }
        if assenti.contains(chiave) { return nil }

        // se un'altra riga della stessa marca sta già scaricando, aspetta lo stesso risultato
        let compito: Task<(UIImage?, Bool), Never>
        if let esistente = inCorso[chiave] {
            compito = esistente
        } else {
            let indirizzi = Marca.urlLogo(da: nome)
            let minimo = latoMinimo
            compito = Task { await Self.scarica(indirizzi, latoMinimo: minimo) }
            inCorso[chiave] = compito
        }

        let (immagine, erroreRete) = await compito.value
        inCorso[chiave] = nil

        if let immagine {
            cache[chiave] = immagine
        } else if !erroreRete {
            assenti.insert(chiave)      // nessuna fonte ha un logo abbastanza grande
        }
        return immagine
    }

    private static func scarica(_ indirizzi: [URL], latoMinimo: CGFloat) async -> (UIImage?, Bool) {
        var erroreRete = false
        for url in indirizzi {
            do {
                let (dati, risposta) = try await URLSession.shared.data(from: url)
                guard (risposta as? HTTPURLResponse)?.statusCode == 200,
                      let immagine = UIImage(data: dati) else { continue }
                let lato = min(immagine.size.width, immagine.size.height) * immagine.scale
                if lato >= latoMinimo { return (immagine, false) }
            } catch {
                erroreRete = true
            }
        }
        return (nil, erroreRete)
    }
}

// MARK: - Mostra il logo; se non c'è (o è troppo piccolo) mostra `alternativa`
struct LogoMarca<Alternativa: View>: View {
    let nome: String
    var margine: CGFloat = 0
    let alternativa: Alternativa

    @State private var immagine: UIImage?
    @State private var finito = false

    init(nome: String, margine: CGFloat = 0, @ViewBuilder alternativa: () -> Alternativa) {
        self.nome = nome
        self.margine = margine
        self.alternativa = alternativa()
    }

    var body: some View {
        Group {
            if let immagine {
                Image(uiImage: immagine)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .padding(margine)
            } else if finito {
                alternativa
            } else {
                Color.clear
            }
        }
        .task(id: nome) {
            immagine = nil
            finito = false
            let trovata = await ServizioLoghi.shared.logo(per: nome)
            if Task.isCancelled { return }      // la riga è uscita dallo schermo
            immagine = trovata
            finito = true
        }
    }
}

// MARK: - Vista da usare nelle liste e nei dettagli
struct ComponenteImmagine: View {
    var colore: Color = .blue          // colore della categoria (es. modello.colore)
    let nome: String
    var dimensione: CGFloat = 60

    var body: some View {
        LogoMarca(nome: nome, margine: dimensione * 0.14) {
            monogramma
        }
        .frame(width: dimensione, height: dimensione)
    }

    // Quadrato colorato con le iniziali della marca (colore della categoria)
    private var monogramma: some View {
        ZStack {
            RoundedRectangle(cornerRadius: dimensione * 0.2)
                .fill(colore.gradient)
            Text(Marca.iniziali(da: nome))
                .font(.system(size: dimensione * 0.34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(dimensione * 0.08)
    }
}
