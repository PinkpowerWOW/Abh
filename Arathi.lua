local frame = AscensionBGMapFrame 

local activeNodeName = nil

local ABG_NodeMenu = CreateFrame("Frame", "ABG_NodeContextMenu", UIParent)
ABG_NodeMenu:SetSize(100, 205) 
ABG_NodeMenu:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
})
ABG_NodeMenu:SetBackdropColor(0, 0, 0, 0.9)
ABG_NodeMenu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
ABG_NodeMenu:SetFrameStrata("TOOLTIP")
ABG_NodeMenu:SetFrameLevel(150)
ABG_NodeMenu:Hide()

local function SendNodeAnnounce(msgType, count)
    if not activeNodeName then return end
    local msg = ""
    local tag = "[ABH] " 
    local node = activeNodeName:upper()
    
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
    end

    local chatType = (select(2, GetInstanceInfo()) == "pvp") and "BATTLEGROUND" or "SAY"
    SendChatMessage(msg, chatType)
    ABG_NodeMenu:Hide()
end


for i = 1, 5 do
    local btn = CreateFrame("Button", nil, ABG_NodeMenu)
    btn:SetSize(90, 18)
    btn:SetPoint("TOP", ABG_NodeMenu, "TOP", 0, -5 - (i-1)*20)
    
    local t = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER"); t:SetText("INC +" .. i); t:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    btn:SetScript("OnClick", function() SendNodeAnnounce("INC", i) end)
end

local deffBtn = CreateFrame("Button", nil, ABG_NodeMenu)
deffBtn:SetSize(90, 18)
deffBtn:SetPoint("TOP", ABG_NodeMenu, "TOP", 0, -5 - (5*20))
local dt = deffBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dt:SetPoint("CENTER"); dt:SetText("NEED DEFF"); dt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
dt:SetTextColor(1, 0.8, 0)
deffBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
deffBtn:SetScript("OnClick", function() SendNodeAnnounce("DEFF") end)

local atkBtn = CreateFrame("Button", nil, ABG_NodeMenu)
atkBtn:SetSize(90, 18)
atkBtn:SetPoint("TOP", ABG_NodeMenu, "TOP", 0, -5 - (6*20))
local at = atkBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
at:SetPoint("CENTER"); at:SetText("ATTACK"); at:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
at:SetTextColor(1, 0.2, 0.2)
atkBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
atkBtn:SetScript("OnClick", function() SendNodeAnnounce("ATTACK") end)

local omwBtn = CreateFrame("Button", nil, ABG_NodeMenu)
omwBtn:SetSize(90, 18)
omwBtn:SetPoint("TOP", ABG_NodeMenu, "TOP", 0, -5 - (7*20))
local ot = omwBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ot:SetPoint("CENTER"); ot:SetText("ON MY WAY"); ot:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
ot:SetTextColor(0.3, 0.6, 1) 
omwBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
omwBtn:SetScript("OnClick", function() SendNodeAnnounce("OMW") end)

local iamBtn = CreateFrame("Button", nil, ABG_NodeMenu)
iamBtn:SetSize(90, 18)
iamBtn:SetPoint("TOP", ABG_NodeMenu, "TOP", 0, -5 - (8*20))
local it = iamBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
it:SetPoint("CENTER"); it:SetText("I AM DEFF"); it:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
it:SetTextColor(0.1, 1, 0.1) 
iamBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
iamBtn:SetScript("OnClick", function() SendNodeAnnounce("IAMDEFF") end)

local ABG_ClickCoords = {
    ["stables"]     = { x = -31, y = 43,  name = "STABLES" },
    ["gold mine"]   = { x = 29,  y = 45,  name = "GM" },
    ["blacksmith"]  = { x = -1,  y = 10,  name = "BS" },
    ["lumber mill"] = { x = -30, y = -18, name = "LM" },
    ["farm"]        = { x = 29,  y = -15, name = "FARM" },
}

local NodeClickParent = CreateFrame("Frame", nil, frame)
NodeClickParent:SetAllPoints(frame)

for id, data in pairs(ABG_ClickCoords) do
    local zone = CreateFrame("Button", nil, NodeClickParent)
    zone:SetSize(24, 24)
    zone:SetPoint("CENTER", NodeClickParent, "CENTER", data.x, data.y)
    zone:SetFrameLevel(frame:GetFrameLevel() + 20)
    zone:EnableMouse(true)
    zone:RegisterForClicks("RightButtonUp")
    
    zone:SetScript("OnClick", function()
        activeNodeName = data.name
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        ABG_NodeMenu:ClearAllPoints()
        ABG_NodeMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x/scale, y/scale)
        ABG_NodeMenu:Show()
    end)
end

local function UpdateAratiZones()
    local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
    

    
    local isArathi = (instanceID == 529 or instanceID == 2004 or instanceID == 1681)

    if not isArathi then
        local zoneName = GetRealZoneText()
        if zoneName == "Arathi Basin" or zoneName == "Низина Арати" then
            isArathi = true
        end
    end

    if isArathi then 
        NodeClickParent:Show() 
    else 
        NodeClickParent:Hide()
        ABG_NodeMenu:Hide() 
    end
end

local zoneCheckFrame = CreateFrame("Frame")
zoneCheckFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneCheckFrame:RegisterEvent("WORLD_MAP_UPDATE") 
zoneCheckFrame:SetScript("OnEvent", UpdateAratiZones)

C_Timer.After(2, UpdateAratiZones)

UpdateAratiZones()

ABG_NodeMenu:SetScript("OnUpdate", function(self)
    if not self:IsMouseOver() and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")) then
        self:Hide()
    end
end)
