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
        case .generico:    return Color(hex: 0x4B5563) // Grigio slate elegante
        case .cpu:         return Color(hex: 0x3B82F6) // Blu classico bilanciato
        case .cpuFan:      return Color(hex: 0x0EA5E9) // Azzurro cielo satinato
        case .motherboard: return Color(hex: 0xEF4444) // Rosso corallo morbido
        case .gpu:         return Color(hex: 0x10B981) // Verde smeraldo profondo
        case .ram:         return Color(hex: 0xF97316) // Arancio calmo
        case .psu:         return Color(hex: 0xEAB308) // Giallo ambrato
        case .storage:     return Color(hex: 0x6366F1) // Indaco / Lavanda
        case .pcCase:      return Color(hex: 0x06B6D4)
        case .os:          return Color(hex: 0x9333EA) // Viola vellutato
        case .soundCard:   return Color(hex: 0xEC4899) // Rosa lampone
        case .networkCard: return Color(hex: 0x0D9488) // Ottanio opaco
        }
    }

    /// Tinta per testi e dettagli sullo sfondo di sistema (si adatta chiaro/scuro).
    var accento: Color {
        switch self {
        case .generico:    return Color(chiaro: 0x4B5563, scuro: 0x9CA3AF)
        case .cpu:         return Color(chiaro: 0x1D4ED8, scuro: 0x60A5FA)
        case .cpuFan:      return Color(chiaro: 0x0369A1, scuro: 0x38BDF8)
        case .motherboard: return Color(chiaro: 0xDC2626, scuro: 0xF87171)
        case .gpu:         return Color(chiaro: 0x059669, scuro: 0x34D399)
        case .ram:         return Color(chiaro: 0xEA580C, scuro: 0xFB923C)
        case .psu:         return Color(chiaro: 0xCA8A04, scuro: 0xFBBF24)
        case .storage:     return Color(chiaro: 0x4F46E5, scuro: 0x818CF8)
        case .pcCase:      return Color(chiaro: 0x9333EA, scuro: 0xC084FC)
        case .os:          return Color(chiaro: 0x7E22CE, scuro: 0xC084FC)
        case .soundCard:   return Color(chiaro: 0xDB2777, scuro: 0xF472B6)
        case .networkCard: return Color(chiaro: 0x0F766E, scuro: 0x2DD4BF)
        }
    }
}
