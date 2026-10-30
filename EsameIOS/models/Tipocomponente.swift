//
//  TipoComponente.swift
//  EsameIOS
//
//  Unico posto in cui si decidono i colori delle categorie.
//
//  - colore  : tinta piena per sfondi/bottoni con sopra testo BIANCO.
//              Tutte le tinte hanno contrasto >= 4.5:1 con il bianco (WCAG AA),
//              quindi vanno bene sia in modalità chiara sia scura.
//  - accento : per testi, bordi e chip appoggiati sullo sfondo di sistema.
//              Chiaro = tinta scura (leggibile su bianco), scuro = tinta chiara (leggibile su nero).
//
import SwiftUI
import UIKit

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    /// Colore che cambia da solo tra modalità chiara e scura.
    init(chiaro: UInt32, scuro: UInt32) {
        self.init(uiColor: UIColor { trait in
            UIColor(hex: trait.userInterfaceStyle == .dark ? scuro : chiaro)
        })
    }

    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

enum TipoComponente: CaseIterable {
    case generico
    case cpu
    case cpuFan
    case motherboard
    case gpu
    case ram
    case psu
    case storage
    case pcCase
    case os
    case soundCard
    case networkCard

    /// Tinta piena (testo bianco sopra).
    var colore: Color {
        switch self {
        case .generico:    return Color(hex: 0x2B59C3)
        case .cpu:         return Color(hex: 0x0A5FD6)
        case .cpuFan:      return Color(hex: 0x00778A)
        case .motherboard: return Color(hex: 0xC62828)
        case .gpu:         return Color(hex: 0x1B7F3B)
        case .ram:         return Color(hex: 0xB85400)
        case .psu:         return Color(hex: 0x8A6D00)
        case .storage:     return Color(hex: 0x4338CA)
        case .pcCase:      return Color(hex: 0x7B4A2D)
        case .os:          return Color(hex: 0x7B2FBE)
        case .soundCard:   return Color(hex: 0xC2185B)
        case .networkCard: return Color(hex: 0x00695C)
        }
    }

    /// Tinta per testi e dettagli sullo sfondo di sistema (si adatta chiaro/scuro).
    var accento: Color {
        switch self {
        case .generico:    return Color(chiaro: 0x2B59C3, scuro: 0x8FB0FF)
        case .cpu:         return Color(chiaro: 0x0A5FD6, scuro: 0x6EA8FE)
        case .cpuFan:      return Color(chiaro: 0x00778A, scuro: 0x5CD6EE)
        case .motherboard: return Color(chiaro: 0xC62828, scuro: 0xFF8A80)
        case .gpu:         return Color(chiaro: 0x1B7F3B, scuro: 0x66D98A)
        case .ram:         return Color(chiaro: 0xB85400, scuro: 0xFFB366)
        case .psu:         return Color(chiaro: 0x8A6D00, scuro: 0xE6C84A)
        case .storage:     return Color(chiaro: 0x4338CA, scuro: 0xA5A0FF)
        case .pcCase:      return Color(chiaro: 0x7B4A2D, scuro: 0xC9A27E)
        case .os:          return Color(chiaro: 0x7B2FBE, scuro: 0xC79BFF)
        case .soundCard:   return Color(chiaro: 0xC2185B, scuro: 0xFF8DB8)
        case .networkCard: return Color(chiaro: 0x00695C, scuro: 0x4DD0C0)
        }
    }
}
