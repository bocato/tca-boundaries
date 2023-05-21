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


//
//import SwiftUI
//
////public typealias BoundedStoreOf<R: ReducerProtocol> = Store<R.State, R.Action> where R.Action: TCAFeatureAction
//
//public struct WithBoundedViewStore<State, Action: TCAFeatureAction, Content> {
//    public init<ViewState, ViewAction>(
//      _ store: Store<ViewState, Action>,
//      observe toViewState: @escaping (State) -> ViewState,
//      send fromViewAction: @escaping (ViewAction) -> Action,
//      removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool,
//      @ViewBuilder content: @escaping (ViewStore<ViewState, ViewAction>) -> Content,
//      file: StaticString = #fileID,
//      line: UInt = #line
//    ) {
//      self.init(
//        store: store.scope(state: toViewState, action: fromViewAction),
//        removeDuplicates: isDuplicate,
//        content: content,
//        file: file,
//        line: line
//      )
//    }
//}
//
//extension WithViewStore {
//    public init<State, Action>(
//      _ store: Store<State, Action>,
//      observe toViewState: @escaping (State) -> ViewState,
//      send fromViewAction: @escaping (ViewAction) -> Action,
//      removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool,
//      @ViewBuilder content: @escaping (ViewStore<ViewState, ViewAction>) -> Content,
//      file: StaticString = #fileID,
//      line: UInt = #line
//    ) where Action: TCAFeatureAction, ViewAction: Action.ViewAction {
//      self.init(
//        store: store.scope(state: toViewState, action: fromViewAction),
//        removeDuplicates: isDuplicate,
//        content: content,
//        file: file,
//        line: line
//      )
//    }
//
//    init(
//      store: Store<ViewState, ViewAction>,
//      removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool,
//      boundedContent: @escaping (ViewStore<ViewState, ViewAction.ViewAction>) -> Content,
//      file: StaticString = #fileID,
//      line: UInt = #line
//    ) where ViewAction: TCAFeatureAction {
//        WithViewStore(<#T##store: Store<State, Action>##Store<State, Action>#>, observe: <#T##(State) -> ViewState#>, send: <#T##(ViewAction) -> Action#>, removeDuplicates: <#T##(ViewState, ViewState) -> Bool#>, content: <#T##(ViewStore<ViewState, ViewAction>) -> View#>)
//        self.init(
//            store: store,
//            removeDuplicates: isDuplicate,
//            content: boundedContent,
//            file: file,
//            line: line
//        )
//    }
//}
