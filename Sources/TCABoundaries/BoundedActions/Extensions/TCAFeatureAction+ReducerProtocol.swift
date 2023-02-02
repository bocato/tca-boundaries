import ComposableArchitecture

extension ReducerProtocol where Action: TCAFeatureAction {
    @inlinable
    public func ifLet<Wrapped: ReducerProtocol>(
      _ toWrappedState: WritableKeyPath<State, Wrapped.State?>,
      action toWrappedAction: CasePath<Action.InternalAction, Wrapped.Action>,
      @ReducerBuilderOf<Wrapped> then wrapped: () -> Wrapped,
      file: StaticString = #file,
      fileID: StaticString = #fileID,
      line: UInt = #line
    ) -> _IfLetReducer<Self, Wrapped> {
        self.ifLet(
            toWrappedState,
            action: (/Action._internal).appending(path: toWrappedAction),
            then: wrapped,
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
