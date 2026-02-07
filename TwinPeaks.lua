local frame = AscensionBGMapFrame
local activeTPNode = nil

local ABG_TPCoords = {
    ["alliance"] = { x = 32, y = 61,  name = "ALLIANCE BASE" },
    ["horde"]    = { x = -1,  y = -63, name = "HORDE BASE" },
}

local ABG_TPMenu = CreateFrame("Frame", "ABG_TPContextMenu", UIParent)
ABG_TPMenu:SetSize(100, 185) 
ABG_TPMenu:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
})
ABG_TPMenu:SetBackdropColor(0, 0, 0, 0.9)
ABG_TPMenu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
ABG_TPMenu:SetFrameStrata("TOOLTIP")
ABG_TPMenu:SetFrameLevel(151)
ABG_TPMenu:Hide()

local function SendTPAnnounce(msgType, count)
    local msg = ""
    local tag = "[ABH] "

    if msgType == "TAKE" then
        msg = tag .. "I'LL TAKE THE FLAG!"
    elseif not activeTPNode then return 
    elseif msgType == "INC" then
        msg = tag .. "INC " .. count .. " " .. activeTPNode:upper()
    elseif msgType == "DEFF" then
        msg = tag .. activeTPNode:upper() .. " - GUARD NEEDED!"
    elseif msgType == "ATTACK" then
        msg = tag .. activeTPNode:upper() .. " - ATTACK!"
    end
    
    local chatType = (select(2, GetInstanceInfo()) == "pvp") and "BATTLEGROUND" or "SAY"
    SendChatMessage(msg, chatType)
    ABG_TPMenu:Hide()
end


local takeBtn = CreateFrame("Button", nil, ABG_TPMenu)
takeBtn:SetSize(90, 18); takeBtn:SetPoint("TOP", ABG_TPMenu, "TOP", 0, -5)
local tt = takeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tt:SetPoint("CENTER"); tt:SetText("TAKE FLAG"); tt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); tt:SetTextColor(0, 1, 0)
takeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
takeBtn:SetScript("OnClick", function() SendTPAnnounce("TAKE") end)

for i = 1, 5 do
    local btn = CreateFrame("Button", nil, ABG_TPMenu)
    btn:SetSize(90, 18); btn:SetPoint("TOP", ABG_TPMenu, "TOP", 0, -5 - (i*20))
    local t = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER"); t:SetText("INC +" .. i); t:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    btn:SetScript("OnClick", function() SendTPAnnounce("INC", i) end)
end

local dBtn = CreateFrame("Button", nil, ABG_TPMenu); dBtn:SetSize(90, 18); dBtn:SetPoint("TOP", ABG_TPMenu, "TOP", 0, -5 - (6*20))
local dt = dBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); dt:SetPoint("CENTER"); dt:SetText("NEED DEFF"); dt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); dt:SetTextColor(1, 0.8, 0)
dBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); dBtn:SetScript("OnClick", function() SendTPAnnounce("DEFF") end)

local aBtn = CreateFrame("Button", nil, ABG_TPMenu); aBtn:SetSize(90, 18); aBtn:SetPoint("TOP", ABG_TPMenu, "TOP", 0, -5 - (7*20))
local at = aBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); at:SetPoint("CENTER"); at:SetText("ATTACK"); at:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); at:SetTextColor(1, 0.2, 0.2)
aBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); aBtn:SetScript("OnClick", function() SendTPAnnounce("ATTACK") end)

local TPClickParent = CreateFrame("Frame", nil, frame)
TPClickParent:SetAllPoints(frame)

for id, data in pairs(ABG_TPCoords) do
    local zone = CreateFrame("Button", nil, TPClickParent)
    zone:SetSize(24, 24) 
    zone:SetPoint("CENTER", TPClickParent, "CENTER", data.x, data.y)
    zone:SetFrameLevel(frame:GetFrameLevel() + 21)
    zone:EnableMouse(true); zone:RegisterForClicks("RightButtonUp")
    

    --local tx = zone:CreateTexture(); tx:SetAllPoints(); tx:SetTexture(0, 1, 0, 0.3) 

    zone:SetScript("OnClick", function()
        activeTPNode = data.name
        local x, y = GetCursorPosition(); local scale = UIParent:GetEffectiveScale()
        ABG_TPMenu:ClearAllPoints(); ABG_TPMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale, y/scale)
        ABG_TPMenu:Show()
    end)
end

local function UpdateTPZones()
    local name, _, _, _, _, _, _, mapID = GetInstanceInfo()
    local mapName = GetMapInfo()
    if mapID == 726 or mapName == "TwinPeaks" or name == "Twin Peaks" or name == "Два Пика" then 
        TPClickParent:Show() 
    else 
        TPClickParent:Hide(); ABG_TPMenu:Hide() 
    end
end

local tpCheckFrame = CreateFrame("Frame")
tpCheckFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA"); tpCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
tpCheckFrame:SetScript("OnEvent", UpdateTPZones)
C_Timer.After(2, UpdateTPZones)

ABG_TPMenu:SetScript("OnUpdate", function(self)
    if not self:IsMouseOver() and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")) then self:Hide() end
end)

