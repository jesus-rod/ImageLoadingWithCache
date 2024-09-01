//
//  NetworkError.swift
//  ImageLoaderPlusCache
//
//  Created by JesusR on 01.09.24.
//

enum NetworkError: Error {
    case cancelled
    case noData
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .cancelled:
            "Request was cancelled"
        case .noData:
            "Data not available"
        case .unknown:
            "Unknown error"
        }
    }
}
