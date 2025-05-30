/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

/*
/atom/movable/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/atom/movable/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()
*/

/atom/movable/screen/ghost/respawn
	name = "Respawn"
	icon_state = "respawn"

/atom/movable/screen/ghost/respawn/Click()
	var/mob/dead/observer/G = usr
	G.respawn()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/pai
	name = "pAI Candidate"
	icon_state = "pai"

/atom/movable/screen/ghost/pai/Click()
	var/mob/dead/observer/G = usr
	G.register_pai()

/atom/movable/screen/ghost/spawner_menu
	name = "Spawner Menu"
	icon = 'icons/hud/screen_ghost.dmi'
	icon_state = "spawner_menu"

/atom/movable/screen/ghost/spawner_menu/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/respawn()
	using.screen_loc = ui_ghost_respawn
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/ghost/pai()
	using.screen_loc = ui_ghost_pai
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/language_menu
	using.icon = ui_style
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/ghost/spawner_menu()
	using.screen_loc = ui_ghost_spawner_menu
	using.hud = src
	static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.ghost_hud)
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		return
	. = ..()
