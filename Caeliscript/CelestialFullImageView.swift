//
//  CelestialFullImageView.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/27/25.
//
import SwiftUI
import ImageViewer

struct CelestialFullImageView: View {
    let celestialImage: CelestialImage
    @State var isPersisted: Bool
    @State var uiImage: Image
    @State var showImageViewer = true
    let declination: NSDecimalNumber
    init(_ celestialImage: CelestialImage) {
        self.celestialImage = celestialImage
        isPersisted = celestialImage.shouldPersist
        declination = (celestialImage.associatedBody?.declination)!
        uiImage = Image(uiImage: UIImage(data: celestialImage.imageData!)!)
    }
    var body: some View {
        VStack {
            Text(celestialImage.associatedBody?.name ?? "Unknown Body")
            Text("\(declination)°")
            Text("\(celestialImage.license!)")
            Text("\(celestialImage.creater!)")
            
            Button(action: {
                celestialImage.shouldPersist.toggle()
                isPersisted = celestialImage.shouldPersist
            }, label: {
                Image(systemName: isPersisted ? "checkmark.circle.fill" : "arrow.down.circle")

                    .frame(width: 28, height: 28)
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(ImageViewer(image: self.$uiImage, viewerShown: self.$showImageViewer, closeButtonTopRight: true))
    }
}
