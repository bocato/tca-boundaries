import CasePaths
import ComposableArchitecture

public protocol BoundingReducer: Reducer where Action: TCAFeatureAction {
    func reduce(
        into state: inout State,
        viewAction action: Action.ViewAction
    ) -> Effect<Action>
    
    func reduce(
        into state: inout State,
        internalAction action: Action.InternalAction
    ) -> Effect<Action>
    
    func reduce(
        into state: inout State,
        delegateAction action: Action.DelegateAction
    ) -> Effect<Action>
}

public extension BoundingReducer {
    func reduce(
        into state: inout State,
        internalAction action: Action.InternalAction
    ) -> ComposableArchitecture.Effect<Action> { .none }
    
    func reduce(
        into state: inout State,
        delegateAction action: Action.DelegateAction
    ) -> Effect<Action> { .none }
}

public extension BoundingReducer where Body == Never {
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        if let viewAction = action[case: \.view] {
            return reduce(into: &state, viewAction: viewAction)
        }

        if let internalAction = action[case: \._internal] {
            return reduce(into: &state, internalAction: internalAction)
        }

        if let delegateAction = action[case: \.delegate] {
            return reduce(into: &state, delegateAction: delegateAction)
        }
        
        return .none
    }
}

