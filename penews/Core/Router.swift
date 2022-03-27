//
//  Router.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import Alamofire

enum Router: URLRequestConvertible {
    
    // MARK: - Cases
    
    case everything(q: String? = nil, sources: String? = nil, sortBy: String? = nil)
    case topHeadlines(q: String? = nil, country: String? = nil, category: String? = nil, sources: String? = nil)
    case sources(category: String? = nil, country: String? = nil)
    
    
    // MARK: - URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        
        var routerCase = prepareRouterCase()
        
        let urlRequest = try Router.prepareUrlRequest(method: routerCase.method, path: routerCase.path)
        Router.prepareParameters(&routerCase.parameters)
        
        if let jsonObject = routerCase.jsonObject {
            
            let urlRequest = try URLEncoding(destination: .queryString).encode(urlRequest, with: routerCase.parameters)
            return try JSONEncoding.default.encode(urlRequest, withJSONObject: jsonObject)
        } else {
            
            return try URLEncoding.default.encode(urlRequest, with: routerCase.parameters)
        }
    }
    
    
    // MARK: - Methods
    
    func prepareRouterCase() -> (method: HTTPMethod, path: String, parameters: Parameters?, jsonObject: Any?) {
        
        let method: HTTPMethod = .get // var
        var path: String? = nil
        var parameters: Parameters? = nil
        let jsonObject: Any? = nil  // var
        
        switch self {
        
        case let .everything(q, sources, sortBy):
            path = "/everything"
            parameters = [:]
        
            if let q = q, !q.isEmpty {
                parameters?["q"] = q
            }
            if let sources = sources {
                parameters?["sources"] = sources
            }
            if let sortBy = sortBy {
                parameters?["sortBy"] = sortBy
            }
        
        case let .topHeadlines(q, country, category, sources):
            path = "/top-headlines"
            parameters = [:]
        
            if let q = q, !q.isEmpty {
                parameters?["q"] = q
            }
            if let country = country {
                
                parameters?["country"] = country
            } else if sources?.isEmpty ?? true {
                
                parameters?["country"] = "ua"
            }
            if let category = category {
                parameters?["category"] = category
            }
            if let sources = sources {
                parameters?["sources"] = sources
            }
            
        case let .sources(category, country):
            path = "/top-headlines/sources"
            parameters = [:]
        
            if let category = category {
                parameters?["category"] = category
            }
            if let country = country {
                parameters?["country"] = country
            }
        }
    
        return (method: method, path: path!, parameters: parameters, jsonObject: jsonObject)
    }
    
    
    // MARK: - Static methods
    
    static func prepareParameters(_ parameters: inout Parameters?) {
        
        if parameters == nil {
            
            parameters = [
                "apiKey": Api.apiKey,
            ]
            
        } else {
            
            parameters!["apiKey"] = Api.apiKey
        }
    }
    
    static func prepareUrlRequest(method: HTTPMethod, path: String) throws -> URLRequest {
        
        let baseUrl = try Api.baseUrl.asURL()
        
        var urlRequest = URLRequest(url: baseUrl.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}

