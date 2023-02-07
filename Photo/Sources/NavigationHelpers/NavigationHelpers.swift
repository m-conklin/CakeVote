import ComposableArchitecture
import SwiftUI

public struct RouteIntent<R: NavigationRoute>: Hashable {

    public enum Action: Hashable {
        case navigateTo
        case enterInto(EnterIntoContext = .default)
    }

    public var route: R
    public var action: Action

    public init(route: R, action: RouteIntent<R>.Action) {
        self.route = route
        self.action = action
    }
}

public struct EnterIntoContext: OptionSet, Hashable {

    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let fullScreen = EnterIntoContext(rawValue: 1 << 0)
    public static let destinationEmbeddedIntoNavigationView = EnterIntoContext(rawValue: 1 << 1)

    public static let all: EnterIntoContext = [.fullScreen, .destinationEmbeddedIntoNavigationView]
    public static let `default`: EnterIntoContext = [.destinationEmbeddedIntoNavigationView]
    public static let none: EnterIntoContext = []
}

public protocol NavigationRoute: Hashable {

    associatedtype Destination: View
    associatedtype State: NavigationState where State.RouteType == Self
    associatedtype Action: NavigationAction where Action.RouteType == Self

    func destination(in store: Store<State, Action>) -> Destination
}

public protocol NavigationState: Equatable {
    associatedtype RouteType: NavigationRoute where RouteType.State == Self

    var route: RouteIntent<RouteType>? { get set }
}

public protocol NavigationAction {
    associatedtype RouteType: NavigationRoute where RouteType.Action == Self
    static func route(_ route: RouteIntent<RouteType>?) -> Self
}

extension NavigationRoute {

    public var label: String {
        Mirror(reflecting: self).children.first?.label
        ?? String(describing: self)
    }
}

extension NavigationAction {

    public static func dismiss() -> Self {
        .route(nil)
    }

    public static func navigate(to route: RouteType) -> Self {
        .route(.navigate(to: route))
    }

    public static func enter(into route: RouteType, context: EnterIntoContext = .default) -> Self {
        .route(.enter(into: route, context: context))
    }
}

extension RouteIntent {

    public static func navigate(to route: R) -> Self {
        .init(route: route, action: .navigateTo)
    }

    public static func enter(into route: R, context: EnterIntoContext = .default) -> Self {
        .init(route: route, action: .enterInto(context))
    }
}

extension View {

    @ViewBuilder
    public func navigationRoute<State: NavigationState>(
        in store: Store<State, State.RouteType.Action>
    ) -> some View {
        navigationRoute(State.RouteType.self, in: store)
    }

    @ViewBuilder
    public func navigationRoute<Route: NavigationRoute>(
        _ route: Route.Type = Route.self, in store: Store<Route.State, Route.Action>
    ) -> some View {
        modifier(NavigationRouteViewModifier<Route>(store))
    }
}

extension Effect where Output: NavigationAction {

    public static func dismiss() -> Self {
        Effect(value: .dismiss())
    }

    public static func navigate(to route: Output.RouteType) -> Self {
        Effect(value: .navigate(to: route))
    }

    public static func enter(into route: Output.RouteType, context: EnterIntoContext = .default) -> Self {
        Effect(value: .enter(into: route, context: context))
    }
}

public struct NavigationRouteViewModifier<Route: NavigationRoute>: ViewModifier {

    public typealias State = Route.State
    public typealias Action = Route.Action

    public let store: Store<State, Action>

    @ObservedObject private var viewStore: ViewStore<RouteIntent<Route>?, Action>

    @SwiftUI.State private var intent: Identified<UUID, RouteIntent<Route>>?
    @SwiftUI.State private var isReady: Identified<UUID, RouteIntent<Route>>?

    public init(_ store: Store<State, Action>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: \.route))
    }

    public func body(content: Content) -> some View {
        content
            .background(routing)
            .onReceive(viewStore.publisher) { state in
                guard state != intent?.value else { return }
                intent = state.map { .init($0, id: UUID()) }
            }
    }

    @ViewBuilder private var routing: some View {
        if let intent = intent {
            create(intent)
                .inserting(intent, into: $isReady)
        }
    }

    @ViewBuilder private func create(_ intent: Identified<UUID, RouteIntent<Route>>) -> some View {
        let binding = viewStore.binding(
            get: { $0 },
            send: Action.route
        )
        switch intent.value.action {
        case .navigateTo:
            NavigationLink(
                destination: intent.value.route.destination(in: store),
                isActive: Binding(binding, to: intent, isReady: $isReady),
                label: EmptyView.init
            )

        case .enterInto(let context) where context.contains(.fullScreen):
            Color.clear
                .fullScreenCover(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        if context.contains(.destinationEmbeddedIntoNavigationView) {
                            NavigationView { intent.value.route.destination(in: store) }
                                .navigationViewStyle(.stack)
                        } else {
                            intent.value.route.destination(in: store)
                        }
                    }
                )

        case .enterInto(let context):
            Color.clear
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        if context.contains(.destinationEmbeddedIntoNavigationView) {
                            NavigationView { intent.value.route.destination(in: store) }
                                .navigationViewStyle(.stack)
                        } else {
                            intent.value.route.destination(in: store)
                        }
                    }
                )
        }
    }
}

extension View {

    @ViewBuilder fileprivate func inserting<E>(
        _ element: E,
        into binding: Binding<E?>
    ) -> some View where E: Hashable {
        onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(15)) { binding.wrappedValue = element }
        }
    }
}

extension Binding where Value == Bool {

    fileprivate init<E: Equatable>(
        _ source: Binding<E?>,
        to element: Identified<UUID, E>,
        isReady ready: Binding<Identified<UUID, E>?>
    ) {
        self.init(
            get: { source.wrappedValue == element.value && ready.wrappedValue == element },
            set: { source.wrappedValue = $0 ? element.value : nil }
        )
    }
}
