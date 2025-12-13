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

local function RegexSearchSpellStrings(spell, possibleSpellStrings, affixes)
  -- print("[Goon's Library] Checking spell:", spell)

  for _, spellString in pairs(possibleSpellStrings) do
    -- print("[Goon's Library]  Comparing against base:", spellString)

    -- 1) exact match
    if spell == spellString then
      -- print("[Goon's Library]  -> Direct match found:", spellString)
      return true
    end

    -- prepare literal-safe base for pattern assembly
    local escBase = escape_lua_pattern(spellString)

    -- 2) affix-based pattern matches (aff.Pre and aff.Suf are Lua patterns)
    for _, aff in ipairs(affixes) do
      local pattern = aff.Pre .. escBase .. aff.Suf
      -- print("[Goon's Library]    Trying affix pattern:", pattern)
      if string.match(spell, pattern) then
        -- print("[Goon's Library]    -> Affix match found:", spell, "with pattern:", pattern)
        return true
      end
    end
  end

  -- print("[Goon's Library][Helper] Result for", spell, "= false")
  return false
end

-- ==================================== Party iteration helper ====================================

local function ApplyStatusToParty(status, source)
    local partyMembers = Osi.DB_PartyMembers:Get(nil)
    if not partyMembers then return end

    for _, row in ipairs(partyMembers) do
        local member = row[1]
        if Osi.IsPartyMember(member, 1) == 1 then
            Osi.ApplyStatus(member, status, 0, 1, source)
        end
    end
end

-- ==================================== Spells ====================================

local function TrackSpellcasts(spell)
  -- print("[Goon's Library][Check] Weapon enchant spell cast:", spell)
  local spellStrings = {
    "Shout_Shillelagh"
  }
  return RegexSearchSpellStrings(spell, spellStrings, DefaultAffixes)
end

-- ==================================== Listeners ====================================

EventCoordinator:RegisterEventProcessor("UsingSpellOnTarget", function(caster, target, spell, spellType, spellElement, storyActionID)
  -- print("[Goon's Library][Event] UsingSpellOnTarget -> caster:", caster, "target:", target, "spell:", spell)
  if TrackSpellcasts(spell)
      and Osi.HasPassive(caster, "Goon_Disenchant_Master_Passive") == 1
    then
      -- print("[Goon's Library]  -> Applying disenchant technical to trigger passive spell unlock")
      ApplyStatusToParty("GOON_DISENCHANT_TECHNICAL", caster)
    else
      -- print("[Goon's Library]  -> No matching spell check for:", spell)
  end
end)
