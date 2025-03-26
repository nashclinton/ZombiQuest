//
//  Tiles.swift
//  Zombicide Game Builder
//
//  Created by Nash Clinton on 1/8/25.
//

import Foundation
import SwiftUI


struct ImageMold: View {
    var tile: Tile
    @Binding var tiles: [Tile]

    var body: some View {
        ZStack {
            VStack {
                let components = tile.name.split(separator: "\n")
                let tileName = components.first ?? ""
                let sourceGame = components.count > 1 ? components.last ?? "" : ""
                let imageName = String(tileName + sourceGame)
                
                Image(uiImage: UIImage(named: imageName) ?? UIImage(named: "Test")!)
                    .resizable()
                    .frame(width: 125, height: 125)
                    .rotationEffect(Angle(degrees: Double(tile.rotation)))
                    .gesture(
                        TapGesture()
                            .onEnded {
                                withAnimation {
                                    rotateTile()
                                }
                            }
                    )
                    .padding(5)
            }
        }
    }
    
    private func rotateTile() {
        if let index = tiles.firstIndex(where: { $0.id == tile.id }) {
            tiles[index].rotation += 90
        }
    }
}




// MARK: If there is an API, this wouldn't exist.

class Tiles {
    static let shared = Tiles()
    
    var tiles: [Tile] = []

    private init() {
        // Generate tiles for each game
        tiles += createTiles(for: .BP, range: 1...9)
        tiles += createTiles(for: .WB, range: 10...11)
        tiles += createTiles(for: .GH, range: 12...20)
        tiles += createTiles(for: .FF, range: 21...25)
        tiles += createTiles(for: .NR, range: 26...30)
    }
    
    private func createTiles(for sourceGame: Tile.SourceGame, range: ClosedRange<Int>) -> [Tile] {
        return range.map { number in
            Tile(
                name: "\(number)",
                sourceGame: sourceGame
            )
        }
    }
}

