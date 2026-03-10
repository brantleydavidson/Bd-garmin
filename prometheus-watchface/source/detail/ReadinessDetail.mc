using Toybox.Activity;
using Toybox.SensorHistory;
using Toybox.UserProfile;

class ReadinessDetail extends DetailView {

    function initialize() {
        DetailView.initialize("READINESS", 0x00E676, :readiness);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var hrvVal = 0;
        var bbVal = 0;
        var slpVal = 0;

        // Body Battery
        try {
            var info = Activity.getActivityInfo();
            if (info != null && info.bodyBattery != null) {
                bbVal = info.bodyBattery;
            }
        } catch (e) {}

        // HRV
        try {
            if (SensorHistory has :getHeartRateVariabilityHistory) {
                var iter = SensorHistory.getHeartRateVariabilityHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
                if (iter != null) {
                    var sample = iter.next();
                    if (sample != null && sample.data != null) {
                        hrvVal = sample.data.toNumber();
                    }
                }
            }
        } catch (e) {}

        // Sleep score
        try {
            if (UserProfile has :getSleepHistory) {
                var sleepHist = UserProfile.getSleepHistory();
                if (sleepHist != null && sleepHist.size() > 0) {
                    var entry = sleepHist[0];
                    if (entry has :score && entry.score != null) {
                        slpVal = entry.score;
                    }
                }
            }
        } catch (e) {}

        // Composite readiness score
        var readiness = (hrvVal * 0.4 + bbVal * 0.4 + slpVal * 0.2).toNumber();
        heroVal = readiness.toString();

        if (readiness >= 70) { status = "READY TO PERFORM"; }
        else if (readiness >= 45) { status = "MODERATE - EASY EFFORT"; }
        else { status = "REST & RECOVER"; }

        return {
            :heroValue => heroVal,
            :unit => "/ 100",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "HRV", :value => hrvVal.toString()},
                {:key => "BATTERY", :value => bbVal.toString()},
                {:key => "SLEEP SC", :value => slpVal.toString()},
                {:key => "FORMULA", :value => "40/40/20"}
            ],
            :tip => "Listen to your body today"
        };
    }
}
