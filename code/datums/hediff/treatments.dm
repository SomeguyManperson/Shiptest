/datum/treatment
	var/name = "ubercharge"
	var/plural = FALSE
	/// Amount to heal per process
	var/heal_speed = 0
	/// Amount of bleeding this will reduce
	var/bleed_suppress = 0
	/// Amount of bleeding this will remove per process
	var/bleed_staunch = 0
	/// Surface level this is applied to (skin, surface, bandage). Higher level treatments obscure and obstruct application or damage of lower level ones
	var/surface_level = HEDIFF_SURFACE_WOUND
	var/infection_mod = 1

/datum/treatment/proc/take_damage(damage, damtype)
	if(prob(damage * 5)) //tragedy strikes
		end_effect(TRUE)

/datum/treatment/proc/end_effect(violent = FALSE)

/datum/treatment/gauze
	name = "gauze wrapping"
	plural = TRUE
	bleed_suppress = 5
	bleed_staunch = 0.1
	surface_level = HEDIFF_SURFACE_WRAPPING
	infection_mod = 0.9
	/// How much damage we can take
	var/integrity = 30

/datum/treatment/gauze/take_damage(damage, damtype) //gauze protects treatments underneath it, and can withstand incoming attacks more reliably
	integrity -= damage
	if(integrity <= 0)
		end_effect(TRUE)

/datum/treatment/gauze/improv
	name = "improvised gauze wrapping"
	bleed_staunch = 0.01
	infection_mod = 1
	integrity = 15

/datum/treatment/suture
	name = "suturing"
	plural = TRUE
	heal_speed = 1
	bleed_suppress = 10
	bleed_staunch = 0.1
	surface_level = HEDIFF_SURFACE_WOUND

/datum/treatment/suture/medicated
	name = "medicated suturing"
	heal_speed = 2
	infection_mod = 0.8

/datum/treatment/pack
	name = "bruise gel"
	plural = TRUE
	heal_speed = 1.5
	surface_level = HEDIFF_SURFACE_SKIN

/datum/treatment/pack/herb
	name = "herbal poultice"

/datum/treatment/mesh
	name = "regenerative mesh"
	plural = TRUE
	heal_speed = 1
	infection_mod = 0.8
	surface_level = HEDIFF_SURFACE_WOUND

/datum/treatment/mesh/adv
	name = "aloe-treated mesh"
	heal_speed = 2
	infection_mod = 0.4

/datum/treatment/ointment
	name = "ointment"
	plural = TRUE
	heal_speed = 1.5
	surface_level = HEDIFF_SURFACE_SKIN

/datum/treatment/ointment/herb
	name = "herbal salve"
