using Toybox.Activity;
using Toybox.ActivityMonitor;

class StepsDetail extends DetailView {

    function initialize() {
        DetailView.initialize("STEPS", 0x00C9A7, :steps);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var history = [0, 0, 0, 0, 0, 0];
        var goal = 10000;

        try {
            var info = ActivityMonitor.getInfo();
            if (info != null) {
                if (info.steps != null) {
                    heroVal = info.steps.toString();
                    var pct = (info.steps.toFloat() / goal * 100).toNumber();
                    if (pct >= 100) { status = "GOAL REACHED!"; }
                    else if (pct >= 75) { status = "ALMOST THERE"; }
                    else if (pct >= 50) { status = "HALFWAY"; }
                    else { status = "KEEP MOVING"; }
                }
                if (info.stepGoal != null) {
                    goal = info.stepGoal;
                }
            }
        } catch (e) {}

        // Step history
        try {
            if (ActivityMonitor has :getHistory) {
                var hist = ActivityMonitor.getHistory();
                if (hist != null) {
                    for (var i = 0; i < hist.size() && i < 6; i++) {
                        if (hist[i] != null && hist[i].steps != null) {
                            history[5 - i] = hist[i].steps;
                        }
                    }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "steps",
            :status => status,
            :history => history,
            :stats => [
                {:key => "GOAL", :value => goal.toString()},
                {:key => "DISTANCE", :value => "---"},
                {:key => "7D AVG", :value => "---"},
                {:key => "ACTIVE MIN", :value => "---"}
            ],
            :tip => "Every step counts"
        };
    }
}
