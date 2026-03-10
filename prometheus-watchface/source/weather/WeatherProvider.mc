using Toybox.Weather;

class WeatherProvider {

    // Map Garmin Weather.Condition codes to drawable resource IDs
    static function getWeatherIcon(condition) {
        if (condition == null) {
            return Rez.Drawables.ic_sunny;
        }
        if (condition == Weather.CONDITION_CLEAR) {
            return Rez.Drawables.ic_sunny;
        }
        if (condition == Weather.CONDITION_PARTLY_CLOUDY) {
            return Rez.Drawables.ic_partly_cloudy;
        }
        if (condition == Weather.CONDITION_MOSTLY_CLOUDY) {
            return Rez.Drawables.ic_partly_cloudy;
        }
        if (condition == Weather.CONDITION_CLOUDY) {
            return Rez.Drawables.ic_partly_cloudy;
        }
        if (condition == Weather.CONDITION_RAIN) {
            return Rez.Drawables.ic_rain;
        }
        if (condition == Weather.CONDITION_LIGHT_RAIN) {
            return Rez.Drawables.ic_rain;
        }
        if (condition == Weather.CONDITION_HEAVY_RAIN) {
            return Rez.Drawables.ic_rain;
        }
        if (condition == Weather.CONDITION_SHOWERS) {
            return Rez.Drawables.ic_rain;
        }
        if (condition == Weather.CONDITION_THUNDERSTORMS) {
            return Rez.Drawables.ic_thunderstorm;
        }
        if (condition == Weather.CONDITION_SNOW) {
            return Rez.Drawables.ic_snow;
        }
        if (condition == Weather.CONDITION_LIGHT_SNOW) {
            return Rez.Drawables.ic_snow;
        }
        if (condition == Weather.CONDITION_HEAVY_SNOW) {
            return Rez.Drawables.ic_snow;
        }
        if (condition == Weather.CONDITION_FOG) {
            return Rez.Drawables.ic_fog;
        }
        if (condition == Weather.CONDITION_HAZE) {
            return Rez.Drawables.ic_fog;
        }
        if (condition == Weather.CONDITION_MIST) {
            return Rez.Drawables.ic_fog;
        }
        if (condition == Weather.CONDITION_WINDY) {
            return Rez.Drawables.ic_windy;
        }
        // Default fallback
        return Rez.Drawables.ic_sunny;
    }

    // Get human-readable condition text
    static function getConditionText(condition) {
        if (condition == null) { return ""; }
        if (condition == Weather.CONDITION_CLEAR) { return "Clear"; }
        if (condition == Weather.CONDITION_PARTLY_CLOUDY) { return "Partly Cloudy"; }
        if (condition == Weather.CONDITION_MOSTLY_CLOUDY) { return "Mostly Cloudy"; }
        if (condition == Weather.CONDITION_CLOUDY) { return "Cloudy"; }
        if (condition == Weather.CONDITION_RAIN) { return "Rain"; }
        if (condition == Weather.CONDITION_LIGHT_RAIN) { return "Light Rain"; }
        if (condition == Weather.CONDITION_HEAVY_RAIN) { return "Heavy Rain"; }
        if (condition == Weather.CONDITION_SHOWERS) { return "Showers"; }
        if (condition == Weather.CONDITION_THUNDERSTORMS) { return "Thunderstorms"; }
        if (condition == Weather.CONDITION_SNOW) { return "Snow"; }
        if (condition == Weather.CONDITION_LIGHT_SNOW) { return "Light Snow"; }
        if (condition == Weather.CONDITION_HEAVY_SNOW) { return "Heavy Snow"; }
        if (condition == Weather.CONDITION_FOG) { return "Fog"; }
        if (condition == Weather.CONDITION_HAZE) { return "Haze"; }
        if (condition == Weather.CONDITION_MIST) { return "Mist"; }
        if (condition == Weather.CONDITION_WINDY) { return "Windy"; }
        return "Unknown";
    }

    // Convert Celsius to Fahrenheit
    static function celsiusToF(c) {
        if (c == null) { return null; }
        return (c * 9 / 5 + 32).toNumber();
    }

    // Convert m/s to mph
    static function msToMph(ms) {
        if (ms == null) { return null; }
        return (ms * 2.237).toNumber();
    }

    // Check if it's nighttime based on condition or time
    static function isNightCondition(condition) {
        if (condition == Weather.CONDITION_CLEAR) {
            var clockTime = System.getClockTime();
            // Simple heuristic: night = before 6am or after 8pm
            if (clockTime.hour < 6 || clockTime.hour >= 20) {
                return true;
            }
        }
        return false;
    }

    // Get weather icon with night awareness
    static function getWeatherIconWithNight(condition) {
        if (isNightCondition(condition)) {
            return Rez.Drawables.ic_clear_night;
        }
        return getWeatherIcon(condition);
    }
}
