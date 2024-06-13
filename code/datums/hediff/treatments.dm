/datum/treatment/healing
	name = "ubercharge"
	hidden = TRUE //snowflake. snowflake. snowflake.
	/// Amount to heal per process
	var/heal_speed = 0
	/// Amount of bleeding this will reduce
	var/bleed_suppress = 0
	/// Amount of bleeding this will remove per process
	var/bleed_staunch = 0
	/// Surface level this is applied to (skin, surface, bandage). Higher level treatments obscure and obstruct application or damage of lower level ones
	var/surface_level = HEDIFF_SURFACE_WOUND

/datum/treatment/healing/take_damage(damage, damtype)
	if(prob(damage * 5)) //tragedy strikes
		end_effect(TRUE)

/datum/treatment/healing/gauze
	name = "gauze wrapping"
	plural = TRUE
	bleed_suppress = 5
	bleed_staunch = 0.1
	surface_level = HEDIFF_SURFACE_WRAPPING
	infection_mod = 0.9
	/// How much damage we can take
	var/integrity = 30

/datum/treatment/healing/gauze/take_damage(damage, damtype) //gauze protects treatments underneath it, and can withstand incoming attacks more reliably
	integrity -= damage
	if(integrity <= 0)
		end_effect(TRUE)

/datum/treatment/healing/gauze/improv
	name = "improvised gauze wrapping"
	bleed_staunch = 0.01
	infection_mod = 1
	integrity = 15

/datum/treatment/healing/suture
	name = "suturing"
	plural = TRUE
	heal_speed = 1
	bleed_suppress = 10
	bleed_staunch = 0.1
	surface_level = HEDIFF_SURFACE_WOUND

/datum/treatment/healing/suture/medicated
	name = "medicated suturing"
	heal_speed = 2
	infection_mod = 0.8

/datum/treatment/healing/pack
	name = "bruise gel"
	plural = TRUE
	heal_speed = 1.5
	surface_level = HEDIFF_SURFACE_SKIN

/datum/treatment/healing/pack/herb
	name = "herbal poultice"

/datum/treatment/healing/mesh
	name = "regenerative mesh"
	plural = TRUE
	heal_speed = 1
	infection_mod = 0.8
	surface_level = HEDIFF_SURFACE_WOUND

/datum/treatment/healing/mesh/adv
	name = "aloe-treated mesh"
	heal_speed = 2
	infection_mod = 0.4

/datum/treatment/healing/ointment
	name = "ointment"
	plural = TRUE
	heal_speed = 1.5
	surface_level = HEDIFF_SURFACE_SKIN

/datum/treatment/healing/ointment/herb
	name = "herbal salve"
