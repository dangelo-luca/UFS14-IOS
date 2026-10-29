import SwiftUI

// Modello di una build salvata
struct SavedBuild: Identifiable {
    let id = UUID()
    var nome: String
    var dataCreazione: Date = Date()
    var componenti: [String: Risultato] // Dizionario dei componenti scelti
    
    var totale: Double {
        componenti.values.compactMap { $0.prezzo }.reduce(0, +)
    }
}

// Gestore centralizzato condiviso
@Observable
class BuildManager {
    var savedBuilds: [SavedBuild] = []
    
    func aggiungiBuild(scelti: [String: Risultato], nomeCustom: String? = nil) {
        let numero = savedBuilds.count + 1
        let titolo = nomeCustom?.isEmpty == false ? nomeCustom! : "Build #\(numero)"
        let nuovaBuild = SavedBuild(nome: titolo, componenti: scelti)
        
        savedBuilds.append(nuovaBuild)
    }
    
    func eliminaBuild(at offsets: IndexSet) {
        savedBuilds.remove(atOffsets: offsets)
    }
}
