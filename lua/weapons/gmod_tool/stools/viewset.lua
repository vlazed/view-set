TOOL.Category = "Render"
TOOL.Name = "#tool.viewset.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["name"] = ""

local firstReload = true
function TOOL:Think()
	if CLIENT and firstReload then
		self:RebuildControlPanel()
		firstReload = false
	end
end

---Set an entity's view set
---@param tr table|TraceResult
---@return boolean
function TOOL:LeftClick(tr)
	local entity = tr.Entity
	if not IsValid(entity) then
		return false
	end
	---@cast entity ViewEntity

	if CLIENT then
		return true
	end
	local name = self:GetClientInfo("name")

	ViewSet.System.setName(entity, name)

	return true
end

---Remove an entity from any viet set
---@param tr table|TraceResult
---@return boolean
function TOOL:RightClick(tr)
	local entity = tr.Entity
	if not IsValid(entity) then
		return false
	end
	---@cast entity ViewEntity

	if CLIENT then
		return true
	end

	ViewSet.System.setName(entity, nil)

	return true
end

if SERVER then
	return
end

TOOL:BuildConVarList()

---@module "viewset.client.ui"
local ui = include("viewset/client/ui.lua")

local panelState = {}

---@param cPanel ControlPanel|DForm
function TOOL.BuildCPanel(cPanel)
	---@type PanelProps
	local panelProps = {}
	local panelChildren = ui.ConstructPanel(cPanel, panelProps, panelState)
	ui.HookPanel(panelChildren, panelProps, panelState)
end

TOOL.Information = {
	{ name = "info" },
	{ name = "left" },
	{ name = "right" },
}
