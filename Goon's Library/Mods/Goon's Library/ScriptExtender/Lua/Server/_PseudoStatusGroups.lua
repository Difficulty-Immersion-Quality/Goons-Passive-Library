local BleedingCondition = {
    "BLEEDING",
    "BARBED_ARROW",
    "HEAVY_BLEEDING"
}

local BurningCondition = {
    "BURNING",
    "BURNING_AZER",
    "BURNING_HOLY",
    "BURNING_HELLFIRE",
    "BURNING_LAVA",
    "BURNING_TRAPWALL",
    "FLAMING_SPHERE_AURA",
    "FLAMING_SPHERE_AURA_3",
    "FLAMING_SPHERE_AURA_4",
    "FLAMING_SPHERE_AURA_5",
    "FLAMING_SPHERE_AURA_6",
    "FLAMING_SPHERE_AURA_7",
    "FLAMING_SPHERE_AURA_8",
    "FLAMING_SPHERE_AURA_9",
    "FLAMING_SPHERE",
    "FLAMING_SPHERE_3",
    "FLAMING_SPHERE_4",
    "FLAMING_SPHERE_5",
    "FLAMING_SPHERE_6",
    "FLAMING_SPHERE_7",
    "FLAMING_SPHERE_8",
    "FLAMING_SPHERE_9",
    "HAV_MAG_INFERNAL_FIRE",
    "LOW_HOH_BOAR_BURNING_DAMAGE",
    "MAG_FIRE_HEAT",
    "MAG_INFERNAL_BURNING",
    "ORI_KARLACH_ENRAGE",
    "ORI_KARLACH_INFERNAL_FURY",
    "SEARING_SMITE",
    "WILD_MAGIC_BURNING"
}

local DeafenedCondition = {
    "DEAFENED",
    "DEAF",
    "DEAFNESS",
    "GOON_DEAFENED",
    "GOON_REAL_INJURY_GRIT_GLORY_DEAFNESS",
    "GOON_REAL_INJURY_GRIT_GLORY_PARTIAL_DEAFNESS"
}

local SilencedCondition = {
    "SILENCED",
    "SHA_SILENTLIBRARY_LIBRARIANSILENCE_STATUS",
    "LOW_VoicelessPenitent_Silenced",
    "SILENCED_MOVEMENT",
    "GARROTE_SILENCED",
    "GOON_SILENCED_AURA"
}


local function HasAnyStatus(statusTable, charID)
    for _, status in ipairs(statusTable) do
        if Osi.HasActiveStatus(charID, status) == 1 then
            return true
        end
    end
    return false
end

-- replaces the four Has*Condition one-liner wrappers; each entry drives one SG status
local PseudoGroups = {
    { condition = BleedingCondition, sgStatus = "SG_Bleeding" },
    { condition = BurningCondition,  sgStatus = "SG_Burning"  },
    { condition = DeafenedCondition, sgStatus = "SG_Deafened" },
    { condition = SilencedCondition, sgStatus = "SG_Silenced" },
}

-- built once at load so StatusIsRelevant is O(1); was four sequential ipairs scans per status event
local RelevantStatuses = {}
for _, group in ipairs(PseudoGroups) do
    for _, status in ipairs(group.condition) do
        RelevantStatuses[status] = true
    end
end

local function RunPseudoStatusGroups(charID)
    for _, group in ipairs(PseudoGroups) do
        if HasAnyStatus(group.condition, charID) then
            if Osi.HasActiveStatus(charID, group.sgStatus) == 0 then
                Osi.ApplyStatus(charID, group.sgStatus, -1, 1, charID)
            end
        else
            if Osi.HasActiveStatus(charID, group.sgStatus) == 1 then
                Osi.RemoveStatus(charID, group.sgStatus)
            end
        end
    end
end

local function StatusIsRelevant(status)
    return RelevantStatuses[status] == true
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(charID, status, causee, storyActionID)
    if StatusIsRelevant(status) then
        RunPseudoStatusGroups(charID)
    end
end)

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(charID, status, causee, storyActionID)
    if StatusIsRelevant(status) then
        RunPseudoStatusGroups(charID)
    end
end)
