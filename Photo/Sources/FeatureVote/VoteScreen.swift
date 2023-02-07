import ComposableArchitecture
import ComponentLibrary
import Models
import NavigationHelpers
import ServiceImage
import SwiftUI

public struct VoteEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let imageAPI: ImageAPI
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        imageAPI: ImageAPI
    ) {
        self.mainQueue = mainQueue
        self.imageAPI = imageAPI
    }
}

extension VoteEnvironment {
    public static let noop = VoteEnvironment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        imageAPI: .noop
    )
}

public enum VoteAction: Equatable {
    case onAppear
    case photosQueryResults(Result<PhotoResults, Failure>)
    case setSelection(String)
    case saveSelection(String, String)
    case tileDidAppear(String)
    case fetchNextPage
    case nextPageResults(Result<PhotoResults, Failure>)
    case dismiss
}

public struct VoteState: Equatable {
    let queryString: String
    var currentSelection: String
    
    var didAppear: Bool = false
    
    var photos: [Photo] = []
    var didLoadPhotos: Bool = false
    var didSelect: Bool = false
    
    var currentId: String = ""
    var currentPage: Int = 1
    var pageThreshold: Int = 10
    var loadingNextPage: Bool = false
    
    var fetchedIds: Set<String> = []
    var fetchedId: String = ""
        
    public init(
        queryString: String = "cake",
        currentSelection: String = ""
    ) {
        self.queryString = queryString
        self.currentSelection = currentSelection
    }
    
    var shouldFetchNextPage: Bool {
        guard !loadingNextPage else { return false }
        guard let currentIndex = photos.firstIndex(where: { $0.id == currentId}) else { return false }
        
        let thresholdIndex = photos.index(photos.endIndex, offsetBy: -pageThreshold)
        
        guard currentIndex == thresholdIndex, !fetchedIds.contains(currentId) else { return false }
        
        return true
    }
}

public let voteReducer = AnyReducer<VoteState, VoteAction, VoteEnvironment> { state, action, environment in
    switch action {
    case .onAppear:
        print("Vote view did appear")
        guard !state.didAppear else { return .none }
        state.didAppear = true
        
        return environment.imageAPI.searchPhotos(query: state.queryString)
            .receive(on: environment.mainQueue)
            .catchToEffect(VoteAction.photosQueryResults)
        
    case .photosQueryResults(.success(let queryResults)):
        state.photos = queryResults.results
        state.didLoadPhotos = true
        
        return .none
        
    case .photosQueryResults(.failure(let error)):
        print(error)
        return .none
        
    case .setSelection(let id):
        if state.currentSelection == id { state.currentSelection = "" }
        else {
            state.currentSelection = id
        }
        return Effect(value: .saveSelection(state.queryString, state.currentSelection))
        
    case .tileDidAppear(let id):
        state.currentId = id
        guard state.shouldFetchNextPage else { return .none}
        state.fetchedId = id
        return Effect(value: .fetchNextPage)
        
    case .fetchNextPage:
        state.loadingNextPage = true
        
        let page = state.currentPage + 1
        return environment.imageAPI.searchPhotos(query: state.queryString, page: page)
            .receive(on: environment.mainQueue)
            .catchToEffect(VoteAction.nextPageResults)
        
    case .nextPageResults(.success(let nextPage)):
        state.loadingNextPage = false
        
        
        state.currentPage += 1
        state.photos.append(contentsOf: nextPage.results)
        
        return .none
        
    case .nextPageResults(.failure(let error)):
        state.loadingNextPage = false
        print(error)
        return .none
    
    // Handled in rootReducer
    case .saveSelection:
        return .none

    // Handled in rootReducer
    case .dismiss:
        return .none
    }
}

public struct VoteScreen: View {
    let store: Store<VoteState, VoteAction>
        
    public init(store: Store<VoteState, VoteAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                header
                Spacer()
                if !viewStore.didLoadPhotos {
                    ProgressView()
                } else {
                    photos
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        WithViewStore(store) { viewStore in
            HStack {
                CircleButton(title: "chevron.backward") {
                    viewStore.send(.dismiss)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var photos: some View {
        let columns = [GridItem()]
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewStore.photos) { photo in
                        Tile(
                            url: URL(string: photo.urls.small)!,
                            selected: viewStore.binding(
                                get: { $0.currentSelection == photo.id },
                                send: { _ in VoteAction.setSelection(photo.id) }
                            )
                        )
                        .frame(width: 340)
                        .onAppear {
                            viewStore.send(.tileDidAppear(photo.id))
                        }
                    }
                }
            }
            
        }
    }
}

struct VoteScreen_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: VoteState(),
            reducer: voteReducer,
            environment: .noop
        )
        VoteScreen(store: store)
    }
}
