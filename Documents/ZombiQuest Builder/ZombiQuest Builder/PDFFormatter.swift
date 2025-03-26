//
//  PDFFormatter.swift
//  ZombiQuest Builder
//
//  Created by Nash Clinton on 3/12/25.
//

import Foundation
import PDFKit

func createPdf(tiles: [Tile], materials: String, objectives: String, description: String, rules: String, tileSize: Int, title: String) -> URL? {
    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

    let format = UIGraphicsPDFRendererFormat()
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    let tileNames = tiles
    

    let textWidth: CGFloat = 250
    var textConstraints: CGFloat
    switch tileSize {
        case 1...3: textConstraints = 450
        case 4...6: textConstraints = 305
        default: textConstraints = 200
    }
    
    let totalContent =
        """
            \(description)
        
           Tiles Needed:
           \(tileDescription(tileNames))

           \(materials)
        
           Objectives: 
           \(objectives)
        
           Special Rules:
           \(rules)
        """
    

    let columns = splitTextIntoColumns(text: totalContent, font: UIFont.systemFont(ofSize: 14), columnWidth: textWidth, maxHeight: textConstraints)


    let pdfData = renderer.pdfData { context in
        if columns.count > 2 {
            twoPageFormatting(context: context, tiles: tiles, columns: columns, pageRect: pageRect, textWidth: textWidth, title: title)
        } else {
            onePageFormatting(context: context, tiles: tiles, columns: columns, pageRect: pageRect, textWidth: textWidth, title: title)
        }
    }

    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("GeneratedFlyer.pdf")
    
    do {
        try pdfData.write(to: tempURL)
        return tempURL
    } catch {
        print("Failed to save PDF: \(error)")
        return nil
    }
}


func tileDescription(_ tiles: [Tile]) -> String {
    var result = ""
    
    for (index, tile) in tiles.enumerated() {
        let cleanedName = tile.name.components(separatedBy: "\n").first ?? tile.name
        
        if index == tiles.count - 1 {
            result.append(cleanedName)
        } else {
            result.append(cleanedName + ", ")
        }
    }
    
    return result
}





func onePageFormatting(context: UIGraphicsPDFRendererContext, tiles: [Tile], columns: [String], pageRect: CGRect, textWidth: CGFloat, title: String) {
    context.beginPage()
    
    let titleAttribute = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 35)
    ]
    let questAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 30),
        .foregroundColor: UIColor.blue
    ]
    let contentAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14)
    ]
    
    let image = UIImage(named: "zombicideQuestBackground")!
    let questNum = "Quest 12:"
    let title = title


    image.draw(in: pageRect)
    drawLineBreak(in: context.cgContext, at: CGPoint(x: 45, y: 50), width: textWidth)
    questNum.draw(at: CGPoint(x: 50, y: 55), withAttributes: questAttribute)
    title.draw(at: CGPoint(x: 50, y: 100), withAttributes: titleAttribute)
    drawLineBreak(in: context.cgContext, at: CGPoint(x: 45, y: 150), width: textWidth)


    let leftSide = CGRect(x: 50, y: 170, width: textWidth, height: 550)
    let rightSide = CGRect(x: 310, y: 53, width: textWidth, height: 670)

    (columns[0] as NSString).draw(with: leftSide, options: .usesLineFragmentOrigin, attributes: contentAttribute, context: nil)
    
    if columns.count > 1 {
        (columns[1] as NSString).draw(with: rightSide, options: .usesLineFragmentOrigin, attributes: contentAttribute, context: nil)
    }
    mapImagesPageOne(context: context, tiles: tiles, pageRect: pageRect)
}

func twoPageFormatting(context: UIGraphicsPDFRendererContext, tiles: [Tile], columns: [String], pageRect: CGRect, textWidth: CGFloat, title: String) {
    context.beginPage()

    let titleAttribute = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 35)
    ]
    let questAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 30),
        .foregroundColor: UIColor.blue
    ]
    let contentAttribute: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14)
    ]

    let image = UIImage(named: "zombicideQuestBackground")!
    let questNum = "Quest 12:"
    let title = "Title"


    image.draw(in: pageRect)
    drawLineBreak(in: context.cgContext, at: CGPoint(x: 45, y: 50), width: textWidth)
    questNum.draw(at: CGPoint(x: 50, y: 55), withAttributes: questAttribute)
    title.draw(at: CGPoint(x: 50, y: 100), withAttributes: titleAttribute)
    drawLineBreak(in: context.cgContext, at: CGPoint(x: 45, y: 150), width: textWidth)


    let leftSide = CGRect(x: 50, y: 170, width: textWidth, height: 550)
    let rightSide = CGRect(x: 310, y: 53, width: textWidth, height: 670)

    (columns[0] as NSString).draw(with: leftSide, options: .usesLineFragmentOrigin, attributes: contentAttribute, context: nil)
    
    if columns.count > 1 {
        (columns[1] as NSString).draw(with: rightSide, options: .usesLineFragmentOrigin, attributes: contentAttribute, context: nil)
    }

    context.beginPage()
    
    image.draw(in: pageRect)

    let secondPageTextRect = CGRect(x: 50, y: 50, width: textWidth, height: 700)
    
    mapImagesPageTwo(context: context, tiles: tiles, pageRect: pageRect)
}
