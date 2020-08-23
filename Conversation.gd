extends Node

# Options panel
const OptionsPanel = preload("res://ui/OptionsPanel.gd")
export(NodePath) var options_path = NodePath("../ui/options")
onready var _options_panel: OptionsPanel = self.get_node(options_path)

# Narrative panel
const NarrativePanel = preload("res://ui/NarrativePanel.gd")
export(NodePath) var narrative_path = NodePath("../ui/narrative")
onready var _narrative_panel: NarrativePanel = self.get_node(narrative_path)

# Participants container
export(NodePath) var participants_path = NodePath("../participants")
onready var _participants: Node = self.get_node(participants_path)

var _passed_segments = []
var segments_db:Dictionary = {
	"#1": ConversationSegment.new("First alternative from dictionary", [], [
		{"speaker": "father-in-law", "text": "Dialog text from dictionary #1"},
		{"text": "Narration dictionary #1"},
	]),
	"#1a": ConversationSegment.new("Another option (right after first)", [
		{"follows": "#1"}
	], [
		{"text": "Follow up on #1"},
	]),
	"#2": ConversationSegment.new("Second alternative from dictionary", [], [
		{"speaker": "mother-in-law", "text": "Dialog text from dictionary #2"},
		{"text": "Narration dictionary #2"},
	]),
	"#2a": ConversationSegment.new("Different option (right after second)", [
		{"follows": "#2"}
	], [
		{"text": "Follow up on #2"},
	]),

	"1,2?": ConversationSegment.new("Optional option (after any of the 'originals')", [
		{"after_any": ["#1", "#2"]},
	], [
		{"text": "Follow up on #1 and #2"},
	]),

	"1+2=3": ConversationSegment.new("Conclusive option (after both 'originals')", [
		{"after_all": ["#1", "#2"]},
	], [
		{"text": "Follow up on #1 and #2"},
	]),
}

func _ready():
	self.populate_options()


func get_last_segment():
	return _passed_segments.back() if not _passed_segments.empty() else null


func populate_options():
	_options_panel.clear_options()

	# Filter out available conversations
	var available_conversations = []
	for key in segments_db.keys():
		var segment:ConversationSegment = segments_db[key]
		# Don't allow doing the same thing twice
		if key in _passed_segments:
			continue
		# All prequisites must be fullfilled
		if segment.is_presentable(_passed_segments):
			available_conversations.append([key, segment])

	# Are there prioritized options?
	var nead_to_prioritize = false
	for a in available_conversations:
		var key: String = a[0]
		var segment:ConversationSegment = a[1]

		if segment.is_prioritized():
			nead_to_prioritize = true

	# Add buttons for each available conversation
	for a in available_conversations:
		var key: String = a[0]
		var segment:ConversationSegment = a[1]

		if not nead_to_prioritize or segment.is_prioritized():
			var title: String = segment.title
			_options_panel.add_option(key, title)

func rewind_one_step():
	_passed_segments.pop_back()
	self.pressent_options()

func pressent_options():
	_narrative_panel.visible = false
	self.populate_options()
	_options_panel.visible = true

func present_segment(key:String):
	# Hide options
	_options_panel.visible = false

	var speakers = {}
	for c in _participants.get_children():
		speakers[c.name] = c

	# Present narrative pannel
	_narrative_panel.clear();
	var segment:ConversationSegment = segments_db[key]
	segment.present(speakers, _narrative_panel)
	_narrative_panel.visible = true

	# Record as passed conversation
	_passed_segments.push_back(key)

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


	func is_prioritized():
		for pr in prequisites:
			if "follows" in pr.keys():
				return true
		return false


	func fullfilled(pr, passed: Array):
		match pr:
			# Require that this comes directly after the given statemen(s)
			{"follows": var key}:
				var last_segment_key = passed.back()
				if key is String:
					return last_segment_key ==  key
				elif key is Array:
					return last_segment_key in key
				else:
					printerr("Unrechognized type for 'follows':", typeof(key))

			# Require that this commes sometime *after* the given statemen
			{"after": var key}:
				if key is String:
					return key in passed
				else:
					printerr("Unrechognized type for 'after':", typeof(key))

			# Require that this commes sometime *after any* of the given statemens
			{"after_any": var keys }:
				if keys is Array:
					for k in keys:
						if k in passed:
							return true
					return false
				else:
					printerr("Unrechognized type for 'after_any':", typeof(keys))

			# Require that this commes sometime *after all* of the given statemens
			{"after_all": var keys }:
				if keys is Array:
					for k in keys:
						if not k in passed:
							return false
					return true
				else:
					printerr("Unrechognized type for 'after_all':", typeof(keys))

			_:
				printerr("Unrechognized prequisite:", pr)
		#
		return false

	func present(speakers, out):
		for el in self.narrative:
			match el:
				{"text": var text, "speaker": var speaker_id}:
					if speaker_id in speakers:
						var speaker = speakers[speaker_id]
						out.queue_dialouge(speaker, text)
					else:
						printerr("Unknown speaker: ", speaker_id)

				{"text": var text}:
					out.queue_narration(text)

				{"change_anxiety": var c }:
					out.queue_anxiety_change(c)

				{"change_favour_of": var speaker_id, "by_amount": var c }:
					var speaker = speakers[speaker_id]
					out.queue_favour_change(speaker, c)

				{"play_animation": var animation_id}:
					out.queue_animation(animation_id)

				_:
					printerr("Unablle to pressent", el)
