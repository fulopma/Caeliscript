//
//  CelestialViewModel.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/25/25.
//
import Foundation

final class CelestialViewModel: ObservableObject {
    @Published var celestialBodies: [CelestialBody] = []
    private let repoLayer: LocalCelestialRepoLayer
    private let networkLayer: Networking
    init(networkLayer: Networking = NetworkManager()){
        self.networkLayer = networkLayer
        repoLayer = LocalCelestialRepoLayer(context: PersistenceController.shared.container.viewContext)
        #if DEBUG
        do {
            try repoLayer.removeNonPersisentImages()
            if try repoLayer.getCelestialBodiesSorted().count == 0 {
                addExampleData()
            }
        }
        catch {
            print("Error fetching celestial bodies: \(error)")
        }
        #endif
        do {
            celestialBodies = try repoLayer.getCelestialBodiesSorted()
        } catch {
            print("Error fetching celestial bodies: \(error)")
        }
    }
    func getImageData(for celestialImage: CelestialImage) async {
        do {
            try await repoLayer.downloadCelestialImage(for: celestialImage)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    func addExampleData() {
        do {
            try repoLayer.deleteAll()
            let andromeda = try repoLayer.addCelestialBody(name: "Andromeda", declination: 41.2692)
            try repoLayer.addCelestialImage(
                url: "https://upload.wikimedia.org/wikipedia/commons/5/57/M31-Andromede-16-09-2023-Hamois.jpg",
                license: "CC 2.0 Generic",
                creator: "Luc Viator",
                associatedBody: andromeda
            )
            try repoLayer.addCelestialImage(
                url: "https://upload.wikimedia.org/wikipedia/commons/e/eb/M31%2C_the_Andromeda_Galaxy%2C_Killarney_Provincial_Park_Observatory.jpg",
                license: "CC 4.0 International",
                creator: "Brucewaters",
                associatedBody: andromeda
            )
            let sirius = try repoLayer.addCelestialBody(name: "Sirius", declination: -16.7161)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/f/f3/Sirius_A_and_B_Hubble_photo.jpg", license: "Public Domain", creator: "NASA & ESA", associatedBody: sirius)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/d/d6/Sirius_A_%26_B_X-ray.jpg", license: "Public Domain", creator: "NASA", associatedBody: sirius)
            let eagleNebula = try repoLayer.addCelestialBody(name: "Eagle Nebula", declination: -13.786944)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/2/2b/Eagle_Nebula_from_ESO.jpg", license: "CC 4.0 International", creator: "European Southern Observatory", associatedBody: eagleNebula)
            try repoLayer.addCelestialImage(url: "https://stsci-opo.org/STScI-01GFNN3PWJMY4RQXKZ585BC4QH.png", license: "Public Domain", creator: "NASA, ESA, CSA, & STScI", associatedBody: eagleNebula)
            let sombreroGalaxy = try repoLayer.addCelestialBody(name: "Sombrero Galaxy", declination: -10.3769116)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/c/cc/Sombrero_Galaxy_%28heic2506a%29.jpg", license: "CC 4.0 International", creator: "ESA/Hubble", associatedBody: sombreroGalaxy)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/4/4b/Sombrero_Galaxy_%28MIRI_Image%29_%282024-137%29.png", license: "Public Domain", creator: "NASA, ESA, CSA, & STScI", associatedBody: sombreroGalaxy)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/5/50/Sombrero_Galaxy_%28NIRCam%29_%282025-127%29.jpg", license: "Public Domain", creator: "NASA, ESA, CSA, & STScI", associatedBody: sombreroGalaxy)
            let m87Blackhole = try repoLayer.addCelestialBody(name: "M87* Supermassive Blackhole", declination: 12.3911233)
            try repoLayer.addCelestialImage(url: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Black_hole_-_Messier_87_crop_max_res.jpg", license: "CC 4.0", creator: "Event Horizon Telescope Collaboration", associatedBody: m87Blackhole)
            
        } catch {
            print("\(error)")
        }
    }
    deinit {
        // remove data that should not persist
        do {
            try repoLayer.removeNonPersisentImages()
        }
        catch {
            print("\(error.localizedDescription)")
        }
    }
}
