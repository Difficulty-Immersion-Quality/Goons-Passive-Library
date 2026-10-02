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

local PseudoGroups = {
	{ condition = BleedingCondition, sgStatus = "SG_Bleeding" },
	{ condition = BurningCondition,  sgStatus = "SG_Burning"  },
	{ condition = DeafenedCondition, sgStatus = "SG_Deafened" },
	{ condition = SilencedCondition, sgStatus = "SG_Silenced" },
}

local PseudoGroupByStatus = {}
for _, group in ipairs(PseudoGroups) do
	for _, status in ipairs(group.condition) do
		PseudoGroupByStatus[status] = group
	end
end

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(charID, status)
	local group = PseudoGroupByStatus[status]
	if group and Osi.HasActiveStatus(charID, group.sgStatus) == 0 then
		Osi.ApplyStatus(charID, group.sgStatus, -1, 1, charID)
	end
end)

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(charID, status)
	local group = PseudoGroupByStatus[status]
	if group and not HasAnyStatus(group.condition, charID) and Osi.HasActiveStatus(charID, group.sgStatus) == 1 then
		Osi.RemoveStatus(charID, group.sgStatus)
	end
end)
