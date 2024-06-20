/datum/hediff/damage
	name = "minor injury"
	/// How much damage does this hold? Applied to the limb it is attached to
	var/damage = 0
	/// Damage type this applies, used for health readouts and healing items
	var/damtype = BRUTE
	/// How much bleeding does this cause to its attached limb?
	var/bleeding = 0
	/// How much damage is applied as bleeding?
	var/bleed_coeff = 0
	/// How much damage does this need to contain to apply bleeding?
	var/bleed_min = 0
	/// Which healing factors are being applied to this wound?
	var/list/treatments = list()

/// Do things here after damage numbers are finalized
/datum/hediff/damage/proc/apply_damage()
	if(bleed_coeff)
		bleeding += damage * bleed_coeff

/datum/hediff/damage/end_effect()
	for(var/datum/treatment/T in treatments)
		T.end_effect()
	//to_chat(owner, span_nicegreen("\The [name] on your"))
	..()

/datum/hediff/damage/on_life()
	..()
	apply_treatments()

/// Gets the effective bleeding of this injury, minus the suppression of any treatments
/datum/hediff/damage/proc/get_effective_bleeding()
	. = bleeding
	if(!. || !LAZYLEN(treatments)) //don't need to bother
		return
	for(var/datum/treatment/stopit in treatments)
		. -= min(stopit.bleed_suppress, .)

/// Apply all our treatment effects
/datum/hediff/damage/proc/apply_treatments()
	if(!LAZYLEN(treatments))
		return
	var/heal_coeff = 1 //THEOTODO: vital
	for(var/datum/treatment/medicbag in treatments)
		damage -= min(medicbag.heal_speed * heal_coeff, damage)
		bleeding -= min(medicbag.bleed_staunch, bleeding)
	if(!damage)
		end_effect(src)

/datum/hediff/damage/proc/get_highest_treatment()
	if(!LAZYLEN(treatments))
		return
	var/datum/treatment/highestpoint = treatments[1]
	for(var/datum/treatment/inmaryland in treatments)
		if(highestpoint.surface_level < inmaryland)
			highestpoint = inmaryland

/datum/hediff/damage/brute
	name = "abrasions"
	plural = TRUE
	damtype = BRUTE
/datum/hediff/damage/brute/blunt
	name = "bruising"
	plural = TRUE
	bleed_coeff = 0.013
	bleed_min = 12
/datum/hediff/damage/brute/sharp
	name = "cut"
	bleed_coeff = 0.013
	bleed_min = 5
/datum/hediff/damage/brute/bullet
	name = "gunshot wound"
	bleed_coeff = 0.013
	bleed_min = 11 //prevents beanbags and rubbershot from causing bleeding
/datum/hediff/damage/burn
	name = "burns"
	plural = TRUE
	damtype = BURN
/datum/hediff/damage/burn/general
	name = "blister"
