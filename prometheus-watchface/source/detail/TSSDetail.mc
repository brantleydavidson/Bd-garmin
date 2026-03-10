using Toybox.UserProfile;

class TSSDetail extends DetailView {

    function initialize() {
        DetailView.initialize("WEEKLY TSS", 0xFFD700, :tss);
    }

    function getData() {
        var heroVal = "--";
        var status = "";

        // TSS approximation from training load
        try {
            if (UserProfile has :getTrainingLoad) {
                var load = UserProfile.getTrainingLoad();
                if (load != null) {
                    var tss = (load / 10).toNumber();
                    heroVal = tss.toString();
                    if (tss >= 80) { status = "HIGH VOLUME"; }
                    else if (tss >= 40) { status = "MODERATE"; }
                    else { status = "LOW VOLUME"; }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "TSS",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [
                {:key => "THIS WEEK", :value => "---"},
                {:key => "LAST WEEK", :value => "---"},
                {:key => "4W AVG", :value => "---"},
                {:key => "TREND", :value => "---"}
            ],
            :tip => "Increase TSS by 5-10% weekly"
        };
    }
}
