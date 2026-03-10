using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.UserProfile;
using Toybox.SensorHistory;
using Toybox.Weather;
using Toybox.Time;
using Toybox.Time.Gregorian;

class PrometheusView extends WatchUi.WatchFace {

    // Screen constants
    const CX = 227;
    const CY = 227;
    const SCREEN = 454;

    // Arc constants
    const OUTER_R = 213;
    const OUTER_STROKE = 5;
    const INNER_R = 199;
    const INNER_STROKE = 4;
    const ARC_START = -150;
    const ARC_END = 150;
    const ARC_SWEEP = 300;

    // Colors
    const TRACK_OUTER = 0x1A1A1A;
    const TRACK_INNER = 0x161616;
    const TICK_MAJOR = 0x282828;
    const TICK_MINOR = 0x161616;
    const DATE_COLOR = 0x484848;
    const LABEL_DIM = 0x888888;
    const DIVIDER_COLOR = 0x1E1E1E;
    const FOOTER_COLOR = 0x484848;
    const SLOT_BORDER = 0x252525;

    // Readiness colors
    const READY_COLOR = 0x00E676;
    const MODERATE_COLOR = 0xFFB300;
    const EASY_COLOR = 0xEF5350;

    // State
    var _isSleeping = false;
    var _settings;

    // Cached data (refreshed each onUpdate)
    var _bodyBattery = null;
    var _hrv = null;
    var _sleepHours = null;
    var _sleepScore = null;
    var _rhr = null;
    var _trainingLoad = null;
    var _steps = null;
    var _kcal = null;
    var _stress = null;
    var _vo2 = null;
    var _floors = null;
    var _tss = null;
    var _weather = null;

