local frame = AscensionBGMapFrame

local activeWSGNode = nil

local ABG_WSGMenu = CreateFrame("Frame", "ABG_WSGContextMenu", UIParent)
ABG_WSGMenu:SetSize(100, 185) 
ABG_WSGMenu:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
})
ABG_WSGMenu:SetBackdropColor(0, 0, 0, 0.9)
ABG_WSGMenu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
ABG_WSGMenu:SetFrameStrata("TOOLTIP")
ABG_WSGMenu:SetFrameLevel(153)
ABG_WSGMenu:Hide()

local function SendWSGAnnounce(msgType, count)
    local msg = ""
    local tag = "[ABH] " 
    
    if msgType == "TAKE" then
        msg = tag .. "I'LL TAKE THE FLAG!"
    elseif not activeWSGNode then return 
    elseif msgType == "INC" then
        msg = tag .. "INC " .. count .. " " .. activeWSGNode:upper()
    elseif msgType == "DEFF" then
        msg = tag .. activeWSGNode:upper() .. " GUARD NEEDED!"
    elseif msgType == "ATTACK" then
        msg = tag .. activeWSGNode:upper() .. " ATTACK!"
    end
    
    local chatType = (select(2, GetInstanceInfo()) == "pvp") and "BATTLEGROUND" or "SAY"
    SendChatMessage(msg, chatType)
    ABG_WSGMenu:Hide()
end

local wsTakeBtn = CreateFrame("Button", nil, ABG_WSGMenu)
wsTakeBtn:SetSize(90, 18); wsTakeBtn:SetPoint("TOP", ABG_WSGMenu, "TOP", 0, -5)
local wst = wsTakeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wst:SetPoint("CENTER"); wst:SetText("TAKE FLAG"); wst:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); wst:SetTextColor(0, 1, 0)
wsTakeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
wsTakeBtn:SetScript("OnClick", function() SendWSGAnnounce("TAKE") end)

for i = 1, 5 do
    local btn = CreateFrame("Button", nil, ABG_WSGMenu)
    btn:SetSize(90, 18); btn:SetPoint("TOP", ABG_WSGMenu, "TOP", 0, -5 - (i*20))
    local t = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER"); t:SetText("INC +" .. i); t:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    btn:SetScript("OnClick", function() SendWSGAnnounce("INC", i) end)
end

local wsDBtn = CreateFrame("Button", nil, ABG_WSGMenu); wsDBtn:SetSize(90, 18); wsDBtn:SetPoint("TOP", ABG_WSGMenu, "TOP", 0, -5 - (6*20))
local wsDT = wsDBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); wsDT:SetPoint("CENTER"); wsDT:SetText("NEED DEFF"); wsDT:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); wsDT:SetTextColor(1, 0.8, 0)
wsDBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); wsDBtn:SetScript("OnClick", function() SendWSGAnnounce("DEFF") end)

local wsABtn = CreateFrame("Button", nil, ABG_WSGMenu); wsABtn:SetSize(90, 18); wsABtn:SetPoint("TOP", ABG_WSGMenu, "TOP", 0, -5 - (7*20))
local wsAT = wsABtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); wsAT:SetPoint("CENTER"); wsAT:SetText("ATTACK"); wsAT:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); wsAT:SetTextColor(1, 0.2, 0.2)
wsABtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); wsABtn:SetScript("OnClick", function() SendWSGAnnounce("ATTACK") end)

local ABG_WSGCoords = {
    ["alliance"] = { x = -2, y = 70,  name = "SILVERWING HOLD" },
    ["horde"]    = { x = 5,  y = -72, name = "WARSONG LUMBER MILL" },
}

local WSGClickParent = CreateFrame("Frame", "ABG_WSG_ClickParent", frame)
WSGClickParent:SetAllPoints(frame)

for id, data in pairs(ABG_WSGCoords) do
    local zone = CreateFrame("Button", nil, WSGClickParent)
    zone:SetSize(24, 24) 
    zone:SetPoint("CENTER", WSGClickParent, "CENTER", data.x, data.y)
    zone:SetFrameLevel(frame:GetFrameLevel() + 25)
    zone:EnableMouse(true); zone:RegisterForClicks("RightButtonUp")
    

    --local tx = zone:CreateTexture(); tx:SetAllPoints(); tx:SetTexture(0, 1, 0, 0.3) 

    zone:SetScript("OnClick", function()
        activeWSGNode = data.name
        local x, y = GetCursorPosition(); local scale = UIParent:GetEffectiveScale()
        ABG_WSGMenu:ClearAllPoints(); ABG_WSGMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale, y/scale)
        ABG_WSGMenu:Show()
    end)
end

local function UpdateWSGZones()
    if not WSGClickParent then return end
    local name, _, _, _, _, _, _, mapID = GetInstanceInfo()
    local mapName = GetMapInfo()
    if mapID == 489 or mapName == "WarsongGulch" or name == "Warsong Gulch" then 
        WSGClickParent:Show() 
    else 
        WSGClickParent:Hide()
        ABG_WSGMenu:Hide() 
    end
end

local wsgCheckFrame = CreateFrame("Frame")
wsgCheckFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
wsgCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
wsgCheckFrame:SetScript("OnEvent", UpdateWSGZones)

C_Timer.After(2, UpdateWSGZones)

ABG_WSGMenu:SetScript("OnUpdate", function(self)
    if not self:IsMouseOver() and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")) then self:Hide() end
end)