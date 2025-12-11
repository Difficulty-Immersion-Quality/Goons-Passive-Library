Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    local modVars = Ext.Vars.GetModVariables(ModuleUUID)
    modVars.HasGoonLibraryPassives = modVars.HasGoonLibraryPassives or {}
    local assigned = modVars.HasGoonLibraryPassives

    local MasterPassives = {
        "Goon_Finesse_Throwing_Master_Passive",
        "Goon_DamageReroll_Throwing_Master_Passive",
        "Goon_Advantage_Throwing_Master_Passive",
        "Goon_IgnoreResistance_Throwing_Master_Passive",
        "Goon_Disenchant_Master_Passive"
    }

    -- lookup table for cleanup
    local MasterLookup = {}
    for _, p in ipairs(MasterPassives) do MasterLookup[p] = true end

    local function ApplyMasterPassives(entityID)
        if type(entityID) ~= "string" then return end
        assigned[entityID] = assigned[entityID] or {}

    -- STEP 1: REMOVE passives no longer in MasterPassives
        for savedPassive, _ in pairs(assigned[entityID]) do
            if not MasterLookup[savedPassive] then
                if Osi.HasPassive(entityID, savedPassive) == 1 then
                    Osi.RemovePassive(entityID, savedPassive)
                    -- print(string.format("[Goon's Library] Removed outdated passive %s from %s", savedPassive, entityID))
                end
                assigned[entityID][savedPassive] = nil
            end
        end

    -- STEP 2 — ADD new valid passives
        for _, passive in ipairs(MasterPassives) do
            -- Check if the passive actually exists in BG3
            local stat = Ext.Stats.Get(passive, nil, false)
            if stat == nil then
                -- print(string.format("[Goon's Library] WARNING: Passive does not exist: %s", passive))
            else
                if not assigned[entityID][passive] then
                    if Osi.HasPassive(entityID, passive) == 0 then
                        Osi.AddPassive(entityID, passive)
                        -- print(string.format("[Goon's Library] Added new passive %s to %s", passive, entityID))
                    end
                    assigned[entityID][passive] = true
                end
            end
        end
    end

    -- All party members
    for _, row in ipairs(Osi.DB_PartyMembers:Get(nil) or {}) do
        ApplyMasterPassives(row[1])
    end

    -- All ServerCharacters (NPCs)
    for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter") or {}) do
        local charID = entity.Uuid and entity.Uuid.EntityUuid
        if charID then
            ApplyMasterPassives(charID)
        end
    end
end)
