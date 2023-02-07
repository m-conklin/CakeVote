import Combine
import ComposableArchitecture
import Models
import NavigationHelpers
@testable import FeatureApp
import XCTest

final class FeatureAppTests: XCTestCase {
    func testVoteButtonTapped() throws {
        let scheduler = DispatchQueue.test
        let store = TestStore(
            initialState: RootState(),
            reducer: rootReducer,
            environment: RootEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                imageAPI: .noop
            )
        )
        
        store.send(.voteButtonTapped("cake")) {
            $0.queryString = "cake"
            $0.voteState = .init(
                queryString: "cake",
                currentSelection: ""
            )
        }
        
        store.receive(.route(.enter(into: .vote, context: .fullScreen))) {
            $0.route = RouteIntent(
                route: RootRoute.vote,
                action: RouteIntent.Action.enterInto(.fullScreen)
            )
        }
    }
}
