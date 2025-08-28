//
//  LocalRepoLayer.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/26/25.
//

import CoreData
import SwiftData

final class LocalCelestialRepoLayer {
    private let context: NSManagedObjectContext
    private let networkLayer: Networking = NetworkManager()
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func addCelestialBody(name: String, declination: Double) throws -> CelestialBody {
        let newCelestialBody = CelestialBody(context: context)
        newCelestialBody.id = UUID()
        newCelestialBody.name = name
        newCelestialBody.declination = NSDecimalNumber(decimal: Decimal(declination))
        try saveContext()
        return newCelestialBody
    }
    private func saveContext() throws {
        
        do {
            try context.save()
        }
        catch {
            throw NSError(domain: "Could not save MOContext", code: 999)
        }
        
    }
    
    func addCelestialImage(url: String, license: String, creator: String, associatedBody: CelestialBody) throws  {
        let newCelestialImage = CelestialImage(context: context)
        newCelestialImage.url = url
        newCelestialImage.license = license
        newCelestialImage.creater = creator
        newCelestialImage.timestamp = Date()
        newCelestialImage.id = UUID()
        newCelestialImage.shouldPersist = false
        associatedBody.associatedImages = (associatedBody.associatedImages ?? []).adding(newCelestialImage) as NSSet
        try saveContext()
       // return newCelestialImage
    }
    func addCelestialImage(url: String, license: String, creator: String,
                           associatedBodyId: UUID) throws -> CelestialImage {
        let newCelestialImage = CelestialImage(context: context)
        newCelestialImage.url = url
        newCelestialImage.license = license
        newCelestialImage.creater = creator
        newCelestialImage.timestamp = Date()
        newCelestialImage.id = UUID()
        newCelestialImage.shouldPersist = false
        let request = CelestialBody.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", associatedBodyId.uuidString)
        guard let celestialBody = try context.fetch(request).first else {
            throw NSError(domain: "Could not save context \(associatedBodyId)", code: 998)
        }
        celestialBody.associatedImages? = (celestialBody.associatedImages ?? []).adding(newCelestialImage) as NSSet
        try saveContext()
        return newCelestialImage
    }
    func getCelestialBodiesSorted() throws -> [CelestialBody] {
        let request: NSFetchRequest<CelestialBody> = CelestialBody.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        return try context.fetch(request)
    }
    func deleteCelestialBody(id: UUID) throws {
        let request: NSFetchRequest<CelestialBody> = CelestialBody.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        guard let celestialBodyToDelete = try context.fetch(request).first else {
            throw NSError(domain: "Could not find celestial body to delete \(id)", code: 997)
        }
        context.delete(celestialBodyToDelete)
        try saveContext()
    }
    func deleteCelestialImage(id: UUID) throws {
        let request: NSFetchRequest<CelestialImage> = CelestialImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        guard let celestialImageToDelete = try context.fetch(request).first else {
            throw NSError(domain: "Could not delete Celestial Image \(id)", code: 996)
        }
        context.delete(celestialImageToDelete)
        try saveContext()
    }
    func downloadCelestialImage(for celestialImageId: UUID) async throws {
        let request: NSFetchRequest<CelestialImage> = CelestialImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", celestialImageId.uuidString)
        guard let celestialImageToDownload = try context.fetch(request).first else {
            throw NSError(domain: "Could not download Celestial Image \(celestialImageId)", code: 995)
        }
        celestialImageToDownload.imageData = try await networkLayer.fetchRawData(endpoint: celestialImageToDownload.url ?? "")
        try saveContext()
    }
    func downloadCelestialImage(for celestialImage: CelestialImage) async throws {
        celestialImage.imageData = try await networkLayer.fetchRawData(endpoint: celestialImage.url ?? "")
        DispatchQueue.main.async {
            do {
                try self.saveContext()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    func deleteAll() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = CelestialBody.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(batchDeleteRequest)
        }
        catch {
            throw NSError(domain: "Could not TRUNCATE database tables", code: 994)
        }
    }
    func removeNonPersisentImages() throws {
        let fetchRequest: NSFetchRequest<CelestialImage> = CelestialImage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "shouldPersist == %@", NSNumber(value: false))
        let images = try context.fetch(fetchRequest)
        for image in images {
            image.imageData = nil
        }
        try saveContext()
        
    }
}
