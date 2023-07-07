import ComposableArchitecture

extension ReducerProtocol where Action: TCAFeatureAction {
    /// Embeds a child reducer in a parent domain that works on an optional property of parent state.
    ///
    /// For example, if a parent feature holds onto a piece of optional child state, then it can
    /// perform its core logic _and_ the child's logic by using the `ifLet` operator:
    ///
    /// ```swift
    /// struct Parent: ReducerProtocol {
    ///   struct State {
    ///     var child: Child.State?
    ///     // ...
    ///   }
    ///   enum Action {
    ///     case child(Child.Action)
    ///     // ...
    ///   }
    ///
    ///   var body: some ReducerProtocol<State, Action> {
    ///     Reduce { state, action in
    ///       // Core logic for parent feature
    ///     }
    ///     .ifLet(\.child, action: /Action.child) {
    ///       Child()
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// The `ifLet` operator does a number of things to try to enforce correctness:
    ///
    ///   * It forces a specific order of operations for the child and parent features. It runs the
    ///     child first, and then the parent. If the order was reversed, then it would be possible for
    ///     the parent feature to `nil` out the child state, in which case the child feature would not
    ///     be able to react to that action. That can cause subtle bugs.
    ///
    ///   * It automatically cancels all child effects when it detects the child's state is `nil`'d
    ///     out.
    ///
    ///   * Automatically `nil`s out child state when an action is sent for alerts and confirmation
    ///     dialogs.
    ///
    /// See ``ReducerProtocol/ifLet(_:action:destination:fileID:line:)`` for a more advanced operator
    /// suited to navigation.
    ///
    /// - Parameters:
    ///   - toWrappedState: A writable key path from parent state to a property containing optional
    ///     child state.
    ///   - toWrappedAction: A case path from parent action to a case containing child actions.
    ///   - wrapped: A reducer that will be invoked with child actions against non-optional child
    ///     state.
    /// - Returns: A reducer that combines the child reducer with the parent reducer.
    @inlinable
    @warn_unqualified_access
    public func ifLet<WrappedState, WrappedAction, Wrapped: ReducerProtocol>(
      _ toWrappedState: WritableKeyPath<State, WrappedState?>,
      action toWrappedAction: CasePath<Action.InternalAction, WrappedAction>,
      @ReducerBuilder<WrappedState, WrappedAction> then wrapped: () -> Wrapped,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) -> _IfLetReducer<Self, Wrapped> where WrappedState == Wrapped.State, WrappedAction == Wrapped.Action {
        self.ifLet(
            toWrappedState,
            action: (/Action._internal).appending(path: toWrappedAction),
            then: wrapped,
            fileID: fileID,
            line: line
        )
    }

    @inlinable
    @warn_unqualified_access
    public func ifLet<WrappedState: _EphemeralState, WrappedAction>(
        _ toWrappedState: WritableKeyPath<State, WrappedState?>,
        action toWrappedAction: CasePath<Action.InternalAction, WrappedAction>,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> _IfLetReducer<Self, EmptyReducer<WrappedState, WrappedAction>> {
        self.ifLet(
            toWrappedState,
            action: (/Action._internal).appending(path: toWrappedAction),
            fileID: fileID,
            line: line
        )
    }
}