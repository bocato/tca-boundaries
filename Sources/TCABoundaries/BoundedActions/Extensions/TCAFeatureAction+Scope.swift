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
      _ child: () -> Child
    ) {
        self = .init(
            state: toChildState,
            action: (/ParentAction._internal).appending(path: toChildAction),
            child: child
        )
    }

    /// Initializes a reducer that runs the given child reducer against a slice of parent state and
    /// actions.
    ///
    /// Useful for combining child reducers into a parent.
    ///
    /// ```swift
    /// var body: some Reducer<State, Action> {
    ///   Scope(state: \.profile, action: /Action.profile) {
    ///     Profile()
    ///   }
    ///   Scope(state: \.settings, action: /Action.settings) {
    ///     Settings()
    ///   }
    ///   // ...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - toChildState: A writable key path from parent state to a property containing child state.
    ///   - toChildAction: A case path from parent action to a case containing child actions.
    ///   - child: A reducer that will be invoked with child actions against child state.
    @inlinable
    public init<ChildState, ChildAction>(
      state toChildState: WritableKeyPath<ParentState, ChildState>,
      action toChildAction: CasePath<ParentAction.InternalAction, ChildAction>,
      @ReducerBuilder<ChildState, ChildAction> child: () -> Child
    ) where ChildState == Child.State, ChildAction == Child.Action {
      self.init(
        state: toChildState,
        action: (/ParentAction._internal).appending(path: toChildAction),
        child: child
      )
    }

    /// Initializes a reducer that runs the given child reducer against a slice of parent state and
    /// actions.
    ///
    /// Useful for combining reducers of mutually-exclusive enum state.
    ///
    /// ```swift
    /// var body: some Reducer<State, Action> {
    ///   Scope(state: /State.loggedIn, action: /Action.loggedIn) {
    ///     LoggedIn()
    ///   }
    ///   Scope(state: /State.loggedOut, action: /Action.loggedOut) {
    ///     LoggedOut()
    ///   }
    /// }
    /// ```
    ///
    /// > Warning: Be careful when assembling reducers that are scoped to cases of enum state. If a
    /// > scoped reducer receives a child action when its state is set to an unrelated case, it will
    /// > not be able to process the action, which is considered an application logic error and will
    /// > emit runtime warnings.
    /// >
    /// > This can happen if another reducer in the parent domain changes the child state to an
    /// > unrelated case when it handles the action _before_ the scoped reducer runs. For example, a
    /// > parent may receive a dismissal action from the child domain:
    /// >
    /// > ```swift
    /// > Reduce { state, action in
    /// >   switch action {
    /// >   case .loggedIn(.quitButtonTapped):
    /// >     state = .loggedOut(LoggedOut.State())
    /// >   // ...
    /// >   }
    /// > }
    /// > Scope(state: /State.loggedIn, action: /Action.loggedIn) {
    /// >   LoggedIn()  // ⚠️ Logged-in domain can't handle `quitButtonTapped`
    /// > }
    /// > ```
    /// >
    /// > If the parent domain contains additional logic for switching between cases of child state,
    /// > prefer ``Reducer/ifCaseLet(_:action:then:fileID:line:)``, which better ensures that
    /// > child logic runs _before_ any parent logic can replace child state:
    /// >
    /// > ```swift
    /// > Reduce { state, action in
    /// >   switch action {
    /// >   case .loggedIn(.quitButtonTapped):
    /// >     state = .loggedOut(LoggedOut.State())
    /// >   // ...
    /// >   }
    /// > }
    /// > .ifCaseLet(/State.loggedIn, action: /Action.loggedIn) {
    /// >   LoggedIn()  // ✅ Receives actions before its case can change
    /// > }
    /// > ```
    ///
    /// - Parameters:
    ///   - toChildState: A case path from parent state to a case containing child state.
    ///   - toChildAction: A case path from parent action to a case containing child actions.
    ///   - child: A reducer that will be invoked with child actions against child state.
    @inlinable
    public init<ChildState, ChildAction>(
      state toChildState: CasePath<ParentState, ChildState>,
      action toChildAction: CasePath<ParentAction.InternalAction, ChildAction>,
      @ReducerBuilder<ChildState, ChildAction> child: () -> Child,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) where ChildState == Child.State, ChildAction == Child.Action {
      self.init(
        state: toChildState,
        action: (/ParentAction._internal).appending(path: toChildAction),
        child: child,
        fileID: fileID,
        line: line
      )
    }
}
