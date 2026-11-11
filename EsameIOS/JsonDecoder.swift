import SwiftUI

func caricaJson<T: Decodable>(_ nomeFile: String) -> T {
    guard let url = Bundle.main.url(forResource: nomeFile, withExtension: nil) else {
        fatalError("impossibile trovare il file \(nomeFile) nel progetto")
    }
    guard let dati = try? Data(contentsOf: url) else {
        fatalError("impossibile leggere il file \(nomeFile)")
    }
    do {
        return try JSONDecoder().decode(T.self, from: dati)
    } catch {
        fatalError("Errore durante la decodifica di \(nomeFile): \(error)")
    }
}

func caricaTutti<T: Decodable>(_ nomeFile: String) -> [T] {
    return caricaJson(nomeFile)
}

func caricaSicuro<T: Decodable>(_ nomeFile: String) -> [T] {
    guard let url = Bundle.main.url(forResource: nomeFile, withExtension: nil),
          let dati = try? Data(contentsOf: url) else {
        print("RICERCA: file \(nomeFile) non trovato nel progetto")
        return []
    }
    do {
        return try JSONDecoder().decode([T].self, from: dati)
    } catch {
        print("RICERCA: errore in \(nomeFile): \(error)")
        return []
    }
}

final class Fonte {
    let file: String
    let categoria: String
    private let leggi: () -> [Component]

    lazy var dati: [Component] = leggi()

    lazy var risultati: [Risultato] = creaRisultati()

    init<T: Component>(_ file: String, _ tipo: T.Type) {
        self.file = file
        self.categoria = file.replacingOccurrences(of: ".json", with: "")
        self.leggi = { () -> [Component] in
            let lista: [T] = caricaSicuro(file)
            return lista.map { $0 as Component }
        }
    }

    private func creaRisultati() -> [Risultato] {
        dati.map { elemento in
            Risultato(categoria: categoria, nome: elemento.name, prezzo: elemento.price, modello: elemento)
        }
    }
}

func caricaRisultati(da fonti: [Fonte]) -> [Risultato] {
    return fonti.flatMap { $0.risultati }
}

func cercaNeiFile(_ testo: String, in fonti: [Fonte]) -> [Risultato] {
    let query = testo.trimmingCharacters(in: .whitespaces)
    guard !query.isEmpty else { return [] }
    return caricaRisultati(da: fonti).filter { $0.nome.localizedCaseInsensitiveContains(query) }
}

func leggiCampo<V>(_ oggetto: Any, _ nome: String) -> V? {
    Mirror(reflecting: oggetto).children.first { $0.label == nome }?.value as? V
}
