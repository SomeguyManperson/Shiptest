/obj/machinery/atmospherics/components/unary/thermomachine
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	idle_power_usage = IDLE_DRAW_LOW
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	pipe_flags = PIPING_ONE_PER_TURF

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

	var/min_temperature = 0
	var/max_temperature = 0
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.

/obj/machinery/atmospherics/components/unary/thermomachine/Initialize(mapload)
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer
	..()

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	var/B
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		B += M.rating
	heat_capacity = 5000 * ((B - 1) ** 2)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_state()

	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(on && is_operational)
		icon_state = icon_state_on
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/update_overlays()
	. = ..()
	. += getpipeimage(icon, "pipe", dir, , piping_layer)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/thermomachine/examine(mob/user)
	. = ..()
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Efficiency <b>[(heat_capacity/5000)*100]%</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.")

/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos(seconds_per_tick)
	..()
	if(!on || !nodes[1])
		return
	var/datum/gas_mixture/air_contents = airs[1]

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.return_temperature()

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.return_temperature()
		air_contents.set_temperature(combined_energy/combined_heat_capacity)

	var/temperature_delta= abs(old_temperature - air_contents.return_temperature())
	if(temperature_delta > 1)
		active_power_usage = (heat_capacity * temperature_delta) / 5 + idle_power_usage
		update_parents()
	else
		active_power_usage = idle_power_usage
	return 1

/obj/machinery/atmospherics/components/unary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoMachine", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/air1 = airs[1]
	data["temperature"] = air1.return_temperature()
	data["pressure"] = air1.return_pressure()
	return data

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			if(on)
				set_active_power()
			else
				set_idle_power()
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)

	update_appearance()

//WS Edit - Update from Cit's Thermomachine - PR #8800, adds additional info to ctrl and alt clicks - BFAT

/obj/machinery/atmospherics/components/unary/thermomachine/CtrlClick(mob/living/user)
	var/area/A = get_area(src)
	var/turf/T = get_turf(src)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	on = !on
	if(on)
		set_active_power()
	else
		set_idle_power()
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	update_appearance()
	investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
	message_admins("[src.name] was turned [on ? "on" : "off"] [ADMIN_LOOKUPFLW(usr)] at [ADMIN_COORDJMP(T)], [A]")

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "freezer"
	icon_state = "freezer"
	icon_state_off = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	max_temperature = T20C
	min_temperature = 170 //actual minimum temperature is defined by RefreshParts()
	circuit = /obj/item/circuitboard/machine/thermomachine/freezer

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on
	on = TRUE
	icon_state = "freezer_1"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/Initialize()
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom
	name = "cold room freezer"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom/Initialize()
	. = ..()
	target_temperature = T0C-80

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	min_temperature = max(T0C - (initial(min_temperature) + L * 15), TCMB) //73.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/AltClick(mob/living/user)
	. = ..()
	var/area/A = get_area(src)
	var/turf/T = get_turf(src)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	target_temperature = min_temperature
	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	message_admins("[src.name] was minimized by [ADMIN_LOOKUPFLW(user)] at [ADMIN_COORDJMP(T)], [A]")
	to_chat(user, span_notice("You minimize the target temperature on [src] to [target_temperature] K."))

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "heater"
	icon_state = "heater"
	icon_state_off = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	max_temperature = 140 //actual maximum temperature is defined by RefreshParts()
	min_temperature = T20C
	circuit = /obj/item/circuitboard/machine/thermomachine/heater

/obj/machinery/atmospherics/components/unary/thermomachine/heater/on
	on = TRUE
	icon_state = "heater_1"

/obj/machinery/atmospherics/components/unary/thermomachine/heater/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	max_temperature = T20C + (initial(max_temperature) * L) //573.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/heater/AltClick(mob/living/user)
	. = ..()
	var/area/A = get_area(src)
	var/turf/T = get_turf(src)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	target_temperature = max_temperature
	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	message_admins("[src.name] was maximized by [ADMIN_LOOKUPFLW(user)] at [ADMIN_COORDJMP(T)], [A]")
	to_chat(user, span_notice("You maximize the target temperature on [src] to [target_temperature] K."))
