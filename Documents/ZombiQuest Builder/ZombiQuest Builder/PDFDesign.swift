//
//  PDFDesign.swift
//  ZombiQuest Builder
//
//  Created by Nash Clinton on 3/26/25.
//

import Foundation


import PDFKit
import CoreText

func drawTextWithCustomFont(context: CGContext, pageRect: CGRect) {
    // Load the custom font
    guard let customFontURL = Bundle.main.url(forResource: titleFont, withExtension: "ttf"),
          let fontData = try? Data(contentsOf: customFontURL),
          let provider = CGDataProvider(data: fontData as CFData),
          let cgFont = CGFont(provider) else {
        print("Failed to load the custom font.")
        return
    }

    // Register the font
    CTFontManagerCreateFontDescriptorsFromData(cgFont as! CFData)
    
    // Create the CTFont
    let font = CTFontCreateWithGraphicsFont(cgFont, 12.0, nil, nil) // Size 12.0
    
    // Set up the text style (using NSAttributedString)
    let text = "Hello, Custom Font!"
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: UIColor.black
    ]
    
    let attributedString = NSAttributedString(string: text, attributes: attributes)
    
    // Draw the text in the PDF context
    let textRect = CGRect(x: 50, y: pageRect.height - 100, width: pageRect.width - 100, height: 50)
    
    // Draw the attributed string in the PDF context
    attributedString.draw(in: textRect)
}

func generateTextGridImage(tiles: [Tile], imageSize: CGSize) -> UIImage? {
    let rows = 3
    let columns = 3
    let spacing: CGFloat = 2

    let totalWidth = CGFloat(columns) * imageSize.width + CGFloat(columns - 1) * spacing
    let totalHeight = CGFloat(rows) * imageSize.height + CGFloat(rows - 1) * spacing
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
    
    return renderer.image { context in
        for row in 0..<rows {
            for col in 0..<columns {
                let tileIndex = row * columns + col
                if tileIndex < tiles.count {
                    let tile = tiles[tileIndex]
                    
                    let x = CGFloat(col) * (imageSize.width + spacing)
                    let y = CGFloat(row) * (imageSize.height + spacing)
                    let rect = CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)

                    let text = tile.name
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: .font(.custom(titleFont, Size: 70)),
                        .foregroundColor: UIColor.black
                    ]
                    
                    let textRect = rect.insetBy(dx: 10, dy: 10)
                    text.draw(in: textRect, withAttributes: attributes)
                    
                    context.cgContext.setFillColor(UIColor.gray.withAlphaComponent(0.3).cgColor)
                    context.cgContext.fill(rect)
                    
                    context.cgContext.setFillColor(UIColor.gray.withAlphaComponent(0.3).cgColor)
                    context.cgContext.fill(rect)
                }
            }
        }
    }
}


func rotateImage(image: UIImage, degrees: Int) -> UIImage? {
    guard let cgImage = image.cgImage else {
        print("Error: Image does not have a valid cgImage.")
        return nil
    }

    var rotatedImage: UIImage?

    let normalizedDegrees = degrees % 360

    switch normalizedDegrees {
    case 90:
        rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
    case 180:
        rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
    case 270:
        rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
    default:
        rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
    
    print(normalizedDegrees)

    return rotatedImage
}
