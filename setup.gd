extends Node2D
var city
var zipcode


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
				var lat = item.get("lat")
				var lon = item.get("lon")
				print("Found Town:")
				print("Name: ", item.get("display_name"))
				print("Latitude: ", lat)
				print("Longitude: ", lon)
				$Part1.visible = false
				$Part1Confirm.visible = true
				$Part1Confirm/PartText2.text = item.get("display_name")
				return

		print("No town found in the results.")
	else:
		print("Invalid JSON response.")
