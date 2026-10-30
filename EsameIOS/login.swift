//
//  login.swift
//  EsameIOS
//
//  Created by s17 on 22/10/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Button("Accedi") {
                    // Logica di login
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer().frame(height: 20)
                
                NavigationLink(destination: RegistrationView()) {
                    HStack(spacing: 4) {
                        Text("Non hai un account?")
                            .foregroundColor(.secondary)
                        
                        Text("Registrati")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .font(.callout)
                }
            }
            .padding()
        }
    }
}



#Preview {
    LoginView()
}
