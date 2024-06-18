/* Health differentials
** Applied to limbs, these store damage and handle related effects
** Such as bleeding and infections.
*/

/datum/hediff
	/// Used for health readouts
	var/name = "lycanthropy"
	/// Used for grammar in health readouts, if the name is plural or not
	var/plural = FALSE
	///// Hide this from readouts?
	//var/hidden = FALSE
	/// THEOTODO: handle this
	var/infection_mod = 0

/// Behavior when we get pulsed by our holding limb
/datum/hediff/proc/on_life()

/// Obliterates the hediff and handles any required behavior.
/datum/hediff/proc/end_effect()
	qdel(src)
