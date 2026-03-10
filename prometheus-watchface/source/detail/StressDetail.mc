using Toybox.Activity;
using Toybox.SensorHistory;

class StressDetail extends DetailView {

    function initialize() {
        DetailView.initialize("STRESS", 0xFF8C42, :stress);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var history = [0, 0, 0, 0, 0, 0];

        try {
            var info = Activity.getActivityInfo();
            if (info != null && info.stressLevel != null) {
                heroVal = info.stressLevel.toString();
                var s = info.stressLevel;
                if (s >= 76) { status = "HIGH STRESS"; }
                else if (s >= 51) { status = "MODERATE"; }
                else if (s >= 26) { status = "LOW STRESS"; }
                else { status = "RESTING"; }
            }
        } catch (e) {}

        // Stress history
        try {
            if (SensorHistory has :getStressHistory) {
                var iter = SensorHistory.getStressHistory({:period => 6 * 86400, :order => SensorHistory.ORDER_OLDEST_FIRST});
                if (iter != null) {
                    var idx = 0;
                    var sample = iter.next();
                    while (sample != null && idx < 6) {
                        if (sample.data != null) {
                            history[idx] = sample.data.toNumber();
                        }
                        idx++;
                        sample = iter.next();
                    }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "/ 100",
            :status => status,
            :history => history,
            :stats => [
                {:key => "AVG TODAY", :value => "---"},
                {:key => "PEAK", :value => "---"},
                {:key => "REST %", :value => "---"},
                {:key => "7D AVG", :value => "---"}
            ],
            :tip => "Try deep breathing to reduce stress"
        };
    }
}
