using Toybox.Activity;
using Toybox.ActivityMonitor;

class KcalDetail extends DetailView {

    function initialize() {
        DetailView.initialize("ACTIVE CALORIES", 0xFF9100, :kcal);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        try {
            var info = ActivityMonitor.getInfo();
            if (info != null && info.calories != null) {
                heroVal = info.calories.toString();
                if (info.calories >= 500) { status = "HIGH BURN"; }
                else if (info.calories >= 300) { status = "MODERATE"; }
                else { status = "LOW ACTIVITY"; }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "kcal",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "ACTIVE", :value => heroVal},
                {:key => "RESTING", :value => "---"},
                {:key => "TOTAL", :value => "---"},
                {:key => "7D AVG", :value => "---"}
            ],
            :tip => "Stay active throughout the day"
        };
    }
}
