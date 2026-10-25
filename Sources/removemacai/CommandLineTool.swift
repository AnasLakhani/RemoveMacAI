import Foundation

/// The removemacai command for the app from the zip, which the installer and
/// Homebrew put on the PATH but the app doesn't.
enum CommandLineTool {
  static let path = "/usr/local/bin/removemacai"

  /// Links path to the binary after one password prompt.
  static func link(to binary: String, prompt: String) -> Shell.Result {
    Shell.admin(commands(linking: binary, at: path), prompt: prompt)
  }

  static func commands(linking binary: String, at path: String) -> [String] {
    let folder = (path as NSString).deletingLastPathComponent
    return ["mkdir -p \(Shell.quote(folder))", "ln -sfn \(Shell.quote(binary)) \(Shell.quote(path))"]
  }
}
