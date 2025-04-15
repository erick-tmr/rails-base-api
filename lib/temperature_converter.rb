class TemperatureConverter
  def initialize(kelvin_temperature)
    @kelvin_temperature = kelvin_temperature
  end

  def celsius
    @celsius ||= (@kelvin_temperature - 273.15).round(2)
  end

  def fahrenheit
    @fahrenheit ||= ((@kelvin_temperature - 273.15) * 1.8 + 32).round(2)
  end

  def kelvin
    @kelvin_temperature.round(2)
  end
end
