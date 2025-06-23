-----------------------------------
-- Production Shop NPC Core - Safer Pattern with Direct Page References
-- File: modules/custom/lua/npc_shop_core.lua
-----------------------------------

local shopCore = {}

-- Create a shop NPC following the exact working pattern with direct page references
function shopCore.createShopNPC(shopData)
    -- Declare menu at function level like working example
    local menu = {
        title = shopData.greeting or "Welcome to my shop!",
        options = {},
    }
    
    local mainPage = {}
    
    -- Create delay function exactly like working example
    local delaySendMenu = function(player)
        printf("[SHOP DEBUG] delaySendMenu called - menu has %d options", #menu.options)
        player:timer(50, function(playerArg)
            printf("[SHOP DEBUG] Timer executing - menu still has %d options", #menu.options)
            playerArg:customMenu(menu)
        end)
    end
    
    -- Store all pages as direct variables to avoid nested table lookups
    local allPages = {}
    
    -- Build main page first
    for i, category in ipairs(shopData.categories) do
        table.insert(mainPage, {
            category.name,
            function(playerArg)
                printf("[SHOP] Category selected: %s", category.name)
                -- Get the first page for this category
                local firstPageKey = "cat" .. i .. "_page1"
                printf("[SHOP DEBUG] Looking for page key: %s", firstPageKey)
                local firstPage = allPages[firstPageKey]
                if firstPage then
                    printf("[SHOP DEBUG] Found page with %d options", #firstPage)
                    -- Debug the page contents
                    for j, option in ipairs(firstPage) do
                        printf("[SHOP DEBUG] Option %d: %s", j, option[1])
                    end
                    menu.options = firstPage
                    delaySendMenu(playerArg)
                else
                    printf("[SHOP ERROR] First page not found for category %d, key: %s", i, firstPageKey)
                    -- Debug what keys we actually have
                    printf("[SHOP DEBUG] Available page keys:")
                    for key, _ in pairs(allPages) do
                        printf("[SHOP DEBUG] - %s", key)
                    end
                end
            end,
        })
    end
    
    -- Add exit option to main page
    table.insert(mainPage, {
        "Leave",
        function(playerArg)
            playerArg:printToPlayer(shopData.farewell or "Thank you for visiting!")
        end,
    })
    
    -- Build category pages with 4 items per page maximum
    for catIndex, category in ipairs(shopData.categories) do
        local itemsPerPage = 4 -- Maximum 4 items per page for reliable display
        local totalItems = #category.items
        local totalPages = math.ceil(totalItems / itemsPerPage)
        
        printf("[SHOP DEBUG] Category %d (%s): %d items, %d pages", catIndex, category.name, totalItems, totalPages)
        
        -- Create pages for this category
        for pageNum = 1, totalPages do
            local startIndex = (pageNum - 1) * itemsPerPage + 1
            local endIndex = math.min(startIndex + itemsPerPage - 1, totalItems)
            
            printf("[SHOP DEBUG] Creating page %d for category %d: items %d-%d", pageNum, catIndex, startIndex, endIndex)
            
            local page = {}
            local pageKey = "cat" .. catIndex .. "_page" .. pageNum
            
            -- Add items for this page
            for i = startIndex, endIndex do
                local item = category.items[i]
                local itemName = string.format("Item %d", item.itemId)
                
                -- Get item name safely
                local success, itemObj = pcall(GetItemByID, item.itemId)
                if success and itemObj then
                    itemName = itemObj:getName()
                end
                
                local price = item.price or 0
                local optionText = string.format("%s - %d gil", itemName, price)
                
                table.insert(page, {
                    optionText,
                    function(playerArg)
                        printf("[SHOP] Item selected: %s (ID: %d)", itemName, item.itemId)
                        
                        -- Process purchase inline to avoid table reference issues
                        local playerGil = playerArg:getGil()
                        
                        -- Check gil
                        if playerGil < price then
                            playerArg:printToPlayer(string.format("You need %d gil but only have %d gil.", price, playerGil))
                            -- Stay on same page
                            menu.options = page
                            delaySendMenu(playerArg)
                            return
                        end
                        
                        -- Check inventory space
                        if playerArg:getFreeSlotsCount() == 0 then
                            playerArg:printToPlayer("Your inventory is full!")
                            -- Stay on same page
                            menu.options = page
                            delaySendMenu(playerArg)
                            return
                        end
                        
                        -- Process purchase
                        playerArg:delGil(price)
                        playerArg:addItem(item.itemId)
                        
                        playerArg:printToPlayer(string.format("You purchased %s for %d gil!", itemName, price))
                        printf("[SHOP] Purchase completed: %s bought %s for %d gil", playerArg:getName(), itemName, price)
                        
                        -- Stay on same page
                        menu.options = page
                        delaySendMenu(playerArg)
                    end,
                })
            end
            
            printf("[SHOP DEBUG] Added %d items to page %d", endIndex - startIndex + 1, pageNum)
            
            -- Add navigation - Previous Page (only if not page 1)
            if pageNum > 1 then
                printf("[SHOP DEBUG] Adding Previous Page to page %d", pageNum)
                local prevPageKey = "cat" .. catIndex .. "_page" .. (pageNum - 1)
                table.insert(page, {
                    "Previous Page",
                    function(playerArg)
                        local prevPage = allPages[prevPageKey]
                        if prevPage then
                            menu.options = prevPage
                            delaySendMenu(playerArg)
                        else
                            printf("[SHOP ERROR] Previous page not found: %s", prevPageKey)
                        end
                    end,
                })
            end
            
            -- Add navigation - Next Page (only if not last page)
            if pageNum < totalPages then
                printf("[SHOP DEBUG] Adding Next Page to page %d (total pages: %d)", pageNum, totalPages)
                local nextPageKey = "cat" .. catIndex .. "_page" .. (pageNum + 1)
                table.insert(page, {
                    "Next Page",
                    function(playerArg)
                        local nextPage = allPages[nextPageKey]
                        if nextPage then
                            menu.options = nextPage
                            delaySendMenu(playerArg)
                        else
                            printf("[SHOP ERROR] Next page not found: %s", nextPageKey)
                        end
                    end,
                })
            end
            
            -- Add back to categories
            printf("[SHOP DEBUG] Adding Back to Categories to page %d", pageNum)
            table.insert(page, {
                "Back to Categories",
                function(playerArg)
                    menu.options = mainPage
                    delaySendMenu(playerArg)
                end,
            })
            
            printf("[SHOP DEBUG] Final page %d has %d options total", pageNum, #page)
            
            -- Store the page with a simple key
            allPages[pageKey] = page
            printf("[SHOP DEBUG] Stored page with key: %s", pageKey)
        end
    end
    
    -- Return NPC behavior functions
    return {
        onTrade = function(player, npc, trade)
            player:printToPlayer("I'm not interested in trades right now.")
        end,
        
        onTrigger = function(player, npc)
            printf("[SHOP] NPC triggered by player %s", player:getName())
            menu.options = mainPage
            delaySendMenu(player)
        end,
        
        onEventUpdate = function(player, csid, option, npc)
            -- Not used with customMenu
        end,
        
        onEventFinish = function(player, csid, option, npc)
            -- Not used with customMenu
        end
    }
end

return shopCore
