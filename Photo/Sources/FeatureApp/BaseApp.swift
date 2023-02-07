import ComposableArchitecture
import SwiftUI

@main
struct BaseApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootState(),
                    reducer: rootReducer,
                    environment: RootEnvironment.live()
                )
            )
        }
    }
}
