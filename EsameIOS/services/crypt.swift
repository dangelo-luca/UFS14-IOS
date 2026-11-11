import Foundation
import CryptoKit

func hashPassword(psw: String) -> String{
    guard let dati = psw.data(using: .utf8) else {return ""}

    let digest = SHA256.hash(data: dati)

    return digest.compactMap({String(format: "%02x", $0)}).joined()
}
