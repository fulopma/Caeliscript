//
//  NetworkLayer.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/25/25.
//
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case decodingFailed
    // no response from server
    case fetchFailed
    // server responds but with error like 4xx, 5xx
    case invalidFetchCode
}
public enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}
protocol Request {
    var baseURL: String { get set }
    var path: String { get set }
    var httpMethod: HttpMethod { get set }
    var params: [String: String] { get set }
    var header: [String: String] { get set }
}
extension Request {
    func createRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + path)
        urlComponents?.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let url = urlComponents?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = header
        return urlRequest
    }
}
protocol Networking {
    func execute<T: Decodable>(request: Request, modelName: T.Type, retries left: Int) async throws
        -> T
    func fetchRawData(endpoint: String) async throws -> Data
}
final class NetworkManager: Networking {
    private let urlSession: URLSession
    init() {
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    func execute<T>(request: any Request, modelName: T.Type, retries left: Int = 3) async throws -> T
    where T: Decodable {
        guard let urlRequest = request.createRequest() else {
            throw NetworkError.invalidURL
        }
        let data: Data
        var response: URLResponse?
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw NetworkError.invalidFetchCode
            }
        }
        guard let _ = response else {
            throw NetworkError.fetchFailed
        }
        do {
            return try JSONDecoder().decode(modelName.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    func fetchRawData(endpoint: String) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let urlRequest = URLRequest(url: url)
        let data: Data
        var response: URLResponse?
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw NetworkError.invalidFetchCode
            }
        }
        guard let _ = response else {
            throw NetworkError.fetchFailed
        }
        return data
    }
}

