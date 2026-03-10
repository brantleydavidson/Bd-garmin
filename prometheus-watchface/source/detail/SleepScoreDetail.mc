using Toybox.UserProfile;

class SleepScoreDetail extends DetailView {

    function initialize() {
        DetailView.initialize("SLEEP SCORE", 0x4FC3F7, :slpScr);
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
                        if (entry has :score && entry.score != null) {
                            history[5 - i] = entry.score;
                            if (i == 0) {
                                heroVal = entry.score.toString();
                                if (entry.score >= 80) { status = "EXCELLENT SLEEP"; }
                                else if (entry.score >= 60) { status = "GOOD SLEEP"; }
                                else if (entry.score >= 40) { status = "FAIR SLEEP"; }
                                else { status = "POOR SLEEP"; }
                            }
                        }
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
                {:key => "7D AVG", :value => "---"},
                {:key => "BEST", :value => "---"},
                {:key => "WORST", :value => "---"},
                {:key => "TREND", :value => "---"}
            ],
            :tip => "Keep a consistent sleep schedule"
        };
    }
}
