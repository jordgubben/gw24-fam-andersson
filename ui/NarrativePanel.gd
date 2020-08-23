extends Control

const Person = preload("res://Person.gd")

var DialougeBox: PackedScene = preload("res://ui/DialougeBox.tscn")
var NarrationBox: PackedScene = preload("res://ui/NarrationBox.tscn")
var AnxietyBox: PackedScene = preload("res://ui/AnxietyChangeBox.tscn")
var FavourBox: PackedScene = preload("res://ui/FavourChangeBox.tscn")

signal anxiety_changed(change)
signal favour_changed(person, change)
signal animation_requested(animation_id)
signal pressentation_completed()

var _postponed_elements:Array = []

func _ready():
	# Remove placeholders
	clear()

func queue_dialouge(speaker: Person, dialoug: String):
	var d = DialougeBox.instance()
	d.get_node("speaker_name").text = speaker.speaker_name
	d.get_node("speaker_portrait").texture = speaker.speaker_portrait
	d.get_node("speaker_portrait").modulate = speaker.self_modulate
	d.get_node("dialouge_label").bbcode_text = dialoug
	self.queue_element(d)


func queue_narration(narration: String):
	var n = NarrationBox.instance()
	var label = "[center]" + narration +"[/center]"
	n.get_node("narration_label").bbcode_text = label
	self.queue_element(n)


func queue_animation(animation_id:String):
	var control = Control.new()

	var con_err = control.connect("tree_entered", self, "_on_animation_requested", [animation_id])
	if con_err != OK:
		printerr("Failed to connect '_on_animation_requested' due to error code:", con_err)

	self.queue_element(control)


func _on_animation_requested(animation_id:String ):
	self.emit_signal("animation_requested", animation_id)


func queue_anxiety_change(change: float):
	var box:Control = AnxietyBox.instance()

	# Set label
	var label: RichTextLabel = box.get_node("label")
	if change > 0:
		label.bbcode_text = "Anxiety [color=red]increased[/color]!"
	elif change < 0:
		label.bbcode_text = "Anxiety [color=blue]decreased[/color]!"
	else:
		label.bbcode_text = "Anxiety [color=green]remained unchanged[/color]."

	# Center text
	label.bbcode_text = "[center]" + label.bbcode_text + "[/center]"

	# Connect
	var con_err := box.connect("tree_entered", self, "_on_anxiety_changed", [change])
	if con_err != OK:
		printerr("Failed to connect '_on_anxiety_changed' to self. Error code:", con_err)

	self.queue_element(box)


func _on_anxiety_changed(change):
	prints(self, "_on_anxiety_changed:", change)
	self.emit_signal("anxiety_changed", change)


func queue_favour_change(person: Person, change: float):
	var box:Control = FavourBox.instance()

	# Set label
	var label: RichTextLabel = box.get_node("label")
	if change > 0:
		label.bbcode_text = "Gained favour with %s!" % person.speaker_name
	elif change < 0:
		label.bbcode_text = "Lost favour with %s!" % person.speaker_name
	else:
		label.bbcode_text = "Favour remained unchanged with %s." % person.speaker_name

	# Center text
	label.bbcode_text = "[center]" + label.bbcode_text + "[/center]"

	box.connect("tree_entered", self, "_on_favour_changed", [person, change])

	self.queue_element(box)


func _on_favour_changed(person:Person, change: float):
	self.emit_signal("favour_changed", person, change)


func queue_element(new_el: Control):
	# Don't add anything more if there's already a queue
	if not _postponed_elements.empty():
		_postponed_elements.push_back(new_el)
		return

	# See if there is room for one more
	if not self.present_element(new_el):
		_postponed_elements.push_back(new_el)

func present_element(new_el:Control)->bool:
	# Total height of current elements
	var content_height = 0
	for el in $margin/vbox.get_children():
		content_height += el.rect_size.y

	# Height including the new element
	var new_total_height = new_el.rect_size.y + content_height;

	# Only add the new element if there is room for it
	var height_limit = $margin/vbox.rect_size.y
	if(new_total_height <= height_limit):
		$margin/vbox.add_child(new_el)
		return true
	else:
		return false


func clear():
	for c in $margin/vbox.get_children():
		$margin/vbox.remove_child(c)
		c.queue_free()

func _on_continue_button_pressed():
	# If there is nothing more to present
	# then we are done here
	if _postponed_elements.empty():
		self.emit_signal("pressentation_completed")
		return

	# Make room for a new elements
	self.clear()

	# Attempt to add as many postponed elements as posible
	while not _postponed_elements.empty():
		var next_candidate = _postponed_elements.front()
		if self.present_element(next_candidate):
			_postponed_elements.pop_front()
		else:
			# Halt for now since there's no more room
			return
