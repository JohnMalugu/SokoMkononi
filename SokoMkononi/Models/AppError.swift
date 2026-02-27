import Foundation

// MARK: - App Error Hierarchy

enum AppError: LocalizedError {
    case networkUnavailable
    case decodingFailed(String)
    case serverError(Int)
    case dataNotFound
    case storageFailure(String)
    case unknown(Error)
    
    var userFacingMessage: String {
        switch self {
        case .networkUnavailable:
            return "Hakuna mtandao. Tafadhali angalia muunganiko wako wa intaneti."
        case .decodingFailed(let detail):
            return "Hitilafu ya data: \(detail)"
        case .serverError(let code):
            return "Hitilafu ya seva (\(code)). Jaribu tena baadaye."
        case .dataNotFound:
            return "Hakuna data iliyopatikana."
        case .storageFailure(let detail):
            return "Hitilafu ya kuhifadhi: \(detail)"
        case .unknown(let error):
            return "Hitilafu isiyojulikana: \(error.localizedDescription)"
        }
    }
    
    var errorDescription: String? { userFacingMessage }
    
    var isRecoverable: Bool {
        switch self {
        case .networkUnavailable, .serverError: return true
        default: return false
        }
    }
}

// MARK: - Result extensions

extension Result where Failure == AppError {
    var value: Success? {
        if case .success(let v) = self { return v }
        return nil
    }
    
    var error: AppError? {
        if case .failure(let e) = self { return e }
        return nil
    }
}
