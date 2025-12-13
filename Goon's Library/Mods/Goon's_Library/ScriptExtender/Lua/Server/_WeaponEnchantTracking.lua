-- ==================================== Regex helper ====================================

-- Escape Lua pattern magic characters so spell base is treated literally
local function escape_lua_pattern(s)
  return s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Default affix patterns (adjust/add as needed)
local DefaultAffixes = {
  { Pre = "^",    Suf = "_.*$" },   -- base followed by "_" + anything
  { Pre = "^.-_", Suf = "$"    },   -- anything_ before base (ending at base)
  { Pre = "^.-_", Suf = "_.*$" },   -- anything_ before base and _anything after
}

function Goon_InjurySpellCheck_Helper(spell, possibleSpellStrings, affixes)
  -- print("[Helper] Checking spell:", spell)

  for _, spellString in pairs(possibleSpellStrings) do
    -- print("  Comparing against base:", spellString)

    -- 1) exact match
    if spell == spellString then
      -- print("  -> Direct match found:", spellString)
      return true
    end

    -- prepare literal-safe base for pattern assembly
    local escBase = escape_lua_pattern(spellString)

    -- 2) affix-based pattern matches (aff.Pre and aff.Suf are Lua patterns)
    for _, aff in ipairs(affixes) do
      local pattern = aff.Pre .. escBase .. aff.Suf
      -- print("    Trying affix pattern:", pattern)
      if string.match(spell, pattern) then
        -- print("    -> Affix match found:", spell, "with pattern:", pattern)
        return true
      end
    end
  end

  -- print("[Helper] Result for", spell, "= false")
  return false
end

-- ==================================== Party iteration helper ====================================

function ApplyStatusToParty(status, source)
    local partyMembers = Osi.DB_PartyMembers:Get(nil)
    if not partyMembers then return end

    for _, row in ipairs(partyMembers) do
        local member = row[1]
        if Osi.IsPartyMember(member, 1) == 1 then
            Osi.ApplyStatus(member, status, 1, 1, source)
        end
    end
end

-- ==================================== Spells ====================================

function Goon_Lesser_Restoration_Spell_Check(spell)
  -- print("[Check] Lesser Restoration:", spell)
  local spellStrings = {
    "Shout_Shillelagh"
  }
  return Goon_InjurySpellCheck_Helper(spell, spellStrings, DefaultAffixes)
end

-- ==================================== Statuses ====================================

-- function Goon_XXXXXXXXXXXXXXX_Status_Check(status)
--   -- print("[StatusCheck] XXXXXXXXXXXXXXX:", status)
--   return status == 'XXXXXXXXXXXXXXX'
-- end

-- ==================================== Listeners ====================================

EventCoordinator:RegisterEventProcessor("UsingSpellOnTarget", function(caster, target, spell, spellType, spellElement, storyActionID)
  -- print("[Event] UsingSpellOnTarget -> caster:", caster, "target:", target, "spell:", spell)
  local partyMembers = Osi.DB_PartyMembers:Get(nil)

  if Goon_Lesser_Restoration_Check(spell) then
    -- print("  -> Applying Lesser Restoration Injury Removal")
    Osi.ApplyStatus(target, "GOON_LESSER_RESTORATION_INJURY_REMOVAL", 1, 1, caster)
  elseif Goon_Greater_Restoration_Check(spell) then
    -- print("  -> Applying Greater Restoration Injury Removal")
    Osi.ApplyStatus(target, "GOON_GREATER_RESTORATION_INJURY_REMOVAL", 1, 1, caster)
  else
    -- print("  -> No matching spell check for:", spell)
  end
end)

-- Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
--   -- print("[Event] StatusApplied -> object:", object, "status:", status, "causee:", causee)
--   if Goon_XXXXXXXXXXXXXXX_Status_Check(status) then
--     -- print("  -> Applying XXXXXXXXXXXXXXX")
--     Osi.ApplyStatus(object, "XXXXXXXXXXXXXXX", 1, 1, causee)
--   end
-- end)

-- Listener for status application
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
    if status == "GOON_SHILLELAGH_DUMMY_UNLOCK_REMOVAL" then
        -- Iterate through all party members
        local partyMembers = Osi.DB_PartyMembers:Get(nil)
        if partyMembers then
            for _, member in pairs(partyMembers) do
                local partyMember = member[1] -- Extract the UUID from the table entry
                if partyMember ~= object and Osi.IsPartyMember(partyMember, 1) == 1 then
                    Osi.ApplyStatus(partyMember, "GOON_SHILLELAGH_DUMMY_UNLOCK_REMOVAL_2", 1, 1, causee)
                end
            end
        end
    end
end)