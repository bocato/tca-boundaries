# TCABoundaries

The `TCAFeatureAction` defines a pattern for actions on TCA based on https://www.merowing.info/boundries-in-tca/
Its idea is to set a well defined specification for actions on TCA views, where ideally View and Internal actions should not go out of the feature scope.

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

## Examples
### Child flow on parent, with boundaries
When you have a `Child` flow inside a `Parent` store and need to scope it is often expressed as an `InternalAction` of the `Parent` store.
```swift
enum ParentAction: TCAFeatureAction {
    enum InternalAction: Equatable {
    // ...
        case child(ChildAction)
    }
    // ...
    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
}
```
This will be expressed like below:
```swift
// On the reducer 
Scope(state: \.child, action: /Action.InternalAction.child) {
    ChildFeature()
}
// On the view
struct ParentView: View {
    let store: StoreOf<ParentReducer>
    
    var body: some View {
        // ...
        ChildView(
            store.scope(
                state: \.childState,
                action: /ParentAction.InternalAction.child
             )
         )
         // ...
     }
}
```


# Bounding Reducers
Bounding reducers is a protocol to define a standard when implementing reducers with Boundaries.
We can have them on composed (reducers with body) or non-composed reducers.

The main idea relies on setting a standard for separating the actions based on its type on specific functions:

```swift
// To handle actions coming from the view
func reduce(into state: inout State, viewAction action: Action.ViewAction) -> Effect<Action>

// To handle actions that happen inside the reducer
func reduce(into state: inout State, internalAction action: Action.InternalAction) -> Effect<Action>

// To handle actions that where delegated to this reducer
func reduce(into state: inout State, delegateAction action: Action.DelegateAction) -> Effect<Action>
```

Example for non-composed reducers:
```swift
struct SomeFeature: BoundingReducer {
      func reduce(into state: inout State, viewAction action: Action.ViewAction) -> Effect<Action> {
        switch action {
         ...
        }
     }

    func reduce(into state: inout State, internalAction action: Action.InternalAction) -> Effect<Action> {
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
      var body: some Reducer<State, Action> {
        coreReducer
            .ifLet(\.child, action: /Action.InternalAction.child) {
                ChildFeature()
            }
      }

      func reduce(into state: inout State, viewAction action: Action.ViewAction) -> Effect<Action> {
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
