/** Treatments are applied to damage hediffs to make them kill you less
 *  This is accomplished by reducing the damage and bleeding caused by said damage hediff over time
 */
/datum/treatment
	var/name = "ubercharge"
	var/plural = FALSE
	/// Amount to heal per process
	var/heal_speed = 0
	/// Amount of bleeding this will reduce
	var/bleed_suppress = 0
	/// Amount of bleeding this will remove per process
	var/bleed_staunch = 0
	/// Surface level this is applied to (wound, skin, wrapping).
	var/surface_level = HEDIFF_SURFACE_WOUND
	var/infection_mod = 1 //THEOTODO: HANDLE THIS

/// Kills the effect and returns a string of flavortext
/datum/treatment/proc/end_effect()
	. = "sample text"
	qdel(src)

/datum/treatment/gauze
	name = "gauze wrapping"
	bleed_suppress = 5
	bleed_staunch = 0.1
	surface_level = HEDIFF_SURFACE_WRAPPING
	infection_mod = 0.9

/datum/treatment/gauze/improv
	name = "improvised gauze wrapping"
	bleed_staunch = 0.01
	infection_mod = 1

/datum/treatment/cauterization
	name = "cauterization"
	plural = TRUE
	bleed_staunch = 0.01
	bleed_suppress = 2.5
	surface_level = HEDIFF_SURFACE_WOUND

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
