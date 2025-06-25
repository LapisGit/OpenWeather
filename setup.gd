extends Node2D
var city
var zipcode
var saved_lat
var saved_lon

func _on_part_1_done_pressed() -> void:
	var city = $Part1/CityName.text
	var zipcode = $Part1/ZipCode.text
	var url = "https://nominatim.openstreetmap.org/search?format=json&q="+city+"+"+zipcode
	print(url)

	var err = $HTTPRequest.request(url, ["User-Agent: Godot"])
	if err != OK:
		print("Request failed: ", err)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("HTTP Error: ", response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json is Array:
		for item in json:
			if item.has("type") and item["type"] == "town" or "administrative" or "city" or "village":
				saved_lat = item.get("lat")
				saved_lon = item.get("lon")
				print("Found Town:")
				print("Name: ", item.get("display_name"))
				print("Latitude: ", saved_lat)
				print("Longitude: ", saved_lon)
				$Part1.visible = false
				$Part1Confirm.visible = true
				$Part1Confirm/PartText2.text = item.get("display_name")
				return

		print("No town found in the results.")
	else:
		print("Invalid JSON response.")


func _on_yes_pressed() -> void:
	var file_path := "user://data.weather"
	var location_data := {
		"latitude": saved_lat,
		"longitude": saved_lon
	}

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(location_data, "\t")) # Pretty-print with tabs
		file.close()
		print("Location saved to ", file_path)
	else:
		print("Failed to open file for writing.")
	global.changescene("res://main.tscn")


func _on_no_pressed() -> void:
	$Part1Confirm.visible = false
	$Part1.visible = true
