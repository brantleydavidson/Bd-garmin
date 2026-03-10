using Toybox.Weather;

class WeatherDetail extends DetailView {

    function initialize() {
        DetailView.initialize("WEATHER", 0x90A4AE, :weather);
    }

    function getData() {
        var heroVal = "--";
        var status = "";
        var stats = [];

        try {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null) {
                // Temperature as hero
                if (conditions.temperature != null) {
                    var tempF = WeatherProvider.celsiusToF(conditions.temperature);
                    heroVal = tempF.toString() + "\u00B0";
                }

                // Condition text
                status = WeatherProvider.getConditionText(conditions.condition);

                // Stats
                var feelsLike = "---";
                if (conditions.feelsLikeTemperature != null) {
                    feelsLike = WeatherProvider.celsiusToF(conditions.feelsLikeTemperature).toString() + "\u00B0F";
                }
                var humidity = "---";
                if (conditions.relativeHumidity != null) {
                    humidity = conditions.relativeHumidity.toString() + "%";
                }
                var wind = "---";
                if (conditions.windSpeed != null) {
                    wind = WeatherProvider.msToMph(conditions.windSpeed).toString() + " mph";
                }
                var uv = "---";
                if (conditions has :uvIndex && conditions.uvIndex != null) {
                    uv = conditions.uvIndex.toString();
                }

                stats = [
                    {:key => "FEELS LIKE", :value => feelsLike},
                    {:key => "HUMIDITY", :value => humidity},
                    {:key => "WIND", :value => wind},
                    {:key => "UV INDEX", :value => uv}
                ];
            }
        } catch (e) {}

        if (stats.size() == 0) {
            stats = [
                {:key => "FEELS LIKE", :value => "---"},
                {:key => "HUMIDITY", :value => "---"},
                {:key => "WIND", :value => "---"},
                {:key => "UV INDEX", :value => "---"}
            ];
        }

        return {
            :heroValue => heroVal,
            :unit => "Fahrenheit",
            :status => status,
            :history => [0, 0, 0, 0, 0, 0],
            :stats => stats,
            :tip => "Connect phone for weather data"
        };
    }
}
