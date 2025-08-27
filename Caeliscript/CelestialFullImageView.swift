//
//  CelestialFullImageView.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/27/25.
//
import SwiftUI

struct CelestialFullImageView: View {
    let celestialImage: CelestialImage
    @State var isPersisted: Bool
    let declination: NSDecimalNumber
    init(_ celestialImage: CelestialImage) {
        self.celestialImage = celestialImage
        isPersisted = celestialImage.shouldPersist
        declination = (celestialImage.associatedBody?.declination)!
    }
    var body: some View {
        NavigationStack {
            VStack {
                Text(celestialImage.associatedBody?.name ?? "Unknown Body")
                Text("\(declination)°")
                Text("\(celestialImage.license!)")
                Text("\(celestialImage.creater!)")
                Image(uiImage: UIImage(data: celestialImage.imageData!)!)
                Button(action: {
                    celestialImage.shouldPersist.toggle()
                    isPersisted = celestialImage.shouldPersist
                }, label: {
                    Image(systemName: isPersisted ? "checkmark.circle.fill" : "arrow.down.circle")
 
                        .frame(width: 28, height: 28)
                })
            }
        }
        .navigationTitle(celestialImage.associatedBody?.name ?? "Unknown Body")
    }
}
