-- CombatTextLite v0.2
-- Simple toggle for enabling or disabling floating combat text through an easy in-game command and options interface.

local addonName = "CombatTextLite"

-- Localization
local L = {
    ADDON_LOADED = "CombatTextLite loaded. Use /ctl toggle to enable/disable Floating Combat Text.",
    FCT_ENABLED = "Floating Combat Text has been enabled.",
    FCT_DISABLED = "Floating Combat Text has been disabled.",
    SETTINGS_NOT_FOUND = "Settings panel not found.",
    SETTINGS_CHANGED = "Setting changed. Please /reload or use the Reload UI button in settings to apply changes.",
    USAGE = "Usage: /ctl toggle - Toggle Floating Combat Text on or off.",
    USAGE_HELP = "Available commands:|n/ctl toggle - Toggle all Floating Combat Text on or off|n/ctl config - Open settings panel"
}

local function err(msg)
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
    -- Line used for debugging; commented out for release
    -- DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000CombatTextLite Error|r: " .. msg)
end

local function info(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00CombatTextLite|r: " .. msg)
end

--[[
THIS IS WHERE WE BUILD OUR CORE FUNCTIONALITY/LOGIC
EVERYTHING IMPORTANT GOES HERE, AND BELOW THIS AREA
IS WHERE WE BUILD OUT THE SETTINGS PANEL AND SLASH COMMANDS
]]

-- Settings Panel
local settingsCategory
local settingsFrame
local suppressCallbacks = false

local function CreateSettingsPanel()
    -- Create custom frame with manual UI elements instead of using Blizzard's managed layout system.
    -- Using RegisterCanvasLayoutCategory (custom frame) instead of RegisterVerticalLayoutCategory
    -- (Blizzard-managed widgets) prevents taint issues when interacting with protected frames
    -- like Edit Mode and ExtraActionButton.
    settingsFrame = CreateFrame("Frame", "CombatTextLiteSettingsFrame")
    settingsFrame:Hide()
    
    -- Title
    local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("CombatTextLite")
    
    -- Master toggle checkbox
    local masterCheckbox = CreateFrame("CheckButton", nil, settingsFrame, "InterfaceOptionsCheckButtonTemplate")
    masterCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    masterCheckbox.Text:SetText("Toggle All Combat Text")
    
    local function GetMasterValue()
        return GetCVar("floatingCombatTextCombatDamage_v2") == "1"
    end
    
    local function SetMasterValue(value)
        suppressCallbacks = true
        local newValue = value and "1" or "0"
        SetCVar("floatingCombatTextCombatDamage_v2", newValue)
        SetCVar("floatingCombatTextCombatHealing_v2", newValue)
        SetCVar("floatingCombatTextPetMeleeDamage_v2", newValue)
        SetCVar("floatingCombatTextPetSpellDamage_v2", newValue)
        SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", newValue)
        suppressCallbacks = false
        
        -- Update individual checkboxes to reflect new state
        for _, cb in ipairs(settingsFrame.individualCheckboxes or {}) do
            cb:SetChecked(value)
        end
        
        info(L.SETTINGS_CHANGED)
    end
    
    masterCheckbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        SetMasterValue(checked)
    end)
    
    masterCheckbox:SetScript("OnShow", function(self)
        self:SetChecked(GetMasterValue())
    end)
    
    -- Individual settings header
    local individualHeader = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    individualHeader:SetPoint("TOPLEFT", masterCheckbox, "BOTTOMLEFT", 0, -16)
    individualHeader:SetText("Individual Settings")
    
    -- Individual CVar checkboxes
    local cvars = {
        {cvar = "floatingCombatTextCombatDamage_v2", label = "Combat Damage", tooltip = "floatingCombatTextCombatDamage_v2\n\nShow damage you deal"},
        {cvar = "floatingCombatTextCombatHealing_v2", label = "Combat Healing", tooltip = "floatingCombatTextCombatHealing_v2\n\nShow healing you receive"},
        {cvar = "floatingCombatTextPetMeleeDamage_v2", label = "Pet Melee Damage", tooltip = "floatingCombatTextPetMeleeDamage_v2\n\nShow pet melee damage"},
        {cvar = "floatingCombatTextPetSpellDamage_v2", label = "Pet Spell Damage", tooltip = "floatingCombatTextPetSpellDamage_v2\n\nShow pet spell damage"},
        {cvar = "floatingCombatTextCombatLogPeriodicSpells_v2", label = "Periodic Spells", tooltip = "floatingCombatTextCombatLogPeriodicSpells_v2\n\nShow DoT/HoT ticks"}
    }
    
    settingsFrame.individualCheckboxes = {}
    local lastCheckbox = individualHeader
    
    for _, data in ipairs(cvars) do
        local checkbox = CreateFrame("CheckButton", nil, settingsFrame, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -8)
        checkbox.Text:SetText(data.label)
        
        checkbox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(data.tooltip)
            GameTooltip:Show()
        end)
        
        checkbox:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        checkbox:SetScript("OnClick", function(self)
            if not suppressCallbacks then
                local value = self:GetChecked() and "1" or "0"
                SetCVar(data.cvar, value)
                info(L.SETTINGS_CHANGED)
            end
        end)
        
        checkbox:SetScript("OnShow", function(self)
            self:SetChecked(GetCVar(data.cvar) == "1")
        end)
        
        table.insert(settingsFrame.individualCheckboxes, checkbox)
        lastCheckbox = checkbox
    end
    
    -- Reload UI button
    local reloadButton = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    reloadButton:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -24)
    reloadButton:SetSize(150, 25)
    reloadButton:SetText("Reload UI")
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    local reloadText = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    reloadText:SetPoint("LEFT", reloadButton, "RIGHT", 8, 0)
    reloadText:SetText("Click to reload the UI")
    
    -- Register with Settings API using Canvas layout.
    -- Canvas layout displays our custom frame directly, avoiding taint from Blizzard's
    -- internal Settings widgets that interact with protected frames.
    local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "CombatTextLite")
    settingsCategory = category.ID
    Settings.RegisterAddOnCategory(category)
