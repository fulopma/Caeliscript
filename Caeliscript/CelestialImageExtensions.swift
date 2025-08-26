//
//  CelestialImageExtensions.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/26/25.
//
import Foundation

enum LoadingState {
    case isLoading
    case loaded
    case error
}

extension CelestialImage {
    var loadingState: LoadingState {
        if let _ = self.imageData {
            return .loaded
        }
        else {
            return .isLoading
        }
    }
}
