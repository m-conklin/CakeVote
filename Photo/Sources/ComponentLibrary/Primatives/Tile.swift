import CachedAsyncImage
import SwiftUI

public struct Tile: View {
    let url: URL
    @Binding var selected: Bool
    
    public init(
        url: URL,
        selected: Binding<Bool>
    ) {
        self.url = url
        _selected = selected
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            image
            checkbox
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .gesture(
            TapGesture()
                .onEnded {
                    selected.toggle()
                }
        )
    }
    
    @ViewBuilder
    private var checkbox: some View {
        Image(systemName: selected ? "heart.fill" : "heart")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 54, height: 54)
            .foregroundColor(.gray)
            .padding(10)
            .animation(.spring(), value: selected)
    }
    
    @ViewBuilder
    private var image: some View {
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
        CachedAsyncImage(urlRequest: request) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 14)
                .foregroundColor(.white)
        }
    }
}

struct Tile_Previews: PreviewProvider {
    
    static var previews: some View {
        Tile(url: URL(string: "https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=Mnw0MDU1OTB8MHwxfHNlYXJjaHwyfHxjYWtlfGVufDB8fHx8MTY3NTY2MDc3Ng&ixlib=rb-4.0.3&q=80&w=1080")!,
             selected: .constant(true)
        )
            .frame(width: 256, height: 256)
        Tile(url: URL(string: "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=Mnw0MDU1OTB8MHwxfHNlYXJjaHwxfHxjYWtlfGVufDB8fHx8MTY3NTY2MDc3Ng&ixlib=rb-4.0.3&q=80&w=1080")!,
             selected: .constant(false)
        )
            .frame(width: 256, height: 256)
    }
}
