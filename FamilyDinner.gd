extends Node2D

const ConversationSegment = preload("res://Conversation.gd").ConversationSegment
const S = "speaker"
const SO = "significant_other"
const IV = "inner_voice"

var conversations_segments: Dictionary = {
	# Real intro
	"start": ConversationSegment.new("(Start the actuall story)", [
	], [
		{S: "mother-in-law",
		"text": "Welcome, dear!\n" +
				"It's such a joy you to finally get to meet you."},
	]),
	"start->inlaws": ConversationSegment.new("It's great to finally meet my inlaws", [
		{"follows": "start"},
	], [
		{S: "mother-in-law", "text": "\"Inlaws\"?!"},
		{"change_anexity": +1},
		{S: "mother-in-law",
			"text": "We're not old enough to be someones inlaws, right dearest?"},
		{	"text": "My new father-in-law mumbles something about [b]golf[/b] " +
					"and [b]boats[/b] from behind his newspaper."},
	]),
	"start->inlaws->apologize": ConversationSegment.new("(Apologize)", [
		{"follows": "start->inlaws"},
	], [
		{S: "me", "text": "Oh.. I didn't mean to imply.."},
		{S: SO, "text": "Mother. That's not what he/she said."},
		{S: "mother-in-law", "text": "Don't worry! I was just.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{S: "mother-in-law", "text": "..needed in the kitchen. Appartently."},
		{"text": "She swirls of into the next room"},
		{"change_anexity": -1},
		{"speaker": IV, "text": "Saved by the bell, literally."}
	]),
	"start->inlaws->laugh": ConversationSegment.new("(Laugh it off)", [
		{"follows": "start->inlaws"},
	], [
		{S: "me", "text": "Of course not."},
		{S: "me", "text": "I've just been seeing your son/dauhter for so long."},
		{S: "me", "text": "It seemd like the right thing to call you."},
		{"text": "My father inlaw looks up from his newspaper."},
		{S: "father-in-law", "text": "I was under the impression that you two met just recently."},
		{"speaker": IV, "text": "You where?"},
		{"text": "I glance over at my BG/GF, "+
			"who is currently occupied avoiding eyecontat with exactly every sentient being in the known universe."},
		{"speaker": IV, "text": "What has he/she told them? Do I need to keep our stories traight for some reason?"},
		{"text": "Suddenly. The kitchen timer rings."},
		{S: "mother-in-law", "text": "Well, that's my queue. We'll have to talk more about this later."},
		{"change_anexity": +2},
		{"text": "She shifts gracefully in to the next room, while keeping her eyes fixed on my fidgeting fiance."},
	]),
	"start->home": ConversationSegment.new("I've been so looking forward to seeing my BFs/GFs home.", [
		{"follows": "start"},
	], [
		{S: "me", "text": "I'm just so suprised by how lovely this home is!"},
		{S: "sister-in-law", "text": "\"Suprised\"?"},
		{S: IV, "text": "\"Amazed\", I ment to say \"Amazed\"!"},
		{S: "sister-in-law", "text": "Did you think we where poor? Living in some rough neighbourhood?"},
		{S: SO, "text": "Sis! That's not what he/she said!"},
		{S: "me", "text": "Um.. What I meant was.."},
	]),
	"start->home->rustic": ConversationSegment.new("..it's so rustic and charming", [
		{"follows": "start->home"},
	], [
		{"text": "My mother-in-law struggles to stay humble, whilst truly beaming with pride."},
		{S: "mother-in-law", "text": "Well, it might be an old place."},
		{S: "mother-in-law", "text": "Despite everything I do think we've managed to creat a cozy home filled with love."},
		{S: "father-in-law", "text": "Except when the boiler breaks or pipes jam."},
		{"text": "He turns the page for dramatic effect."},
		{S: "father-in-law", "text": "Then it's a cold home filled with bills."},
		{S: "mother-in-law", "text": "Hmpf.. The house you wanted on the other hand.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{"text": "My mother-in-law marches out into the next room."},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),
	"start->home->modern": ConversationSegment.new("..it's so modern and practical", [
		{"follows": "start->home"},
	], [
		{S: "father-in-law", "text": "Yes, why yes it is, isn't it!?"},
		{"text": "My father-in-law pops up from behind his newspaper,\n"
				+ "like someone called his name in a lottery raffel."},
		{S: "father-in-law", "text": "This house has all the latest modernities."},
		{S: "mother-in-law", "text": "Yet it it only had a fireplace.."},
		{S: "father-in-law", "text": "..which is an expensive thing."},
		{"text": "He dodges back behind his newspaper."},
		{S: "father-in-law", "text": "It's also a fire hassard that.."},
		{"text": "Suddenly. The kitchen timer rings."},
		{"text": "My mother-in-law strides out into the next room."},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),
	"change_the_subject": ConversationSegment.new("(Try to change the subject)", [
		{"follows": [
			"start->inlaws->apologize",
			"start->inlaws->laugh",
			"start->home->rustic",
			"start->home->modern",
			]},
	], [
		{S: "me", "text": "So.. *cough*"},
		{S: "me", "text": "What nice weather we've had so far this summer."},
	]),
}


# Populate options panel with some placeholders
func _ready():
	# Set gender expression of SO at random
	randomize()
	if randi() % 2 == 0:
		$dining_room/occupants/significant_other.speaker_portrait = load("res://people/so_f_port.png")
	else:
		$dining_room/occupants/significant_other.speaker_portrait = load("res://people/so_m_port.png")

	# Prep. conversation
	$conversation.segments_db = conversations_segments
	$conversation.present_segment("start")

func _on_options_option_selected(key):
	$conversation.present_segment(key)

func _on_narrative_pressentation_completed():
	$conversation.pressent_options()

func _on_narrative_anexity_changed(change):
	prints(self, " _on_narrative_anexity_changed", change)
	$ui/anexity_bar.target += change

func _on_rewind_btn_pressed():
	prints("<< Rewinding a by a single step")
	$conversation.rewind_one_step()
