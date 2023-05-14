class Environment {
  final double temperature;
  final int humidity;
  final double pressure;

  final int aqi;

  Environment(this.temperature, this.humidity, this.pressure, this.aqi);

  Environment.fromJson(Map<String, dynamic> json)
      : temperature = json['data']['iaqi']['t']['v'],
        humidity = json['data']['iaqi']['h']['v'],
        pressure = json['data']['iaqi']['p']['v'],
        aqi = json['data']['aqi'];
}
