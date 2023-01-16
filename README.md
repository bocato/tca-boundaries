# TCABoundaries

The `TCAFeatureAction` defines a pattern for actions on TCA based on https://www.merowing.info/boundries-in-tca/
Its idea is to set a well defined specification for actions on TCA views, where ideally View and Internal actions should not go out of the view scope.

Example:
```swift
enum ExampleAction: TCAFeatureAction {
    enum ViewAction: Equatable {
        case onTapLoginButton
    }
     
    enum DelegateAction: Equatable {
        case notifyLoginSuccess
    }

    enum InternalAction: Equatable {
        case loginResult(Result<String, NSError>)
    }
    
    case view(ViewAction)
    case delegate(DelegateAction)
    case _internal(InternalAction)
}
```

# Bounding Reducers
Bounding reducers is a protocol to define a standard when implementing reducers with Boundaries.
We can have them on composed (reducers with body) or non-composed reducers.

Example for non-composed reducers:
```swift
struct SomeFeature: BoundingReducer {
      func reduce(into state: inout State, viewAction action: Action.ViewAction) -> EffectTask<Action> {
        switch action {
         ...
        }
     }

    func reduce(into state: inout State, internalAction action: Action.InternalAction) -> EffectTask<Action> {
        switch action {
         ...
        }
    }

    ...
}
```

Example for composed reducers:
```swift
struct SomeFeature: ComposedBoundingReducer {
      var body: some ReducerProtocol<State, Action> {
        coreReducer
            .ifLet(\.child, action: /Action.InternalAction.child) {
                ChildFeature()
            }
      }

      func reduce(into state: inout State, viewAction action: Action.ViewAction) -> EffectTask<Action> {
        switch action {
         ...
        }
     }
    ...
}
```

## Installation

You can add TCABoundaries to an Xcode project by adding it as a package dependency.

1. From the File menu, select Add Packages...
2. Enter "https://github.com/bocato/tca-boundaries" into the package repository URL text field
