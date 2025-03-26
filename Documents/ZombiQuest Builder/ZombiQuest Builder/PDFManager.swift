import Foundation
import SwiftUI
import SwiftData


@MainActor
class PDFManager: ObservableObject {
    @Published var currentPDF: PDF?
    
    var pdfs: [PDF] = []
    
    func addNewPDF(title: String, modelContext: ModelContext) async -> UUID {
        print("pdf was created")
        let newPDF = PDF(
            title: title,
            tiles: nil,
            content: nil,
            fileData: nil
        )
        
        modelContext.insert(newPDF)
        currentPDF = newPDF
        
        return newPDF.id
    }
    
    func getPDF(by id: UUID, pdfs: [PDF]) -> PDF? {
        print("Looking for PDF with ID: \(id)")
        if let foundPDF = pdfs.first(where: { $0.id == id }) {
            print("✅ Found PDF: \(foundPDF)")
            return foundPDF
        }
        print("❌ Failed to find PDF")
        return nil
    }
    
    func updatePDFMap(_ id: UUID, tiles: [Tile], modelContext: ModelContext, pdfs: [PDF]) async {
        guard let pdf = getPDF(by: id, pdfs: pdfs) else { print("failed to find pdf"); return }
        
        let sortedTiles = tiles.sorted { $0.orderIndex < $1.orderIndex }
        
        pdf.tiles = sortedTiles
        print("tiles to save \(tileImageName(sortedTiles))")
        print("pdf tiles updated")
        
        do {
            try modelContext.save()
            print("Model saved successfully.")
        } catch {
            print("Error saving model context: \(error)")
        }
    }
    
    func updatePDF(_ id: UUID, title: String, objectives: [String], story: String, specialRules: [String], selectedGames: [String], modelContext: ModelContext, pdfs: [PDF]) async {
        print("updatePDF was called")
        guard let pdf = getPDF(by: id, pdfs: pdfs) else { print("❌ Failed to find PDF"); return }
        
        if pdf.content == nil {
            pdf.content = Quest(objectives: objectives, story: story, specialRules: specialRules, selectedGames: selectedGames)
        } else {
            pdf.content?.objectives = objectives
            pdf.content?.story = story
            pdf.content?.specialRules = specialRules
            pdf.content?.selectedGames = selectedGames
        }
        
        pdf.title = title
        
        pdf.fileData?.dateModified = Date()

        do {
            try modelContext.save()
            print("✅ Pdf was updated and saved successfully")
        } catch {
            print("❌ Failed to save model context after update: \(error)")
        }
    }
    
    func deletePDF(at offsets: IndexSet, pdfs: [PDF], modelContext: ModelContext) async {
        withAnimation {
            let sortedOffsets = offsets.sorted(by: >)
            
            for index in sortedOffsets {
                if index < pdfs.count {
                    let pdfToDelete = pdfs[index]
                    print("PDf was deleted")
                    modelContext.delete(pdfToDelete)
                }
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to save model context after deletion: \(error)")
            }
        }
    }
}
