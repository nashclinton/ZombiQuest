import SwiftUI
import SwiftData

struct MyQuestsView: View {
    @StateObject private var pdfManager = PDFManager()
    @Environment(\.modelContext) private var modelContext
    @Query var pdfs: [PDF]
    @State private var selectedPDF: UUID? = nil
    
    @State private var sheetToShow: SheetType? = nil
    
    enum SheetType: Identifiable {
        case newPDF
        case viewingPDF
        
        var id: String {
            switch self {
            case .newPDF:
                return "newPDF"
            case .viewingPDF:
                return "viewingPDF"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(pdfs) { pdf in
                        Button(action: {
                            selectedPDF = pdf.id
                            print("Selected PDF: \(String(describing: selectedPDF))")
                            sheetToShow = .viewingPDF
                        }) {
                            Text(pdf.title)
                        }
                    }
                    .onDelete { offsets in
                        Task {
                            await pdfManager.deletePDF(at: offsets, pdfs: pdfs, modelContext: modelContext)
                        }
                    }
                }
                .navigationTitle("My Quests")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                sheetToShow = .newPDF 
                            }
                    }
                }
                .foregroundColor(.accentColor)
            }
            .sheet(item: $sheetToShow) { sheetType in
                switch sheetType {
                case .newPDF:
                    GenerateMapView()
                        .environment(\.modelContext, modelContext)
                case .viewingPDF:
                    if let pdf = selectedPDF {
                        PDFGenerationView(selectedPDF: pdf)
                            .environment(\.modelContext, modelContext)
                    }
                }
            }
            .onChange(of: selectedPDF) {
                if selectedPDF != nil {
                    sheetToShow = .viewingPDF
                }
            }

        }
        .modelContext(modelContext)
    }
}

#Preview {
    MyQuestsView()
        .modelContainer(for: PDF.self, inMemory: true)
}
