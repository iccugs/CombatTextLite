-- CombatTextLite v0.1
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
local suppressCallbacks = false

local function CreateSettingsPanel()
    local category, layout = Settings.RegisterVerticalLayoutCategory("CombatTextLite")
    settingsCategory = category.ID

    -- Master toggle
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
        info(L.SETTINGS_CHANGED)
    end
    
    local masterSetting = Settings.RegisterProxySetting(category, "PROXY_MASTER_TOGGLE", 
        Settings.VarType.Boolean, "Toggle All Combat Text", 
        Settings.Default.True, GetMasterValue, SetMasterValue)
    
    Settings.CreateCheckbox(category, masterSetting, "Enable or disable all combat text at once")

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Individual Settings"))

    -- Short labels, full CVar names in tooltips
    local cvars = {
        {cvar = "floatingCombatTextCombatDamage_v2", label = "Combat Damage", tooltip = "floatingCombatTextCombatDamage_v2\n\nShow damage you deal"},
        {cvar = "floatingCombatTextCombatHealing_v2", label = "Combat Healing", tooltip = "floatingCombatTextCombatHealing_v2\n\nShow healing you receive"},
        {cvar = "floatingCombatTextPetMeleeDamage_v2", label = "Pet Melee Damage", tooltip = "floatingCombatTextPetMeleeDamage_v2\n\nShow pet melee damage"},
        {cvar = "floatingCombatTextPetSpellDamage_v2", label = "Pet Spell Damage", tooltip = "floatingCombatTextPetSpellDamage_v2\n\nShow pet spell damage"},
        {cvar = "floatingCombatTextCombatLogPeriodicSpells_v2", label = "Periodic Spells", tooltip = "floatingCombatTextCombatLogPeriodicSpells_v2\n\nShow DoT/HoT ticks"}
    }

    for _, data in ipairs(cvars) do
        local setting = Settings.RegisterCVarSetting(category, data.cvar, Settings.VarType.Boolean, data.label)
        Settings.CreateCheckbox(category, setting, data.tooltip)
        Settings.SetOnValueChangedCallback(data.cvar, function()
            if not suppressCallbacks then
                info(L.SETTINGS_CHANGED)
            end
        end)
    end

    -- Add reload UI button using Canvas API
    do
        local initializer = CreateFromMixins(SettingsListElementInitializer)
        initializer:Init()
        
        local function OnButtonClick()
            ReloadUI()
        end
        
        layout:AddInitializer(CreateSettingsButtonInitializer(
            "Click to reload the UI",
            "Reload UI",
            OnButtonClick,
            nil,
            true
        ))
    end

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
