-----------------------------------
-- Area: Hazhalm_Testing_Grounds
-----------------------------------
zones = zones or {}

zones[xi.zone.HAZHALM_TESTING_GROUNDS] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6384, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6390, -- Obtained: <item>.
        GIL_OBTAINED                  = 6391, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6393, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7001, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7002, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7003, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7023, -- Your party is unable to participate because certain members' levels are restricted.
        PARTY_MEMBERS_HAVE_FALLEN     = 7611, -- All party members have fallen in battle. Now leaving the battlefield.
        THE_PARTY_WILL_BE_REMOVED     = 7618, -- If all party members' HP are still zero after # minute[/s], the party will be removed from the battlefield.
    },
    mob =
    {
        -- Einherjar: Wing 1: Mobs
        BUGARD_X         = GetTableOfIDs('Bugard-X'),
        CHIGOE           = GetTableOfIDs('Chigoe'),
        CRAVEN_EINHERJAR = GetTableOfIDs('Craven_Einherjar'),
        DARK_ELEMENTAL   = GetTableOfIDs('Dark_Elemental'),
        DJIGGA           = GetTableOfIDs('Djigga'), -- Chigoes for Hildesvini; can also appear in Wing 3
        EINHERJAR_EATER  = GetTableOfIDs('Einherjar_Eater'),
        HAZHALM_BAT      = GetTableOfIDs('Hazhalm_Bat'),
        HAZHALM_BATS     = GetTableOfIDs('Hazhalm_Bats'),
        HYNDLA           = GetTableOfIDs('Hyndla'),
        INFECTED_WAMOURA = GetTableOfIDs('Infected_Wamoura'),
        LOGI             = GetTableOfIDs('Logi'),
        NICKUR           = GetTableOfIDs('Nickur'),
        ROTTING_HUSKARL  = GetTableOfIDs('Rotting_Huskarl'),
        SJOKRAKJEN       = GetTableOfIDs('Sjokrakjen'),

        -- Einherjar: Wing 1: Bosses
        HAKENMANN      = GetFirstID('Hakenmann'),
        HILDESVINI     = GetFirstID('Hildesvini'),
        HIMINRJOT      = GetFirstID('Himinrjot'),
        HRAESVELG      = GetFirstID('Hraesvelg'),
        MORBOL_EMPEROR = GetFirstID('Morbol_Emperor'),
        NIHHUS         = GetFirstID('Nihhus'),

        -- Einherjar: Wing 2: Mobs
        BATTLEMITE           = GetTableOfIDs('Battlemite'),
        CORRUPT_EINHERJAR    = GetTableOfIDs('Corrupt_Einherjar'),
        EINHERJAR_BREI       = GetTableOfIDs('Einherjar_Brei'),
        FLAMES_OF_MUSPELHEIM = GetTableOfIDs('Flames_of_Muspelheim'),
        GARDSVOR             = GetTableOfIDs('Gardsvor'),
        HAZHALM_LEECH        = GetTableOfIDs('Hazhalm_Leech'),
        ODINS_FOOL           = GetTableOfIDs('Odins_Fool'),
        UTGARTH_BAT          = GetTableOfIDs('Utgarth_Bat'),
        UTGARTH_BATS         = GetTableOfIDs('Utgarth_Bats'),
        UTGARTH_LEECH        = GetTableOfIDs('Utgarth_Leech'),
        WALDGEIST            = GetTableOfIDs('Waldgeist'),
        WINEBIBBER           = GetTableOfIDs('Winebibber'),

        -- Einherjar: Wing 2: Bosses
        ANDHRIMNIR     = GetFirstID('Andhrimnir'),
        ARIRI_SAMARIRI = GetFirstID('Ariri_Samariri'),
        BALRAHN        = GetFirstID('Balrahn'),
        HRUNGNIR       = GetFirstID('Hrungnir'),
        MOKKURALFI     = GetFirstID('Mokkuralfi'),
        TANGRISNIR     = GetFirstID('Tanngrisnir'),

        -- Einherjar: Wing 3: Mobs
        AUDHUMBLA            = GetTableOfIDs('Audhumbla'),
        BERSERKR             = GetTableOfIDs('Berserkr'),
        EXPERIMENTAL_POROGGO = GetTableOfIDs('Experimental_Poroggo'),
        HAFGYGR              = GetTableOfIDs('Hafgygr'),
        IDUN                 = GetTableOfIDs('Idun'),
        LIQUIFIED_EINHERJAR  = GetTableOfIDs('Liquified_Einherjar'),
        MARGYGR              = GetTableOfIDs('Margygr'),
        MARID_X              = GetTableOfIDs('Marid-X'),
        MANTICORE_X          = GetTableOfIDs('Manticore-X'),
        ODINS_JESTER         = GetTableOfIDs('Odins_Jester'),
        ORMR                 = GetTableOfIDs('Ormr'),
        SOULFLAYER           = GetTableOfIDs('Soulflayer'),
        VAMPYR_DOG           = GetTableOfIDs('Vampyr_Dog'),
        VANQUISHED_EINHERJAR = GetTableOfIDs('Vanquished_Einherjar'),
        WIVRE_X              = GetTableOfIDs('Wivre-X'),
        HERVARTH             = GetFirstID('Hervarth'),            -- Motsognir add
        HJORVARTH            = GetFirstID('Hjorvarth'),           -- Motsognir add
        HRANI                = GetFirstID('Hrani'),               -- Motsognir add
        ANGANTYR             = GetFirstID('Angantyr'),            -- Motsognir add
        BUI                  = GetFirstID('Bui'),                 -- Motsognir add
        BRAMI                = GetFirstID('Brami'),               -- Motsognir add
        BARRI                = GetFirstID('Barri'),               -- Motsognir add
        REIFNIR              = GetFirstID('Reifnir'),             -- Motsognir add
        TIND                 = GetFirstID('Tind'),                -- Motsognir add
        TYRFING              = GetFirstID('Tyrfing'),             -- Motsognir add
        HADDING_THE_ELDER    = GetFirstID('Hadding_the_Elder'),   -- Motsognir add
        HADDING_THE_YOUNGER  = GetFirstID('Hadding_the_Younger'), -- Motsognir add
        VAMPYR_BATS          = GetTableOfIDs('Vampyr_Bats'),      -- Vampyr Jarl adds
        VAMPYR_WOLF          = GetTableOfIDs('Vampyr_Wolf'),      -- Vampyr Jarl adds

        -- Einherjar: Wing 3: Bosses
        DENDAINSONNE = GetFirstID('Dendainsonne'),
        FREKE        = GetFirstID('Freke'),
        GORGIMERA    = GetFirstID('Gorgimera'),
        MOTSOGNIR    = GetFirstID('Motsognir'),
        STOORWORM    = GetFirstID('Stoorworm'),
        VAMPYR_JARL  = GetFirstID('Vampyr_Jarl'),

        -- Einherjar: Odin's Chamber
        ODIN         = GetFirstID('Odin'),
        BRUNHILDE    = GetFirstID('Brunhilde'),
        SIEGRUNE     = GetFirstID('Siegrune'),
        ROSSWEISSE   = GetFirstID('Rossweisse'),
        GERHILDE     = GetFirstID('Gerhilde'),
        SCHWERTLEITE = GetFirstID('Schwertleite'),
        HELMWIGE     = GetFirstID('Helmwige'),
        ORTLINDE     = GetFirstID('Ortlinde'),
        GRIMGERDE    = GetFirstID('Grimgerde'),
        WALTRAUTE    = GetFirstID('Waltraute'),

        -- Einherjar: Special Mobs - 9 copies of each
        HUGINN     = GetTableOfIDs('Huginn'),
        MUNINN     = GetTableOfIDs('Muninn'),
        HEITHRUN   = GetTableOfIDs('Heithrun'),
        SAEHRIMNIR = GetTableOfIDs('Saehrimnir'),
    },
    npc =
    {
        -- Einherjar: Armoury Crates (Rewards chests x9, Temporary items chests x9)
        ARMOURY_CRATE = GetTableOfIDs('Armoury_Crate'),
    },
}

return zones[xi.zone.HAZHALM_TESTING_GROUNDS]
