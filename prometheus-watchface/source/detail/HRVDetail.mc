using Toybox.SensorHistory;

class HRVDetail extends DetailView {

    function initialize() {
        DetailView.initialize("HRV STATUS", 0xBB86FC, :hrv);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var history = [0, 0, 0, 0, 0, 0];

        try {
            if (SensorHistory has :getHeartRateVariabilityHistory) {
                var iter = SensorHistory.getHeartRateVariabilityHistory({:period => 6 * 86400, :order => SensorHistory.ORDER_OLDEST_FIRST});
                if (iter != null) {
                    var idx = 0;
                    var lastVal = null;
                    var sample = iter.next();
                    while (sample != null && idx < 6) {
                        if (sample.data != null) {
                            history[idx] = sample.data.toNumber();
                            lastVal = sample.data.toNumber();
                        }
                        idx++;
                        sample = iter.next();
                    }
                    if (lastVal != null) {
                        heroVal = lastVal.toString();
                        if (lastVal >= 60) { status = "BALANCED"; }
                        else if (lastVal >= 30) { status = "RECOVERING"; }
                        else { status = "LOW - REST UP"; }
                    }
                }
            }
        } catch (e) {}

        return {
            :heroValue => heroVal,
            :unit => "ms",
            :status => status,
            :history => history,
            :stats => [
                {:key => "7D AVG", :value => "---"},
                {:key => "BASELINE", :value => "---"},
                {:key => "RANGE", :value => "---"},
                {:key => "TREND", :value => "---"}
            ],
            :tip => "Consistent sleep improves HRV"
        };
    }
}
