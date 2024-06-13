/* Health differentials
** Applied to limbs, these store damage and handle related effects
** Such as bleeding and infections.
*/

/datum/hediff
	/// Used for health readouts
	var/name = "lycanthropy"
	/// Used for grammar in health readouts, if the name is plural or not
	var/plural = FALSE
	/// Hide this from readouts?
	var/hidden = FALSE
	/// TODO: handle this
	var/infection_mod = 0

/// Behavior when we get pulsed by our holding limb
/datum/hediff/proc/on_life()

/// BOY I SURE HOPE NOTHING BAD HAPPENS
/datum/hediff/proc/take_damage(damage, damtype)

/// Obliterates the hediff and handles any required behavior. violent = use violent flavortext
/datum/hediff/proc/end_effect(violent = FALSE)
	qdel(src)
