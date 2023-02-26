import ComposableArchitecture
import ComponentLibrary
import FeatureVote
import NavigationHelpers
import ServiceImage
import SwiftUI

public struct RootEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let imageAPI: ImageAPI
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        imageAPI: ImageAPI
    ) {
        self.mainQueue = mainQueue
        self.imageAPI = imageAPI
    }
    
    public static func live() -> Self {
        return Self(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            imageAPI: ImageAPI()
        )
    }
}

public enum RootAction: NavigationAction, Equatable {
    case onAppear
    case voteButtonTapped(String)
    case showSuccessToast(Bool)
    
    case voteScreen(VoteAction)
    
    case route(RouteIntent<RootRoute>?)
}

public enum RootRoute: NavigationRoute, Equatable {
    case vote
    
    @ViewBuilder
    public func destination(in store: Store<RootState, RootAction>) -> some View {
        switch self {
        case .vote:
            IfLetStore(
                store.scope(
                    state: \.voteState,
                    action: RootAction.voteScreen
                ),
                then: VoteScreen.init(store:)
            )
        }
    }
}

public struct RootState: NavigationState, Equatable {
    var queryString: String = "cake"
    var voteDict: [String : String] = [:]
    var voteState: VoteState?
    var showSuccessToast: Bool = false

    public var route: RouteIntent<RootRoute>?
    
    public init() {}
    
    var hasPlacedAllVotes: Bool {
        guard !voteDict.isEmpty,
               voteDict.keys.contains("wedding cake"),
               voteDict.keys.contains("birthday cake"),
               voteDict.keys.contains("innovative cake"),
               voteDict.keys.contains("cake"),
               voteDict.keys.contains("cup of tea"),
              !voteDict.values.contains("")
        else { return false }
                
        return true
    }
    
    var votedWeddingCake: Bool {
        return voteDict.keys.contains("wedding cake") && voteDict[""] != ""
    }
    
    var votedBirthdayCake: Bool {
        return voteDict.keys.contains("birthday cake") && voteDict["birthday cake"] != ""
    }
    
    var votedInnovativeCake: Bool {
        return voteDict.keys.contains("innovative cake") && voteDict["innovative cake"] != ""
    }
    
    var votedColorfulCake: Bool {
        return voteDict.keys.contains("cake") && voteDict["cake"] != ""
    }
    
    var votedCupOfTea: Bool {
        return voteDict.keys.contains("cup of tea") && voteDict["cup of tea"] != ""
    }
}

public let rootReducer = AnyReducer<RootState, RootAction, RootEnvironment>.combine(
    voteReducer
        .optional()
        .pullback(
            state: \RootState.voteState,
            action: /RootAction.voteScreen,
            environment: {
                VoteEnvironment(
                    mainQueue: $0.mainQueue,
                    imageAPI: $0.imageAPI
                )
            }
        ),
    .init { state, action, environment in
        switch action {
        case .onAppear:
            print("RootView did appear")
            return .none
            
        case .voteButtonTapped(let category):
            state.queryString = category
            state.voteState = .init(
                queryString: state.queryString,
                currentSelection: state.voteDict[category] ?? ""
            )
            return Effect(value: .route(.enter(into: .vote, context: .fullScreen)))
            
        case .showSuccessToast(let showToast):
            state.showSuccessToast = showToast
            return .none
            
        case .voteScreen(.saveSelection(let category, let id)):
            state.voteDict[category] = id
            return .none
            
        case .voteScreen(.dismiss):
            return Effect(value: .route(nil))
        
        case .voteScreen:
            return .none
            
        case .route(let route):
            state.route = route
            return .none
        }
    }
)

public struct RootView: View {
    let store: Store<RootState, RootAction>
    
    public init(store: Store<RootState, RootAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 18) {
                Spacer()
                Text("Vote for your favourite cakes!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                Spacer()
                PrimaryButton(title: "Vote for Best Wedding Cake", trailingImage: viewStore.votedWeddingCake ? Image(systemName: "checkmark.square") : nil) {
                    viewStore.send(.voteButtonTapped("wedding cake"))
                }
                PrimaryButton(title: "Vote for Best Birthday Cake", trailingImage: viewStore.votedBirthdayCake ? Image(systemName: "checkmark.square") : nil) {
                    viewStore.send(.voteButtonTapped("birthday cake"))
                }
                PrimaryButton(title: "Vote for Most Innovative Cake", trailingImage: viewStore.votedInnovativeCake ? Image(systemName: "checkmark.square") : nil) {
                    viewStore.send(.voteButtonTapped("innovative cake"))
                }
                PrimaryButton(title: "Vote for Most Colorful Cake", trailingImage: viewStore.votedColorfulCake ? Image(systemName: "checkmark.square") : nil) {
                    viewStore.send(.voteButtonTapped("cake"))
                }
                PrimaryButton(title: "Vote for Best Cup of Tea", trailingImage: viewStore.votedCupOfTea ? Image(systemName: "checkmark.square") : nil) {
                    viewStore.send(.voteButtonTapped("cup of tea"))
                }
                Spacer()
                PrimaryButton(title: viewStore.hasPlacedAllVotes ? "Submit your votes!" : "Vote in each category before submitting", invertColor: true) {
                    print("Votes submitted")
                    viewStore.send(.showSuccessToast(true))
                }
                .disabled(!viewStore.hasPlacedAllVotes)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
            .overlay() {
                successToast
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .navigationRoute(in: store)
        }
    }
    
    
    
    @ViewBuilder
    private var successToast: some View {
        WithViewStore(store) { viewStore in
            if viewStore.showSuccessToast {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundColor(.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.gray)
                        )
                    VStack {
                        HStack {
                            CircleButton(title: "xmark") {
                                viewStore.send(.showSuccessToast(false))
                            }
                            Spacer()
                        }
                        Spacer()
                        Text("Great, thanks for voting!")
                            .foregroundColor(.white)
                        Spacer()
                        PrimaryButton(title: "Dismiss") {
                            viewStore.send(.showSuccessToast(false))
                        }
                    }
                    .padding(12)
                }
                .frame(height: 600)
                .padding(8)
            } else {
                EmptyView()
            }
        }
    }
}
