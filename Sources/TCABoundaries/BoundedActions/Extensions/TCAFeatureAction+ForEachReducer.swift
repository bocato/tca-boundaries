import ComposableArchitecture

extension Reducer where Action: TCAFeatureAction {
    /// Embeds a child reducer in a parent domain that works on elements of a collection in parent
    /// state.
    ///
    /// For example, if a parent feature holds onto an array of child states, then it can perform
    /// its core logic _and_ the child's logic by using the `forEach` operator:
    ///
    /// ```swift
    /// struct Parent: Reducer {
    ///   struct State {
    ///     var rows: IdentifiedArrayOf<Row.State>
    ///     // ...
    ///   }
    ///   enum Action {
    ///     case row(id: Row.State.ID, action: Row.Action)
    ///     // ...
    ///   }
    ///
    ///   var body: some Reducer<State, Action> {
    ///     Reduce { state, action in
    ///       // Core logic for parent feature
    ///     }
    ///     .forEach(\.rows, action: /Action.row) {
    ///       Row()
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// > Tip: We are using `IdentifiedArray` from our
    /// [Identified Collections][swift-identified-collections] library because it provides a safe
    /// and ergonomic API for accessing elements from a stable ID rather than positional indices.
    ///
    /// The `forEach` forces a specific order of operations for the child and parent features. It
    /// runs the child first, and then the parent. If the order was reversed, then it would be
    /// possible for the parent feature to remove the child state from the array, in which case the
    /// child feature would not be able to react to that action. That can cause subtle bugs.
    ///
    /// It is still possible for a parent feature higher up in the application to remove the child
    /// state from the array before the child has a chance to react to the action. In such cases a
    /// runtime warning is shown in Xcode to let you know that there's a potential problem.
    ///
    /// [swift-identified-collections]: http://github.com/pointfreeco/swift-identified-collections
    ///
    /// - Parameters:
    ///   - toElementsState: A writable key path from parent state to an `IdentifiedArray` of child
    ///     state.
    ///   - toElementAction: A case path from parent action to child identifier and child actions.
    ///   - element: A reducer that will be invoked with child actions against elements of child
    ///     state.
    /// - Returns: A reducer that combines the child reducer with the parent reducer.
    @inlinable
    @warn_unqualified_access
    public func forEach<ElementState, ElementAction, ID: Hashable, Element: Reducer>(
      _ toElementsState: WritableKeyPath<State, IdentifiedArray<ID, ElementState>>,
      action toElementAction: CasePath<Action.InternalAction, (ID, ElementAction)>,
      @ReducerBuilder<ElementState, ElementAction> element: () -> Element,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) -> _ForEachReducer<Self, ID, Element> where ElementState == Element.State, ElementAction == Element.Action {
        self.forEach(
            toElementsState,
            action: (/Action._internal).appending(path: toElementAction),
            element: element,
            fileID: fileID,
            line: line
        )
    }
}
