/obj/machinery/power/emitter
	name = "emitter"
	desc = "A heavy-duty industrial laser, often used in containment fields and power generation."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	base_icon_state = "emitter"

	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	circuit = /obj/item/circuitboard/machine/emitter

	use_power = NO_POWER_USE
	idle_power_usage = IDLE_DRAW_MINIMAL
	active_power_usage = ACTIVE_DRAW_LOW

	var/icon_state_on = "emitter_+a"
	var/icon_state_underpowered = "emitter_+u"
	var/active = FALSE
	var/powered = FALSE
	var/fire_delay = 100
	var/maximum_fire_delay = 100 //10 seconds
	var/minimum_fire_delay = 20 // 2 seconds
	var/last_shot = 0
	var/shot_number = 0
	var/welded = FALSE ///if it's welded down to the ground or not. the emitter will not fire while unwelded. if set to true, the emitter will start anchored as well.
	var/locked = FALSE
	var/allow_switch_interact = TRUE

	var/projectile_type = /obj/projectile/beam/emitter/hitscan //WS - Hitscan emitters
	var/projectile_sound = 'sound/weapons/gun/laser/heavy_laser.ogg'
	var/datum/effect_system/spark_spread/sparks

	var/obj/item/gun/energy/gun
	var/list/gun_properties
	var/mode = 0

	// The following 3 vars are mostly for the prototype
	var/manual = FALSE
	var/charge = 0
	var/last_projectile_params


/obj/machinery/power/emitter/Initialize()
	. = ..()
	RefreshParts()
	wires = new /datum/wires/emitter(src)
	if(welded)
		if(!anchored)
			set_anchored(TRUE)
		connect_to_network()

	sparks = new
	sparks.attach(src)
	sparks.set_up(5, TRUE, src)

/obj/machinery/power/emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)

/obj/machinery/power/emitter/set_anchored(anchorvalue)
	. = ..()
	if(!anchored && welded) //make sure they're keep in sync in case it was forcibly unanchored by badmins or by a megafauna.
		welded = FALSE

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = ACTIVE_DRAW_LOW
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

/obj/machinery/power/emitter/examine(mob/user)
	. = ..()
	if(welded)
		. += span_info("It's moored firmly to the floor. You can unsecure its moorings with a <b>welder</b>.")
	else if(anchored)
		. += span_info("It's currently anchored to the floor. You can secure its moorings with a <b>welder</b>, or remove it with a <b>wrench</b>.")
	else
		. += span_info("It's not anchored to the floor. You can secure it in place with a <b>wrench</b>.")

	if(in_range(user, src) || isobserver(user))
		if(!active)
			. += span_notice("Its status display is currently turned off.")
		else if(!powered)
			. += span_notice("Its status display is glowing faintly.")
		else
			. += span_notice("Its status display reads: Emitting one beam every <b>[DisplayTimeText(fire_delay)]</b>.")
			. += span_notice("Power consumption at <b>[DisplayPower(active_power_usage)]</b>.")

/obj/machinery/power/emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, PROC_REF(can_be_rotated)))

/obj/machinery/power/emitter/proc/can_be_rotated(mob/user,rotation_type)
	if (anchored)
		to_chat(user, span_warning("It is fastened to the floor!"))
		return FALSE
	return TRUE

/*WS Edit - Smartwire Revert
/obj/machinery/power/emitter/should_have_node()
	return welded
*/

