extends Node2D

const ConversationSegment = preload("res://Conversation.gd").ConversationSegment
const S = "speaker"
const SO = "significant_other"
const IV = "inner_voice"

var conversation_start = "start"
var conversation_end = "to_be_continued"
var conversations_segments: Dictionary = {
	# Real intro
	"start": ConversationSegment.new("(Start the actuall story)", [
	], [
		{"text": "We enter the dining room, where my mother-, father- and sister-in-law are all gathered."},
		{S: "mother-in-law",
		"text": "Welcome, dear!\n" +
				"It's such a joy you to finally get to meet you."},
		{"text": "My sister-in-law nods politely. " },
		{"text": "My father-in-law on the other hand seems to busy with his newspaper to take any notice of us."},
		{S: SO,
			"text": "You'll have to excuse him. He'll be with us in a few moments."},
		{"text": "I take a seat next tom my fiancé. As I do so, my feet bump into somthing large and hairy under the table." },
	]),
	"start->inlaws": ConversationSegment.new("It's great to finally meet my inlaws", [
		{"follows": "start"},
	], [
		{S: "mother-in-law", "text": "\"Inlaws\"?!"},
		{"change_anxiety": +1},
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
		{"text": "Suddenly, the kitchen timer rings."},
		{S: "mother-in-law", "text": "..needed in the kitchen. Apparently."},
		{"play_animation": "mil_exits"},
		{"text": "She swirls of into the next room"},
		{"change_anxiety": -1},
		{"speaker": IV, "text": "Saved by the bell, literally."}
	]),
	"start->inlaws->laugh": ConversationSegment.new("(Laugh it off)", [
		{"follows": "start->inlaws"},
	], [
		{S: "me", "text": "Of course not."},
		{S: "me", "text": "I've just been seeing your son/dauhter for so long."},
		{S: "me", "text": "It seemed like the right thing to call you."},
		{"text": "My father in law looks up from his newspaper."},
		{S: "father-in-law", "text": "I was under the impression that you two met just recently."},
		{"speaker": IV, "text": "You were?"},
		{"text": "I glance over at my BG/GF, "+
			"who is currently occupied avoiding eyecontat with exactly every sentient being in the known universe."},
		{"speaker": IV, "text": "What has he/she told them? Do I need to keep our stories straight for some reason?"},
		{"text": "Suddenly, the kitchen timer rings."},
		{S: "mother-in-law", "text": "Well, that's my queue. We'll have to talk more about this later."},
		{"play_animation": "mil_exits"},
		{"change_anxiety": +2},
		{"text": "She shifts gracefully in to the next room, while keeping her eyes fixed on my fidgeting fiance."},
	]),
	"start->home": ConversationSegment.new("I've been so looking forward to seeing my BFs/GFs home.", [
		{"follows": "start"},
	], [
		{S: "me", "text": "I'm just so suprised by how lovely this home is!"},
		{S: "sister-in-law", "text": "\"Suprised\"?"},
		{S: IV, "text": "\"Amazed\", I ment to say \"Amazed\"!"},
		{"change_anxiety": +1},
		{S: "sister-in-law", "text": "Did you think we where poor? Living in some rough neighbourhood?"},
		{S: SO, "text": "Sis! That's not what he/she said!"},
		{S: "me", "text": "Um.. What I meant was.."},
	]),
	"start->home->rustic": ConversationSegment.new("..it's so rustic and charming", [
		{"follows": "start->home"},
	], [
		{"text": "My mother-in-law struggles to stay humble, whilst truly beaming with pride."},
		{S: "mother-in-law", "text": "Well, it might be an old place."},
		{"change_favour_of": "mother-in-law", "by_amount": +1 },
		{S: "mother-in-law", "text": "Despite everything I do think we've managed to create a cozy home filled with love."},
		{S: "father-in-law", "text": "Except when the boiler breaks or pipes jam."},
		{"text": "He turns the page for dramatic effect."},
		{S: "father-in-law", "text": "Then it's a cold home filled with bills."},
		{"change_anxiety": +1},
		{S: "mother-in-law", "text": "Hmpf.. The house you wanted on the other hand.."},
		{"text": "Suddenly, the kitchen timer rings."},
		{"text": "My mother-in-law marches out into the next room."},
		{"play_animation": "mil_exits"},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),
	"start->home->modern": ConversationSegment.new("..it's so modern and practical", [
		{"follows": "start->home"},
	], [
		{S: "father-in-law", "text": "Yes, why yes it is, isn't it!?"},
		{"text": "My father-in-law pops up from behind his newspaper,\n"
				+ "like someone called his name in a lottery raffel."},
		{"change_favour_of": "father-in-law", "by_amount": +1 },
		{S: "father-in-law", "text": "This house has all the latest modernities."},
		{S: "mother-in-law", "text": "Yet if it only had a fireplace.."},
		{S: "father-in-law", "text": "..which is an expensive thing."},
		{"text": "He dodges back behind his newspaper."},
		{"change_anxiety": +1},
		{S: "father-in-law", "text": "It's also a fire hassard that.."},
		{"text": "Suddenly, the kitchen timer rings."},
		{"text": "My mother-in-law strides out into the next room."},
		{"play_animation": "mil_exits"},
		{S: IV, "text": "Ooookeeey... Touchy subject?"},
	]),

	# The family dog - A single use anxiety reliver
	"doggo?": ConversationSegment.new("(Check under the table)", [
		{"after": "start"},
	], [
		{	"text": "I take a quick peak."},
		{	"text": "A St. Bernard lays asleep right at my feet."},
		{S: IV, "text":"They have a dog! They have a dog! They have a dog! They have a dog! " +
			"They have a dog! They have a dog! They have a dog! They have a dog!"},
		{S: IV, "text":"My new inlaws have a D.O.G.!"},
	]),
	"pet-doggo!": ConversationSegment.new("(Pet dog)", [
		{"after": "doggo?"},
	], [
		{"text": "I reach down and stroke the long fur."},
		{"change_anxiety": -3},
		{"text": "The dog ruffs contently, then gets up and leaves."},
	]),

	# Climate change
	"warmer_climate": ConversationSegment.new("(Try to change the subject)", [
		{"after": "start"},
	], [
		{S: "me", "text":
			"So.. *cough*\n" +
			"What nice weather we've had so far this summer."},
		{S: "father-in-law", "text":
			"Why Yes, it's even better than last year isn't it."},
		{"text": "He flips a page."},
		{S: "father-in-law", "text":
			"Now if summer it going to get warmer and longer like this, " +
			"then I don't think anyone will mind some more of this 'climate change'."},
		{S: SO, "text":
			"Except almost every other species on the plannet."},
		{"text": "My father-in-law flips another page of his newspaper."},
		{S: "father-in-law", "text":
			"Then we can always build bigger Zoo. Who does not like the zoo?"},
		{S: "sister-in-law", "text":
			"Let's see.. Whales? Elephants? Most birds?"},
		{S: IV, "text":"Introverts? Agoraphobics?"},
		{"change_anxiety": +1},
	]),
	"warmer_climate->moderate_skepticism": ConversationSegment.new("Perhaps this was just a warm summer", [
		{"follows": "warmer_climate"},
	], [
		{S: "me", "text":
			"We can't know for certain that the warm [u]this[/u] was caused by climate change, but.."},
		{"text": "A voice from the other room interupts."},
		{S: "mother-in-law", "text":
			"Middle child! I need some help in the kitchen."},
		{S: "sister-in-law", "text":
			"Are you saying climate change isn't real?"},
		{"change_favour_of": "sister-in-law", "by_amount": -1 },
		{S: SO, "text":
			"Mother. I'm in the middle of a discussion!?\n(And I have a name)"},
		{S: "me", "text":
			"I'm not saying it isn't real. I just ment that.."},
		{"text": "Kitchen voice again."},
		{S: "mother-in-law", "text":
			"And I'm in the middle of making lasagna.\nNow get in here and help me out!"},
		{"text": "My fiancé sighs, then gets up."},
		{S: IV, "text":
			"Don't run away righ after you dragged me in to this."},
		{"play_animation": "so_exits"},
		{S: SO, "text":
			"I'll be right back. Promise."},
		{S: IV, "text":
			"Q~Q..."},
	]),
	"warmer_climate->wildlife_sanctuaries": ConversationSegment.new("Wildlife sanctuaries need to expand", [
		{"follows": "warmer_climate"},
	], [
		{S: "me", "text":
			"Just making every Zoo larger might not be ideal.\n" +
			"Wildlife sanctuaries on the other hand might.."},
		{"text": "A voice from the other room interupts."},
		{S: "mother-in-law", "text":
			"Middle child! I need some help in the kitchen."},
		{S: "father-in-law", "text":
			"And who's land will be confiscated to build those?"},
		{"change_favour_of": "father-in-law", "by_amount": -1 },
		{S: SO, "text":
			"Mother. I'm in the middle of a discussion!?\n(And I have a name)"},
		{S: "me", "text":
			"It'll have to be a gradual process. Land owners must of course be compen.. "},
		{"text": "Kitchen voice again."},
		{S: "mother-in-law", "text":
			"And I'm in the middle of making lasagna.\nNow get in here and help me out!"},
		{"text": "My fiancé sighs, then gets up."},
		{S: IV, "text":
			"Don't run away righ after you dragged me in to this."},
		{"play_animation": "so_exits"},
		{S: SO, "text":
			"I'll be right back. Promise."},
		{S: IV, "text":
			"Q~Q..."},
	]),
	"warmer_climate->moving_along": ConversationSegment.new("(Try to change the subject again)", [
		{"follows": [
			"warmer_climate->moderate_skepticism",
			"warmer_climate->wildlife_sanctuaries",
			"warmer_climate->jobbs_and_welfare",
			"warmer_climate->inhabitable_planet",
			]}
	], [
		{S: "me", "text":
			"Perhaps we should find something more pleasant to talk about."},
		{S: "sister-in-law", "text":
			"*sigh*\n" +
			"That's probaly for the best.\n" +
			"As you can probably tell we've had this conversation a few (too many) times."
			},
		{S: "father-in-law", "text":
			"On that we can agree.\n" +
			"Let's change the topic to something of greater interest."
			},
		{"text":
			"He folds up his newspaper and places it next to him. " +
			"Adjusting his glasses, he leans forward and asks.."},
		{S: "father-in-law", "text":
			"Now. Tell us.\n" +
			"Who might you be?"
			},
	]),

	# To be continued...
	"to_be_continued": ConversationSegment.new("(To be continued..)", [
		{"follows": [
			"warmer_climate->moving_along",
			]}
	], [
		{"text": "Thank you for playing through this short pilot."},
		{"text": "(That's it for now. Have a nice day.)"},
	]),
}

# Track anxiety
export(float, 0, 5) var anxiety = 0 setget set_anxiety
func set_anxiety(value: float):
	anxiety = clamp(value, 0, 5)
	if $ui/anxiety_bar:
		$ui/anxiety_bar.target = anxiety

var _blackout: bool = false

# Populate options panel with some placeholders
func _ready():
	$ui/anxiety_bar.target = anxiety

	# Configute SO appearence
	var so_ge = settings.so_gender_expression
	if so_ge == "grl":
		$dining_room/occupants/significant_other.speaker_portrait = load("res://people/so_f_port.png")
		$dining_room/occupants/significant_other.texture = load("res://people/so_f_sitting_in_dining_room.png")
	else: #(if so_ge == "boi")
		$dining_room/occupants/significant_other.speaker_portrait = load("res://people/so_m_port.png")
		$dining_room/occupants/significant_other.texture = load("res://people/so_m_sitting_in_dining_room.png")

	# Prep. conversation
	$conversation.segments_db = conversations_segments

	# Fade in
	$main_animation_player.play("fade_in")


func _on_options_option_selected(key):
	$conversation.present_segment(key)

func _on_narrative_pressentation_completed():
	if _blackout:
		$main_animation_player.play("blackout_anim")
	elif $conversation.get_last_segment() == conversation_end:
		$main_animation_player.play("ending_fade_out")
	else:
		$conversation.pressent_options()

func _on_narrative_anxiety_changed(change):
	prints(self, " _on_narrative_anxiety_changed", change)

	if self.anxiety >= 5 and change >0:
		_blackout = true
	else:
		self.anxiety += change

func _on_narrative_favour_changed(person, change):
	# TODO: Display and use 'favour' in some way
	prints("Favour changed for ", person, "by", change)


func _on_narrative_animation_requested(animation_id):
	if $main_animation_player.has_animation(animation_id):
		$main_animation_player.play(animation_id)
	else:
		printerr("Unknown animation:", animation_id)


func _on_main_animation_player_animation_finished(anim_name):
	prints(self, "_on_blackout_animation_player_animation_finished", anim_name)
	if anim_name == "fade_in":
		$conversation.present_segment(conversation_start)
	elif anim_name == "ending_fade_out":
		$popups_layer/ending_popup.popup()
	elif anim_name == "blackout_anim":
		$popups_layer/blackout_popup.popup()
	else:
		printerr("Unknown animation:", anim_name)

func _on_try_again_btn_pressed():
	self.get_tree().reload_current_scene()

func _on_rewind_btn_pressed():
	prints("<< Rewinding a by a single step")
	$conversation.rewind_one_step()
