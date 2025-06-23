local system = {}

---@type {[string]: boolean}
local sets = {}

net.Receive("viewset_sendsnapshot", function(len, ply)
	local setLength = net.ReadUInt(16)
	local setData = net.ReadData(setLength)

	sets = util.JSONToTable(util.Decompress(setData))

	ViewSet.System.viewChanged()
end)

---@param name string
---@param visible boolean
function system.setVisibility(name, visible)
	if sets[name] ~= nil then
		sets[name] = visible
	end
	net.Start("viewset_setvisibility")
	net.WriteString(name)
	net.WriteBool(visible)
	net.SendToServer()
end

function system.getSets()
	return sets
end

function system.viewChanged() end

ViewSet.System = system
