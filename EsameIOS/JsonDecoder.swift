/*
//
//  EsamwIOS.swift
//  EsameIOS
//
//  Created by s17 on 06/10/26.
//

import SwiftUI

enum OsMode: Codable {
    case singolo(Int)
    case multiplo([Int])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let valoreSingolo = try? container.decode(Int.self) {
            self = .singolo(valoreSingolo)
        }
        else if let arrayValori = try? container.decode([Int].self) {
            self = .multiplo(arrayValori)
        }
        else {
            throw DecodingError.typeMismatch(OsMode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Atteso Int o [Int]"))
        }
    }
}

struct Os: Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let mode: OsMode
    let max_memory: Int
}

struct Ups: Codable, Identifiable {
    var id: String { self.name }
    let name: String
    let price: Double?
    let capacity_w: Int?
    let capacity_va: Int?
}

func caricaJson<T: Decodable>(_ nomeFile:String) -> T{
    guard let url  = Bundle.main.url(forResource: nomeFile, withExtension: nil) else{
        fatalError("impossibile leggere il file \(nomeFile)")
    }
    guard let dati = try? Data(contentsOf: url) else{
        fatalError("impossibile leggere il file")
    }
    do {
        let decoder = JSONDecoder()
        let datiDecodificati = try decoder.decode(T.self, from: dati)
        return datiDecodificati
    } catch {
        fatalError("Errore durante la decodifica di \(nomeFile)")
    }
}
*/
