local frame = AscensionBGMapFrame
local activeEOTSNode = nil

local ABG_EOTSMenu = CreateFrame("Frame", "ABG_EOTSContextMenu", UIParent)
ABG_EOTSMenu:SetSize(100, 225) 
ABG_EOTSMenu:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
})
ABG_EOTSMenu:SetBackdropColor(0, 0, 0, 0.9)
ABG_EOTSMenu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
ABG_EOTSMenu:SetFrameStrata("TOOLTIP")
ABG_EOTSMenu:SetFrameLevel(152)
ABG_EOTSMenu:Hide()

local function SendEOTSAnnounce(msgType, count)
    if not activeEOTSNode then return end
    local msg = ""
    local tag = "[ABH] "
    local node = activeEOTSNode:upper()
    
    if msgType == "INC" then
        msg = tag .. "INC " .. count .. " " .. node
    elseif msgType == "DEFF" then
        msg = tag .. node .. " GUARD NEEDED!"
    elseif msgType == "ATTACK" then
        msg = tag .. node .. " ATTACK!"
    elseif msgType == "OMW" then
        msg = tag .. node .. " I'M ON MY WAY!"
    elseif msgType == "IAMDEFF" then
        msg = tag .. node .. " I AM DEFENDING THE POINT."
    elseif msgType == "KILL" then
        msg = tag .. "KILL ALL IN CENTER! I'M CAP THE FLAG!"
    end
    
    local chatType = (select(2, GetInstanceInfo()) == "pvp") and "BATTLEGROUND" or "SAY"
    SendChatMessage(msg, chatType)
    ABG_EOTSMenu:Hide()
end

for i = 1, 5 do
    local btn = CreateFrame("Button", nil, ABG_EOTSMenu)
    btn:SetSize(90, 18); btn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (i-1)*20)
    local t = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER"); t:SetText("INC +" .. i); t:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    btn:SetScript("OnClick", function() SendEOTSAnnounce("INC", i) end)
end

local edBtn = CreateFrame("Button", nil, ABG_EOTSMenu); edBtn:SetSize(90, 18); edBtn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (5*20))
local edt = edBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); edt:SetPoint("CENTER"); edt:SetText("NEED DEFF"); edt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); edt:SetTextColor(1, 0.8, 0)
edBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); edBtn:SetScript("OnClick", function() SendEOTSAnnounce("DEFF") end)

local eaBtn = CreateFrame("Button", nil, ABG_EOTSMenu); eaBtn:SetSize(90, 18); eaBtn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (6*20))
local eat = eaBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); eat:SetPoint("CENTER"); eat:SetText("ATTACK"); eat:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); eat:SetTextColor(1, 0.2, 0.2)
eaBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); eaBtn:SetScript("OnClick", function() SendEOTSAnnounce("ATTACK") end)

local omwBtn = CreateFrame("Button", nil, ABG_EOTSMenu); omwBtn:SetSize(90, 18); omwBtn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (7*20))
local ot = omwBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); ot:SetPoint("CENTER"); ot:SetText("ON MY WAY"); ot:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); ot:SetTextColor(0.3, 0.6, 1)
omwBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); omwBtn:SetScript("OnClick", function() SendEOTSAnnounce("OMW") end)

local iamBtn = CreateFrame("Button", nil, ABG_EOTSMenu); iamBtn:SetSize(90, 18); iamBtn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (8*20))
local it = iamBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); it:SetPoint("CENTER"); it:SetText("I AM DEFF"); it:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); it:SetTextColor(0.1, 1, 0.1)
iamBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); iamBtn:SetScript("OnClick", function() SendEOTSAnnounce("IAMDEFF") end)

local killBtn = CreateFrame("Button", nil, ABG_EOTSMenu); killBtn:SetSize(90, 18); killBtn:SetPoint("TOP", ABG_EOTSMenu, "TOP", 0, -5 - (9*20))
local kt = killBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal"); kt:SetPoint("CENTER"); kt:SetText("KILL ALL"); kt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE"); kt:SetTextColor(1, 0, 0)
killBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight"); killBtn:SetScript("OnClick", function() SendEOTSAnnounce("KILL") end)

local ABG_EOTSCoords = {
    ["fel orc village"] = { x = -26, y = -17,  name = "FR" },
    ["blood elf tower"] = { x = 24,  y = -14,  name = "BE" },
    ["draenei ruins"]   = { x = 20, y = 19, name = "DR" },
    ["mage tower"]      = { x = -29,  y = 17, name = "MT" },
    ["flag center"]     = { x = -1, y = 0, name = "CENTER" }, 
}

local EOTSClickParent = CreateFrame("Frame", nil, frame)
EOTSClickParent:SetAllPoints(frame)

for id, data in pairs(ABG_EOTSCoords) do
    local zone = CreateFrame("Button", nil, EOTSClickParent)
    zone:SetSize(24, 24) 
    zone:SetPoint("CENTER", EOTSClickParent, "CENTER", data.x, data.y)
    zone:SetFrameLevel(frame:GetFrameLevel() + 20)
    zone:EnableMouse(true); zone:RegisterForClicks("RightButtonUp")
    
    -- local tx = zone:CreateTexture(); tx:SetAllPoints(); tx:SetTexture(0, 1, 0, 0.3)

    zone:SetScript("OnClick", function()
        activeEOTSNode = data.name
        local x, y = GetCursorPosition(); local scale = UIParent:GetEffectiveScale()
        ABG_EOTSMenu:ClearAllPoints(); ABG_EOTSMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale, y/scale)
        ABG_EOTSMenu:Show()
    end)
end

local function UpdateEOTSZones()
    local name, instanceType, _, _, _, _, _, mapID = GetInstanceInfo()
    local mapName = GetMapInfo()
    if mapID == 566 or mapName == "Netherstorm" or mapName == "Expansion01" or name == "Eye of the Storm" or name == "Око Бури" then 
        EOTSClickParent:Show() 
    else 
        EOTSClickParent:Hide(); ABG_EOTSMenu:Hide() 
    end
end

local eotsCheckFrame = CreateFrame("Frame")
eotsCheckFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA"); eotsCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD"); eotsCheckFrame:RegisterEvent("WORLD_MAP_UPDATE")
eotsCheckFrame:SetScript("OnEvent", UpdateEOTSZones)

C_Timer.After(2, UpdateEOTSZones)
ABG_EOTSMenu:SetScript("OnUpdate", function(self)
    if not self:IsMouseOver() and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")) then self:Hide() end
end)

