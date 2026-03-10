using Toybox.UserProfile;

class RHRDetail extends DetailView {

    function initialize() {
        DetailView.initialize("RESTING HR", 0xEF5350, :rhr);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        try {
            var profile = UserProfile.getProfile();
            if (profile != null && profile.restingHeartRate != null) {
                var rhr = profile.restingHeartRate;
                heroVal = rhr.toString();
                if (rhr < 50) { status = "EXCELLENT"; }
                else if (rhr < 60) { status = "VERY GOOD"; }
                else if (rhr < 70) { status = "GOOD"; }
                else if (rhr < 80) { status = "AVERAGE"; }
                else { status = "ABOVE AVERAGE"; }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "bpm",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "7D AVG", :value => "---"},
                {:key => "30D AVG", :value => "---"},
                {:key => "LOW", :value => "---"},
                {:key => "TREND", :value => "---"}
            ],
            :tip => "Lower RHR = better fitness"
        };
    }
}
