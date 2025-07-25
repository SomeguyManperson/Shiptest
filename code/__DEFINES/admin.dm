//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC (1<<0)
#define MUTE_OOC (1<<1)
#define MUTE_PRAY (1<<2)
#define MUTE_ADMINHELP (1<<3)
#define MUTE_DEADCHAT (1<<4)
#define MUTE_MENTORHELP (1<<5)
#define MUTE_ALL (~0)

//Some constants for DB_Ban
#define BANTYPE_PERMA 1
#define BANTYPE_TEMP 2
#define BANTYPE_JOB_PERMA 3
#define BANTYPE_JOB_TEMP 4
/// used to locate stuff to unban.
#define BANTYPE_ANY_FULLBAN 5

#define BANTYPE_ADMIN_PERMA 7
#define BANTYPE_ADMIN_TEMP 8
/// used to remove jobbans
#define BANTYPE_ANY_JOB 9

//Admin Permissions
#define R_BUILD (1<<0)
#define R_ADMIN (1<<1)
#define R_BAN (1<<2)
#define R_FUN (1<<3)
#define R_SERVER (1<<4)
#define R_DEBUG (1<<5)
#define R_POSSESS (1<<6)
#define R_PERMISSIONS (1<<7)
#define R_STEALTH (1<<8)
#define R_POLL (1<<9)
#define R_VAREDIT (1<<10)
#define R_SOUND (1<<11)
#define R_SPAWN (1<<12)
#define R_AUTOADMIN (1<<13)
#define R_DBRANKS (1<<14)
#define R_MENTOR (1<<15)

#define R_DEFAULT R_AUTOADMIN

#define R_EVERYTHING (1<<16)-1 //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='byond://?_src_=vars;[HrefToken(TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_SP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];skill=[REF(user)]'>SP</a>)"
#define ADMIN_KICK(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
/// Displays "(SHOW)" in the chat, when clicked it tries to show atom(paper) or atom(photo). First you need to set the request_state variable to TRUE for the paper.
#define ADMIN_SHOW_PAPER(atom) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];show_paper=[REF(atom)]'>SHOW</a>)"
#define ADMIN_SHOW_PHOTO(atom) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];show_photo=[REF(atom)]'>PHOTO</a>)"

/// Used in logging uses of admin verbs (and sometimes some non-admin or debug verbs) to the blackbox
/// Only pass it a string key, the verb being used.
#define BLACKBOX_LOG_ADMIN_VERB(the_verb) SSblackbox.record_feedback("tally", "admin_verb", 1, the_verb)

#define ADMIN_PUNISHMENT_LIGHTNING "Lightning bolt"
#define ADMIN_PUNISHMENT_BRAINDAMAGE "Brain damage"
#define ADMIN_PUNISHMENT_GIB "Gib"
#define ADMIN_PUNISHMENT_BSA "Bluespace Artillery Device"
#define ADMIN_PUNISHMENT_FIREBALL "Fireball"
#define ADMIN_PUNISHMENT_SUPPLYPOD_QUICK "Supply Pod (Quick)"
#define ADMIN_PUNISHMENT_SUPPLYPOD "Supply Pod"
#define ADMIN_PUNISHMENT_MAZING "Puzzle"
#define ADMIN_PUNISHMENT_IMMERSE "Fully Immerse"
#define ADMIN_PUNISHMENT_CRACK ":B:oneless"
#define ADMIN_PUNISHMENT_BLEED ":B:loodless"
#define ADMIN_PUNISHMENT_PERFORATE ":B:erforate"
#define ADMIN_PUNISHMENT_SHOES "Knot Shoes"

#define AHELP_ACTIVE 1
#define AHELP_CLOSED 2
#define AHELP_RESOLVED 3

/// Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_WARNING 5
/// Number of identical messages required before the spam-prevention will automute you
#define SPAM_TRIGGER_AUTOMUTE 10

///Max length of a keypress command before it's considered to be a forged packet/bogus command
#define MAX_KEYPRESS_COMMANDLENGTH 16
///Maximum keys that can be bound to one button
#define MAX_COMMANDS_PER_KEY 5
///Maximum keys per keybind
#define MAX_KEYS_PER_KEYBIND 3
///Max amount of keypress messages per second over two seconds before client is autokicked
#define MAX_KEYPRESS_AUTOKICK 50
///Length of held key buffer
#define HELD_KEY_BUFFER_LENGTH 15

#define STICKYBAN_DB_CACHE_TIME 10 SECONDS
#define STICKYBAN_ROGUE_CHECK_TIME 5

/// for [/proc/check_asay_links], if there are any actionable refs in the asay message, this index in the return list contains the new message text to be printed
#define ASAY_LINK_NEW_MESSAGE_INDEX "!asay_new_message"
/// for [/proc/check_asay_links], if there are any admin pings in the asay message, this index in the return list contains a list of admins to ping
#define ASAY_LINK_PINGED_ADMINS_INDEX "!pinged_admins"

/// Shown to vicitm of staff of change and related effects.
#define POLICY_POLYMORPH "polymorph"
/// Shown on top of policy verb window
#define POLICY_VERB_HEADER "policy_verb_header"

//How many things you can spawn at once with spawn verb/create panel
#define ADMIN_SPAWN_CAP 100

// LOG BROWSE TYPES
#define BROWSE_ROOT_ALL_LOGS 1
#define BROWSE_ROOT_CURRENT_LOGS 2
