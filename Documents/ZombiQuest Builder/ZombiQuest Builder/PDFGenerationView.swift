//
//  ContentView.swift
//  PDFTest
//
//  Created by Nash Clinton on 3/5/25.
//

import SwiftUI
import PDFKit
import SwiftData

struct PDFGenerationView: View {
    @State private var pdfUrl: URL? = nil
    @State private var pdf: PDF? = nil
    @StateObject private var pdfManager = PDFManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var pdfs: [PDF]

    var selectedPDF: UUID
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack {
                        HStack {
                            if let pdf = pdf {
                                Image(systemName: "doc.viewfinder")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                                Text("\(pdf.title).pdf")
                                    .foregroundColor(.accentColor)
                            } else {
                                ProgressView()
                            }
                        }
                        
                        Text("2.3MB * Created: Jan 15, 2025")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                        
                        if let pdfUrl = pdfUrl {
                            PDFKitView(url: pdfUrl)
                                .frame(height: 500)
                        } else {
                            ProgressView()
                                .frame(height: 500)
                        }
                    }
                    .onAppear {
                        Task {
                            await fetchPDF()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        VStack {
                            Button("Download PDF") { }
                                .buttonStyle(PDFViewButtons())
                            Button(action: {
                                print("Share tapped")
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(ShareButton())
                        }
                        Spacer()
                    }
                    .padding()
                }
                
                Section {
                    Text("Document Details")
                    HStack { Text("Created"); Spacer(); Text("12/31/2020") }
                    HStack { Text("Modified"); Spacer(); Text("12/31/2020") }
                    HStack { Text("Size"); Spacer(); Text("123.45 KB") }
                    HStack { Text("Pages"); Spacer(); Text("2") }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Print Quest") { }
                            .buttonStyle(PDFViewButtons())
                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            Task {
                await fetchPDF()
            }
        }
    }

    
    
    func fetchPDF() async {
        guard let pdf = pdfs.first(where: { $0.id == selectedPDF }) else {
            print("PDF not found")
            return
        }
        
        self.pdf = pdf
        
        if let pdfUrl = createPdf(
            tiles: (pdf.tiles ?? []).sorted { $0.orderIndex < $1.orderIndex },
            materials: gamesFormatting(pdf.content?.selectedGames ?? []),
            objectives: listFormatting(pdf.content?.objectives ?? []),
            description: pdf.content?.story ?? "",
            rules: listFormatting(pdf.content?.specialRules ?? []),
            tileSize: pdf.tiles?.count ?? 0,
            title: pdf.title
        ) {
            self.pdfUrl = pdfUrl
            print("fetched PDF")
        } else {
            print("Failed to generate PDF URL")
        }
    }

    func gamesFormatting(_ games: [String]) -> String {
        var result = ""
        for (index, item) in games.enumerated() {
            if index == games.count - 1 {
                result.append("and " + item)
            } else {
                result.append("Zombicide: " + item + ", ")
            }
        }
        return result
    }

    func listFormatting(_ list: [String]) -> String {
        return list.joined(separator: "\n")
    }

    struct PDFKitView: UIViewRepresentable {
        let url: URL

        func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
            let pdfView = PDFView()
            pdfView.document = PDFDocument(url: self.url)
            pdfView.autoScales = true
            pdfView.scaleFactor = 0.5
            return pdfView
        }

        func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) { }
    }
}



class TestContent {
    var title: String
    var author: String
    var materialsNeeded: String
    var tiles: [String]
    var objectives: String
    var description: String
    var specialRules: [String]
    var objectivesConstraints: CGRect

    init() {
        self.objectivesConstraints = CGRect(x: 40, y: 500, width: 240, height: 300)
        self.title = "The Final Stand: No Escape"
        self.author = "Nash Clinton"
        self.materialsNeeded = "\n\nZombicide: Black Plague and Zombicide: Wulfsburg."
        self.tiles =  ["1V", "2V", "3R", "4R", "5V", "6V", "8R", "10V"]

        self.objectives = """
        1. Secure the Safehouse. The undead will keep coming, so securing it fast is the priority. 
        2. Collect all necessary supplies before the nightfall—food, weapons, and medical kits.
        3. Survive for at least 10 full rounds of relentless zombie attacks.
        """

        self.description =
        "The apocalypse has left the city in ruin. Zombies prowl the streets, searching for any sign "

        self.specialRules =
            
            [
               " Special Rules:",
           " - Each survivor starts with one random weapon. Some weapons are more powerful than others.",
           " - At the start of each round, spawn two extra waves of zombies—one from the south entrance and another from the east.",
           " - Any survivor that ends their turn outside a building must roll a die. On a 1-2, they attract additional zombies.",
            "- If a survivor uses a firearm, the sound draws zombies to their location immediately.",
            "- The Safehouse doors are reinforced, and cannot be opened"
            ]
    }
}





