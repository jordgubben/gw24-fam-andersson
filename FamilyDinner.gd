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

const S = "speaker"
const SO = "significant_other"
const IV = "inner_voice"

var _potential_conversations: Dictionary = {
	# Real intro
	"start": ConversationSegment.new("(Start the actuall story)", [
	], [
		{S: "mother-in-law", "text": "Welcome, dear!"},
		{S: "mother-in-law", "text": "It brings such you to finaly get to meet you."},
	]),
	"start->inlaws": ConversationSegment.new("It's great to finally meet my inlaws", [
		{"passed": "start"},
	], [
		{S: "mother-in-law", "text": "\"Inlaws\"?!"},
		{S: "mother-in-law",
			"text": "We're not old enough to be someones inlaws, right dearest?"},
		{	"text": "My new father-in-law mumbles something about [b]golf[/b]" +
					"and [b]boats[/b] from behiond his newspaper."},
	]),
	"start->inlaws->apologize": ConversationSegment.new("(Apologize)", [
		{"passed": "start->inlaws"},
	], [
		{S: "me", "text": "Oh.. I didn't mean to imply.."},
		{S: SO, "text": "Mother. That's not what he/she said."},
		{S: "mother-in-law", "text": "Don't worry! I was just.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{S: "mother-in-law", "text": "..needed in the kitchen. Appartently."},
		{"text": "She swirls of into the next room"},
		{"speaker": IV, "text": "Saved by the bell, literally."}
	]),
	"start->inlaws->laugh": ConversationSegment.new("(Laugh it off)", [
		{"passed": "start->inlaws"},
	], [
		{S: "me", "text": "Of course not."},
		{S: "me", "text": "I've just been seeing your son/dauhter for so long."},
		{S: "me", "text": "It seemd like the right thing to call you."},
		{"text": "My father inlaw looks up from his newspaper."},
		{S: "father-in-law", "text": "I was under the impression that you two met just recently."},
		{"speaker": IV, "text": "You are?"},
		{"text": "I glance over at my BG/GF, "+
			"who is currently occupied avoiding eyecontat with exactly every sentient being in the known universe."},
		{"speaker": IV, "text": "What has he/sehe told them? Do I need to keep our sories traight for some good reason?"},
		{"text": "Suddenly. The kitchen timer rings."},
		{S: "mother-in-law", "text": "Well, that's my queue. We'll have to talk more about this later."},
		{"text": "She shifts gracefully in to the next room, wile keeping her eyes fixed on my fidgeting fiance."},
	]),
	"start->home": ConversationSegment.new("I've been so looking forward to seeing my BFs/GFs home.", [
		{"passed": "start"},
	], [
		{S: "me", "text": "I'm just so supprised by how lovely this home is!"},
		{S: "sister-in-law", "text": "\"Supprised\"?"},
		{S: IV, "text": "\"Amazed\", I ment to say \"Amazed\"!"},
		{S: "sister-in-law", "text": "Did you think we where poor? Living in some rough neighbourhood?"},
		{S: SO, "text": "Sis! That's not what he/she said!"},
		{S: "me", "text": "Um.. What I meant was.."},
	]),
	"start->home->rustic": ConversationSegment.new("..it's so rustic and charming", [
		{"passed": "start->home"},
	], [
		{"text": "My mother-in-law struggles to stay humble, whilst truly beaming with pride."},
		{S: "mother-in-law", "text": "Well, it might be an old place."},
		{S: "mother-in-law", "text": "Despit that I do think we've managed to creat a home filled with warmth."},
		{S: "father-in-law", "text": "Except when the boiler breaks or pipes jam."},
		{S: "father-in-law", "text": "Then it's a place cold filed with bills."},
		{S: "mother-in-law", "text": "Hmpf.. The house you wanted was.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{"text": "My mother-in-law marches out into the next room."},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),
	"start->home->modern": ConversationSegment.new("..it's so modern and practical", [
		{"passed": "start->home"},
	], [
		{"text": "My father-in-law pops pup from behind his newspaper, "
				+ "like someone called his name in a lotter raffel."},
		{S: "father-in-law", "text": "Yes, why it is, isn't it!?"},
		{S: "father-in-law", "text": "This house has all the latest modernities."},
		{S: "mother-in-law", "text": "Yet it it only had a fireplace.."},
		{S: "father-in-law", "text": "..which is expensive."},
		{S: "father-in-law", "text": "It's also a fire hassard that.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{"text": "My mother-in-law strides out into the next room."},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),

	# Separatpor + Dummy options (remove later)
	"---": ConversationSegment.new("--- --- --- --- --- ---", [	], [	]),

	"#1": ConversationSegment.new("First alternative from dictionary", [], [
		{"speaker": "father-in-law", "text": "Dialog text from dictionary #1"},
		{"text": "Narration dictionary #1"},
	]),
	"#1a": ConversationSegment.new("Another option (sometime after first)", [
		{"passed": "#1"}
	], [
		{"text": "Follow up on #1"},
	]),
	"#2": ConversationSegment.new("Second alternative from dictionary", [], [
		{"speaker": "mother-in-law", "text": "Dialog text from dictionary #2"},
		{"text": "Narration dictionary #2"},
	]),
	"#2a": ConversationSegment.new("Different option (sometime after second)", [
		{"passed": "#2"}
	], [
		{"text": "Follow up on #2"},
	]),
	"1+2=3": ConversationSegment.new("Conclusive option (after both 'originals')", [
		{"passed": ["#1", "#2"]},
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

	var speakers = {}
	for c in $dining_room_occupants.get_children():
		speakers[c.name] = c

	# Present narrative pannel
	_narrative_panel.clear();
	var segment:ConversationSegment = _potential_conversations[key]
	segment.present(speakers, _narrative_panel)
	_narrative_panel.visible = true

	# Record as passed conversation
	_passed_conversations.push_back(key)



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
				if key is String:
					return key in passed
				elif key is Array:
					for k in key:
						if not k in passed:
							return false
					return true
				else:
					printerr("Unrechognized type for 'passed':", typeof(key))

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

				_:
					printerr("Unablle to pressent", el)


func _on_rewind_btn_pressed():
	prints("<< Rewinding a by a single step")
	_passed_conversations.pop_back()
	self.populate_options()
