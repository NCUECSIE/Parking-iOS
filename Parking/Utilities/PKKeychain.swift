import Security
import Foundation

class PKKeychain {
    internal enum PKKeychainSaveResult {
        case success
        case failed
    }
    class func set(key: String, value: String) -> PKKeychainSaveResult {
        guard let data = value.data(using: .utf8) else {
            return .failed
        }
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete((query as CFDictionary))
        let result = SecItemAdd(query as CFDictionary, nil)
        
        if result == errSecSuccess {
            return .success
        } else {
            return .failed
        }
    }
    class func get(key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            let data = dataTypeRef as! Data?
            if let data = data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    class func delete(key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
    }
}
