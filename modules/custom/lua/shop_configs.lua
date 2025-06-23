-----------------------------------
-- Shop Configuration Module
-- Individual shop data configurations
-- File: modules/custom/shop_configs.lua
-----------------------------------

local shopConfigs = {}

-- General Equipment Shop
shopConfigs.general_equipment = {
    id = "relic_equipment",
    greeting = "Welcome to my relic shop!",
    farewell = "Come back anytime for quality gear!",
    categories = {
        {
            name = "Weapons",
            items = {
                { itemId = 16482, price = 1000, stock = -1 }, -- Bronze Sword
                { itemId = 16640, price = 2500, stock = -1 }, -- Mythril Sword
                { itemId = 17440, price = 500,  stock = -1 }, -- Bronze Dagger
                { itemId = 17600, price = 1200, stock = -1 }, -- Mythril Dagger
                { itemId = 17024, price = 800,  stock = -1 }, -- Ash Club
                { itemId = 17152, price = 1800, stock = -1 }, -- Oak Staff
            }
        },
        {
            name = "Armor",
            items = {
                { itemId = 12416, price = 800,  stock = -1 }, -- Leather Vest
                { itemId = 12544, price = 1500, stock = -1 }, -- Chain Hauberk
                { itemId = 12672, price = 400,  stock = -1 }, -- Leather Gloves
                { itemId = 12800, price = 700,  stock = -1 }, -- Chain Mittens
                { itemId = 12928, price = 600,  stock = -1 }, -- Leather Trousers
                { itemId = 13056, price = 300,  stock = -1 }, -- Leather Boots
            }
        },
        {
            name = "Accessories",
            items = {
                { itemId = 13446, price = 2000, stock = -1 }, -- Brass Ring
                { itemId = 13447, price = 3000, stock = -1 }, -- Silver Ring
                { itemId = 15516, price = 1500, stock = -1 }, -- Leather Gorget
                { itemId = 15517, price = 2500, stock = -1 }, -- Chain Gorget
            }
        }
    }
}

-- Consumables Shop
shopConfigs.consumables = {
    id = "consumables",
    greeting = "Need supplies for your adventures?",
    farewell = "Stay safe out there!",
    categories = {
        {
            name = "Healing Items",
            items = {
                { itemId = 4112, price = 12,   stock = -1 }, -- Potion
                { itemId = 4128, price = 40,   stock = -1 }, -- Hi-Potion
                { itemId = 4144, price = 8,    stock = -1 }, -- Ether
                { itemId = 4160, price = 25,   stock = -1 }, -- Hi-Ether
                { itemId = 4176, price = 100,  stock = -1 }, -- X-Potion
            }
        },
        {
            name = "Food & Drinks",
            items = {
                { itemId = 4361, price = 5,    stock = -1 }, -- Orange Juice
                { itemId = 4362, price = 8,    stock = -1 }, -- Apple Juice
                { itemId = 4445, price = 15,   stock = -1 }, -- Meat Jerky
                { itemId = 4446, price = 20,   stock = -1 }, -- Fish Jerky
                { itemId = 4509, price = 12,   stock = -1 }, -- Roasted Corn
            }
        },
        {
            name = "Tools & Utilities",
            items = {
                { itemId = 1024, price = 50,   stock = -1 }, -- Pickaxe
                { itemId = 1025, price = 75,   stock = -1 }, -- Hatchet
                { itemId = 1027, price = 25,   stock = -1 }, -- Sickle
                { itemId = 305,  price = 100,  stock = -1 }, -- Chocobo Whistle
            }
        }
    }
}