    // Weather icon bitmap cache
    var _weatherIcon = null;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _settings = PrometheusSettings.getInstance();
    }

    function onShow() {
    }

    function onUpdate(dc) {
        _settings = PrometheusSettings.getInstance();
        fetchData();

        // Clear screen
        dc.setColor(_settings.bgColor, _settings.bgColor);
        dc.clear();

        // Draw in z-order
        drawTicks(dc);
        drawOuterArc(dc);
        drawInnerArc(dc);
        drawArcLabels(dc);
        drawDateStrip(dc);
        drawWeatherStrip(dc);
        drawTime(dc);
        drawReadinessPill(dc);
        drawDivider(dc, CY + 48);
        drawMetricRow1(dc);
        drawMetricRow2(dc);
        drawDivider(dc, CY + 160);
        drawFooter(dc);
    }

    //
    // DATA FETCHING
    //

    function fetchData() {
        // Body Battery
        try {
            var info = Activity.getActivityInfo();
            if (info != null) {
                _bodyBattery = info.bodyBattery;
                _steps = info.steps;
                _kcal = info.calories;
                _stress = info.stressLevel;
                _floors = info.floorsClimbed;
            }
        } catch (e) {}

        // HRV from SensorHistory
        try {
            if (SensorHistory has :getHeartRateVariabilityHistory) {
                var hrvIter = SensorHistory.getHeartRateVariabilityHistory({:period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST});
                if (hrvIter != null) {
                    var sample = hrvIter.next();
                    if (sample != null && sample.data != null) {
                        _hrv = sample.data.toNumber();
                    }
                }
            }
        } catch (e) {}

        // Sleep
        try {
            if (UserProfile has :getSleepHistory) {
                var sleepHistory = UserProfile.getSleepHistory();
                if (sleepHistory != null && sleepHistory.size() > 0) {
                    var latest = sleepHistory[0];
                    if (latest has :duration && latest.duration != null) {
                        _sleepHours = (latest.duration.toFloat() / 3600.0);
                    }
                    if (latest has :score && latest.score != null) {
                        _sleepScore = latest.score;
                    }
                }
            }
        } catch (e) {}

        // Resting HR
        try {
            var profile = UserProfile.getProfile();
            if (profile != null && profile.restingHeartRate != null) {
                _rhr = profile.restingHeartRate;
            }
        } catch (e) {}

        // Training Load
        try {
            if (UserProfile has :getTrainingLoad) {
                _trainingLoad = UserProfile.getTrainingLoad();
            }
        } catch (e) {}

        // VO2 Max
        try {
            if (UserProfile has :getVO2MaxRunning) {
                _vo2 = UserProfile.getVO2MaxRunning();
            }
        } catch (e) {}

        // Weather
        try {
            _weather = Weather.getCurrentConditions();
        } catch (e) {}

        // TSS (placeholder: use training load / 10 as approximation)
        if (_trainingLoad != null) {
            _tss = (_trainingLoad / 10).toNumber();
        }
    }

    //
    // TICK MARKS
    //

    function drawTicks(dc) {
        var tickR = 221;
        for (var i = 0; i < 60; i++) {
            var angle = (i * 6.0); // degrees, 0=top
            var rad = Math.toRadians(angle);
            var sinA = Math.sin(rad);
            var cosA = Math.cos(rad);

            var isMajor = (i % 5 == 0);
            var tickLen = isMajor ? 14 : 6;
            var tickColor = isMajor ? TICK_MAJOR : TICK_MINOR;
            var tickWidth = isMajor ? 2 : 1;

            var outerX = CX + (tickR * sinA).toNumber();
            var outerY = CY - (tickR * cosA).toNumber();
            var innerX = CX + ((tickR - tickLen) * sinA).toNumber();
            var innerY = CY - ((tickR - tickLen) * cosA).toNumber();

            dc.setPenWidth(tickWidth);
            dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(outerX, outerY, innerX, innerY);
        }
    }

    //
    // ARC DRAWING
    //

    function drawArcSegment(dc, r, startDeg, endDeg, strokeW, color) {
        dc.setPenWidth(strokeW);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        // Garmin: 0=right, 90=top. Convert from our system (0=top, clockwise)
        var gStart = 90 - startDeg;
        var gEnd = 90 - endDeg;
        dc.drawArc(CX, CY, r, Graphics.ARC_CLOCKWISE, gStart, gEnd);
    }

    function drawOuterArc(dc) {
        // Track
        drawArcSegment(dc, OUTER_R, ARC_START, ARC_END, OUTER_STROKE, TRACK_OUTER);

        // Fill based on training load (0-100 normalized)
        var load = 0;
        if (_trainingLoad != null) {
            load = (_trainingLoad / 10.0);  // Normalize 0-999 to 0-99.9
            if (load > 100) { load = 100; }
        }
        if (load > 0) {
            var fillEnd = ARC_START + (load / 100.0 * ARC_SWEEP);

            // Premium glow
            if (_settings.isPremium) {
                drawArcSegment(dc, OUTER_R, ARC_START, fillEnd, OUTER_STROKE * 3, _settings.outerArcColor & 0x2EFFFFFF);
            }

            drawArcSegment(dc, OUTER_R, ARC_START, fillEnd, OUTER_STROKE, _settings.outerArcColor);
        }
    }

    function drawInnerArc(dc) {
        // Track - starts at 120deg, sweeps 300deg
        var innerStart = 120;
        var innerEnd = 420;
        drawArcSegment(dc, INNER_R, innerStart, innerEnd, INNER_STROKE, TRACK_INNER);

        // Fill based on body battery (0-100)
        var bb = 0;
        if (_bodyBattery != null) {
            bb = _bodyBattery;
            if (bb > 100) { bb = 100; }
        }
        if (bb > 0) {
            var fillEnd = innerStart + (bb.toFloat() / 100.0 * ARC_SWEEP);

            // Premium glow
            if (_settings.isPremium) {
                drawArcSegment(dc, INNER_R, innerStart, fillEnd, INNER_STROKE * 3, _settings.innerArcColor & 0x2EFFFFFF);
            }

            drawArcSegment(dc, INNER_R, innerStart, fillEnd, INNER_STROKE, _settings.innerArcColor);
        }
    }

    //
    // ARC LABELS
    //

    function drawArcLabels(dc) {
        dc.setColor(_settings.outerArcColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(56, CY, Graphics.FONT_XTINY, "LOAD", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(_settings.innerArcColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(398, CY, Graphics.FONT_XTINY, "BB", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // DATE STRIP
    //

    function drawDateStrip(dc) {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayOfWeek = now.day_of_week.toUpper();
        var month = now.month.toUpper();
        var day = now.day.format("%d");

        var dateStr = dayOfWeek.substring(0, 3) + " \u00B7 " + month.substring(0, 3) + " " + day;

        dc.setColor(DATE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 52, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // WEATHER STRIP
    //

    function drawWeatherStrip(dc) {
        if (_weather == null) {
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX, 80, Graphics.FONT_XTINY, "No weather data", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // Weather icon
        var iconRes = WeatherProvider.getWeatherIconWithNight(_weather.condition);
        var icon = WatchUi.loadResource(iconRes);
        dc.drawBitmap(CX - 13, 61, icon);

        // Temperature (right of icon)
        var temp = _weather.temperature;
        var tempStr = "--";
        if (temp != null) {
            var tempF = WeatherProvider.celsiusToF(temp);
            tempStr = tempF.toString() + "\u00B0";
        }
        dc.setColor(0xC8C8C8, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX + 22, 74, Graphics.FONT_XTINY, tempStr, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Feels-like temp (smaller, below temp)
        var feelsLike = _weather.feelsLikeTemperature;
        if (feelsLike != null) {
            var flF = WeatherProvider.celsiusToF(feelsLike);
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX + 22, 90, Graphics.FONT_XTINY, "FL " + flF.toString() + "\u00B0", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Wind (left of icon)
        var wind = _weather.windSpeed;
        if (wind != null) {
            var mph = WeatherProvider.msToMph(wind);
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX - 22, 74, Graphics.FONT_XTINY, mph.toString() + "mph", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Humidity (left, below wind)
        var hum = _weather.relativeHumidity;
        if (hum != null) {
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX - 22, 90, Graphics.FONT_XTINY, hum.toString() + "%", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Condition label (bottom center)
        var condText = WeatherProvider.getConditionText(_weather.condition);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 104, Graphics.FONT_XTINY, condText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // TIME DISPLAY
    //

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour.format("%02d");
        var mins = clockTime.min.format("%02d");
        var timeStr = hours + ":" + mins;

        // Premium glow effect
        if (_settings.isPremium) {
            dc.setColor(_settings.timeColor & 0x14FFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(CX, 213, Graphics.FONT_NUMBER_HOT, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        dc.setColor(_settings.timeColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, 213, Graphics.FONT_NUMBER_HOT, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // READINESS PILL
    //

    function drawReadinessPill(dc) {
        // Compute readiness score
        var hrvVal = (_hrv != null) ? _hrv : 0;
        var bbVal = (_bodyBattery != null) ? _bodyBattery : 0;
        var slpVal = (_sleepScore != null) ? _sleepScore : 0;
        var readiness = (hrvVal * 0.4 + bbVal * 0.4 + slpVal * 0.2).toNumber();

        var label;
        var pillColor;
        if (readiness >= 70) {
            label = "\u25CF READY";
            pillColor = READY_COLOR;
        } else if (readiness >= 45) {
            label = "\u25CF MODERATE";
            pillColor = MODERATE_COLOR;
        } else {
            label = "\u25CF EASY DAY";
            pillColor = EASY_COLOR;
        }

        // Draw pill background
        var pillX = CX - 52;
        var pillY = CY + 13;
        var pillW = 104;
        var pillH = 24;
        var pillR = 12;

        dc.setColor(_settings.pillBgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(pillX, pillY, pillW, pillH, pillR);

        // Draw pill text
        dc.setColor(pillColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, pillY + pillH / 2, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // DIVIDER
    //

    function drawDivider(dc, y) {
        dc.setPenWidth(1);
        dc.setColor(DIVIDER_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(CX - 145, y, CX + 145, y);
    }

    //
    // METRIC GRID
    //

    function drawMetricRow1(dc) {
        var valY = CY + 74;
        var lblY = CY + 90;

        // Body Battery
        var bbStr = (_bodyBattery != null) ? _bodyBattery.toString() : "--";
        drawMetricCell(dc, CX - 96, valY, lblY, bbStr, "BB");

        // HRV
        var hrvStr = (_hrv != null) ? _hrv.toString() : "--";
        drawMetricCell(dc, CX, valY, lblY, hrvStr, "HRV");

        // Sleep Hours
        var sleepStr = "--";
        if (_sleepHours != null) {
            var h = _sleepHours.toNumber();
            var m = ((_sleepHours - h) * 60).toNumber();
            sleepStr = h.toString() + "h" + m.format("%02d");
        }
        drawMetricCell(dc, CX + 96, valY, lblY, sleepStr, "SLEEP");
    }

    function drawMetricRow2(dc) {
        var valY = CY + 130;
        var lblY = CY + 146;

        // Resting HR (fixed)
        var rhrStr = (_rhr != null) ? _rhr.toString() : "--";
        drawMetricCell(dc, CX - 96, valY, lblY, rhrStr, "RHR");

        // Swappable Slot 1
        var s1Val = getSlotValue(_settings.slot1Metric);
        var s1Label = getSlotLabel(_settings.slot1Metric);
        drawSwappableCell(dc, CX, valY, lblY, s1Val, s1Label);

        // Swappable Slot 2
        var s2Val = getSlotValue(_settings.slot2Metric);
        var s2Label = getSlotLabel(_settings.slot2Metric);
        drawSwappableCell(dc, CX + 96, valY, lblY, s2Val, s2Label);
    }

    function drawMetricCell(dc, x, valY, lblY, value, label) {
        dc.setColor(_settings.metricColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, valY, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(LABEL_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, lblY, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSwappableCell(dc, x, valY, lblY, value, label) {
        // Dashed border rectangle
        dc.setPenWidth(1);
        dc.setColor(SLOT_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(x - 38, valY - 20, 76, 40, 4);

        drawMetricCell(dc, x, valY, lblY, value, label);
    }

    function getSlotValue(metric) {
        if (metric == :load) {
            return (_trainingLoad != null) ? (_trainingLoad / 10).toNumber().toString() : "--";
        }
        if (metric == :tss) {
            return (_tss != null) ? _tss.toString() : "--";
        }
        if (metric == :slpScr) {
            return (_sleepScore != null) ? _sleepScore.toString() : "--";
        }
        if (metric == :steps) {
            return (_steps != null) ? formatSteps(_steps) : "--";
        }
        if (metric == :kcal) {
            return (_kcal != null) ? _kcal.toString() : "--";
        }
        if (metric == :stress) {
            return (_stress != null) ? _stress.toString() : "--";
        }
        if (metric == :vo2) {
            return (_vo2 != null) ? _vo2.toString() : "--";
        }
        if (metric == :floors) {
            return (_floors != null) ? _floors.toString() : "--";
        }
        return "--";
    }

    function getSlotLabel(metric) {
        if (metric == :load)   { return "LOAD";   }
        if (metric == :tss)    { return "TSS";    }
        if (metric == :slpScr) { return "SLP SC"; }
        if (metric == :steps)  { return "STEPS";  }
        if (metric == :kcal)   { return "KCAL";   }
        if (metric == :stress) { return "STRESS"; }
        if (metric == :vo2)    { return "VO2";    }
        if (metric == :floors) { return "FLOORS"; }
        return "---";
    }

    function formatSteps(steps) {
        if (steps >= 1000) {
            return (steps / 1000.0).format("%.1f") + "k";
        }
        return steps.toString();
    }

    //
    // FOOTER
    //

    function drawFooter(dc) {
        var slpStr = (_sleepScore != null) ? _sleepScore.toString() : "--";
        var tssStr = (_tss != null) ? _tss.toString() : "--";
        var footerStr = "SLP " + slpStr + " \u00B7 " + tssStr + " TSS";

        dc.setColor(FOOTER_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CX, CY + 177, Graphics.FONT_XTINY, footerStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //
    // AOD (Always-On Display)
    //

    function onEnterSleep() {
        _isSleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _isSleeping = false;
        WatchUi.requestUpdate();
    }

    function onPartialUpdate(dc) {
        if (_isSleeping) {
            // Minimal AOD
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();

            drawTime(dc);
            drawOuterArc(dc);

            if (_settings.isPremium) {
                drawInnerArc(dc);
                // Small HRV value
                var hrvStr = (_hrv != null) ? _hrv.toString() : "--";
                dc.setColor(0xBB86FC, Graphics.COLOR_TRANSPARENT);
                dc.drawText(CX, CY + 60, Graphics.FONT_XTINY, "HRV " + hrvStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }
}
