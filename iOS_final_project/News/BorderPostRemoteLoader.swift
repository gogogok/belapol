//
//  BorderPostRemoteLoader.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 17.03.26.
//

import Foundation

final class BorderPostsRemoteLoader {
    
    typealias Response = NewsModel.BorderResponse
    
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
    
    func reload(completion: @escaping (Result<[NewsModel.BorderPost], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(LoaderError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                200 ... 299 ~= httpResponse.statusCode
            else {
                DispatchQueue.main.async {
                    completion(.failure(LoaderError.badResponse))
                }
                return
            }
            
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(LoaderError.invalidData))
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        .resume()
    }
}