-- Crafting Materials Shop
shopConfigs.materials = {
    id = "materials",
    greeting = "Looking for quality crafting materials?",
    farewell = "Good luck with your crafting!",
    categories = {
        {
            name = "Ores & Metals",
            items = {
                { itemId = 644,  price = 50,   stock = -1 }, -- Copper Ore
                { itemId = 645,  price = 100,  stock = -1 }, -- Iron Ore
                { itemId = 646,  price = 200,  stock = -1 }, -- Silver Ore
                { itemId = 647,  price = 500,  stock = -1 }, -- Mythril Ore
                { itemId = 651,  price = 25,   stock = -1 }, -- Tin Ore
            }
        },
        {
            name = "Cloths & Leathers",
            items = {
                { itemId = 700,  price = 75,   stock = -1 }, -- Wool Cloth
                { itemId = 704,  price = 150,  stock = -1 }, -- Silk Cloth
                { itemId = 850,  price = 100,  stock = -1 }, -- Sheep Leather
                { itemId = 851,  price = 200,  stock = -1 }, -- Dhalmel Leather
                { itemId = 852,  price = 300,  stock = -1 }, -- Tiger Leather
            }
        },
        {
            name = "Crystals",
            items = {
                { itemId = 4096, price = 50,   stock = -1 }, -- Fire Crystal
                { itemId = 4097, price = 50,   stock = -1 }, -- Ice Crystal
                { itemId = 4098, price = 50,   stock = -1 }, -- Wind Crystal
                { itemId = 4099, price = 50,   stock = -1 }, -- Earth Crystal
                { itemId = 4100, price = 50,   stock = -1 }, -- Lightning Crystal
                { itemId = 4101, price = 50,   stock = -1 }, -- Water Crystal
                { itemId = 4102, price = 50,   stock = -1 }, -- Light Crystal
                { itemId = 4103, price = 50,   stock = -1 }, -- Dark Crystal
            }
        }
    }
}

-- Rare/Special Items Shop (with limited stock)
shopConfigs.rare_items = {
    id = "rare_items",
    greeting = "I deal in rare and special items...",
    farewell = "These items won't last long!",
    categories = {
        {
            name = "Items",
            items = {
                { itemId = 875, price = 1 }, -- Amaltheia Leather
                { itemId = 668, price = 1 }, -- Orichalcum Sheet
                { itemId = 720, price = 1 }, -- Ancient Lumber
                { itemId = 12301, price = 1 }, -- Buckler
                { itemId = 12295, price = 1 }, -- Round Shield
                { itemId = 12387, price = 1 }, -- Koenig Shield
                { itemId = 1821, price = 1 }, -- Attestation of Invulnerability
                { itemId = 1589, price = 1 }, -- Necropsyche
                { itemId = 1822, price = 1 }, -- Supernal Fragment
            }
        },
        {
            name = "Base Weapon",
            items = {
                { itemId = 18260, price = 1 }, -- Relic Knucles
                { itemId = 18266, price = 1 }, -- Relic Dagger
                { itemId = 18272, price = 1 }, -- Relic Sword
                { itemId = 18278, price = 1 }, -- Relic Blade
                { itemId = 18284, price = 1 }, -- Relic Axe
                { itemId = 18290, price = 1 }, -- Relic Bhuj
                { itemId = 18296, price = 1 }, -- Relic Lance
                { itemId = 18302, price = 1 }, -- Relic Scythe
                { itemId = 18308, price = 1 }, -- Ihintanto
                { itemId = 18314, price = 1 }, -- Ito
                { itemId = 18320, price = 1 }, -- Relic Maul
                { itemId = 18326, price = 1 }, -- Relic Staff
                { itemId = 18332, price = 1 }, -- Relic Gun
                { itemId = 18338, price = 1 }, -- Relic Horn
                { itemId = 18344, price = 1 }, -- Relic Bow
                { itemId = 15066, price = 1 }, -- Relic Shield
            }
        },
        {
            name = "Currency",
            items = {
                { itemId = 1455, price = 1 }, -- One Byne Bill
                { itemId = 1456, price = 1 }, -- One Hundred Byne Bill
                { itemId = 1457, price = 1 }, -- Ten Thousand Byne Bill
                { itemId = 1449, price = 1 }, -- Tukuku Whiteshell
                { itemId = 1450, price = 1 }, -- Lungo Nango Jadeshell
                { itemId = 1451, price = 1 }, -- Rimilala Stripeshell
                { itemId = 1452, price = 1 }, -- Ordelle Bronzepiece
                { itemId = 1453, price = 1 }, -- Montiont Silverpiece
                { itemId = 1454, price = 1 }, -- Ranperre Goldpiece
            }
        }
    }
}
return shopConfigs
