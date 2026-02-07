local fixedScale = 1.3
local manualToggle = false 


local function InitSettings()
    if not ABG_Settings then
        ABG_Settings = { angle = 180, posX = 0, posY = 0, shown = false }
    end
end


local frame = CreateFrame("Frame", "AscensionBGMapFrame", UIParent)
frame:SetSize(288, 192) 
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:Hide()

frame:SetBackdrop({
    edgeFile = "Interface\\Buttons\\WHITE8X8", 
    edgeSize = 8, 
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
})
frame:SetBackdropBorderColor(0, 0, 0, 1) 
frame:SetBackdropColor(0, 0, 0, 0) 

local header = CreateFrame("Frame", nil, frame)
header:SetHeight(25)
header:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)
header:EnableMouse(true)
header:RegisterForDrag("LeftButton")
local headerTex = header:CreateTexture(nil, "BACKGROUND")
headerTex:SetAllPoints(); headerTex:SetTexture(0, 0, 0, 1) 

header:SetScript("OnDragStart", function() frame:StartMoving() end)
header:SetScript("OnDragStop", function() 
    frame:StopMovingOrSizing() 
    local _, _, _, x, y = frame:GetPoint()
    ABG_Settings.posX = x; ABG_Settings.posY = y
end)

local locationText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
locationText:SetPoint("CENTER", header, "CENTER", 0, 0)
locationText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") 

local function ForceShowMap()
    if not IsAddOnLoaded("Blizzard_BattlefieldMinimap") then
        LoadAddOn("Blizzard_BattlefieldMinimap")
    end
    
    if BattlefieldMinimap then
        BattlefieldMinimap:Show()
        BattlefieldMinimap:SetParent(frame)
        BattlefieldMinimap:ClearAllPoints()
        BattlefieldMinimap:SetPoint("CENTER", frame, "CENTER", 3, 0)
        BattlefieldMinimap:SetScale(fixedScale)
        
        if BattlefieldMinimapBackground then BattlefieldMinimapBackground:Hide() end
        if BattlefieldMinimapCloseButton then BattlefieldMinimapCloseButton:Hide() end
        if BattlefieldMinimapCorner then BattlefieldMinimapCorner:Hide() end
    end
end


local lastUpdate = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate > 0.2 then
        local _, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then
            if not frame:IsShown() then 
                frame:Show() 
            end
            if BattlefieldMinimap and not BattlefieldMinimap:IsShown() then
                ForceShowMap()
            end
            manualToggle = false
        elseif (instanceType == "party" or instanceType == "raid") and not manualToggle then
            frame:Hide()
            manualToggle = true 
        end

        local loc = GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()
        locationText:SetText(loc ~= "" and loc or "Battleground")
        lastUpdate = 0
    end
end)

hooksecurefunc("ToggleBattlefieldMinimap", function()
    if BattlefieldMinimap and BattlefieldMinimap:IsShown() then
        frame:Show()
        ForceShowMap()
    else
        local _, instanceType = GetInstanceInfo()
        if instanceType ~= "pvp" then frame:Hide() end
    end
end)

local function GetBGStatus()
    local zone = GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText()
    local count = 0
    local numGroup = GetNumRaidMembers()
    for i = 1, (numGroup > 0 and numGroup or GetNumPartyMembers()) do
        local unit = (numGroup > 0 and "raid" or "party")..i
        if not UnitIsUnit(unit, "player") and UnitIsVisible(unit) and CheckInteractDistance(unit, 4) then
            count = count + 1
        end
    end
    return (zone ~= "" and zone or "Base"), count
end

local function SendIncom(enemies, isClear)
    local loc, allies = GetBGStatus()
    local tag = "[ABH] " 
    
    local msg = isClear and (tag .. "CLEAR " .. loc .. " - Allies: " .. allies) 
                         or (tag .. "INC " .. enemies .. " " .. loc .. " - Allies: " .. allies)
                         
    local _, instanceType = GetInstanceInfo()
    local chatType = (instanceType == "pvp") and "BATTLEGROUND" or (UnitInRaid("player") and "RAID" or "SAY")
    SendChatMessage(msg, chatType)
end

