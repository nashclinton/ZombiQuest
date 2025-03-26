//
//  GenerateMapView.swift
//  ZombiQuest Builder
//
//  Created by Nash Clinton on 3/13/25.
//

import SwiftUI
import SwiftData

struct GenerateMapView: View {
    @State private var boardSize: Int = 0
    @State private var selectedGames: Set<Tile.SourceGame> = []
    @State private var isDropdownVisible: Bool = false
    @State private var randomizedTiles: [Tile] = []
    
    @Query var pdfs: [PDF]
    
    @State private var isLoaded: Bool = false
    @State private var canLoad: Bool = false
    
    @State var selectedPDF: UUID? = nil
    

    let games = Tile.SourceGame.allCases
    let tileColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    let textColumns: [GridItem] = Array(repeating: .init(.fixed(50), spacing: 2), count: 3)

    func updateCanLoad() {
        canLoad = !selectedGames.isEmpty && boardSize > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                GameSelectionView(
                    selectedGames: $selectedGames,
                    isDropdownVisible: $isDropdownVisible,
                    games: games,
                    canLoadUpdate: updateCanLoad
                )
                
                BoardSizeStepperView(boardSize: $boardSize, canLoadUpdate: updateCanLoad)
                
                Spacer()
                
                ActionButtonsView(
                    selectedPDF: $selectedPDF,
                    randomizedTiles: $randomizedTiles,
                    canLoad: canLoad,
                    isLoaded: isLoaded,
                    generateBoard: {
                        randomizedTiles = generateRandomTiles(boardSize: boardSize, allowedSourceGames: Array(selectedGames))
                        isLoaded = !randomizedTiles.isEmpty
                    }
                )
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                if isLoaded {
                    TileGridView(
                        randomizedTiles: randomizedTiles,
                        textColumns: textColumns,
                        tileColumns: tileColumns,
                        tiles: $randomizedTiles
                    )
                }
            }
            .padding()
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let selectedPDF = selectedPDF {
                        NavigationLink("Add Conditions") {
                            AddEditQuestView(selectedPDF: selectedPDF)
                        }
                        .buttonStyle(SegueButton())
                    }
                }
            }
        }
    }
}


struct GameSelectionView: View {
    @Binding var selectedGames: Set<Tile.SourceGame>
    @Binding var isDropdownVisible: Bool
    
    
    let games: [Tile.SourceGame]
    let canLoadUpdate: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isDropdownVisible.toggle()
                }
            }) {
                HStack {
                    Text(selectedGames.isEmpty ? "Select Games" : "\(selectedGames.count) Selected")
                        .font(.custom(titleFont, size: 17))
                        .foregroundColor(Color.accentColor)
                    Spacer()
                    Image(systemName: isDropdownVisible ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color.accentColor)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1))
            }
            
            if isDropdownVisible {
                VStack(spacing: 0) {
                    ForEach(games, id: \.self) { game in
                        Button(action: {
                            if selectedGames.contains(game) {
                                selectedGames.remove(game)
                            } else {
                                selectedGames.insert(game)
                            }
                            canLoadUpdate()
                        }) {
                            HStack {
                                Text(game.rawValue.capitalized)
                                    .fontWeight(.bold)
                                    .font(.custom(titleFont, size: 17))
                                    .foregroundColor(Color.accentColor)
                                Spacer()
                                if selectedGames.contains(game) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.accentColor)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1))
            }
        }
    }
}


struct BoardSizeStepperView: View {
    @Binding var boardSize: Int
    let canLoadUpdate: () -> Void
    
    var body: some View {
        VStack {
            
            CustomStepperView(boardSize: $boardSize, canLoadUpdate: canLoadUpdate)
                .padding(.vertical)
        }
    }
}

struct ActionButtonsView: View {
    @StateObject private var pdfManager = PDFManager()
    @Binding var selectedPDF: UUID?
    @Environment(\.modelContext) private var modelContext
    @Binding var randomizedTiles: [Tile]
    @Query var pdfs: [PDF]
    
    let canLoad: Bool
    let isLoaded: Bool
    let generateBoard: () -> Void

    var body: some View {
        HStack {
            Button("Generate Board") {
                generateBoard()
                Task {
                    if selectedPDF == nil {
                        await createNewPDF(modelContext: modelContext)
                        try modelContext.save()
                    }
                    await pdfManager.updatePDFMap(selectedPDF!, tiles: randomizedTiles, modelContext: modelContext, pdfs: pdfs)
                    try modelContext.save()
                }
            }
                .opacity(canLoad ? 1.0 : 0.5)
                .disabled(!canLoad)
                .buttonStyle(ActionButton())
        }
    }
    
    func createNewPDF(modelContext: ModelContext) async {
        let newPDFID = await pdfManager.addNewPDF(title: "Untitled", modelContext: modelContext)
        
        try? modelContext.save()
    
        self.selectedPDF = newPDFID
        print("New PDF created with ID: \(newPDFID)")
    }

}

struct TileGridView: View {
    let randomizedTiles: [Tile]
    let textColumns: [GridItem]
    let tileColumns: [GridItem]
    @Binding var tiles: [Tile]

    var body: some View {
        VStack {
            LazyVGrid(columns: textColumns, spacing: 2) {
                ForEach(randomizedTiles, id: \.name) { tile in
                    Text(tile.name)
                        .font(.custom(bodyFont, size: 16))
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.accentColor)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                }
            }
            .padding()
            
            LazyVGrid(columns: tileColumns, spacing: 0) {
                ForEach(randomizedTiles.indices, id: \.self) { index in
                    ImageMold(tile: randomizedTiles[index], tiles: $tiles)
                        .frame(width: 125, height: 125)
                }
            }
        }
    }
}

func generateRandomTiles(boardSize: Int, allowedSourceGames: [Tile.SourceGame]) -> [Tile] {
    var filteredTiles = Tiles.shared.tiles.filter { allowedSourceGames.contains($0.sourceGame) }
    var randomizedTiles: [Tile] = []
    let numberOfTiles = min(boardSize, filteredTiles.count)
    
    for index in 0..<numberOfTiles {
        if let tile = filteredTiles.randomElement() {
            var newTile = tile
            
            newTile.side = Bool.random() ? .r : .v
            newTile.rotation = [0, 90, 180, 270].randomElement() ?? 0
            
            let baseName = tile.name.filter { $0.isNumber }
            newTile.name = "\(baseName)\(newTile.side.rawValue.uppercased())\n\(tile.sourceGame)"
            
            newTile.orderIndex = index
            
            randomizedTiles.append(newTile)
            filteredTiles.removeAll { $0.name == tile.name && $0.sourceGame == tile.sourceGame }
        }
    }
    
    print("Generated tiles in order:", randomizedTiles.map { "\($0.orderIndex): \($0.name)" })
    return randomizedTiles
}

