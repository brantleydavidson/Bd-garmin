using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Application.Storage;

class PrometheusSettings {
    static var instance = null;

    // Color palettes
    static var ARC_COLORS = [0xFF6B35, 0x00C9A7, 0x4FC3F7, 0xBB86FC, 0xEF5350, 0xFFD700];
    static var TIME_COLORS = [0xFFFFFF, 0xFF6B35, 0x00C9A7];
    static var METRIC_COLORS = [0xFFFFFF, 0xFF8C42, 0x00C9A7, 0x4FC3F7, 0xBB86FC];

    // Slot metric symbols indexed by setting value
    static var SLOT_METRICS = [:load, :tss, :slpScr, :steps, :kcal, :stress, :vo2, :floors];

    // Theme definitions
    static var THEMES = {
        0 => { // Prometheus (Default)
            :bg        => 0x000000,
            :accent    => 0xFF6B35,
            :accent2   => 0x00C9A7,
            :text      => 0xFFFFFF,
            :label     => 0x888888,
            :pillBg    => 0x041A0A,
            :pillText  => 0x00E676
        },
        1 => { // Deep Navy
            :bg        => 0x040916,
            :accent    => 0x00E5FF,
            :accent2   => 0xBB86FC,
            :text      => 0xE8F4F8,
            :label     => 0x5A7A9A,
            :pillBg    => 0x001A2E,
            :pillText  => 0x00E5FF
        },
        2 => { // Carbon
            :bg        => 0x080A0C,
            :accent    => 0xE8F4F8,
            :accent2   => 0x607D8B,
            :text      => 0xFFFFFF,
            :label     => 0x607D8B,
            :pillBg    => 0x0A1018,
            :pillText  => 0xE8F4F8
        },
        3 => { // Ember Red
            :bg        => 0x080200,
            :accent    => 0xFF3D00,
            :accent2   => 0xFF9100,
            :text      => 0xFFF3E0,
            :label     => 0x7A4020,
            :pillBg    => 0x1A0600,
            :pillText  => 0xFF6D00
        }
    };

    // Current settings values
    var outerArcColor;
    var innerArcColor;
    var timeColor;
    var metricColor;
    var slot1Metric;
    var slot2Metric;
    var isPremium;
    var premiumTheme;

    // Resolved theme colors (for premium)
    var bgColor;
    var textColor;
    var labelColor;
    var pillBgColor;
    var pillTextColor;

    function initialize() {
        load();
    }

    function load() {
        // Arc colors
        var outerIdx = safeGetProperty("outerArcColor", 0);
        outerArcColor = ARC_COLORS[clampIndex(outerIdx, ARC_COLORS.size())];

        var innerIdx = safeGetProperty("innerArcColor", 1);
        innerArcColor = ARC_COLORS[clampIndex(innerIdx, ARC_COLORS.size())];

        // Time color
        var timeIdx = safeGetProperty("timeColor", 0);
        timeColor = TIME_COLORS[clampIndex(timeIdx, TIME_COLORS.size())];

        // Metric color
        var metIdx = safeGetProperty("metricColor", 0);
        metricColor = METRIC_COLORS[clampIndex(metIdx, METRIC_COLORS.size())];

        // Swappable slot metrics
        var s1Idx = safeGetProperty("slot1Metric", 0);
        slot1Metric = SLOT_METRICS[clampIndex(s1Idx, SLOT_METRICS.size())];

        var s2Idx = safeGetProperty("slot2Metric", 3);
        slot2Metric = SLOT_METRICS[clampIndex(s2Idx, SLOT_METRICS.size())];

        // Premium status from Storage (not Properties)
        var prem = Storage.getValue("isPremium");
        isPremium = (prem != null) ? prem : false;

        // Theme (premium only)
        var themeIdx = safeGetProperty("premiumTheme", 0);
        premiumTheme = clampIndex(themeIdx, 4);

        // Apply theme
        applyTheme();
    }

    function applyTheme() {
        if (isPremium) {
            var theme = THEMES[premiumTheme];
            bgColor = theme[:bg];
            textColor = theme[:text];
            labelColor = theme[:label];
            pillBgColor = theme[:pillBg];
            pillTextColor = theme[:pillText];
        } else {
            // Free tier: always Prometheus theme
            bgColor = 0x000000;
            textColor = 0xFFFFFF;
            labelColor = 0x888888;
            pillBgColor = 0x041A0A;
            pillTextColor = 0x00E676;
        }
    }

    function safeGetProperty(key, defaultVal) {
        try {
            var val = Properties.getValue(key);
            if (val != null) {
                return val.toNumber();
            }
        } catch (e) {
            // Property may not exist yet
        }
        return defaultVal;
    }

    function clampIndex(idx, size) {
        if (idx == null || idx < 0 || idx >= size) {
            return 0;
        }
        return idx;
    }

    // Get detail view key for a slot metric symbol
    function getSlotDetailKey(slotMetric) {
        return slotMetric;
    }

    static function getInstance() {
        if (instance == null) {
            instance = new PrometheusSettings();
        }
        return instance;
    }
}
