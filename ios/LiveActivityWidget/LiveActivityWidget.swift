import ActivityKit
import SwiftUI
import WidgetKit

// ─── Re-declare attributes here for the extension target ─────────────────────
// (Because Flutter extension targets cannot import Runner directly.)
// Keep this in sync with ios/Runner/LyricaActivityAttributes.swift

@available(iOS 16.2, *)
struct LyricaActivityAttributes: ActivityAttributes {
    public let title: String

    public struct ContentState: Codable, Hashable {
        var progressMs:  Int
        var durationMs:  Int
        var isPlaying:   Bool
        var artistName:  String
        var coverUrl:    String

        var progressFraction: Double {
            guard durationMs > 0 else { return 0 }
            return min(1.0, Double(progressMs) / Double(durationMs))
        }

        var formattedProgress: String {
            let t = progressMs / 1000
            return String(format: "%d:%02d", t / 60, t % 60)
        }

        var formattedDuration: String {
            let t = durationMs / 1000
            return String(format: "%d:%02d", t / 60, t % 60)
        }
    }
}

// ─── Widget Bundle Entry Point ────────────────────────────────────────────────

@available(iOS 16.2, *)
@main
struct LyricaWidgetBundle: WidgetBundle {
    var body: some Widget {
        LyricaLiveActivityWidget()
    }
}

// ─── Live Activity Widget ─────────────────────────────────────────────────────

@available(iOS 16.2, *)
struct LyricaLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LyricaActivityAttributes.self) { context in
            // ── Lock Screen / Notification banner view ──────────────────────
            LyricaLockScreenView(
                attributes: context.attributes,
                state:      context.state
            )
            .activityBackgroundTint(Color(red: 0.03, green: 0.03, blue: 0.10))

        } dynamicIsland: { context in
            DynamicIsland {
                // ── Expanded Dynamic Island ─────────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    AsyncCoverImage(urlString: context.state.coverUrl)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.leading, 6)
                        .padding(.top, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        PlayStateIcon(isPlaying: context.state.isPlaying)
                            .padding(.trailing, 8)
                            .padding(.top, 6)
                        Text(context.state.formattedProgress)
                            .font(.system(size: 11, weight: .medium,
                                          design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .padding(.trailing, 10)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.title)
                            .font(.system(size: 14, weight: .bold,
                                          design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(context.state.artistName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                            .lineLimit(1)
                    }
                    .padding(.top, 6)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // Progress bar across the full width
                    LyricaProgressBar(fraction: context.state.progressFraction)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            } compactLeading: {
                // ── Compact leading: album thumbnail ─────────────────────────
                AsyncCoverImage(urlString: context.state.coverUrl)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.leading, 2)

            } compactTrailing: {
                // ── Compact trailing: play/pause icon ─────────────────────────
                PlayStateIcon(isPlaying: context.state.isPlaying)
                    .padding(.trailing, 4)

            } minimal: {
                // ── Minimal (one island): album art circle ────────────────────
                AsyncCoverImage(urlString: context.state.coverUrl)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
            }
        }
    }
}

// ─── Lock Screen View ─────────────────────────────────────────────────────────

@available(iOS 16.2, *)
struct LyricaLockScreenView: View {
    let attributes: LyricaActivityAttributes
    let state: LyricaActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            // Album art
            AsyncCoverImage(urlString: state.coverUrl)
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .purple.opacity(0.5), radius: 8)

            // Track info + progress
            VStack(alignment: .leading, spacing: 4) {
                Text(attributes.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(state.artistName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)

                Spacer().frame(height: 4)

                // Progress bar
                LyricaProgressBar(fraction: state.progressFraction)

                // Timestamps
                HStack {
                    Text(state.formattedProgress)
                    Spacer()
                    Text(state.formattedDuration)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            // Play / Pause icon
            PlayStateIcon(isPlaying: state.isPlaying)
                .padding(.trailing, 4)
        }
        .padding(16)
        .background(
            // Frosted glass dark gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.04, blue: 0.22),
                    Color(red: 0.03, green: 0.03, blue: 0.10),
                ]),
                startPoint: .topLeading,
                endPoint:   .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

// ─── Reusable Sub-views ───────────────────────────────────────────────────────

/// Gradient-filled progress track mimicking the app's glassmorphism slider.
struct LyricaProgressBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 3)
                // Fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.49, green: 0.23, blue: 0.93),
                                Color(red: 0.23, green: 0.51, blue: 0.96),
                            ],
                            startPoint: .leading,
                            endPoint:   .trailing
                        )
                    )
                    .frame(width: geo.size.width * fraction, height: 3)
            }
        }
        .frame(height: 3)
    }
}

/// Play / pause icon with violet glow.
struct PlayStateIcon: View {
    let isPlaying: Bool

    var body: some View {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.49, green: 0.23, blue: 0.93),
                                Color(red: 0.23, green: 0.51, blue: 0.96),
                            ],
                            startPoint: .topLeading,
                            endPoint:   .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.5),
                    radius: 6)
    }
}

/// Async image view with a gradient placeholder — no dependencies needed.
struct AsyncCoverImage: View {
    let urlString: String

    var body: some View {
        if #available(iOS 15.0, *), let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderGradient
                }
            }
        } else {
            placeholderGradient
        }
    }

    private var placeholderGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.49, green: 0.23, blue: 0.93),
                Color(red: 0.23, green: 0.51, blue: 0.96),
            ],
            startPoint: .topLeading,
            endPoint:   .bottomTrailing
        )
    }
}

// ─── Xcode Preview ────────────────────────────────────────────────────────────

@available(iOS 16.2, *)
struct LyricaLiveActivity_Previews: PreviewProvider {
    static let attrs = LyricaActivityAttributes(title: "Blinding Lights")
    static let state = LyricaActivityAttributes.ContentState(
        progressMs:  87_000,
        durationMs:  200_000,
        isPlaying:   true,
        artistName:  "The Weeknd",
        coverUrl:    "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36"
    )

    static var previews: some View {
        attrs
            .previewContext(state, viewKind: .content)
            .previewDisplayName("Lock Screen")
    }
}
