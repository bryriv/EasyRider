-- EasyRider
-- BryRiv
-- © 2022. This work is licensed under a CC BY-NC-SA 4.0 license. 

----------------------------------------------------------
local EasyRider = {}
EasyRider.version = "1.0"

EasyRider.frame = CreateFrame("FRAME")
EasyRider.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
EasyRider.frame:RegisterEvent("PLAYER_LOGIN")
EasyRider.frame:RegisterEvent("PLAYER_LOGOUT")

EasyRider.useAllMounts = false
EasyRider.prefix = "|c00508ecc[Easy Rider] |cFFe3c564"

local filterType = {
    ground = { index = 1, checked = true },
    flying = { index = 2, checked = true },
    aquatic = { index = 3, checked = false }
}

EasyRider.dismount = function()
    C_MountJournal.Dismiss()
end

EasyRider.mountUp = function()

    if EasyRiderVars.srcMode == "all" then
        EasyRider.useAllMounts = true
    end

    local actionMessage
    if IsSubmerged() then
        filterType.ground.checked = false
        filterType.flying.checked = false
        filterType.aquatic.checked = true
        actionMessage = "Let's swim, I guess!?"
    elseif IsFlyableArea() then
        filterType.ground.checked = false
        filterType.flying.checked = true
        filterType.aquatic.checked = false
        actionMessage = "Let's fly!"
    else
        filterType.ground.checked = true
        filterType.flying.checked = false
        filterType.aquatic.checked = false
        actionMessage = "Screw it, let's just run."
    end

    C_MountJournal.SetAllSourceFilters(true)
    C_MountJournal.SetTypeFilter(filterType.ground.index, filterType.ground.checked)
    C_MountJournal.SetTypeFilter(filterType.flying.index, filterType.flying.checked)
    C_MountJournal.SetTypeFilter(filterType.aquatic.index, filterType.aquatic.checked)
    C_MountJournal.SetCollectedFilterSetting(1, true)
    C_MountJournal.SetCollectedFilterSetting(2, false)
    C_MountJournal.SetSearch('')

    local numMounts = C_MountJournal.GetNumDisplayedMounts()
    local myMounts = {}

    for n = 1, numMounts do
        local mountName, _, _, _, _, _, isFavorite, _, _, _, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(n)
        local usable, _ = C_MountJournal.GetMountUsabilityByID(mountID, true)

        if isCollected and usable and (isFavorite or EasyRider.useAllMounts) then
            myMounts[#myMounts + 1] = {
                name = mountName,
                id = mountID
            }
        end
    end

    if #myMounts == 0 then
        EasyRider.out("Seems like mounting not allowed here. Sorry.")
    else
        local mount_idx = fastrandom(#myMounts)
        if not EasyRiderVars.quiet then
            EasyRider.out(actionMessage)
            EasyRider.out("Mounting up on " .. myMounts[mount_idx].name)
            local _, desc = C_MountJournal.GetMountInfoExtraByID(myMounts[mount_idx].id)
            EasyRider.out("|c00889D9D<"..desc..">")
        end
        C_MountJournal.SummonByID(myMounts[mount_idx].id)
    end

end

EasyRider.out = function(msg)
    if not msg then return end
    if not EasyRider.quiet then
        ChatFrame1:AddMessage(EasyRider.prefix .. msg)
    end
end

EasyRider.cmdHandler = function(opt)

    local cmdColor = "|cFFe3c564";

    if opt == "all" then
        EasyRider.useAllMounts = true
        EasyRiderVars.srcMode = "all"
        EasyRider.out(cmdColor.."Set source to all mounts.")
    elseif opt == "favs" then
        EasyRider.useAllMounts = false
        EasyRiderVars.srcMode = "favs"
        EasyRider.out(cmdColor.."Set source to favorite mounts")
    elseif opt == "src" then
        EasyRider.out(cmdColor.."Source currently set to " .. EasyRiderVars.srcMode)
    elseif opt == "quiet" then
        EasyRider.out(cmdColor.."EasyRider shutting up")
        EasyRiderVars.quiet = true
    elseif opt == "chatty" then
        EasyRiderVars.quiet = false
        EasyRider.out(cmdColor.."EasyRider chatty info enabled")
    elseif IsMounted() and not IsFlying() then
        EasyRider.dismount()
    elseif IsMounted() and  IsFlying() then
        EasyRider.out(cmdColor.."No dismounting in the air, fool!")
    else
        EasyRider.mountUp()
    end

end

EasyRider.eventHandler = function(self, event, arg)

    if event == "PLAYER_ENTERING_WORLD" then

        if EasyRiderVars == nil then
            EasyRiderVars = {
                srcMode = 'favs',
                quiet = false
            }
        end

        local initPrefix = "|cFFe3c564[Init] "
        if EasyRiderVars.srcMode == nil then
            EasyRider.out(initPrefix.."Source Mode is not set, defaulting to 'favs'.");
            EasyRiderVars.srcMode = "favs";
        end
        EasyRider.out(initPrefix.."Source Mode set to " .. EasyRiderVars.srcMode)

        if EasyRiderVars.quiet == nil then
            EasyRiderVars.quiet = false
        elseif EasyRiderVars.quiet then
            EasyRider.out(initPrefix.."Shutting up now.");
        end

        EasyRider.frame:UnregisterEvent("PLAYER_ENTERING_WORLD")

    end

end

EasyRider.frame:SetScript("OnEvent", EasyRider.eventHandler);

SLASH_EASYRIDER1 = "/easyrider"
SlashCmdList["EASYRIDER"] = EasyRider.cmdHandler
