//
//  JsonDecoder.swift
//  EsameIOS
//

import SwiftUI

// MARK: - Lettura base di un file json (ritorna T, di solito un array)
// Uso:  let cpu: [CPU] = caricaJson("cpu.json")
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

// MARK: - UN file -> TUTTI i dati (vettore)
// Uso:  let cpu: [CPU] = caricaTutti("cpu.json")
func caricaTutti<T: Decodable>(_ nomeFile: String) -> [T] {
    return caricaJson(nomeFile)
}

// Come caricaTutti, ma se il file non si legge o non rispetta il modello
// NON chiude l'app: stampa l'errore in console (righe "RICERCA:") e ritorna [].
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

// MARK: - Fonte = un file json + la classe con cui si legge
// Uso:  Fonte("cpu.json", CPU.self)
// Il file viene letto UNA volta sola, la prima volta che serve, poi resta in memoria.
final class Fonte {
    let file: String
    let categoria: String
    private let leggi: () -> [Component]

    // Gli oggetti letti dal json
    lazy var dati: [Component] = leggi()

    // Gli stessi oggetti come Risultato (nome e prezzo già estratti, id stabili)
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

// MARK: - PIÙ file -> TUTTI i dati (vettore)
// Da usare al caricamento di una pagina (es. Components):
//   let tutti = caricaRisultati(da: [Fonte("cpu.json", CPU.self)])
func caricaRisultati(da fonti: [Fonte]) -> [Risultato] {
    return fonti.flatMap { $0.risultati }
}

// MARK: - PIÙ file -> SOLO quelli cercati
// Uso:  let trovati = cercaNeiFile("ryzen", in: [Fonte("cpu.json", CPU.self)])
func cercaNeiFile(_ testo: String, in fonti: [Fonte]) -> [Risultato] {
    let query = testo.trimmingCharacters(in: .whitespaces)
    guard !query.isEmpty else { return [] }
    return caricaRisultati(da: fonti).filter { $0.nome.localizedCaseInsensitiveContains(query) }
}

// Legge il campo `nome` di un qualsiasi oggetto (es. "name", "price")
func leggiCampo<V>(_ oggetto: Any, _ nome: String) -> V? {
    Mirror(reflecting: oggetto).children.first { $0.label == nome }?.value as? V
}
