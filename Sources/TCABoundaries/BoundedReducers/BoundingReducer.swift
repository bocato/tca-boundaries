import CasePaths
import ComposableArchitecture

public protocol BoundingReducer: ReducerProtocol where Action: TCAFeatureAction {
    func reduce(
        into state: inout State,
        viewAction action: Action.ViewAction
    ) -> EffectTask<Action>
    
    func reduce(
        into state: inout State,
        internalAction action: Action.InternalAction
    ) -> EffectTask<Action>
    
    func reduce(
        into state: inout State,
        delegateAction action: Action.DelegateAction
    ) -> EffectTask<Action>
}

public extension BoundingReducer {
    func reduce(
        into state: inout State,
        delegateAction action: Action.DelegateAction
    ) -> EffectTask<Action> { .none }
}

public extension BoundingReducer where Body == Never {
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        if let viewAction = (/Action.view).extract(from: action) {
            return reduce(into: &state, viewAction: viewAction)
        }
        
        if let internalAction = (/Action._internal).extract(from: action) {
            return reduce(into: &state, internalAction: internalAction)
        }
        
        if let delegateAction = (/Action.delegate).extract(from: action) {
            return reduce(into: &state, delegateAction: delegateAction)
        }
        
        return .none
    }
}

