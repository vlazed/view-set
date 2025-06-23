ViewSet = ViewSet or {}

if SERVER then
	AddCSLuaFile("viewset/client/system.lua")
	AddCSLuaFile("viewset/client/ui.lua")

	include("viewset/server/system.lua")
else
	include("viewset/client/system.lua")
end
