//
//  WordCloudImageView.swift
//  WordCloudDemo
//
//  Created by SHEN SHENG on 12/25/21.
//

import SwiftUI

struct WordCloudImageView: View {
    private let words: [WordElement] = [WordElement].generate()
    private let canvasSize = CGSize(width: 1024, height: 1024)
    
    var body: some View {
        Image(uiImage: wordCloudImage(words))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(10)
    }
    
    func wordCloudImage(_ words: [WordElement]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 1.0)
        
        var occupiedAreas = [CGRect]()
        for word in words {
            let textAttrs = [
                NSAttributedString.Key.font: UIFont(name: word.fontName, size: word.fontSize)!,
                NSAttributedString.Key.foregroundColor: word.color,
            ] as [NSAttributedString.Key : Any]
            
            // calculate rendered size
            let estimateSize = (word.text as NSString).size(withAttributes: textAttrs)
            
            let textRect = findSafePlace(for: estimateSize, avoid: occupiedAreas)
            word.text.draw(in: textRect, withAttributes: textAttrs)
            
            occupiedAreas.append(textRect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func findSafePlace(for size: CGSize, avoid occupiedAreas: [CGRect]) -> CGRect {
        // keep trying random places until it fit
        for _ in 0...100 {
            let randomRect = CGRect(origin: CGPoint(x: CGFloat.random(in: 0...canvasSize.width),
                                                    y: CGFloat.random(in: 0...canvasSize.height)),
                                    size: size)
            var collision = false
            for rect in occupiedAreas {
                if rect.intersects(randomRect) {
                    collision = true
                    break
                }
            }
            if !collision {
                return randomRect
            }
        }
        
        return CGRect.zero
    }
}

struct WordCloudImageView_Previews: PreviewProvider {
    static var previews: some View {
        WordCloudImageView()
    }
}