/obj/machinery/power/emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("Emitter deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("Emitter deleted at [AREACOORD(T)]")
		investigate_log("<font color='red'>deleted</font> at [AREACOORD(T)]", INVESTIGATE_SINGULO)
	QDEL_NULL(sparks)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/emitter/update_icon_state()
	if(!active || !powernet)
		icon_state = base_icon_state
		return ..()
	icon_state = avail(active_power_usage) ? icon_state_on : icon_state_underpowered
	return ..()

/obj/machinery/power/emitter/interact(mob/user)
	add_fingerprint(user)
	if(welded)
		if(!powernet)
			to_chat(user, span_warning("\The [src] isn't connected to a wire!"))
			return TRUE
		if(!locked && allow_switch_interact)
			if(active == TRUE)
				active = FALSE
				to_chat(user, span_notice("You turn off [src]."))
			else
				active = TRUE
				to_chat(user, span_notice("You turn on [src]."))
				shot_number = 0
				fire_delay = maximum_fire_delay

			message_admins("Emitter turned [active ? "ON" : "OFF"] by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
			log_game("Emitter turned [active ? "ON" : "OFF"] by [key_name(user)] in [AREACOORD(src)]")
			investigate_log("turned [active ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)

			update_appearance()

		else
			to_chat(user, span_warning("The controls are locked!"))
	else
		to_chat(user, span_warning("[src] needs to be firmly secured to the floor first!"))
		return TRUE

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/M)
	if(ismegafauna(M) && anchored)
		set_anchored(FALSE)
		M.visible_message(span_warning("[M] rips [src] free from its moorings!"))
	else
		. = ..()
	if(. && !anchored)
		step(src, get_dir(M, src))

/obj/machinery/power/emitter/process(seconds_per_tick)
	if(machine_stat & (BROKEN))
		return
	if(!welded || (!powernet && active_power_usage))
		active = FALSE
		update_appearance()
		return
	if(active == TRUE)
		if(!active_power_usage || surplus() >= active_power_usage)
			add_load(active_power_usage)
			if(!powered)
				powered = TRUE
				update_appearance()
				investigate_log("regained power and turned <font color='green'>ON</font> at [AREACOORD(src)]", INVESTIGATE_SINGULO)
		else
			if(powered)
				powered = FALSE
				update_appearance()
				investigate_log("lost power and turned <font color='red'>OFF</font> at [AREACOORD(src)]", INVESTIGATE_SINGULO)
				log_game("Emitter lost power in [AREACOORD(src)]")
			return
		if(charge <= 80)
			charge += 2.5 * seconds_per_tick
		if(!check_delay() || manual == TRUE)
			return FALSE
		fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((src.last_shot + src.fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam_pulse()
	if(!check_delay())
		return FALSE
	if(!welded)
		return FALSE
	if(surplus() >= active_power_usage)
		add_load(active_power_usage)
		fire_beam()

/obj/machinery/power/emitter/proc/fire_beam(mob/user)
	var/obj/projectile/P = new projectile_type(get_turf(src))
	playsound(src, projectile_sound, 50, TRUE)
	if(prob(35))
		sparks.start()
	P.firer = user ? user : src
	P.fired_from = src
	if(last_projectile_params)
		P.p_x = last_projectile_params[2]
		P.p_y = last_projectile_params[3]
		P.fire(last_projectile_params[1])
	else
		P.fire(dir2angle(dir))
	if(!manual)
		last_shot = world.time
		if(shot_number < 3)
			fire_delay = 20
			shot_number ++
		else
			fire_delay = rand(minimum_fire_delay,maximum_fire_delay)
			shot_number = 0
	return P

/obj/machinery/power/emitter/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, span_warning("Turn \the [src] off first!"))
		return FAILED_UNFASTEN

	else if(welded)
		if(!silent)
			to_chat(user, span_warning("[src] is welded to the floor!"))
		return FAILED_UNFASTEN

	return ..()

/obj/machinery/power/emitter/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/power/emitter/welder_act(mob/living/user, obj/item/I)
	..()
	if(active)
		to_chat(user, span_warning("Turn [src] off first!"))
		return TRUE

	if(welded)
		if(!I.tool_start_check(user, src, amount=0))
			return TRUE
		user.visible_message(span_notice("[user.name] starts to cut the [name] free from the floor."), \
			span_notice("You start to cut [src] free from the floor..."), \
			span_hear("You hear welding."))
		if(I.use_tool(src, user, 20, volume=50) && welded)
			welded = FALSE
			to_chat(user, span_notice("You cut [src] free from the floor."))
			disconnect_from_network()
//			update_cable_icons_on_turf(get_turf(src)) - WS Edit - Smartwire Revert

	else if(anchored)
		if(!I.tool_start_check(user, src, amount=0))
			return TRUE
		user.visible_message(span_notice("[user.name] starts to weld the [name] to the floor."), \
			span_notice("You start to weld [src] to the floor..."), \
			span_hear("You hear welding."))
		if(I.use_tool(src, user, 20, volume=50) && anchored)
			welded = TRUE
			to_chat(user, span_notice("You weld [src] to the floor."))
			connect_to_network()
//			update_cable_icons_on_turf(get_turf(src)) - WS Edit - Smartwire Revert

	else
		to_chat(user, span_warning("[src] needs to be wrenched to the floor!"))

	return TRUE

/obj/machinery/power/emitter/crowbar_act(mob/living/user, obj/item/I)
	if(panel_open && gun)
		return remove_gun(user)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/power/emitter/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	default_deconstruction_screwdriver(user, "emitter_open", "emitter", I)
	return TRUE


/obj/machinery/power/emitter/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		if(obj_flags & EMAGGED)
			to_chat(user, span_warning("The lock seems to be broken!"))
			return
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, span_notice("You [src.locked ? "lock" : "unlock"] the controls."))
			else
				to_chat(user, span_warning("The controls can only be locked when \the [src] is online!"))
		else
			to_chat(user, span_danger("Access denied."))
		return

	else if(is_wire_tool(I) && panel_open)
		wires.interact(user)
		return
	else if(panel_open && !gun && istype(I,/obj/item/gun/energy))
		if(integrate(I,user))
			return
	return ..()

/obj/machinery/power/emitter/proc/integrate(obj/item/gun/energy/E,mob/user)
	if(istype(E, /obj/item/gun/energy))
		if(!user.transferItemToLoc(E, src))
			return
		gun = E
		gun_properties = gun.get_turret_properties()
		set_projectile()
		return TRUE

/obj/machinery/power/emitter/proc/remove_gun(mob/user)
	if(!gun)
		return
	user.put_in_hands(gun)
	gun = null
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	gun_properties = list()
	set_projectile()
	return TRUE

/obj/machinery/power/emitter/proc/set_projectile()
	if(LAZYLEN(gun_properties))
		if(mode || !gun_properties["lethal_projectile"])
			projectile_type = gun_properties["stun_projectile"]
			projectile_sound = gun_properties["stun_projectile_sound"]
		else
			projectile_type = gun_properties["lethal_projectile"]
			projectile_sound = gun_properties["lethal_projectile_sound"]
		return
	projectile_type = initial(projectile_type)
	projectile_sound = initial(projectile_sound)

/obj/machinery/power/emitter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	obj_flags |= EMAGGED
	if(user)
		user.visible_message(span_warning("[user.name] emags [src]."), span_notice("You short out the lock."))

/obj/machinery/power/emitter/welded/Initialize()
	welded = TRUE
	return ..()

/obj/machinery/power/emitter/welded/upgraded/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	RefreshParts()

/obj/machinery/power/emitter/prototype
	name = "Prototype Emitter"
	icon = 'icons/obj/turrets.dmi'
	base_icon_state = "protoemitter"
	icon_state = "protoemitter"
	icon_state_on = "protoemitter_+a"
	icon_state_underpowered = "protoemitter_+u"
	can_buckle = TRUE
	buckle_lying = 0
	var/view_range = 4.5
	var/datum/action/innate/protoemitter/firing/auto

//BUCKLE HOOKS

/obj/machinery/power/emitter/prototype/unbuckle_mob(mob/living/buckled_mob,force = 0)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, TRUE)
	manual = FALSE
	for(var/obj/item/I in buckled_mob.held_items)
		if(istype(I, /obj/item/turret_control))
			qdel(I)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = buckled_mob.base_pixel_x
		buckled_mob.pixel_y = buckled_mob.base_pixel_y
		if(buckled_mob.client)
			buckled_mob.client.view_size.resetToDefault()
	auto.Remove(buckled_mob)
	. = ..()

/obj/machinery/power/emitter/prototype/user_buckle_mob(mob/living/M, mob/living/carbon/user, check_loc = FALSE)
	if(user.incapacitated() || !istype(user))
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density && (A != src && A != M))
			return
	M.forceMove(get_turf(src))
	..()
	playsound(src,'sound/mecha/mechmove01.ogg', 50, TRUE)
	M.pixel_y = 14
	layer = 4.1
	if(M.client)
		M.client.view_size.setTo(view_range)
	if(!auto)
		auto = new()
	auto.Grant(M, src)

