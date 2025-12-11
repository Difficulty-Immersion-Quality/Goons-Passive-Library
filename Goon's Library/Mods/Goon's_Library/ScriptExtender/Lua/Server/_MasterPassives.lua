Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    local modVars = Ext.Vars.GetModVariables(ModuleUUID)
    modVars.HasGoonLibraryPassives = modVars.HasGoonLibraryPassives or {}
    local assigned = modVars.HasGoonLibraryPassives

    local MasterPassives = {
        "Goon_Finesse_Throwing_Master_Passive",
        "Goon_DamageReroll_Throwing_Master_Passive",
        "Goon_Advantage_Throwing_Master_Passive",
        "Goon_IgnoreResistance_Throwing_Master_Passive",
        "Goon_Remove_Shillelagh_Passive" -- Rename and make a global implementation
    }

    local function ApplyMasterPassives(entityID)
        if type(entityID) ~= "string" then return end
        if type(assigned[entityID]) ~= "table" then
            assigned[entityID] = {}
        end
        for _, passive in ipairs(MasterPassives) do
            if not assigned[entityID][passive] then
                local hasPassive = (Osi.HasPassive(entityID, passive) == 1)
                if not hasPassive then
                    Osi.AddPassive(entityID, passive)
                    print(string.format("[Goon's Library] Added passive %s to %s", passive, entityID)) -- Comment out once done testing
                end
                assigned[entityID][passive] = true
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
