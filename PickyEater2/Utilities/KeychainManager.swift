import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private let userKey = "com.pickyeater.user"

    private init() {}

    func saveUser(_ user: User) throws {
        let data = try JSONEncoder().encode(user)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userKey,
            kSecValueData as String: data,
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    func loadUser() -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let user = try? JSONDecoder().decode(User.self, from: data)
        else {
            return nil
        }

        return user
    }

    func deleteUser() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userKey,
        ]

        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)

    var localizedDescription: String {
        switch self {
        case let .saveFailed(status):
            return "Failed to save to Keychain: \(status)"
        case let .loadFailed(status):
            return "Failed to load from Keychain: \(status)"
        case let .deleteFailed(status):
            return "Failed to delete from Keychain: \(status)"
        }
    }
}