/datum/action/innate/protoemitter
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	var/obj/machinery/power/emitter/prototype/PE
	var/mob/living/carbon/U


/datum/action/innate/protoemitter/Grant(mob/living/carbon/L, obj/machinery/power/emitter/prototype/proto)
	PE = proto
	U = L
	. = ..()

/datum/action/innate/protoemitter/firing
	name = "Switch to Manual Firing"
	desc = "The emitter will only fire on your command and at your designated target"
	button_icon_state = "mech_zoom_on"

/datum/action/innate/protoemitter/firing/Activate()
	if(PE.manual)
		playsound(PE,'sound/mecha/mechmove01.ogg', 50, TRUE)
		PE.manual = FALSE
		name = "Switch to Manual Firing"
		desc = "The emitter will only fire on your command and at your designated target"
		button_icon_state = "mech_zoom_on"
		for(var/obj/item/I in U.held_items)
			if(istype(I, /obj/item/turret_control))
				qdel(I)
		UpdateButtonIcon()
		return
	else
		playsound(PE,'sound/mecha/mechmove01.ogg', 50, TRUE)
		name = "Switch to Automatic Firing"
		desc = "Emitters will switch to periodic firing at your last target"
		button_icon_state = "mech_zoom_off"
		PE.manual = TRUE
		for(var/V in U.held_items)
			var/obj/item/I = V
			if(istype(I))
				if(U.dropItemToGround(I))
					var/obj/item/turret_control/TC = new /obj/item/turret_control()
					U.put_in_hands(TC)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				var/obj/item/turret_control/TC = new /obj/item/turret_control()
				U.put_in_hands(TC)
		UpdateButtonIcon()


