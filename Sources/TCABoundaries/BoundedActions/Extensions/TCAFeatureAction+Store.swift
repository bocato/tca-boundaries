import ComposableArchitecture

extension Store where Action: TCAFeatureAction {
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
    ///                 action: (/ParentAction._internal .. /ParentAction.InternalAction.child).embed
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
    ///                 action: /ParentAction.InternalAction.child
    ///             )
    ///         )
    ///         // ...
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - toChildState: A function that transforms `State` into `ChildState`.
    ///   - fromChildAction: A function that transforms `Action.InternalAction` into `ChildAction`.
    /// - Returns: A new store with its domain (state and action) transformed.
    public func scope<ChildState, ChildAction>(
        state toChildState: @escaping (State) -> ChildState,
        action fromChildAction: CasePath<Action.InternalAction, ChildAction>
    ) -> Store<ChildState, ChildAction> {
        scope(
            state: toChildState,
            action: { ._internal(fromChildAction.embed($0)) }
        )
    }
}
