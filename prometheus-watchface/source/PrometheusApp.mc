using Toybox.Application;
using Toybox.Application.Storage;
using Toybox.Communications;
using Toybox.WatchUi;

class PrometheusApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        // Initialize settings singleton
        PrometheusSettings.getInstance();

        // Register for phone app messages (premium unlock)
        Communications.registerForPhoneAppMessages(method(:onPhoneMessage));
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [new PrometheusView(), new PrometheusDelegate()];
    }

    function getSettingsView() {
        return [new PrometheusSettingsView(), new PrometheusSettingsDelegate()];
    }

    function onSettingsChanged() {
        PrometheusSettings.getInstance().load();
        WatchUi.requestUpdate();
    }

    function onPhoneMessage(msg) {
        if (msg != null && msg.data != null) {
            var data = msg.data;
            if (data instanceof Dictionary && data.hasKey("type")) {
                if (data["type"].equals("premium_unlock")) {
                    Storage.setValue("isPremium", true);
                    PrometheusSettings.getInstance().isPremium = true;
                    PrometheusSettings.getInstance().applyTheme();
                    WatchUi.requestUpdate();
                }
            }
        }
    }
}

// Simple settings view for on-device editor (System 8)
class PrometheusSettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            "Settings",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

class PrometheusSettingsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}
