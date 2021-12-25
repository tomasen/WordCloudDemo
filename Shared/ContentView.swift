//
//  ContentView.swift
//  Shared
//
//  Created by SHEN SHENG on 12/25/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: WordCloudImageView()){
                    Text("Word Cloud - UIImage")
                }
                
                Spacer()
                
                NavigationLink(destination: WordCloudView()){
                    Text("Word Cloud - SwiftUI")
                }
                
                Spacer()
            }
            
            EmptyView()
        }
    }
}

struct WordElement {
    let text: String
    let color: UIColor
    let fontName: String
    let fontSize: CGFloat
}

extension Array where Element == WordElement {
    static func generate(forSwiftUI: Bool = false) -> [WordElement] {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        var words = [WordElement]()
        for _ in 0...15 {
            words.append(
                WordElement(text: String((0...Int.random(in: 4...9)).map{ _ in letters.randomElement()! }),
                            color: UIColor(.purple),
                            fontName: "AvenirNext-Regular",
                            fontSize: forSwiftUI ? CGFloat.random(in:20...50) : CGFloat.random(in:50...150))
            )
        }
        return words
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
