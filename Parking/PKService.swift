import Foundation
import Alamofire
import Accounts
import MapKit
import SwiftyJSON
import Dispatch

class PKService {
    var loggedIn: Bool {
        return token != nil
    }
    
    lazy var config: [String: Any] = {
        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let dictionary = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        
        return dictionary
    }()
    lazy var rootEndpoint: URL = {
        return URL(string: self.config["endpoint"] as! String)!
    }()
    lazy var appId: String = {
        let value = self.config["facebookAppId"]! as! String
        return value
    }()
    
    var token: String? {
        return PKKeychain.get(key: "pkserver")
    }
    
    func login(completionHandler: @escaping (_ result: Result<Void>) -> Void) {
        let store = ACAccountStore()
        let facebook = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
        store.requestAccessToAccounts(with: facebook, options: [ACFacebookAppIdKey: appId, ACFacebookPermissionsKey: []], completion: { granted, error in
            if let _ = error {
                completionHandler(.error("無法取得 Facebook 資訊，請確認是否有在系統設定中設定 Facebook 帳號。"))
            } else if granted {
                if let accounts = store.accounts(with: facebook) as? [ACAccount] {
                    if accounts.count > 0 {
                        let facebookAccount = accounts[0]
                        let token = facebookAccount.credential.oauthToken!
                        
                        // PKServer
                        let url = URL(string: "auth/facebook", relativeTo: self.rootEndpoint)!
                        var request = try! URLRequest(url: url, method: .post)
                        let json = [ "scope": "standard", "accessToken": token ] as JSON
                        request.httpBody = try! json.rawData()
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        Alamofire.request(request).responseString(queue: nil) { data in
                            if let _ = data.error {
                                completionHandler(.error("Parking 系統錯誤"))
                            } else if let data = data.result.value {
                                _ = PKKeychain.set(key: "pkserver", value: data)
                                completionHandler(.success())
                            }
                        }
                    }
                }
            } else {
                completionHandler(.error("未知的錯誤"))
            }
        })
    }
    
    func spaces(in rect: MKCoordinateRegion, completionHandler: @escaping (Result<[PKSpace]>) -> Void) {
        let lowerLatitude = floor((rect.center.latitude - rect.span.latitudeDelta) * 100.0) / 100.0
        let upperLatitude = ceil((rect.center.latitude + rect.span.latitudeDelta) * 100.0) / 100.0
        let lowerLongitude = floor((rect.center.longitude - rect.span.longitudeDelta) * 100.0) / 100.0
        let upperLongitude = ceil((rect.center.longitude + rect.span.longitudeDelta) * 100.0) / 100.0
        
        let spec = String(format: "%.2f-%.2f:%.2f-%.2f", lowerLatitude, upperLatitude, lowerLongitude, upperLongitude)
        var request = makeRequest(on: "/spaces", with: ["grids": spec])
        request.httpMethod = "GET"
        
        Alamofire.request(request).PKResponse { response in
            if case let .error(code, error) = response {
                if code == 11 {
                    completionHandler(.error("請放大地圖到理想位置，應用程式無法載入此區域的資料。"))
                } else {
                    completionHandler(.error(error))
                }
            } else if case let .success(json) = response {
                var hasDeserializationError = false
                let result = json.arrayValue.map { object -> PKSpace? in
                    let result = object.pkspace
                    if result == nil {
                        hasDeserializationError = true
                    }
                    return result
                }
                
                if hasDeserializationError {
                    completionHandler(.error("資料序列錯誤"))
                } else {
                    completionHandler(.success(result.map { $0! }))
                }
            }
        }
    }
    
    func space(id: String, completionHandler: @escaping (Result<PKSpace>) -> Void ) {
        var request = makeRequest(on: "/spaces/\(id)")
        request.httpMethod = "GET"
        Alamofire.request(request).PKResponse { response in
            if case let .error(_, error) = response {
                completionHandler(.error(error))
            } else if case let .success(json) = response {
                guard let result = json.pkspace else {
                    completionHandler(.error("資料序列錯誤"))
                    return
                }
                
                completionHandler(.success(result))
            }
        }
    }
    
