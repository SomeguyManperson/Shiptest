/obj/item/clothing/under/rank/civilian/curator
	name = "sensible suit"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit"
	item_state = "red_suit"
	mob_overlay_icon = 'icons/mob/clothing/under/suits.dmi'


/obj/item/clothing/under/rank/civilian/curator/skirt
	name = "sensible suitskirt"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit_skirt"
	item_state = "red_suit"
	mob_overlay_icon = 'icons/mob/clothing/under/suits.dmi'
	body_parts_covered = CHEST|GROIN|ARMS

	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON | VOX_VARIATION

/obj/item/clothing/under/rank/civilian/curator/treasure_hunter
	name = "treasure hunter uniform"
	desc = "A rugged uniform suitable for treasure hunting."
	icon = 'icons/obj/clothing/under/service.dmi'
	icon_state = "curator"
	item_state = "curator"
	mob_overlay_icon = 'icons/mob/clothing/under/service.dmi'

/obj/item/clothing/under/rank/civilian/curator/nasa
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "black"
	item_state = "bl_suit"
	mob_overlay_icon = 'icons/mob/clothing/under/color.dmi'
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT

	resistance_flags = NONE
