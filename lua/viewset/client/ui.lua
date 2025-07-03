local ui = {}

---Helper for DForm
---@param cPanel ControlPanel|DForm
---@param name string
---@param type "ControlPanel"|"DForm"
---@return ControlPanel|DForm
local function makeCategory(cPanel, name, type)
	---@type DForm|ControlPanel
	local category = vgui.Create(type, cPanel)

	category:SetLabel(name)
	cPanel:AddItem(category)
	return category
end

local WIDTH, HEIGHT = ScrW(), ScrH()

---@param cPanel DForm|ControlPanel
---@param panelProps PanelProps
---@param panelState PanelState
---@return PanelChildren
function ui.ConstructPanel(cPanel, panelProps, panelState)
	cPanel:Help("#tool.viewset.general")

	local viewName = cPanel:TextEntry("#tool.viewset.setname", "viewset_name")
	local viewList = vgui.Create("DPanel", cPanel)
	viewList.list = vgui.Create("DScrollPanel", viewList)
	cPanel:AddItem(viewList)
	viewList:SizeTo(-1, 400, 0.1)
	local viewRefresh = cPanel:Button("#tool.viewset.refresh", "")

	if IsValid(ViewSet.EntityList) then
		ViewSet.EntityList:Remove()
	end

	local frame = vgui.Create("DFrame")
	local list = vgui.Create("DListView", frame)
	frame:SetPos(WIDTH * 0.1, HEIGHT * 0.25)
	frame:SetSize(WIDTH * 0.125, HEIGHT * 0.5)
	frame:SetSizable(true)
	frame:SetTitle("Entity List")
	frame:ShowCloseButton(false)
	list:Dock(FILL)
	list:SetMultiSelect(true)
	list:AddColumn("Index")
	list:AddColumn("Model")
	list:AddColumn("Class")
	
	local refresh = vgui.Create("DButton", frame)
	refresh:SetText("#tool.viewset.entitylist.refresh")
	refresh:Dock(BOTTOM)
	ViewSet.EntityList = frame
	ViewSet.EntityList.list = list
	ViewSet.EntityList.refresh = refresh

	function viewList:PerformLayout()
		self.list:Dock(FILL)
	end

	return {
		viewName = viewName,
		viewList = viewList,
		viewRefresh = viewRefresh,
	}
end

local states = {
	[true] = Color(255, 255, 255, 255),
	[false] = Color(64, 64, 64, 255),
}

---@param entity Entity
---@param dList DListView
---@return DListView_Line
local function entityListLine(entity, dList)
	local line = dList:AddLine(entity:EntIndex(), entity:GetModel(), entity:GetClass())
	line.entity = entity
	---@cast line DListView_Line
	
	---@param name string
	local function sendList(name)
			local lines = dList:GetSelected()
			net.Start("viewset_setviewname")
			net.WriteString(name)
			net.WriteUInt(#lines, 13)
			for i = 1, #lines do
				net.WriteEntity(lines[i].entity)
			end
			net.SendToServer()

	end


	function line:OnRightClick()
		local menu = DermaMenu()

		menu:AddOption("Assign selected to set name", function()
			sendList(GetConVar("viewset_name"):GetString())
		end)
		menu:AddOption("Remove selected from set name", function()
			sendList("")
		end)
		menu:Open()
	end

	return line
end

---@param panelChildren PanelChildren
---@param panelProps PanelProps
---@param panelState PanelState
function ui.HookPanel(panelChildren, panelProps, panelState)
	local viewList = panelChildren.viewList
	local viewRefresh = panelChildren.viewRefresh

	local function refreshList()
		local sets = ViewSet.System.getSets()
		viewList.list:Clear()

		for name, visible in pairs(sets) do
			local viewPanel = vgui.Create("DButton", viewList.list)
			viewPanel:SetText(name)
			viewPanel:SetDark(true)
			viewPanel.visible = visible
			viewPanel:SetColor(states[visible])
			viewList.list:AddItem(viewPanel)
			viewPanel:Dock(TOP)

			function viewPanel:DoClick()
				viewPanel.visible = not viewPanel.visible
				viewPanel:SetColor(states[viewPanel.visible])
				ViewSet.System.setVisibility(name, viewPanel.visible)
			end
		end
	end

	function viewRefresh:DoClick()
		refreshList()
	end

	function ViewSet.System.viewChanged()
		refreshList()
	end

	local function refreshEntityList()
		if not IsValid(ViewSet.EntityList) then return end

		local dList = ViewSet.EntityList.list
		for i = 1, #dList:GetLines() do
			dList:RemoveLine(i)
		end
		for _, entity in ipairs(ents.GetAll()) do
			---@cast entity Entity
			if IsValid(entity) and not entity:IsWorld() and not entity:IsPlayer() and entity:EntIndex() > 0 then
				entity.viewset_entityline = entityListLine(entity, dList)
			end
		end

	end

	if ViewSet.EntityList then
		function ViewSet.EntityList.refresh:DoClick()
			refreshEntityList()
		end
	end

	hook.Remove("OnContextMenuOpen", "viewset_hookcontext")
	if IsValid(ViewSet.EntityList) then
		hook.Add("OnContextMenuOpen", "viewset_hookcontext", function()
			local tool = LocalPlayer():GetTool()
			if tool and tool.Mode == "viewset" then
				ViewSet.EntityList:SetVisible(true)
				ViewSet.EntityList:MakePopup()
			end
		end)
	end

	hook.Remove("OnContextMenuClose", "viewset_hookcontext")
	if IsValid(ViewSet.EntityList) then
		hook.Add("OnContextMenuClose", "viewset_hookcontext", function()
			ViewSet.EntityList:SetVisible(false)
			ViewSet.EntityList:SetMouseInputEnabled(false)
			ViewSet.EntityList:SetKeyboardInputEnabled(false)
		end)
	end

	refreshEntityList()
	refreshList()
end

hook.Remove("OnEntityCreated", "viewset_entitylist")
hook.Add("OnEntityCreated", "viewset_entitylist", function(ent)
	if IsValid(ViewSet.EntityList) and IsValid(ent) and ent:EntIndex() > 0 then
		ent.viewset_entityline = entityListLine(ent, ViewSet.EntityList.list)
	end
end)

hook.Remove("EntityRemoved", "viewset_entitylist")
hook.Add("EntityRemoved", "viewset_entitylist", function(ent, fullUpdate)
	if fullUpdate then return end

	if IsValid(ViewSet.EntityList) and IsValid(ent) then
		if IsValid(ent.viewset_entityline) then
			ViewSet.EntityList.list:RemoveLine(ent.viewset_entityline:GetID())
		else
			local list = ViewSet.EntityList.list
			local desiredIndex = ent:EntIndex()
			for i, line in ipairs (list:GetLines()) do
				---@cast line DListView_Line
				if line:GetSortValue(1) == desiredIndex then
					list:RemoveLine(i)
					break
				end
			end
		end
	end
end)

return ui
