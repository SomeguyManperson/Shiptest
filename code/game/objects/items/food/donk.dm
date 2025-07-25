/obj/item/food/donkpocket/random
	name = "\improper Random Donk-pocket"
	icon_state = "donkpocket"
	desc = "The food of choice for the seasoned coder (if you see this, contact DonkCo. as soon as possible)."
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)// immediately gets overwritten. This exists to not set off the edibility unit test.

/obj/item/food/donkpocket/random/Initialize()
	. = ..()
	var/list/donkblock = list(
	/obj/item/food/donkpocket/warm,
	/obj/item/food/donkpocket/warm/spicy,
	/obj/item/food/donkpocket/warm/teriyaki,
	/obj/item/food/donkpocket/warm/pizza,
	/obj/item/food/donkpocket/warm/berry
	)

	var donk_type = pick(subtypesof(/obj/item/food/donkpocket) - donkblock)
	new donk_type(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/food/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	microwaved_type = /obj/item/food/donkpocket/warm
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2 //uhhh lorewise microwaving donkpockets makes the proteins into omnizine or somethin idk
	)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

	/// What type of donk pocket we're warmed into via baking or microwaving.
	//var/warm_type = /obj/item/food/donkpocket/warm
	/// The lower end for how long it takes to bake
	var/baking_time_short = 25 SECONDS
	/// The upper end for how long it takes to bake
	var/baking_time_long = 30 SECONDS

/*
/obj/item/food/donkpocket/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type)
*/

/obj/item/food/donkpocket/warm
	name = "warm Donk-pocket"
	desc = "The heated food of choice for the seasoned traitor."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 6
	)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN
	microwaved_type = /obj/item/food/badrecipe
	baking_time_short = 10 SECONDS
	baking_time_long = 15 SECONDS

/obj/item/food/dankpocket
	name = "\improper Dank-pocket"
	desc = "The food of choice for the seasoned botanist."
	icon_state = "dankpocket"
	food_reagents = list(
		/datum/reagent/toxin/lipolicide = 3,
		/datum/reagent/drug/space_drugs = 3,
		/datum/reagent/consumable/nutriment = 4
	)
	tastes = list("meat" = 2, "dough" = 2)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/donkpocket/spicy
	name = "\improper Spicy-pocket"
	desc = "The classic snack food, now with a heat-activated spicy flair."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/spicy
	microwaved_type = /obj/item/food/donkpocket/warm/spicy

/obj/item/food/donkpocket/warm/spicy
	name = "warm Spicy-pocket"
	desc = "The classic snack food, now maybe a bit too spicy."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/capsaicin = 5
	)
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/teriyaki
	name = "\improper Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/soysauce = 2
	)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/teriyaki
	microwaved_type = /obj/item/food/donkpocket/warm/teriyaki

/obj/item/food/donkpocket/warm/teriyaki
	name = "warm Teriyaki-pocket"
	desc = "An east-asian take on the classic stationside snack, now steamy and warm."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/pizza
	name = "\improper Pizza-pocket"
	desc = "Delicious, cheesy and surprisingly filling."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/tomatojuice = 2
	)
	tastes = list("meat" = 2, "dough" = 2, "cheese"= 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/pizza
	microwaved_type = /obj/item/food/donkpocket/warm/pizza

/obj/item/food/donkpocket/warm/pizza
	name = "warm Pizza-pocket"
	desc = "Delicious, cheesy, and even better when hot."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/tomatojuice = 2
	)
	tastes = list("meat" = 2, "dough" = 2, "melty cheese"= 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/berry
	name = "\improper Berry-pocket"
	desc = "A relentlessly sweet donk-pocket first created for use in Operation Dessert Storm."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/berryjuice = 3
	)
	tastes = list("dough" = 2, "jam" = 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/berry
	microwaved_type = /obj/item/food/donkpocket/warm/berry

/obj/item/food/donkpocket/warm/berry
	name = "warm Berry-pocket"
	desc = "A relentlessly sweet donk-pocket, now warm and delicious."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/berryjuice = 3
	)
	tastes = list("dough" = 2, "warm jam" = 2)
	foodtypes = GRAIN
