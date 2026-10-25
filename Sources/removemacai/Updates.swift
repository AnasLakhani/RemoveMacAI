import Foundation

/// The newest release on GitHub. Only asked when someone chooses Check for
/// Updates, so RemoveMacAI otherwise makes no network requests.
enum Updates {
  static let latestURL = URL(string: "https://api.github.com/repos/omlahore/RemoveMacAI/releases/latest")!
  static let releasesPage = URL(string: "https://github.com/omlahore/RemoveMacAI/releases/latest")!

  struct Release {
    let version: String
    let page: URL
  }

  /// The latest release that isn't a beta, or why it couldn't be read.
  static func latest() async -> Result<Release, Error> {
    var request = URLRequest(url: latestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
        let tag = json["tag_name"] as? String
      else { throw URLError(.cannotParseResponse) }
      let page = (json["html_url"] as? String).flatMap(URL.init(string:)) ?? releasesPage
      return .success(Release(version: tag.hasPrefix("v") ? String(tag.dropFirst()) : tag, page: page))
    } catch {
      return .failure(error)
    }
  }

  /// Whether latest is newer than current. A beta comes before its release,
  /// so 1.2.0 is newer than 1.2.0-beta.1 and 1.1.4 is not.
  static func isNewer(_ latest: String, than current: String) -> Bool {
    func parts(_ v: String) -> (numbers: [Int], beta: String?) {
      let split = v.split(separator: "-", maxSplits: 1).map(String.init)
      return (split[0].split(separator: ".").map { Int($0) ?? 0 }, split.count > 1 ? split[1] : nil)
    }
    let a = parts(latest), b = parts(current)
    for i in 0..<max(a.numbers.count, b.numbers.count) {
      let x = i < a.numbers.count ? a.numbers[i] : 0, y = i < b.numbers.count ? b.numbers[i] : 0
      if x != y { return x > y }
    }
    switch (a.beta, b.beta) {
    case (nil, nil): return false
    case (nil, _): return true
    case (_, nil): return false
    case (let x?, let y?): return x.compare(y, options: .numeric) == .orderedDescending
    }
  }
}
