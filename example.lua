local Boost = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkinWalkeClub/Walke-Boost/main/boost.lua"))()

Boost.monitor(function(fps) print("fps:", fps) end)

local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.F then
		local now = Boost.toggle("low")
		print(now and "boost ON" or "boost OFF (restored)")
	end
end)
