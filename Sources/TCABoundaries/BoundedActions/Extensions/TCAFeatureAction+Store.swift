import CasePaths
import ComposableArchitecture

/// `ViewOnlyStoreOf` For use when scoping down to a store of only `ViewAction`
public typealias ViewOnlyStoreOf<R: BoundingReducer> = Store<R.State, R.Action.ViewAction>

/// `ViewOnlyViewStoreOf` For use when scoping down to a viewstore of only `ViewAction`
public typealias RestrictedViewStore<R: BoundingReducer> = ViewStore<R.State, R.Action.ViewAction>

extension Store where Action: TCAFeatureAction {
    /// Convenience var to quickly scope a store to just it's `ViewAction`
    public var viewScope: Store<State, Action.ViewAction> {
        scope(state: \.self, action: \.view)
    }
    /// When you have a `Child` flow inside a `Parent` store and need to scope it is often expressed as an `InternalAction` of the `Parent` store.
    /// This can lead to a bit a an awkward API when trying to express that relation...
    /// ```swift
    /// enum ParentAction: TCAFeatureAction {
    ///    enum InternalAction: Equatable {
    ///        // ...
    ///        case child(ChildAction)
    ///    }
    ///    // ...
    ///    case view(ViewAction)
    ///    case _internal(InternalAction)
    ///    case delegate(DelegateAction)
    /// }
    /// ```
    /// Without this extension we would have to write something like:
    /// ```swift
    /// struct ParentView: View {
    ///     let store: Store<ParentState, ParentAction>
    ///     var body: some View {
    ///         // ...
    ///         ChildView(
    ///             store.scope(
    ///                 state: \.childState,
    ///                 action: \ParentAction.Cases._internal.child
    ///             )
    ///         )
    ///         // ...
    ///     }
    /// }
    /// ```
    /// With this exntesion we are able to get a cleaner API like below:
    /// ```swift
    /// struct ParentView: View {
    ///     let store: Store<ParentState, ParentAction>
    ///     var body: some View {
    ///         // ...
    ///         ChildView(
    ///             store.scope(
    ///                 state: \.childState,
    ///                 action: \ParentAction.Cases._internal.child
    ///             )
    ///         )
    ///         // ...
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - toChildState: A key path that transforms `State` into `ChildState`.
    ///   - toChildAction: A case key path that transforms `Action.InternalAction` into `ChildAction`.
    /// - Returns: A new store with its domain (state and action) transformed.
    public func scope<ChildState, ChildAction>(
        state toChildState: KeyPath<State, ChildState>,
        action toChildAction: CaseKeyPath<Action.InternalAction, ChildAction>
    ) -> Store<ChildState, ChildAction> {
        scope(
            state: toChildState,
            action: (\Action.Cases._internal).appending(path: toChildAction)
        )
    }
}
