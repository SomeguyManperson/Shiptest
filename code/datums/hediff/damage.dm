/datum/hediff/damage
	name = "minor injury"
	/// How much damage does this hold? Applied to the limb it is attached to
	var/damage = 0
	/// Damage type this applies, used to handle healing and etc if necessary
	var/damtype = BRUTE


/*datum/hediff/damage/Initialize(_damage, name_override)
	damage = _damage
	if(name_override)
		name = name_override*/

/datum/hediff/damage/brute
	name = "abrasions"
	damtype = BRUTE
/datum/hediff/damage/brute/blunt
	name = "bruising"
/datum/hediff/damage/brute/sharp
	name = "cuts"
/datum/hediff/damage/burn
	name = "burns"
	damtype = BURN
/datum/hediff/damage/burn/laser
	name = "blisters"
