/datum/hediff/damage
	name = "minor injury"
	/// How much damage does this hold? Applied to the limb it is attached to
	var/damage = 0
	/// Damage type this applies
	var/damtype = BRUTE
	/// How much bleeding does this cause to its attached limb?
	var/bleeding = 0
	/// How much damage is applied as bleeding?
	var/bleed_coeff = 0
	/// Which healing factors are being applied to this wound?
	var/list/treatments = list(HEDIFF_SURFACE_WRAPPING = null, HEDIFF_SURFACE_SKIN = null, HEDIFF_SURFACE_WOUND = null)


/datum/hediff/damage/New(_damage, name_override)
	damage = _damage
	if(name_override)
		name = name_override
	if(bleed_coeff)
		bleeding += damage * bleed_coeff

/datum/hediff/damage/brute
	name = "abrasions"
	damtype = BRUTE
/datum/hediff/damage/brute/blunt
	name = "bruising"
/datum/hediff/damage/brute/sharp
	name = "cuts"
	bleed_coeff = 0.013
/datum/hediff/damage/burn
	name = "burns"
	damtype = BURN
/datum/hediff/damage/burn/laser
	name = "blisters"
