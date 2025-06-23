-----------------------------------
-- Area: Boneyard_Gully
-----------------------------------
zones = zones or {}

zones[xi.zone.BONEYARD_GULLY] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        TIME_IN_THE_BATTLEFIELD_IS_UP = 7073, -- Your time in the battlefield is up! Now exiting...
        PARTY_MEMBERS_ARE_ENGAGED     = 7088, -- The battlefield where your party members are engaged in combat is locked. Access is denied.
        NO_BATTLEFIELD_ENTRY          = 7097, -- An ominous veil of pitch-black gas blocks your path. You cannot proceed any further...
        MEMBERS_OF_YOUR_PARTY         = 7379, -- Currently, # members of your party (including yourself) have clearance to enter the battlefield.
        MEMBERS_OF_YOUR_ALLIANCE      = 7380, -- Currently, # members of your alliance (including yourself) have clearance to enter the battlefield.
        TIME_LIMIT_FOR_THIS_BATTLE_IS = 7382, -- The time limit for this battle is <number> minutes.
        ORB_IS_CRACKED                = 7383, -- There is a crack in the %. It no longer contains a monster.
        A_CRACK_HAS_FORMED            = 7384, -- A crack has formed on the <item>, and the beast inside has been unleashed!
        PARTY_MEMBERS_HAVE_FALLEN     = 7418, -- All party members have fallen in battle. Now leaving the battlefield.
        THE_PARTY_WILL_BE_REMOVED     = 7425, -- If all party members' HP are still zero after # minute[/s], the party will be removed from the battlefield.
        CONQUEST_BASE                 = 7442, -- Tallying conquest results...
        ENTERING_THE_BATTLEFIELD_FOR  = 7605, -- Entering the battlefield for [Head Wind/Like the Wind/Sheep in Antlion's Clothing/Shell We Dance?/Totentanz/Tango with a Tracker/Requiem of Sin/Antagonistic Ambuscade/Head Wind]!
        FOLLOW_LEAD                   = 7728, -- Follow my lead!
        I_CANT_HAVE_LOST              = 7737, -- I...I can't have lost...
        READY_TO_REAP                 = 7738, -- Ready to rrrreap!
        LET_THE_MASSACRE_BEGIN        = 7739, -- Let the massacrrre begin!
        JUST_FOR_YOU_SUGARPLUM        = 7740, -- Just for you, sugarplum!
        IN_YOUR_EYE_HONEYCAKES        = 7741, -- In your eye, honeycakes!
        READY_TO_RUMBLE               = 7749, -- Ready to rrrumble!
        TIME_TO_HUNT                  = 7750, -- Mithran Trackers! Time to hunt!
        MY_TURN                       = 7751, -- My turn! My Turn!
        YOURE_MINE                    = 7752, -- You're mine!
        TUCHULCHA_SANDPIT             = 7761, -- Tuchulcha retreats beneath the soil!
        BURSTS_INTO_FLAMES            = 7766, -- The {key item} suddenly bursts into flames, the blackened remains borne away by the wind...
        GET_YOUR_BLOOD_RACING         = 7816, -- I'll get your blood rrracing!
        SCENT_OF_FRESH_BLOOD          = 7818, -- Ah, the scent of frrrresh blood!
        EVEN_AT_MY_BEST               = 7820, -- Even at my best...
        TIME_TO_END_THE_HUNT          = 7821, -- Time to end the hunt! Go for the jugular!
        DINNER_TIME_ADVENTURER_STEAK  = 7822, -- Dinner time! Tonight we're having "Adventurer Steak"!
    },

    mob =
    {
        PARATA            = GetFirstID('Parata'),
        SHIKAREE_Z        = GetFirstID('Shikaree_Z'),
        TUCHULCHA         = GetFirstID('Tuchulcha'),
        SHIKAREE_Z_OFFSET = GetTableOfIDs('Shikaree_Z'),
    },

    npc =
    {
    },

    shellWeDance =
    {
        [1] =
        {
            PARATA_ID        = 16810024,
            BLADMALL_ID      = 16810025,
            PARATA_PET_IDS   = { 16810026, 16810027, 16810028 },
            BLADMALL_PET_IDS = { 16810029, 16810030, 16810031 },
        },
        [2] =
        {
            PARATA_ID        = 16810033,
            BLADMALL_ID      = 16810034,
            PARATA_PET_IDS   = { 16810035, 16810036, 16810037 },
            BLADMALL_PET_IDS = { 16810038, 16810039, 16810040 },
        },
        [3] =
        {
            PARATA_ID        = 16810042,
            BLADMALL_ID      = 16810043,
            PARATA_PET_IDS   = { 16810044, 16810045, 16810046 },
            BLADMALL_PET_IDS = { 16810047, 16810048, 16810049 },
        },
    },
}

return zones[xi.zone.BONEYARD_GULLY]
