local afkPlayers = {}

-- Function to check if a player is AFK
function isPlayerAFK(player)
    if afkPlayers[player] then
        return true
    else
        return false
    end
end

-- Function to reset AFK status when a player moves or interacts
function resetAFKStatus(player)
    if afkPlayers[player] then
        afkPlayers[player] = nil
    end
end

-- Set the AFK timeout duration in seconds
local afkTimeout = 300 -- 5 minutes (adjust as needed)

-- Main anti-AFK function
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second

        for _, player in ipairs(GetPlayers()) do
            local source = tonumber(player)

            if not IsPlayerDead(source) then
                local ped = GetPlayerPed(-1)

                local x, y, z = table.unpack(GetEntityCoords(ped, false))

                if not afkPlayers[source] then
                    afkPlayers[source] = { x = x, y = y, z = z, time = GetGameTimer() }
                else
                    local currentTime = GetGameTimer()
                    local lastPosition = afkPlayers[source]

                    local distance = Vdist(x, y, z, lastPosition.x, lastPosition.y, lastPosition.z)

                    if distance > 1.0 then
                        resetAFKStatus(source)
                    elseif currentTime - lastPosition.time > (afkTimeout * 1000) then
                        -- Perform anti-AFK action (e.g., kick the player)
                        DropPlayer(source, "You were kicked for being AFK.")
                    end
                end
            end
        end
    end
end)