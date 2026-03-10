using Toybox.WatchUi;

class PrometheusDelegate extends WatchUi.WatchFaceDelegate {

    const CY = 227;

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onTap(tapEvent) {
        var coords = tapEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        var zone = detectZone(x, y);
        if (zone != null) {
            var view = createDetailView(zone);
            if (view != null) {
                WatchUi.pushView(view, new DetailDelegate(), WatchUi.SLIDE_IMMEDIATE);
                return true;
            }
        }
        return false;
    }

    function detectZone(x, y) {
        // Weather strip
        if (x >= 157 && x <= 297 && y >= 58 && y <= 110) {
            return :weather;
        }
        // Readiness pill
        if (x >= 175 && x <= 279 && y >= CY + 12 && y <= CY + 37) {
            return :readiness;
        }
        // Row 1: BB, HRV, Sleep
        if (y >= CY + 50 && y <= CY + 95) {
            if (x >= 95 && x <= 167) { return :bb; }
            if (x >= 191 && x <= 263) { return :hrv; }
            if (x >= 287 && x <= 359) { return :sleep; }
        }
        // Row 2: RHR, Slot1, Slot2
        if (y >= CY + 107 && y <= CY + 152) {
            if (x >= 95 && x <= 167) { return :rhr; }
            if (x >= 191 && x <= 263) { return :slot1; }
            if (x >= 287 && x <= 359) { return :slot2; }
        }
        // Outer arc label (LOAD)
        if (x >= 32 && x <= 80 && y >= CY - 10 && y <= CY + 10) {
            return :load;
        }
        return null;
    }

    function createDetailView(zone) {
        if (zone == :weather)   { return new WeatherDetail();       }
        if (zone == :readiness) { return new ReadinessDetail();     }
        if (zone == :bb)        { return new BodyBatteryDetail();   }
        if (zone == :hrv)       { return new HRVDetail();           }
        if (zone == :sleep)     { return new SleepDetail();         }
        if (zone == :rhr)       { return new RHRDetail();           }
        if (zone == :load)      { return new TrainingLoadDetail();  }

        // Swappable slots — route to configured metric
        var settings = PrometheusSettings.getInstance();
        var metric = null;
        if (zone == :slot1) { metric = settings.slot1Metric; }
        if (zone == :slot2) { metric = settings.slot2Metric; }

        if (metric != null) {
            return createViewForMetric(metric);
        }
        return null;
    }

    function createViewForMetric(metric) {
        if (metric == :load)   { return new TrainingLoadDetail();  }
        if (metric == :tss)    { return new TSSDetail();           }
        if (metric == :slpScr) { return new SleepScoreDetail();    }
        if (metric == :steps)  { return new StepsDetail();         }
        if (metric == :kcal)   { return new KcalDetail();          }
        if (metric == :stress) { return new StressDetail();        }
        if (metric == :vo2)    { return new VO2MaxDetail();        }
        if (metric == :floors) { return new FloorsDetail();        }
        return null;
    }
}
