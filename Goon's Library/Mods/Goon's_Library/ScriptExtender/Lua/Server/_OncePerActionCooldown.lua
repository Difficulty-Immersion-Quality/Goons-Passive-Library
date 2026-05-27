-- ==================================== How to use ====================================
-- Using the once per action cooldown in your passives and what not:
-- 1: Remove cooldowns from "Properties" in passives. This once per action stuff is mainly intended to replace OncePerAttack cooldowns.
-- 3: Create a status prefixed with "GOON_ONCEPERACTION_COOLDOWN_" and suffix it with something unique. We don't want it conflicting with another cooldown entry, you could even prefix your suffix like so "GOON_ONCEPERACTION_COOLDOWN_JEFF_FIRESPLOSION". (I don't know what the entry name character limit is...)
-- 3: Remove cooldowns from "Properties" in passives. This once per action stuff is mainly intended to replace OncePerAttack cooldowns.
-- 4: Reference your status a condition where relevant:
-- not HasStatus('GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix')
-- 5: At the end of your functors apply the status for 1 turn:
-- ApplyStatus(GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix, 100, 1)"
-- 6: You can add my custom tooltip warning to explain the cooldown functionality.

-- Tooltip warning:
-- &lt;LSTag Type="Image" Info="SoftWarning"/&gt; This effect can only trigger once per &lt;LSTag Tooltip="Action"&gt;action&lt;/LSTag&gt; for each target.
-- data "TooltipPermanentWarnings" "2e9bcfe0-6444-477c-a767-40e967ca7b55"

-- Example status:
-- new entry "GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix"
-- type "StatusData"
-- data "StatusType" "BOOST"
-- data "StackId" "GOON_ONCEPERACTION_COOLDOWN_ExampleUniqueSuffix"
-- data "StatusPropertyFlags" "DisablePortraitIndicator;DisableOverhead;DisableCombatlog;ApplyToDead"

-- ==================================== Once per action cooldown stuff ====================================
-- Credit to Nzx for making this cleaner than I would have by a mile.

local trackedTargets = {}  -- [uuid] = { [statusId] = true }

Ext.Entity.OnCreate("ServerStatusApplyEvent", function(entity)
    local comp = entity.ServerStatusApplyEvent
    if not string.find(comp.StatusId, "^GOON_ONCEPERACTIONCOOLDOWN_") then return end
    local uuid = comp.Target.Uuid.EntityUuid
    local set = trackedTargets[uuid] or {}
    trackedTargets[uuid] = set
    set[comp.StatusId] = true
end)

Ext.Entity.OnCreate("ServerStatusRemoveEvent", function(entity)
    local comp = entity.ServerStatusRemoveEvent
    if not string.find(comp.StatusId, "^GOON_ONCEPERACTIONCOOLDOWN_") then return end
    local uuid = comp.Target.Uuid.EntityUuid
    local set = trackedTargets[uuid]
    if not set then return end
    set[comp.StatusId] = nil
    if not next(set) then trackedTargets[uuid] = nil end
end)

Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target)
    local set = trackedTargets[target:sub(-36)]
    if not set then return end
    for statusId in pairs(set) do
        Osi.RemoveStatus(target, statusId)
    end
end)
