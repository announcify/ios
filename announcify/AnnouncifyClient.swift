import Foundation

protocol AnnouncifyClientDelegate {
    func message(announcement: AnnouncifyAnnouncement)
    func noMessage()
    func fail(error: Error)
}

class AnnouncifyClient {
    
    private let host: String
    private let apiKey: String
    private let projectId: Int
    private let locale: Locale
    private let delegate: Delegate
    
    init(host: String, apiKey: String, projectId: Int, locale: Locale, delegate: Delegate) {
        self.host = host
        self.apiKey = apiKey
        self.projectId = projectId
        self.locale = locale
        self.delegate = delegate //TODO: rename to (completion) handler: completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    }
    
    func request() {
        let url = URL(string: "https://\(host)/projects/\(projectId)/active-announcement/active-message")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(toLanguageTag(locale: locale), forHTTPHeaderField: "accept-language")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if statusCode == 404 {
                    print("[Announcify] No active announcement available.")
                    self.delegate.noMessage()
                    return
                }
                
                if statusCode != 200 {
                    print("[Announcify] Request active announcement failed with HTTP error \(statusCode)!")
                    self.delegate.fail(error: AnnouncifyError.requestError("Request active announcement failed. Status code: \(statusCode)!"))
                    return
                }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let announcement = try jsonDecoder.decode(AnnouncifyAnnouncement.self, from: data!)
                    self.delegate.message(announcement: announcement)
                    print("[Announcify] Found active announcement \(announcement)!")
                } catch {
                    print("[Announcify] Parsing announcement response failed! \(error)")
                    self.delegate.fail(error: error)
                }
            }
        }.resume()
    }
    
    private func toLanguageTag(locale: Locale) -> String {
        let language = locale.languageCode ?? "en"
        let country = locale.regionCode ?? "US"
        return "\(language)_\(country)"
    }
    
    class Builder {
        
        private let defaultHost = "api.announcify.io"
        private var host: String? = nil
        private var apiKey: String? = nil
        private var projectId: Int? = nil
        private var locale: Locale? = nil
        private var delegate: Delegate? = nil
        
        func set(host: String) -> Builder {
            self.host = host
            return self
        }
        
        func set(apiKey: String) -> Builder {
            self.apiKey = apiKey
            return self
        }
        
        func set(projectId: Int) -> Builder {
            self.projectId = projectId
            return self
        }
        
        func set(delegate: Delegate) -> Builder {
            self.delegate = delegate
            return self
        }
        
        func build() throws -> AnnouncifyClient {
            let host = self.host ?? defaultHost
            
            // TODO: read from info.p
            guard let apiKey = self.apiKey else {
                throw AnnouncifyError.illegalArgumentError("Argument `apiKey` is required and must be set!")
            }
            
            // TODO: read from info.p
            guard let projectId = self.projectId else {
                throw AnnouncifyError.illegalArgumentError("Argument `projectId` is required and must be set!")
            }
            
            guard let delegate = self.delegate else {
                throw AnnouncifyError.illegalArgumentError("Argument `delegate` is required and must be set!")
            }
            
            let locale = self.locale ?? Locale.current
            
            return AnnouncifyClient(
                host: host,
                apiKey: apiKey,
                projectId: projectId,
                locale: locale,
                delegate: delegate)
        }
    }
    
    typealias Delegate = AnnouncifyClientDelegate
}
