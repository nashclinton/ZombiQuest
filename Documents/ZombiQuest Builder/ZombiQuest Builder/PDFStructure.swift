//
//  PDFDesigns.swift
//  PDFTest
//
//  Created by Nash Clinton on 3/5/25.
//

import Foundation
import PDFKit

import UIKit

func tileSourcing(_ tiles: [Tile]) -> [String] {
    var result: [String] = []
    for (index, tile) in tiles.enumerated() {
        let cleanedName = tile.name.replacingOccurrences(of: "\n", with: "")
        if index != tiles.count - 1 {
            result.append(cleanedName + ",")
        } else {
            result.append(cleanedName)
        }
    }
    return result
}

func tileImageName(_ tiles: [Tile]) -> [String] {
    var result: [String] = []
    for (index, tile) in tiles.enumerated() {
        let cleanedName = tile.name.replacingOccurrences(of: "\n", with: "")
        if index != tiles.count - 1 {
            result.append(cleanedName)
        } else {
            result.append(cleanedName)
        }
    }
    return result
}



func drawLineBreak(in context: CGContext, at position: CGPoint, width: CGFloat, color: UIColor = .black, lineWidth: CGFloat = 2.0) {
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(lineWidth)
    context.move(to: position)
    context.addLine(to: CGPoint(x: position.x + width, y: position.y))
    context.strokePath()
}

func mapImagesPageOne(context: UIGraphicsPDFRendererContext, tiles: [Tile], pageRect: CGRect) {
    
    let maxPerPage = 9
    let imagesPerRow = 3
    let imageSize = CGSize(width: 120, height: 120)
    
    let imageNames = tileImageName(tiles)
    
    let totalRows = min((tiles.count + 2) / imagesPerRow, 3)
    let tileGridHeight = CGFloat(totalRows) * imageSize.height
    
    
    if let itemsNeededImage = UIImage(named: "itemsNeeded") {
        let itemSize = CGSize(width: 250, height: 150)
        let itemRenderer = UIGraphicsImageRenderer(size: itemSize)
        
        let scaledItemImage = itemRenderer.image { _ in
            itemsNeededImage.draw(in: CGRect(origin: .zero, size: itemSize))
        }
        
        let itemYPosition = pageRect.height - tileGridHeight - itemSize.height - 60
        scaledItemImage.draw(at: CGPoint(x: 310, y: itemYPosition))
    }
    
    print("Tile image names: \(imageNames)")


    if let textGridImage = generateTextGridImage(tiles: tiles, imageSize: imageSize) {
        let itemYPosition = pageRect.height - tileGridHeight - imageSize.height - 60
        let gridRect = CGRect(x: 430, y: itemYPosition + 160, width: 100, height: 100)
        
        textGridImage.draw(in: gridRect)
    }
    
    for (index, tile) in tiles.enumerated() {
        print("Loading image: \(tile)")
        guard let image = UIImage(named: imageNames[index]) else {
            print("Error: Image for tile \(imageNames[index]) not found.")
            continue
        }

        if index % maxPerPage == 0 && index != 0 {
            context.beginPage()
        }

        let row = (index % maxPerPage) / imagesPerRow
        let col = (index % maxPerPage) % imagesPerRow
        let startY = pageRect.height - tileGridHeight - 60

        let position = CGPoint(
            x: CGFloat(50 + col * Int(imageSize.width)),
            y: startY + CGFloat(row * Int(imageSize.height))
        )

        let imageRect = CGRect(origin: position, size: imageSize)

        rotateImage(image: image, degrees: Int(tile.rotation))!.draw(in: imageRect)
    }
}




func mapImagesPageTwo(context: UIGraphicsPDFRendererContext, tiles: [Tile], pageRect: CGRect) {
    
    let maxPerPage = 9
    let imagesPerRow = 3
    let imageSize = CGSize(width: 150, height: 150)
    
    let totalRows = min((tiles.count + 2) / imagesPerRow, 3)
    let tileGridHeight = CGFloat(totalRows) * imageSize.height
    
    let imageNames = tileImageName(tiles)

    if let itemsNeededImage = UIImage(named: "itemsNeeded"), let tilePlacementImage = UIImage(named: "tilePlacementImage") {
        let targetSize = CGSize(width: 250, height: 150)
        let placementSize = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let placementRenderer = UIGraphicsImageRenderer(size: placementSize)
        
        let scaledItemImage = renderer.image { _ in
            itemsNeededImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        let scaledPlacementImage = placementRenderer.image { _ in
            tilePlacementImage.draw(in: CGRect(origin: .zero, size: placementSize))
        }
        
        let itemYPosition = (pageRect.height - tileGridHeight) / 2 - targetSize.height - 20
        scaledPlacementImage.draw(at: CGPoint(x: 80, y: itemYPosition + 50))
        scaledItemImage.draw(at: CGPoint(x: 280, y: itemYPosition))
    }
    print("Tile image names: \(imageNames)")

    for (index, tile) in tiles.enumerated() {
        print("Loading image: \(tile)")
        guard let image = UIImage(named: imageNames[index]) else {
            print("Error: Image for tile \(imageNames[index]) not found.")
            continue
        }

        if index % maxPerPage == 0 && index != 0 {
            context.beginPage()
        }

        let row = (index % maxPerPage) / imagesPerRow
        let col = (index % maxPerPage) % imagesPerRow

        let startX = (pageRect.width - (CGFloat(imagesPerRow) * imageSize.width)) / 2
        let startY = (pageRect.height - tileGridHeight) / 2

        let position = CGPoint(
            x: startX + CGFloat(col) * imageSize.width,
            y: startY + CGFloat(row) * imageSize.height
        )

        let imageRect = CGRect(origin: position, size: imageSize)
        rotateImage(image: image, degrees: Int(tile.rotation))!.draw(in: imageRect)
    }
}

typealias ColumnContent = [String]

func splitTextIntoColumns(text: String, font: UIFont, columnWidth: CGFloat, maxHeight: CGFloat) -> [String] {
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    
    var columns: [String] = []
    var currentText = ""
    var currentHeight: CGFloat = 0
    var columnIndex = 0
    
    let words = text.split(separator: " ")

    for word in words {
        let testText = (currentText.isEmpty ? "" : currentText + " ") + word
        let textSize = (testText as NSString).boundingRect(
            with: CGSize(width: columnWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        let maxHeightForColumn = ((columnIndex == 1) ? maxHeight + 120 : maxHeight)

        if textSize.height > maxHeightForColumn {
            columns.append(currentText.trimmingCharacters(in: .whitespaces))
            columnIndex += 1
            
            currentText = String(word)
            currentHeight = textSize.height
        } else {
            currentText = testText
            currentHeight = textSize.height
        }
    }

    if !currentText.isEmpty {
        columns.append(currentText.trimmingCharacters(in: .whitespaces))
    }

    print(columns)
    return columns
}
