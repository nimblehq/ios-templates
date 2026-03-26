import SwiftUI

/// Public contract for the Home feature's root view.
///
/// Any module depending on the Home feature imports `HomeInterface` and uses
/// this protocol — it never imports the `Home` implementation target directly.
/// This keeps the dependency graph clean and build times fast.
public protocol HomeViewProtocol: View {}
