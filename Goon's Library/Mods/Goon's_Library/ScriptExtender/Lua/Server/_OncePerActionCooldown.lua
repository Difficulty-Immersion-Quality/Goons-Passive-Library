-- ==================================== How to use ====================================
-- Using the once per action cooldown in your passives and what not:
-- 1: Remove cooldowns from "Properties" in passives. This once per action stuff is mainly intended to replace OncePerAttack cooldowns.
-- 2: Create a status prefixed with "GOON_ONCEPERACTION_COOLDOWN_" and suffix it with something unique. We don't want it conflicting with another cooldown entry, you could even prefix your suffix like so "GOON_ONCEPERACTION_COOLDOWN_JEFF_FIRESPLOSION". (I don't know what the entry name character limit is...)
-- 3: Reference your status a condition where relevant:
-- "not HasStatus('GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix',context.Target)" or "not HasStatus('GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix',context.Source)"
-- 4: At the end of your functors apply the status for 1 turn:
-- "ApplyStatus(GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix, 100, 1)" or "ApplyStatus(SELF,GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix, 100, 1)"
-- 5: You can add my custom tooltip warning to explain the cooldown functionality.

-- A: Tooltip warnings:
-- &lt;LSTag Type="Image" Info="SoftWarning"/&gt; This effect can only trigger once per &lt;LSTag Tooltip="Action"&gt;action&lt;/LSTag&gt; for each target.
-- data "TooltipPermanentWarnings" "2e9bcfe0-6444-477c-a767-40e967ca7b55"

-- // &lt;LSTag Type="Image" Info="SoftWarning"/&gt; This effect can only trigger once per &lt;LSTag Tooltip="Action"&gt;action&lt;/LSTag&gt;.
-- data "TooltipPermanentWarnings" "d58d5fff-c41b-46a7-afde-9bfd4852eb0a"

-- B: Example status:
-- new entry "GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix"
-- type "StatusData"
-- data "StatusType" "BOOST"
-- data "StackId" "GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix"
-- data "StatusPropertyFlags" "DisablePortraitIndicator;DisableOverhead;DisableCombatlog;ApplyToDead"

-- ==================================== Once per action cooldown stuff ====================================
-- Jank city bitch jank jank city bitch

local trackedCaster = {}
local previousCaster = nil

Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID)

    local casterId = caster:sub(-36)

    print("[OncePerAction] UsingSpell fired")
    print("[OncePerAction] Current caster:", casterId)
    print("[OncePerAction] Previous caster:", previousCaster)

    if previousCaster then
        print("[OncePerAction] Applying technical status to:", previousCaster)
        Osi.ApplyStatus(previousCaster, "GOON_ONCEPERACTION_CASTER_TECHNICAL", 0, 1)
    else
        print("[OncePerAction] NO PREVIOUS CASTER STORED")
    end

    previousCaster = casterId
    print("[OncePerAction] Updated previousCaster =", previousCaster)
end)

-- ==================================== Oldge
-- Credit to Nzx for making this cleaner than I would have by a mile.

-- local trackedEntity = {}  -- [uuid] = { [statusId] = true }

-- Ext.Entity.OnCreate("ServerStatusApplyEvent", function(entity)
--     local comp = entity.ServerStatusApplyEvent
--     if not string.find(comp.StatusId, "^GOON_ONCEPERACTION_COOLDOWN_") then return end
--     local uuid = comp.Target.Uuid.EntityUuid
--     local set = trackedEntity[uuid] or {}
--     trackedEntity[uuid] = set
--     set[comp.StatusId] = true
-- end)

-- Ext.Entity.OnCreate("ServerStatusRemoveEvent", function(entity)
--     local comp = entity.ServerStatusRemoveEvent
--     if not string.find(comp.StatusId, "^GOON_ONCEPERACTION_COOLDOWN_") then return end
--     local uuid = comp.Target.Uuid.EntityUuid
--     local set = trackedEntity[uuid]
--     if not set then return end
--     set[comp.StatusId] = nil
--     if not next(set) then trackedEntity[uuid] = nil end
-- end)

-- Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(caster, target)
--     local casterSet = trackedEntity[caster:sub(-36)]
--     if casterSet then
--     for statusId in pairs(casterSet) do
--         Osi.RemoveStatus(caster, statusId)
--         end
--     end

--     local targetSet = trackedEntity[target:sub(-36)]
--     if not targetSet then return end
--     for statusId in pairs(targetSet) do
--         Osi.RemoveStatus(target, statusId)
--     end
-- end)
