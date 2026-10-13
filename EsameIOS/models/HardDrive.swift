//
//  HardDrive.swift
//  EsameIOS
//
//  Created by s6 on 13/10/26.
//
class HardDrive : Model, Codable, Identifiable {
    var id: String {self.name}
    let name: String
    let price: Double?
}
