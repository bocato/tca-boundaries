import CasePaths
import ComposableArchitecture

public protocol ComposedBoundingReducer: BoundingReducer {
    @ReducerBuilder<State, Action> var body: Body { get }
}

public extension ComposedBoundingReducer {
    func reduceCore(into state: inout State, action: Action) -> Effect<Action> {
        if let action = action[case: \.view] {
            return reduce(into: &state, viewAction: action)
        }
        if let action = action[case: \._internal] {
            return reduce(into: &state, internalAction: action)
        }
        if let action = action[case: \.delegate] {
            return reduce(into: &state, delegateAction: action)
        }
        return .none
    }
    
    var coreReducer: Reduce<State, Action> {
        Reduce(reduceCore)
    }
}
