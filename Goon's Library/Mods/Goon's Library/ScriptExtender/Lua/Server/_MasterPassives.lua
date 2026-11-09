local MASTER_PASSIVES = {
	"Goon_Finesse_Throwing_Master_Passive",
	"Goon_DamageReroll_Throwing_Master_Passive",
	"Goon_Advantage_Throwing_Master_Passive",
	"Goon_IgnoreResistance_Throwing_Master_Passive",
	"Goon_Remove_Shillelagh_Passive",
	-- "Goon_Disenchant_Master_Passive"
	-- TODO: Replace Shillelagh stuff with universal implementation
}

local MASTER_LOOKUP = {}
for _, passive in ipairs(MASTER_PASSIVES) do
	MASTER_LOOKUP[passive] = true
end

local availableMasterPassives
local legacyEntriesMigrated = false

local function getAvailableMasterPassives()
	if availableMasterPassives then return availableMasterPassives end

	availableMasterPassives = {}
	for _, passive in ipairs(MASTER_PASSIVES) do
		if Ext.Stats.Get(passive, nil, false) then
			table.insert(availableMasterPassives, passive)
		end
	end

	return availableMasterPassives
end

local function migrateLegacyEntries(assignedPassives)
	if legacyEntriesMigrated then return end

	local legacyEntityIDs = {}
	for entityID in pairs(assignedPassives) do
		if entityID ~= entityID:sub(-36) then
			table.insert(legacyEntityIDs, entityID)
		end
	end

	for _, legacyEntityID in ipairs(legacyEntityIDs) do
		local legacyPassives = assignedPassives[legacyEntityID]
		local entityID = legacyEntityID:sub(-36)

		if next(legacyPassives) then
			local entityPassives = assignedPassives[entityID] or {}
			for passive in pairs(legacyPassives) do
				entityPassives[passive] = true
			end
			assignedPassives[entityID] = entityPassives
		end

		assignedPassives[legacyEntityID] = nil
	end

	legacyEntriesMigrated = true
end

local function ApplyMasterPassives(entityID)
	entityID = entityID:sub(-36)

	local modVars = Ext.Vars.GetModVariables(ModuleUUID)
	modVars.HasGoonLibraryPassives = modVars.HasGoonLibraryPassives or {}
	local assignedPassives = modVars.HasGoonLibraryPassives
	migrateLegacyEntries(assignedPassives)

	local entityPassives = assignedPassives[entityID] or {}
	assignedPassives[entityID] = entityPassives

	for savedPassive in pairs(entityPassives) do
		if not MASTER_LOOKUP[savedPassive] then
			if Osi.HasPassive(entityID, savedPassive) == 1 then
				Osi.RemovePassive(entityID, savedPassive)
			end
			entityPassives[savedPassive] = nil
		end
	end

	for _, passive in ipairs(getAvailableMasterPassives()) do
		if not entityPassives[passive] then
			if Osi.HasPassive(entityID, passive) == 0 then
				Osi.AddPassive(entityID, passive)
			end
			entityPassives[passive] = true
		end
	end

	if not next(entityPassives) then
		assignedPassives[entityID] = nil
	end
end

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
	local processed = {}

	for _, row in ipairs(Osi.DB_PartyMembers:Get(nil)) do
		local entityID = row[1]:sub(-36)
		processed[entityID] = true
		ApplyMasterPassives(entityID)
	end

	for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
		local entityID = entity.Uuid.EntityUuid:sub(-36)
		if not processed[entityID] then
			ApplyMasterPassives(entityID)
		end
	end
end)

Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", ApplyMasterPassives)
