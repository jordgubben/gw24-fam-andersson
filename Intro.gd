extends Control



func _on_ge_btn_pressed(ge):
	# Determine gender expression randomly
	if ge == "rnd":
		randomize()
		ge = "grl" if randi() % 2 == 0 else "boi"
	
	prints("Gender expression set to:", ge)
	settings.so_gender_expression = ge
	self.get_tree().change_scene("res://FamilyDinner.tscn")