end

-- Slash command
SLASH_COMBATTEXTLITE1 = "/ctl"
SlashCmdList["COMBATTEXTLITE"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+",""):gsub("%s+$","")
    if msg == "toggle" then
        -- Check if any CVar is enabled to determine toggle direction
        local damage = GetCVar("floatingCombatTextCombatDamage_v2") == "1"
        local healing = GetCVar("floatingCombatTextCombatHealing_v2") == "1"
        local petMelee = GetCVar("floatingCombatTextPetMeleeDamage_v2") == "1"
        local petSpell = GetCVar("floatingCombatTextPetSpellDamage_v2") == "1"
        local periodic = GetCVar("floatingCombatTextCombatLogPeriodicSpells_v2") == "1"
        
        -- If any are enabled, disable all; otherwise enable all
        local anyEnabled = damage or healing or petMelee or petSpell or periodic
        local newValue = anyEnabled and "0" or "1"

        SetCVar("floatingCombatTextCombatDamage_v2", newValue)
        SetCVar("floatingCombatTextCombatHealing_v2", newValue)
        SetCVar("floatingCombatTextPetMeleeDamage_v2", newValue)
        SetCVar("floatingCombatTextPetSpellDamage_v2", newValue)
        SetCVar("floatingCombatTextCombatLogPeriodicSpells_v2", newValue)

        info(newValue == "1" and L.FCT_ENABLED or L.FCT_DISABLED)
        info(L.SETTINGS_CHANGED)
    elseif msg == "config" or msg == "settings" then
        if settingsCategory then
            Settings.OpenToCategory(settingsCategory)
        else
            err(L.SETTINGS_NOT_FOUND)
        end
    elseif msg == "help" or msg == "" then
        info(L.USAGE_HELP)
    else
        info(L.USAGE)
    end
end

-- Init
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Create settings panel with error handling
        local success, errorMsg = pcall(CreateSettingsPanel)
        if not success then
            err("Failed to create settings panel: " .. tostring(errorMsg))
        end
        
        info(L.ADDON_LOADED)
        
        -- Unregister event - we only need to initialize once
        frame:UnregisterEvent("ADDON_LOADED")
    end
end)
