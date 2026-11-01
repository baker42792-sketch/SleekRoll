-- WotLK 3.3.5a. Keep Blizzard's roll scripts and confirmation handling intact.
local WHITE = "Interface\\Buttons\\WHITE8X8"
local frames, previews = {}, {}
local anchor = CreateFrame("Frame", "SleekRollAnchor", UIParent)
anchor:SetWidth(360)
anchor:SetHeight(22)
anchor:SetMovable(true)
anchor:SetClampedToScreen(true)
anchor:SetFrameStrata("DIALOG")
anchor:EnableMouse(true)
anchor:RegisterForDrag("LeftButton")
local backdrop = {bgFile = WHITE, edgeFile = WHITE, edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1}}
anchor:SetBackdrop(backdrop)
anchor:SetBackdropColor(.06, .08, .10, .96)
anchor:SetBackdropBorderColor(.25, .65, .72, .8)
local title = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("CENTER")
title:SetText("SLEEKROLL  /  drag to move")
title:SetTextColor(.65, .85, .88)
anchor:Hide()

local function Position()
    anchor:ClearAllPoints()
    local db = SleekRollDB
    anchor:SetPoint(db.point or "CENTER", UIParent, db.point or "CENTER", db.x or 0, db.y or 100)
end

local function Layout()
    local previous
    for _, list in ipairs({frames, previews}) do
        for _, f in ipairs(list) do
            if f:IsShown() then
                f:ClearAllPoints()
                if SleekRollDB and SleekRollDB.growth == "up" then
                    f:SetPoint("BOTTOMLEFT", previous or anchor, "TOPLEFT", 0, 6)
                else
                    f:SetPoint("TOPLEFT", previous or anchor, "BOTTOMLEFT", 0, -6)
                end
                previous = f
            end
        end
    end
end

anchor:SetScript("OnDragStart", function(self) self:StartMoving() end)
anchor:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    SleekRollDB.point, SleekRollDB.x, SleekRollDB.y = point, x, y
end)

local function Place(region, parent, x, y, w, h)
    region:ClearAllPoints()
    region:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    region:SetWidth(w)
    region:SetHeight(h)
end

local function UpdateNameBacking(f)
    local name = _G[f:GetName().."Name"]
    if not f.nameBacking then return end
    local width = math.min(name:GetStringWidth(), name:GetWidth())
    local height = math.min(name:GetStringHeight(), name:GetHeight())
    f.nameBacking:ClearAllPoints()
    f.nameBacking:SetPoint("LEFT", name, "LEFT", -4, 0)
    f.nameBacking:SetWidth(math.max(1, width + 8))
    f.nameBacking:SetHeight(math.max(1, height + 4))
end

local function Resize(f)
    local db, n = SleekRollDB, f:GetName()
    local w, h = db.width or 360, db.height or 73
    f:SetWidth(w)
    f:SetHeight(h)
    f:SetScale(db.scale or 1)
    local buttons = {f.needButton, f.greedButton, f.disenchantButton, f.passButton}
    if h < 73 then
        -- Compact rows put the name and roll icons on one line.
        local iconSize = math.min(32, h - 12)
        local left = iconSize + 14
        -- Reserve readable name space even at the narrowest width.
        local buttonSize = math.min(28, h - 12, math.floor((w - left - 56) / 4) - 4)
        local buttonLeft = w - 8 - 4 * (buttonSize + 4)
        Place(_G[n.."IconFrame"], f, 6, -5, iconSize, iconSize)
        Place(_G[n.."Name"], f, left, -5, buttonLeft - left - 8, h - 12)
        for i, b in ipairs(buttons) do
            Place(b, f, buttonLeft + (i - 1) * (buttonSize + 4), -((h - 5 - buttonSize) / 2), buttonSize, buttonSize)
        end
    else
        local iconSize = math.min(64, h - 33)
        local left = iconSize + 22
        Place(_G[n.."IconFrame"], f, 11, -11, iconSize, iconSize)
        Place(_G[n.."Name"], f, left, -10, w - left - 13, h - 53)
        local cellWidth = (w - left - 13) / 4
        local buttonSize = math.min(28, cellWidth - 4)
        for i, b in ipairs(buttons) do
            local x = left + (i - 1) * cellWidth + (cellWidth - buttonSize) / 2
            Place(b, f, x, -(h - 39), buttonSize, buttonSize)
        end
    end
    Place(f.accent, f, 0, 0, 2, h)
    if f.knotArt then
        -- Stretch the tightly cropped band across the entire row.
        Place(f.knotArt, f, 0, 0, w, h)
        f.knotArt:SetAlpha(1) -- The texture itself contains the 33%-to-0% fade.
    end
    Place(_G[n.."Timer"], f, 11, -(h - 7), w - 24, 3)
    UpdateNameBacking(f)
