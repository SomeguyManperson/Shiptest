/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	BLACKBOX_LOG_ADMIN_VERB("Toggle Debug Two")



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/air_status_loc()
	set category = "Debug.Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = get_turf(mob)
	if(!isturf(T))
		return
	atmosanalyzer_scan(usr, T, TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Air Status In Location")

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Event.Fun"
	set name = "Make Robot"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human, Robotize))

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Event.Fun"
	set name = "Make Simple Animal"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, Animalize))


/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Event.Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in sortNames(available)
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)

	var/chosen_name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text|null

	if (isnull(chosen_name))
		return

	pai.name = chosen_name
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in SSpai.candidates)
		if(candidate.key == choice.key)
			SSpai.candidates.Remove(candidate)
	BLACKBOX_LOG_ADMIN_VERB("Make pAI")

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Event.Fun"
	set name = "Make Alien"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob/living/carbon/human, Alienize))
		BLACKBOX_LOG_ADMIN_VERB("Make Alien")
		log_admin("[key_name(usr)] made [key_name(M)] into an alien at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into an alien."))
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Event.Fun"
	set name = "Make slime"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob/living/carbon/human, slimeize))
		BLACKBOX_LOG_ADMIN_VERB("Make Slime")
		log_admin("[key_name(usr)] made [key_name(M)] into a slime at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into a slime."))
	else
		alert("Invalid mob")


//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in sortList(matches)
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].")
		BLACKBOX_LOG_ADMIN_VERB("Delete All")


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	BLACKBOX_LOG_ADMIN_VERB("Make Powernets")

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Debug.Debug"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			id = new /obj/item/card/id/gold(H.loc)
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.update_label()
			id.update_appearance()

			if(worn)
				if(istype(worn, /obj/item/pda))
					var/obj/item/pda/PDA = worn
					PDA.id = id
					id.forceMove(PDA)
				else if(istype(worn, /obj/item/storage/wallet))
					var/obj/item/storage/wallet/W = worn
					W.front_id = id
					id.forceMove(W)
					W.update_appearance()
			else
				H.equip_to_slot(id,ITEM_SLOT_ID)

	else
		alert("Invalid mob")
	BLACKBOX_LOG_ADMIN_VERB("Grant Full Access")
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins(span_adminnotice("[key_name_admin(usr)] has granted [M.key] full access."))

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Debug.Debug"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(alert("This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.",,"Yes","No") != "Yes")
			return
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists."))
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] assumed direct control of [M]."))
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = mob
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = ckey
	if(isobserver(adminmob))
		qdel(adminmob)
	BLACKBOX_LOG_ADMIN_VERB("Assume Direct Control")

