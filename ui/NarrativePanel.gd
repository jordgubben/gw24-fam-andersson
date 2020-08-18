extends Control

const Person = preload("res://Person.gd")

var DialougeBox: PackedScene = preload("res://ui/DialougeBox.tscn")
var NarrationBox: PackedScene = preload("res://ui/NarrationBox.tscn")

signal pressentation_completed()

func _ready():
	# Remove placeholders
	clear()

func queue_dialouge(speaker: Person, dialoug: String):
	var d = DialougeBox.instance()
	d.get_node("speaker_name").text = speaker.speaker_name
	d.get_node("dialouge_label").bbcode_text = dialoug
	$margin/vbox.add_child(d)

func queue_narration(narration: String):
	var n = NarrationBox.instance()
	n.bbcode_text = narration
	$margin/vbox.add_child(n)

func clear():
	for c in $margin/vbox.get_children():
		$margin/vbox.remove_child(c)
		c.queue_free()

func _on_continue_button_pressed():
	self.emit_signal("pressentation_completed")
