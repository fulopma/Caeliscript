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
                .padding(0)
            }
        }
    }
}
struct CelestialImageView: View {
    let image: CelestialImage
    var viewModel: CelestialViewModel
    var UIImage: UIImage?
    @State var isLoading: Bool = true
    @State var isPersisted: Bool
    init(image: CelestialImage, viewModel: CelestialViewModel) {
        self.image = image
        self.viewModel = viewModel
        isPersisted = image.shouldPersist
    }
    var body: some View {
        VStack {
            Text("\(image.license ?? "") \(image.creater ?? "")")
                .font(.caption)
            if !isLoading{
                ZStack(alignment: .bottomTrailing){
                    Image(uiImage: (UIKit.UIImage(data: image.imageData!) ?? UIKit.UIImage(systemName: "questionmark"))!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 270)
                        .clipped()
                    Button(action: {
                        // shouldPersist does not support binding
                        // which is why we need a duplicate data that basically copies
                        // shouldPersist but supports reactive programming
                        image.shouldPersist.toggle()
                        isPersisted = image.shouldPersist
                    }, label: {
                        if !isPersisted {
                            Image(systemName: "arrow.down.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }
                        else {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }
                    })
                }
            }
            else {
                ProgressView()
                    .frame(width: 200, height: 270)
            }
        }
        .padding(10)
        .task {
            if ( image.imageData == nil) {
                Task {
                    await viewModel.getImageData(for: image)
                    isLoading = false
                }
            }
            else {
                isLoading = false
            }
        }
    }
}
#Preview {
    CelestialView()
}