end

local function ApplySize()
    -- All rows and the handle share a scale, keeping their anchors aligned.
    anchor:SetWidth(SleekRollDB.width or 360)
    anchor:SetScale(SleekRollDB.scale or 1)
    for _, list in ipairs({frames, previews}) do
        for _, f in ipairs(list) do Resize(f) end
    end
    Layout()
end

local function Refresh(f)
    local n = f:GetName()
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(.035, .045, .06, .96)
    f:SetBackdropBorderColor(.19, .22, .27, 1)
    _G[n.."Decoration"]:Hide()
    _G[n.."Corner"]:Hide()
    local quality = f.previewQuality
    if not quality and f.rollID then
        local _, _, _, q = GetLootRollItemInfo(f.rollID)
        quality = q
    end
    local c = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]
    f.accent:SetTexture(c.r, c.g, c.b, 1)
    if f.knotArt then
        f.knotArt:SetVertexColor(c.r, c.g, c.b, 1)
    end
    _G[n.."Timer"]:SetStatusBarColor(c.r, c.g, c.b, .85)
    UpdateNameBacking(f)
end

local function Skin(f)
    local n = f:GetName()
    f:SetWidth(360)
    f:SetHeight(73)
    _G[n.."SlotTexture"]:Hide()
    _G[n.."NameFrame"]:Hide()
    f.accent = f:CreateTexture(nil, "ARTWORK")
    -- BORDER sits above the panel backdrop and below its item name and buttons.
    f.knotArt = f:CreateTexture(nil, "BORDER")
    f.knotArt:SetTexture("Interface\\AddOns\\SleekRoll\\Media\\KnotworkFade.tga")
    f.nameBacking = f:CreateTexture(nil, "ARTWORK")
    f.nameBacking:SetTexture(0, 0, 0, 1)
    _G[n.."Name"]:SetDrawLayer("OVERLAY")
    Place(f.accent, f, 0, 0, 2, 73)
    local icon = _G[n.."IconFrame"]
    Place(icon, f, 11, -11, 40, 40)
    local texture = _G[n.."IconFrameIcon"]
    texture:ClearAllPoints()
    texture:SetAllPoints(icon)
    texture:SetTexCoord(.08, .92, .08, .92)
    Place(_G[n.."Name"], f, 62, -10, 285, 20)
    -- Keep the template's original dice, coin, disenchant, and pass artwork,
    -- including pressed/highlight textures, eligibility, and tooltip scripts.
    for _, b in ipairs({f.needButton, f.greedButton, f.disenchantButton, f.passButton}) do
        b:SetText("")
    end
    local timer = _G[n.."Timer"]
    timer:DisableDrawLayer("OVERLAY")
    Place(timer, f, 11, -66, 336, 3)
    timer:SetStatusBarTexture(WHITE)
    local bg = timer:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(timer)
    bg:SetTexture(.15, .17, .20, 1)
    Resize(f)
    Refresh(f)
end

local function HidePreviews()
    for _, f in ipairs(previews) do f:Hide() end
end

