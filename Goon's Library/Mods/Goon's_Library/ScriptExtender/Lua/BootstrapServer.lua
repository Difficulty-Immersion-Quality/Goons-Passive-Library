--- @type RegisterVariableOptions
local opts = {
    Server = true,
    Client = false,
    WriteableOnServer = true,
    WriteableOnClient = false,
    Persistent = true,
    SyncToClient = false,
    SyncToServer = true,
    SyncOnWrite = false,
    DontCache = false
}
Ext.Vars.RegisterModVariable(ModuleUUID, "HasGoonLibraryPassives", opts)

Ext.Require("Server/_MasterPassives.lua")
Ext.Require("Server/_PseudoStatusGroups.lua")
-- Ext.Require("Server/_WeaponEnchantTracking.lua")
