import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var liveActivityID: String?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        setupLiveActivityChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: – Platform Channel Setup

    private func setupLiveActivityChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "lyrica/live_activity",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "startLiveActivity":
                self.handleStartLiveActivity(call: call, result: result)
            case "updateLiveActivity":
                self.handleUpdateLiveActivity(call: call, result: result)
            case "endLiveActivity":
                self.handleEndLiveActivity(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: – Start

    private func handleStartLiveActivity(call: FlutterMethodCall, result: FlutterResult) {
        guard #available(iOS 16.2, *) else {
            result(FlutterError(code: "UNSUPPORTED",
                                message: "Live Activities require iOS 16.2+",
                                details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        // End any existing activity first
        endAllActivities()

        let contentState = LyricaActivityAttributes.ContentState(
            progressMs:  args["progressMs"]  as? Int    ?? 0,
            durationMs:  args["durationMs"]  as? Int    ?? 0,
            isPlaying:   args["isPlaying"]   as? Bool   ?? false,
            artistName:  args["artistName"]  as? String ?? "",
            coverUrl:    args["coverUrl"]    as? String ?? ""
        )

        let attributes = LyricaActivityAttributes(
            title: args["title"] as? String ?? "Unknown"
        )

        do {
            let activity = try Activity<LyricaActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            liveActivityID = activity.id
            result(activity.id)
        } catch {
            result(FlutterError(code: "START_FAILED",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    // MARK: – Update

    private func handleUpdateLiveActivity(call: FlutterMethodCall, result: FlutterResult) {
        guard #available(iOS 16.2, *) else { result(nil); return }

        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        Task {
            for activity in Activity<LyricaActivityAttributes>.activities {
                let newState = LyricaActivityAttributes.ContentState(
                    progressMs:  args["progressMs"]  as? Int    ?? activity.contentState.progressMs,
                    durationMs:  args["durationMs"]  as? Int    ?? activity.contentState.durationMs,
                    isPlaying:   args["isPlaying"]   as? Bool   ?? activity.contentState.isPlaying,
                    artistName:  args["artistName"]  as? String ?? activity.contentState.artistName,
                    coverUrl:    args["coverUrl"]    as? String ?? activity.contentState.coverUrl
                )
                await activity.update(using: newState)
            }
            result(nil)
        }
    }

    // MARK: – End

    private func handleEndLiveActivity(result: FlutterResult) {
        guard #available(iOS 16.2, *) else { result(nil); return }
        Task {
            await endAllActivitiesAsync()
            result(nil)
        }
    }

    @available(iOS 16.2, *)
    private func endAllActivitiesAsync() async {
        for activity in Activity<LyricaActivityAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        liveActivityID = nil
    }

    private func endAllActivities() {
        if #available(iOS 16.2, *) {
            Task { await endAllActivitiesAsync() }
        }
    }
}