local function Preview()
    if previews[1] and previews[1]:IsShown() then HidePreviews(); return end
    for _, f in ipairs(frames) do
        if f:IsShown() then
            DEFAULT_CHAT_FRAME:AddMessage("SleekRoll: preview is unavailable during a real roll.")
            return
        end
    end
    anchor:Show()
    for i = 1, 2 do
        local f = previews[i]
        if not f then
            f = CreateFrame("Frame", "SleekRollPreview"..i, UIParent, "GroupLootFrameTemplate")
            f:UnregisterAllEvents()
            f:SetScript("OnShow", nil)
            f:SetScript("OnHide", nil)
            f.previewQuality = i == 1 and 4 or 3
            local n = f:GetName()
            local icon = _G[n.."IconFrame"]
            icon:SetScript("OnUpdate", nil)
            icon:SetScript("OnEnter", nil)
            icon:SetScript("OnClick", nil)
            _G[n.."Timer"]:SetScript("OnUpdate", nil)
            Skin(f)
            for _, b in ipairs({f.needButton, f.greedButton, f.disenchantButton, f.passButton}) do
                b:SetScript("OnClick", function() HidePreviews() end)
                b:SetScript("OnEnter", nil)
            end
            _G[n.."Name"]:SetText(i == 1 and "Epic item / preview" or "Rare item / preview")
            local c = ITEM_QUALITY_COLORS[f.previewQuality]
            _G[n.."Name"]:SetTextColor(c.r, c.g, c.b)
            UpdateNameBacking(f)
            _G[n.."IconFrameIcon"]:SetTexture("Interface\\Icons\\INV_Sword_62")
            _G[n.."Timer"]:SetMinMaxValues(0, 1)
            _G[n.."Timer"]:SetValue(i == 1 and .75 or .45)
            previews[i] = f
        end
        Refresh(f)
        f:Show()
    end
    Layout()
end

