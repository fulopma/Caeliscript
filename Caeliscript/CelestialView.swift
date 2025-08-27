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
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(viewModel.celestialBodies) { celestialBody in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(celestialBody.name ?? "Unknown Body")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom, 4)
                            let images: [CelestialImage] = celestialBody.associatedImages?.sortedArray(using:
                                [NSSortDescriptor(key: "id", ascending: false)]
                            ) as? [CelestialImage] ?? []
                            if !images.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(images) { image in
                                            CelestialCellImageView(image: image, viewModel: viewModel)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .frame(height: 320)
                            } else {
                                Text("No images available.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Celestial Bodies")
        }
    }
}

struct CelestialCellImageView: View {
    let image: CelestialImage
    var viewModel: CelestialViewModel
    var UIImage: UIImage?
    @State var isLoading = true
    @State var isPersisted: Bool
    @State var showFullImage = false
    init(image: CelestialImage, viewModel: CelestialViewModel) {
        self.image = image
        self.viewModel = viewModel
        isPersisted = image.shouldPersist
    }
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if !isLoading {
                            Image(uiImage: (UIKit.UIImage(data: image.imageData!) ?? UIKit.UIImage(systemName: "questionmark"))!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 220, height: 220)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            ProgressView()
                                .frame(width: 220, height: 220)
                        }
                    }
                    Button(action: {
                        image.shouldPersist.toggle()
                        isPersisted = image.shouldPersist
                    }, label: {
                        Image(systemName: image.shouldPersist ? "checkmark.circle.fill" : "arrow.down.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(isPersisted ? .green : .blue)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .padding(8)
                    })
                }
                Text(image.license ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(image.creater ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Button(action: {
                    showFullImage = true
                }, label: {
                    Text("Show Full Image")
                })
                .navigationDestination(isPresented: $showFullImage, destination: {
                    CelestialFullImageView(image)
                })
            }
            .frame(width: 220)
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.systemGray3), radius: 2, x: 0, y: 1)
            .task {
                if (image.imageData == nil) {
                    Task {
                        await viewModel.getImageData(for: image)
                        isLoading = false
                    }
                } else {
                    isLoading = false
                }
            }
        }
    }
}
#Preview {
    CelestialView()
}