local function CreateCustomButton(name, parent, width, height, text, xOff)
    local btn = CreateFrame("Button", name, parent)
    btn:SetSize(width, height)
    btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", xOff, 0)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetTexture(0, 0, 0, 1)
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnText:SetPoint("CENTER"); btnText:SetText(text); btnText:SetTextColor(1, 1, 1, 1)
    btnText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE") 
    btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    btn:GetPushedTexture():SetBlendMode("ADD")
    btn:SetScript("OnMouseDown", function() PlaySound("igMainMenuOptionCheckBoxOn") end)
    return btn
end

for i = 1, 5 do
    local btn = CreateCustomButton("ABGBtn"..i, frame, 40, 20, "+"..i, (i-1)*41)
    btn:SetScript("OnClick", function() SendIncom(i, false) end)
end
local clearBtn = CreateCustomButton("ABGClearBtn", frame, 65, 20, "CLEAR", 223)
clearBtn:SetScript("OnClick", function() SendIncom(0, true) end)


--------------------------------------МИНИМАП КНОПКА------------------------------------------------


local MiniBtn = CreateFrame("Button", "ABGMinimapButton", Minimap)
MiniBtn:SetSize(32, 32); MiniBtn:SetFrameLevel(8); MiniBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local MiniTex = MiniBtn:CreateTexture(nil, "BACKGROUND")
local faction = UnitFactionGroup("player")
if faction == "Horde" then
    MiniTex:SetTexture("Interface\\Icons\\Achievement_PVP_H_01")
elseif faction == "Alliance" then
    MiniTex:SetTexture("Interface\\Icons\\Achievement_PVP_A_01")
else
    -- Для Ренегатов или нейтралов ставим мечи
    MiniTex:SetTexture("Interface\\Icons\\Ability_Warrior_OffensiveStance")
end

MiniTex:SetSize(20, 20); MiniTex:SetPoint("CENTER")
MiniTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local MiniBorder = MiniBtn:CreateTexture(nil, "OVERLAY"); MiniBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); MiniBorder:SetSize(52, 52); MiniBorder:SetPoint("TOPLEFT")
local function UpdateMapPos() MiniBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(ABG_Settings.angle)), (80 * sin(ABG_Settings.angle)) - 52) end

MiniBtn:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", function()
    local x, y = GetCursorPosition(); local mx, my = Minimap:GetCenter()
    ABG_Settings.angle = math.deg(math.atan2(y/Minimap:GetEffectiveScale() - my, x/Minimap:GetEffectiveScale() - mx)); UpdateMapPos()
end) end)
MiniBtn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
MiniBtn:RegisterForDrag("LeftButton")
MiniBtn:SetScript("OnClick", function() 
    if frame:IsShown() then 
        frame:Hide() 
        manualToggle = true 
    else 
        frame:Show() 
        ForceShowMap() 
        manualToggle = false 
    end 
end)


local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Abh" then
        InitSettings()
        frame:ClearAllPoints(); frame:SetPoint("CENTER", UIParent, "CENTER", ABG_Settings.posX, ABG_Settings.posY)
        UpdateMapPos()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local _, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then ForceShowMap() end
    end
end)









--------------------------------------ТАЙМЕРЫ + ФЛАГОНОСЦЫ----------------------------------------------------

local ALLIANCE_BUFF_ID = 86475 
local HORDE_BUFF_ID = 86476   

local ABG_Timers = {}
local ABG_Carriers = { Alliance = nil, Horde = nil }
local TIMER_DURATION = 60 

local NodeSettings = {
    ["stables"]      = { x = -33, y = 68, name = "" },
    ["farm"]         = { x = 52,  y = -7, name = "" },
    ["blacksmith"]   = { x = 15,    y = 22,   name = "" },
    ["lumber mill"]  = { x = -64,  y = -18, name = "" },
    ["gold mine"]    = { x = 41,   y = 61,  name = "" },
    ["mine"]         = { x = 41,   y = 61,  name = "" },

    ["fel orc village"] = { x = -70, y = 40,  name = "ORC" },
    ["blood elf tower"] = { x = 70,  y = 40,  name = "BE" },
    ["draenei ruins"]   = { x = -70, y = -40, name = "DR" },
    ["mage tower"]      = { x = 70,  y = -40, name = "MT" },
}

local carrierParent = CreateFrame("Frame", "ABG_CarrierContainer", header)
carrierParent:SetPoint("BOTTOM", header, "TOP", 0, 5)
carrierParent:SetSize(288, 30)

