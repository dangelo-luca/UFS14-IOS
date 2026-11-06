import SwiftUI

struct Selezione {
    var risultato: Risultato
    var quantita: Int = 1

    var subtotale: Double { (risultato.prezzo ?? 0) * Double(quantita) }
}

struct SavedBuild: Identifiable {
    let id = UUID()
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
    var savedBuilds: [SavedBuild] = []

    func aggiungiBuild(scelti: [String: Selezione], nomeCustom: String? = nil) {
        let numero = savedBuilds.count + 1
        let titolo = nomeCustom?.isEmpty == false ? nomeCustom! : "Build #\(numero)"
        let nuovaBuild = SavedBuild(nome: titolo, componenti: scelti)

        savedBuilds.append(nuovaBuild)
    }

    // Aggiorna una build già salvata (usata dal tasto "Modifica")
    func aggiornaBuild(id: UUID, scelti: [String: Selezione], nome: String) {
        guard let i = savedBuilds.firstIndex(where: { $0.id == id }) else { return }
        savedBuilds[i].componenti = scelti
        if !nome.isEmpty {
            savedBuilds[i].nome = nome
        }
    }

    func eliminaBuild(at offsets: IndexSet) {
        savedBuilds.remove(atOffsets: offsets)
    }
}
