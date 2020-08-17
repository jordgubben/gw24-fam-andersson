extends Control

onready var _dialouge_prototype: Control = $margin/vbox/dialouge_example
onready var _narration_prototype: RichTextLabel = $margin/vbox/narration_example

func _ready():
	# Remove prototypes from tree
	# (but keep them for future cloning)
	self.remove_child(_dialouge_prototype)
	self.remove_child(_narration_prototype)

func queue_dialouge(speaker: String, dialoug: String):
	var d =_dialouge_prototype.duplicate()
	d.get_node("dialouge_label").bbcode_text = dialoug
	$margin/vbox.add_child(d)

func queue_narration(narration: String):
	var n =_narration_prototype.duplicate()
	n.bbcode_text = narration
	$margin/vbox.add_child(n)

func clear():
	for c in $margin/vbox.get_children():
		self.remove_child(c)
		c.queue_free()