local loader = CreateFrame("Frame")
local options, syncOptions
local function OpenOptions()
    if not options then
        options = CreateFrame("Frame", "SleekRollOptions", UIParent)
        options:SetWidth(380)
        options:SetHeight(420)
        options:SetPoint("CENTER")
        options:SetFrameStrata("DIALOG")
        options:SetToplevel(true)
        options:SetMovable(true)
        options:SetClampedToScreen(true)
        options:EnableMouse(true)
        options:RegisterForDrag("LeftButton")
        options:SetScript("OnDragStart", function(self) self:StartMoving() end)
        options:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        options:SetBackdrop(backdrop)
        options:SetBackdropColor(.035, .045, .06, .98)
        options:SetBackdropBorderColor(.25, .65, .72, 1)
        local heading = options:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        heading:SetPoint("TOPLEFT", 22, -20)
        heading:SetText("SleekRoll options")
        local note = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        note:SetPoint("TOPLEFT", 22, -47)
        note:SetText("Changes apply immediately and save automatically.")
        local close = CreateFrame("Button", nil, options, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -3, -3)
        close:SetScript("OnClick", function() options:Hide() end)
        UISpecialFrames[#UISpecialFrames + 1] = "SleekRollOptions"
        local controls, syncing = {}, false
        local function Slider(key, label, y, low, high, step, fallback)
            local name = "SleekRollOption"..key
            local s = CreateFrame("Slider", name, options, "OptionsSliderTemplate")
            Place(s, options, 30, y, 320, 17)
            s:SetMinMaxValues(low, high)
            s:SetValueStep(step)
            _G[name.."Low"]:SetText(low)
            _G[name.."High"]:SetText(high)
            s:SetScript("OnValueChanged", function(self, value)
                value = math.floor(value / step + .5) * step
                value = math.max(low, math.min(high, value))
                local display = tostring(value)
                if key == "scale" then display = string.format("%.2f", value) end
                _G[name.."Text"]:SetText(label..": "..display)
                if not syncing then
                    SleekRollDB[key] = value
                    ApplySize()
                end
            end)
            controls[#controls + 1] = {slider = s, key = key, fallback = fallback}
        end
        Slider("width", "Width", -96, 200, 720, 1, 360)
        Slider("height", "Height", -158, 32, 180, 1, 73)
        Slider("scale", "Scale", -220, .6, 1.8, .05, 1)
        local function Button(label, x, y, width, action)
            local b = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
            Place(b, options, x, y, width, 25)
            b:SetText(label)
            b:SetScript("OnClick", action)
            return b
        end
        local growth = Button("", 22, -265, 336, function()
            SleekRollDB.growth = SleekRollDB.growth == "up" and "down" or "up"
            Layout()
            syncOptions()
        end)
        Button("Toggle preview", 22, -302, 164, Preview)
        Button("Unlock position", 194, -302, 164, function() anchor:Show() end)
        Button("Lock position", 22, -337, 164, function()
            anchor:StopMovingOrSizing()
            anchor:Hide()
            HidePreviews()
        end)
        Button("Reset defaults", 194, -337, 164, function()
            SleekRollDB = {}
            ApplySize()
            Position()
            anchor:Show()
            syncOptions()
        end)
        local hint = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("BOTTOM", 0, 20)
        hint:SetText("Toggle preview to see your changes. Drag the handle to move.")
        syncOptions = function()
            syncing = true
            for _, c in ipairs(controls) do
                c.slider:SetValue(SleekRollDB[c.key] or c.fallback)
            end
            growth:SetText("Growth direction: "..(SleekRollDB.growth == "up" and "Up" or "Down").." (click to switch)")
            syncing = false
        end
        options:SetScript("OnShow", syncOptions)
    end
    syncOptions()
    options:Show()
end

loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    SleekRollDB = SleekRollDB or {}
    SleekRollDB.width = math.max(200, math.min(720, tonumber(SleekRollDB.width) or 360))
    SleekRollDB.height = math.max(32, math.min(180, tonumber(SleekRollDB.height) or 73))
    SleekRollDB.scale = math.max(.6, math.min(1.8, tonumber(SleekRollDB.scale) or 1))
    SleekRollDB.artOpacity = nil -- Retire the former adjustable opacity setting.
    anchor:SetScale(SleekRollDB.scale)
    Position()
    for i = 1, NUM_GROUP_LOOT_FRAMES do
        local f = _G["GroupLootFrame"..i]
        frames[#frames + 1] = f
        Skin(f)
        f:HookScript("OnShow", function(frame)
            HidePreviews()
            Refresh(frame)
            Layout()
        end)
        f:HookScript("OnHide", Layout)
    end
    ApplySize()
    hooksecurefunc("AlertFrame_FixAnchors", Layout)
    SLASH_SLEEKROLL1 = "/sleekroll"
    SLASH_SLEEKROLL2 = "/sr"
    SlashCmdList.SLEEKROLL = function(msg)
        msg = string.lower(string.match(msg or "", "^%s*(.-)%s*$"))
        local command, args = string.match(msg, "^(%S+)%s*(.*)$")
        if msg == "" or msg == "options" then OpenOptions()
        elseif msg == "test" then Preview()
        elseif command == "growth" then
            if args == "up" or args == "down" then
                SleekRollDB.growth = args
                Layout()
                DEFAULT_CHAT_FRAME:AddMessage("SleekRoll: loot windows now grow "..args..".")
            else
                DEFAULT_CHAT_FRAME:AddMessage("SleekRoll: /sr growth up or /sr growth down")
            end
        elseif command == "size" then
            local w, h = string.match(args, "^(%d+)%s+(%d+)$")
            w, h = tonumber(w), tonumber(h)
            if w and h and w >= 200 and w <= 720 and h >= 32 and h <= 180 then
                SleekRollDB.width, SleekRollDB.height = w, h
                ApplySize()
            else
                DEFAULT_CHAT_FRAME:AddMessage("SleekRoll: /sr size WIDTH HEIGHT (width 200-720, height 32-180). Example: /sr size 240 40")
            end
        elseif command == "scale" then
            local scale = tonumber(args)
            if scale and scale >= .6 and scale <= 1.8 then
                SleekRollDB.scale = scale
                ApplySize()
            else
                DEFAULT_CHAT_FRAME:AddMessage("SleekRoll: /sr scale 0.6 to 1.8. Example: /sr scale 1.2")
            end
        elseif msg == "unlock" then anchor:Show()
        elseif msg == "lock" then
            anchor:StopMovingOrSizing()
            anchor:Hide()
            HidePreviews()
        elseif msg == "reset" then
            SleekRollDB = {}
            ApplySize()
            Position()
            anchor:Show()
            Layout()
        else
            OpenOptions()
        end
        if options and options:IsShown() then syncOptions() end
    end
    self:UnregisterEvent("PLAYER_LOGIN")
end)
