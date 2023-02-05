import Foundation

/// The `TCAFeatureAction` defines a pattern for actions on TCA based on https://www.merowing.info/boundries-in-tca/
/// Its idea is to set a well defined specification for actions on TCA views, where ideally View and Internal actions should not go out of the view scope.
///
/// Example:
/// ```swift
/// enum ExampleAction: TCAFeatureAction {
///     enum ViewAction: Equatable {
///         case onTapLoginButton
///     }
///
///     enum DelegateAction: Equatable {
///         case notifyLoginSuccess
///     }
///
///     enum InternalAction: Equatable {
///         case loginResult(Result<String, NSError>)
///     }
///
///     case view(ViewAction)
///     case delegate(DelegateAction)
///     case _internal(InternalAction)
/// }
/// ```
public protocol TCAFeatureAction: Equatable {
    /// `ViewAction` relates  to actions that happen arround the view, being sent or received by it
    associatedtype ViewAction: Equatable
    /// `DelegateAction` relates to actions that are delegate to parent components (like the well known Delegate pattern)
    associatedtype DelegateAction: Equatable
    /// `InternalAction` relates to actions that happen inside the Reducer's scope, like: handling results, internal/reused actions and such
    associatedtype InternalAction: Equatable

    static func view(_: ViewAction) -> Self
    static func delegate(_: DelegateAction) -> Self
    static func _internal(_: InternalAction) -> Self
}
