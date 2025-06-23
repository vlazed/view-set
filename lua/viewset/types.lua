---@meta

---@class ViewListPanel: DPanel
---@field list DScrollPanel

---@class ViewEntity: Entity
---@field viewName string?

---@alias ViewEntityInfo {[1]: Entity, [2]: string}

---@class PanelState
---@field viewName string

---@class PanelChildren
---@field viewList ViewListPanel
---@field viewName DTextEntry
---@field viewRefresh DButton

---@class ViewEntityData
---@field viewName string?

---@class PanelProps
