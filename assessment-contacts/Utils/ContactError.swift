//
//  ContactError.swift
//  assessment-contacts
//
//  Created by Andrew Elliott on 4/15/22.
//

import Foundation

enum ContactError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    case ckError(Error)
    
    var errorDescriptions: String? {
        switch self {
        case .invalidURL:
            return "Internal error. Please update Contacts or contact support."
        case .thrownError(let error):
            return error.localizedDescription
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        case .ckError(let error):
            return error.localizedDescription
        }
    }
}