local function GetClassColorText(name)
    if not name then return "" end
    
    local classTag
    for i = 1, GetNumBattlefieldScores() do
        local n, _, _, _, _, _, _, _, _, class = GetBattlefieldScore(i)
        if n and n:match("([^%-]+)") == name:match("([^%-]+)") then
            classTag = class
            break
        end
    end

    if not classTag then
        _, classTag = UnitClass(name)
    end

    if classTag then
        local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classTag]
        if color then
            return string.format("|cff%02x%02x%02x%s|r", color.r*255, color.g*255, color.b*255, name)
        end
    end
    return name
end
----------------------------------------------------------------------------------------------------------

local function PrepareBtn(name)
    local btn = CreateFrame("Button", name, carrierParent, "SecureActionButtonTemplate")
    btn:SetAttribute("type", "target")
    btn:SetSize(140, 30)
    btn:SetFrameStrata("TOOLTIP")
    btn:SetFrameLevel(130)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")
    
    local t = btn:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints()
    t:SetTexture(0, 0, 0, 0)
    btn.tex = t
    return btn
end

local btnAlly = PrepareBtn("ABG_CarrierBtnAlly")
local btnHorde = PrepareBtn("ABG_CarrierBtnHorde")

btnAlly:SetPoint("RIGHT", carrierParent, "CENTER", -2, -5)
btnHorde:SetPoint("LEFT", carrierParent, "CENTER", 2, -5)

local function UpdateCarriers()
    local text = ""
    local nowAlly = ABG_Carriers.Alliance
    local nowHorde = ABG_Carriers.Horde

    if not carrierParent.text then
        carrierParent.text = carrierParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        carrierParent.text:SetPoint("BOTTOM", carrierParent, "BOTTOM", 0, 0)
        carrierParent.text:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    end

    if nowAlly then text = text .. "|cff0070dd[Ally]:|r " .. GetClassColorText(nowAlly) .. "  " end
    if nowHorde then text = text .. "|cffff0000[Horde]:|r " .. GetClassColorText(nowHorde) end
    carrierParent.text:SetText(text)

    if not InCombatLockdown() then
        if nowAlly and frame:IsShown() then
            btnAlly:SetAttribute("unit", nowAlly)
            btnAlly:Show()
        else
            btnAlly:Hide()
        end

        if nowHorde and frame:IsShown() then
            btnHorde:SetAttribute("unit", nowHorde)
            btnHorde:Show()
        else
            btnHorde:Hide()
        end
    end
end

local combatFix = CreateFrame("Frame")
combatFix:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFix:SetScript("OnEvent", function()
    UpdateCarriers()
end)



-----------------------------------------------------------------------------------

local function CreateNodeTimer(id)
    local config = NodeSettings[id] or {x = 0, y = 0, name = ""}
    local f = CreateFrame("Frame", nil, frame)
    f:SetSize(80, 20)
    f:SetPoint("CENTER", frame, "CENTER", config.x, config.y)
    local txt = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txt:SetPoint("CENTER")
    txt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") 
    f.txt, f.nodeDisplayName, f.startTime, f.baseColor = txt, config.name, 0, "|cffffffff"
    f:Hide()
    return f
end

for id in pairs(NodeSettings) do ABG_Timers[id] = CreateNodeTimer(id) end

