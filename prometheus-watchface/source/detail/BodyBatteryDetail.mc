using Toybox.Activity;
using Toybox.SensorHistory;

class BodyBatteryDetail extends DetailView {

    function initialize() {
        DetailView.initialize("BODY BATTERY", 0x00C9A7, :bb);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var history = [0, 0, 0, 0, 0, 0];
        var stats = [];

        // Current value
        try {
            var info = Activity.getActivityInfo();
            if (info != null && info.bodyBattery != null) {
                var bb = info.bodyBattery;
                heroVal = bb.toString();
                if (bb >= 70) { status = "FULLY CHARGED"; }
                else if (bb >= 40) { status = "MODERATE ENERGY"; }
                else if (bb >= 20) { status = "LOW ENERGY"; }
                else { status = "DEPLETED"; }
            }
        } catch (e) {}

        // History (last 6 days)
        try {
            if (SensorHistory has :getBodyBatteryHistory) {
                var iter = SensorHistory.getBodyBatteryHistory({:period => 6 * 86400, :order => SensorHistory.ORDER_OLDEST_FIRST});
                if (iter != null) {
                    var idx = 0;
                    var sample = iter.next();
                    while (sample != null && idx < 6) {
                        if (sample.data != null) {
                            history[idx] = sample.data;
                        }
                        idx++;
                        sample = iter.next();
                    }
                }
            }
        } catch (e) {}

        stats = [
            {:key => "PEAK", :value => "---"},
            {:key => "LOW", :value => "---"},
            {:key => "AVG", :value => "---"},
            {:key => "TREND", :value => "---"}
        ];

        return {
            :heroValue => heroVal,
            :unit => "/ 100",
            :status => status,
            :history => history,
            :stats => stats,
            :tip => "Prioritize sleep to recharge"
        };
    }
}
