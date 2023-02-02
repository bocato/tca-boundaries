import CasePaths
import ComposableArchitecture

public protocol ComposedBoundingReducer: BoundingReducer {
    @ReducerBuilder<State, Action> var body: Body { get }
}

public extension ComposedBoundingReducer {
    func reduceCore(into state: inout State, action: Action) -> EffectTask<Action> {
        if let action = (/Action.view).extract(from: action) {
            return reduce(into: &state, viewAction: action)
        }
        if let action = (/Action._internal).extract(from: action) {
            return reduce(into: &state, internalAction: action)
        }
        if let action = (/Action.delegate).extract(from: action) {
            return reduce(into: &state, delegateAction: action)
        }
        return .none
    }
    
    var coreReducer: Reduce<State, Action> {
        Reduce(reduceCore)
    }
}