/client/proc/cmd_give_direct_control(mob/M in GLOB.mob_list)
	set category = "Debug.Debug"
	set name = "Give direct control"

	if(!M)
		return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.key]. Are you sure you wish to give someone else control of it? [M.key] will be made a ghost.",,"Yes","No") != "Yes")
			return
	var/client/newkey = input(src, "Pick the player to put in control.", "New player") as null|anything in sortList(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || alert("Do you want to delete [newkey]'s old mob?","Delete?","Yes","No") != "No"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists, aborting."))
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	if(delmob)
		qdel(oldmob)
	message_admins(span_adminnotice("[key_name_admin(usr)] gave away direct control of [M] to [newkey]."))
	log_admin("[key_name(usr)] gave away direct control of [M] to [newkey].")
	BLACKBOX_LOG_ADMIN_VERB("Give Direct Control")

/client/proc/cmd_admin_test_atmos_controllers()
	set category = "Debug.Mapping"
	set name = "Test Atmos Monitoring Consoles"

	var/list/dat = list()

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential = TRUE)
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Atmos Monitor debug command."))
	log_admin("[key_name(usr)] used the Test Atmos Monitor debug command.")

	var/bad_shit = 0
	for(var/obj/machinery/computer/atmos_control/tank/console in GLOB.atmos_air_controllers)
		dat += "<h1>[console] at [AREACOORD(console)]:</h1><br>"
		if(console.input_tag == console.output_tag)
			dat += "Error: input_tag is the same as the output_tag, \"[console.input_tag]\"!<br>"
			bad_shit++
		if(!LAZYLEN(console.input_info))
			dat += "Failed to find a valid outlet injector as an input with the tag [console.input_tag].<br>"
			bad_shit++
		if(!LAZYLEN(console.output_info))
			dat += "Failed to find a valid siphon pump as an outlet with the tag [console.output_tag].<br>"
			bad_shit++
		if(!bad_shit)
			dat += "<B>STATUS:</B> NORMAL"
		else
			bad_shit = 0
		dat += "<br>"
		CHECK_TICK

	var/datum/browser/popup = new(usr, "testatmoscontroller", "Test Atmos Monitoring Consoles", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

/client/proc/cmd_admin_areatest()
	set category = "Debug.Mapping"
	set name = "Test Areas"

	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()
	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!", confidential = TRUE)
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Areas debug command checking all z-levels."))
	log_admin("[key_name(usr)] used the Test Areas debug command checking z-levels.")

	for(var/area/A in world)
		areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!A)
			dat += "Skipped over [APC] in invalid location, [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Skipped over [AA] in invalid location, [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!A)
			dat += "Skipped over [RC] in invalid location, [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			dat += "Skipped over [L] in invalid location, [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			dat += "Skipped over [LS] in invalid location, [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in GLOB.machines)
		var/area/A = get_area(C)
		if(!A)
			dat += "Skipped over [C] in invalid location, [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>AREAS WITHOUT AN APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>AREAS WITH MULTIPLE APCS:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>AREAS WITHOUT AN AIR ALARM:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>AREAS WITHOUT A REQUEST CONSOLE:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>AREAS WITHOUT ANY LIGHTS:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>AREAS WITHOUT A LIGHT SWITCH:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>AREAS WITHOUT ANY INTERCOMS:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>AREAS WITHOUT ANY CAMERAS:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>No problem areas!</b>"

	var/datum/browser/popup = new(usr, "testareas", "Test Areas", 500, 750)
	popup.set_content(dat.Join())
	popup.open()


/client/proc/cmd_admin_areatest_station()
	set category = "Debug.Mapping"
	set name = "Test Areas (STATION Z)"
	cmd_admin_areatest(TRUE)

/client/proc/cmd_admin_areatest_all()
	set category = "Debug.Mapping"
	set name = "Test Areas (ALL)"
	cmd_admin_areatest(FALSE)

/client/proc/robust_dress_shop()

	var/list/baseoutfits = list("Naked","Custom","As Job...", "As Plasmaman...")
	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman)

	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in baseoutfits + sortList(outfits)
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "As Plasmaman...")
		var/list/plasmaman_paths = subtypesof(/datum/outfit/plasmaman)
		var/list/plasmaman_outfits = list()
		for(var/path in plasmaman_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				plasmaman_outfits[initial(O.name)] = path

		dresscode = input("Select plasmeme equipment", "Robust quick dress shop") as null|anything in sortList(plasmaman_outfits)
		dresscode = plasmaman_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in sortList(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

/client/proc/start_singlo()
	set category = "Debug.Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == 0)
			F.set_anchored(TRUE)
			F.active = 1
			F.state = 2
			F.power = 250
			F.warming_up = 3
			F.start_fields()
			F.update_appearance()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
//				qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.set_moles(GAS_PLASMA, 70)
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","), confidential = TRUE)
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","), confidential = TRUE)
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","), confidential = TRUE)
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.alive_mob_list,","), confidential = TRUE)
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","), confidential = TRUE)
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","), confidential = TRUE)
		if("Joined Clients")
			to_chat(usr, jointext(GLOB.joined_player_list,","), confidential = TRUE)

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		if(LAZYLEN(I.extra_details))
			var/details = I.extra_details.Join("</li><li>")
			dellog += "<li>Extra Info: <ul><li>[details]</li></ul>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(dellog.Join(), "window=dellog")

/client/proc/cmd_display_overlay_log()
	set category = "Debug"
	set name = "Display overlay Log"
	set desc = "Display SSoverlays log of everything that's passed through it."

	render_stats(SSoverlays.stats, src)

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialize() Log"
	set desc = "Displays a list of things that didn't handle Initialize() properly"

	usr << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

