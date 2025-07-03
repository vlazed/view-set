---@module "viewset.server.setarray"
local setArray = include("viewset/server/setarray.lua")

---@type Entity
local ENTITY = FindMetaTable("Entity")
local EntitySetNoDraw = ENTITY.SetNoDraw

local system = {}

local entities = setArray({})
---@type {[string]: boolean}
local sets = {}

local function refreshViewSet()
	local names = {}
	for _, entity in ipairs(entities.array) do
		local name = entity.viewName
		if name and sets[name] ~= nil and not names[name] then
			names[name] = true
		end
	end

	for name, visible in pairs(sets) do
		sets[name] = Either(names[name], visible, nil)
	end
end

local viewsetID = "viewset_modifier"

---@param _ any
---@param ent ViewEntity
---@param data ViewEntityData
local function setViewName(_, ent, data)
	local name = data.viewName
	name = Either(name ~= nil and #string.gsub(name, "%s+", "") > 0, name, nil)
	ent.viewName = name
	duplicator.ClearEntityModifier(ent, viewsetID)
	if name then
		duplicator.StoreEntityModifier(ent, viewsetID, data)

		if not entities:Get(ent) then
			entities:Add(ent)
		end

		if sets[name] == nil then
			sets[name] = true
		end
	else
		if entities:Get(ent) then
			entities:Remove(ent)
			ent:SetNoDraw(false)
		end
	end

	refreshViewSet()
	system.viewChanged()
end

duplicator.RegisterEntityModifier(viewsetID, setViewName)

util.AddNetworkString("viewset_sendsnapshot")
function system.viewChanged()
	local setData = util.Compress(util.TableToJSON(sets))
	local entityList = {}
	for _, entity in ipairs(entities.array) do
		table.insert(entityList, { entity:EntIndex(), entity.viewName })
	end
	net.Start("viewset_sendsnapshot")
	net.WriteUInt(#setData, 16)
	net.WriteData(setData)
	net.Broadcast()
end

util.AddNetworkString("viewset_setviewname")
---@param ply Player
local function setViewNameNet(_, ply)
	local name = net.ReadString()
	local count = net.ReadUInt(13)
	local data = {viewName = name}
	for i = 1, count do
		local entity = net.ReadEntity()
		---@cast entity ViewEntity 
		setViewName(ply, entity, data)
	end
end
net.Receive("viewset_setviewname", setViewNameNet)

local drawFilter = {
	-- TODO: Add entities that should remain invisible
	-- and put this in a separate file if necessary
	-- Hat Painter entities
}

---@param entity Entity
---@param visible boolean
local function setDraw(entity, visible)
	if drawFilter[entity:GetClass()] then
		return
	end
	EntitySetNoDraw(entity, visible)
	for _, child in ipairs(entity:GetChildren()) do
		setDraw(child, visible)
	end
	---@diagnostic disable: undefined-field
	if entity:GetClass() == "prop_effect" and IsValid(entity.AttachedEntity) then
		setDraw(entity.AttachedEntity, visible)
	end
	---@diagnostic enable
end

util.AddNetworkString("viewset_setvisibility")
net.Receive("viewset_setvisibility", function()
	local name = net.ReadString()
	local visible = net.ReadBool()
	for _, entity in ipairs(entities.array) do
		if entity.viewName == name then
			setDraw(entity, visible)
		end
	end
end)

---@param entity ViewEntity
---@param name string?
function system.setName(entity, name)
	setViewName(nil, entity, { viewName = name })
end

function system.getSets()
	return sets
end

hook.Remove("EntityRemoved", "viewset_entityremoved")
hook.Add("EntityRemoved", "viewset_entityremoved", function(ent)
	if entities:Get(ent) then
		entities:Remove(entities.set[ent])
		refreshViewSet()
		system.viewChanged()
	end
end)

hook.Remove("InitPostEntity", "viewset_initialize")
hook.Add("InitPostEntity", "viewset_initialize", function()
	system.viewChanged()
end)

ViewSet.System = system
