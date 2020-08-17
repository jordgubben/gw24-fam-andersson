extends Node2D

# Options panel
const OptionsPanel = preload("res://ui/OptionsPanel.gd")
export(NodePath) var options_path = NodePath("ui/options")
onready var _options_panel: OptionsPanel = self.get_node(options_path)

# Narrative panel
const NarrativePanel = preload("res://ui/NarrativePanel.gd")
export(NodePath) var narrative_path = NodePath("ui/narrative")
onready var _narrative_panel: NarrativePanel = self.get_node(narrative_path)


var _potential_conversations: Dictionary = {
	"#1": ConversationSegment.new("First alternative from dictionary", [], [
		{"speaker": "Godot mascot", "text": "Dialog text from dictionary #1"},
		{"text": "Narration dictionary #1"},
	]),
	"#2": ConversationSegment.new("Second alternative from dictionary", [], [
		{"speaker": "Godot mascot", "text": "Dialog text from dictionary #2"},
		{"text": "Narration dictionary #2"},
	]),
}


# Populate options panel with some placeholders
func _ready():
	for key in _potential_conversations.keys():
		var segment:ConversationSegment = _potential_conversations[key]
		var title: String = segment.title
		_options_panel.add_option(key, title)


func _on_options_option_selected(key):
	# Hide options
	_options_panel.visible = false

	# Present narrative pannel
	_narrative_panel.clear();
	var segment:ConversationSegment = _potential_conversations[key]
	segment.present(_narrative_panel)
	_narrative_panel.visible = true

func _on_narrative_pressentation_completed():
	_narrative_panel.visible = false
	_options_panel.visible = true

#
# A Narrative sequence is an exchange of thouhgts and feelings
# between one or more characters.
#
class ConversationSegment:
	var title: String = ""
	var prequisites: Array = []
	var narrative: Array = []

	func _init(title:String, preq: Array, narr:Array):
		self.title = title
		self.prequisites = preq
		self.narrative = narr

	func is_presentable():
		return true

	func present(out):
		for el in self.narrative:
			match el:
				{"text": var text, "speaker": var speaker}:
					out.queue_dialouge(speaker, text)

				{"text": var text}:
					out.queue_narration(text)

				_:
					printerr("Unablle to pressent", el)