/client/proc/debug_huds(i as num)
	set category = "Debug"
	set name = "Debug HUDs"
	set desc = "Debug the data or antag HUDs"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."
	if(!holder)
		return
	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in sortList(names)


	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		usr.forceMove(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"), confidential = TRUE)
		to_chat(usr, span_italics("[template.description]"), confidential = TRUE)

/client/proc/fucky_wucky()
	set category = "Event.Fun"
	set name = "Fucky Wucky"
	set desc = "Inform the players that the code monkeys at our headquarters are working very hard to fix this."

	if(!check_rights(R_FUN))
		return
	remove_verb(/client/proc/fucky_wucky)
	message_admins(span_adminnotice("[key_name_admin(src)] did a fucky wucky."))
	log_admin("[key_name(src)] did a fucky wucky.")
	for(var/m in GLOB.player_list)
		var/datum/asset/fuckywucky = get_asset_datum(/datum/asset/simple/fuckywucky)
		fuckywucky.send(m)
		SEND_SOUND(m, 'sound/misc/fuckywucky.ogg')
		to_chat(m, span_purple(boxed_message("<img src='[SSassets.transport.get_asset_url("fuckywucky.png")]'>")))

	addtimer(CALLBACK(src, PROC_REF(restore_fucky_wucky)), 600)

/client/proc/restore_fucky_wucky()
	add_verb(/client/proc/fucky_wucky)

/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Medal Disable"
	set desc = "Toggles the safety lock on trying to contact the medal hub."

	if(!check_rights(R_SERVER))
		return

	SSachievements.achievements_enabled = !SSachievements.achievements_enabled

	message_admins(span_adminnotice("[key_name_admin(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout."))
	BLACKBOX_LOG_ADMIN_VERB("Toggle Medal Disable") // If...
	log_admin("[key_name(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the medal hub lockout.")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/pump_random_event()
	set category = "Debug"
	set name = "Pump Random Event"
	set desc = "Schedules the event subsystem to fire a new random event immediately. Some events may fire without notification."
	if(!holder)
		return

	SSevents.scheduled = world.time

	message_admins(span_adminnotice("[key_name_admin(src)] pumped a random event."))
	BLACKBOX_LOG_ADMIN_VERB("Pump Random Event")
	log_admin("[key_name(src)] pumped a random event.")

/client/proc/start_line_profiling()
	set category = "Debug.Profile"
	set name = "Start Line Profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	LINE_PROFILE_START

	message_admins(span_adminnotice("[key_name_admin(src)] started line by line profiling."))
	BLACKBOX_LOG_ADMIN_VERB("Start Line Profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Debug.Profile"
	set name = "Stops Line Profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	LINE_PROFILE_STOP

	message_admins(span_adminnotice("[key_name_admin(src)] stopped line by line profiling."))
	BLACKBOX_LOG_ADMIN_VERB("Stop Line Profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Debug.Profile"
	set name = "Show Line Profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time"		=	/proc/cmp_profile_avg_time_dsc,
		"Total Time"	=	/proc/cmp_profile_time_dsc,
		"Call Count"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/reload_configuration()
	set category = "Debug"
	set name = "Reload Configuration"
	set desc = "Force config reload to world default"
	if(!check_rights(R_DEBUG))
		return
	if(alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", "No", "Yes") == "Yes")
		config.admin_reload()

/// A debug verb to check the sources of currently running timers
/client/proc/check_timer_sources()
	set category = "Debug.Debug"
	set name = "Check Timer Sources"
	set desc = "Checks the sources of the running timers"
	if (!check_rights(R_DEBUG))
		return

	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	usr << browse({"
		<h3>bucket_list</h3>
		[bucket_list_output]

		<h3>second_queue</h3>
		[second_queue]
	"}, "window=check_timer_sources;size=700x700")

/client/proc/allow_browser_inspect()
	set category = "Debug.Debug"
	set name = "Allow Browser Inspect"
	set desc = "Allows browser debugging via inspect"

	if(!check_rights(R_DEBUG))
		return

	var/client/user = usr

	if(user.byond_version < 516)
		to_chat(user, span_warning("You can only use this on 516!"))
		return

	to_chat(user, span_notice("You can now right click to use inspect on browsers."))
	winset(user, null, list("browser-options" = "+devtools"))

/proc/generate_timer_source_output(list/datum/timedevent/events)
	var/list/per_source = list()

	// Collate all events and figure out what sources are creating the most
	for (var/_event in events)
		if (!_event)
			continue
		var/datum/timedevent/event = _event

		do
			if (event.source)
				if (per_source[event.source] == null)
					per_source[event.source] = 1
				else
					per_source[event.source] += 1
			event = event.next
		while (event && event != _event)

	// Now, sort them in order
	var/list/sorted = list()
	for (var/source in per_source)
		sorted += list(list("source" = source, "count" = per_source[source]))
	sorted = sortTim(sorted, PROC_REF(cmp_timer_data))

	// Now that everything is sorted, compile them into an HTML output
	var/output = "<table border='1'>"

	for (var/_timer_data in sorted)
		var/list/timer_data = _timer_data
		output += {"<tr>
			<td><b>[timer_data["source"]]</b></td>
			<td>[timer_data["count"]]</td>
		</tr>"}

	output += "</table>"

	return output

/proc/cmp_timer_data(list/a, list/b)
	return b["count"] - a["count"]
