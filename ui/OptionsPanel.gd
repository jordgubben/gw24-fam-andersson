extends Control


signal option_selected(key)

func _ready():
	# Clear placeholders
	for c in $margin/vbox.get_children():
		self.remove_child(c)
		c.queue_free()

func add_option(key: String, title: String):
	var b = Button.new()
	b.text = title
	b.connect("pressed", self, "on_option_clicked", [key])
	$margin/vbox.add_child(b)

func on_option_clicked(key:String):
	prints("Selected: ", key)
	self.emit_signal("option_selected", key)
