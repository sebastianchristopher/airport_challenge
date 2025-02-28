class Weather
  attr_reader :weather_rating

  def initialize
    generate_weather
  end

  def stormy?
    @weather_rating >= 9
  end

  private

  def generate_weather
    @weather_rating = rand(1..10)
  end
end
