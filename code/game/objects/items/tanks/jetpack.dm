/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = GAS_O2
	var/on = FALSE
	var/stabilizers = FALSE
	var/full_speed = TRUE // Whether damage slowdown will affect the jetpack
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/tank/jetpack/Initialize()
	. = ..()
	ion_trail = new
	ion_trail.auto_process = FALSE
	ion_trail.set_up(src)

/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		air_contents.set_moles(gas_type, ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))

/obj/item/tank/jetpack/ui_action_click(mob/living/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			stabilizers = !stabilizers
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilizers ? "on" : "off"]."))
	else
		toggle_internals(user)


/obj/item/tank/jetpack/proc/cycle(mob/living/user)
	if(user.incapacitated())
		return

	if(!on)
		turn_on(user)
		to_chat(user, span_notice("You turn the jetpack on."))
	else
		turn_off(user)
		to_chat(user, span_notice("You turn the jetpack off."))
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/tank/jetpack/proc/turn_on(mob/living/user)
	if(!allow_thrust(0.01, user))
		return
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	ion_trail.start()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_react))
	if(full_speed)
		user.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown_flying)

/obj/item/tank/jetpack/proc/turn_off(mob/living/user)
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	ion_trail.stop()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)
	user.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown_flying)

/obj/item/tank/jetpack/proc/move_react(mob/living/user)
	if(!on)//If jet dont work, it dont work
		return
	if(!user)//Don't allow jet self using
		return
	if(!isturf(user.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(user.is_flying() || user.is_floating()) || user.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(user.pulledby)//You don't must use jet if someone pull you
		return
	if(user.throwing)//You don't must use jet if you thrown
		return
	if(length(user.client.keys_held & user.client.movement_keys))//You use jet when press keys. yes.
		allow_thrust(0.01, user)

/obj/item/tank/jetpack/proc/pre_move_react(mob/living/user)
	ion_trail.oldposition = get_turf(src)

/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user)
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return

	assume_air_moles(air_contents, num)

	return TRUE


/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	item_state = "jetpack-sec"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE // affected by damage slowdown

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user)
	if(rand(0,250) == 0)
		to_chat(user, span_notice("You feel your jetpack's engines cut out."))
		turn_off(user)
		return
	..()

	assume_air_moles(air_contents, num)

	return TRUE

/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"



/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = GAS_CO2


/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon = 'icons/obj/items.dmi'
	icon_state = "jetpack_upgrade"
	item_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	custom_price = 2000
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/cur_user

/obj/item/tank/jetpack/suit/Initialize()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, span_warning("\The [src] must be connected to a hardsuit!"))
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank/internals))
		to_chat(user, span_warning("You need a tank in your suit storage!"))
		return
	..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return
	var/mob/living/carbon/human/H = user
	tank = H.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	cur_user = user
	..()

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	cur_user = null
	..()

/obj/item/tank/jetpack/suit/process(seconds_per_tick)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		turn_off(cur_user)
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(cur_user)
		return
	..()


//Return a jetpack that the mob can use
//Back worn jetpacks, hardsuit internal packs, and so on.
//Used in Process_Spacemove() and wherever you want to check for/get a jetpack

/mob/proc/get_jetpack()
	return

/mob/living/carbon/get_jetpack()
	var/obj/item/tank/jetpack/J = back
	if(istype(J))
		return J

/mob/living/carbon/human/get_jetpack()
	var/obj/item/tank/jetpack/J = ..()
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	return J
