import Foundation
import SwiftData

@Model
class PDF {
    @Attribute(.unique) var id: UUID
    var title: String
    var tiles: [Tile]?
    var fileData: FileData?
    var content: Quest?

    init(title: String, tiles: [Tile]? = nil, content: Quest? = nil, fileData: FileData? = nil) {
        self.id = UUID()  
        self.title = title
        self.tiles = tiles
        self.content = content
        self.fileData = fileData
    }
}


@Model
class Quest {
    @Attribute(.externalStorage) var objectivesData: String
    var story: String
    @Attribute(.externalStorage) var specialRulesData: String
    @Attribute(.externalStorage) var selectedGamesData: String
    
    var objectives: [String] {
        get { decodeJSON(objectivesData) ?? [] }
        set { objectivesData = encodeJSON(newValue) }
    }
    
    var specialRules: [String] {
        get { decodeJSON(specialRulesData) ?? [] }
        set { specialRulesData = encodeJSON(newValue) }
    }
    
    var selectedGames: [String] {
        get { decodeJSON(selectedGamesData) ?? [] }
        set { selectedGamesData = encodeJSON(newValue) }
    }
    
    init(objectives: [String], story: String, specialRules: [String], selectedGames: [String]) {
        self.objectivesData = encodeJSON(objectives)
        self.story = story
        self.specialRulesData = encodeJSON(specialRules)
        self.selectedGamesData = encodeJSON(selectedGames)
    }
}

func encodeJSON<T: Encodable>(_ value: T) -> String {
    guard let data = try? JSONEncoder().encode(value) else { return "[]" }
    return String(data: data, encoding: .utf8) ?? "[]"
}

func decodeJSON<T: Decodable>(_ json: String) -> T? {
    guard let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
}

@Model
class Tile: Identifiable {
    var name: String
    var sourceGame: SourceGame
    var side: Side
    var id: UUID
    var rotation: Double
    var orderIndex: Int

    enum SourceGame: String, CaseIterable, Codable {
        case GH = "Green Hoard"
        case BP = "Black Plague"
        case WB = "Wulfsburg"
        case FF = "Friends and Foes"
        case NR = "No Rest for the Wicked"
    }

    enum Side: String, Codable {
        case r, v, a, b
    }

    init(name: String, sourceGame: SourceGame, side: Side = .v, rotation: Double = 0, orderIndex: Int = 0) {
        self.name = name
        self.sourceGame = sourceGame
        self.side = side
        self.id = UUID()
        self.rotation = rotation
        self.orderIndex = orderIndex
    }
}

@Model
class FileData {
    var dateCreated: Date
    var dateModified: Date
    var fileName: String
    var fileSize: Int
    var pageNumber: Int

    init(dateCreated: Date, dateModified: Date, fileName: String, fileSize: Int, pageNumber: Int) {
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.fileName = fileName
        self.fileSize = fileSize
        self.pageNumber = pageNumber
    }
}
