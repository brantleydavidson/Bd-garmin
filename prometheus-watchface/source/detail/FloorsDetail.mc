using Toybox.ActivityMonitor;

class FloorsDetail extends DetailView {

    function initialize() {
        DetailView.initialize("FLOORS CLIMBED", 0x80CBC4, :floors);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        try {
            var info = ActivityMonitor.getInfo();
            if (info != null && info.floorsClimbed != null) {
                heroVal = info.floorsClimbed.toString();
                var goal = 10;
                if (info.floorsClimbedGoal != null) {
                    goal = info.floorsClimbedGoal;
                }
                var pct = (info.floorsClimbed.toFloat() / goal * 100).toNumber();
                if (pct >= 100) { status = "GOAL REACHED!"; }
                else if (pct >= 50) { status = "GOOD PROGRESS"; }
                else { status = "TAKE THE STAIRS"; }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "floors",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "GOAL", :value => "10"},
                {:key => "DOWN", :value => "---"},
                {:key => "7D AVG", :value => "---"},
                {:key => "ELEVATION", :value => "---"}
            ],
            :tip => "Stairs are great cardio"
        };
    }
}
