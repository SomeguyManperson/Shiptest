/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD,FAN_HUD)
	hud_type = /datum/hud/human
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	can_be_shoved_into = TRUE
	//Hair colour and style
	var/hair_color = "000"
	var/hairstyle = "Bald"

	///Colour used for the hair gradient.
	var/grad_color = "000"
	///Style used for the hair gradient.
	var/grad_style

	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hairstyle = "Shaved"

	//Eye colour
	var/eye_color = "000"
	var/sclera_color = "ebeae8"

	var/skin_tone = "caucasian1"	//Skin tone

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30		//Player's age

	var/underwear = "Nude"				//Which underwear the player wants
	var/underwear_color = "000"			//underwear color, what it sounds like
	var/undershirt = "Nude" 			//Which undershirt the player wants
	var/undershirt_color = "000"		//undershirt color
	var/socks = "Nude"					//Which socks the player wants
	var/socks_color = "000"				//socks color, who could guess
	var/backpack = DBACKPACK			//Which backpack type the player has chosen.
	var/jumpsuit_style = PREF_SUIT		//suit/skirt
	var/exowear = PREF_EXOWEAR			//exowear

	///Whether this human started with a full-body prosthesis
	var/fbp = FALSE

	//Equipment slots
	var/obj/item/clothing/wear_suit = null
	var/obj/item/clothing/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	/// Adjective used in get_generic_name(), if any
	var/generic_adjective

	///For stopping bloodloss
	var/bleedsuppress = 0

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/slime, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
	var/last_fire_update
	var/account_id

	/// How many "units of blood" we have on our hands
	var/blood_in_hands = 0
	///blood particle effect
	var/obj/effect/abstract/particle_holder/blood_particle

	COOLDOWN_DECLARE(bloodloss_message)
