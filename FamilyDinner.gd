extends Node2D

# Options panel
const OptionsPanel = preload("res://ui/OptionsPanel.gd")
export(NodePath) var options_path = NodePath("ui/options")
onready var _options_panel: OptionsPanel = self.get_node(options_path)

# Narrative panel
const NarrativePanel = preload("res://ui/NarrativePanel.gd")
export(NodePath) var narrative_path = NodePath("ui/narrative")
onready var _narrative_panel: NarrativePanel = self.get_node(narrative_path)

var _passed_conversations = []

var _potential_conversations: Dictionary = {
	"#1": ConversationSegment.new("First alternative from dictionary", [], [
		{"speaker": "Godot mascot", "text": "Dialog text from dictionary #1"},
		{"text": "Narration dictionary #1"},
	]),
	"#1a": ConversationSegment.new("Another option (sometime after first)", [
		{"passed": "#1"}
	], [
		{"text": "Follow up on #1"},
	]),
	"#2": ConversationSegment.new("Second alternative from dictionary", [], [
		{"speaker": "Godot mascot", "text": "Dialog text from dictionary #2"},
		{"text": "Narration dictionary #2"},
	]),
	"#2a": ConversationSegment.new("Different option (sometime after second)", [
		{"passed": "#2"}
	], [
		{"text": "Follow up on #2"},
	]),
	"1+2=3": ConversationSegment.new("Conclusive option (after both 'originals')", [
		{"passed": "#1"}, {"passed": "#2"},
	], [
		{"text": "Follow up on #1 and #2"},
	]),
}


# Populate options panel with some placeholders
func _ready():
	self.populate_options()


func populate_options():
	_options_panel.clear_options()

	# Filter out available conversations
	var available_conversations = []
	for key in _potential_conversations.keys():
		var segment:ConversationSegment = _potential_conversations[key]
		# Don't allow doing the same thing twice
		if key in _passed_conversations:
			continue
		# All prequisites must be fullfilled
		if segment.is_presentable(_passed_conversations):
			available_conversations.append([key, segment])

	# Add buttons for each available conversation
	for a in available_conversations:
		var key: String = a[0]
		var segment:ConversationSegment = a[1]
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

	# Record as passed conversation
	_passed_conversations.append(key)

func _on_narrative_pressentation_completed():
	_narrative_panel.visible = false
	self.populate_options()
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

	func is_presentable(passed: Array):
		for pr in prequisites:
			if not fullfilled(pr, passed):
				return false
		return true

	func fullfilled(pr, passed: Array):
		match pr:
			{"passed": var key}:
				return key in passed

			_:
				printerr("Unrechognized prequisite:", pr)
				return false

	func present(out):
		for el in self.narrative:
			match el:
				{"text": var text, "speaker": var speaker}:
					out.queue_dialouge(speaker, text)

				{"text": var text}:
					out.queue_narration(text)

				_:
					printerr("Unablle to pressent", el)
