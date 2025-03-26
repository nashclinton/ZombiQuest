import SwiftUI
import SwiftData

struct AddEditQuestView: View {
    @State var description: String = ""
    @State var objectives: [String] = ["Objective 1", "Objective 2", "Objective 3"]
    @State var specialRules: [String] = ["Rule 1", "Rule 2", "Rule 3"]
    @State var title: String = ""
    
    @StateObject private var pdfManager = PDFManager()
    @Query private var pdfs: [PDF]
    
    @Environment(\.modelContext) private var modelContext
    
    var selectedPDF: UUID
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Title", text: $title)
                    .frame(width: 340, height: 50, alignment: .center)
                    .multilineTextAlignment(.center)
                    .border(Color.accentColor, width: 1)
                    .onSubmit {
                        updatePDF()
                    }
                
                Text("Create A Story For This Adventure!")
                    .foregroundStyle(Color.accentColor)
                    .font(.custom(titleFont, size: 20))
                
                TextEditor(text: $description)
                    .frame(width: 340, height: 100)
                    .border(Color.accentColor, width: 1)
                    .padding()
                    .onChange(of: description) {
                        updatePDF()
                    }
                
                ListEditorSection(title: "Objectives", updatePDF: updatePDF, items: $objectives)
                
                ListEditorSection(title: "Special Rules", updatePDF: updatePDF, items: $specialRules)
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            loadPDF()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Done") {
                    PDFGenerationView(selectedPDF: selectedPDF)
                }
                .buttonStyle(SegueButton())
            }
        }
    }
    
    private func loadPDF() {
        if let pdf = pdfManager.getPDF(by: selectedPDF, pdfs: pdfs) {
            title = pdf.title
            description = pdf.content?.story ?? ""
            objectives = pdf.content?.objectives ?? []
            specialRules = pdf.content?.specialRules ?? []
        }
    }

   private func updatePDF() {
        Task {
            await pdfManager.updatePDF(
                selectedPDF,
                title: title,
                objectives: objectives,
                story: description,
                specialRules: specialRules,
                selectedGames: [],
                modelContext: modelContext, pdfs: pdfs
            )
            do {
                try modelContext.save()
            } catch {
                print("failed to save updated data")
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}


struct ListEditorSection: View {
    let title: String
    let updatePDF: () -> Void
    
    @Binding var items: [String]
    @State private var editingIndex: Int? = nil
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundStyle(Color.accentColor)
                    .font(.custom(bodyFont, size: 24))
                Spacer()
                Button(action: {
                    items.append("New \(title.dropLast())")
                }) {
                    Label("Add \(title.dropLast())", systemImage: "plus")
                }
                .buttonStyle(ConditionsButton())
            }
            .padding()
            
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        editingIndex = index
                        focusedIndex = index
                    }) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    if editingIndex == index {
                        TextField("Edit \(title.dropLast())", text: $items[index], onCommit: {
                            editingIndex = nil
                            updatePDF()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                        .focused($focusedIndex, equals: index)
                        .onAppear {
                            focusedIndex = index
                        }
                    } else {
                        Text(items[index])
                            .font(.custom(descriptionFont, size: 16))
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    Spacer()
                    
                    Button(action: { items.remove(at: index) }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
            }
        }
        .onTapGesture {
            editingIndex = nil
            focusedIndex = nil
        }
    }
}

extension UIApplication {

    func endEditing(_ force: Bool = false) {
        windows
            .filter { $0.isKeyWindow }
            .first?
            .endEditing(force)
    }
}
