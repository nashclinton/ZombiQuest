//
//  Styles.swift
//  ZombiQuest Builder
//
//  Created by Nash Clinton on 3/12/25.
//

import Foundation
import SwiftUI

let bodyFont = "Andalus"
let titleFont = "AlgoFYW01-Regular"
let descriptionFont = "Segoe Print"

struct PDFViewButtons: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(width: 300, height: 40, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
            .foregroundColor(.white)
    }
}

struct ShareButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(width: 300, height: 40, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
            .border(Color.black, width: 1)
            .foregroundColor(.accentColor)
    }
}

struct ConditionsButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(bodyFont, size: 18))
            .padding()
            .frame(width: 170, height: 40, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray3)))
            .foregroundColor(.accentColor)
    }
}



struct SegueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(Color.accentColor)))
            .foregroundColor(.white)
    }
}



struct ActionButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(descriptionFont, size: 14))
            .padding(8)
            .background(
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 120, height: 120)
            )
            .foregroundColor(.white)
    }
}

struct CustomStepperView: View {
    @Binding var boardSize: Int
    let canLoadUpdate: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                if boardSize > 0 {
                    boardSize -= 1
                    canLoadUpdate()
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 30))
            }

            Text("Board Size: \(boardSize)")
                .font(.custom(bodyFont, size: 24))
                .padding()

            Button(action: {
                if boardSize < 9 {
                    boardSize += 1
                    canLoadUpdate()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 30))
            }
        }
        .padding()
    }
}

