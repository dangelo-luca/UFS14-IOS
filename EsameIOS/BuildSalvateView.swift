//
//  BuildSalvateView.swift
//  EsameIOS
//
//  Created by d13 on 13/10/26.
//

import SwiftUI

struct BuildSalvateView: View {
    @State var testo: String = ""
        @State var risultati: [Risultato] = []
        @State var isPressed2: Bool = false   // serve comunque come parametro, ma qui non viene usato

        var body: some View {
            NavigationStack {
                VStack {
                    List(risultati) { r in
                        Text("\(r.categoria): \(r.nome)")
                    }

                    NavBar(placeholder: "Cerca",
                           cerca: ["cpu", "case"],
                           style: .senzaPiu,
                           testo: $testo,
                           risultati: $risultati,
                           isPressed2: $isPressed2)
                }
            }
        }
}

#Preview {
    BuildSalvateView()
}
