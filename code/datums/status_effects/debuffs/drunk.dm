/// The threshld which determine if someone is tipsy vs drunk
#define TIPSY_THRESHOLD 6

/**
 * The drunk status effect.
 * Slowly decreases in drunk_value over time, causing effects based on that value.
 */
/datum/status_effect/inebriated
	id = "drunk"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	remove_on_fullheal = TRUE
	/// The level of drunkness we are currently at.
	var/drunk_value = 0

/datum/status_effect/inebriated/on_creation(mob/living/new_owner, drunk_value = 0)
	. = ..()
	set_drunk_value(drunk_value)

/datum/status_effect/inebriated/get_examine_text()
	// Dead people don't look drunk
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return null

	// Having your face covered conceals your drunkness
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		if(carbon_owner.wear_mask?.flags_inv & HIDEFACE)
			return null
		if(carbon_owner.head?.flags_inv & HIDEFACE)
			return null

	// .01s are used in case the drunk value ends up to be a small decimal.
	switch(drunk_value)
		if(11 to 21)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] slightly flushed.")
		if(21.01 to 41)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] flushed.")
		if(41.01 to 51)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] quite flushed and [owner.p_their()] breath smells of alcohol.")
		if(51.01 to 61)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] very flushed and [owner.p_their()] movements jerky, with breath reeking of alcohol.")
		if(61.01 to 91)
			return span_warning("[owner.p_they(TRUE)] look[owner.p_s()] like a drunken mess.")
		if(91.01 to INFINITY)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] a shitfaced, slobbering wreck.")

	return null

/// Sets the drunk value to set_to, deleting if the value drops to 0 or lower
/datum/status_effect/inebriated/proc/set_drunk_value(set_to)
	if(!isnum(set_to))
		CRASH("[type] - invalid value passed to set_drunk_value. (Got: [set_to])")

	drunk_value = set_to
	if(drunk_value <= 0)
		qdel(src)

/datum/status_effect/inebriated/tick()
	// Drunk value does not decrease while dead
	if(owner.stat == DEAD)
		return

	// Every tick, the drunk value decrases by
	// 4% the current drunk_value + 0.01
	// (until it reaches 0 and terminates)
	set_drunk_value(drunk_value - (0.01 + drunk_value * 0.04))
	if(QDELETED(src))
		return

	on_tick_effects()

/// Side effects done by this level of drunkness on tick.
/datum/status_effect/inebriated/proc/on_tick_effects()
	return

/**
 * Stage 1 of drunk, applied at drunk values between 0 and 6.
 * Basically is the "drunk but no side effects" stage.
 */
/datum/status_effect/inebriated/tipsy
	alert_type = null

/datum/status_effect/inebriated/tipsy/set_drunk_value(set_to)
	. = ..()
	if(QDELETED(src))
		return

	// Become fully drunk at over than 6 drunk value
	if(drunk_value >= TIPSY_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/inebriated/drunk, drunk_value)

/**
 * Stage 2 of being drunk, applied at drunk values between 6 and onward.
 * Has all the main side effects of being drunk, scaling up as they get more drunk.
 */
/datum/status_effect/inebriated/drunk
	alert_type = /atom/movable/screen/alert/status_effect/drunk

/datum/status_effect/inebriated/drunk/on_apply()
	. = ..()
	owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/drunk)

/datum/status_effect/inebriated/drunk/on_remove()
	clear_effects()
	return ..()

// Going from "drunk" to "tipsy" should remove effects like on_remove
/datum/status_effect/inebriated/drunk/be_replaced()
	clear_effects()
	return ..()

/// Clears any side effects we set due to being drunk.
/datum/status_effect/inebriated/drunk/proc/clear_effects()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)

	if(owner.sound_environment_override == SOUND_ENVIRONMENT_PSYCHOTIC)
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/datum/status_effect/inebriated/drunk/set_drunk_value(set_to)
	. = ..()
	if(QDELETED(src))
		return

	// Return to "tipsyness" when we're below 6.
	if(drunk_value < TIPSY_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/inebriated/tipsy, drunk_value)

/datum/status_effect/inebriated/drunk/on_tick_effects()
	// Drunk people will always lose jitteriness
	owner.adjust_timed_status_effect(-6 SECONDS, /datum/status_effect/jitter)

	// Over 31, we will constantly gain slurring up to 10 seconds of slurring.
	if(drunk_value >= 31)
		owner.adjust_timed_status_effect(2.4 SECONDS, /datum/status_effect/speech/slurring/drunk, max_duration = 10 SECONDS)

	// Over 41, we have a 30% chance to gain confusion, and we will always have 20 seconds of dizziness.
	if(drunk_value >= 41)
		if(prob(30))
			owner.confused += 1
		owner.set_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

	// Over 51, we have a 3% chance to gain a lot of confusion and vomit, and we will always have 50 seconds of dizziness
	if(drunk_value >= 51)
		owner.set_timed_status_effect(50 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

	//if our drunkenness is over 61 and we have alcohol tolerance, or over 51 and we *dont*, and also prob(3)
	if(drunk_value >= (HAS_TRAIT(owner,TRAIT_ALCOHOL_TOLERANCE) ? 51 : 61) && prob(3))
		owner.confused += 7
		if(iscarbon(owner))
			var/mob/living/carbon/carbon_owner = owner
			carbon_owner.vomit() // Vomiting clears toxloss - consider this a blessing

	// Over 71, we will constantly have blurry eyes
	if(drunk_value >= 71)
		owner.blur_eyes(5)

	// Over 81, we will gain constant toxloss
	if(drunk_value >= 81)
		owner.adjustToxLoss(1)
		if(owner.stat == CONSCIOUS && prob(5))
			to_chat(owner, span_warning("Maybe you should lie down for a bit..."))

	// Over 91, we gain even more toxloss, brain damage, and have a chance of dropping into a long sleep
	if(drunk_value >= 91)
		owner.adjustToxLoss(1)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4)
		if(owner.stat == CONSCIOUS && prob(20))
			to_chat(owner, span_warning("Just a quick nap..."))
			owner.Sleeping(90 SECONDS)

	// And finally, over 100 - let's be honest, you shouldn't be alive by now.
	if(drunk_value >= 101)
		owner.adjustToxLoss(2)

/// Status effect for being fully drunk (not tipsy).
/atom/movable/screen/alert/status_effect/drunk
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, \
		motor skills, and mental cognition. Make sure to act like it."
	icon_state = "drunk"

#undef TIPSY_THRESHOLD
