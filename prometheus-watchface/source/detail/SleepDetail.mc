using Toybox.UserProfile;

class SleepDetail extends DetailView {

    function initialize() {
        DetailView.initialize("SLEEP", 0x4FC3F7, :sleep);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var history = [0, 0, 0, 0, 0, 0];

        try {
            if (UserProfile has :getSleepHistory) {
                var sleepHist = UserProfile.getSleepHistory();
                if (sleepHist != null) {
                    for (var i = 0; i < sleepHist.size() && i < 6; i++) {
                        var entry = sleepHist[i];
                        if (entry has :duration && entry.duration != null) {
                            var hrs = entry.duration.toFloat() / 3600.0;
                            history[5 - i] = (hrs * 10).toNumber(); // scale for chart
                            if (i == 0) {
                                var h = hrs.toNumber();
                                var m = ((hrs - h) * 60).toNumber();
                                heroVal = h.toString() + "h " + m.format("%02d") + "m";
                                if (hrs >= 7.5) { status = "GREAT SLEEP"; }
                                else if (hrs >= 6.0) { status = "ADEQUATE"; }
                                else { status = "NEEDS IMPROVEMENT"; }
                            }
                        }
                    }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "hours",
            :status => status,
            :history => history,
            :stats => [
                {:key => "DEEP", :value => "---"},
                {:key => "REM", :value => "---"},
                {:key => "LIGHT", :value => "---"},
                {:key => "AWAKE", :value => "---"}
            ],
            :tip => "Aim for 7-9 hours nightly"
        };
    }
}
