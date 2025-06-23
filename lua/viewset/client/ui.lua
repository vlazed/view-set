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

---@param panelChildren PanelChildren
---@param panelProps PanelProps
---@param panelState PanelState
function ui.HookPanel(panelChildren, panelProps, panelState)
	local viewList = panelChildren.viewList
	local viewRefresh = panelChildren.viewRefresh

	print("rebuilt ui")

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

	refreshList()
end

return ui
