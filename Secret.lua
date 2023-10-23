local players = game:GetService("Players")
local lplr = players.LocalPlayer
local replicatedstorage = game:GetService("ReplicatedStorage")
local vampireRemote = replicatedstorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged:WaitForChild("CursedCoffinApplyVampirism")

local function vampirefunc(plr)
    repeat task.wait() until plr:GetAttribute("PlayerConnected") and plr.Character and plr.Character:FindFirstChild("Head")
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        vampireRemote:FireServer({player = plr})
    end)
    vampireRemote:FireServer({player = plr})
end

for i,v in players:GetPlayers() do 
    if v ~= lplr then
       task.spawn(vampirefunc, v) 
    end
end 

players.PlayerAdded:Connect(vampirefunc)