    func reservations(completionHandler: @escaping (Result<[PKReservation]>) -> Void) {
        var request = makeRequest(on: "reservations")
        request.httpMethod = "GET"
        
        Alamofire.request(request).PKResponse { response in
            switch response {
            case .error(_):
                completionHandler(.error(nil))
            case let .success(json):
                var hasDeserializationError = false
                let result = json.arrayValue.map { object -> PKReservation? in
                    let result = object.pkreservation
                    if result == nil {
                        hasDeserializationError = true
                    }
                    return result
                }
                
                if hasDeserializationError {
                    completionHandler(.error("資料序列錯誤"))
                } else {
                    completionHandler(.success(result.map { $0! }))
                }
            }
        }
    }
    func makeReservation(in grid: CLLocationCoordinate2D, on date: Date, completionHandler: @escaping (Result<Void>) -> Void) {
        let body: JSON = [
            "time": ISO8601DateFormatter().string(from: date),
            "grid": grid.normalized().spec
        ]
        
        var request = makeRequest(on: "reservations")
        request.httpMethod = "POST"
        request.httpBody = try? body.rawData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).PKResponse { response in
            switch response {
            case .error(_):
                completionHandler(.error(nil))
            case .success(_):
                completionHandler(.success())
            }
        }
    }
    func cancel(_ reservation: PKReservation, completionHandler: @escaping (Result<Void>) -> Void) {
        var request = makeRequest(on: "reservations/\(reservation._id)")
        request.httpMethod = "DELETE"
        
        Alamofire.request(request).PKResponse { response in
            switch response {
            case .error(_):
                completionHandler(.error(nil))
            case .success(_):
                completionHandler(.success())
            }
        }
    }
    func parkings(completionHandler: @escaping (Result<[PKParking]>) -> Void) {
        var request = makeRequest(on: "parking")
        request.httpMethod = "GET"
        
        Alamofire.request(request).PKResponse { response in
            switch response {
            case .error(_):
                completionHandler(.error(nil))
            case let .success(json):
                var hasDeserializationError = false
                let result = json.arrayValue.map { object -> PKParking? in
                    let result = object.pkparking
                    if result == nil {
                        hasDeserializationError = true
                    }
                    return result
                }
                
                if hasDeserializationError {
                    completionHandler(.error("資料序列錯誤"))
                } else {
                    completionHandler(.success(result.map { $0! }))
                }
            }
        }
    }
    func records(completionHandler: @escaping (Result<[PKRecord]>) -> Void) {
        var request = makeRequest(on: "records")
        request.httpMethod = "GET"
        
        Alamofire.request(request).PKResponse { response in
            switch response {
            case .error(_):
                completionHandler(.error(nil))
            case let .success(json):
                var hasDeserializationError = false
                let result = json.arrayValue.map { object -> PKRecord? in
                    let result = object.pkrecord
                    if result == nil {
                        hasDeserializationError = true
                    }
                    return result
                }
                
                if hasDeserializationError {
                    completionHandler(.error("資料序列錯誤"))
                } else {
                    completionHandler(.success(result.map { $0! }))
                }
            }
        }
    }
    func makeRequest(on path: String, with queries: [String: String] = [:]) -> URLRequest {
        let url = URL(string: path, relativeTo: self.rootEndpoint)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = queries.map { key, value in URLQueryItem(name: key, value: value) }
        var request = URLRequest(url: try! components.asURL())
        request.addValue(token!, forHTTPHeaderField: "token")
        
        return request
    }
}

enum APIResult {
    case success(JSON)
    case error(Int, String)
}
extension DataRequest {
    @discardableResult
    func PKResponse(completionHandler: @escaping (APIResult) -> Void) -> Self {
        self.responseData { response in
            if let error = response.error {
                completionHandler(.error(-1, "network error: " + error.localizedDescription))
                return
            } else if let data = response.value {
                let json = JSON(data: data)
                if let error = json["error"].string,
                    let code = json["code"].int {
                    completionHandler(.error(code, error))
                } else {
                    completionHandler(.success(json))
                }
            } else {
                completionHandler(.error(-1, "unknown error"))
            }
        }
        
        return self
    }
}
