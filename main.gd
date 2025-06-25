extends Node2D

var lat: String = ""
var lon: String = ""
var currentweatherurl: String = ""

func _ready() -> void:
	load_coordinates()
	if lat != "" and lon != "":
		currentweatherurl = "https://api.open-meteo.com/v1/forecast?" + \
			"latitude=" + lat + "&longitude=" + lon + \
			"&current=wind_speed_10m,wind_direction_10m,wind_gusts_10m," + \
			"weather_code,cloud_cover,precipitation,rain,showers,is_day," + \
			"temperature_2m,relative_humidity_2m,apparent_temperature&forecast_days=1"
		$HTTPRequest.request(currentweatherurl)
	else:
		print("Latitude or longitude missing.")

func load_coordinates() -> void:
	var file_path := "user://data.weather"
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_text := file.get_as_text()
			file.close()
			var json = JSON.parse_string(json_text)
			if typeof(json) == TYPE_DICTIONARY:
				lat = str(json.get("latitude", ""))
				lon = str(json.get("longitude", ""))
			else:
				print("Invalid JSON structure in data.weather.")
	else:
		print("data.weather file not found.")

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("Error: ", response_code)
		return

	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_DICTIONARY:
		print("Invalid response.")
		return

	var current = response.get("current", {})
	var units = response.get("current_units", {})

	print("Weather at (", response.get("latitude"), ",", response.get("longitude"), ")")
	print("Timezone:", response.get("timezone_abbreviation"))
	print("Time:", current.get("time"))
	print("Temperature:", current.get("temperature_2m"), units.get("temperature_2m"))
	print("Feels Like:", current.get("apparent_temperature"), units.get("apparent_temperature"))
	print("Humidity:", current.get("relative_humidity_2m"), units.get("relative_humidity_2m"))
	print("Wind Speed:", current.get("wind_speed_10m"), units.get("wind_speed_10m"))
	print("Wind Gusts:", current.get("wind_gusts_10m"), units.get("wind_gusts_10m"))
	print("Wind Direction:", current.get("wind_direction_10m"), units.get("wind_direction_10m"))
	print("Cloud Cover:", current.get("cloud_cover"), units.get("cloud_cover"))
	print("Precipitation:", current.get("precipitation"), units.get("precipitation"))
	print("Rain:", current.get("rain"), units.get("rain"))
	print("Showers:", current.get("showers"), units.get("showers"))
	print("Is Day:", current.get("is_day") == 1)
	
	$Currently/CurrentTemp.text = str(celsius_to_fahrenheit(float(current.get("temperature_2m")))) + "°F"+" "+"("+str(current.get("temperature_2m"))+"°C)"
	$Currently/FeelsLike.text = "Feels Like: "+str(celsius_to_fahrenheit(float(current.get("apparent_temperature")))) + "°F"+" "+"("+str(current.get("apparent_temperature"))+"°C)"
	$Currently/Humidity.text = "Humidity: "+str(current.get("relative_humidity_2m")) + units.get("relative_humidity_2m")
	$Currently/WindSpeed.text = "Wind Speed: "+str(kmh_to_mph(float(current.get("wind_speed_10m")))) + "mph"+" "+"("+str(current.get("wind_speed_10m"))+"km/h)"
	$Currently/WindGusts.text = "Wind Gusts: "+str(kmh_to_mph(float(current.get("wind_gusts_10m")))) + "mph"+" "+"("+str(current.get("wind_gusts_10m"))+"km/h)"
	$Currently/WindDirection.text = "Wind Direction: "+str(get_cardinal_direction(current.get("wind_direction_10m")))
	$Currently/CloudCover.text = "Cloud Cover: "+str(current.get("cloud_cover"))+units.get("cloud_cover")
	$Currently/Precip.text = "Precipitation: "+str(current.get("precipitation"))+units.get("precipitation")
	$Currently/Rain.text = "Rain: "+str(current.get("rain"))+units.get("rain")
	$Currently/Showers.text = "Showers: "+str(current.get("showers"))+units.get("showers")
	
func celsius_to_fahrenheit(celsius_temp: float):
	var fahrenheit_temp = (celsius_temp * 9.0 / 5.0) + 32.0
	return fahrenheit_temp
	
func get_cardinal_direction(degrees: float) -> String:
	if degrees >= 315 or degrees < 45:
		return "North"
	elif degrees >= 45 and degrees < 135:
		return "East"
	elif degrees >= 135 and degrees < 225:
		return "South"
	elif degrees >= 225 and degrees < 315:
		return "West"
	else:
		return "Unknown"
		
func kmh_to_mph(speed_kmh):
	var speed_mph = speed_kmh * 0.621371
	return snappedf(speed_mph, 0.1)
