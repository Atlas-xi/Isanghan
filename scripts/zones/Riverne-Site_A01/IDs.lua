-----------------------------------
-- Area: Riverne-Site_A01
-----------------------------------
zones = zones or {}

zones[xi.zone.RIVERNE_SITE_A01] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        NOTHING_OUT_OF_ORDINARY       = 6405, -- There is nothing out of the ordinary here.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        CONQUEST_BASE                 = 7068, -- Tallying conquest results...
        TIME_IN_THE_BATTLEFIELD_IS_UP = 7232, -- Your time in the battlefield is up! Now exiting...
        PARTY_MEMBERS_ARE_ENGAGED     = 7247, -- The battlefield where your party members are engaged in combat is locked. Access is denied.
        NO_BATTLEFIELD_ENTRY          = 7263, -- A glowing mist of ever-changing proportions floats before you...
        MEMBERS_OF_YOUR_PARTY         = 7538, -- Currently, # members of your party (including yourself) have clearance to enter the battlefield.
        MEMBERS_OF_YOUR_ALLIANCE      = 7539, -- Currently, # members of your alliance (including yourself) have clearance to enter the battlefield.
        TIME_LIMIT_FOR_THIS_BATTLE_IS = 7541, -- The time limit for this battle is # minutes.
        PARTY_MEMBERS_HAVE_FALLEN     = 7577, -- All party members have fallen in battle. Now leaving the battlefield.
        THE_PARTY_WILL_BE_REMOVED     = 7584, -- If all party members' HP are still zero after # minute[/s], the party will be removed from the battlefield.
        ENTERING_THE_BATTLEFIELD_FOR  = 7604, -- Entering the battlefield for [Ouryu Cometh/]!
        SD_VERY_SMALL                 = 7608, -- The spatial displacement is very small. If you only had some item that could make it bigger...
        SD_HAS_GROWN                  = 7609, -- The spatial displacement has grown.
        SPACE_SEEMS_DISTORTED         = 7610, -- The space around you seems oddly distorted and disrupted.
        MONUMENT                      = 7617, -- Something has been engraved on this stone, but the message is too difficult to make out.
        HOMEPOINT_SET                 = 7745, -- Home point set!
        UNITY_WANTED_BATTLE_INTERACT  = 7803, -- Those who have accepted % must pay # Unity accolades to participate. The content for this Wanted battle is #. [Ready to begin?/You do not have the appropriate object set, so your rewards will be limited.]
    },
    mob =
    {
        HELIODROMOS_OFFSET       = GetFirstID('Heliodromos'),
        CARMINE_DOBSONFLY_OFFSET = GetFirstID('Carmine_Dobsonfly'),
        AIATAR                   = GetFirstID('Aiatar'),
        ZIRYU                    = GetTableOfIDs('Ziryu'),
    },
    npc =
    {
        DISPLACEMENT_OFFSET = GetFirstID('Spatial_Displacement'),
    },
}

return zones[xi.zone.RIVERNE_SITE_A01]
