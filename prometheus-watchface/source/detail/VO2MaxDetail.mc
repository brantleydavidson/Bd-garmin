using Toybox.UserProfile;

class VO2MaxDetail extends DetailView {

    function initialize() {
        DetailView.initialize("VO2 MAX", 0x00E5FF, :vo2);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        try {
            if (UserProfile has :getVO2MaxRunning) {
                var vo2 = UserProfile.getVO2MaxRunning();
                if (vo2 != null) {
                    heroVal = vo2.toString();
                    if (vo2 >= 55) { status = "SUPERIOR"; }
                    else if (vo2 >= 45) { status = "EXCELLENT"; }
                    else if (vo2 >= 35) { status = "GOOD"; }
                    else if (vo2 >= 25) { status = "FAIR"; }
                    else { status = "NEEDS WORK"; }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "mL/kg/min",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "RUN", :value => heroVal},
                {:key => "CYCLE", :value => "---"},
                {:key => "FIT AGE", :value => "---"},
                {:key => "TREND", :value => "---"}
            ],
            :tip => "Zone 2 training boosts VO2 Max"
        };
    }
}
