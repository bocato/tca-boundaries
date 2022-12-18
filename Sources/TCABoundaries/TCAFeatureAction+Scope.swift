import ComposableArchitecture

extension Scope where ParentAction: TCAFeatureAction {
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
    /// Scope(/Action._internal .. /Action.InternalAction.child) {
    ///    ChildFeature()
    /// }
    /// ```
    /// With this extension we are able to get a cleaner API like below:
    /// ```swift
    /// Scope(state: \.child, action: /Action.InternalAction.child) {
    ///     ChildFeature()
    /// }
    /// ```
    /// - Parameters:
    ///   - state: A function that transforms `State` into `ChildState`.
    ///   - action: A function that transforms `Action.InternalAction` into `ChildAction`.
    ///   - child: The reducer builder for the Child.
    @inlinable
    public init(
      state toChildState: WritableKeyPath<ParentState, Child.State>,
      action toChildAction: CasePath<ParentAction.InternalAction, Child.Action>,
      @ReducerBuilderOf<Child> _ child: () -> Child
    ) {
        self = .init(
            state: toChildState,
            action: (/ParentAction._internal).appending(path: toChildAction),
            child
        )
    }
}
