import SwiftData
import Foundation

@Model
final class User: Identifiable {
    @Attribute(.unique) var email: String
    var name: String
    var surname: String
    var passwordHash: String

    var id: String { email }

    init(name: String, surname: String, email: String, passwordHash: String) {
        self.name = name
        self.surname = surname
        self.email = email
        self.passwordHash = passwordHash
    }

    @Relationship(deleteRule: .cascade, inverse: \Build.user)
    var builds: [Build] = []
}
