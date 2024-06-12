/* Health differentials
** Applied to limbs, these store damage and handle related effects
** Such as bleeding and infections.
*/

/datum/hediff
	/// Used for health readouts
	var/name = "lycanthropy"
	/// Used for grammar in health readouts, if the name is plural or not
	var/plural = FALSE
	/// Hide this from health scanners y/n
	var/hidden = FALSE
	/// TODO: handle this
	var/infection_chance = 0
