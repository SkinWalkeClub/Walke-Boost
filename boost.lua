local B = {}
B._VERSION = "1.0.0"
B._AUTHOR = "Weegee_MLG / Skin Walke Team"
B.on = false
B.saved = {}
B.order = {}
B.count = 0

local env = (getgenv and getgenv()) or _G
local function gg(n) return env[n] or _G[n] end
local setfps = gg("setfpscap")

local NIL = setmetatable({}, { __tostring = function() return "nil" end })

local function save(o, p)
	local box = B.saved[o]
	if not box then box = {} B.saved[o] = box B.order[#B.order + 1] = o end
	if box[p] == nil then
		local ok, v = pcall(function() return o[p] end)
		box[p] = (ok and v ~= nil) and v or NIL
	end
end

local function set(o, p, v)
	save(o, p)
	pcall(function() o[p] = v end)
end

local emitters = { ParticleEmitter = 1, Trail = 1, Beam = 1, Smoke = 1, Fire = 1, Sparkles = 1 }

local function opt(o, s)
	local cn = o.ClassName
	if s.particles and emitters[cn] then set(o, "Enabled", false) return end
	if s.postfx and o:IsA("PostEffect") then set(o, "Enabled", false) return end
	if s.textures and (o:IsA("Decal") or o:IsA("Texture")) then
		if s.destroy then pcall(function() o:Destroy() end) else set(o, "Transparency", 1) end
		return
	end
	if o:IsA("SurfaceAppearance") then
		if s.pbr and s.destroy then pcall(function() o:Destroy() end) end
		return
	end
	if o:IsA("BasePart") then
		if s.materials then set(o, "Material", Enum.Material.Plastic) end
		if s.reflect then set(o, "Reflectance", 0) end
		if s.shadows then set(o, "CastShadow", false) end
		if s.meshDetail and cn == "MeshPart" then pcall(function() set(o, "RenderFidelity", Enum.RenderFidelity.Performance) end) end
	end
end

local function envKnobs(s)
	local lg = game:GetService("Lighting")
	if s.shadows then set(lg, "GlobalShadows", false) end
	if s.atmosphere then
		set(lg, "FogEnd", math.min((function() local ok, v = pcall(function() return lg.FogEnd end) return ok and v or 1e6 end)(), 500))
		local atm = lg:FindFirstChildOfClass("Atmosphere")
		if atm then if s.destroy then pcall(function() atm:Destroy() end) else set(atm, "Density", 0) end end
	end
	local tr = workspace:FindFirstChildOfClass("Terrain")
	if tr and s.terrain then
		set(tr, "Decoration", false)
		set(tr, "WaterWaveSize", 0)
		set(tr, "WaterWaveSpeed", 0)
		set(tr, "WaterReflectance", 0)
	end
	if s.quality then
		pcall(function()
			local r = settings().Rendering
			save(r, "QualityLevel")
			r.QualityLevel = Enum.QualityLevel.Level01
		end)
	end
	if s.fps and setfps then pcall(setfps, s.fps) end
end

local FULL = {
	particles = true, materials = true, reflect = true, shadows = true,
	meshDetail = true, textures = true, postfx = true, pbr = true,
	terrain = true, atmosphere = true, quality = true,
}
local function copy(t, extra)
	local o = {}
	for k, v in pairs(t) do o[k] = v end
	if extra then for k, v in pairs(extra) do o[k] = v end end
	return o
end

B.presets = {
	potato = copy(FULL, { destroy = true }),
	low = copy(FULL),
	balanced = { particles = true, reflect = true, shadows = true, postfx = true, terrain = true, quality = false, atmosphere = true },
}

function B.apply(opts)
	if B.on then B.restore() end
	if type(opts) == "string" then opts = B.presets[opts] or B.presets.low end
	opts = opts or B.presets.low
	B.opts = opts
	B.saved, B.order, B.count = {}, {}, 0
	envKnobs(opts)
	for _, d in ipairs(workspace:GetDescendants()) do opt(d, opts) B.count = B.count + 1 end
	local lg = game:GetService("Lighting")
	for _, d in ipairs(lg:GetDescendants()) do opt(d, opts) end
	B.conn = workspace.DescendantAdded:Connect(function(d) if B.on then opt(d, opts) end end)
	B.on = true
	return B.count
end

function B.restore()
	if B.conn then pcall(function() B.conn:Disconnect() end) B.conn = nil end
	for _, o in ipairs(B.order) do
		local box = B.saved[o]
		if box then for p, v in pairs(box) do if v ~= NIL then pcall(function() o[p] = v end) end end end
	end
	B.saved, B.order = {}, {}
	B.on = false
end

function B.toggle(opts) if B.on then B.restore() return false else B.apply(opts) return true end end

function B.monitor(cb)
	local rs = game:GetService("RunService")
	local sig = rs:FindFirstChild("RenderStepped") and rs.RenderStepped or (rs.Heartbeat or rs.Stepped)
	local ev = rs.RenderStepped or rs.Heartbeat
	local acc, frames, fps = 0, 0, 0
	return ev:Connect(function(dt)
		acc = acc + dt frames = frames + 1
		if acc >= 0.5 then fps = math.floor(frames / acc + 0.5) acc, frames = 0, 0 if cb then pcall(cb, fps) end end
	end)
end

return B