/obj/item/turret_control
	name = "turret controls"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | NOBLUDGEON
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/delay = 0

/obj/item/turret_control/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/turret_control/afterattack(atom/targeted_atom, mob/user, proxflag, clickparams)
	. = ..()
	var/obj/machinery/power/emitter/E = user.buckled
	E.setDir(get_dir(E,targeted_atom))
	user.setDir(E.dir)
	switch(E.dir)
		if(NORTH)
			E.layer = 3.9
			user.pixel_x = 0
			user.pixel_y = -14
		if(NORTHEAST)
			E.layer = 3.9
			user.pixel_x = -8
			user.pixel_y = -12
		if(EAST)
			E.layer = 4.1
			user.pixel_x = -14
			user.pixel_y = 0
		if(SOUTHEAST)
			E.layer = 3.9
			user.pixel_x = -8
			user.pixel_y = 12
		if(SOUTH)
			E.layer = 4.1
			user.pixel_x = 0
			user.pixel_y = 14
		if(SOUTHWEST)
			E.layer = 3.9
			user.pixel_x = 8
			user.pixel_y = 12
		if(WEST)
			E.layer = 4.1
			user.pixel_x = 14
			user.pixel_y = 0
		if(NORTHWEST)
			E.layer = 3.9
			user.pixel_x = 8
			user.pixel_y = -12

	E.last_projectile_params = calculate_projectile_angle_and_pixel_offsets(user, clickparams)

	if(E.charge >= 10 && world.time > delay)
		E.charge -= 10
		E.fire_beam(user)
		delay = world.time + 10
	else if (E.charge < 10)
		playsound(src,'sound/machines/buzz-sigh.ogg', 50, TRUE)

