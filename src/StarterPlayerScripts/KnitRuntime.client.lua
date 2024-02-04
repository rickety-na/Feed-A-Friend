local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Rojo.Packages.Knit)

for i, v in pairs(ReplicatedStorage.Rojo.Controllers:GetDescendants()) do
    if v:IsA("ModuleScript") and v.Name:match("Controller$") then
        require(v)
    end
end

Knit.Start():catch(warn)