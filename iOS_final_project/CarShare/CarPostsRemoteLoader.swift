//
//  CarPostsRemoteLoader.swift
//  iOS_final_project
//

import Foundation

final class CarPostsRemoteLoader {
    
    typealias Model = CarShareModel
    
    enum LoaderError: Error {
        case invalidURL
        case invalidData
        case badResponse
    }
    
    private let urlString: String
    private let session: URLSession
    
    init(urlString: String) {
        self.urlString = urlString
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 20
        
        self.session = URLSession(configuration: config)
    }
    
    func load(completion: @escaping (Result<[Model.CarPostDTO], Error>) -> Void) {
        requestPosts(completion: completion)
    }
    
    func reload(completion: @escaping (Result<[Model.CarPostDTO], Error>) -> Void) {
        requestPosts(completion: completion)
    }
    
    private func requestPosts(completion: @escaping (Result<[Model.CarPostDTO], Error>) -> Void) {
        guard var components = URLComponents(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(LoaderError.invalidURL))
            }
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "_ts", value: "\(Int(Date().timeIntervalSince1970))")
        ]
        
        guard let url = components.url else {
            DispatchQueue.main.async {
                completion(.failure(LoaderError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    completion(.failure(LoaderError.badResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(LoaderError.invalidData))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(Model.CarPostsResponseDTO.self, from: data)
                    completion(.success(decoded.posts))
                } catch {
                    completion(.failure(error))
                }
            }
        })
        
        task.resume()
    }
}