local function HandleBGEvent(msg)
    if not msg or type(msg) ~= "string" then return end
    local lowMsg = msg:lower()
    local isPlayerAlliance = UnitBuff("player", (GetSpellInfo(ALLIANCE_BUFF_ID)))
    
    for n, f in pairs(ABG_Timers) do
        if lowMsg:find(n) then
            if lowMsg:find("assaulted") then
                local cracker = msg:match("^([^%s]+) has assaulted")
                local isAllyAction = (cracker and (UnitInRaid(cracker) or UnitInParty(cracker) or cracker == UnitName("player"))) or lowMsg:find("alliance")
                local finalColor = isAllyAction and (isPlayerAlliance and "|cff0070dd" or "|cffff0000") or (isPlayerAlliance and "|cffff0000" or "|cff0070dd")
                if lowMsg:find("alliance") then finalColor = "|cff0070dd" elseif lowMsg:find("horde") then finalColor = "|cffff0000" end
                f.baseColor = finalColor
                f.startTime = GetTime()
                f:Show()
            elseif lowMsg:find("defended") or lowMsg:find("taken") or lowMsg:find("captured") or lowMsg:find("claims") or lowMsg:find("control") then
                f:Hide()
            end
        end
    end

    if (lowMsg:find("picked up") or lowMsg:find("took")) and lowMsg:find("flag") then
        local flagSide = lowMsg:find("alliance") and "Alliance" or "Horde"
        local carrier = msg:match("by ([^!%.]+)") or "Unknown"
        ABG_Carriers[flagSide] = carrier:trim(); UpdateCarriers()
    elseif lowMsg:find("captured") or lowMsg:find("returned") or lowMsg:find("dropped") or lowMsg:find("placed") then
        local flagSide = lowMsg:find("alliance") and "Alliance" or "Horde"
        ABG_Carriers[flagSide] = nil; UpdateCarriers()
    end
end

frame:HookScript("OnUpdate", function(self, elapsed)
    local now = GetTime()
    for id, f in pairs(ABG_Timers) do
        if f:IsShown() then
            local timeLeft = TIMER_DURATION - (now - f.startTime)
            if timeLeft <= 0 then f:Hide()
            else f.txt:SetText(string.format("%s%s %d|r", f.baseColor, f.nodeDisplayName, math.ceil(timeLeft))) end
        end
    end
end)

local eventFrameFinal = CreateFrame("Frame")
eventFrameFinal:RegisterEvent("ADDON_LOADED")
eventFrameFinal:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrameFinal:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
eventFrameFinal:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
eventFrameFinal:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
eventFrameFinal:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
eventFrameFinal:RegisterEvent("CHAT_MSG_SYSTEM")

eventFrameFinal:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "Abh" then
        InitSettings()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", ABG_Settings.posX, ABG_Settings.posY)
        UpdateMapPos()
        
        local _, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then
            frame:Show()
            ForceShowMap()
        else
            frame:Hide()
            if BattlefieldMinimap then BattlefieldMinimap:Hide() end
        end
        
        if BattlefieldMinimap then BattlefieldMinimap:EnableMouse(false) end
    elseif event == "PLAYER_ENTERING_WORLD" then
        manualToggle = false 
        
        local _, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then 
            frame:Show()
            ForceShowMap() 
        else
            frame:Hide()
            if BattlefieldMinimap then BattlefieldMinimap:Hide() end
        end

        for k, v in pairs(ABG_Timers) do v:Hide() end
        ABG_Carriers = { Alliance = nil, Horde = nil }
        UpdateCarriers()
    elseif arg1 then
        HandleBGEvent(arg1)
    end
end)



--------------------------------------------- не трогать!

--[[local debugCoord = CreateFrame("Frame", nil, header)
debugCoord:SetAllPoints(header)
debugCoord.text = debugCoord:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
debugCoord.text:SetPoint("BOTTOM", header, "TOP", 0, 10)
debugCoord.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
debugCoord.text:SetTextColor(0, 1, 0) 

debugCoord:SetScript("OnUpdate", function()
    if frame:IsMouseOver() then
        local x, y = GetCursorPosition()
        local s = frame:GetEffectiveScale()
        local cx, cy = frame:GetCenter()
        local curX = (x / s) - cx
        local curY = (y / s) - cy
        debugCoord.text:SetText(string.format("X: %.0f | Y: %.0f", curX, curY))
    else
        debugCoord.text:SetText("Наведи на карту")
    end
end)]]



local function BlockMapToggle()
    local _, instanceType = GetInstanceInfo()
    if instanceType == "pvp" then
        return true
    end
end

local originalToggle = ToggleBattlefieldMinimap
function ToggleBattlefieldMinimap()
    local _, instanceType = GetInstanceInfo()
    if instanceType == "pvp" then
        if not BattlefieldMinimap:IsShown() then
            ForceShowMap()
        end
        return 
    end
    originalToggle()
end

if BattlefieldMinimapCloseButton then
    BattlefieldMinimapCloseButton:HookScript("OnClick", function()
        local _, instanceType = GetInstanceInfo()
        if instanceType == "pvp" then
            ForceShowMap()
        end
    end)
end