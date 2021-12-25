//
//  WordCloudView.swift
//  WordCloudDemo
//
//  Created by SHEN SHENG on 12/25/21.
//

import SwiftUI

struct WordCloudView: View {
    private let words: [WordElement] = [WordElement].generate(forSwiftUI: true)
    private var positionCache = WordCloudPositionCache()
    
    @State private var canvasRect = CGRect()
    @State private var wordSizes: [CGSize]
    
    init() {
        self._wordSizes = State(initialValue:[CGSize](repeating: CGSize.zero, count: words.count))
    }
    
    var body: some View {
        let pos = calcPositions(canvasSize: canvasRect.size, itemSizes: wordSizes)
        
        return ZStack{
            ForEach(Array(words.enumerated()), id: \.offset) {idx, word in
                NavigationLink(destination: Text("\(word.text)")) {
                    Text("\(word.text)")
                        .foregroundColor(Color(word.color))
                        .font(Font.custom(word.fontName,
                                          size:word.fontSize))
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(3)
                        .background(WordSizeGetter($wordSizes, idx))
                }
                .position(x: canvasRect.width/2 + pos[idx].x,
                          y: canvasRect.height/2 + pos[idx].y)
                
            }
        }
        .background(RectGetter($canvasRect))
    }
    
func checkIntersects(rect: CGRect, rects: [CGRect]) -> Bool {
    for r in rects {
        if rect.intersects(r) {
            return true
        }
    }
    return false
}

func simularWordSizes(a: [CGSize], b: [CGSize]) -> Bool {
    if a == b {
        return true
    }
    
    if a.count != b.count {
        return false
    }
    var diff : CGFloat = 0
    for i in 0...(a.count-1) {
        diff += abs(a[i].width - b[i].width) +
        abs(a[i].height - b[i].height)
    }
    
    return diff < 0.01
}

func checkOutsideBoundry(canvasSize: CGSize, rect: CGRect) -> Bool {
    if rect.maxY > canvasRect.height/2 {
        return true
    }
    if rect.minY < -canvasRect.height/2 {
        return true
    }
    return false
}

func calcPositions(canvasSize: CGSize, itemSizes: [CGSize]) -> [CGPoint] {
    var pos = [CGPoint](repeating: CGPoint.zero, count: itemSizes.count)
    if canvasSize.height == 0 {
        return pos
    }
    
    if positionCache.canvasSize == canvasSize
        && simularWordSizes(a: positionCache.wordSizes, b: wordSizes) {
        return positionCache.positions
    }
    defer {
        positionCache.canvasSize = canvasSize
        positionCache.wordSizes = wordSizes
        positionCache.positions = pos
    }
    
    var rects = [CGRect]()
    
    var step : CGFloat = 0
    let ratio = canvasSize.width * 1.5 / canvasSize.height
    
    let startPos = CGPoint(x: CGFloat.random(in: 0...1) * canvasSize.width * 0.1,
                           y: CGFloat.random(in: 0...1) * canvasSize.height * 0.1)
    
    for (index, itemSize) in itemSizes.enumerated() {
        var nextRect = CGRect(origin: CGPoint(x: startPos.x - itemSize.width/2,
                                              y: startPos.y - itemSize.height/2),
                              size: itemSize)
        if index > 0 {
            while checkOutsideBoundry(canvasSize: canvasSize,
                                      rect: nextRect)
                    || checkIntersects(rect: nextRect, rects: rects) {
                nextRect.origin.x = startPos.x + ratio * step * cos(step) + startPos.x - itemSize.width/2
                nextRect.origin.y = startPos.y + step * sin(step) + startPos.y - itemSize.height/2
                step = step + 0.01
            }
        }
        pos[index] = nextRect.center
        rects.append(nextRect)
    }
    return pos
}
}


class WordCloudPositionCache {
    var canvasSize = CGSize.zero
    var wordSizes = [CGSize]()
    var positions = [CGPoint]()
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(x: self.origin.x + self.size.width/2,
                       y: self.origin.y + self.size.height/2)
    }
}

struct WordSizeGetter: View {
    @Binding var sizeStorage: [CGSize]
    private var index: Int
    
    init(_ sizeStorage: Binding<[CGSize]>, _ index: Int) {
        _sizeStorage = sizeStorage
        self.index = index
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.sizeStorage[index] = proxy.frame(in: .global).size
        }
        
        return Rectangle().fill(Color.clear)
    }
}

struct RectGetter: View {
    @Binding var rect: CGRect
    
    init(_ rect: Binding<CGRect>) {
        _rect = rect
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        
        return Rectangle().fill(Color.clear)
    }
}

struct WordCloudView_Previews: PreviewProvider {
    static var previews: some View {
        WordCloudView()
    }
}
