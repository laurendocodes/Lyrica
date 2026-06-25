import ActivityKit
import Foundation

/// Shared ActivityAttributes model used by both the Runner target
/// (AppDelegate Live Activity calls) and the LiveActivityWidget extension.
/// Add this file to BOTH the Runner and LiveActivityWidget targets in Xcode.
@available(iOS 16.2, *)
struct LyricaActivityAttributes: ActivityAttributes {

    /// Static data that does not change during the activity lifetime.
    public let title: String

    /// Dynamic content state — updated every heartbeat from Flutter.
    public struct ContentState: Codable, Hashable {
        var progressMs:  Int
        var durationMs:  Int
        var isPlaying:   Bool
        var artistName:  String
        var coverUrl:    String

        /// Progress fraction in [0, 1]
        var progressFraction: Double {
            guard durationMs > 0 else { return 0 }
            return min(1.0, Double(progressMs) / Double(durationMs))
        }

        /// Human-readable elapsed time "mm:ss"
        var formattedProgress: String {
            let total = progressMs / 1000
            let m = total / 60
            let s = total % 60
            return String(format: "%d:%02d", m, s)
        }

        /// Human-readable total duration "mm:ss"
        var formattedDuration: String {
            let total = durationMs / 1000
            let m = total / 60
            let s = total % 60
            return String(format: "%d:%02d", m, s)
        }
    }
}
