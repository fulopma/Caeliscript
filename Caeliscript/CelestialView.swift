//
//  ContentView.swift
//  Caeliscript
//
//  Created by Marcell Fulop on 8/25/25.
//

import SwiftUI
import CoreData

struct CelestialView: View {
    @StateObject var viewModel = CelestialViewModel()
    var body: some View {
        NavigationStack {
            List(viewModel.celestialBodies) { celestialBody in
                VStack(alignment: .center) {
                    Text(celestialBody.name ?? "")
                    let images: [CelestialImage] = celestialBody.associatedImages?.sortedArray(using:
                        [NSSortDescriptor(key: "id", ascending: false)]
                    )
                    as? [CelestialImage] ?? []
                    List{
                        ScrollView(.horizontal) {
                            HStack{
                                ForEach(images) { image in
                                    CelestialImageView(image: image, viewModel: viewModel)
                                }
                            }
                        }
                    }
                    .frame(height: 400)
                }
                
            }
        }
    }
}
struct CelestialImageView: View {
    let image: CelestialImage
    var viewModel: CelestialViewModel
    var UIImage: UIImage?
    init(image: CelestialImage, viewModel: CelestialViewModel) {
        self.image = image
        self.viewModel = viewModel
        if (image.license == "Public Domain" && image.imageData == nil) {
            Task {
                await viewModel.getImageData(for: image)
            }
        }
    }
    var body: some View {
        VStack {
            Text("\(image.license ?? "") \(image.creater ?? "")")
            if image.imageData != nil {
                Image(uiImage: (UIKit.UIImage(data: image.imageData!) ?? UIKit.UIImage(systemName: "questionmark"))!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 270)
            }
            else {
                //ProgressView()
                Image(systemName: "questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 270)
            }
           // Image(UIImage(data: viewModel.getImageData(for: image)))
        }
        .padding(10)
    }
}
#Preview {
    CelestialView()
}
