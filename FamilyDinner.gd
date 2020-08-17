extends Node2D

# Options panel
const OptionsPanel = preload("res://ui/OptionsPanel.gd")
export(NodePath) var options_path = NodePath("ui/options")
onready var _options_panel: OptionsPanel = self.get_node(options_path)

# Narrative panel
const NarrativePanel = preload("res://ui/NarrativePanel.gd")
export(NodePath) var narrative_path = NodePath("ui/narrative")
onready var _narrative_panel: NarrativePanel = self.get_node(narrative_path)

# Populate options panel with some placeholders
func _ready():
	_options_panel.add_option("#1", "First alternative")
	_options_panel.add_option("#2", "Second alternative")


func _on_options_option_selected(key):
	prints(self, "_on_options_option_selected", key)
	_options_panel.visible = false

	_narrative_panel.clear();
	_narrative_panel.visible = true
	match key:
		"#1":
			_narrative_panel.queue_dialouge("Godot mascot", "Dynamic dialog text #1")
			_narrative_panel.queue_narration("Dynamic naration #1")
		"#2":
			_narrative_panel.queue_narration("Dynamic naration #2")
			_narrative_panel.queue_dialouge("Godot mascot", "Dynamic dialog text #2")


