///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH

	var/basic_mob_flags = NONE

	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
	var/attacked_sound = "punch" //This should be an element

	///What kind of objects this mob can smash.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/datum/armor/armor

	///Verbs used for speaking e.g. "Says" or "Chitters". This can be elementized
	var/list/speak_emote = list()

	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"

	///Basic mob's own attacks verbs,
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"

	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null
	///Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.
	var/flip_on_death = FALSE

	///Sentience type, for slime potions. SHOULD BE AN ELEMENT BUT I DONT CARE ABOUT IT FOR NOW
	var/sentience_type = SENTIENCE_ORGANIC

	///Leaving something at 0 means it's off - has no maximum.
	var/list/habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	///This damage is taken when atmos doesn't fit all the requirements above. Set to 0 to avoid adding the atmos_requirements element.
	var/unsuitable_atmos_damage = 1

	///Minimal body temperature without receiving damage
	var/minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP
	///Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP
	///This damage is taken when the body temp is too cold. Set both this and unsuitable_heat_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_cold_damage = 1
	///This damage is taken when the body temp is too hot. Set both this and unsuitable_cold_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_heat_damage = 1

	///conneceted nest datum, used to talk to the monster's 'nest'/spawner
	var/datum/component/spawner/nest

/mob/living/basic/Initialize(mapload)
	. = ..()
	if (islist(armor))
		armor = getArmor(arglist(armor))
	else if (!armor)
		armor = getArmor()
	else if (!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during [src.type] Initialize()")

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	update_basic_mob_varspeed()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

	apply_atmos_requirements(mapload)
	apply_temperature_requirements(mapload)

/// Ensures this mob can take atmospheric damage if it's supposed to
/mob/living/basic/proc/apply_atmos_requirements(mapload)
	if(unsuitable_atmos_damage == 0 || isnull(habitable_atmos))
		return
	//String assoc list returns a cached list, so this is like a static list to pass into the element below.
	habitable_atmos = string_assoc_list(habitable_atmos)
	AddElement(/datum/element/atmos_requirements, habitable_atmos, unsuitable_atmos_damage, mapload)

/// Ensures this mob can take temperature damage if it's supposed to
/mob/living/basic/proc/apply_temperature_requirements(mapload)
	if((unsuitable_cold_damage == 0 && unsuitable_heat_damage == 0) || (minimum_survivable_temperature <= 0 && maximum_survivable_temperature >= INFINITY))
		return
	AddElement(/datum/element/basic_body_temp_sensetive, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage, mapload)

/mob/living/basic/getarmor(def_zone, type)
	if(armor)
		return armor.getRating(type)
	return FALSE

/mob/living/basic/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	///Automatic stamina re-gain
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * seconds_per_tick, FALSE, TRUE)

/mob/living/basic/say_mod(input, datum/language/message_language, list/message_mods = list())
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()

/mob/living/basic/death(gibbed)
	. = ..()
	if(nest)
		if(QDELETED(nest))
			nest = null
		else
			nest.spawned_mobs -= src
			nest = null
	if(basic_mob_flags & DEL_ON_DEATH)
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		if(flip_on_death)
			transform = transform.Turn(180)
		density = 0

/mob/living/basic/proc/melee_attack(atom/target)
	src.face_atom(target)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_basic_mob(src)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/set_varspeed(var_value)
	speed = var_value
	update_basic_mob_varspeed()

/mob/living/basic/proc/update_basic_mob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/basicmob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/basicmob_varspeed, multiplicative_slowdown = speed)
	SEND_SIGNAL(src, POST_BASIC_MOB_UPDATE_VARSPEED)
