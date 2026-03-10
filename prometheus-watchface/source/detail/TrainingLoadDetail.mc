using Toybox.UserProfile;

class TrainingLoadDetail extends DetailView {

    function initialize() {
        DetailView.initialize("TRAINING LOAD", 0xFF6B35, :load);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        try {
            if (UserProfile has :getTrainingLoad) {
                var load = UserProfile.getTrainingLoad();
                if (load != null) {
                    heroVal = load.toString();
                    var normalized = load / 10;
                    if (normalized >= 80) { status = "OVERREACHING"; }
                    else if (normalized >= 50) { status = "PRODUCTIVE"; }
                    else if (normalized >= 20) { status = "MAINTAINING"; }
                    else { status = "DETRAINING"; }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "7-day load",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "ACUTE", :value => "---"},
                {:key => "CHRONIC", :value => "---"},
                {:key => "RATIO", :value => "---"},
                {:key => "OPTIMAL", :value => "---"}
            ],
            :tip => "Balance load with recovery"
        };
    }
}
