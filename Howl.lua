local args = {
    [1] = {
        ["player"] = game:GetService("Players").LocalPlayer
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("UseWerewolfHowlAbility"):InvokeServer(unpack(args))
