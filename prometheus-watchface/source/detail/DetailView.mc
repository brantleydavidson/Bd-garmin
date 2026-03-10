using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Lang;

class DetailView extends WatchUi.View {

    const CX = 227;
    const CY = 227;
    const SCREEN = 454;

    var _title;
    var _accentColor;
    var _metricKey;

    function initialize(title, accentColor, metricKey) {
        View.initialize();
        _title = title;
        _accentColor = accentColor;
        _metricKey = metricKey;
    }

    function onUpdate(dc) {
        // Black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var data = getData();

        // Title
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 40, Graphics.FONT_XTINY, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Hero value
        var heroVal = (data.hasKey(:heroValue)) ? data[:heroValue] : "--";
        dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 100, Graphics.FONT_NUMBER_HOT, heroVal, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Unit label
        if (data.hasKey(:unit)) {
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX, 140, Graphics.FONT_XTINY, data[:unit], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Status subtitle
        if (data.hasKey(:status)) {
            dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX, 162, Graphics.FONT_XTINY, data[:status], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Bar chart (6 bars)
        if (data.hasKey(:history)) {
            drawBarChart(dc, data[:history], _accentColor);
        }

        // Bar chart label
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 295, Graphics.FONT_XTINY, "LAST 6 DAYS \u00B7 TODAY \u2192", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stats grid (2x2)
        if (data.hasKey(:stats)) {
            drawStatsGrid(dc, data[:stats]);
        }

        // Coaching tip
        if (data.hasKey(:tip)) {
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX, 400, Graphics.FONT_XTINY, data[:tip], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Back hint
        dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 435, Graphics.FONT_XTINY, "\u2190 BACK", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawBarChart(dc, data, color) {
        if (data == null || data.size() == 0) { return; }

        var barCount = data.size();
        if (barCount > 6) { barCount = 6; }

        var barWidth = 30;
        var barGap = 10;
        var totalWidth = barCount * barWidth + (barCount - 1) * barGap;
        var startX = CX - totalWidth / 2;
        var baseY = 280;
        var maxBarH = 60;

        // Find max for scaling
        var maxVal = 1;
        for (var i = 0; i < barCount; i++) {
            if (data[i] != null && data[i] > maxVal) {
                maxVal = data[i];
            }
        }

        for (var i = 0; i < barCount; i++) {
            var val = (data[i] != null) ? data[i] : 0;
            var barH = (val.toFloat() / maxVal * maxBarH).toNumber();
            if (barH < 2) { barH = 2; }

            var x = startX + i * (barWidth + barGap);
            var y = baseY - barH;

            // Last bar (today) is brightest, others are dimmer
            var alpha = (i == barCount - 1) ? color : (color & 0x7FFFFF);
            dc.setColor(alpha, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, barWidth, barH, 3);
        }
    }

    function drawStatsGrid(dc, stats) {
        // stats is an array of {:key, :value} dicts, up to 4
        if (stats == null || stats.size() == 0) { return; }

        var positions = [
            [CX - 70, 325],  // top-left
            [CX + 70, 325],  // top-right
            [CX - 70, 360],  // bottom-left
            [CX + 70, 360]   // bottom-right
        ];

        for (var i = 0; i < stats.size() && i < 4; i++) {
            var stat = stats[i];
            var px = positions[i][0];
            var py = positions[i][1];

            // Value
            dc.setColor(0xC8C8C8, Graphics.COLOR_TRANSPARENT);
            dc.drawText(px, py, Graphics.FONT_XTINY, stat[:value], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // Key label
            dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
            dc.drawText(px, py + 14, Graphics.FONT_XTINY, stat[:key], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Subclasses must override this
    function getData() {
        return {
            :heroValue => "--",
            :unit => "",
            :status => "",
            :history => [0, 0, 0, 0, 0, 0],
            :stats => [],
            :tip => ""
        };
    }
}
