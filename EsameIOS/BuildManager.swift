import SwiftUI

struct Selezione: Codable {
    var risultato: Risultato
    var quantita: Int = 1

    var subtotale: Double { (risultato.prezzo ?? 0) * Double(quantita) }
}

struct SavedBuild: Identifiable, Codable {
    var id = UUID()
    let userID: String
    var nome: String
    var dataCreazione: Date = Date()
    var componenti: [String: Selezione]

    var totale: Double {
        componenti.values.map(\.subtotale).reduce(0, +)
    }

    var numeroPezzi: Int {
        componenti.values.map(\.quantita).reduce(0, +)
    }
}

@Observable
class BuildManager {
    var savedBuilds: [SavedBuild] = [] {
        didSet {
            salvaSuDisco()
        }
    }

    private let keyStorage = "salvati_builds_app"

    init() {
        caricaDaDisco()
    }

    var buildUtenteCorrente: [SavedBuild] {
        let currentId = UserSettings.shared.user_id
        guard !currentId.isEmpty else { return [] }
        return savedBuilds.filter { $0.userID == currentId }
    }

    func prossimoNumeroBuild(per userID: String) -> Int {
        savedBuilds.filter { $0.userID == userID }.count + 1
    }

    func aggiungiBuild(scelti: [String: Selezione], nomeCustom: String? = nil) {
        let currentId = UserSettings.shared.user_id
        let numero = prossimoNumeroBuild(per: currentId)
        let titolo = nomeCustom?.isEmpty == false ? nomeCustom! : "Build #\(numero)"

        let nuovaBuild = SavedBuild(
            userID: currentId,
            nome: titolo,
            componenti: scelti
        )

        savedBuilds.append(nuovaBuild)
    }

    func aggiornaBuild(id: UUID, scelti: [String: Selezione], nome: String) {
        guard let i = savedBuilds.firstIndex(where: { $0.id == id }) else { return }
        savedBuilds[i].componenti = scelti
        if !nome.isEmpty {
            savedBuilds[i].nome = nome
        }
    }

    func eliminaBuild(id: UUID) {
        savedBuilds.removeAll(where: { $0.id == id })
    }

    func eliminaBuildUtente(at offsets: IndexSet) {
        let attuali = buildUtenteCorrente
        for index in offsets {
            let buildDaRimuovere = attuali[index]
            savedBuilds.removeAll(where: { $0.id == buildDaRimuovere.id })
        }
    }

    func eliminaTutteBuildUtente(userID: String) {
        savedBuilds.removeAll(where: { $0.userID == userID })
    }

    private func salvaSuDisco() {
        if let encoded = try? JSONEncoder().encode(savedBuilds) {
            UserDefaults.standard.set(encoded, forKey: keyStorage)
        }
    }

    private func caricaDaDisco() {
        if let data = UserDefaults.standard.data(forKey: keyStorage),
           let decoded = try? JSONDecoder().decode([SavedBuild].self, from: data) {
            self.savedBuilds = decoded
        }
    }
}
