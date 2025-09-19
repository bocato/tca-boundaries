import CasePaths
import ComposableArchitecture
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
///
/// Conforming types automatically satisfy ``ComposableArchitecture/ViewAction`` so they can adopt
/// conveniences like the ``ComposableArchitecture/ViewAction(for:)`` macro. You should still
/// leverage ``CasePathable`` synthesis (for example by annotating the reducer with ``Reducer()`` or
/// the action enum with ``CasePathable``) so that case key paths can be composed ergonomically when
/// interacting with the latest versions of the Composable Architecture.
public protocol TCAFeatureAction: CasePathable, Equatable, ComposableArchitecture.ViewAction {
    /// `DelegateAction` relates to actions that are delegate to parent components (like the well known Delegate pattern)
    associatedtype DelegateAction: Equatable
    /// `InternalAction` relates to actions that happen inside the Reducer's scope, like: handling results, internal/reused actions and such
    associatedtype InternalAction: Equatable

    static func delegate(_: DelegateAction) -> Self
    static func _internal(_: InternalAction) -> Self
}
