/datum/hediff/healing
	name = "ubercharge"
	/// Amount to heal per process
	var/heal_amt = 0
	/// Amount this can heal in total
	var/heal_total = 0
	/// Damage types this will heal
	var/list/healtype = list(BRUTE)
	/// Amount of bleeding on parent limb this will reduce
	var/bleed_suppress = 0
	/// Amount of bleeding on parent limb this will remove per process
	var/bleed_staunch = 0
	/// TODO: handle this
	var/infection_mod = 0
	/// Surface level this is applied to (skin, surface, bandage)
	var/surface_level = 0
